import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart' hide ImageFormat;
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/progress.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/boardview/boardview_screen.dart';
import 'package:workcake/components/channel/channel_info.dart';
import 'package:workcake/components/channel/invite_channel.dart';
import 'package:workcake/components/chat_item.dart';
import 'package:workcake/components/record_audio.dart';
import 'package:workcake/components/sticker_emoji.dart';
import 'package:workcake/components/thread_view.dart';
import 'package:workcake/components/typing.dart';
import 'package:workcake/emoji/emoji.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/message.dart';
import 'package:workcake/src/mention_view_new.dart';
import '../desktop/components/create_poll.dart';
import '../flutter_mentions.dart';
import '../generated/l10n.dart';
import 'work_screen/issues.dart';
import 'dart:ui' as ui;


class Conversation extends StatefulWidget {
  final id;
  final hideInput;
  final changePageView;
  final isNavigator;
  final PanelController? panelController;

  Conversation({
    Key? key,
    @required this.id,
    this.hideInput = false,
    required this.changePageView,
    this.isNavigator,
    this.panelController
  }) : super(key: key);
  @override
  ConversationState createState() => ConversationState();
}

class ConversationState extends State<Conversation> {
  ScrollController _scrollController = ScrollController();
  List suggestCommands = [];
  Map dataMessageSelected = {};
  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
  List<Map<String, dynamic>> suggestionMentions = [];
  String textInput = "";
  List images = [];
  final picker = ImagePicker();
  CameraPickerTextDelegate textDelegateCamera = EnglishCameraPickerTextDelegate();
  GlobalKey keyMessageToJump = GlobalKey();
  bool hasJump = false;
  final heightInputController =  StreamController<double>.broadcast(sync: false);
  double heightInput = 55.0;
  bool isBlock = false;
  bool isShow = false;
  bool isEdit = false;
  Timer? _debounce;
  double heightKeyboard = 0.0;
  StreamController<double> heightKeyboadStream = StreamController<double>.broadcast(sync: false);

  PanelController? get panelController => widget.panelController;
 
