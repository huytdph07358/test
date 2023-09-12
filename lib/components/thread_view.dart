import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:heic_to_jpg/heic_to_jpg.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart' hide ImageFormat;
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/progress.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/chat_item.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/controller/direct_message_controller.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/conversation.dart';
import 'package:workcake/screens/message.dart';
import 'package:workcake/service_locator.dart';
import 'package:workcake/src/mention_view_new.dart';

import '../../flutter_mentions.dart';
import '../../generated/l10n.dart';
import '../common/palette.dart';

class ThreadView extends StatefulWidget {
  final isChannel;
  final idMessage;
  final keyDB;
  final idConversation;
  final channelId;
  final String? idMessageToJump;

  ThreadView({Key? key, @required this.idMessage, @required this.keyDB, @required this.isChannel, this.idConversation, this.channelId,  this.idMessageToJump});

  @override
  _ThreadView createState() => _ThreadView();
}

class _ThreadView extends State<ThreadView> {
  // NOTE
  // phan tu dau tien cua data dung de render parentMessage, nen luon phai co
  List data = [{}];
  var controller = ScrollController();
  List images = [];
  String textMessage = "";
  var messageParent;
  var selectedMessage;
  var focusNode;
  bool isMentions = true;
  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
  late ConversationMessageData? currentDataMessageConversation;
  var channel;
  String textInput = "";
  // final picker = ImagePicker();
  bool isFocus = false;
  double heightKeyboard = 0;
  final int placeBottom = Platform.isAndroid ? 30 : 34;
  final positionController = StreamController<double>.broadcast(sync: false);
  final heightInputController =  StreamController<double>.broadcast(sync: false);
  GlobalKey contaierMention = GlobalKey();
  double bot = 0.0;
  double heightInput = 48.0;
  PanelController panelController = PanelController();
  GlobalKey keyMessageToJump = GlobalKey();
  bool isShow = false;
  bool isEdit = false;
  bool connectionStatus = true;
  bool isBlock = false;

  @override
  void initState() {
    super.initState();

    var token = Provider.of<Auth>(context, listen: false).token;
    channel = Provider.of<Auth>(context, listen: false).channel;

    if (widget.isChannel) {
      getDataChannelThread();
      channel.on("reaction_channel_message", (data, _ref, _j){
        updateReactionChannelMessage(data);
      });
    } else {
      DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.idConversation);
      if (dm == null || channel == null) return;
      List<ConversationMessageData> dataMessageConversation =  Provider.of<DirectMessage>(context, listen: false).dataDMMessages.where((element) => element.conversationId == dm.id).toList();
      channel.on("new_thread_count_conversation", (data, _ref, _joinRef) {
        processData(data["data"], dm.id);
      });
      channel.on("update_dm_thread_message", (data, _ref, _joinRef){
        processUpdateDM(data);
      });

      channel.on("delete_message_dm", (dataSocket, _r, _j){
        if (dataSocket == null) return;
        final conversationId = dataSocket["conversation_id"];
        if (conversationId == dm.id && this.mounted){
          var messageDeleted = dataSocket["message_ids"];
          messageDeleted.map((mid) {
          Provider.of<DirectMessage>(context, listen: false).updateDeleteMessage(token, conversationId, mid);
          }).toList();

          setState(() {
            data = data.map((dataM){
              var indexInDelete = (messageDeleted as List).indexWhere((element) => element == dataM["id"]);
              if (indexInDelete == -1) return dataM;
              return {
                ...(dataM as Map),
                "action": "delete"
              };
            }).toList();
          });
        }
      });

      channel.on("delete_for_me", (dataSocket, _r, _j){
        if (dataSocket == null) return;
        final conversationId = dataSocket["conversation_id"];
        if (conversationId == dm.id && this.mounted){
          var messageDeleted = dataSocket["message_ids"];
          messageDeleted.map((mid) {
          Provider.of<DirectMessage>(context, listen: false).updateDeleteMessage(token, conversationId, mid, type: "delete_for_me");
          }).toList();

          setState(() {
            data = data.map((dataM){
              var indexInDelete = (messageDeleted as List).indexWhere((element) => element == dataM["id"]);
              if (indexInDelete == -1) return dataM;
              return {
                ...(dataM as Map),
                "action": "delete_for_me"
              };
            }).toList();
          });
        }
      });
      getData(dm.id, token);
      Timer.run(() async {
        messageParent = await MessageConversationServices.getListMessageById(dm, widget.idMessage, dm.id) ?? {};
        Provider.of<Messages>(context, listen: false).openThreadMessage(true, messageParent);
        var u = dm.user.where((element) => element["user_id"] == messageParent["user_id"]).toList();
        if (u.length > 0) {
          messageParent["fullName"] = u[0]["full_name"];
          messageParent["avatarUrl"] = u[0]["avatar_url"] ?? "";
        }
        setState(() {
          messageParent =  messageParent;
          currentDataMessageConversation  = dataMessageConversation.length  == 0? null :  dataMessageConversation[0];
        });
      });
    }
    focusNode =  FocusNode();

