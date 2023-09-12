import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart' hide ImageFormat;
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/progress.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/chat_item.dart';
import 'package:workcake/components/direct_message/dm_info.dart';
import 'package:workcake/components/direct_message/unread_thread_dm.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/typing.dart';
import 'package:workcake/emoji/emoji.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:hive/hive.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/conversation.dart';
import '../components/thread_view.dart';
import 'package:workcake/src/mention_view_new.dart';
import '../flutter_mentions.dart';
import '../generated/l10n.dart';
import 'not_found_conversation.dart';
import 'dart:ui' as ui;

class Message extends StatefulWidget {
  final id;
  final name;
  final avatarUrl;
  final DirectModel dataDirectMessage;
  final changePageView;
  final isNavigator;
  final idMessageToJump;
  final PanelController? panelController;

  Message({
    Key? key,
    this.id,
    @required this.name,
    @required this.avatarUrl,
    required this.dataDirectMessage,
    this.changePageView,
    this.isNavigator,
    this.idMessageToJump,
    this.panelController
  }): super(key: key);
  @override
  MessageState createState() => MessageState();
}

// check miss message and load it to local
// only call hive db when offline;

class MessageState extends State<Message> {
  var data = [];
  var listkeyMessage = [];
  LazyBox? directMessageBox;
  bool isInternet = true;
  var channel;
  ScrollController? controller;
  var selectedMessage;
  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
  String textInput = "";
  final picker = ImagePicker();
  bool isFocus = false;
  GlobalKey keyMessageToJump = GlobalKey();
  List<Map<String, dynamic>> suggestionMentions = [];
  bool hasJump = false;
  bool isShow = false;
  double heightInput = 48.0;
  final heightInputController =  StreamController<double>.broadcast(sync: false);
  PanelController? get panelController => widget.panelController;
  bool isBlock = false;
  Timer? _debounce;
  double heightKeyboard = 0.0;
  StreamController<double> heightKeyboadStream = StreamController<double>.broadcast(sync: false);

  @override
  void initState() {
    super.initState();
    controller = new ScrollController()..addListener(_scrollListener);

    Timer.run(() async {
      unHideDirectMessage();
      markUnNewMessage();
    });
    getSuggestionMentions();
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

  void _scrollToTop() {
    if (controller!.offset <=  400 || controller!.offset > 0) {
      controller!.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.linear);
    } else if (controller!.offset > 400) {
      controller!.animateTo(0,
        duration: Duration(seconds: 2), curve: Curves.linear);
    }
  }

  unHideDirectMessage(){
    Provider.of<DirectMessage>(context, listen: false).setHideConversation(widget.dataDirectMessage.id, false, context);
  }
  markUnNewMessage()async{
    try {
      await Future.delayed(Duration(seconds: 5));
      Provider.of<DirectMessage>(context, listen: false).removeMarkNewMessage(widget.dataDirectMessage.id);
    } catch (e) {
    }
  }

  jumpToContext(BuildContext? c, String idMessage, {bool isMessageJump = false}){
    BuildContext? messageContext = c;
    if (messageContext == null) return;
    final renderObejctMessage = messageContext.findRenderObject() as RenderBox;
    try {
      double heightMessage = 0.0, heightScrollTo = 0.0;
      double heightContentRenderMessage = MediaQuery.of(context).size.height - 184; // 300 bao gon header + input
      var offsetGlobal = renderObejctMessage.localToGlobal(Offset.zero);
      if (isMessageJump) {
        // heightMessage = messageContext.size!.height;
        if (heightMessage < heightContentRenderMessage) {
          heightScrollTo = (heightContentRenderMessage - heightMessage) / 2  ;
        } else {
          heightScrollTo = heightContentRenderMessage - heightMessage;
        }
      }
      var scrolllOffset = controller!.offset - offsetGlobal.dy + heightScrollTo;
      controller!.animateTo(scrolllOffset >= 0 ? scrolllOffset : 0.0, duration: Duration(milliseconds: 200), curve: Curves.ease);
    } catch (e) {
      print("jumpToContext: $e");
    }
  }

  onFirstFrameMessageSelectedToJumpDone(BuildContext? cont, int? time, String? idMessage){
    if (hasJump) return;
    try {
      var idMessageToJump = Provider.of<DirectMessage>(context, listen: false).idMessageToJump;
      if (cont == null || idMessageToJump == "" || idMessage == null) return;
      List dataMessage  = [];
      final dataMessageConversation = Provider.of<DirectMessage>(context, listen: false).getCurrentDataDMMessage(widget.dataDirectMessage.id);
      if (dataMessageConversation != null) {
        dataMessage = dataMessageConversation.messages;
      }
      int index  = dataMessage.indexWhere((ele) => ele["id"] == idMessageToJump);
      if (index == -1 || time == null) return;
      int currentT = dataMessage[index]["current_time"];
      if (time >=currentT) jumpToContext(cont, idMessage,  isMessageJump: time == currentT);
      if (time == currentT) {
        hasJump = true;
        Provider.of<DirectMessage>(context, listen: false).setIdMessageToJump("");
      }
    } catch (e) {

      print("PPPPPPP $e");
    }
  }

