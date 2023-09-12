import 'package:flutter/material.dart';

class Issue {
  int _id = 0;
  String _title = "";
  String _description = "";
  String _insertedAt = "";
  int _uniqueId = 0;
  int _workspaceId = 0;
  int _channelId = 0;
  String _lastEditId = "";
  String _ownerId = "";
  bool _isClosed= false;
  int _commentsCount = 0;

  int get commentsCount => this._commentsCount;

  set commentsCount( value) => this._commentsCount = value;

  bool get isClosed => this._isClosed;

  set isClosed( value) => this._isClosed = value;

  String get ownerId => this._ownerId;

  set ownerId( ownerId) => this._ownerId = ownerId;

  int get id => this._id;

  set id( value) => this._id = value;

  String get title => this._title;

  set title( value) => this._title = value;

  String get description => this._description;

  set description( value) => this._description = value;

  String get insertedAt => this._insertedAt;

  set insertedAt( value) => this._insertedAt = value;

  int get uniqueId => this._uniqueId;

  set uniqueId( value) => this._uniqueId = value;

  int get workspaceId => this._workspaceId;

  set workspaceId( value) => this._workspaceId = value;

  int get channelId => this._channelId;

  set channelId( value) => this._channelId = value;

  String get lastEditId => this._lastEditId;

  set lastEditId( value) => this._lastEditId = value;

 Issue(int id, String ownerId, String title, String description, String insertedAt, int uniqueId, int workspaceId, int channelId, String lastEditId, bool isClosed, int commentsCount){
   this._id  = id;
   this._title = title;
   this._description = description;
   this._insertedAt = insertedAt;
   this._uniqueId = uniqueId;
   this._workspaceId = workspaceId;
   this._channelId = channelId;
   this._lastEditId= lastEditId;
   this._ownerId = ownerId;
   this._isClosed = isClosed;
   this._commentsCount = commentsCount;
 }

  static Issue parseFromJson(Map o){
    Map obj = {
      ...o,
      ...((o["issue"] ?? {}) as Map)
    };
    return Issue(
      obj["id"] ?? 0,
      obj["author_id"] ?? "",
      obj["title"] ?? "", 
      obj["description"] ?? "", 
      obj["inserted_at"] ?? "", 
      obj["unique_id"] ?? 0,
      int.parse("${obj["workspace_id"] ?? 0}"),
      int.parse("${obj["channel_id"] ?? 0}"),
      obj["last_edit_id"] ?? "",
      obj["is_closed"] ?? false,
      obj["count_child"] ?? 0,
    );
  
  }

  Widget render(BuildContext context){
    return Container(
    );
  }

  Map toJson(){
    return {
      "id": this._id,
      "title": this._title,
      "description": this._description,
      "workspace_id": this._workspaceId,
      "channel_id": this._channelId,
      "unique_id": this._uniqueId,
      "is_closed": this._isClosed,
      "count_child": this._commentsCount,
      "comments_count": this._commentsCount
    };
  }
}


class CommentIssue{
  int _id  = 0;
  String _authorId = "";
  String _comment = "";
  int _channelId = 0;
  int _workspaceId  = 0;
  String _insertedAt = "";
  String _updatedAt = "";
  int _issueId  = 0;

  String get insertedAt => this._insertedAt;

  set insertedAt( value) => this._insertedAt = value;

  int get workspaceId => this._workspaceId;

  set workspaceId( value) => this._workspaceId = value;

  int get channelId => this._channelId;

  set channelId( value) => this._id = value;

  int get id => this._id;

  set id( value) => this._id = value;

  String get authorId => this._authorId;

  set authorId( value) => this._authorId = value;

  String get comment => this._comment;

  set comment( value) => this._comment = value;

  String get updatedAt => this._updatedAt;

  set updatedAt( value) => this._updatedAt = value;

  int get issueId => this._issueId;

  set issueId( value) => this._issueId = value;

 CommentIssue(int id, String authorId, String comment, int channelId, int workspaceId, int issueId, String insertedAt, String updatedAt){
   this._authorId = authorId;
   this._id = id;
   this._channelId = channelId;
   this._workspaceId  = workspaceId;
   this._issueId = issueId;
   this._insertedAt = insertedAt;
   this._updatedAt= updatedAt;
   this._comment = comment;

 }

 static CommentIssue parseFromJson(Map obj){
   return CommentIssue(
     int.parse("${obj["id"] ?? 0}"),
     obj["author_id"] ?? "",
     obj["comment"] ?? "",
     obj["channel_id"] ?? 0,
     obj["workspace_id"] ?? 0,
     obj["issue_id"] ?? 0,
     obj["inserted_at"] ?? "",
     obj["updated_at"] ?? ""
   );
 }

  void update(Map? obj){
    if (obj == null) return;
    // chi ho tro update comment
    this.comment =  obj["comment"] ?? this.comment;
  }
}