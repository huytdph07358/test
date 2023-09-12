import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/http_exception.dart';

import 'package:workcake/common/utils.dart';
import 'package:workcake/components/workspace/snappy/extension.dart';
import 'package:workcake/service_locator.dart';
import 'package:workcake/services/sharedprefsutil.dart';

import '../components/custom_dialog_new.dart';
import 'models.dart';

class WorkspaceItem {
  final id;
  final name;
  final ownerId;
  final settings;

  WorkspaceItem({this.id, this.name, this.ownerId, this.settings});
}

class Workspaces with ChangeNotifier {
  List members = [];
  List _data = [];
  Map _currentWorkspace = {};
  int _selectedTab = 100;
  bool _loading = false;
  Map _currentMember = {};
  String _message = "";
  bool _changeToMessage = true;
  List _emojis = [];
  List _mentions = [];
  bool _selectMentionWorkspace = false;
  bool _isOnThreads = false;
  List _listWorkspaceMembers = [];
  List _preloadIssues = [];
  int page = 0;

  List get mentions => _mentions;
  List get emojis => _emojis;
  List get data => _data;
  Map get currentWorkspace => _currentWorkspace;
  bool get loading => _loading;
  Map get currentMember => _currentMember;
  String get message => _message;
  bool get changeToMessage => _changeToMessage;
  bool get selectMentionWorkspace => _selectMentionWorkspace;
  bool get isOnThreads => _isOnThreads;
  List get preloadIssues => _preloadIssues;
  List get listWorkspaceMembers => _listWorkspaceMembers;

  Workspaces() {
    getTab().then((value) {
      _selectedTab = value;
      notifyListeners();
    });
  }

  Future<dynamic> setNullMentions(value) async {
    _selectMentionWorkspace = value;
    // if (value) _isUnread = false;
    notifyListeners();
  }

  int get tab => _selectedTab;
  set tab(int value) => setTab(value);

  void setTab(value) {
    _selectedTab = value;
    sl.get<SharedPrefsUtil>().setTab(value);
    notifyListeners();
  }

  Future<dynamic> changeToMessageView(value) async {
    _changeToMessage = value;
    notifyListeners();
  }

  Future<int> getTab() async {
    final tab = sl.get<SharedPrefsUtil>().getTab();
    return tab;
  }

  setData(data) {_data = data;}
  
  Future<dynamic> deleteChannelMember(String token, workspaceId, channelId, list, {String type = ""}) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/delete_member?token=$token');

    try {
      final response = await http.post(url, headers: Utils.headers, body: json.encode({"list": list, "type": type}));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        members = members.where((element) => element["id"] != list[0]).toList();
      } else {
        throw HttpException(responseData['message']);
      }