  @override
  void didUpdateWidget(oldWidget){
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id){
      getLastEdited();
      _scrollController.jumpTo(0);
      isShow = false;
    }
  }

  loadAssets() async {
    List<AssetEntity> resultList = await Provider.of<Work>(context, listen: false).openFileSelector(context);
    this.setState(() { images = resultList; });
    List results = await Utils.handleFileData(resultList);
    if (!mounted) return;
    images = results.where((e) => e.isNotEmpty).toList();
    key.currentState!.focusNode.requestFocus();
  }

  openCamera() async {
    final AssetEntity? pickedFile = await Provider.of<Work>(context, listen: false).openCamera(context);
    if (pickedFile == null) return; 
    this.setState(() { images = [pickedFile]; });
    List results = await Utils.handleFileData([pickedFile]);

    if (!mounted) return;
    images = results.where((e) => e.isNotEmpty).toList();
  }

  void _scrollToTop() {
    if (_scrollController.offset <=  400 || _scrollController.offset > 0) {
      _scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.linear);
    } else if (_scrollController.offset > 400) {
      _scrollController.animateTo(0,
        duration: Duration(seconds: 2), curve: Curves.linear);
    }
  }

  String uint8ListTob64(Uint8List uint8list) {
    String base64String = base64Encode(uint8list);
    return base64String;
  }

  processDocument() async {
    try {
      final List<PlatformFile> files = await Utils.pickedFileOther();
      final List stateFile = images;
      setState(() {
        images = [] + stateFile + files;
      });

      List results = await Utils.handleFileOtherData(files);
      if (!mounted) return;

      Future.delayed(Duration(milliseconds: 200), () {
        this.setState(() {
          images = stateFile + results.where((e) => e.isNotEmpty).toList();
        });
      });
    } catch (e, t){
      print("fileItems: $e, $t");
    }
  }

  removeImage(index) {
    List list = images;
    list.removeAt(index);
    this.setState(() {
      images = list;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = new ScrollController()..addListener(_scrollListener);
    AssetPicker.registerObserve();
    getLastEdited();
    Work.eventChannelStream.listen((call) async {
      try {
        double devicePixelRatio = ui.window.devicePixelRatio;
        Map dataNative = jsonDecode(call);
        if (dataNative["type"] == "height_keyboard"){
          heightKeyboard = (dataNative["height"] ?? 0.0).toDouble() / devicePixelRatio;
          if (heightKeyboard < 0) heightKeyboard = 0.0;
          heightKeyboadStream.add(heightKeyboard);
          return null;        
        }
        return null;        
      } catch (e, t) {
        print("________$e, $t");
      }
    });
  }

  getLastEdited() async {
    Box box = await Hive.openBox('drafts');
    var lastEdited = box.get('lastEdited');

    if (lastEdited != null) {
      final index = lastEdited.indexWhere((e) => e["id"] == widget.id);
      key.currentState!.controller.document = Document();
      if (index != -1) {
        Document newDoc = Document.fromJson(lastEdited[index]["text"]);

        if(newDoc.toPlainText().trim() != '@') {
          key.currentState!.controller.document = newDoc;
          key.currentState!.controller.updateSelection(
            TextSelection.collapsed(offset: key.currentState!.controller.document.toPlainText().length), ChangeSource.LOCAL
          );
        }
      }
    }
    key.currentState!.focusNode.unfocus();
  }

  saveChangesToHive() async {
    Box box = await Hive.openBox('drafts');
    var lastEdited = box.get('lastEdited');
    final Document doc = key.currentState!.document;
    List changes;

    if (lastEdited == null) {
      changes = [{
        "id": widget.id,
        "text": doc.toDelta().toJson(),
      }];
    } else {
      changes = List.from(lastEdited);
      final index = changes.indexWhere((e) => e["id"] == widget.id);

      if (index != -1) {
        changes[index] = {
          "id": widget.id,
          "text": doc.toPlainText().trim() != "" ? doc.toDelta().toJson() : Document().toDelta().toJson(),
        };
      } else {
        changes.add({
          "id": widget.id,
          "text": doc.toPlainText().trim() != "" ? doc.toDelta().toJson() : Document().toDelta().toJson(),
        });
      }
    }

    box.put('lastEdited', changes);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    if(_debounce != null) {
      _debounce?.cancel();
    }

    super.dispose();
  }

  _scrollListener() {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentChannel = Provider.of<Channels>(context, listen: false).getChannel(widget.id);
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).getDataWorkspace(currentChannel["workspace_id"]);
    

    if (_scrollController.position.extentAfter < 10 && _scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      Provider.of<Messages>(context, listen: false).loadMoreMessages(token, currentWorkspace["id"], currentChannel["id"]);
    }

    if (_scrollController.position.extentBefore < 10 && _scrollController.position.userScrollDirection == ScrollDirection.forward){
      Provider.of<Messages>(context, listen: false).getMessageChannelUp(token, currentChannel["id"], currentWorkspace["id"], isNotifyListeners: true);
    }
  }

  _sendSticker(data) {
    var auth = Provider.of<Auth>(context, listen: false);
    var user  =  Provider.of<User>(context, listen: false);
    final currentChannel = Provider.of<Channels>(context, listen: false).getChannel(widget.id);
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).getDataWorkspace(currentChannel["workspace_id"]);

    var dataMessage = {
      "channel_thread_id": null,
      "key": Utils.getRandomString(20),
      "message": '',
      "attachments": [{
        'type': 'sticker',
        'data': data
      }],
      "channel_id":  widget.id,
      "workspace_id": currentWorkspace['id'],
      "user_id": auth.userId,
      "is_system_message": false,
      "full_name": user.currentUser["full_name"] ?? "",
      "avatar_url": user.currentUser["avatar_url"] ?? "",
    };

    dataMessage = {
      ...dataMessage,
      "inserted_at": DateTime.now().add(new Duration(hours: -7)).toIso8601String()
    };
    Provider.of<Messages>(context, listen: false).sendMessageWithImage([], dataMessage, auth.token);
  }

  _sendMessage(token, workspaceId, message) async {
    _scrollToTop();
    var shortCut = message.split(" ")[0];
    var user  =  Provider.of<User>(context, listen: false);
    var auth = Provider.of<Auth>(context, listen: false);
    final currentCommands = Provider.of<Channels>(context, listen: false).currentCommand;
    final currentCommand = message != "" ? currentCommands.where((element) {return element["short_cut"] == shortCut.substring(1);}).toList() : [];

    if (currentCommand.length > 0 && dataMessageSelected["id"] == null) {
      var messages = message.split(" ");
      var listParams = [];

      for (int i = 1; i <= messages.length - 1; i++ ) {
        listParams.add(messages[i]);
      }


      var c  =  currentCommand[0];
      var newList = [];

      if (c["command_params"].length == listParams.length) {
        for (int i = 0; i <= listParams.length - 1; i++) {
          newList.add(
            {
              c["command_params"][i]["key"]: listParams[i]
            }
          );
        }
      }

      c["command"] = message;
      c["channel_id"] = widget.id;
      c["workspace_id"] = workspaceId;
      c["to_command_params"] = newList;
      c["key"] =  Utils.getRandomString(20);
      var messageDummy = {
        "message": "",
        "attachments": [{
          "type": "bot",
          "data": {...c, "command": message.replaceFirst("/", "")},
          "bot": {"id": c["app_id"]}
        }],
        "channel_id":  widget.id,
        "workspace_id": workspaceId,
        "key": Utils.getRandomString(20),
        "id": Utils.generateUUIDfromTimestamp(),
        "user_id": auth.userId,
        "user": user.currentUser["full_name"] ?? "",
        "avatar_url": user.currentUser["avatar_url"] ?? "",
        "inserted_at": DateTime.now().add(new Duration(hours: -7)).toIso8601String(),
        "is_system_message": false
      };
      Provider.of<Messages>(context, listen: false).checkNewMessage(messageDummy);
      Provider.of<Messages>(context, listen: false).excuteCommand(token, workspaceId, widget.id, {...c, "message_id": messageDummy["message_id"]});
      setState(() {
        suggestCommands = [];
      });
    } else {
      // var user  =  Provider.of<User>(context, listen: false);
      Auth auth = Provider.of<Auth>(context, listen: false);
      List checkingShareMessage = images.where((element) => element["mime_type"] == "share").toList();
      List attachments = [];

      final Document document = key.currentState!.document;

      if(!Utils.checkedTypeEmpty(document.toPlainText().trim()) && images.isEmpty) return;

      attachments = Utils.checkedTypeEmpty(document.toPlainText().trim()) ? [{
        'type': "mention",
        'data': Utils.parseQuillController(document),
        'jsonText': document.toDelta().toJson()
      }] : [];


      Map dataMessage = {
        "channel_thread_id": null,
        "key": Utils.getRandomString(20),
        "message": '',
        "attachments": attachments + checkingShareMessage,
        "channel_id":  widget.id,
        "workspace_id": workspaceId,
        "user_id": auth.userId,
        "is_system_message": false,
        "full_name": user.currentUser["full_name"] ?? "",
        "avatar_url": user.currentUser["avatar_url"] ?? "",
      };

      if (dataMessage["message"] == "" && dataMessage["attachments"].length == 0 && images.length == 0) return;

      if (dataMessageSelected["id"] == null){
        dataMessage = {
          ...dataMessage,
          "inserted_at": DateTime.now().add(new Duration(hours: -7)).toIso8601String()
        };
        Provider.of<Messages>(context, listen: false).sendMessageWithImage(images, dataMessage, token);
      } else {
        dataMessage["message_id"] = dataMessageSelected["id"];
        dataMessage["id"] = dataMessageSelected["id"];
        Provider.of<Messages>(context, listen: false).newUpdateChannelMessage(token, dataMessage, images);
        setState(() {
          dataMessageSelected = {};
        });
      }
    }

    this.setState(() { images = []; });
    key.currentState!.controller.document = Document();
  }

  disconnectChannel() {
    final auth = Provider.of<Auth>(context, listen: false);
    key.currentState!.controller.document = Document();
    // setState(() {
      // openKeyboard = false;
    // });

    auth.channel.push(
      event: "disconnect_channel",
      payload: {"channel_id": widget.id}
    );
  }

  checkCommand(value, context){
    final currentCommand  =  Provider.of<Channels>(context, listen: false).currentCommand;
    // get list Commad short_cut
    if(value.length ==0 || value.substring(0,1) != "/"){
      setState(() {
        suggestCommands= [];
      });
    }
    else {
      var result  = currentCommand.where((element){
        return element["short_cut"].contains("${value.substring(1)}");}).toList();
      setState(() {
        suggestCommands= result;
      });
    }
  }

  onEditMessage(keyM) {
    String messageId  =  keyM.split("__")[1];
    final channelId = Provider.of<Channels>(context, listen: false).currentChannel["id"];
    List messagesData = Provider.of<Messages>(context, listen: false).data.where((element) => element["channelId"] == channelId).toList();
    List data = messagesData.length > 0 ? messagesData[0]["messages"] : [];
    // moi ho tro revert image, text, mentions
    if (data.length > 0) {
      int indexMessage = data.indexWhere((e) => e["id"] == messageId);
      if (indexMessage != -1) {
        var dataM = data[indexMessage];
        int index = (dataM['attachments'] ?? []).indexWhere((e) => e['type'] == 'mention');

        if(index != -1) {
          isEdit = true;
          final dataJson = dataM['attachments'][index]['jsonText'];
          key.currentState!.controller.document = Document();

          if(dataJson != null) {
            key.currentState!.controller.document = Document.fromJson(dataJson);
            key.currentState!.controller.updateSelection(TextSelection.collapsed(offset: key.currentState!.document.toPlainText().length), ChangeSource.LOCAL);
          } else {
            var mentionData = dataM['attachments'][index]["data"];
            List dataJsonText = [];

            for(final item in mentionData) {
              if (['user', 'all', 'issue'].contains(item["type"])) {
                String markMention = '=======${item["trigger"] ?? "@"}/${item["value"]}^^^^^${item["name"]}^^^^^${item["type"] ?? ((item["id"].length < 10) ? "all" : "user")}+++++++';

                dataJsonText.add({
                  "insert": (item["trigger"] ?? "@") + item["name"],
                  "attributes": {
                    "mention": markMention
                  }
                });
              } else {
                dataJsonText.add({
                  "insert": item["value"]
                });
              }
            }

            dataJsonText.add({
              "insert": ' \n'
            });

            key.currentState!.controller.document = Document.fromJson(dataJsonText);
            key.currentState!.controller.updateSelection(TextSelection.collapsed(offset: key.currentState!.document.toPlainText().length), ChangeSource.LOCAL);
          }
        } else {
          String message = dataM['message'];
          key.currentState!.controller.document.insert(0, message);
          key.currentState!.controller.updateSelection(TextSelection.collapsed(offset: message.length), ChangeSource.LOCAL);
        }

        images = dataM["attachments"] != null ? dataM["attachments"].where((ele) => ele["mime_type"] != "block_code" && ele["type"] != "mention" && ele["type"] != 'preview').toList() : [];
        key.currentState!.focusNode.requestFocus();
        dataMessageSelected = dataM;
      }
    }
  }

  copyMessage(keyM) {
    String messageId  =  keyM.split("__")[1];
    final channelId = Provider.of<Channels>(context, listen: false).currentChannel["id"];
    List messagesData = Provider.of<Messages>(context, listen: false).data.where((element) => element["channelId"] == channelId).toList();
    List data = messagesData.length > 0 ? messagesData[0]["messages"] : [];
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    String message = "";
    if (data.length > 0) {
      int indexMessage = data.indexWhere((e) => e["id"] == messageId);
      if (indexMessage != -1) {
        var dataM = data[indexMessage];
        message = dataM["message"];
        int index = (dataM['attachments'] ?? []).indexWhere((e) => e['type'] == 'mention');

        if(index != -1) {
          List mentionData = dataM['attachments'][index]["data"] ?? [];

          for(final item in mentionData) {
            if (['user', 'all', 'issue'].contains(item["type"])) {
              message += (item["trigger"] ?? "@") + item["name"];
            } else if(item['type'] == 'block_code') {
              if(item['isThreeBackstitch'] ?? false) {
                message += '\n' + item["value"] + '\n';
              } else {
                message += item["value"];
              }
            } else {
              message += item["value"];
            }
          }
        }
      }
    }

    Clipboard.setData(new ClipboardData(text: message));
    Fluttertoast.showToast(
      msg: "copied",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D),
      textColor: isDark ? Color(0xff2E2E2E) : Colors.white,
      fontSize: 16.0
    );
  }

  getDataMentions() {
    List channelMembers = Provider.of<Channels>(context, listen: false).channelMember;
    if (channelMembers.length > 0) setState(() {
      suggestionMentions = [{'id': "${widget.id}", 'display': 'all', 'full_name': 'all', 'photo': '', "type": "all"}];

      for (var i = 0 ; i < channelMembers.length; i++){
        Map<String, dynamic> item = {
          'id': channelMembers[i]["id"],
          "type": "user",
          'display': Utils.getUserNickName(channelMembers[i]["id"]) ?? channelMembers[i]["full_name"],
          'full_name': Utils.getUserNickName(channelMembers[i]["id"]) ?? channelMembers[i]["full_name"],
          'photo': channelMembers[i]["avatar_url"]
        };
        suggestionMentions += [item];
      }
    });
    else setState(() {
      suggestionMentions = [];
    });
  }

  onSelectCommand(commad, commandParams) {
    final String space = (commandParams != null && commandParams.length > 0) ? "" : " ";
    String newString = commad + space;
    key.currentState!.controller.document = Document();
    key.currentState!.document.insert(0, newString);
    key.currentState!.controller.updateSelection(TextSelection.collapsed(offset: newString.length), ChangeSource.LOCAL);
    key.currentState!.focusNode.requestFocus();
  }

  onFirstFrameMessageSelectedToJumpDone(BuildContext? cont, int? time, String? idMessage){
    if (hasJump) return;
    final messageIdToJump = Provider.of<Messages>(context, listen: false).messageIdToJump;
    try {
      if (Utils.checkedTypeEmpty(messageIdToJump)) {
        final currentChannel = Provider.of<Channels>(context, listen: false).getChannel(widget.id);
        final messagesData = Provider.of<Messages>(context, listen: false).data.where((element) => element["channelId"].toString() == currentChannel["id"].toString()).toList();
        final data = messagesData.length > 0 ? messagesData[0]["messages"] : [];
        int index  = data.indexWhere((ele) => ele["id"] == messageIdToJump);
        if (index == -1 || time == null || idMessage == null) return;
        int currentT = data[index]["current_time"];
        if (time >=currentT) jumpToContext(cont, idMessage, isMessageJump: time == currentT);
        if (time <= currentT) {
          Provider.of<Messages>(context, listen: false).setMessageIdToJump("");
          hasJump = true;
        }
      }
    } catch (e) {
      print("______ $e");
    }
  }

  jumpToContext(BuildContext? c, String idMessage, {bool isMessageJump = false}) {
    BuildContext? messageContext = c;
    if (messageContext == null) return;
    final renderObejctMessage = messageContext.findRenderObject() as RenderBox;
    try {
      double heightMessage = 0.0, heightScrollTo = 0.0;
      double heightContentRenderMessage = MediaQuery.of(context).size.height - 184; // 300 bao gon header + input
      var offsetGlobal = renderObejctMessage.localToGlobal(Offset.zero);
      if (isMessageJump) {
        heightMessage = messageContext.size!.height;
        if (heightMessage < heightContentRenderMessage) {
          heightScrollTo = (heightContentRenderMessage - heightMessage) / 2  ;
        } else {
          heightScrollTo = heightContentRenderMessage - heightMessage;
        }
      }
      var scrolllOffset = _scrollController.offset - offsetGlobal.dy + heightScrollTo;
      _scrollController.animateTo(scrolllOffset >= 0 ? scrolllOffset : 0.0, duration: Duration(milliseconds: 200), curve: Curves.ease);
    } catch (e) {
      print("jumpToContext: $e");
    }
  }

  getSuggestionIssue() {
    List preloadIssues = Provider.of<Workspaces>(context, listen: false).preloadIssues;
    List dataList = [];

    for (var i = 0 ; i < preloadIssues.length; i++){
      Map<String, dynamic> item = {
        'id': "${preloadIssues[i]["id"]}-${preloadIssues[i]["workspace_id"]}-${preloadIssues[i]["channel_id"]}",
        'type': 'issue',
        'display': preloadIssues[i]["unique_id"].toString(),
        'title': preloadIssues[i]["title"],
        'channel_name': preloadIssues[i]["channel_name"],
        'is_closed': preloadIssues[i]["is_closed"]
      };

      dataList += [item];
    }

    return dataList;
  }

  _selectEmoji(emoji) {
    final int start = key.currentState!.controller.selection.baseOffset;

    key.currentState!.document.insert(start, emoji.value);
    key.currentState!.controller.updateSelection(TextSelection.collapsed(offset: start + 2), ChangeSource.LOCAL);
    key.currentState!.focusNode.requestFocus();
  }

  Future<dynamic> createPollDialog(BuildContext context) async {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext context) {
        return CreatePollDialog();
      }
    );
  }

  onReplyMessage(atts) {
    List list = images;
    final index = list.indexWhere((element) => element["mime_type"] == "share");
    if(index == -1) {
      list.add(atts);
    }
    else {
      list.replaceRange(index, index + 1, [atts]);
    }
    this.setState(() {
      images = list;
    });
  }

  bool connectionStatus = true;

  resendMessage(connectionProvider) async {
    if (connectionProvider != connectionStatus) {
      connectionStatus = connectionProvider;
      if (connectionStatus) {
        connectionStatus = connectionProvider;
        await Provider.of<Auth>(context, listen: false).getQueueMessages(widget.id);
      }
    }
  }

  Widget renderActionItem(String title) {
    Function eventAction;
    Widget widget = Container();

    Auth auth = Provider.of<Auth>(context);
    final bool isDark = auth.theme == ThemeType.DARK;

    switch (title) {
      case 'Stickers':
        widget = Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Icon(
            PhosphorIcons.stickerLight,
            size: 23, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
          )
        );
        eventAction = () {
          final currentChannel = Provider.of<Channels>(context, listen: false).getChannel(this.widget.id);
          final currentWorkspace = Provider.of<Workspaces>(context, listen: false).getDataWorkspace(currentChannel["workspace_id"]);

          selectSticker(context, _sendSticker, currentWorkspace['id'], _selectEmoji);
        };
        break;
      case 'Camera':
        eventAction = openCamera;

        widget = Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Icon(
            PhosphorIcons.cameraLight,
            size: 23, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
          ),
        );
        break;
      case 'Photo & Video':
        eventAction = loadAssets;

        widget = Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Icon(
            PhosphorIcons.imageLight,
            size: 23, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
          ),
        );
        break;
      case 'File':
        eventAction = processDocument;

        widget = Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Icon(
            PhosphorIcons.fileLight,
            size: 23, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
          ),
        );
        break;
      case 'Record':
        widget = Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Icon(
            PhosphorIcons.microphoneLight,
            size: 23, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
          ),
        );
        eventAction = () {
          showModalBottomSheet<void>(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            context: context,
            builder: (BuildContext context) {
              return RecordAudio();
            }
          );
        };
        break;
      case 'Poll':
        eventAction = () => createPollDialog(context);

        widget = Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: SvgPicture.asset("assets/images/icons/poll.svg", color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E))
        );
        break;
      
      default:
        eventAction = () {};
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          eventAction();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              widget,
              SizedBox(width: 16),
              Text(title),
            ],
          )
        ),
      ),
    );
  }

  Widget onShowMoreAction() {
    bool isDark = Provider.of<Auth>(context).theme == ThemeType.DARK;
    final Widget dividerWidget = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Divider(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB), height: 0.5)
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xff353535) : Colors.white,
        borderRadius: BorderRadius.circular(6)
      ),
      child: Column(
        children: [
          renderActionItem('Stickers'),
          dividerWidget,
          renderActionItem('Camera'),
          dividerWidget,
          renderActionItem('File'),
          dividerWidget,
          renderActionItem('Record'),
          dividerWidget,
          renderActionItem('Poll'),
        ],
      ),
    );
  }

  onShowDialogMoreAction() {
    bool isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          alignment: Alignment(0, 0.9),
          insetPadding: EdgeInsets.symmetric(horizontal: 8),
          child: Container(
            width: MediaQuery.of(context).size.width, height: 330,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                onShowMoreAction(),
                Material(
                  color: isDark ? Color(0xff4B4B4B) : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity, height: 40,
                      alignment: Alignment.center,
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w500))
                    ),
                  ),
                )
              ],
            )
          ),
        );
      }
    );
  }

  Widget renderActionInput() {
    Auth auth = Provider.of<Auth>(context);
    final bool isDark = auth.theme == ThemeType.DARK;
    final currentChannel = Provider.of<Channels>(context, listen: true).getChannel(widget.id);
    final currentWorkspace = Provider.of<Workspaces>(context).getDataWorkspace(currentChannel["workspace_id"]);
    final currentUser = Provider.of<User>(context, listen: false).currentUser;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: onShowDialogMoreAction,
              child: Container(
                height: 32, width: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color : isDark ? Color(0xff4C4C4C) : Color(0xffdbdbdb),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Icon(
                  PhosphorIcons.plus,
                  size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
                ),
              ),
            ),
            SizedBox(width: 2),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: openCamera,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    PhosphorIcons.camera,
                    size: 23, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
                  ),
                ),
              ),
            ),
            SizedBox(width: 6),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: loadAssets,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    PhosphorIcons.imageLight,
                    size: 23, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
                  ),
                ),
              ),
            ),
            SizedBox(width: 6),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Icon(PhosphorIcons.sticker, size: 23, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E))
                ),
                onTap: () => selectSticker(context, _sendSticker, currentWorkspace['id'], _selectEmoji),
              ),
            ),
          ],
        ),
    
        Row(
          children: [
            isEdit == true ? Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: (){
                  setState(() {
                    isEdit = !isEdit;
                  });
                  dataMessageSelected = {};
                  key.currentState!.controller.document = Document();
                  key.currentState!.focusNode.requestFocus();
                },
                child: Container(
                  padding: EdgeInsets.only(top: 6, right: 8, bottom: 6, left: 8),
                  child: Icon(PhosphorIcons.x, color: Palette.errorColor, size: 20,),
                ),
              ),
            ) : Container(),
            SizedBox(width: 4),
            Container(
              padding: EdgeInsets.only(top: 6, right: 14, bottom: 6, left: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: (Utils.checkedTypeEmpty(textInput) || images.isNotEmpty)
                  ? () async {
                    if(isEdit == true) {
                      setState(() {
                        isEdit = !isEdit;
                      });
                    }
                    _sendMessage(auth.token, currentWorkspace["id"], textInput);
                    if(currentUser["off_sending_sound_status"] == false) {
                      Work.platform.invokeMethod("active_sound_send_message");
                    }
                  }: null,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      isEdit ? PhosphorIcons.check  : PhosphorIcons.paperPlaneTilt,
                      size: 22,
                      color: (Utils.checkedTypeEmpty(textInput) || images.isNotEmpty) ? 
                      isDark ? Color(0xffFAAD14) : Color(0xff1890FF) 
                      : isDark ? Color(0xff828282) : Color(0xffC9C9C9),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<Auth>(context).token;
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    final userId = Provider.of<Auth>(context).userId;
    final currentChannel = Provider.of<Channels>(context, listen: true).getChannel(widget.id);
    final currentWorkspace = Provider.of<Workspaces>(context).getDataWorkspace(currentChannel["workspace_id"]);
    final messagesData = Provider.of<Messages>(context, listen: true).data.where((element) => element["channelId"].toString() == currentChannel["id"].toString()).toList();
    final data = messagesData.length > 0 ? messagesData[0]["messages"] : [];
    final workspaceMember = Provider.of<Workspaces>(context, listen: true).members;
    var listIdUserOnline = workspaceMember.where((e) => (e["is_online"] == true) && e["id"] != currentUser["id"]).map((e) => e["id"]);

    final theme = Provider.of<Auth>(context, listen: false).theme;
    final auth = Provider.of<Auth>(context, listen: true);
    int index = Provider.of<Messages>(context, listen: true).data.indexWhere((element) => element["channelId"].toString() == currentChannel["id"].toString());
    var numberNewMessages = index == -1 ? null :  Provider.of<Messages>(context).data[index]["numberNewMessages"];
    var isFetchingUp =  (index == -1 ? false :  Provider.of<Messages>(context).data[index]["isLoadingUp"]) ?? false;
    var isFetchingDown =  (index == -1 ? false :  Provider.of<Messages>(context).data[index]["isLoadingDown"]) ?? false;
    bool isFocus = key.currentState?.focusNode.hasFocus ?? false;
    final messageIdToJump = Provider.of<Messages>(context, listen: true).messageIdToJump;
    final dataReversed = data;
    bool connectionProvider = Provider.of<Work>(context, listen: true).connectionStatus;
    resendMessage(connectionProvider);
    final bool isAndroid = Platform.isAndroid;
    //
    return Scaffold(
      resizeToAvoidBottomInset: Platform.isAndroid ? false : true,
      body: Container(
        color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
        child: SafeArea(
          right: false, bottom: false,
          child: Container(
            child: Column(
              children: [
                Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff2E2E2E) : Colors.white,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: isDark ? null : Border(bottom: BorderSide(color: Color(0xffDBDBDB)))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            // disconnectChannel();
                            if (Utils.checkedTypeEmpty(widget.isNavigator)) {
                              // widget.changePageView != null && widget.changePageView(0);
                              Navigator.pop(context);
                            } else {
                              widget.changePageView(0);
                              key.currentState!.focusNode.unfocus();
                              isShow = false;
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Icon(PhosphorIcons.arrowLeft, size: 20, color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E)),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                ChannelInfo(
                                  token: token,
                                  workspaceId: currentWorkspace["id"],
                                  channelId: currentChannel["id"],
                                  userId: userId
                                )
                              ));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      currentChannel["id"] != null ? currentChannel["name"] : "",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.5,
                                        color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)
                                      )
                                    ),
                                  ),
                                  SizedBox(width: 4,),
                                  Icon(PhosphorIcons.gear, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), size: 18,)
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            if (currentChannel["kanban_mode"] == true) {
                              Navigator.push(
                                context, MaterialPageRoute(builder: (context) => BoardViewScreen(), fullscreenDialog: true)
                              );
                            } else {
                              Navigator.push(
                                context, MaterialPageRoute(builder: (context) => Issues(isNavigator: true))
                              );
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: isDark ? SvgPicture.asset("assets/images/icons/issueDark.svg") : SvgPicture.asset("assets/images/icons/issueLight.svg"),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: data != null && data.isNotEmpty
                  ? Container(
                    color: isDark ? Color(0xff353535) : Colors.white,
                    child: Stack(
                      children: [
                        Column(
                          children: <Widget>[
                            index == -1 ? Expanded(child: shimmerEffect(context))
                            : Expanded(
                              child: ListView.builder(
                                itemCount: dataReversed.length,
                                reverse: true,
                                padding: EdgeInsets.zero,
                                controller: _scrollController,
                                physics: ClampingScrollPhysics(),
                                itemBuilder: (BuildContext c, int i){
                                  Map message = dataReversed[i];
                                  return Column(
                                    children: [
                                      (i == dataReversed.length - 1) ? AnimatedContainer(
                                        height: isFetchingDown ? 65 : 0,
                                        duration: Duration(milliseconds: 300),
                                        child: shimmerEffect(context),
                                      ) : Container(),
                                      ChatItem(
                                        onEditMessage: onEditMessage,
                                        copyMessage: copyMessage,
                                        isChannel: true,
                                        id: "${message["current_time"]}" == "1"  ? null :message["id"],
                                        isMe: message["user_id"] == auth.userId,
                                        message:message["message"] ?? "",
                                        avatarUrl: message["avatar_url"],
                                        insertedAt: message["inserted_at"] ?? message["time_create"],
                                        fullName: Utils.getUserNickName(message["user_id"]) ?? message["full_name"],
                                        attachments: message["attachments"],
                                        isFirst: message["isFirst"],
                                        count: message["count_child"] == null ? 0 : message["count_child"],
                                        isLast: message["isLast"],
                                        isChildMessage: false,
                                        userId: message["user_id"],
                                        success: message["success"] == null ? true : message["success"],
                                        infoThread: message["info_thread"] != null ? message["info_thread"] : [],
                                        isAfterThread: message["isAfterThread"],
                                        showHeader: false,
                                        snippet: message["snippet"] ?? "",
                                        blockCode: message["block_code"] ?? "",
                                        showNewUser: message["showNewUser"],
                                        isBlur: message["isBlur"] == null ?  false : message["isBlur"],
                                        reactions: message["reactions"] == null ? [] : message["reactions"],
                                        isSystemMessage: message["is_system_message"] ?? false,
                                        idMessageToJump: messageIdToJump,
                                        onFirstFrameDone: (widget.isNavigator == true) ? onFirstFrameMessageSelectedToJumpDone : null,
                                        channelId: currentChannel["id"],
                                        isUnsent: message["is_unsent"],
                                        lastEditedAt: message["last_edited_at"],
                                        firstMessage: message["firstMessage"],
                                        isConversation: true,
                                        currentTime: message["current_time"],
                                        isOnline: listIdUserOnline.contains(message["user_id"]),
                                        isDark: isDark,
                                        onReplyMessage: onReplyMessage,
                                      ),
                                      i == 0 ? AnimatedContainer(
                                        height: isFetchingUp ? 65 : 0,
                                        duration: Duration(milliseconds: 300),
                                        child: shimmerEffect(context),
                                      ) : Container(),
                                    ],
                                  );
                                }
                              ),
                            ),
                            TypingMobile(id: widget.id),
                            Container(
                              child: StreamBuilder(
                                initialData: heightInput,
                                stream: heightInputController.stream,
                                builder: (context, snapshot) {
                                  bool disableSendButtons = !isFocus && images.length == 0 && !Utils.checkedTypeEmpty(textInput);
                                  return Stack(
                                    children: [
                                      SlidingUpPanel(
                                        panelSnapping: true,
                                        isDraggable: (!isFocus && images.length == 0) ? false : true,
                                        onPanelSlide: (double value) {
                                          if(value != 0.0) {
                                            isBlock = true;
                                          } else {
                                            if(isBlock) {
                                              Future.delayed(Duration(milliseconds: 1000), () {
                                                isBlock = false;
                                              });
                                            } else {
                                              key.currentState!.focusNode.unfocus();
                                              FocusScope.of(context).unfocus();
                                            }
                                          }
                                        },
                                        minHeight: (!disableSendButtons
                                          ? (isAndroid ? 50 : 52) + heightInput
                                          : isAndroid ? 58 : 60
                                        ) + (isFocus ? 0 : (isAndroid ? 0 : 20)),
                                        maxHeight: (disableSendButtons ? 68 : 300) + (isFocus ? 0 : (isAndroid ? 0 : 20)),
                                        color: isDark ? Color(0xff2E2E2E) : Color(0xfff5f5f5),
                                        boxShadow : const <BoxShadow>[BoxShadow(blurRadius: 8.0, color: Color.fromARGB(0, 0, 0, 0))],
                                        controller: panelController,
                                        border: Border(
                                          top: BorderSide(color: isDark ? Color(0xff707070) : Color(0xFFB7B7B7), width: 0.5),
                                        ),
                                        padding: EdgeInsets.only(bottom: isFocus ? 0 : (isAndroid ? 0 : 20)),
                                        panel: Column(
                                          children:[
                                            (Utils.checkedTypeEmpty(key.currentState == null ? null : key.currentState!.document.toPlainText().trim()) ||  isFocus || images.length > 0) ? Container(
                                              margin: EdgeInsets.only(top: 5),
                                              height: 4, width: 50,
                                              decoration: BoxDecoration(
                                                color: isDark ? Color(0xFF5E5E5E) :Color(0xffC9C9C9),
                                                borderRadius: BorderRadius.circular(16)
                                              )
                                            ) : Container(),
                                            MeasureSize(
                                              onChange: (Size size) {
                                                heightInput = size.height;
                                                heightInputController.add(size.height);
                                              },
                                              child: Column(
                                                children: [
                                                  images.length > 0 ? Container(margin: EdgeInsets.only(top: 3), child: FileItems(files: images, removeFile: removeImage)) : Container(),
                                                  Container(
                                                    padding: EdgeInsets.only(top: disableSendButtons ? 10 : 0,),
                                                    child: FlutterMentions(
                                                      textCapitalization: TextCapitalization.sentences,
                                                      onTap: () {
                                                        heightInputController.add(heightInput);
                                                      },
                                                      cursorColor: theme == ThemeType.DARK ? Colors.grey[400]! : Colors.black87,
                                                      key: key,
                                                      id: widget.id.toString(),
                                                      isDark: auth.theme == ThemeType.DARK,
                                                      style: TextStyle(fontSize: 15.5, color: theme == ThemeType.DARK ? Colors.grey[300] : Colors.grey[800]),
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        focusedBorder: InputBorder.none,
                                                        enabledBorder: InputBorder.none,
                                                        errorBorder: InputBorder.none,
                                                        disabledBorder: InputBorder.none,
                                                        contentPadding: EdgeInsets.only(left: 4, bottom: 12, right: 4, top: 10),
                                                        hintText: "${S.current.typeAMessage}...",
                                                        hintStyle: TextStyle(color: Colors.grey[600])
                                                        // hintText: "Message ${currentChannel["name"]}",
                                                      ),
                                                      islastEdited: false,
                                                      onChanged: (str) {
                                                        String text = str.trim();
                                                        saveChangesToHive();
                                                        checkCommand(str.substring(0, str.length - 1), context);
                                                        // str.substring(0, str.length - 1) lay gia tri nay boi vi chuoi tra ve luon co ky tu /n o cuoi cung
                                                  
                                                        if(text.length == 0 && textInput.length != 0) {
                                                          setState(() {
                                                            textInput = text;
                                                          });
                                                        } else if(text.length != 0 && textInput.length == 0){
                                                          setState(() {
                                                            textInput = text;
                                                          });
                                                        }
                                                  
                                                        if(Utils.checkedTypeEmpty(textInput)) {
                                                          if (_debounce?.isActive ?? false) _debounce?.cancel();
                                                  
                                                          _debounce = Timer(const Duration(milliseconds: 500), () {
                                                            auth.channel.push(
                                                              event: "on_typing",
                                                              payload: {"channel_id": currentChannel["id"], "workspace_id": currentWorkspace["id"], "user_name": currentUser["full_name"]}
                                                            );
                                                          });
                                                        }
                                                      },
                                                      suggestionListHeight: 200,
                                                      onSearchChanged: (trigger, onGetMentions) {
                                                        if (trigger == "@"){
                                                          getDataMentions();
                                                        }
                                                      },
                                                      mentions: [
                                                        Mention(
                                                          markupBuilder: (trigger, mention, value, type) {
                                                            return "=======@/$mention^^^^^$value^^^^^$type+++++++";
                                                          },
                                                          trigger: '@',
                                                          style: TextStyle(color: Colors.lightBlue),
                                                          data: suggestionMentions,
                                                          matchAll: true,
                                                        ),
                                                        Mention(
                                                          markupBuilder: (trigger, mention, value, type) {
                                                            return "=======#/$mention^^^^^$value^^^^^$type+++++++";
                                                          },
                                                          trigger: "#",
                                                          style: const TextStyle(color: Colors.lightBlue),
                                                          data: getSuggestionIssue(),
                                                          matchAll: true
                                                        )
                                                      ],
                                                      leading: [
                                                        if(!isFocus && images.length == 0 && !Utils.checkedTypeEmpty(textInput)) InkWell(
                                                          onTap: onShowDialogMoreAction,
                                                          child: Container(
                                                            height: 32, width: 32,
                                                            decoration: BoxDecoration(
                                                              color : isDark ? Color(0xff4C4C4C) : Color(0xffdbdbdb),
                                                              shape: BoxShape.circle,
                                                            ),
                                                            margin: const EdgeInsets.only(left: 12, right: 4, bottom: 8),
                                                            child: Icon(
                                                              PhosphorIcons.plus,
                                                              size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      trailing: [
                                                        if(!isFocus && images.length == 0 && !Utils.checkedTypeEmpty(textInput)) Container(
                                                          margin: const EdgeInsets.only(left: 4, bottom: 4, right: 12),
                                                          child: Material(
                                                            color: Colors.transparent,
                                                            child: InkWell(
                                                              onTap: () {
                                                                selectSticker(context, _sendSticker, currentWorkspace['id'], _selectEmoji);
                                                              },
                                                              borderRadius: BorderRadius.circular(22),
                                                              child: Container(
                                                                padding: const EdgeInsets.all(6),
                                                                child: Icon(
                                                                  PhosphorIcons.sticker,
                                                                  size: 24, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ]
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ),
                                          ]
                                        ),
                                      ),
                                      if(textInput.isNotEmpty || isFocus || images.isNotEmpty) Positioned(
                                        bottom: isFocus ? 0 : (isAndroid ? 0 : 20), width: MediaQuery.of(context).size.width,
                                        child: renderActionInput()
                                      )
                                    ],
                                  );
                                }
                              ),
                            )
                          ]
                        ),
                        AnimatedPositioned(
                          bottom: heightInput + 50,
                          left: 0,
                          right: 0,
                          height: suggestCommands.length <5 ? suggestCommands.length * 50.0 : 250.0,

                          duration: Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: auth.theme == ThemeType.DARK ? Color(0xFF434343) : Color(0xFFf0f0f0),
                                boxShadow: suggestCommands.length > 0 ?
                                [BoxShadow(
                                    color: auth.theme == ThemeType.DARK  ? Color(0xFF262626).withOpacity(0.5) : Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3), // changes position of shadow
                                  ),
                                ] : [],
                            ),
                            child: ListView(
                              children: [
                                Column(
                                  children: suggestCommands.map<Widget>((command){
                                    var string = command["command_params"] != null ? command["command_params"].map((e) {
                                      return "[${e["key"]}]";
                                    }) : [];
                                    return Container(
                                      child: TextButton(
                                        onPressed: (){
                                          onSelectCommand("/" + command["short_cut"], command["command_params"]);
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "/${command["short_cut"] ?? ""} ",
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    "${string.join(" ")}",
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Color(0xFF8C8C8C),
                                                      fontWeight: FontWeight.w300,
                                                      fontSize: 12
                                                    )
                                                  )
                                                ],
                                              ),
                                            ),
                                            command["description"] != null ? Container(
                                              padding: EdgeInsets.only(left: 4, top: 2, bottom: 2),
                                              child: Text(
                                                command["description"],
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Color(0xFF8C8C8C),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w300
                                                ),
                                              )
                                            ) : Container()
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          )
                        ),
                        data.length > 0 && (numberNewMessages ?? 0) > 0 ?
                          Positioned(
                            bottom: 100,
                            height: 50,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: HoverItem(
                                child: GestureDetector(
                                  onTap: (){
                                    Provider.of<Messages>(context, listen: false).resetOneChannelMessage(currentChannel["id"]);
                                    Provider.of<Messages>(context, listen: false).loadMoreMessages(token, currentWorkspace["id"] ,currentChannel["id"]);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: theme == ThemeType.DARK ? Palette.defaultBackgroundDark : Palette.defaultBackgroundLight,
                                      borderRadius: BorderRadius.all(Radius.circular(20)),
                                      border: Border.all(color: Color(0xFFbfbfbf), width: 1),
                                    ),
                                    child: Text(
                                      "$numberNewMessages new messages",
                                      style: TextStyle(fontSize: 12, color: theme == ThemeType.DARK ? Colors.white70 : Color(0xFF6a6e74)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container()
                      ]
                    )
                  )
                  : shimmerEffect(context),
                ),
                Platform.isAndroid ? StreamBuilder(
                  stream: heightKeyboadStream.stream,
                  builder: (BuildContext c, s){
                    return Container(height: heightKeyboard,);
                  } 
                ) : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

  selectSticker(BuildContext context, Function sendSticker, workspaceId, Function selectEmoji) async {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      builder: (BuildContext context) {
        return StickerEmojiWidget(
          key: Utils.stickerEmojiWidgetState,
          selectSticker: sendSticker,
          workspaceId: workspaceId,
          onSelect: selectEmoji,
        );
      }
    );
  }

showInviteChannel(context) {
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    builder: (BuildContext context) {
      return Container(
        child: InviteChannel()
      );
    }
  );
}