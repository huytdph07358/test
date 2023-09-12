import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/issue.dart';
import 'package:workcake/models/message.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/models/thread_user.dart';

class ThreadUserWorkspace {
  bool fetching = false;
  int workspaceId  = 0;
  int page = 0;
  List<ThreadUser> data = [];

  ThreadUserWorkspace(bool fetching, int workspaceId){
    this.fetching = fetching;
    this.workspaceId = workspaceId;
  }
}

class ThreadUserProvider with ChangeNotifier{
  List<ThreadUser> _data = [];
  bool _fetching = false;
  int _countUnreadThread = 0;



  // workspace
  List<ThreadUserWorkspace> _threadWorkspaces = [];
  List<ThreadUserWorkspace> get threadsWorkspace => _threadWorkspaces;

  List<ThreadUser> get data => _data;
  bool get fetching => _fetching;
  int get countUnreadThread => _countUnreadThread;

  // hien tai /users/threads chi moi lay thread cua DMs
  void getThread(String token, BuildContext context, {bool isUpdate = false, String? lastId })async{
    return;
  }

  Future<Map> processThreadUserConversation(Map obj, BuildContext context) async {
    try {
      var currentDM = Provider.of<DirectMessage>(context, listen: false).getCurrentDataDMMessage(obj["conversation_id"]);

      Future<Map> decryptMessage(String conversationId, Map objMessage) async {
        var dataOnIsar; var dataDe = {};
        try {
          dataDe = currentDM!.conversationKey!.decryptMessage(objMessage);
        } catch (e) {
        }   

        try {
          DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(obj["conversation_id"]);
          if (dm == null) return {};
          dataOnIsar = await MessageConversationServices.getListMessageById(dm, objMessage["id"], obj["conversation_id"]);
        } catch (e) {
        } 
        return {
          ...objMessage,
          ...(dataOnIsar != null ? dataOnIsar : {}),
          ...(Utils.checkedTypeEmpty(dataDe["success"] ) ? dataDe["message"] : {}),
        };
      }

      return {
        ...obj,
        "parent": {
          ...(obj["parent"] as Map),
          ...(await decryptMessage(obj["conversation_id"], obj["parent"]))
        },
        "childrens": await Future.wait(
          (obj["childrens"] as List).map(
            (child) async {
              return await decryptMessage(obj["conversation_id"], child);
            }
          )
        )
      };      
    } catch (e) {
      return {};
    } 
  }

  String getLastId(){
    try {
      return _data.last.id;      
  } catch (e) {
      return "";
    }
  }

  void insertOrUpdateThreadUser(data, BuildContext context) async {
    var countThread = data["count_unread_thread"];
    var dataThread  = await processThreadUserConversation(data["data_thread"], context);
    var indexThread = _data.indexWhere((element) => element.id == dataThread["id"]);
    if (indexThread == -1){
      _data = [
        ThreadUser.parseFromJson(dataThread)
      ] + _data;
    } else {
      _data.removeAt(indexThread);
      _data = [
        ThreadUser.parseFromJson(dataThread)
      ] + _data;
    }
    _countUnreadThread = countThread;

    notifyListeners();

  }

  List<ThreadUser> uniq(List<ThreadUser> dataSource){
    Map index = {};
    List<ThreadUser> results  = [];
    for(int i = 0; i< dataSource.length; i++){
      if (index[dataSource[i].id] == null){
        index[dataSource[i].id] = results.length;
        results += [dataSource[i]];
      } else {
        results[index[dataSource[i].id]] = dataSource[i];
      }
    }
    return results;
  }

  ThreadUserWorkspace getThreadUserWorkspaceData(int workspaceId){
    try {
      int index = _threadWorkspaces.indexWhere((element) => element.workspaceId == workspaceId);
      return _threadWorkspaces[index];
    } catch (e) {
      ThreadUserWorkspace dataInit =  ThreadUserWorkspace(false, workspaceId);
      _threadWorkspaces.add(dataInit);
      return dataInit;
    }
  }

  void getThreadWorkspace(int workspaceId, String token,  {bool isReset = false}) async {
    ThreadUserWorkspace thread = getThreadUserWorkspaceData(workspaceId);
    if (thread.fetching) return;
    thread.fetching = true;
    try {
      var url = "${Utils.apiUrl}workspaces/$workspaceId/get_threads_workspace_v3?token=$token&page=${isReset ? 1 : (thread.page+1)}";
      var res = await Dio().get(url);  
      var data = res.data;
      List<ThreadUser> dataAfterProcess = (data["threads"] as List).map((e)  {
        return ThreadUser.parseFromJson(
          {...e, "type": e["issue_id"] == null ? "thread_message_workspace": "thread_issue_workspace"}
        );
      }).toList();

      thread.data = uniq(isReset ? dataAfterProcess : (thread.data + dataAfterProcess));
      thread.page = isReset ? 1 : ( dataAfterProcess.length == 0 ? thread.page : (thread.page + 1));
      thread.fetching = false;      
    } catch (e) {
      thread.fetching = false;     
    }
   
    notifyListeners();
  }