  @override
  void dispose() {
    controller!.dispose();
    if(_debounce != null) {
      _debounce?.cancel();
    }

    super.dispose();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    getSuggestionMentions();
    if (oldWidget.id != widget.id) {
      (controller as ScrollController).jumpTo(0);
      fileItems = [];
      getLastEdited();
      isShow = false;
    }
    // if (oldWidget.idMessageToJump != widget.idMessageToJump){
    //   onFirstFrameMessageSelectedToJumpDone();
    //   removeMessageToJump();
    // }
  }

  getLastEdited() async {
    if (widget.isNavigator != null && widget.isNavigator) return;
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

  disconnectDirect() {
    try {
      channel = Provider.of<Auth>(context, listen: false).channel;
      channel.push(event: "disconnect_direct", payload: {});
    } catch (e) {
    }
  }

  _scrollListener() {
    if (controller ==  null) return;
    final auth = Provider.of<Auth>(context, listen: false);
    if (controller!.position.extentAfter < 10 && controller!.position.userScrollDirection == ScrollDirection.reverse)
      Provider.of<DirectMessage>(context, listen: false).getMessageFromApi(widget.dataDirectMessage.id, auth.token, false, null, auth.userId, forceCallViaIsolate: true);
    if (controller!.position.extentBefore < 10 && controller!.position.userScrollDirection == ScrollDirection.forward){
      Provider.of<DirectMessage>(context, listen: false).getMessageFromApiUp(widget.dataDirectMessage.id, auth.token, auth.userId);
    }
  }

  getIdConversation(){
    if (widget.dataDirectMessage.id != "" && !Utils.checkedTypeEmpty(widget.isNavigator)) return widget.dataDirectMessage.id;
    else return  Provider.of<DirectMessage>(context, listen: false).directMessageSelected.id;
  }

  String uint8ListTob64(Uint8List uint8list) {
    String base64String = base64Encode(uint8list);
    return base64String;
  }

  sendDirectMessage(token) async {
    _scrollToTop();
    var directMessageSelected = Provider.of<DirectMessage>(context, listen: false).getModelConversation(getIdConversation());
    if (directMessageSelected == null) return;
    var currentUser =  Provider.of<User>(context, listen: false).currentUser;
    var idDirectmessage = directMessageSelected.id;
    var fakeId  = Utils.getRandomString(20);
    var userId  = Provider.of<Auth>(context, listen: false).userId;
    var checkingShareMessage = fileItems.where((element) => element["mime_type"] == "share").toList();

    final Document document = key.currentState!.document;

    if(!Utils.checkedTypeEmpty(document.toPlainText().trim()) && fileItems.isEmpty) return;

    List attachments = Utils.checkedTypeEmpty(document.toPlainText().trim()) ? [{
      'type': "mention",
      'data': Utils.parseQuillController(document)
    }] : [];

    var dataMessage = {
      "message": '',
      "attachments": attachments + checkingShareMessage,
      "title": "",
      "avatar_url": currentUser["avatar_url"],
      "full_name": currentUser["full_name"],
      "conversation_id": idDirectmessage,
      "show": true,
      "id": selectedMessage == null ?  "" : selectedMessage["id"],
      "user_id": userId,
      "time_create": selectedMessage == null ? DateTime.now().add(new Duration(hours: -7)).toIso8601String() : selectedMessage["time_create"],
      "count": 0,
      "sending": true,
      "success": true,
      "fake_id": fakeId,
      "current_time": selectedMessage == null ? DateTime.now().millisecondsSinceEpoch * 1000 : selectedMessage["current_time"],
      "isSend": selectedMessage == null ? true : false
    };

    key.currentState!.controller.document = Document();
    selectedMessage = null;
    if ((dataMessage["message"] == "") && (dataMessage["attachments"].length == 0 && fileItems.length == 0)){}
    else
      Provider.of<DirectMessage>(context, listen: false).sendMessageWithImage(fileItems ,dataMessage, token);

    this.setState(() { fileItems = []; });
  }

  getDMname(List data, String field) {
    if (data.length  == 1) return data[0][field];
    var result = "";
    var userId  = Provider.of<Auth>(context, listen: false).userId;
    for (var i = 0; i < data.length; i++) {
      if (data[i]["user_id"] == userId) continue;
      if (i != 0 && result != "") result += ", ";
      result += data[i][field];
    }
    return result;
  }

  List fileItems = [];

  loadAssets() async {
    List<AssetEntity> resultList = await Provider.of<Work>(context, listen: false).openFileSelector(context);
    this.setState(() { fileItems = resultList; });
    List results = await Utils.handleFileData(resultList);

    if (!mounted) return;
    key.currentState!.focusNode.requestFocus();
    setState(() {
      fileItems = results.where((e) => e.isNotEmpty).toList();
    }
    );
  }

  openCamera() async {
    final AssetEntity? pickedFile = await Provider.of<Work>(context, listen: false).openCamera(context);
    if (pickedFile == null) return; 
    this.setState(() { fileItems = [pickedFile]; });
    List results = await Utils.handleFileData([pickedFile]);

    if (!mounted) return;
    fileItems = results.where((e) => e.isNotEmpty).toList();
  }

  processDocument() async {
    try {
      final List<PlatformFile> files = await Utils.pickedFileOther();
      final List stateFile = fileItems;
      setState(() {
        fileItems = [] + stateFile + files;
      });

      List results = await Utils.handleFileOtherData(files);
      if (!mounted) return;

      Future.delayed(Duration(milliseconds: 200), () {
        this.setState(() {
          fileItems = stateFile + results.where((e) => e.isNotEmpty).toList();
        });
      });
    } catch (e, t){
      print("fileItems: $e, $t");
    }
  }

  removeImage(index) {
    List list = fileItems;
    list.removeAt(index);
    this.setState(() {
      fileItems = list;
    });
  }

  copyMessage(String keyMessage){
    var idMessage = keyMessage.split("__")[1];
    var dataMessageConversation  = Provider.of<DirectMessage>(context, listen: false).getCurrentDataDMMessage(widget.dataDirectMessage.id);
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    String message ="";
    if (dataMessageConversation != null) {
      List dataMessages = dataMessageConversation.messages;
      var indexMessage = dataMessages.indexWhere((element) => element["id"] == idMessage);
      if (indexMessage != -1){
        var dataM = dataMessages[indexMessage];
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

  getSuggestionMentions() {
    final auth = Provider.of<Auth>(context, listen: false);
    final dataUserMentions = Provider.of<User>(context, listen: false).userMentionInDirect;
    final directMessage = Provider.of<DirectMessage>(context, listen: false).getModelConversation(getIdConversation());
    if (directMessage == null) return;
    var listUser = [] + directMessage.user + dataUserMentions;
    Map index = {};

    List<Map<String, dynamic>> dataList = directMessage.user.length > 2 ? [{'id': widget.dataDirectMessage.id, 'display': 'all', 'full_name': 'all', 'photo': 'all', 'type': 'all'}] : [];
      for (var i = 0 ; i< listUser.length; i++){
        if (index[listUser[i]["user_id"]] != null) continue;
        Map<String, dynamic> item = {
          'id': listUser[i]["user_id"],
          'type': 'user',
          'display': listUser[i]["full_name"],
          'full_name': listUser[i]["full_name"],
          'photo': listUser[i]["avatar_url"]
        };
        index[listUser[i]["user_id"]] = true;

        if (auth.userId != listUser[i]["user_id"]) dataList += [item];
      }

    suggestionMentions = dataList;
  }
  onReplyMessage(atts) {
    List list = fileItems;
    final index = list.indexWhere((element) => element["mime_type"] == "share");
    if(index == -1) {
      list.add(atts);
    }
    else {
      list.replaceRange(index, index + 1, [atts]);
    }
    this.setState(() {
      fileItems = list;
    });
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

  _sentSticker(data) {
    var directMessageSelected = Provider.of<DirectMessage>(context, listen: false).getModelConversation(getIdConversation());
    if (directMessageSelected == null) return;
    var currentUser =  Provider.of<User>(context, listen: false).currentUser;
    var idDirectmessage = directMessageSelected.id;
    var fakeId  = Utils.getRandomString(20);
    final auth = Provider.of<Auth>(context, listen: false);

    var dataMessage = {
      "message": '',
      "attachments": [{
        'type': 'sticker',
        'data': data
      }],
      "title": "",
      "avatar_url": currentUser["avatar_url"],
      "full_name": currentUser["full_name"],
      "conversation_id": idDirectmessage,
      "show": true,
      "user_id": auth.userId,
      "time_create": DateTime.now().add(new Duration(hours: -7)).toIso8601String(),
      "count": 0,
      "sending": true,
      "success": true,
      "fake_id": fakeId,
      "current_time": DateTime.now().millisecondsSinceEpoch * 1000,
      "isSend": true
    };

    Provider.of<DirectMessage>(context, listen: false).sendMessageWithImage([] ,dataMessage, auth.token);
  }

  _selectEmoji(emoji) {
    final int start = key.currentState!.controller.selection.baseOffset;

    key.currentState!.document.insert(start, emoji.value);
    key.currentState!.controller.updateSelection(TextSelection.collapsed(offset: start + 2), ChangeSource.LOCAL);
    key.currentState!.focusNode.requestFocus();
  }

  bool connectionStatus = true;

  resendMessage(connectionProvider) async {
    if (connectionProvider != connectionStatus) {
      connectionStatus = connectionProvider;
      if (connectionStatus) {
        connectionStatus = connectionProvider;
        final token = Provider.of<Auth>(context, listen: false).token;
        Provider.of<DirectMessage>(context, listen: false).checkReSendMessageError(token, widget.dataDirectMessage.id);
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
          selectSticker(context, _sentSticker, 0, _selectEmoji);
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
          renderActionItem('Photo & Video'),
          dividerWidget,
          renderActionItem('File'),
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
            width: MediaQuery.of(context).size.width, height: 240,
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
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: EdgeInsets.all(6),
                  child: Icon(PhosphorIcons.sticker, size: 23, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E))
                ),
                onTap: () => selectSticker(context, _sentSticker, 0, _selectEmoji),
              ),
            ),
          ],
        ),
    
        Container(
          padding: EdgeInsets.only(top: 6, right: 14, bottom: 6, left: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: !Utils.checkedTypeEmpty(textInput) && fileItems.isEmpty ? null : () async {
                sendDirectMessage(auth.token);
                if(currentUser["off_sending_sound_status"] == false) {
                  Work.platform.invokeMethod("active_sound_send_message");
                }
              },
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: EdgeInsets.all(6),
                child: Icon(
                  PhosphorIcons.paperPlaneTilt,
                  size: 22,
                  color: (Utils.checkedTypeEmpty(textInput) || fileItems.isNotEmpty) ? isDark ? Color(0xffFAAD14) : Color(0xff1890FF) : isDark ? Color(0xff828282) :  Color(0xffC9C9C9),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    final errorCode = Provider.of<DirectMessage>(context, listen: false).errorCode;
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    DirectModel? directMessage = Provider.of<DirectMessage>(context, listen: true).getModelConversation(getIdConversation());
    ConversationMessageData? dataMessageConversation  = Provider.of<DirectMessage>(context, listen: false).getCurrentDataDMMessage(widget.dataDirectMessage.id);
    if (dataMessageConversation == null || directMessage == null ) return NotFoundConversationException(
      onTap: (){
        if (Utils.checkedTypeEmpty(widget.isNavigator)){
          Navigator.pop(context);
        } else {
          widget.changePageView(0);
        }
      }
    );
    var listUser = (directMessage.id != "" ? directMessage.user : []).where((element) => element["status"] == "in_conversation" || element["status"] == null).toList();
    var listIdUserOnline = listUser.where((e) => Utils.checkedTypeEmpty(e["is_online"]) && e["user_id"] != currentUser["id"]).map((e) => e["user_id"]);
    final theme = Provider.of<Auth>(context, listen: false).theme;
    var disableLoad = dataMessageConversation.isFetching;

    final isPanchat = listUser.where((element) => element["user_id"] == "41b87209-ec1f-4781-a7be-4c861d4864ca").toList();
    var idMessageToJump = Provider.of<DirectMessage>(context,listen: false).idMessageToJump;
    var dataMessage = dataMessageConversation.messages;
    final dataInfoThreadMessage = Provider.of<DirectMessage>(context, listen: false).dataInfoThreadMessage;
    bool connectionProvider = Provider.of<Work>(context, listen: true).connectionStatus;
    connectionProvider = true;
    resendMessage(connectionProvider);
    final bool isAndroid = Platform.isAndroid;

    return  Scaffold(
      resizeToAvoidBottomInset: Platform.isAndroid ? false : true,
      backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 62,
              decoration: BoxDecoration(
                color: isDark ? Color(0xff2E2E2E) : Colors.white,

              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: isDark ? null : Border(bottom: BorderSide(color: Color(0xffDBDBDB))) ,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: (){
                        disconnectDirect();
                        Provider.of<Messages>(context, listen: false).openConversation(false);
                        if (Utils.checkedTypeEmpty(widget.isNavigator)){
                          Navigator.pop(context);
                        }
                        else {
                          setState(() {
                            isShow = false;
                          });
                          widget.changePageView(0);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Icon(PhosphorIcons.arrowLeft, size: 20, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => DMInfo(id: widget.id)));
                      },
                      child: Container(
                        width: 160,
                        child: Text(
                          directMessage.name != "" ? directMessage.name : directMessage.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle( fontWeight: FontWeight.bold, fontSize: 17),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        dataMessageConversation.dataUnreadThread.isEmpty ? Container() : Container(width: 60,
                          child: InkWell(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              await Navigator.push(context, MaterialPageRoute(builder: (context) => ListUnreadThreadDM(conversationId: widget.id)));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child:  isDark ? SvgPicture.asset("assets/icons/Thread.svg") : SvgPicture.asset("assets/icons/thread_light.svg",)
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            await Navigator.push(context, MaterialPageRoute(builder: (context) => DMInfo(id: widget.id)));
                          },
                          child: Container(
                            height: 30,
                            width: 32,
                            margin: EdgeInsets.only(right: 10,top: 12, bottom: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff444444) : Color(0xffEDEDED),
                              borderRadius: BorderRadius.circular(30)
                            ),
                            child: Icon(PhosphorIcons.gearSix, size: 18,)
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 1,color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB),),
            Expanded(
              child: Container(
                color: isDark ? Color(0xff353535) : Colors.white,
                child: Stack(
                  children: [
                    Container(
                      child: Column(
                        children: <Widget>[
                          AnimatedContainer(
                            alignment: Alignment.center,
                            duration: Duration(milliseconds: 300),
                            color: Colors.red[100],
                            height: (errorCode != null) && (getIdConversation() != MessageConversationServices.shaString([Utils.panchatSupportId, auth.userId])) ? 50 : 0,
                            child: Text("You can't send message to user on conversation.", style: TextStyle(color: Colors.red),),
                          ),
                          dataMessage.length == 0 && disableLoad ? Expanded(
                            child: Scrollbar(child: shimmerEffect(context))
                          ) : Expanded(
                            child: ListView.builder(
                              reverse: true,
                              padding: EdgeInsets.zero,
                              physics: ClampingScrollPhysics(),
                              controller: controller,
                              itemCount: dataMessage.length,
                              itemBuilder: (BuildContext context, int index){
                                Map message = dataMessage[index];
                                if (message["action"] == "delete_for_me") return Container();
                                return Column(
                                  children: [
                                    (index == dataMessage.length -1) && (!dataMessageConversation.disableHiveDown) && (dataMessageConversation.isFetching) ? Container(
                                      height: 60,
                                      child: shimmerEffect(context),
                                    ) : Container(),
                                    ChatItem(
                                      key: message["id"] == idMessageToJump ? keyMessageToJump : null,
                                      onEditMessage: (keyM) {},
                                      copyMessage: copyMessage,
                                      isChannel: false,
                                      id: "${message["current_time"]}" == "1"  ? null :message["id"],
                                      isMe: message["user_id"] == auth.userId,
                                      message:message["message"] ?? "",
                                      avatarUrl: message["avatar_url"] ?? message["avatarUrl"],
                                      insertedAt: message["inserted_at"] ?? message["time_create"],
                                      fullName: message["full_name"] ?? message["fullName"],
                                      conversationId: directMessage.id,
                                      attachments: message["attachments"],
                                      isFirst: message["isFirst"] ?? false,
                                      count: (dataInfoThreadMessage[message["id"]])?.count ?? message["count"] ?? 0,
                                      isLast: message["isLast"] ?? false,
                                      isChildMessage: false,
                                      isSystemMessage: message["is_system_message"] ?? false,
                                      userId: message["user_id"],
                                      success: message["success"] == null ? true : message["success"],
                                      infoThread: message["info_thread"] != null ? message["info_thread"] : [],
                                      isAfterThread: message["isAfterThread"] ?? false,
                                      showHeader: false ,
                                      showNewUser: message["showNewUser"] ?? false,
                                      isBlur:  message["isBlur"] == null ?  false:  message["isBlur"],
                                      reactions: message["reactions"] == null ? [] : message["reactions"],
                                      idMessageToJump: idMessageToJump,
                                      onFirstFrameDone: (widget.isNavigator ?? false) ? onFirstFrameMessageSelectedToJumpDone : null,
                                      firstMessage: message["firstMessage"] ?? false,
                                      // lastEditedAt: Utils.checkedTypeEmpty(message["last_edited_at"]) && message["last_edited_at"] != "null" ? message["last_edited_at"] : null,
                                      waittingForResponse: (message["status_decrypted"] ?? "") == "decryptionFailed",
                                      isConversation: true,
                                      isUnreadThreadMessage: ((dataInfoThreadMessage[message["id"]])?.isRead ?? true),
                                      isUnsent: (message["action"] ?? "") == "delete",
                                      currentTime: message["current_time"],
                                      isOnline: listIdUserOnline.contains(message["user_id"]),
                                      isDark: isDark,
                                      messageAction: message["action"],
                                      onReplyMessage: onReplyMessage,
                                    ),
                                  ],
                                );
                              }
                            )
                          ),
                          TypingMobile(id: directMessage.id),
                          Container(
                            
                            child: StreamBuilder(
                              initialData: heightInput,
                              stream: heightInputController.stream,
                              builder: (context, snapshot) {
                                bool disableSendButtons = !isFocus && !Utils.checkedTypeEmpty(textInput) && (fileItems.length == 0);
                                return Stack(
                                  children: [
                                    SlidingUpPanel(
                                      isDraggable: !isFocus &&  (fileItems.length == 0)  ? false : true,
                                      onPanelSlide: (double value) {
                                        if(value != 0.0) {
                                          isBlock = true;
                                        } else {
                                          if(isBlock) {
                                            Future.delayed(Duration(milliseconds: 1000), () {
                                              isBlock = false;
                                            });
                                          } else {
                                            FocusScope.of(context).unfocus();
                                          }
                                        }
                                      },
                                      border: Border(
                                        top: BorderSide(color: isDark ? Color(0xff707070) : Color(0xFFB7B7B7), width: 0.5),
                                      ),
                                      color: isDark ? Color(0xff2E2E2E) : Color(0xfff5f5f5),
                                      boxShadow : const <BoxShadow>[BoxShadow(blurRadius: 8.0, color: Color.fromARGB(0, 0, 0, 0))],
                                      controller: panelController,
                                      minHeight: (!disableSendButtons
                                        ? (isAndroid ? 50 : 52) + heightInput
                                        : (isAndroid ? 58 : 60)
                                      ) + (isFocus ? 0 : (isAndroid ? 0 : 20)),
                                      maxHeight: (disableSendButtons ? 68 : 300) + (isFocus ? 0 : (isAndroid ? 0 : 20)),
                                      panelSnapping: true,
                                      padding: EdgeInsets.only(bottom: isFocus ? 0 : (isAndroid ? 0 : 20)),
                                      panel: Container(
                                        child: Column(
                                          children: [
                                           (isFocus && (fileItems.length == 0)) ? Container(
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
                                                  fileItems.length > 0 ? FileItems(files: fileItems, removeFile: removeImage) : Container(),
                                                  Focus(
                                                    onFocusChange: (bool value) {
                                                      if(isFocus != value) {
                                                        setState(() {
                                                          isFocus = value;
                                                        });
                                                      }
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.only(top: disableSendButtons ? 10 : 0),
                                                      child: FlutterMentions(
                                                        textCapitalization: TextCapitalization.sentences,
                                                        readOnly: isPanchat.length > 0 ? true : false,
                                                        onTap: () {
                                                          heightInputController.add(heightInput);
                                                        },
                                                        cursorColor: theme == ThemeType.DARK ? Colors.grey[400]! : Colors.black87,
                                                        key: key,
                                                        id: widget.dataDirectMessage.id.toString(),
                                                        isDark: auth.theme == ThemeType.DARK,
                                                        style: TextStyle(fontSize: 15.5, color: theme == ThemeType.DARK ? Colors.grey[300] : Colors.grey[800]),
                                                        decoration: InputDecoration(
                                                          border: InputBorder.none,
                                                          focusedBorder: InputBorder.none,
                                                          enabledBorder: InputBorder.none,
                                                          errorBorder: InputBorder.none,
                                                          disabledBorder: InputBorder.none,
                                                          contentPadding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                                                          hintText: isPanchat.length > 0
                                                            ? "This sender does not support replies"
                                                            : "${S.current.typeAMessage}...",
                                                          hintStyle: TextStyle(color: Colors.grey[600])
                                                              // : Utils.getString("Message ${directMessage.displayName}", 20),
                                                        ),
                                                        islastEdited: false,
                                                        onChanged: (value) {
                                                          String text = value.trim();
                                                          saveChangesToHive();
                                                  
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
                                                                payload: {"conversation_id": getIdConversation(), "user_name": currentUser["full_name"]}
                                                              );
                                                            });
                                                          }
                                                        },
                                                        suggestionListHeight: 200,
                                                        onSearchChanged: (trigger, onGetMentions) {
                                                          if (trigger == "@"){
                                                            // getDataMentions();
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
                                                            matchAll: true
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
                                                          if(!isFocus && !Utils.checkedTypeEmpty(textInput) && (fileItems.length == 0) && isPanchat.length == 0) InkWell(
                                                            onTap: onShowDialogMoreAction,
                                                            child: Container(
                                                              height: 32, width: 32,
                                                              decoration: BoxDecoration(
                                                                color : isDark ? Color(0xff4C4C4C) : Color(0xffdbdbdb),
                                                                shape: BoxShape.circle,
                                                              ),
                                                              margin: const EdgeInsets.only(left: 12, bottom: 8, right: 4),
                                                              child: Icon(
                                                                PhosphorIcons.plus,
                                                                size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                        trailing: [
                                                          if(!isFocus && !Utils.checkedTypeEmpty(textInput) && fileItems.length == 0 && isPanchat.length == 0) Container(
                                                            margin: const EdgeInsets.only(left: 4, bottom: 4, right: 12),
                                                            child: Material(
                                                              color: Colors.transparent,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  selectSticker(context, _sentSticker, 0, _selectEmoji);
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
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if(Utils.checkedTypeEmpty(textInput) || isFocus || (fileItems.length != 0)) Positioned(
                                      bottom: isFocus ? 0 : (isAndroid ? 0 : 20), width: MediaQuery.of(context).size.width,
                                      child: renderActionInput()
                                    )
                                  ],
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                    dataMessageConversation.numberNewMessage!= null && dataMessageConversation.numberNewMessage != 0
                      ? Positioned(
                        bottom: 100,
                        height: 50,
                        left: 0,
                        right: 0,
                        // width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: HoverItem(

                            child: GestureDetector(
                              onTap: (){
                                Provider.of<DirectMessage>(context, listen: false).resetOneConversation(widget.dataDirectMessage.id);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: theme == ThemeType.DARK ? Palette.defaultBackgroundDark : Palette.defaultBackgroundLight,
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  border: Border.all(color: Color(0xFFbfbfbf), width: 1),
                                ),
                                child: Text(
                                  "${dataMessageConversation.numberNewMessage} new messages",
                                  style: TextStyle(fontSize: 12, color: theme == ThemeType.DARK ? Colors.white70 : Color(0xFF6a6e74)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      : Container()
                  ],
                ),
              ),
            ),
            Platform.isAndroid ? StreamBuilder(
              stream: heightKeyboadStream.stream,
              builder: (BuildContext c, s){
                return Container(height: heightKeyboard,);
              } 
            ) : Container()
          ],
        ),
      )
    );

  }
}

renderTextMention(att, isDark) {
  String message = '';

  for(final item in att["data"]) {
    if (['user', 'all', 'issue'].contains(item["type"])) {
      message += (item["trigger"] ?? "@") + item["name"];
    } else if(item['type'] == 'block_code') {
      message = "A block code";
      // if(item['isThreeBackstitch'] ?? false) {
      //   message += '\n' + item["value"] + '\n';
      // } else {
      //   message += item["value"];
      // }
    } else {
      message += item["value"];
    }
  }

  return message;
}

class FileItems extends StatelessWidget{
  final removeFile;
  final files;

  FileItems({
    Key? key,
    this.files,
    this.removeFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    final isDark = Provider.of<Auth>(context).theme == ThemeType.DARK;
    List replyMessage = files.where((ele) => !(ele is AssetEntity) && !(ele is PlatformFile) && ele["mime_type"] == "share").toList();
    final indexReplyMessage = files.indexWhere((ele) => !(ele is AssetEntity) && !(ele is PlatformFile) && ele["mime_type"] == "share");
    List filesMessage = files.where((ele) => ((ele is Map) && (ele['mime_type'] != 'share')) || ele is AssetEntity || ele is PlatformFile).toList();

    return Column(
      children: [
        if(replyMessage.length > 0) Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "Replying"),
                          WidgetSpan(child: SizedBox(width: 4)),
                          TextSpan(text: replyMessage[0]["data"]["fullName"], style: TextStyle(fontWeight: FontWeight.bold))
                        ]
                      )
                    ),
                  ),
                  SizedBox(height: 4),
                  Utils.checkedTypeEmpty(replyMessage[0]["data"]["isUnsent"])
                  ? Container(
                    child: Text(
                      "[This message was deleted.]",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Color(isDark ? 0xffe8e8e8 : 0xff898989)
                      ),
                    ),
                  )
                  : (replyMessage[0]["data"]["message"] != "" && replyMessage[0]["data"]["message"] != null)
                    ? Container(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(replyMessage[0]["data"]["message"]),
                        replyMessage[0]["data"]["attachments"] != null && replyMessage[0]["data"]["attachments"].length > 0
                          ? Text("Attachments")
                          : Container()
                        ],
                      ),
                    )
                    : replyMessage[0]["data"]["attachments"] != null && replyMessage[0]["data"]["attachments"].length > 0
                      ? Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 4.3/5,
                          maxHeight: 20,
                        ),
                        padding: EdgeInsets.only(left: 3),
                          child: Container(
                            child: Text(
                              Utils.checkedTypeEmpty(replyMessage[0]["data"]["message"])
                                ? replyMessage[0]["data"]["message"]
                                : replyMessage[0]["data"]["attachments"][0]["type"] == "mention"
                                  ? renderTextMention(replyMessage[0]["data"]["attachments"][0], isDark)
                                  : replyMessage[0]["data"]["attachments"][0]["mime_type"] == "image"
                                    ? replyMessage[0]["data"]["attachments"][0]["name"]
                                    : "Parent message",
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        )
                    : Container(),
                ],
              ),
              Container(
                width: 30,
                height: 30,
                child: TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                    backgroundColor: MaterialStateProperty.all(Color(0xFF282c2e)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0))),
                  ),
                  onPressed: () {
                    removeFile(indexReplyMessage);
                  },
                  child: Icon(Icons.close, size: 16, color: Colors.grey[200])
                ),
              )
            ],
          ),
        ),
        // if(filesMessage.length > 0) Text("xyzxyz")
        if(filesMessage.length > 0) Container(
          height: 50,
          padding: EdgeInsets.only(left: 10, right: 10, top: 6),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: filesMessage.length,
             itemBuilder: (context, index){
              var file = filesMessage[index];

              if (file is AssetEntity || file is PlatformFile) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[700]
                      ),
                      margin: EdgeInsets.only(right: 5),
                      width: 45,
                      height: 45,
                      child: Center(
                        child: SpinKitCircle(
                          size: 20,
                          color: isDark ? Color(0xffFAAD14) : Colors.blueAccent,
                        )
                      )
                    ),
                    Positioned(
                      right: 6,
                      top: 1.5,
                      child: Container(
                        width: 15,
                        height: 15,
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                            backgroundColor: MaterialStateProperty.all(Color(0xFF282c2e)),
                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0))),
                          ),
                          onPressed: () {
                            removeFile(replyMessage.length > 0 ? index + 1 : index);
                          },
                          child: Icon(Icons.close, size: 10, color: Colors.grey[200])
                        )
                      )
                    )
                  ]
                );
              } else {
                switch (file["type"]) {
                  case "image":
                    return Container(
                      margin: EdgeInsets.only(right: 5),
                      child: Stack(children: [
                        file["bytes"] == null ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: file["content_url"] == null ? Image.file(File(file["path"]), height: 45, width: 45, cacheHeight: 90, fit: BoxFit.cover) :
                           Image.network(file["content_url"], height: 45, width: 45)
                        ) : ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                            child: Utils.checkedTypeEmpty(file["path"] != null)? Image.file(File(file["path"]), height: 45, width: 45, cacheHeight: 90, fit: BoxFit.cover)
                            : Image.memory(
                              file["bytes"],
                              height: 45,
                              width: 45,
                              fit: BoxFit.cover
                          )
                        ),
                        Positioned(
                          right: 1.5,
                          top: 1.5,
                          child: Container(
                            width: 15,
                            height: 15,
                            child: TextButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                backgroundColor: MaterialStateProperty.all(Color(0xFF282c2e)),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0))),
                              ),
                              onPressed: () {
                                removeFile(replyMessage.length > 0 ? index + 1 : index);
                              },
                              child: Icon(Icons.close, size: 10, color: Colors.grey[200])
                            ),
                          )
                        )
                      ]),
                    );

                  default:
                    return Container(
                      margin: EdgeInsets.only(right: 5),
                      child: Stack(children: [
                        ClipRRect(borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 45,
                            color: Color(0xFFf5f5f5),
                              width: 45,
                            child:Center(child: Text(file["mime_type"] ?? "File", style: TextStyle(color: Colors.black, fontSize: 10)))
                          )
                        ),
                        Positioned(
                          right: 1.5,
                          top: 1.5,
                          child: Container(
                            width: 15,
                            height: 15,
                            child: TextButton(
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                backgroundColor: MaterialStateProperty.all(Color(0xFF282c2e)),
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0))),
                              ),
                              onPressed: () {
                                removeFile(index);
                              },
                              child: Icon(Icons.close, size: 10, color: Colors.grey[200])
                            )
                          )
                        )
                      ])
                    );
                  }
              }
            }
          )
        ),
      ],
    );
  }
}