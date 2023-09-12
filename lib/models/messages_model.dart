import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/service_locator.dart';
import 'package:workcake/services/queue.dart';

import 'models.dart';

class Messages with ChangeNotifier {
  List _data = [];
  bool _isFetching = false;
  var _lengthData;
  bool _openThread = false;
  Map _parentMessage = {};
  bool _onConversation = false;
  String _messageIdToJump = "";

  int  get lenghtData => _lengthData;
  bool get isFetching => _isFetching;
  List get data => _data;
  bool get openThread => _openThread;
  Map get parentMessage => _parentMessage;
  bool get onConversation => _onConversation;
  String get messageIdToJump => _messageIdToJump;

  // default MessageDataChannel
  Map defaultMessagesDataChannel = {
    "messages": [],
    "channelId": "",
    "workspaceId": "",
    "queue": null,
    "isLoadingUp": false,
    "disableLoadingUp": true,
    "isLoadingDown": false,
    "disableLoadingDown": false,
    // truong nay su dung khi nhay den tin nhan va tin nha do khong co trong list
    // mac dinh co gia tri null, khi nhay den message ko co san trong list => 0
    // khi gui tin nhan ma numberNewMessages != null => reset tin nhan ve rong roi nhan tin tiep
    "numberNewMessages": null,
    "last_message_readed": null,
  };

  resetMessage() async {
    _data = [];
  }

  onUpdateMessagesChannele(data){
    _data =_data.map((e){
      if ("${e["workspaceId"]}" != "${data["workspace_id"]}") return e;
      e["messages"] = (e["messages"] as List).map((ele){
        if(ele["user_id"] == data["user_id"]){
          ele["full_name"] = data["nickname"];
          }
          return ele;
        }).toList();
      return e;
    }).toList();
    notifyListeners();
  }

  Future<dynamic> loadMessages(token, workspaceId, channelId, {bool isReset = false, bool hasCheckInViewMessage = false}) async {
    int index = _data.indexWhere((e) => e["channelId"] == channelId);
    if (index == -1) {
      try {
        Map newData = {
          "channelId": channelId,
          "workspaceId": workspaceId,
          "messages":[],
          "queue": Scheduler()
        };
        _data = _data + [{
          ...defaultMessagesDataChannel,
          ...newData
        }];
        return loadMoreMessages(token, workspaceId, channelId, isReset: isReset, hasCheckInViewMessage: hasCheckInViewMessage);
      } catch (e) {
      }
    } else {
      if (isReset) return loadMoreMessages(token, workspaceId, channelId, isReset: isReset, hasCheckInViewMessage: hasCheckInViewMessage);
    }
  }

  replaceNickName(List messages) {
    List members = Provider.of<Workspaces>(Utils.globalContext!, listen: false).members;
    List nickNameMembers = members.where((ele) => Utils.checkedTypeEmpty(ele['nickname'])).toList();

    return messages.map((e) {
      int index = nickNameMembers.indexWhere((user) => user["id"]  == e["user_id"]);
      return {...e,
        "full_name": index == -1 ? e["full_name"] : (nickNameMembers[index]["nickname"] ?? e["full_name"])
      };
    }).toList();
  }

  Future<dynamic> loadMoreMessages(String token, workspaceId, channelId, {bool isReset = false, bool hasCheckInViewMessage = false}) async {
    int index = _data.indexWhere((e) => e["channelId"] == channelId);
    if (index == -1 || _data[index]["isLoadingDown"] || (!isReset && _data[index]["disableLoadingDown"])) return;
    var dataChannelMessage = _data[index];
    if (isReset) {
      dataChannelMessage["disableLoadingDown"] = false;
      dataChannelMessage["numberNewMessages"] = null;
    }

    dataChannelMessage["isLoadingDown"] = true;
    notifyListeners();

    List data = dataChannelMessage["messages"];
    var lastId  = (data.length == 0 || isReset ? "" : data.last["id"]) ?? "";

    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/messages?last_id=$lastId&token=$token';
    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        if (hasCheckInViewMessage && dataChannelMessage["messages"].length > 0 && Utils.checkInViewConverastion()) { 
          // dem so tin nhan moi
          Map first = dataChannelMessage["messages"].first;
          int indexFirst = (responseData["messages"] as List).indexWhere((element) => element["id"] == first["id"]);
          switch (indexFirst) {
            case -1:
              dataChannelMessage["numberNewMessages"] = 30;
              dataChannelMessage["disableLoadingUp"] = false;
              break;
            case 0:
              break;
            default:
              dataChannelMessage["numberNewMessages"] = indexFirst;
              dataChannelMessage["disableLoadingUp"] = false;
          }
        } else {
          _lengthData = responseData["messages"].length;
          dataChannelMessage["messages"] = sortMessagesByDay(MessageConversationServices.uniqById([] + await MessageConversationServices.processBlockCodeMessage(responseData["messages"]) + (isReset ? [] : dataChannelMessage["messages"])));
          dataChannelMessage["messages"] = replaceNickName(dataChannelMessage["messages"]);
          dataChannelMessage["disableLoadingDown"] = _lengthData == 0;          
        }

      } else {
        dataChannelMessage["disableLoadingDown"] = true;
        throw HttpException(responseData["message"]);
      }

