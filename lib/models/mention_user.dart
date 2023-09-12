import 'package:workcake/models/issue.dart';
import 'package:workcake/models/message.dart';

abstract class MentionUser{
  String _id = "";
  String _personMentioned = "";
  String _creatorId = "";
  // String _conversationId = "";
  // String _messageId = "";
  // int _workspaceId = 0;
  // int _channelId = 0;
  // int _issueId = 0;
  String _type = "";
  bool _seen = false;
  bool _isSameTop = false;
  String _insertedAt = "";
  String _creatorName = "";
  String _creatorUrl = "";

  Map toJson();
  static MentionUser parseFromObject(Map obj){
    switch (obj["type"]) {
      case "message_issue": return MentionUserWorkspaceIssue.parseFromObject(obj);
      case "message_channel": return MentionUserWorkspaceMessage.parseFromObject(obj);
      case "message_conversation": return MentionUserConversation.parseFromObject(obj);
      default: return MentionUserDefault();
    }
  }

  void update(Map obj);
  String get id => this._id;

  set id(value) => this._id = value;

  String get personMentioned => this._personMentioned;

  set personMentioned(value) => this._personMentioned = value;

  String get creatorId => this._creatorId;

  set creatorId(value) => this._creatorId = value;

  String get type => this._type;

  set type(value) => this._type = value;

  bool get seen => this._seen;

  set seen(bool? value) => this._seen = value ?? _seen;

  bool get isSameTop => this._isSameTop;

  set isSameTop(value) => this._isSameTop = value;

  String get insertedAt => this._insertedAt;

  set insertedAt(value) => this._insertedAt = value;

  String get creatorName => this._creatorName;

  set creatorName(value) => this._creatorName = value;

  String get creatorUrl => this._creatorUrl;

  set creatorUrl(value) => this._creatorUrl = value;

}

class MentionUserDefault extends MentionUser{
  @override
  Map toJson() {
    return {};
  }

  void update(Map obj) {
  }
}
class MentionUserConversation implements MentionUser {


  @override
  String _creatorId = "";

  @override
  String _creatorName = "";

  @override
  String _creatorUrl = "";

  @override
  String _id = "";

  @override
  String _insertedAt = "";

  @override
  bool _isSameTop = false;

  @override
  String _personMentioned = "";

  @override
  bool _seen = false;

  @override
  String _type = "";

  String _conversationId = "";
  String _messageId = "";
  late MessageConv _message;

  MessageConv get message => this._message;

  set message(value) => this._message = value;

  String get id => this._id;

  set id(value) => this._id = value;

  String get personMentioned => this._personMentioned;

  set personMentioned(value) => this._personMentioned = value;

  String get creatorId => this._creatorId;

  set creatorId(value) => this._creatorId = value;

  String get conversationId => this._conversationId;

  set conversationId(value) => this._conversationId = value;

  String get messageId => this._messageId;

  set messageId(value) => this._messageId = value;

  String get type => this._type;

  set type(value) => this._type = value;

  bool get seen => this._seen;

  set seen(bool? value) => this._seen = value ?? _seen;

  bool get isSameTop => this._isSameTop;

  set isSameTop(value) => this._isSameTop = value;

  String get insertedAt => this._insertedAt;

  set insertedAt(value) => this._insertedAt = value;

  String get creatorName => this._creatorName;

  set creatorName(value) => this._creatorName = value;

  String get creatorUrl => this._creatorUrl;

  set creatorUrl(value) => this._creatorUrl = value;

  MentionUserConversation(
      id,
      personMentioned,
      creatorId,
      message,
      conversationId,
      messageId,
      type,
      seen,
      insertedAt,
      creatorName,
      creatorUrl,
      isSameTop) {
    this._id = id;
    this._personMentioned = personMentioned;
    this._creatorId = creatorId;
    this._message = message;
    this._conversationId = conversationId;
    this._messageId = messageId;
    this._type = type;
    this._seen = seen;
    this._insertedAt = insertedAt;
    this._creatorName = creatorName;
    this._creatorUrl = creatorUrl;
    this._isSameTop = isSameTop;
  }