      notifyListeners();
    } catch (e) {
      print(e);
      // sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> getListWorkspace(context, String token) async {
    final url = Utils.apiUrl + 'workspaces?token=$token';
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    var snapshot = await Hive.openBox("snapshotData_${currentUser["id"]}");

     
    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);
      if (responseData["success"] == true) {
        _data = responseData["workspaces"];
        // 
        List channelIds = responseData["channels"].map((channel) => channel["id"]).toList();
        await Work.platform.invokeMethod("save_channel_ids", "__" + channelIds.join("_") + "__");
        //  
        if(_currentWorkspace.isEmpty){
          _currentWorkspace = _data[0];
        }
        if(responseData["workspaces"].length  == 0){
          return showDialog(
            context: context,
            builder: (BuildContext context){
              return CustomDialog(
                action: "Join or create a workspace",
                title: "Join or create a workspace",
              );
            }
          );
        }
        Provider.of<Channels>(context, listen: false).setDataChannels(responseData["channels"]);

        snapshot.put("workspaces", _data);
        snapshot.put("channels", responseData["channels"]);

        var data = _data.map((e){
          e["isShowChannel"] = true;
          e["isShowPinned"] = false;
          return e;
        }).toList();
        _listWorkspaceMembers = responseData["list_workspace_members"];
        var box = await Hive.openBox("stateShowPinned:${currentUser["id"]}");
        var _boxData = box.get("data");
        if (_boxData == null) {
          box.put("data", data);
        }
        _data = data;
        _mentions = data.map((e) => {
          "fetching": false,
          "workspace_id": e["id"],
          "data": [],
          "disableLoadMore": false,
          "unreadMention": e["un_read_mention"]
        }).toList();
        // neu co currentWorkspace reload laij metiooj
        getMentions(token, _currentWorkspace["id"], false);
      } else {
        throw HttpException(responseData['message']);
      }

      notifyListeners();
    } catch (e, t) {
      print("getListWorkspace: $e, $t");
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  onSelectWorkspace(context, workspaceId) {
    final auth = Provider.of<Auth>(context, listen: false);
    setTab(workspaceId);
    selectWorkspace(auth.token, workspaceId, context);
    getInfoWorkspace(auth.token, workspaceId, context);
    getMentions(auth.token, workspaceId, false);
    Provider.of<DirectMessage>(context, listen: false).openDirectSetting(false);
    final selectedMentionWorkspace = selectMentionWorkspace;
    if (selectedMentionWorkspace) {
      auth.channel.push(event: "read_workspace_mentions", payload: {"workspace_id": workspaceId});
    }
  }

  getPreloadIssue(token) async {
    final url = "${Utils.apiUrl}workspaces/preload_issue?token=$token";

    try {
      final response = await Utils.getHttp(url);

      if (response["success"] == true) {
        _preloadIssues = response["issues"];
      } else {
        throw HttpException(response['message']);
      }
    } catch(e){
      print(e);
    }
  }

  updatePreloadIssue(context, payload) {
    final indexWs = _data.indexWhere((e) => e["id"] == payload["workspace_id"]);
    if (indexWs == -1) return;
    final dataChannel = Provider.of<Channels>(context, listen: false).data;
    final indexChannel = dataChannel.indexWhere((e) => e["id"] == payload["channel_id"]);
    if (indexChannel == -1) return;
    final channel = dataChannel[indexChannel];
    payload["channel_name"] = channel["name"];
    _preloadIssues.insert(0, payload);
  }

  Future<dynamic> selectWorkspace(String token, workspaceId, context) async {
    var index = _data.indexWhere((element) => element["id"] == workspaceId);
    if (index < 0){

    } else {
      _currentWorkspace = _data[index];
    }

    ///Lần đầu vào ws lấy ca của user tong ngày hôm đó, sau đấy bắt đầu autocheckin
    _getStatusAttendanceToday(context, workspaceId).then((shifts) {
      Future.delayed(Duration(seconds: 5), () {
        _autoCheckIn(workspaceId, shifts);
      });
    });

    notifyListeners();
  }

  static Map<int, List> listshiftToday = {};

  Future _getStatusAttendanceToday(BuildContext context, int workspaceId, ) async {
    if (listshiftToday[workspaceId] != null) {
      return listshiftToday[workspaceId];
    } else {
      final token = Provider.of<Auth>(context, listen: false).token;
      final url = Utils.apiUrl + 'workspaces/$workspaceId/get_status_attendance_today_v2?token=$token';
      try {
        final response = await Dio().get(url);
        var dataRes = response.data;
        listshiftToday[workspaceId] = dataRes["listshift_today"];
        return dataRes["listshift_today"];
      } catch (e) {
        print(e);
      }
    }
  }

  int timeOfDayToInt(TimeOfDay time) => time.hour*60 + time.minute;
  int compareTimeOfDayToMinute(TimeOfDay time1, TimeOfDay time2) => timeOfDayToInt(time1) - timeOfDayToInt(time2);

  //Hàm autocheckin
  _autoCheckIn(workspaceId, shifts) async {
    try {
      for (var shift in shifts) {
        if (shift["start_time"] == null) return;
        TimeOfDay startTime = TimeOfDay(hour: int.parse(shift["start_time"].split(":")[0]),minute: int.parse(shift["start_time"].split(":")[1]));
        TimeOfDay now = TimeOfDay.fromDateTime(DateTime.now());
        int status = shift["status"];

        if (status == 0) {
          if (compareTimeOfDayToMinute(startTime, now) < 61 && compareTimeOfDayToMinute(startTime, now) > -61) {
            final token = Provider.of<Auth>(Utils.globalContext!, listen: false).token;
            final preCheckinResult = await sendPreCheckin(workspaceId, token);

            if (preCheckinResult["success"]) {
              await sendCheckin(workspaceId, shift["shift_id"], token).then((value) => print("response $value"));
            }
          }
        }
      }
    } catch (e, t) {
      print("$e $t");
    }
  }

  Future<dynamic> getInfoWorkspace(String token, workspaceId, context) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId?token=$token';
    try{
      final response = await Utils.getHttp(url);
    
      if (response["success"] == true) {
        members = response["member"];
        _currentMember = response["current_member"];
      } else {
        throw HttpException(response['message']);
      }
    } catch(e, t){
      print("getInfoWorkspace $e $t");
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  Future<dynamic> createWorkspace(context, String token, String name, String urlAvatar) async {
    final url = Utils.apiUrl + 'workspaces?token=$token';

    try {
      Response response = await Dio().post(
        url,
        // headers: Utils.headers,
        data: json.encode({'name': name, 'content_url': urlAvatar}),
      );

      final responseData = response.data;
      if (responseData["success"] == true) {
        _data = [responseData["workspace"]]  +  _data;
        var channel = responseData["channel"];
        channel["snippet"] = {};
        channel["user_count"] = 1;
        Provider.of<Channels>(context, listen: false).insertDataChannel(channel);

        final auth = Provider.of<Auth>(context, listen: false);
        final providerMessage = Provider.of<Messages>(context, listen: false);
        int index = _data.indexWhere((e) => e["id"] == responseData["workspace"]["id"]);
        if (index == -1) {
          insertDataWorkspace(data);
        }
        onSelectWorkspace(context, responseData["workspace"]["id"]);
        Provider.of<Channels>(context, listen: false).onSelectedChannel(responseData["workspace"]["id"], responseData["channel"]["id"], auth, providerMessage);
      } else {
        throw HttpException(responseData['message']);
      }
      notifyListeners();
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  insertDataWorkspace(workspace){
    final index = _data.indexWhere((e) => e["id"] == workspace["id"]);

    if (index == -1) {
      _data = _data + [workspace];
      _data.sort((a, b) {
        return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
      });
      notifyListeners();
    }
  }

  Future<dynamic> inviteToWorkspace(String token, workspaceId, text, type, userId) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/send_invitation?token=$token';
    try{
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({'id': userId, 'text': text, 'type': type}));
      final responseData = json.decode(response.body);

      _message = responseData['message'];
      if (type == 1) {
        var key = "$workspaceId";
        var box = Hive.box('invitationHistory');
        List invitationHistory = box.get(key) ?? [];
        final index = invitationHistory.indexWhere((e) => e['email'] == text);
        DateTime now = DateTime.now();

        if (index == -1) {
          invitationHistory.insert(0, {'email': text, 'date': now});
          if (invitationHistory.length > 10) invitationHistory.sublist(0, 9);
          box.put(key, invitationHistory);
        } else {
          invitationHistory[index] =  {'email': text, 'date': now};
          box.put(key, invitationHistory);
        }
      }
      return _message;
    }catch(e){
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  // ignore: missing_return
  Future setWorkspaceFromHive(data){
    _data = data;
    return data;
  }

  List getListUsers(workspaceId) {
    List dataUsers = _listWorkspaceMembers.where((ele) => ele['workspace_id'].toString() == workspaceId.toString()).toList();
    return dataUsers;
  }

  Future<dynamic> uploadImage(String token, workspaceId, file, type) async {
    final body = {
      "file": file,
      "content_type": type
    };

    final url = Utils.apiUrl + 'workspaces/$workspaceId/contents?token=$token';
    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(body));
      final responseData = json.decode(response.body);
      return responseData;
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> uploadAvatar(String token, workspaceId, file, type) async {
    final body = {
      "file": file,
      "content_type": type
    };

    final url = Utils.apiUrl + 'workspaces/$workspaceId/contents?token=$token';
    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(body));
      final responseData = json.decode(response.body);
      final workspace = new Map.from(currentWorkspace);
      workspace["avatar_url"] = responseData["content_url"];
      changeWorkspaceInfo(token, workspaceId, workspace);

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

  Future<dynamic> changeWorkspaceInfo(String token, workspaceId, body) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/change_info?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(body));
      final responseData = json.decode(response.body);

      print("res $responseData");

      if (responseData["success"] == true) {
        _currentWorkspace = body;
        final index = _data.indexWhere((e) => e["id"].toString() == workspaceId.toString());
        _data[index]["name"] = body["name"];
        _data[index]["avatar_url"] = body["avatar_url"];
        _data[index]["app_ids"] = body["app_ids"];
        _data[index]["timesheets_config"] = body["timesheets_config"];
      } else {
        throw HttpException(responseData['message']);
      }

      notifyListeners();
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> changeWorkspaceMemberInfo(String token, workspaceId, member) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/change_member_info?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(member));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        _currentMember = member;
      } else {
        throw HttpException(responseData['message']);
      }

      notifyListeners();
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> deleteWorkspace(String token, int workspaceId, context) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/delete_workspace?token=$token';
    // var box = await Hive.openBox("lastSelected");
   
    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers);
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        _selectedTab = 0;
        
        notifyListeners();
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> changeRoleWs(String token, String userId, int roleId) async {
    final url = Utils.apiUrl + 'workspaces/${_currentWorkspace['id']}/change_role_ws?token=$token';
    try {
      final body = {
        "user_id": userId,
        "role_id": roleId
      };
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(body));
      final responseData = json.decode(response.body);
      if (Utils.checkedTypeEmpty(responseData["success"])) {
        members = responseData["members"];
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

  updateWorkspace(data){
    // {avatar_url: null, name: 45, settings: {}, workspace_id: 18}
    var workspaceId  = data["workspace_id"];
    var lastIndex  = _data.lastIndexWhere((element) {return element["id"] == workspaceId; });
    if (lastIndex >= 0){
      _data[lastIndex]["name"] = data["name"];
    }
    if (_currentWorkspace["id"] == workspaceId ){
      _currentWorkspace["name"] = data["name"];
    }
    notifyListeners();
  }

  Future<String> joinWorkspaceByInvitation(token, workspaceId, text, type, userInvite, messageId) async{
    final url = Utils.apiUrl + 'workspaces/$workspaceId/join_workspace?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({'text': text, 'type': type, "user_invite" : userInvite, "message_id" : messageId}));
      final responseData = json.decode(response.body);
      _message = responseData['message'];
      if (responseData["success"] == false) {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
    return _message;
  }

  Future<String> declineInviteWorkspace(token, workspaceId, userInvite, messageId) async{
    final url = Utils.apiUrl + 'workspaces/$workspaceId/decline_invite?token=$token';
    try {
      final response = await http.post(Uri.parse(url),
        headers: Utils.headers,
        body: json.encode({'workspace_id' : workspaceId, 'user_invite' : userInvite, 'message_id' : messageId})
      );
      final responseData = json.decode(response.body);
      _message = responseData["message"];
      if(responseData == false){
        throw HttpException(responseData["message"]);
      }
    } catch (e) {
      print(e);
    }
    return _message;
  }

  joinWorkByCode(token, textCode, currentUser) async {
    final key = textCode.split("-");
    final workspaceId = key[1];
    var type;
    var user;

    if (currentUser["email"] != null || currentUser["email"] != "") {
      type = 1;
      user = currentUser["email"];
    } else {
      type = 2;
      user = currentUser["email"];
    }

    final url = Utils.apiUrl + 'workspaces/$workspaceId/join_workspace?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({'text': user, 'type': type}));
      final responseData = json.decode(response.body);

      if (responseData["success"] == false) {
        _message = responseData['message'];
        print("WSP Model: $_message");
        // throw HttpException(responseData['message']);
        return {"status": responseData["success"], "message": _message};
      } else {
        if (user != null) {
          _message = "Join Workspace Complete !";
          return responseData["success"];
        }
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  resetData() {
    members = [];
    _data = [];
    _selectedTab = 0;
    _loading = false;
    _currentMember = {};
    _message = "";
    _currentWorkspace = {};
  }

  Future<List> searchMember(String text, String token, workspaceId)async{
    try {
      final url = Utils.apiUrl + 'workspaces/$workspaceId/get_workspace_member?value=$text&token=$token';
      var response  = await Dio().get(url);
      var res  = response.data;
      if (res["success"]) return res["members"];
      return [];
    } catch (e) {
      sl.get<Auth>().showErrorDialog(e.toString());
      return [];
    }
  }

  onSaveStatePinned(context, id, isShowChannel, isShowPinned) async{
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    var box = await Hive.openBox("stateShowPinned:${currentUser["id"]}");
    var data = box.get("data");
    int index = data.indexWhere((e) => e["id"] == id);
    if (index > -1) {
      data[index]["isShowChannel"] = isShowChannel != null ? isShowChannel : data[index]["isShowChannel"];
      data[index]["isShowPinned"] = isShowPinned != null ? isShowPinned : data[index]["isShowPinned"];
    }
    box.put("data", data);
    // _data = data;
  }

  setDefaultEmojiData(List data){
    _emojis =  data;
    notifyListeners();
  }

  addEmojiWorkspace(Map data){
    var workspaceId  =  data["workspace_id"];
    var indexW =  _data.indexWhere((element) => "${element["id"]}" == "$workspaceId");
    if (indexW != -1){
      _data[indexW]["emojis"] = (Utils.checkedTypeEmpty(_data[indexW]["emojis"]) ? _data[indexW]["emojis"] : []) + [data];
      if (_currentWorkspace["id"] == workspaceId)
        _currentWorkspace["emojis"] = _data[indexW]["emojis"];
      notifyListeners();
    }
  }

  newWorkspaceMember(data) {
    final newUser = data["new_user"];
    List list = List.from(members);
    final index = list.indexWhere((e) => e["user_id"] == newUser["id"]);

    if (index == -1) {
      list.add(newUser);
      members = list;
      notifyListeners();
    }
  }
  updateWorkspaceMember(bool isProFile ,data) {
    final index = members.indexWhere((e) => e["id"] == data["user_id"]);
    if(index != -1) {
        if(isProFile) {
          members[index]["avatar_url"] = data["avatar_url"];
          members[index]["full_name"] = data["full_name"];
        } else {
          members[index]["role_id"] = data["role_id"];
          members[index]["nickname"] = data["nickname"];
        }
      }
    notifyListeners();
  }

  Future<dynamic> getMentions(String token, workspaceId, bool loadMore) async {
    var indexW = _mentions.indexWhere((element) => "${element["workspace_id"]}" == "$workspaceId");
    if (indexW == -1) return;
    Map dataMentionsWorkspace =  _mentions[indexW];
    if (
      dataMentionsWorkspace["fetching"] 
      || dataMentionsWorkspace["disableLoadMore"]
      || (dataMentionsWorkspace["data"].length > 0 && !loadMore)) return;
    try {
       _mentions[indexW]["fetching"] = true;
      int lengthCurrent = dataMentionsWorkspace["data"].length;
      var lastId = lengthCurrent == 0 ? null : dataMentionsWorkspace["data"][lengthCurrent -1];
      String url = "${Utils.apiUrl}workspaces/$workspaceId/mentions?token=$token";
      if (lastId != null) url += "&last_id=${lastId["id"]}";
      var response  = await Dio().get(url);
      if (response.data["success"]){
        _mentions[indexW]["data"] = dataMentionsWorkspace["data"] + response.data["data"];
        _mentions[indexW]["disableLoadMore"] = response.data["data"].length  == 0;
        _mentions[indexW]["number_unread_mentions"] = response.data["number_unread_mentions"] == null ? 0 : response.data["number_unread_mentions"];
      }
       _mentions[indexW]["fetching"] = false;
      notifyListeners();
    } catch (e) {
      print("__________ $e");
      dataMentionsWorkspace["fetching"] = false;
      notifyListeners();
    }
  }

  newMention(data, userId) {
    var indexW = _mentions.indexWhere((element) => "${element["workspace_id"]}" == "${data["workspace_id"]}");
    if (indexW == -1) return;
    _mentions[indexW]["data"] = [] + [data] + _mentions[indexW]["data"];
    if (userId != data["creator_id"]) {
      _mentions[indexW]["number_unread_mentions"] = (_mentions[indexW]["number_unread_mentions"] == null ? 0 : _mentions[indexW]["number_unread_mentions"]) + 1;
    }
    notifyListeners();
  }

  deleteMention(data){
    var indexW = _mentions.indexWhere((element) => "${element["workspace_id"]}" == "${data["workspace_id"]}");
    if (indexW == -1) return;
    _mentions[indexW]["data"] = _mentions[indexW]["data"].where((e) => e["id"] != data["mention_id"]).toList();
     _mentions[indexW]["number_unread_mentions"] = (_mentions[indexW]["number_unread_mentions"] == null ? 0 : _mentions[indexW]["number_unread_mentions"]) - 1; 
    notifyListeners();
  }

  setNumberUnreadMentions(workspaceId){
    var indexW = _mentions.indexWhere((element) => "${element["workspace_id"]}" == "$workspaceId");
    if (indexW == -1) return;
     _mentions[indexW]["number_unread_mentions"] = 0; 
    notifyListeners();
  }

  updateMentionWorkspace(data){
    var indexW = _mentions.indexWhere((element) => element["workspace_id"] == data["workspace_id"]);
    if (indexW == -1) return;
    var indexMention = _mentions[indexW]["data"].indexWhere((ele) => ele["id"] == data["mention_id"]);
    if (indexMention == -1) return;
    if (_mentions[indexW]["data"][indexMention]["type"] == "channel"){
      _mentions[indexW]["data"][indexMention]["message"] = Utils.mergeMaps([ _mentions[indexW]["data"][indexMention]["message"], data["message"]]);
    } else if (_mentions[indexW]["data"][indexMention]["type"] == "issues") {
      _mentions[indexW]["data"][indexMention]["issue"]["description"] = data["message"]["text"];
    } else {
      _mentions[indexW]["data"][indexMention]["issue_comment"]["comment"] = data["message"]["text"];
    }
    notifyListeners();
  }

  onChangeThread(bool value, token) async {
    final url = Utils.apiUrl + 'workspaces/${currentWorkspace["id"]}/update_unread_threads?token=$token';

    if (value) {
      _currentMember["number_unread_threads"] += 1;
    } else {
      try {
        final response = await Utils.getHttp(url);

        if (response["success"] == true) {
          _currentMember["number_unread_threads"] = 0;
        } else {
          throw HttpException("onChangeThread error");
        }
      } catch (e) {
        print(e.toString());
      }
    }

    notifyListeners();
  }

  onChangeTabs(bool value) {
    _isOnThreads = value;

    notifyListeners();
  }
  
  updateReactionMessageMention(data){
    var reaction = data["reactions"];
    var indexMentionWorkspace = _mentions.indexWhere((ele) => ele["workspace_id"] == reaction["workspace_id"]);
    if (indexMentionWorkspace != -1){
      var indexMessage = _mentions[indexMentionWorkspace]["data"].indexWhere((mention) => mention["message"]["id"] == reaction["message_id"]);
      if (indexMessage != -1){
        _mentions[indexMentionWorkspace]["data"][indexMessage]["message"] = Utils.mergeMaps([
          _mentions[indexMentionWorkspace]["data"][indexMessage]["message"],
          {
            "reactions": reaction["reactions"]
          }
        ]);
        notifyListeners();
      }
    }
  }

  updateDeleteWorkspace(context, token, data) {
    final workspaceId = data["workspace_id"];

    if (currentWorkspace["id"] == workspaceId) {
      getListWorkspace(context, token);
      _selectedTab = 0;
      notifyListeners();
    } else {
      final index = _data.indexWhere((e) => e["id"] == workspaceId);

      if (index != -1) {
        _data.removeAt(index);
        notifyListeners();
      }
    }
  }

  updateOnlineStatus(workspaceId, channelId, data) {
    final indexMember = members.indexWhere((e) => e["id"] == data["user_id"]);
    
    if (indexMember != -1) {
      members[indexMember]["is_online"] = data["is_online"];
      notifyListeners();
    }
  }

  String getNameWorkspace(workspaceId){
    try {
      var index  = _data.indexWhere((element) => "${element["id"] }"== "$workspaceId");
      return _data[index]["name"];
    } catch (e) {
      return "";
    }
  }

  leaveWorkspace(token, workspaceId, userId) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/leave_workspace?token=$token&user_id=$userId';

    try {
      var response  = await Dio().post(url);
      var res  = response.data;

      if (res["success"] == true) {
        final index = _data.indexWhere((e) => e["id"].toString() == workspaceId.toString());
        if (index == -1) return;
        _data.removeAt(index);
        setTab(0);
      } else {
        throw HttpException(res['message']);
      }
    } catch(e){
      print(e);
    }
  }

  sortWorkspace(dataWS) {
    List newList = dataWS.map((e) {
      int index = _data.indexWhere((ele) => ele['id'] == e);
      return index != -1 ? _data[index] : null;
    }).toList().where((e) => e != null).toList();

    _data = newList;
    notifyListeners();
  }

  Map getDataWorkspace(int workspaceId){
    int index = _data.indexWhere((e) => e["id"] == workspaceId);
    if (index == -1) return {};
    return _data[index];
  }

  handleCheckin(BuildContext context, workspaceId, shiftId) async {
    String defaultCheckinSuccessMessage = "Checkin thành công";
    final token = Provider.of<Auth>(context, listen: false).token;
    final preCheckinResult = await sendPreCheckin(workspaceId, token);

    if (preCheckinResult["success"]) {
      context.showLoadingDialog();
      final checkinResult = await sendCheckin(workspaceId, shiftId, token);
      Navigator.of(context).pop();
      if (checkinResult["success"]) {
        context.showDialogWithSuccess(checkinResult["message"] ?? defaultCheckinSuccessMessage);
      } else {
        context.showDialogWithFailure(checkinResult["message"]);
      }
    } else {
      context.showDialogWithFailure(preCheckinResult["message"]);
    }
  }

  Future<Map> sendPreCheckin(workspaceId, token) async {
    final preCheckinUrl = Utils.apiUrl + 'workspaces/$workspaceId/pre_checkin?token=$token';
    await Utils.requestPermission();

    final ssid = () async {
      final info = NetworkInfo();
      String? ssid = await info.getWifiName();
      if (ssid == null) return null;
      if (Platform.isIOS) return ssid;
      if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
        ssid = ssid.substring(1, ssid.length - 1);
      }
      return ssid;
    }.call();

    try {
      final response = await Dio().post(preCheckinUrl,
        data: {
          "ssid": await ssid
        }
      );
      var dataRes = response.data;
      return Map.from(dataRes);
    } catch (e, t) {
      print("$e\n$t");
      return {
        "success": false,
        "message": "Error, try again"
      };
    }
  }

  Future<Map> sendCheckin(workspaceId, shiftId, token) async {
    final checkInUrl = Utils.apiUrl + 'workspaces/$workspaceId/checkin_v2?token=$token';
    try {
      final response = await Dio().post(checkInUrl, data: {
        "shift_id": shiftId,
      });
      var dataRes = response.data;
      return Map.from(dataRes);
    } catch (e, t) {
      print("$e\n$t");
      return {
        "success": false,
        "message": "Error"
      };
    }
  }

  handleCheckout(BuildContext context, workspaceId, shiftId) async {
    String defaultCheckoutSuccessMessage = "Checkout thành công";
    final token = Provider.of<Auth>(context, listen: false).token;
    final checkoutResult = await sendCheckout(workspaceId, shiftId, token);
    if (checkoutResult["success"]) {
      context.showDialogWithSuccess(checkoutResult["message"] ?? defaultCheckoutSuccessMessage);
    } else {
      context.showDialogWithFailure(checkoutResult["message"]);
    }
  }
  Future<Map> sendCheckout(workspaceId, shiftId, token) async {

    final url = Utils.apiUrl + 'workspaces/$workspaceId/checkout_v2?token=$token';
    await Utils.requestPermission();
    final ssid = () async {
      final info = NetworkInfo();
      String? ssid = await info.getWifiName();
      if (ssid == null) return null;
      if (Platform.isIOS) return ssid;
      if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
        ssid = ssid.substring(1, ssid.length - 1);
      }
      return ssid;
    }.call();
    try {
      final response = await Dio().post(url,
        data: {
          "ssid": await ssid,
          "shift_id": shiftId
        }
      );
      var dataRes = response.data;
      return Map.from(dataRes);
    } catch (e, t) {
      print("$e\n$t");
      return {
        "success": false,
        "message": "Error, try again"
      };
    }
  }
}