import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/chat_item.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';

abstract class Message{

  Widget render(BuildContext c, {Function? onTapMessage,}) {
    return Container();
  }

  Map toJson() {
    return {};
  }

}


class MessageChannel extends Message{
  String _id = "";
  int _channelId = 0;
  int _workspaceId = 0;
  String _message = "";
  int _currentTime = 0;
  List _attachments = [];
  List _dataRead = [];
  String? _parentId;
  String _insertedAt = "";
  List<InfoThread> _infoThread = [];
  String _userId = "";
  String _blockCode = "";
  bool _isUnsent = false;



  String get userId => this._userId;

  set userId( value) => this._userId = value;

  get id => this._id;

  set id( value) => this._id = value;

  get workspaceId => this._workspaceId;

  set workspaceId( value) => this._workspaceId = value;

  get channelId => this._channelId;

  set channelId( value) => this._channelId = value;
 
  get message => this._message;

  set message( value) => this._message = value;

  get currentTime => this._currentTime;

  set currentTime( value) => this._currentTime = value;

  get attachments => this._attachments;

  set attachments( value) => this._attachments = value;

  get dataRead => this._dataRead;

  set dataRead( value) => this._dataRead = value;

  get parentId => this._parentId;

  set parentId( value) => this._parentId = value;

  get insertedAt => this._insertedAt;

  set insertedAt( value) => this._insertedAt = value;

  get key => this.key;

  set key( value) => this.key = value;

  List<InfoThread> get  infoThread => this._infoThread;

  set infoThread( value) => this._infoThread = value;

  get blockCode => this._blockCode;

  set blockCode( value) => this.blockCode = value;

  get isUnsent => this._isUnsent;
  set isUnsent(value) => this.isUnsent;

  MessageChannel(String id, int workspaceId, int channelId, String message, int currentTime, List attachments, List dataRead, String? parentId, String insertedAt, String key, List<InfoThread> infoThread, String userId, isUnsent){
    this._id = id;
    this._workspaceId = workspaceId;
    this._channelId = channelId;
    this._message = message;
    this._currentTime = currentTime;
    this._attachments = attachments;
    this._dataRead = dataRead;
    this._parentId = parentId;
    this._insertedAt = insertedAt;
    this._infoThread = infoThread;
    this._userId = userId;
    this._isUnsent = isUnsent;
  }

  static MessageChannel parseFromJson(Map obj) {
    try {
      return MessageChannel(
        obj["id"] ?? "",
        int.parse("${obj["workspace_id"] ?? 0}"),
        int.parse("${obj["channel_id"] ?? 0}"),
        obj["message"] ?? "",
        obj["current_time"] ?? 0,
        obj["attachments"] ?? [],
        obj["data_read"] ?? [],
        obj["parent_id"],
        obj["inserted_at"] ?? "",
        obj["key"] ?? "",
        ((obj["info_thread"] ?? []) as List).map((e) => InfoThread.parseFromJson(e)).toList(),
        obj["user_id"] ?? "",
        obj["is_unsent"] ?? false
      );
    } catch (e) {
      print("______$e, $obj");
      return MessageChannel.parseFromJson({});
    }
   
  }

  Map toJson(){
    return{
      "id" : this.id,
      "inserted_at": this.insertedAt,
      "workspace_id": this._workspaceId,
      "channel_id": this._channelId,
      "message": this._message,
      "attachments": this._attachments,
      "_parentId": this._parentId,
      "current_time": this.currentTime
    };
  }

  Map getUser(BuildContext context) {
    try {
      final members = Provider.of<Workspaces>(context, listen: false).listWorkspaceMembers;
      final index = members.indexWhere((e) => e["id"] == userId);
      return members[index];
    } catch (e) {
      return {};
    }
  }