  updateThreadUnread(workspaceId, channelId, message, token, {isNotify = false}) async {
    final url = "${Utils.apiUrl}workspaces/$workspaceId/update_unread_thread?token=$token";

    try {
      if (workspaceId != null && channelId != null) {
        var response = await Dio().post(url, data: {"message_id": message["issue_id"] != null ? null : message["id"], "channel_id": channelId, "issue_id": message["issue_id"]});
        var dataRes = response.data;
        if (dataRes["success"]) {}

        final index = _threadWorkspaces.indexWhere((e) => "${e.workspaceId}" == "$workspaceId");
        if (index != -1) {
          final indexThread = _threadWorkspaces[index].data.indexWhere((e) => e.id.toString() == message["id"].toString());

          if (indexThread != -1) {
            if (_threadWorkspaces[index].data[indexThread].unread || _threadWorkspaces[index].data[indexThread].mentionCount > 0) {
              _threadWorkspaces[index].data[indexThread].mentionCount = 0;
              _threadWorkspaces[index].data[indexThread].unread = false;
              //Chỗ này cần mới notify tránh bị markneedbuild()
              if (isNotify) notifyListeners();
            

              return [];
            }
          }
        }
      } 
    } catch (e, t) {
      print("updateThreadUnread ${e.toString()}, $t");
    }
  }
  
  void updateWorkspaceThread(String token, Map? data, String type, BuildContext context){
    if (data == null) return;
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final workspaceId = data["workspace_id"];
    var indexThreadWorkspace = _threadWorkspaces.indexWhere((element) => "${element.workspaceId}" == "$workspaceId");
    if (indexThreadWorkspace == -1) {
       getThreadWorkspace(workspaceId, token, isReset: true);
    } else {
      if (type  == "newMessage"){
        try {
          final newMessage = data["message"];
          List<ThreadUser> threadsUser  = _threadWorkspaces[indexThreadWorkspace].data;
          int indexThread  = threadsUser.indexWhere((element) => element.id == data["channel_thread_id"]);
          if (indexThread == -1) return getThreadWorkspace(workspaceId, token, isReset: true);
          WorkspaceMessageThread thread  = (threadsUser[indexThread] as WorkspaceMessageThread);
          final notify = thread.notify;
          final indexMention = (data["users_in_mention"] ?? []).indexWhere((e) => e == userId);
          final unread = thread.unread;
          var mentionCount = thread.mentionCount;
          thread.unread = (notify) ? newMessage["user_id"] != userId : indexMention != -1 ? true : unread ? newMessage["user_id"] != userId : false;
          thread.mentionCount = indexMention != -1 ? mentionCount +=1 : newMessage["user_id"] == userId ? 0 : mentionCount;
          thread.childrens.add(MessageChannel.parseFromJson(newMessage));
          thread.count += 1;

          _threadWorkspaces[indexThreadWorkspace].data.removeAt(indexThread);
          _threadWorkspaces[indexThreadWorkspace].data.insert(0, thread);

          notifyListeners(); 
        } catch (e) {
        }
      }  else if (type == "delete_message") {
        try {
          if (indexThreadWorkspace != -1) {
            List<ThreadUser> threadsUser  = _threadWorkspaces[indexThreadWorkspace].data;
            if (data["channel_thread_id"] != null) {
              int indexThread  = threadsUser.indexWhere((element) => element.id == data["channel_thread_id"]);
              WorkspaceMessageThread thread = (threadsUser[indexThread] as WorkspaceMessageThread);
              if (indexThread != -1) {
                final indexMessage = thread.childrens.indexWhere((e) => e.id == data["message_id"]);
                if (indexMessage != -1) {
                  thread.childrens.removeAt(indexMessage);
                  if ( thread.childrens.length == 0) {
                    threadsUser.removeAt(indexThread);
                  }
                  notifyListeners();
                }
              }
            } else {
              final indexThread = threadsUser.indexWhere((e) => e.id ==  data["message_id"]);
              if (indexThread != -1) {
                threadsUser.removeAt(indexThread);
                notifyListeners();
              }
            }
          }        
        } catch (e, t) {
          print("updateWorkspaceThread error $e $t");
        }
      } else if(type == "update_unread_threads") {
          final index = _threadWorkspaces.indexWhere((e) => "${e.workspaceId}" == workspaceId.toString());
          if(index != -1) {
            final threadsWorkspace = _threadWorkspaces[index].data;
            if (data["message_id"] == null && data["issue_id"] == null) {
              for (var i = 0; i < threadsWorkspace.length; i++) {
                threadsWorkspace[i].unread = false;
                threadsWorkspace[i].mentionCount = 0;
              }
            } else {
              final indexThread = _threadWorkspaces[index].data.indexWhere((e) => e.id == data["message_id"] || e.id == data["issue_id"]);
              if (indexThread == -1) return;
              threadsWorkspace[indexThread].unread = false;
              threadsWorkspace[indexThread].mentionCount = 0;
            }
            notifyListeners();
          }
      } else {
        // update reaction message; 
      }
    }
  }