    channel.on("delete_message", (payload, ref, joinRef) {
      deleteMessage(payload);
    });
  }

  deleteMessage(payload) {
    if (mounted) {
      final messageId = payload["message_id"];
      final index = data.indexWhere((e) => e["id"] == messageId);

      if (index != -1) {
        List newData = List.from(data);
        newData.removeAt(index);

        setState(() {
          data = newData;
        });
      }
    }
  }


  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  updateReactionChannelMessage(dataReaction){
    Map dataM  = dataReaction["reactions"];
    var indexMessage =  data.indexWhere((element) => element["id"] == dataM["message_id"]);
    if (indexMessage != -1 && this.mounted){
      setState(() {
        data[indexMessage]["reactions"] = MessageConversationServices.processReaction(dataM["reactions"]);
      });

    }
  }

  processUpdateDM(dataM){
    var index  = -1;
    if(widget.isChannel) index = data.indexWhere((element) {return element["id"] == dataM["message_id"];});
    else index = data.indexWhere((element) {return element["id"] == dataM["id"];});
    if(index != -1 && this.mounted){
      setState(() {
        data[index]["message"] = dataM["message"];
        data[index]["attachments"] = dataM["attachments"];
      });
    }
  }

  processData(dataM, conversationId) async {
    try {
      for (var i =0; i< dataM.length; i++){
        var dataMessage  = dataM[i];
        var dataDe =  currentDataMessageConversation!.conversationKey!.decryptMessage(dataMessage);
        if(dataDe["success"]){
          dataMessage = dataDe["message"];
          // save to Isar
          // await MessageConversationServices.insertOrUpdateMessage(dataMessage);
          if (this.mounted && (dataMessage["parent_id"] == widget.idMessage) && (conversationId == dataMessage["conversation_id"])) {
            setState(() {
              data = data + [dataDe["message"]];
              if (messageParent != null) {
                // messageParent["count"] = messageParent["count"] + 1;
              }
            });
            // update message
          }
        }
      }
    } catch (e, t) {
      print("__________________$e,  $t");
    }

  }

  getData(directMessageId, token) async {
    try {
      // mac dinh se hien thi data trong isar truoc
      // sau do se merge data tren server
      var messageId = widget.idMessage;
            DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(directMessageId);
      List dataFromIsar = await MessageConversationServices.getMessageThreadAll(dm!, directMessageId, messageId, parseJson: true);
      Provider.of<DirectMessage>(context, listen: false).getLocalPathAtts(dataFromIsar);
      final deviceId  =  await Utils.getDeviceId();
      final url = "${Utils.apiUrl}direct_messages/$directMessageId/thread_messages/$messageId/messages?token=$token&device_id=$deviceId&mark_read_thread=true";
      var response = await Dio().get(url);
      var dataRes = response.data;
      if (dataRes["success"] && this.mounted) {
        var result  = [];
        List<String> errorIds = [];
        List messageError = [];
        Map dataToSave = {};
        for (var i =0 ; i < dataRes["data"].length; i++){
          try {
            var dataM = currentDataMessageConversation!.conversationKey!.decryptMessage( dataRes["data"][i]);
            // merge data on Isar
            var indexFromIsar = dataFromIsar.indexWhere((element) => element["id"] == dataRes["data"][i]["id"]);
            var dataMessage = Utils.mergeMaps([
              indexFromIsar != -1 ? dataFromIsar[indexFromIsar] : {},
              {"conversation_id": directMessageId},
              dataM["success"] ? dataM["message"] : {},
            ]);
            if (dataMessage["id"] != null){
              result += [dataMessage];
              var key = messageId + "_" + dataMessage["id"];
              dataToSave["$key"] = dataMessage;
            } else {
              errorIds += [dataRes["data"][i]["id"]];
              messageError += [{
                ...(dataRes["data"][i]),
                "status_decrypted": "decryptionFailed"
              }];
            }
          } catch (e) {
            print("___ error $e");
          }
        }
        List successIds = await MessageConversationServices.insertOrUpdateMessages(result);
        Provider.of<DirectMessage>(context, listen: false).markReadConversationV2(token, directMessageId, successIds as List<String>, errorIds, false);
        result = MessageConversationServices.uniqById( [] + dataFromIsar + result + messageError);
        setState(() {
          data = data + result.reversed.toList() ;
        });
        DirectMessageController.getReactionMessages(result.map<String>((e) => e["id"]).toList(), directMessageId);
      }
    } catch (e) {
      print("Direct Error: $e ");
    }
  }
  // ham nay de lay thong tin channel_id, workspace_id cua thread
  Map getDataChannel(){
    try {
      List channels = Provider.of<Channels>(context, listen: false).data;
      int index = channels.indexWhere((element) => "${element["id"]}" == "${widget.channelId}");
      return {
        "channel_id": channels[index]["id"],
        "workspace_id": channels[index]["workspace_id"]
      };
    } catch (e) {
      return {};
    }
  }

  updateSocketChannel(payload) {
    if (this.mounted) {
      Map newMessage = payload["message"];

      if (messageParent != null) {
        final messageId = messageParent["id"];

        if (newMessage["channel_thread_id"] != null && newMessage["channel_thread_id"] ==  messageId) {
          setState(() {
            data = data + [newMessage];
          });
          if(controller.offset > 0){
            controller.jumpTo(0);
          }
          else{
             controller.jumpTo(0);
          }
        }
      }
    }
  }

  getDataChannelThread() async {
    final token = Provider.of<Auth>(context, listen: false).token;
    var channelData = getDataChannel();
    final workspaceId = channelData["workspace_id"] ?? "";
    final channelId = channelData["channel_id"] ?? "";
    final messageId = widget.idMessage;
    final channel = Provider.of<Auth>(context, listen: false).channel;

    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/messages/thread?message_id=$messageId&token=$token';
    try {
      final response = await Dio().get(url);
      var dataRes = response.data;

      if (dataRes["success"]) {
        List dataThreads = await MessageConversationServices.processBlockCodeMessage(dataRes["thread_messages"]);
        messageParent = (await MessageConversationServices.processBlockCodeMessage([dataRes["parent_message"]]))[0];
        setState(() {
          data = [messageParent] + MessageConversationServices.uniqById(dataThreads).reversed.toList();
        });
        Provider.of<Messages>(context, listen: false).openThreadMessage(true, messageParent);

        channel.on("new_message_channel", (payload, _ref, _joinRef) {
          updateSocketChannel(payload);
        });

        channel.on("update_channel_thread_message", (data, _ref, _joinRef){
          processUpdateDM(data);
        });

        channel.on("update_channel_message", (data, _ref, _joinRef){
          updateMessageInThread(data);
        });

        controller.jumpTo(0);
      } else {
        throw HttpException(dataRes["message"]);
      }
    } catch (e, trace) {
      print("Error: $e $trace");
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  updateMessageInThread(payload) {
    if (mounted) {
      if (payload["message_id"] == messageParent["id"]) {
        setState(() {
          messageParent["message"] = payload["message"];
          messageParent["attachments"] = payload["attachments"];
        });
      } else {
        final index = data.indexWhere((e) => e["id"] == payload["id"]);

        if (index != -1) {
          this.setState(() {
            data[index]["message"] = payload["message"];
            data[index]["attachments"] = payload["attachments"];
          });
        }
      }
    }
  }

  sendThreadMessage(directMessageId, token) {
    List files = images;
    final userId  = Provider.of<Auth>(context, listen: false).userId;
    final Document document = key.currentState!.document;

    if(!Utils.checkedTypeEmpty(document.toPlainText().trim()) && files.isEmpty) return;

    List attachments = Utils.checkedTypeEmpty(document.toPlainText().trim()) ? [{
      'type': "mention",
      'data': Utils.parseQuillController(document)
    }] : [];

    final dataMessage = {
      "message": '',
      "attachments": attachments,
      "conversation_id": directMessageId,
      "fake_id": Utils.getRandomString(20),
      "time_create": DateTime.now().add(new Duration(hours: -7)).toIso8601String(),
      "user_id": userId,
      "user_id_parent_message": messageParent["user_id"],
      "current_time_parent_message": messageParent["current_time"]
    };

    if (selectedMessage != null){
      // get message selected
      var idMessageSelected  =  selectedMessage.split("__")[1];
      var messageSelected =  data.firstWhere((element)  {return element["id"] == idMessageSelected;});
      var  attachments = messageSelected == null ? [] : messageSelected["attachments"] == null ? [] : messageSelected["attachments"];
      for(var i= 0; i < attachments.length; i ++){
        if ((attachments[i]["type"] ?? "") != "mention"){
          dataMessage["attachments"] +=[attachments[i]];
        }
      }
    }
    key.currentState!.controller.document = Document();
    if ((dataMessage["message"] == "") && (dataMessage["attachments"].length == 0) && (files.length == 0)){}
    else
      try {
        dataMessage["isThread"] = true;
        dataMessage["parentId"] = widget.idMessage;
        dataMessage["isSend"] = selectedMessage == null;
        if (selectedMessage == null) {} else {
          var id = selectedMessage.toString().split("__")[1];
          dataMessage["id"] = id;
        }
        setState(() {
          images = [];
        });

        Provider.of<DirectMessage>(context, listen: false).sendMessageWithImage(files, dataMessage, token);
      } catch (e) {
        print("$e ");
      }
  }

  removeImage(index) {
    List list = images;
    list.removeAt(index);
    this.setState(() {
      images = list;
    });
  }
  String uint8ListTob64(Uint8List uint8list) {
    String base64String = base64Encode(uint8list);
    return base64String;
  }

  loadAssets() async {
    List<AssetEntity> resultList = await Provider.of<Work>(context, listen: false).openFileSelector(context);
    setState(() {images = resultList;});
    List results = await Utils.handleFileData(resultList);

    if (!mounted) return;

    setState(() {
      images = results.where((e) => e.isNotEmpty).toList();
    });
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
  copyMessage(keyM) {
    String messageId  =  keyM.toString().split("__")[1];
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    String message = "";
    if (data.length > 0) {
      var indexMessage = data.indexWhere((element) {return element["id"] == messageId;});
      var dataM = data[indexMessage];
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

  onEditMessage(keyMessage) {
    var id = keyMessage.toString().split("__")[1];
    // focus input, set input value =  data, only apply with message != ""
    var index = data.indexWhere((element) {return element["id"] == id;});
    var dataM = data[index];
    if (index >= 0) {
      var mentions = dataM["attachments"] != null ? dataM["attachments"].where((element) => element["type"] == "mention").toList() : [];
      if (mentions.length > 0) {
        int index = (dataM['attachments'] ?? []).indexWhere((e) => e['type'] == 'mention');
        key.currentState!.controller.document = Document();

        if(index != -1) {
          final dataJson = dataM['attachments'][index]['jsonText'];
          isEdit = true;
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
      }

      var attOldMessage = dataM["attachments"] != null ? dataM["attachments"].where((ele) => ele["mime_type"] != "block_code" && ele["type"] != "mention" && ele["type"] != 'preview').toList() : [];
      setState((){
        images = attOldMessage;
      });
      selectedMessage = keyMessage;
      key.currentState!.focusNode.requestFocus();
    }
  }

  onFirstFrameMessageSelectedToJumpDone(){
    try {
      if (Utils.checkedTypeEmpty(widget.idMessageToJump)) {
        BuildContext? messageContext = keyMessageToJump.currentContext;
        if (messageContext == null) return;
        final renderObejctMessage = messageContext.findRenderObject() as RenderBox;
        var offsetGlobal = renderObejctMessage.localToGlobal(Offset.zero);
        var scrolllOffset = controller.offset - offsetGlobal.dy + MediaQuery.of(context).size.height / 2;
        controller.animateTo(scrolllOffset, duration: Duration(milliseconds: 50), curve: Curves.ease);
      }
    } catch (e, t) {
      print("______ $e $t");
    }
  }

  Widget renderMessage() {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    if (messageParent == null ) return Column(
      children: [
        shimmerEffect(context)
      ],
    );
    return ChatItem(
      onEditMessage: onEditMessage,
      copyMessage: copyMessage,
      channelId: getDataChannel()["channel_id"],
      id: messageParent["id"],
      message: messageParent["message"] ?? "",
      isMe: false,
      avatarUrl: messageParent["avatarUrl"],
      insertedAt: messageParent["time_create"],
      fullName: Utils.getUserNickName(messageParent["user_id"]) ?? messageParent["fullName"],
      isFirst: true,
      isLast: true,
      isChildMessage: false,
      isThreadView: true,
      attachments: messageParent["attachments"],
      count: data.length - 1,
      isChannel: widget.isChannel,
      userId: messageParent["user_id"],
      infoThread: [],
      snippet: messageParent["snippet"],
      blockCode: messageParent["block_code"],
      success: true,
      disableAction: true,
      reactions: messageParent["reactions"] == null ? [] : messageParent["reactions"],
      isThread: true,
      isUnsent: widget.isChannel ? messageParent["is_unsent"] : messageParent["action"] == "delete",
      isDark: isDark,
      currentTime: messageParent['current_time'],
      conversationId: widget.idConversation,
    );
  }

  handleFileData(String? name, String? mimeType, String path, Uint8List bytes) async{
    try {
      String? jpegPath = await HeicToJpg.convert(path);
      File jpeg = File.fromUri(Uri.parse(jpegPath!));
      var finalBytes = mimeType == "heic" ? await jpeg.readAsBytes() : bytes;

      return {
        "name": name,
        "file": finalBytes,
        "type": "image",
        "mime_type": mimeType ?? (name ?? "").split(".").last.toLowerCase()
      };
    } catch (e, trace){
      print("$e\n$trace");
    }
  }

  sendChannelThreadMessage(token) async {
    var channelData = getDataChannel();
    final workspaceId = channelData["workspace_id"] ?? "";
    final channelId = channelData["channel_id"] ?? "";
    final channelThreadId = widget.idMessage;
    final Document document = key.currentState!.document;

    if(!Utils.checkedTypeEmpty(document.toPlainText().trim()) && images.isEmpty) return;

    List attachments = Utils.checkedTypeEmpty(document.toPlainText().trim()) ? [{
      'type': "mention",
      'data': Utils.parseQuillController(document),
      'jsonText': document.toDelta().toJson()
    }] : [];

    var dataMessage  = {
      "channel_thread_id": channelThreadId,
      "channel_id": channelId,
      "workspace_id": workspaceId,
      "key": Utils.getRandomString(20),
      "message": '',
      "attachments": attachments,
    };

    if (selectedMessage != null){
      // get message selected
      var idMessageSelected  =  selectedMessage.split("__")[1];
      var messageSelected =  data.firstWhere((element)  {return element["id"] == idMessageSelected;});
      dataMessage["message_id"] = messageSelected["id"];
      List attachments = messageSelected == null ? [] : messageSelected["attachments"] == null ? [] : messageSelected["attachments"];
      // merger att ko phai la image
      for(final attachment in attachments) {
        if(!['mention', 'image'].contains(attachment["type"])) {
          dataMessage["attachments"] += [attachment];
        }
      }
    }

    // List previews = await Work.addPreviewToMessage(message["message"]);
    //   message["attachments"] += previews;

    setState(() { selectedMessage = null;});
    if (Utils.checkedTypeEmpty(key.currentState!.controller.plainTextEditingValue.text.trim()) || images.length > 0) {
      if (!Utils.checkedTypeEmpty((dataMessage["message_id"]))) {
        Provider.of<Messages>(context, listen: false).sendMessageWithImage(images, dataMessage, token);
        Future.delayed(const Duration(seconds: 3), () {
          int index = data.indexWhere((e) => e["key"] == dataMessage["key"]);
          if(index != -1 && data[index]["id"] == null) {
            data[index]["is_blur"] = true;
          }
        });
      } else {
        Provider.of<Messages>(context, listen: false).newUpdateChannelMessage(token, dataMessage, images);
      }
    }
    
    this.setState(() { images = []; });
    key.currentState!.controller.document = Document();
  }

  getSuggestionMentions() {
    List listUser = [];
    final bool isChannel = widget.isChannel ?? true;
    List<Map<String, dynamic>> dataList = [];
    final auth = Provider.of<Auth>(context, listen: false);

    if(isChannel) {
      List members = Provider.of<Channels>(context, listen: false).getChannelMember(widget.channelId);
      listUser = members.length < 2 ? [] : members;
    } else {
      final dataUserMentions = Provider.of<User>(context, listen: false).userMentionInDirect;
      final directMessage = Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.idConversation);
      listUser = (directMessage == null ? [] : directMessage.user) + dataUserMentions;
    }

    Map index = {};

    final List usersInThread = data.map((e) => e['user_id']).toList().reversed.toList();
    List infoThread = [];

    for(final item in usersInThread) {
      int index = infoThread.indexWhere((e) => e == usersInThread);
      if(index == -1) {
        infoThread.add(item);
        final int indexUser = listUser.indexWhere((ele) => (ele['id'] ?? ele['user_id']) == item);

        if(indexUser != -1) {
          final user = listUser[indexUser];
          List newList = List.from(listUser);
          newList.removeAt(indexUser);
          listUser = [user] + newList;
        }
      }
    }

    for (final user in listUser){
      String keyId = user["user_id"] ?? user["id"];

      if (index[keyId] != null) continue;

      Map<String, dynamic> item = {
        'id': isChannel ? user["id"] : user["user_id"],
        'type': 'user',
        'display':Utils.getUserNickName(isChannel ? user["id"] : user["user_id"]) ?? user["full_name"],
        'full_name': Utils.checkedTypeEmpty(Utils.getUserNickName(isChannel ? user["id"] : user["user_id"]))
            ? "${Utils.getUserNickName(isChannel ? user["id"] : user["user_id"])} • ${user["full_name"]}"
            : user["full_name"],
        'photo': user["avatar_url"],
        'username': user['username']
      };

      index[keyId] = true;

      if ((isChannel && auth.userId != user["id"]) || (user["user_id"] != null && auth.userId != user["user_id"])) dataList += [item];
    }

    return dataList;
  }

  Widget renderMessageChild(index){
    if (data[index]["action"] == "delete_for_me") return Container();
    final DirectModel? directMessage =  Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.idConversation);

    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final locale = auth.locale;
    var listUser = directMessage == null ? [] : directMessage.user;
    if (index == 0) return renderMessage();
    String fullName = "";
    var u = listUser.where((element) => element["user_id"] == data[index]["user_id"]).toList();
    String avatarUrl = "";

    if (widget.isChannel || u.length > 0) {
      fullName = widget.isChannel ? Utils.getUserNickName(data[index]["user_id"]) ?? data[index]["full_name"] ?? "" : u[0]["full_name"];
      avatarUrl = widget.isChannel ? data[index]["avatar_url"] ?? "" : u[0]["avatar_url"] ?? u[0]["avatar_url"] ?? "";
    }

    List attachments = data[index]["attachments"] != null && data[index]["attachments"].length > 0 ? data[index]["attachments"] : [];

    bool showHeader = true;
    DateTime dateTime = DateTime.parse(data[index]["inserted_at"] ?? data[index]["time_create"]).add(Duration(hours: 7));
    var timeStamp = dateTime.toUtc().millisecondsSinceEpoch;
    bool showNewUser = true;

    if ((index -1 ) > 0 ) {
      DateTime prevTime = DateTime.parse(data[index - 1]["inserted_at"] ?? data[index - 1]["time_create"]).add(Duration(hours: 7));
      var prevTimeStamp = prevTime.toUtc().millisecondsSinceEpoch;
      showHeader = (dateTime.day != prevTime.day || dateTime.month != prevTime.month || dateTime.year != prevTime.year);
      showNewUser= prevTimeStamp + 600000 <= timeStamp ? true : false;
    } else showHeader = false;
    if (index == 1) showHeader = true;
    return Column(
      children: [
        showHeader ? Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Divider(height: 40, thickness: .5, color: isDark ? Color(0xff707070) : Color(0xFFB7B7B7))
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                child: Center(
                  child: Text(
                    DateFormatter().getVerboseDateTimeRepresentation(dateTime, locale).toUpperCase(),
                    style: TextStyle(fontSize: 12, color: Color(0xFF6a6e74)),
                  ),
                )
              ),
              Expanded(
                child: Divider(height: 40, thickness: .5, color: isDark ? Color(0xff707070) : Color(0xFFB7B7B7))
              )
            ]
          ),
        ) : SizedBox(),
        ChatItem(
          copyMessage: copyMessage,
          key: data[index]["id"] == widget.idMessageToJump ? keyMessageToJump : null,
          channelId: getDataChannel()["channel_id"],
          isChannel: widget.isChannel,
          id: data[index]["id"],
          isMe: data[index]["user_id"] == auth.userId,
          message: data[index]["message"] ?? "",
          avatarUrl: avatarUrl,
          insertedAt: data[index]["inserted_at"] ?? data[index]["time_create"],
          fullName: fullName,
          attachments: attachments,
          isFirst: index == 0
              ? true
              : data[index]["user_id"] != data[index - 1]["user_id"]
                ? true
                : false,
          count: 0,
          onEditMessage: onEditMessage,
          isLast: index == 0
            ? false
            : index == data.length - 1
              ? true
              : data[index]["user_id"] != data[index + 1]["user_id"]
                ? true
                : false,
          isChildMessage: true,
          userId: data[index]["user_id"],
          success: data[index]["success"] == null ? true : data[index]["success"],
          showHeader: showHeader,
          showNewUser: showNewUser,
          reactions: data[index]["reactions"] == null ? [] : data[index]["reactions"],
          isThread: true,
          conversationId: widget.idConversation,
          waittingForResponse: (data[index]["status_decrypted"] ?? "") == "decryptionFailed",
          isUnsent: widget.isChannel ? null : (data[index]["action"] ?? "") == "delete",
          currentTime: data[index]["current_time"],
          parentId: data[index]["parent_id"],
          isDark: isDark,
          messageAction:  data[index]["action"],
          onFirstFrameDone: data[index]["id"] == widget.idMessageToJump ? onFirstFrameMessageSelectedToJumpDone : (){} ,
          idMessageToJump: widget.idMessageToJump,
        )
      ]
    );
  }

  addStreamPosition(value) async {
    positionController.add(value);
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

  _sentSticker(data) {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    final channelThreadId = widget.idMessage;

    if (!widget.isChannel) {
      final DirectModel? directMessage =  Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.idConversation);
      if(directMessage == null) return;

      var dataMessage = {
        "message": '',
        "attachments": [{
          'type': 'sticker',
          'data': data
        }],
        "conversation_id": directMessage.id,
        "fake_id": Utils.getRandomString(20),
        "time_create": DateTime.now().add(const Duration(hours: -7)).toIso8601String(),
        "user_id": auth.userId,
        "current_time": DateTime.now().microsecondsSinceEpoch,
        "inserted_at": DateTime.now().add(const Duration(hours: -7)).toIso8601String(),
        "user": currentUser["full_name"] ?? "",
        "avatar_url": currentUser["avatar_url"] ?? "",
        "full_name": currentUser["full_name"] ?? "",
        "is_blur": false,
        "user_id_parent_message": messageParent["user_id"] ?? messageParent["userId"],
        "isThread": true,
        "parentId": channelThreadId,
        "isSend":  true
      };

      Provider.of<DirectMessage>(context, listen: false).sendMessageWithImage([], dataMessage, auth.token);
    } else {
      var channelData = getDataChannel();
      final workspaceId = channelData["workspace_id"] ?? "";
      final channelId = channelData["channel_id"] ?? "";

      var dataMessage = {
        "channel_thread_id": channelThreadId,
        "key": Utils.getRandomString(20),
        "message": "",
        "attachments": [{
          'type': 'sticker',
          'data': data
        }],
        "channel_id":  channelId,
        "workspace_id": workspaceId,
        "count_child": 0,
        "user_id": auth.userId,
        "user":currentUser["full_name"] ?? "",
        "avatar_url": currentUser["avatar_url"] ?? "",
        "full_name": Utils.getUserNickName(auth.userId) ?? currentUser["full_name"] ?? "",
        "inserted_at": DateTime.now().add(const Duration(hours: -7)).toIso8601String(),
        "is_system_message": false,
        "is_blur": false,
      };

      Provider.of<Messages>(context, listen: false).sendMessageWithImage([], dataMessage, auth.token);
    }
  }

  resendMessage(connectionProvider) async {
    if (connectionProvider != connectionStatus) {
      connectionStatus = connectionProvider;
      if (connectionStatus) {
        connectionStatus = connectionProvider;
        if (widget.isChannel) {
          await Provider.of<Auth>(context, listen: false).getQueueMessages(messageParent["channel_id"], threadId: messageParent["id"]);
          await getDataChannelThread();
        } else {
          var token = Provider.of<Auth>(context, listen: false).token;
          await Provider.of<DirectMessage>(context, listen: false).checkReSendMessageError(token, messageParent["conversation_id"], threadId: messageParent["id"]);
          DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.idConversation);
          if (dm == null) return;
          getData(dm.id, token);
        }
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
          selectSticker(context, _sentSticker, !this.widget.isChannel ? 0 : getDataChannel()["workspace_id"], _selectEmoji);
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

  Widget renderActionInput() {
    Auth auth = Provider.of<Auth>(context);
    final bool isDark = auth.theme == ThemeType.DARK;
    final DirectModel? directMessage = Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.idConversation);
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
                borderRadius: BorderRadius.circular(22),
                onTap: openCamera,
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
                onTap: () => selectSticker(context, _sentSticker, !widget.isChannel ? 0 : getDataChannel()["workspace_id"], _selectEmoji),
              ),
            ),
          ],
        ),

        Row(
          children: [
            isEdit == true ? Container(
              padding: const EdgeInsets.only(left: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: (){
                    setState(() {
                      isEdit = !isEdit;
                    });
                    selectedMessage = null;
                    key.currentState!.controller.document = Document();
                    key.currentState!.focusNode.requestFocus();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(PhosphorIcons.x, color: Palette.errorColor, size: 20,),
                  )
                ),
              ),
            ) : Container(),
            SizedBox(width: 6,),
            Container(
              padding: EdgeInsets.only(top: 6, right: 14, bottom: 6, left: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      isEdit ? PhosphorIcons.check  : PhosphorIcons.paperPlaneTilt,
                      size: 21,
                      color: (Utils.checkedTypeEmpty(textInput) || images.isNotEmpty) ? isDark ? Color(0xffFAAD14) : Color(0xff1890FF) : isDark ? Color(0xff828282) :  Color(0xffC9C9C9),
                    ),
                  ),
                  onTap: !Utils.checkedTypeEmpty(textInput) && images.isEmpty ? null : () async {
                    if (widget.isChannel) {
                      if(isEdit == true) {
                        setState(() {
                          isEdit = !isEdit;
                        });
                      }
                      sendChannelThreadMessage(auth.token);
                    } else {
                      sendThreadMessage(directMessage == null ? "" : directMessage.id, auth.token);
                    }

                    if(currentUser["off_sending_sound_status"] == false) {
                      Work.platform.invokeMethod("active_sound_send_message");
                    }
                  }
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  onShowDialogMoreAction() {
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;

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

  @override
  Widget build(BuildContext context) {
    final DirectModel? directMessage = Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.idConversation);
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final bool isAndroid = Platform.isAndroid;

    return Scaffold(
      backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      body: SafeArea(
        right: false, bottom: false,
        child: Container(
          child: Column(children: <Widget>[
            // Container(key: contaierMention,),
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
                          Provider.of<Messages>(context, listen: false).openThreadMessage(false, {});
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 60,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        child: Text(
                          "Threads",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )
                        ),
                      ),
                      Container(
                        width: 60,
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: isDark ? Color(0xff353535) : Colors.white,
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignmen,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          color: isDark ? Color(0xff353535) : Colors.white,
                          child: SingleChildScrollView(
                            // keyboardDismissBehavior:  ScrollViewKeyboardDismissBehavior.onDrag,
                            controller: controller,
                            reverse: true,
                            child: Column(
                              children: (data).asMap().map((index, message) => MapEntry(index, renderMessageChild(index))).values.toList()
                            ),
                          ),
                        )
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: StreamBuilder(
                  initialData: heightInput,
                  stream: heightInputController.stream,
                  builder: (context, snapshot) {
                    bool disableSendButtons = !isFocus && !Utils.checkedTypeEmpty(textInput) && images.length == 0;
                    return Stack(
                      children: [
                        SlidingUpPanel(
                          panelSnapping: true,
                          isDraggable: (!isFocus && images.length == 0) ? false : true,
                          color: isDark ? Color(0xff2E2E2E) : Color(0xfff5f5f5),
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
                          padding: EdgeInsets.only(
                            top: (disableSendButtons ? 10 : 0),
                            bottom: isFocus ? 0 : (isAndroid ? 0 : 20)
                          ),
                          border: Border(
                            top: BorderSide(color: isDark ? Color(0xff707070) : Color(0xFFB7B7B7), width: 0.5),
                          ),
                          boxShadow : const <BoxShadow>[BoxShadow(blurRadius: 8.0, color: Color.fromARGB(0, 0, 0, 0))],
                          controller: panelController,
                          minHeight: (!disableSendButtons
                            ? (isAndroid ? 54 : 56) + heightInput
                            : (isAndroid ? 58 : 60)
                          ) + (isFocus ? 0 : (isAndroid ? 0 : 20)),
                          maxHeight: (disableSendButtons ? 60 : 300) + (isFocus ? 0 : (isAndroid ? 0 : 20)),
                          panel: Column(
                            children: [
                              !disableSendButtons ? Center(
                                child: Container(
                                  margin: EdgeInsets.only(top: 5),
                                  height: 4, width: 50,
                                  decoration: BoxDecoration(
                                    color: isDark ? Color(0xFF5E5E5E) :Color(0xffC9C9C9),
                                    borderRadius: BorderRadius.circular(16)
                                  )
                                ),
                              ) : Container(),
                              MeasureSize(
                                onChange: (Size size) {
                                  heightInput = size.height;
                                  heightInputController.add(size.height);
                                },
                                child: Column(
                                  children: [
                                    images.length > 0 ? FileItems(files: images, removeFile: removeImage) : Container(),
                                    Focus(
                                      onFocusChange: (bool value) {
                                        if(value != isFocus) {
                                          setState(() {
                                            isFocus = value;
                                          });
                                        }
                                      },
                                      child: FlutterMentions(
                                        onTap: () {
                                          heightInputController.add(heightInput);
                                        },
                                        cursorColor: isDark ? Colors.grey[400]! : Colors.black87,
                                        key: key,
                                        id: "thread",
                                        isDark: auth.theme == ThemeType.DARK,
                                        style: TextStyle(fontSize: 15, color: isDark ? Colors.grey[300] : Colors.grey[800]),
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                            left: 10, top: 10,right: 10,
                                          ),
                                          hintText: Utils.getString("${S.current.typeAMessage} ${directMessage == null ? "" : directMessage.name }", 20),
                                          hintStyle: TextStyle(color: Colors.grey[600])
                                        ),
                                        islastEdited: false,
                                        onSearchChanged: (trigger, onGetMentions) { },
                                        onChanged: (str) {
                                          String text = str.trim();
                                          if(text.length == 0 && textInput.length != 0) {
                                            setState(() {
                                              textInput = text;
                                            });
                                          } else if(text.length != 0 && textInput.length == 0){
                                            setState(() {
                                              textInput = text;
                                            });
                                          }
                                        },
                                        mentions: [
                                          Mention(
                                            markupBuilder: (trigger, mention, value, type) {
                                              return "=======@/$mention^^^^^$value^^^^^$type+++++++";
                                            },
                                            trigger: '@',
                                            style: TextStyle(color: Colors.lightBlue),
                                            data: getSuggestionMentions(),
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
                                          if(disableSendButtons) InkWell(
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
                                          disableSendButtons ? Container(
                                            margin: const EdgeInsets.only(left: 4, bottom: 6, right: 12),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(22),
                                                child: Container(
                                                  padding: EdgeInsets.all(6),
                                                  child: Icon(
                                                    PhosphorIcons.sticker,
                                                    size: 24, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)
                                                  ),
                                                ),
                                                onTap: () => selectSticker(context, _sentSticker, !widget.isChannel ? 0 : getDataChannel()["workspace_id"], _selectEmoji),
                                              ),
                                            ),
                                          ) : Container(
                                            height: 48,
                                          )
                                        ]
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(!disableSendButtons) Positioned(
                          bottom: isFocus ? 0 : (isAndroid ? 0 : 20), width: MediaQuery.of(context).size.width,
                          child: renderActionInput()
                        )
                      ],
                    );
                  }
                )
              )
            ]
          ),
        )
      )
    );
  }
}


typedef void OnWidgetSizeChange(Size size);


class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}