  void copyMessage(context) {
    var messagesData = this._attachments;

    List data = messagesData.length > 0 ? messagesData[0]["data"] : [];
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    
    String content = "";
    content = "";
    for(var i= 0; i< data.length ; i++){
      if (data[i]["type"] == "text" ) content += data[i]["value"];
      else content += "=======${data[i]["trigger"] ?? "@"}/${data[i]["value"]}^^^^^${data[i]["name"]}^^^^^${data[i]["type"] ?? ((data[i]["id"].length < 10) ? "all" : "user")}+++++++";
    }

    Clipboard.setData(new ClipboardData(text: content));
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

  Widget render(BuildContext context, { isChildMessage = false, onTapMessage}){
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    if (this.id  == "") return Container();
    Map userInfo = getUser(context);
    return Container(
      child: ChatItem(
        isThreadView: true,
        key: null,
        onEditMessage: (key){},
        copyMessage: (key) {
          copyMessage(context);
        },
        isChannel: true,
        id: this.id,
        isMe: this.userId == auth.userId,
        message: this.message ?? "",
        avatarUrl: userInfo["avatar_url"] ?? "",
        insertedAt: this.insertedAt,
        fullName: Utils.getUserNickName(this.userId) ?? userInfo["full_name"] ?? "",
        attachments: this.attachments,
        isFirst: true,
        count: this.infoThread.length,
        isLast: false,
        isChildMessage: isChildMessage ?? false,
        userId: this.userId,
        success: true,
        infoThread: this.infoThread.map((e) => e.toJson()).toList(),
        isAfterThread: false,
        showHeader: false,
        snippet:  "",
        blockCode: this.blockCode,
        showNewUser: true,
        isBlur: false,
        reactions: [],
        isSystemMessage: false,
        idMessageToJump: null,
        onFirstFrameDone: null,
        onTapMessage: onTapMessage,
        isDark: isDark,
        isMentionTab: true,
        currentTime: this.currentTime,
        isUnsent: this.isUnsent ?? false,
        workspaceId: this.workspaceId,
        channelId: this.channelId,
      )
    );
  }

}

class MessageConv extends Message{
  String _id = "";
  String _conversationId = "";
  String _message = "";
  int _currentTime = 0;
  List _attachments = [];
  List _dataRead = [];
  String? _parentId;
  String _insertedAt = "";
  String _fakeId = "";
  List<InfoThread> _infoThread = [];
  String _userId = "";
  String _statusDecrypted = "";
  String _action = "insert";

  get statusDecrypted => this._statusDecrypted;

 set statusDecrypted( value) => this._statusDecrypted = value;


  get userId => this._userId;

  set userId( value) => this._userId = value;

  get id => this._id;

  set id( value) => this._id = value;

  get conversationId => this._conversationId;

  set conversationId( value) => this._conversationId = value;

  get message => this._message;

  set message( value) => this._message = value;

  get currentTime => this._currentTime;

  set currentTime( value) => this._currentTime = value;

  get attachments => this._attachments;

  set attachments( value) => this._attachments = value;

  get dataRead => this._dataRead;

  set dataRead( value) => this._dataRead = value;

  get parentId => this._parentId;

  set parentId( value) => this._parentId = value;

  get insertedAt => this._insertedAt;

  set insertedAt( value) => this._insertedAt = value;

  get fakeId => this._fakeId;

  set fakeId( value) => this._fakeId = value;

  get infoThread => this._infoThread;

  set infoThread( value) => this._infoThread = value;

  MessageConv(String id, String conversationId, String message, int currentTime, List attachments, List dataRead, String? parentId, String insertedAt, String fakeId, List<InfoThread> infoThread, String userId, String statusDecrypted, String action){
    this.id = id;
    this._conversationId = conversationId;
    this._message = message;
    this._currentTime = currentTime;
    this._attachments = attachments;
    this._dataRead = dataRead;
    this._parentId = parentId;
    this._insertedAt = insertedAt;
    this._fakeId = fakeId;
    this._infoThread = infoThread;
    this._userId = userId;
    this._statusDecrypted = statusDecrypted;
    this._action = action;
  }