      dataChannelMessage["isLoadingDown"] = false;
      notifyListeners();
    } catch (e) {
      dataChannelMessage["isLoadingDown"] = false;
      notifyListeners();
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
      return "error_process_message";
    }
  }

  Future<dynamic> newSendMessage(String token, Map message) async {
    var channelId = message["channel_id"];
    var workspaceId = message["workspace_id"];
    var indexChannel  = _data.indexWhere((element) => "${element["channelId"]}" == "$channelId");
    if (message["channel_thread_id"] != null) {
      queueBeforeSend(token, workspaceId, channelId, message);
    } else {
      if (indexChannel == -1) {
        if (message["from"] == "share") queueBeforeSend(token, int.parse("$workspaceId"), int.parse("$channelId"), message);
        return;
      }
      Scheduler queue =  _data[indexChannel]["queue"];
      // check sau 1s nếu vẫn đang sending thì đánh blur thành true
      // if (queue.getLength() != 0) message["isBlur"] = true;
      checkNewMessage(message);
      queue.schedule(() {
        return queueBeforeSend(token, int.parse("$workspaceId"), int.parse("$channelId"), message);
      });
    }
  }

  queueBeforeSend(String token, workspaceId, int channelId, Map message)async{
    try {
      final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/messages?token=$token';
      for (var i =0; i < message["attachments"].length; i++){
        if (message["attachments"][i]["type"] == "befor_upload")
          message["attachments"][i] = {
            "content_url": message["attachments"][i]["content_url"],
            "key": message["attachments"][i]["key"],
            "mime_type":  message["attachments"][i]["mime_type"],
            "type":  message["attachments"][i]["type_file"],
            "name": message["attachments"][i]["name"],
            "image_data": message["attachments"][i]["image_data"],
            "preview": message["attachments"][i]["preview"],
            "url_thumbnail" : message["attachments"][i]["url_thumbnail"]
          };
      }
      checkSuccessMessage(channelId, message);

      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(message));
      final responseData = json.decode(response.body);
      if (responseData['success']  == true) {
        message["success"] = true;
        message["sending"] = false;
        message["isBlur"] = false;
      } else {
        insetMessageErrorToReSend({...message, 'retries': 5});
        message["success"] = false;
        message["sending"] = false;
        message["isBlur"] = true;
        onUpdateChannelMessage(message);
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      insetMessageErrorToReSend({...message, 'retries': 5});
      message["success"] = false;
      message["sending"] = false;
      message["isBlur"] = true;
      onUpdateChannelMessage(message);
      print("______ $e");
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  checkSuccessMessage(channelId, message) {
    message["sending"] = true;
    int index = _data.indexWhere((e) => e["channelId"] == message["channel_id"]);

    Future.delayed(Duration(seconds: 3), () {
      if (index == -1) return;
      var indexMessage  = _data[index]["messages"].indexWhere((ele) => (Utils.checkedTypeEmpty(ele["key"]) && ele["key"] == message["key"]));
      if (indexMessage == -1) return;
      var dataMessage = _data[index]["messages"][indexMessage];
      if (dataMessage["sending"] == true && dataMessage["id"] == null) {
        dataMessage["isBlur"] = true;
        notifyListeners();
      }
    });
  }

  insetMessageErrorToReSend(Map message) async {
    try {
      var queueBox = Hive.box('queueMessages');
      var oldData = queueBox.get(message["key"]);
      queueBox.put(message["key"],
        {...message, ...(oldData ?? {})}
      );
    } catch (e) {
    }
  }

  checkMentions(message, {bool trim = false}){
    var text = trim ? message.trim() : message;
    RegExp exp = new RegExp(r"={7}[@|#][a-zA-Z0-9-\/\=\_]*\^{5}[\w\d\sÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀẾỂưăạảấầẩẫậắằẳẵặẹẻẽềếểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ.\/+!@&$]*\^{5}[a-zA-Z0-9]{1,}\+{7}");
    RegExp oldExp = new RegExp(r"={7}[@|#][a-zA-Z0-9-\/\=\_]*\^{5}[\w\d\sÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀẾỂưăạảấầẩẫậắằẳẵặẹẻẽềếểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ.\/+!@&$]*\+{7}");
    var matchOld = false;
    var matchs = exp.allMatches(text).toList();
    if (matchs.length == 0){
      matchs = oldExp.allMatches(text).toList();
      matchOld = true;
    }
    if (matchs.length == 0 ) return{
      "success": false,
      "data": text
    };
    else {
      var split = text.split(matchOld ? oldExp : exp);
      var result  = [];
      for(var i = 0; i < split.length; i++){
        var resultValue = regexMessageBlockCode(split[i]);
        String value = "";
        if (resultValue["success"]) {
          var listString = resultValue["data"].where((e) => e["type"] == "text").toList();
          value = listString.map((e) => e["value"]).toList().join("");
        } else {
          value = resultValue["data"];
        }
        result  += [{
          "type": "text",
          "value": value
        }];

        if (i < matchs.length){
          var message = matchs[i].group(0)!;
          var type = message.contains("=======#") ? "issue" : "user";
          if (type == "issue") {
            var text = (matchs[i].group(0)!.replaceAll("=======#/", "")).replaceAll("+++++++", "");
            var id = text.split("^^^^^")[0];
            var name = text.split("^^^^^")[1];

            result += [{
              "type": type,
              "value": id,
              "trigger": "#",
              "name": name
            }];
          } else {
            var text = (matchs[i].group(0)!.replaceAll("=======@/", "")).replaceAll("+++++++", "");
            var id  = text.split("^^^^^")[0];
            var name = text.split("^^^^^")[1];

            try {
              type = text.split("^^^^^")[2];
            } catch (e) {}
            // trigger hien chi ho tro mention @
            result  += [{
              "type": type,
              "value": id,
              "trigger": "@",
              "name": name
            }];
          }
        }
      }

      for (var i = 0; i < result.length; i++) {
        if (result[i]["type"] == "issue") {
          List list = result[i]["value"].split("-");
          result[i]["id"] = list[0];
          result[i]["workspace_id"] = list[1];
          result[i]["channel_id"] = list[2];
        }
      }

      return {
        "success": true,
        "data": result
      };
    }
  }

  regexMessageBlockCode(string) {
    RegExp exp = new RegExp(r"\`{3}[a-z0-9A-Z\@\s\\!\/\-()&?:}{\[\]\|=^%$#!~*_<>+]{1,5000}\`{3}");
    var matchs = exp.allMatches(string).toList();
    if (matchs.length == 0) {
      return {
        "success": false,
        "data": string
      };
    }
    else {
      var split = string.split(exp);
      var result  = [];
      for(var i = 0; i < split.length; i++){
        result  += [{
          "type": "text",
          "value": split[i]
        }];
        if (i < matchs.length){
          var text  = (matchs[i].group(0)!.replaceAll("```", ""));
          var snippet  = text.split("*****")[0];
          result  += [{
          "type": "block_code",
          "value": snippet.trim()
        }];
        }
      }
      return {
        "success": true,
        "data": result
      };
    }
  }

  Future<dynamic> newUpdateChannelMessage(token, message, List files) async {
    message["attachments"] = message["attachments"].where((e) => e["type"] != 'preview').toList();
    final String rawText = Utils.getRawTextFromAttachment(message["attachments"] ?? [], message["message"]);
    List previews = await Work.addPreviewToMessage(rawText);
    message["attachments"] += previews;

    if (Utils.checkedTypeEmpty(message["channel_thread_id"])){
      return queueBeforUpdate(token,  message["workspace_id"],  message["channel_id"], message);
    }
    var indexChannel  = _data.indexWhere((element) => element["channelId"] == message["channel_id"]);
    if (indexChannel == -1) return;
    if (message["attachments"].length > 0 || message["message"] != "" || files.length > 0) {
      // tai len tat ca cac att chua co content_url
      // attachments = Taast
      var dummyAtts = files.where((element) => element["content_url"] == null).map((e) {
        return {
          "att_id": e["att_id"],
          "name": e["name"],
          "type": "befor_upload",
          "progress": "0"
        };
      }).toList();
      var noDummyAtts = files.where((element) => element["content_url"] != null).toList();
      message["attachments"] = noDummyAtts + (Utils.checkedTypeEmpty(message["attachments"]) ? message["attachments"] + dummyAtts :  [] + dummyAtts);
      onUpdateChannelMessage(message);
      List resultUpload = await Future.wait(
        files.where((element) => element["content_url"] == null).map((item) async{
          final context = Utils.globalContext;
          var uploadFile = await Provider.of<Work>(context!, listen: false).getUploadData(item);
          return Provider.of<Work>(context, listen: false).uploadImage(token, message["workspace_id"], uploadFile, uploadFile["mime_type"] ?? "image", (value){
            if (message["isThread"] != null && message["isThread"]) return;
            var index  =  message["attachments"].indexWhere((ele) => ele["att_id"] == item["att_id"]);
            if (index != -1){
              message["attachments"][index]["progress"] = "${(value * 100).round()}";
              onUpdateChannelMessage(message);
            }
          });
        })
      );

      //  List failAtt =  resultUpload.where((element) => !element["success"]).toList();
      List successAtt = resultUpload.where((element) => element["success"]).toList();
      message["attachments"].removeWhere((ele) => ele["type"] == "befor_upload");
      message["attachments"] += successAtt;
      Scheduler queue =  _data[indexChannel]["queue"];
      // if (queue.getLength() != 0) message["isBlur"] = true;
      onUpdateChannelMessage(message);
      queue.schedule(() {
        return queueBeforUpdate(token,  message["workspace_id"],  message["channel_id"], message);
      });
    }
  }

  Future queueBeforUpdate(token, workspaceId, channelId, message) async{
    // remove dummy uploaf file
    for (var i =0; i < message["attachments"].length; i++){
      if (message["attachments"][i]["type"] == "befor_upload")
        message["attachments"][i] = {
          "content_url": message["attachments"][i]["content_url"],
          "name": message["attachments"][i]["name"],
          "mime_type": message["attachments"][i]["mime_type"],
          "type":  message["attachments"][i]["type_file"],
          "image_data": message["attachments"][i]["image_data"]
        };
    }
    try {
      final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/update_message?token=$token';
      var response = await Dio().post(url, data: message);
      var resData = response.data;
      if (resData["success"]) {
        message["isBlur"] = false;
        message["success"] = true;
        onUpdateChannelMessage(message);
      } else {
        message["isBlur"] = true;
        message["success"] = false;
        onUpdateChannelMessage(message);
      }
      notifyListeners();
    } catch (e) {
      print("errrpr $e");
      message["isBlur"] = true;
      message["success"] = false;
      onUpdateChannelMessage(message);
      // sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  onUpdateChannelMessage(dataM) async {
    if (dataM["channel_thread_id"] != null) return;

    int channelId = int.parse("${dataM["channel_id"]}");
    final indexChannel = _data.indexWhere((e) => e["channelId"] == channelId);

    if (indexChannel != -1) {
      final messageChannel = _data[indexChannel]["messages"];
      final indexMesasage = messageChannel.indexWhere((e) {
        return e["id"] != null && e["id"] == dataM["message_id"];
      });

      if (indexMesasage != -1 && Utils.checkedTypeEmpty(dataM["message_id"])) {
        messageChannel[indexMesasage] = Utils.mergeMaps([messageChannel[indexMesasage], dataM]);
      } else {
        if (dataM["key"] == null) return;
        final indexKey = messageChannel.indexWhere((e) {
          return e["key"] == dataM["key"];
        });
        if (indexKey != -1  && Utils.checkedTypeEmpty(dataM["key"])){
          messageChannel[indexKey] = Utils.mergeMaps([messageChannel[indexKey], dataM]);
        }
      }
      _data[indexChannel]["messages"] = await MessageConversationServices.processBlockCodeMessage(_data[indexChannel]["messages"]);
      notifyListeners();
    }
  }

  onUpdateProfile(data){
    _data =_data.map((e){
      e["messages"] = (e["messages"] as List).map((ele){
        if(ele["user_id"] == data["user_id"]){
          ele["avatar_url"] = data["avatar_url"];
          ele["full_name"] = data["full_name"];
        }
        return ele;
      }).toList();
      return e;
    }).toList();
    notifyListeners();
  }

  Future<dynamic> excuteCommand(token, workspaceId, channelId, command) async{
    final url = Utils.apiUrl + 'app/${command["app_id"]}/excute_command?token=$token';
    await Dio().post(url, data: command);
  }

  Future<dynamic> uploadThumbnail(String token, workspaceId, file, type) async {
    try {
      if (type != "mov" && type != "mp4" && type != "video") return {};
      var content = await getContentFromApi(token, workspaceId, file["path"]);
      if (content["success"]) {
        return content;
      } else {
        FormData formData = FormData.fromMap({
          "data": MultipartFile.fromBytes(
            file["path"],
            filename: file["filename"],
          ),
          "content_type": type,
          "filename": file["filename"]
        });

        final url = Utils.apiUrl + 'workspaces/$workspaceId/contents/v2?token=$token';
        final response = await Dio().post(url, data: formData);
        final responseData = response.data;
        return responseData;
      }
    } catch (e) {
      print("uploadThumbnail error: $e");
      return {};
    }
  }

  getContentFromApi(token, workspaceId, data) async {
    var bytes = utf8.encode(base64.encode(data)); // data being hashed
    var hashId = sha1.convert(bytes).toString().toLowerCase();

    final res = await http.get(Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/contents/$hashId?token=$token'));
    final responseData = json.decode(res.body);
    return responseData;
  }

  sendMessageWithImage(List files, Map message, String token) async {
    var channelId = message["channel_id"];
    var indexDataMessageChannel = _data.indexWhere((element) => "${element["channelId"]}" == "$channelId");
    if (indexDataMessageChannel != -1 && _data[indexDataMessageChannel]["numberNewMessages"] != null){
      resetOneChannelMessage(channelId);
      loadMoreMessages(token, message["workspace_id"], message["channel_id"]);
    }
    final String rawText = Utils.getRawTextFromAttachment(message["attachments"] ?? [], message["message"]);
    checkNewMessage(message);
    List previews = await Work.addPreviewToMessage(rawText);
    message["attachments"] = [] + message["attachments"] + previews;
    if (files.length == 0) return newSendMessage(token, message );

    try {
      for(var i = 0; i < files.length; i++){
        files[i]["att_id"] = Utils.getRandomString(10);
      }
      // doi voi sua tin nhan thi chi upload file chua cos content_url
      var dummyAtts = files.where((element) => element["content_url"] == null).map((e) {
        return {
          "att_id": e["att_id"],
          "name": e["name"],
          "type": "befor_upload",
          "progress": "0"
        };
      }).toList();
      message["attachments"] =  Utils.checkedTypeEmpty(message["attachments"]) ? message["attachments"] + dummyAtts :  [] + dummyAtts;
      checkNewMessage(message);
      List resultUpload = await Future.wait(
        files.where((element) => element["content_url"] == null && element["mime_type"] != "share").map((item) async{
          final context = Utils.globalContext;
          var uploadFile = await Provider.of<Work>(context!, listen: false).getUploadData(item);
          return Provider.of<Work>(context, listen: false).uploadImage(token, message["workspace_id"], uploadFile, uploadFile["mime_type"] ?? "image", (value){}, key: item["att_id"]);
        })
      );
      List failAtt =  resultUpload.where((element) => !element["success"]).toList();
      List successAtt = resultUpload.where((element) => element["success"]).toList();
      message["attachments"].removeWhere((ele) => ele["type"] == "befor_upload");
      message["attachments"] += successAtt;
      if(message["attachments"].length > 0 || message["message"] != "")
        newSendMessage(token, message);
      else removeMessageNoAttAndMessage(message);
      if (failAtt.length > 0){
        var messagFail = Map.from(message);
        messagFail["key"] = Utils.getRandomString(20);
        messagFail["attachments"] = failAtt;
        messagFail["message"] = "";
        createMessageUploadFail(messagFail);
      }
    } catch (e, trace) {
      print("sendMessageWithImage  $e and $trace");
      message["success"] = false;
      message["isBlur"] = true;
      onUpdateChannelMessage(message);
    }
  }

  removeMessageNoAttAndMessage(message){
    final indexChannel = _data.indexWhere((e) => "${e["channelId"]}" == "${message["channel_id"]}");
    _data[indexChannel]["messages"] = _data[indexChannel]["messages"].where((e) => e["key"] != message["key"]).toList();
    notifyListeners();
  }

  createMessageUploadFail(message){
    int channelId = int.parse("${message["channel_id"]}");
    final indexChannel = _data.indexWhere((e) => e["channelId"] == channelId);
    if (indexChannel != -1) {
      _data[indexChannel]["messages"] = [message] + _data[indexChannel]["messages"];
    }
    notifyListeners();
  }

  setDataDefault(){
    _data = [];
    notifyListeners();
  }

  updateMessage(message) {
    final channelId = message["channel_id"];
    int index = _data.indexWhere((e) => e["channelId"] == channelId);

    final newUser = {
      "user_id": message["user_id"],
      "inserted_at": message["inserted_at"],
      "avatar_url": message["avatar_url"],
      "full_name": message["full_name"]
    };


    if (index != -1) {
      List messages = _data[index]["messages"];
      int indexMessage = messages.indexWhere((e) => e["id"] == message["channel_thread_id"]);

      if (indexMessage != -1) {
        messages[indexMessage]["count_child"] = messages[indexMessage]["count_child"] + 1;

        if (messages[indexMessage]["info_thread"] != null ) {
          messages[indexMessage]["info_thread"] = [] + [newUser] + messages[indexMessage]["info_thread"];
        } else {
          messages[indexMessage]["info_thread"] = [] + [newUser];
        }
      }
    }

    notifyListeners();
  }

  checkNewMessage(message) async {
    if (message["channel_thread_id"] == null) {
      int index = _data.indexWhere((e) => "${e["channelId"]}" == "${message["channel_id"]}");
      if (index != -1) {
        Map newMessage = _data[index];
        // new message la dummy
        // cap nhat tin nhawn

        // trong truong hop co nhay den tin nhan cu(numberNewMessage = 0) thi se khong them vao provider, ma chi tang gia tri do len 1;
        // nguoi dung khi click vao numberNewMessage, se reset tin nhan
        if (_data[index]["numberNewMessages"] != null && Utils.checkedTypeEmpty(message["id"])) {
          _data[index]["numberNewMessages"] = _data[index]["numberNewMessages"] + 1;
          notifyListeners();
          return;
        }
        // trong truong hop con lai thi xu ly bt

        var indexKeyId  = newMessage["messages"].indexWhere((ele) => (Utils.checkedTypeEmpty(ele["key"]) && ele["key"] == message["key"]) );
        if (indexKeyId != -1) {
          newMessage["messages"][indexKeyId] = Utils.mergeMaps([
            newMessage["messages"][indexKeyId],
            message,
            {"isBlur": false, "success": true, "sending": false}
          ]);
          newMessage["messages"] = sortMessagesByDay(await MessageConversationServices.processBlockCodeMessage(newMessage["messages"]));
        } else {
          newMessage["messages"] = sortMessagesByDay(await MessageConversationServices.processBlockCodeMessage([message] + newMessage["messages"]));
        }

        notifyListeners();
      }
    }
  }

  resetStatus(token, context) async {
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    if (currentChannel["id"] != null && currentChannel["workspace_id"] != null) {
      _lengthData = 0;
      final channelId = currentChannel["id"];
      final workspaceId = currentChannel["workspace_id"];
      final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/messages?token=$token';
      try {
        final response = await http.get(Uri.parse(url));
        final responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          _data = _data.map((e) {
            if (e["channelId"] == channelId) return e;
            return {
              ...defaultMessagesDataChannel,
              "channelId": e["channelId"],
              "workspaceId": e["workspaceId"],
              "queue": e["queue"],
              "numberNewMessages": null
            };
          }).toList();
          _lengthData = responseData["messages"].length;
          notifyListeners();
        } else {
          throw HttpException(responseData['message']);
        }
        if (Utils.checkedTypeEmpty(channelId)) {
          // ktra xem neu dang o view conversation thi ko cap nhat nua
          loadMessages(token, workspaceId, channelId, isReset: true, hasCheckInViewMessage: true);
        }
      } catch (e) {
        print(e);
        sl.get<Auth>().showErrorDialog(e.toString());
      }
    }
  }

  openThreadMessage(value, message) {
    _openThread = value;
    _parentMessage = message;

    notifyListeners();
  }

  getMentionChannel(text, workspaceId, channelId, token)async {
    final url = "${Utils.apiUrl}workspaces/$workspaceId/channels/$channelId/search_member?text=$text&token=$token";
    try {
      var response  =  await Dio().get(url);
      var resData  = response.data;
      if (resData["success"]) return resData["members"];
      return [];

    } catch (e) {
      print("error $e");
      sl.get<Auth>().showErrorDialog(e.toString());
      return [];
    }
  }

  openConversation(value) {
    _onConversation = value;
  }

  Future<dynamic> deleteChannelMessage(String token, workspaceId, channelId, messageId) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/messages/delete_message?token=$token&message_id=$messageId';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers);
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {

      } else if (responseData['success'] == false) {
        throw HttpException(responseData['message']);
      }
      notifyListeners();
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  onSubmitPoll(token, workspaceId, channelId, messageId, selected, added, removed) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/messages/submit_poll?token=$token';

    try {
      var response = await Dio().post(url, data: {'removed': removed, 'selected': selected, 'added': added, 'message_id': messageId});
      var resData = response.data;
      if (resData["success"] == true) {

      } else {
        throw HttpException("submit poll error");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  updatePollStatus(token, workspaceId, channelId, messageId, attachments) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/messages/update_poll_status?token=$token';
    try {
      var response = await Dio().post(url, data: {'attachments': attachments, 'message_id': messageId});
      var resData = response.data;
      if (!resData["success"]) print("disable failed");
    } catch (e) {
      print(e.toString());
    }
  }

  deleteMessage(data) {
    final index = _data.indexWhere((e) => e["channelId"] == data["channel_id"]);
    if (index == -1) return;

    final messages = _data[index]["messages"];

    if (data["channel_thread_id"] == null) {
      final indexMessage = messages.indexWhere((e) => e["id"] == data["message_id"]);

      if (indexMessage != -1) {
        messages.removeAt(indexMessage);
        _data[index]["messages"] = sortMessagesByDay(messages.where((e) => (e["id"] ?? []).length != 10).toList());

        if (data["message_id"] == parentMessage["id"]) {
          openThreadMessage(false, {});
        }
        notifyListeners();
      }
    } else {
      final indexMessage = messages.indexWhere((e) => e["id"] == data["channel_thread_id"]);
      if (indexMessage != -1) {
        final indexInfo = messages[indexMessage]["info_thread"].indexWhere((e) => e["message_id"] == data["message_id"]);

        if (indexInfo != -1) {
          messages[indexMessage]["info_thread"].removeAt(indexInfo);
        }
        messages[indexMessage]["count_child"] = messages[indexMessage]["count_child"] - 1;
        notifyListeners();
      }
    }
  }

  reactionChannelMessage(data){
    final index = _data.indexWhere((e) => "${e["channelId"]}" == "${data["reactions"]["channel_id"]}");
    if (index != -1) {
      final indexMessage = _data[index]["messages"].indexWhere((e) => e["id"] == data["reactions"]["message_id"]);

      if (indexMessage != -1) {
        _data[index]["messages"][indexMessage]["reactions"] = MessageConversationServices.processReaction(data["reactions"]["reactions"]);
        notifyListeners();
      }
    }
  }

  handleReactionMessage(Map obj) async{
    String url  = "${Utils.apiUrl}workspaces/${obj["workspace_id"]}/channels/${obj["channel_id"]}/messages/handle_reaction_message?token=${obj["token"]}";
    var response = await Dio().post(url, data: obj);
    var dataRes = response.data;

    if (dataRes["success"]){
      // update
      final index = _data.indexWhere((e) => e["channelId"] == obj["channel_id"]);
      if (index != -1) {
        final indexMessage = _data[index]["messages"].indexWhere((e) => e["id"] == obj["message_id"]);
        if (indexMessage != -1) {
          _data[index]["messages"][indexMessage]["reactions"] = MessageConversationServices.processReaction(dataRes["reactions"]);
          notifyListeners();
        }
      }
    }
  }

  //  ham nay chi su dung khi  numberNewMessages != null va app dung khi gui tin nhan()
  resetOneChannelMessage(int channelId){
    int index = _data.indexWhere((e) => "${e["channelId"]}" == "$channelId");
    if (index == -1) return;
    _data[index] = {
      ...defaultMessagesDataChannel,
      ..._data[index],
      "messages": [],
      "numberNewMessages": null,
      "isLoadingUp": false,
      "disableLoadingUp": false,
      "isLoadingDown": false,
      "disableLoadingDown": false,
    };
    notifyListeners();
  }

  getMessageChannelUp(String token, int channelId, int workspaceId,  {bool isNotifyListeners = false, int limit = 30}) async {
    int indexChannelDataMessage = _data.indexWhere((element) => element["channelId"] == channelId);
    if (indexChannelDataMessage == -1 ) return;
    if (_data[indexChannelDataMessage]["disableLoadingUp"] || _data[indexChannelDataMessage]["isLoadingUp"]) return;
    Map dataMessageChannel = _data[indexChannelDataMessage];
    _data[indexChannelDataMessage]["isLoadingUp"] = true;
    notifyListeners();
    String lastId = dataMessageChannel["messages"].first["id"];
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/messages?latest_id=$lastId&token=$token&limit=$limit';
    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);
      if (responseData["success"] == true) {
        dataMessageChannel["messages"] = sortMessagesByDay(MessageConversationServices.uniqById([] + dataMessageChannel["messages"] + await MessageConversationServices.processBlockCodeMessage(responseData["messages"])));
        dataMessageChannel["messages"] = replaceNickName(dataMessageChannel["messages"]);
        dataMessageChannel["disableLoadingUp"] = responseData["messages"].length <= 1;
        dataMessageChannel["numberNewMessages"] = responseData["messages"].length <= 1 ? null : dataMessageChannel["numberNewMessages"];
        if (isNotifyListeners) notifyListeners();
      } else {
        throw HttpException(responseData["message"]);
      }
      dataMessageChannel["isLoadingUp"] = false;

    } catch (e) {
      dataMessageChannel["isLoadingUp"] = false;
      dataMessageChannel["disableLoadingUp"] = true;
      print(e);
      return "error_process_message";
      // sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  updatePollMessage(payload) async {
    final message = payload["message"];
    final index = _data.indexWhere((e) => "${e["channelId"]}" == "${message["channel_id"]}");
    if (index != -1) {
      final indexMessage = _data[index]["messages"].indexWhere((e) => e["id"] == message["id"]);

      if (indexMessage != -1) {
        List messages = _data[index]["messages"];
        messages[indexMessage]["attachments"] = message["attachments"];
        messages[indexMessage]["current_time"] = message["current_time"];

        if(indexMessage != messages.length - 1 && indexMessage != 0) {
          if(messages[indexMessage - 1]["attachments"].isNotEmpty && messages[indexMessage +  1]["attachments"].isNotEmpty) {
            bool shouldRemoveDate = messages[indexMessage - 1]["attachments"][0]["type"] == "datetime" && messages[indexMessage + 1]["attachments"][0]["type"] == "datetime";

            if(shouldRemoveDate) {
              messages.removeAt(indexMessage + 1);
            }
          }
        }

        (_data[index]["messages"] as List).sort((a, b) => (b["current_time"] ?? 0).compareTo((a["current_time"] ?? 0)));
        notifyListeners();
      }
    }
  }

  // xu ly tin nhan de nhay den
  handleProcessMessageToJump(Map message, BuildContext context) async {
    try {
      String token = Provider.of<Auth>(context, listen: false).token;
      int workspaceId = message["workspace_id"];
      int channelId = message["channel_id"];
      var indexChannelDataMessage = _data.indexWhere((element) => "${element["channelId"]}" == "$channelId");

      if (indexChannelDataMessage == -1 ) {
        _data = [] + _data + [{
          ...defaultMessagesDataChannel,
          "channelId": channelId,
          "workspaceId": workspaceId,
          "queue": Scheduler(),
          "numberNewMessages": 0,
        }];
        indexChannelDataMessage = _data.length -1;
      } else {
        _data[indexChannelDataMessage] = {
          ..._data[indexChannelDataMessage],
          "numberNewMessages": 0,
        };
      }
      // neu message nhay den chua co
      // + Reset tat conversationDataMessage ve mac dinh
      // goij api load 2 chiefutinhs tu message jump
      // cap nhat new_message_countve 0
      // new co tin nhan moi,
      // scroll xuong den khi nao khong the load moi dc nua
      // hoac click vafoso tin moi => reset laij hoi thoaij
      // neu gui tin moi => reset lai hoi thoai
      // viec nhay den tin nhan do view hien thi dam nhan
      _messageIdToJump = message["id"];
      int indexMessageToJump = _data[indexChannelDataMessage]["messages"].indexWhere((element) => element["id"] == message["id"]);
      if (indexMessageToJump != -1){
        // ko load them tin nham
      } else {
        _data[indexChannelDataMessage] = {
          ...defaultMessagesDataChannel,
          ..._data[indexChannelDataMessage],
          "messages": [] + [
            {
              "attachments": [],
              ...message,
              "is_system_message": false
            }
          ],
          "numberNewMessages": 0,
          "isLoadingUp": false,
          "disableLoadingUp": false,
        };
        Map dataChannelMessage = _data[indexChannelDataMessage];
        Future getDown() async{
          return await loadMoreMessages(token, workspaceId, channelId);
        }

        Future getUp() async{
          return await getMessageChannelUp(token, channelId, workspaceId, limit: 5);
        }

        List resApi = await Future.wait([
          getDown(),
          getUp(),
          // Provider.of<Workspaces>(context, listen: false).getInfoWorkspace(token, workspaceId, context)
        ]);

        if (resApi.join("_") == "error_process_message_error_process_message") {
          dataChannelMessage["messages"] = [];
          Fluttertoast.showToast(
            msg: "Error processing message",
            fontSize: 16,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black.withOpacity(0.2),
            toastLength: Toast.LENGTH_SHORT
          );
        }
      }
      // trong truong hop goi API ko thanh cong thi ko nhay den tin do nua

      if (Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"] != workspaceId) {
        Provider.of<Workspaces>(context, listen: false).selectWorkspace(token, workspaceId, context);
        Provider.of<Workspaces>(context, listen: false).setTab(workspaceId);
      }

      if (Provider.of<Channels>(context, listen: false).currentChannel["id"] != channelId) {
        Provider.of<Channels>(context, listen: false).setCurrentChannel(channelId);
        Provider.of<Channels>(context, listen: false).selectChannel(token, workspaceId, channelId);
      }

      Provider.of<User>(context, listen: false).selectTab("channel");      
    } catch (e, t) {
      print("_____$e, $t");
    }
    

  }

  setMessageIdToJump(value, {int delayTime = 0}) async {
    if (delayTime != 0) await Future.delayed(Duration(seconds: delayTime));
    _messageIdToJump = "";
    notifyListeners();
  }

  sortMessagesByDay(messages) {
    messages = messages.where((e) => e["is_datetime"] == null).toList();
    List listMessages = [];

    for (var i = 0; i < messages.length; i++) {
      try {
        listMessages.add(messages[i]);

        if ((i + 1) < messages.length) {
          var currentDay = DateFormat('MM-dd').format(DateTime.parse(messages[i]["inserted_at"]).add(Duration(hours: 7)));
          var nextday = DateFormat('MM-dd').format(DateTime.parse(messages[i+1]["inserted_at"]).add(Duration(hours: 7)));

          if (nextday != currentDay) {
            var stringDay = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(messages[i]["inserted_at"]).add(Duration(hours: 7)));
            var message = {...messages[i],
              "id": stringDay,
              "key": stringDay,
              "is_system_message": true,
              "attachments": [{"type": "datetime", "value": stringDay, "id": messages[i]["id"]}],
              "message": "",
              "channel_id": messages[i]["channel_id"],
              "workspace_id": messages[i]["workspace_id"],
              "is_datetime": true
            };

            listMessages.add(message);
          }
        }
      } catch (e) {
        continue;
      }
    }

    for (var index = 0; index < listMessages.length; index++) {
      try {
        int length = listMessages.length;
        var isFirst = (index + 1) < length ? ((listMessages[index + 1]["user_id"] != listMessages[index]["user_id"]) || listMessages[index + 1]["is_system_message"]) : true;
        var isLast = index == 0  ? true : listMessages[index]["user_id"] != listMessages[index - 1]["user_id"] ;
        bool showNewUser = false;

        if ((index + 1) < length) {
          showNewUser = (listMessages[index + 1]["current_time"] == null || listMessages[index]["current_time"] == null)
            ? false
            : (listMessages[index]["current_time"] - listMessages[index + 1]["current_time"]).abs() > 60000000;
        }

        var firstMessage = index + 1 < length && listMessages[index + 1]["is_datetime"] != null;
        var isAfterThread = (index + 1) < length ? (((listMessages[index +  1]["count_child"] ?? 0) > 0)) : false;

        listMessages[index]["isFirst"] = isFirst;
        listMessages[index]["isLast"] = isLast;
        listMessages[index]["showNewUser"] = showNewUser;
        listMessages[index]["firstMessage"] = firstMessage;
        listMessages[index]["index"] = index;
        listMessages[index]["isAfterThread"] = isAfterThread;
      } catch(e) {
        continue;
      }
    }

    return listMessages;
  }
}