  static MentionUserConversation parseFromObject(Map obj) {

    
    return MentionUserConversation(
        "${obj["id"] ?? ""}",
        obj["person_mentioned"] ?? "",
        obj["creator_id"] ?? "",
        MessageConv.parseFromJson(obj["data"]),
        obj["conversation_id"] ?? "",
        obj["message_id"] ?? "",
        obj["type"] ?? "message_channel",
        obj["seen"] ?? false,
        obj["inserted_at"] ?? "",
        obj["creator_name"] ?? "",
        obj["creator_url"] ?? "",
        obj["is_same_top"] ?? false);
  }

  Map toJson() {
    return {
      "id": this.id,
      "person_mentioned": this.personMentioned,
      "creator_id": this.creatorId,
      "message": this.message.toJson(),
      "conversation_id": this.conversationId,
      "message_id": this.messageId,
      "type": this.type,
      "seen": this.seen,
      "insert_at": this.insertedAt,
      "creator_url": this.creatorUrl,
      "creator_name": this.creatorName,
      "is_same_top": this.isSameTop
    };
  }

  void update(Map obj) {
    // Map dataSource = {...(this.toJson()), ...obj};
    // this._id = dataSource["id"];
    // this._personMentioned = dataSource["person_mentioned"];
    // this._creatorId = dataSource["creator_id"];
    // this._data = dataSource["data"];
    // this._conversationId = dataSource["conversation_id"];
    // this._messageId = dataSource["message_id"];
    // this._workspaceId = dataSource["workspace_id"];
    // this._channelId = dataSource["channel_id"];
    // this._issueId = dataSource["issue_id"];
    // this._type = dataSource["type"];
    // this._seen = dataSource["seen"];
    // this._insertedAt = dataSource["insert_at"];
    // this._creatorName = dataSource["creator_name"];
    // this._creatorUrl = dataSource["creator_url"];
  }
}



class MentionUserWorkspaceMessage implements MentionUser {
  @override
  String _creatorId = "";

  @override
  String _creatorName ="";

  @override
  String _creatorUrl = "";

  @override
  String _id = "";

  @override
  String _insertedAt = "";

  @override
  bool _isSameTop = false;

  @override
  String _personMentioned = "";

  @override
  bool _seen = false;

  @override
  String _type = "";

  late MessageChannel _message;
  String _messageId = "";
  int _workspaceId = 0;
  int _channelId = 0;


  MessageChannel get message => this._message;

  set message(value) => this._message = value;

  String get id => this._id;

  set id(value) => this._id = value;

  String get personMentioned => this._personMentioned;

  set personMentioned(value) => this._personMentioned = value;

  String get creatorId => this._creatorId;

  set creatorId(value) => this._creatorId = value;

  String get messageId => this._messageId;

  set messageId(value) => this._messageId = value;

  String get type => this._type;

  set type(value) => this._type = value;

  bool get seen => this._seen;

  set seen(bool? value) => this._seen = value ?? _seen;

  bool get isSameTop => this._isSameTop;

  set isSameTop(value) => this._isSameTop = value;

  String get insertedAt => this._insertedAt;

  set insertedAt(value) => this._insertedAt = value;

  String get creatorName => this._creatorName;

  set creatorName(value) => this._creatorName = value;

  String get creatorUrl => this._creatorUrl;

  set creatorUrl(value) => this._creatorUrl = value;

  int get workspaceId => this._workspaceId;

  set workspaceId(value) => this._workspaceId = value;

  int get channelId => this._channelId;

  set channelId(int? value) => this._channelId = value ?? _channelId;

  MentionUserWorkspaceMessage(
      id,
      personMentioned,
      creatorId,
      data,

      messageId,
      workspaceId,
      channelId,

      type,
      seen,
      insertedAt,
      creatorName,
      creatorUrl,
      isSameTop) {
    this._id = id;
    this._personMentioned = personMentioned;
    this._creatorId = creatorId;
    this._message = data;

    this._messageId = messageId;
    this._workspaceId = workspaceId;
    this._channelId = channelId;

    this._type = type;
    this._seen = seen;
    this._insertedAt = insertedAt;
    this._creatorName = creatorName;
    this._creatorUrl = creatorUrl;
    this._isSameTop = isSameTop;
  }