  updateIssueThread(context, token, workspaceId, channelId, issueId, type, payload, userCommentId) async {
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final index = _threadWorkspaces.indexWhere((e) => "${e.workspaceId}" == "$workspaceId");
    if (index == -1) {
      getThreadWorkspace(workspaceId, token, isReset: true);
    } else {
      if (type == "add_comment") {
        final newComment = payload["data"]["comment"];
        if (index != -1) {
          final indexThread = _threadWorkspaces[index].data.indexWhere((e) => "${e.id}" == "$issueId");
          final indexMention = (payload["data"]["users_in_mention"] ?? []).indexWhere((e) => e == userId);

          if (indexThread != -1) {
            WorkspaceIssueThread thread  =  _threadWorkspaces[index].data[indexThread] as WorkspaceIssueThread;
            var mentionCount = thread.mentionCount;
            thread.mentionCount = indexMention != -1 ? mentionCount+=1 : newComment["author_id"] == userId ? 0 : mentionCount;
            thread.unread = newComment["author_id"] != userId;
            thread.comments.add(CommentIssue.parseFromJson(newComment));
            thread.count +=1; 

            //update thread len dau
            _threadWorkspaces[index].data.removeAt(indexThread);
            _threadWorkspaces[index].data.insert(0, thread);

            notifyListeners();
          } else {
            getThreadWorkspace(workspaceId, token, isReset: true);
          }
        } else {
          getThreadWorkspace(workspaceId, token, isReset: true);
        }
      } else if (type == "delete_comment") {
        if (index != -1) {
          final indexThread = _threadWorkspaces[index].data.indexWhere((e) => "${e.id}" == "$issueId");
          if (indexThread != -1) {
            WorkspaceIssueThread thread  =  _threadWorkspaces[index].data[indexThread] as WorkspaceIssueThread;
            final indexComment = thread.comments.indexWhere((e) => (e.id == payload["data"]));
            if (indexComment != -1) {
              thread.comments.removeAt(indexComment);
            } else {
              thread.count -=1; 
            }
            notifyListeners();
          }
        }
      } else if (type == "update_comment") {
        if (index != -1) {
          final indexThread = _threadWorkspaces[index].data.indexWhere((e) => "${e.id}" == "$issueId");
          if (indexThread != -1) {
            WorkspaceIssueThread thread = _threadWorkspaces[index].data[indexThread] as WorkspaceIssueThread;
            final indexComment = thread.comments.indexWhere((e) => ("${e.id}" == "${payload["data"]["id"]}"));
            if (indexComment != -1) {
              thread.comments[indexComment].update(payload["data"]);
              notifyListeners();
            } 
          }
        }
      }
    }
  }
  
  updateWorkspaceThreadMessage(data){
    try {
      final index = _threadWorkspaces.indexWhere((e) => e.workspaceId.toString() == data["workspace_id"].toString());
      if (index == -1) return;
      if (data["source"]["channel_thread_id"] != null) {
        final indexThread = _threadWorkspaces[index].data.indexWhere((e) => e.id == (data["source"]["channel_thread_id"]));
        if (indexThread == -1) return;
        WorkspaceMessageThread thread = _threadWorkspaces[index].data[indexThread] as WorkspaceMessageThread;
        final indexMessage = thread.childrens.indexWhere((e) => e.id == data["id"]);
        if (indexMessage == -1) return;
        thread.childrens[indexMessage].message = data["message"];
        thread.childrens[indexMessage].attachments = data["attachments"];
        notifyListeners();
      } else {
        final indexThread = _threadWorkspaces[index].data.indexWhere((e) => e.id == (data["id"]));
        if (indexThread == -1) return;
        WorkspaceMessageThread thread = _threadWorkspaces[index].data[indexThread] as WorkspaceMessageThread;
        thread.parentMessage.message = data["message"];
        thread.parentMessage.attachments = data["attachments"];
        notifyListeners();
      }      
    } catch (e) {
      print("updateWorkspaceThreadMessage: $e");
    } 
  }
}