  static MessageConv parseFromJson(obj)  {

    return MessageConv(
      obj["id"] ?? "",
      obj["conversation_id"] ?? "",
      obj["message"] ?? "",
      obj["current_time"] ?? 0,
      obj["attachments"] ?? [],
      obj["data_read"] ?? [],
      obj["parent_id"],
      obj["inserted_at"] ?? "",
      obj["fakeId"] ?? "",
      ((obj["info_thread"] ?? []) as List).map((e) => InfoThread.parseFromJson(e)).toList(),
      obj["user_id"] ?? "",
      obj["status_decrypted"] ?? "success",
      obj["action"] ?? "insert"
    );

  }

  Map toJson(){
    return {
      "message": this.message,
      "conversation_id": this.conversationId,
      "status_decrypted": this.statusDecrypted,
      "id": this.id,
      "current_time": this.currentTime,
      "parent_id": this.parentId,
      "inserted_at": this.insertedAt,
      "attachments": this.attachments
    };
  }

  Map getUserInfo(context){
    try {
      var indexDM = Provider.of<DirectMessage>(context, listen: false).data.indexWhere((element) => element.id == this.conversationId);
      // print("{{{{{{{{{{{{{{{{{{$indexDM, ${this.toJson()}");
      if (indexDM == -1) return {};
      var indexUser = (Provider.of<DirectMessage>(context, listen: false).data[indexDM] as DirectModel).user.indexWhere((element) => element["user_id"] == this.userId);
      if (indexUser == -1) return {};
      return (Provider.of<DirectMessage>(context, listen: false).data[indexDM] as DirectModel).user[indexUser];
    } catch (e, t) {
      print("catch: $e $t");
      return {};
    }
  }

  void copyMessage(context){
    var messagesData = this._attachments;

    List data = messagesData.length > 0 ? messagesData[0]["data"] : [];
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    
    String content = "";
    content = "";
    for(var i= 0; i< data.length ; i++){
      if (data[i]["type"] == "text" ) content += data[i]["value"];
      else content += "=======${data[i]["trigger"] ?? "@"}/${data[i]["value"]}^^^^^${data[i]["name"]}^^^^^${data[i]["type"] ?? ((data[i]["id"].length < 10) ? "all" : "user")}+++++++";
    }

    Clipboard.setData(new ClipboardData(text: content));
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

  render(BuildContext context, { isChildMessage =  false, onTapMessage}) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    Map userInfo = getUserInfo(context);
    return Container(
      child: ChatItem(
        copyMessage: (key) {
          copyMessage(context);
        },
        isThreadView: true,
        isChannel: false,
        id: this.id,
        isMe: this.userId == auth.userId,
        message:  this.message ?? "",
        avatarUrl: userInfo["avatar_url"],
        insertedAt: this.insertedAt,
        fullName: userInfo["full_name"],
        conversationId: this.conversationId,
        attachments: this.attachments,
        isFirst: true,
        count: this.infoThread.length,
        isLast: true,
        isChildMessage: isChildMessage?? false,
        isSystemMessage: false,
        userId: this.userId,
        success:true,
        infoThread: [],
        isAfterThread:false,
        showHeader: true ,
        showNewUser: true,
        isBlur: false,
        reactions:[],
        idMessageToJump: null,
        onFirstFrameDone:  null,
        onTapMessage: onTapMessage,
        isDark: isDark,
        isUnsent: this._action != "insert",
        waittingForResponse: this.statusDecrypted != "success",
        currentTime: this.currentTime
      ),
    );
  }
}

class InfoThread{
  String _userId = "";
  String _insertedAt = "";
  String _avatarUrl = "";

  InfoThread(String userId, String insertedAt, String avatarUrl){
    this._avatarUrl = avatarUrl;
    this._insertedAt = insertedAt;
    this._userId  = userId;
  }
  static InfoThread parseFromJson(obj){
    return InfoThread(obj["user_id"] ?? "", obj["inserted_at"] ?? "", obj["avatar_url"] ?? "");

  }

  Map toJson(){
    return {
      "user_id": this._userId,
      "inserted_at": this._insertedAt,
      "avatar_url": this._avatarUrl
    };
  }
}