  static MentionUserWorkspaceMessage parseFromObject(Map obj) {

    
    return MentionUserWorkspaceMessage(
        "${obj["id"] ?? ""}",
        obj["person_mentioned"] ?? "",
        obj["creator_id"] ?? "",
        MessageChannel.parseFromJson(obj["data"] ?? {}),
        obj["message_id"] ?? "",
        obj["workspace_id"] ?? 0,
        obj["channel_id"] ?? 0,
        obj["type"] ?? "message_channel",
        obj["seen"] ?? false,
        obj["inserted_at"] ?? "",
        obj["creator_name"] ?? "",
        obj["creator_url"] ?? "",
        obj["is_same_top"] ?? false);
  }

  Map toJson() {
    return {
      "id": this.id,
      "person_mentioned": this.personMentioned,
      "creator_id": this.creatorId,
      "message": this.message,
      "message_id": this.messageId,
      "workspace_id": this.workspaceId,
      "channel_id": this.channelId,
      "type": this.type,
      "seen": this.seen,
      "insert_at": this.insertedAt,
      "creator_url": this.creatorUrl,
      "creator_name": this.creatorName,
      "is_same_top": this.isSameTop
    };

  }

  void update(Map obj){

  }

}


class MentionUserWorkspaceIssue implements MentionUser{
  @override
  String _creatorId = "";

  @override
  String _creatorName ="";

  @override
  String _creatorUrl = "";

  @override
  String _id = "";

  @override
  String _insertedAt = "";

  @override
  bool _isSameTop = false;

  @override
  String _personMentioned = "";

  @override
  bool _seen = false;

  @override
  String _type = "";

  late Issue _issue;
  int _issueId = 0;
  int _workspaceId = 0;
  int _channelId = 0;


  Issue get issue => this._issue;

  set issue(value) => this._issue = value;

  int get issueId => this._issueId;

  set issueId(value) => this._issueId = value;

  String get id => this._id;

  set id(value) => this._id = value;

  String get personMentioned => this._personMentioned;

  set personMentioned(value) => this._personMentioned = value;

  String get creatorId => this._creatorId;

  set creatorId(value) => this._creatorId = value;

  String get type => this._type;

  set type(value) => this._type = value;

  bool get seen => this._seen;

  set seen(bool? value) => this._seen = value ?? _seen;

  bool get isSameTop => this._isSameTop;

  set isSameTop(value) => this._isSameTop = value;

  String get insertedAt => this._insertedAt;

  set insertedAt(value) => this._insertedAt = value;

  String get creatorName => this._creatorName;

  set creatorName(value) => this._creatorName = value;

  String get creatorUrl => this._creatorUrl;

  set creatorUrl(value) => this._creatorUrl = value;

  int get workspaceId => this._workspaceId;

  set workspaceId(value) => this._workspaceId = value;

  int get channelId => this._channelId;

  set channelId(int? value) => this._channelId = value ?? _channelId;



  @override
  Map toJson() {
    return {};
  }

  MentionUserWorkspaceIssue(
      id,
      personMentioned,
      creatorId,
      data,
      issueId,
      workspaceId,
      channelId,
      type,
      seen,
      insertedAt,
      creatorName,
      creatorUrl,
      isSameTop) {
    this._id = id;
    this._personMentioned = personMentioned;
    this._creatorId = creatorId;
    this._issue = data;
    this._issueId = issueId;
    this._workspaceId = workspaceId;
    this._channelId = channelId;
    this._type = type;
    this._seen = seen;
    this._insertedAt = insertedAt;
    this._creatorName = creatorName;
    this._creatorUrl = creatorUrl;
    this._isSameTop = isSameTop;
  }

  
  static MentionUserWorkspaceIssue parseFromObject(Map obj) {
    return MentionUserWorkspaceIssue(
      "${obj["id"] ?? ""}",
      obj["person_mentioned"] ?? "",
      obj["creator_id"] ?? "",
      Issue.parseFromJson({
        ...obj["data"] ?? {},
        ...((obj["data"] ?? {})["issue"] ?? {}),
        "id": obj["issue_id"],
      }),
      obj["issue_id"] ?? 0,
      obj["workspace_id"] ?? 0,
      obj["channel_id"] ?? 0,
      obj["type"] ?? "message_channel",
      obj["seen"] ?? false,
      obj["inserted_at"] ?? "",
      obj["creator_name"] ?? "",
      obj["creator_url"] ?? "",
      obj["is_same_top"] ?? false
    );
  }

  void update(Map obj){
    this.issue.description = obj["description"];
  }
  
}
