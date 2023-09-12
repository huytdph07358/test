import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:hive/hive.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';

class Channels extends ChangeNotifier {
  List _data = [];
  Map _currentChannel = {};
  List _channelMember = [];
  Map _currentMember = {};
  List _selectedMember = [];
  List _currentCommand = [];
  List _appInChannel = [];
  String _message = "";
  String? _fbToken;
  String? _apnsToken;
  List _channelGeneral = [];
  bool _showChannelSetting = false;
  bool _showChannelPinned = false;
  bool _showChannelMember = false;
  List _lastChannelSelected = [];
  List _listChannelMember = [];
  List _listPinnedMessages = [];
  List _pinnedMessages = [];
  bool _isIssueLoading = false;
  List _attachmentsChannel = [];
  Map<String, List<String>> dataAssigneeChannels = {};

  List get data => _data;
  Map get currentChannel => _currentChannel;
  List get channelMember => _getChannelMember();
  Map get currentMember => _currentMember;
  List get selectedMember => _selectedMember;
  List get currentCommand => _currentCommand;
  List get appInChannels => _appInChannel;
  String get message => _message;
  List get channelGeneral => _channelGeneral;
  String? get fbToken => _fbToken;
  String? get apnsToken => _apnsToken;
  bool get showChannelSetting => _showChannelSetting;
  bool get showChannelPinned => _showChannelPinned;
  bool get showChannelMember => _showChannelMember;
  List get lastChannelSelected => _lastChannelSelected;
  List get pinnedMessages => _pinnedMessages;
  bool get isIssueLoading => _isIssueLoading;
  List get attachmentsChannel => _attachmentsChannel;

  // có khả năng sai vì currentchannel
  _getChannelMember() {
    final index = _listChannelMember.indexWhere((e) => e["id"] == currentChannel["id"]);
    if (index == -1) {
      return [];
    } else {
      return  _listChannelMember.where((e) => e["id"] == currentChannel["id"]).toList()[0]["members"];
    }
  }

  setIssueLoading(bool loading) {
   _isIssueLoading = loading;
  }

  Future<dynamic> setNullCurrentChannel() async {
    _currentChannel = {};

    notifyListeners();
  }
  Future<dynamic> loadChannels(String token, workspaceId) async {
    List channels = _data.where((e) => e["workspace_id"] == workspaceId && !Utils.checkedTypeEmpty(e["is_archived"])).toList();

    if (channels.length > 0 ) {
      _currentChannel = channels[0] ?? {};
      var box = await Hive.openBox('lastSelected');
      box.put('lastChannelId', _currentChannel["id"]);
      box.put("isChannel", 1);
    } else {
      _currentChannel = {};
    }
    notifyListeners();
  }

  onChangeLastChannel(workspaceId, channelId) {
    int index = _lastChannelSelected.indexWhere((e) => e["workspace_id"] == workspaceId && !Utils.checkedTypeEmpty(e["is_archived"]));
    if (index == -1) {
      _lastChannelSelected.add({
        "workspace_id": workspaceId,
        "channel_id": channelId
      });
    } else {
      _lastChannelSelected[index]["workspace_id"] = workspaceId;
      _lastChannelSelected[index]["channel_id"] = channelId;
    }
    var box = Hive.box('lastSelected');
    box.put("lastChannelSelected", _lastChannelSelected);
    notifyListeners();
  }

  openChannelSetting(value) async {
    _showChannelSetting = value;
    var box = await Hive.openBox('drafts');
    
    box.put('openSetting', value);
    box.put('openAbout', true);
    box.put('openPinned', false);
    box.put('openMember', false);
    _showChannelMember = false;
    _showChannelPinned = false;
    notifyListeners();
  }

  openChannelMember(value) async {
    _showChannelMember = value;
    var box = await Hive.openBox('drafts');

    _showChannelPinned = false;
    _showChannelSetting = false;
    box.put('openSetting', false);
    box.put('openPinned', false);
    box.put('openMember', value);
    notifyListeners();
  }

  openChannelPinned(value) async {
    _showChannelPinned = value;
    var box = await Hive.openBox('drafts');

    _showChannelSetting = false;
    _showChannelMember = false;
    box.put('openSetting', false);
    box.put('openMember', false);
    box.put('openPinned', true);
    notifyListeners();
  }

  setCurrentChannel(channelId) async {
    int index = _data.indexWhere((e) => e["id"] == channelId);

    if (index != -1) {
      _currentChannel = _data[index] ?? {};
    }

    var box = Hive.box('lastSelected');
    box.put('lastChannelId', channelId);
    box.put("isChannel", 1);

    // notifyListeners();
  }
  
  onSelectedChannel(workspaceId, channelId, auth, providerMessage) {
    setCurrentChannel(channelId);
    onChangeLastChannel(workspaceId, channelId);
    selectChannel(auth.token, workspaceId, channelId);
    providerMessage.loadMessages(auth.token, workspaceId, channelId);
    loadCommandChannel(auth.token, workspaceId, channelId);
    getChannelMemberInfo(auth.token, workspaceId, channelId, auth.userId);

    auth.channel.push(
      event: "join_channel",
      payload: {"channel_id": channelId, "workspace_id": workspaceId, "ssid": NetworkInfo().getWifiName()}
    );
  }

  markAsreadChannel(channelId) {
    final index = _data.indexWhere((e) => e["id"] == int.parse(channelId));
    if(index != -1) {
      _data[index]["seen"] = true;
      _data[index]["new_message_count"] = 0;
    }
    notifyListeners();
  }

  Future<dynamic> selectChannel(String token, workspaceId, channelId) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId?token=$token');
    final index = _listChannelMember.indexWhere((e) => e["id"] == channelId);

    if (index == -1) {
      try {
        final response = await http.get(url);
        final responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          int indexDataFiles = _attachmentsChannel.indexWhere((ele) => ele["id"] == channelId);

          if(indexDataFiles != -1) {
            _attachmentsChannel[indexDataFiles]['files'] = responseData['files'];
          } else {
            _attachmentsChannel.add({
              'id': channelId,
              'files': responseData['files'] 
            });
          }

          _listChannelMember.add({
            "id": channelId,
            "members": responseData["channel_member"]
          });

          _listPinnedMessages.add({
            "id": channelId,
            "pinnedMessages": responseData["pinned_channel_messages"]
          });

          if (currentChannel["id"] != null || currentChannel["id"] == channelId) { 
            _channelMember = responseData["channel_member"];
            _pinnedMessages = responseData["pinned_channel_messages"];
          }

          List newData = List.from(_data);
          int index = newData.indexWhere((e) => e["id"] == _currentChannel["id"]);

          if (index != -1) {
            newData[index]["seen"] = true;
            newData[index]["new_message_count"] = 0;
            _data = newData;
          }
          notifyListeners();
        } else {
          throw HttpException(responseData['message']);
        }
      } catch (e) {
        print(e);
        sl.get<Auth>().showErrorDialog(e.toString());
      }
    } else {
      if (currentChannel["id"] != null || currentChannel["id"] == channelId) {
        _channelMember = _listChannelMember[index]["members"];
        _pinnedMessages = _listPinnedMessages[index]["pinnedMessages"];
      }
      List newData = List.from(_data);
      int indexChannel = newData.indexWhere((e) => e["id"] == _currentChannel["id"]);

      if (index != -1) {
        newData[indexChannel]["seen"] = true;
        newData[indexChannel]["new_message_count"] = 0;
        _data = newData;
      }
    }
  }

  resetData() {
    _currentChannel = {};
    // _data = [];
  }

  Future<dynamic> createChannel(String token, workspaceId, String name, bool isPrivate, List uids, auth, providerMessage) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels?token=$token');
    try {
      final response = await http.post(
        url,
        headers: Utils.headers,
        body: json.encode(
          {'name': name, 'is_private': isPrivate, "user_ids": uids},
        ),
      );

      final responseData = json.decode(response.body);
      if (responseData["success"] == true) {
        final data = responseData["data"];
        final channelId = data["id"];
        int index = _data.indexWhere((e) => e["id"] == channelId);
        if (index == -1) {
          insertDataChannel(data);
          insertChannelMember(data);
        }
        onSelectedChannel(workspaceId, channelId, auth, providerMessage);
      } else {
        throw HttpException(responseData['message']);
      }

      notifyListeners();
    } catch (e) {
      print("____ $e");
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  insertChannelMember(channel) {
    int index = _listChannelMember.indexWhere((e) => e["id"] == channel["id"] && e["workspace_id"] == channel["workspace_id"]);
    if (index != -1) {
      // khi nguoi khac tham gia add members
      int indexUser = _listChannelMember[index]["members"].indexWhere((e) => e["id"] == channel["user"]["id"]);
      if(indexUser == -1) _listChannelMember[index]["members"].add(channel["user"]);
    } else {
      // create channel mac dinh add chinh minh
      _listChannelMember.add({
        "id": channel["id"],
        "workspace_id": channel["workspace_id"],
        "members": [channel["user"]]
      });
    }
  }
  

  Future<String> inviteToChannel(String token, workspaceId, channelId, text, type, userId) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/send_invitation?token=$token');
    try {
      final response = await http.post(url,
          headers: Utils.headers,
          body: json.encode({'id': userId, 'text': text, 'type': type}));
      final responseData = json.decode(response.body);
     _message = responseData["message"];
     return _message;
    } catch(e){
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
    return _message;
  }

  Future<dynamic> inviteToPubChannel(token, workspaceId, channelId, receiverId) async {
    Uri url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/invite_to_public_channel?token=$token');
    try {
      final body = {
        "receiver_id": receiverId
      };
      final response = await http.post(url, headers: Utils.headers, body: json.encode(body));
      final responseData = json.decode(response.body);
      _message = responseData["message"] ?? "";
      if (responseData["success"] == false) {
        throw HttpException(responseData['message']);
      }
      notifyListeners();
    } catch(e) {
      print(e);
    }
  }

  Future<dynamic> addDevicesToken(String token, workspaceId, String? firebaseToken, String platform) async {
    _fbToken = firebaseToken;
    final url = Utils.apiUrl + 'workspaces/$workspaceId/add_devices_token?token=$token';
    try {
      await Dio().post(url,
          data: json
              .encode({'firebase_token': firebaseToken, 'platform': platform}));

      notifyListeners();
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> addApnsToken(String token, workspaceId, String? apnsToken) async {
    _apnsToken = apnsToken;
    final url = Utils.apiUrl + 'workspaces/$workspaceId/add_apns_token?token=$token';
    try {
      await Dio().post(url,
          data: json.encode({'apns_token': apnsToken}));
    } catch (e, trace) {
      print("$e\n$trace");
    }
  }

  Future<dynamic> deleteDevicesToken(String token) async {
    final url = Utils.apiUrl + 'workspaces/remove_devices_token?token=$token';
    try {
      await Dio()
          .delete(url, data: json.encode({'firebase_token': _fbToken}));

      notifyListeners();
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> deleteApnsToken(String token) async {
    final url = Utils.apiUrl + 'workspaces/remove_apns_token?token=$token';
    try {
      await Dio()
          .delete(url, data: json.encode({'apns_token': _apnsToken}));
      notifyListeners();
    } catch (e, trace) {
      print("$e\n $trace");
    }
  }

  Future<dynamic> changeChannelInfo(String token, workspaceId, channelId, channel) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/channel_info?token=$token');

    try {
      final response = await http.post(url,headers: Utils.headers, body: json.encode(channel));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        _currentChannel = channel;
        int index =  _data.indexWhere((e) => e["id"] == channel["id"]);
        _data[index] = channel;
      } else {
        throw HttpException(responseData['message']);
      }

      notifyListeners();
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> deleteChannelMember(String token, workspaceId, channelId, list) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/delete_member?token=$token');

    try {
      final response =
          await http.post(url, headers: Utils.headers, body: json.encode(list));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        // selectChannel(token, workspaceId, channelId);
      } else {
        throw HttpException(responseData['message']);
      }

      notifyListeners();
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> getChannelMemberInfo(String token, workspaceId, channelId, userId) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/member_info?token=$token&userId=$userId');
    if (userId != null) {
      try {
        final response = await http.get(url);
        final responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          _currentMember = responseData["member"];
        } else {
          throw HttpException(responseData['message']);
        }
        // notifyListeners();
      } catch (e) {
        print(e);
        sl.get<Auth>().showErrorDialog(e.toString());
      }
    }
  }

  updateStatusNotify(channelId, statusNotify) {
    final index = _data.indexWhere((e) => e["id"] == channelId);
    if(index == -1) return;
    _data[index]["status_notify"] = statusNotify;
    notifyListeners();
  }

  Future<dynamic> changeChannelMemberInfo(String token, workspaceId, channelId, member, String type) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/change_member_info?token=$token';
    var newMemberInfo = {...member, "type": type};

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(newMemberInfo));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        _currentMember = member;
      } else {
        throw HttpException(responseData['message']);
      }
      notifyListeners();
    } catch (e, trace) {
      print(e);
      print(trace);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> onSelectChannelMember(List list) async {
    _selectedMember = list;
    notifyListeners();
  }

  Future<dynamic> deleteChannel(String token, workspaceId, channelId, idGeneral) async {
    if (idGeneral != channelId) {
      final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/delete?token=$token';
      try {
        final response = await http.post(Uri.parse(url), headers: Utils.headers);
        final responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

          if (indexChannel != -1) {
            _data.removeAt(indexChannel);
            loadChannels(token, workspaceId);
          }
        } else {
          _message = "Không xóa được channel này !";
          throw HttpException(responseData['message']);
        }

        notifyListeners();
      } catch (e) {
        print(e);
        sl.get<Auth>().showErrorDialog(e.toString());
      }
    } else {
      _message = "Không xóa được channel này !";
    }
  }

  updateMessageChannel(payload) {
    int index = _data.indexWhere((e) => e["id"].toString() == payload["channel_id"].toString());

    if (index != -1) {
      _data[index]["new_message_count"] = payload["new_message_count"];
      _data[index]["seen"] = payload["seen"];
      notifyListeners();
    }
  }

  updateProfileChannel(data){
    _channelMember.map((e){
      if(e["id"] == data["user_id"]){
        e["avatar_url"] = data["avatar_url"];
        e["full_name"] = data["full_name"];
      }
      return e;
    }).toList();
    notifyListeners();
  }

  parseAttachments(attachments) {
    final string = attachments[0]["type"] == "mention" ? attachments[0]["data"].map((e) {
      if (e["type"] == "text" ) return e["value"];
      if (e["type"] == "all") return "@all";
      return "@${e["name"] ?? ""}";
    }).toList().join() : attachments[0]["type"] == "bot" ? "Sent an attachment"  : "Sent an image";

    return string;
  }

  Future<dynamic> updateChannelSnippet(channelId, payload) async {
    if (payload["channel_thread_id"] == null) {
      final attachments = payload["attachments"];
      final message = payload["message"];
      final snippet = {
        "message": !Utils.checkedTypeEmpty(message) ? parseAttachments(attachments) : "${payload["message"]}",
        "user": payload["user"] != null ? payload["user"] : payload["full_name"] ?? "Bot",
        "user_id": payload["user_id"]
      };
      List newData = List.from(_data);
      int index = newData.indexWhere((e) => e["id"] == channelId);
      if (index != -1) {
        newData[index]["snippet"] = snippet;
        _data = newData;
      }
      notifyListeners();
    }
  }

  updateChannelSnippets(data){
    var length =  data.length;

    for(var  i= 0; i< length ; i++){
      if (data[i]["snippet"] != null) {
        updateChannelSnippet(data[i]["id"], data[i]["snippet"]);
      }
    }
  }

  //  trong truong hop dang o view IssueInfo thi ko nen reset lai
  //  vi se bi mat data => giuwx laij tat ca nhuwng gi dang co cua channel hien tai, merge data moi.
  setDataChannels(channels) {

    if (Utils.checkedTypeEmpty(currentChannel["id"])){
      channels = channels.map((channel) {
        if (channel["id"] == currentChannel["id"]) {
          int index = data.indexWhere((element) => element["id"] == channel["id"]);
          if (index == -1) return channel;
          return {
            ...data[index],
            ...(channel as Map)
          };
        }
        return channel;
      }).toList();
    }
    _data = channels;
    _data.sort((a, b) => a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));
    _channelGeneral =  _data.where((e) => e['name'] == "newsroom").toList();
    notifyListeners();
  }

  insertDataChannel(channel) {
    final index = _data.indexWhere((e) => e["id"] == channel["id"]);

    if (index == -1) {
      _data = _data + [channel];
      _data.sort((a, b) {
        return a['name'].toLowerCase().compareTo(b['name'].toLowerCase());
      });
      notifyListeners();
    }
  }

  updateChannel(channel, context) {
    var channelId = channel["channel_id"];
    var lastIndex = _data.lastIndexWhere((element) {
      return element["id"] == channelId;
    });

    if (lastIndex >= 0) {
      _data[lastIndex]["name"] = channel["name"] == null ?  _data[lastIndex]["name"] : channel["name"];
      _data[lastIndex]["is_private"] = channel["is_private"] == null ? _data[lastIndex]["is_private"] : channel["is_private"];
      _data[lastIndex]["user_count"] = channel["user_count"] == null ? _data[lastIndex]["user_count"] : channel["user_count"];
      _data[lastIndex]["topic"] = channel["topic"] == null ? _data[lastIndex]["topic"] : channel["topic"];
      _data[lastIndex]["is_archived"] = channel["is_archived"] == null ? _data[lastIndex]["is_archived"] : channel["is_archived"];
    }

    notifyListeners();
  }

  loadCommandChannel(token, workspaceId, channelId) async {
    final url = "${Utils.apiUrl}workspaces/$workspaceId/channels/$channelId/commands?token=$token";
    try {
      var response  = await Dio().get(url);
      var resData = response.data;
      _currentCommand = resData["data"]["commands"];
      _appInChannel = resData["data"]["apps"];
    } catch (e) {
      _currentCommand = [];
      sl.get<Auth>().showErrorDialog(e.toString());
    }
    // notifyListeners();
  }

  Future<String> joinChannelByInvitation(token, workspaceId, channelId, text, type, userInvite, messageId) async{
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/join_channel?token=$token';
    try {

      print({'text': text, 'type': type, 'user_invite' : userInvite, 'message_id' : messageId});
      final response = await http.post(Uri.parse(url),
        headers: Utils.headers,
        body: json.encode({'text': text, 'type': type, 'user_invite' : userInvite, 'message_id' : messageId}));
      final responseData = json.decode(response.body);
      _message = responseData["message"];
      if (responseData["success"] == false) {
        throw HttpException(responseData['message']);
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
    return _message;
  }

  Future<String> declineInviteChannel(token, workspaceId, channelId, userInvite, messageId) async{
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/decline_invite_channel?token=$token';
    try{
      final response = await http.post(Uri.parse(url),
        headers: Utils.headers,
        body: json.encode({'workspace_id' : workspaceId, 'channel_id' : channelId, 'user_invite' : userInvite, 'message_id' : messageId})
      );
      final responseData = json.decode(response.body);
      _message = responseData["message"];
      if(responseData["success"] == false){
        throw HttpException(responseData["message"]);
      }
      notifyListeners();
    } catch(e){
      print(e);
    }
    return _message;
  }

  joinChannelByCode(token ,textCode, currentUser) async {
    final key = textCode.split("-");
    final workspaceId = key[1];
    final channelId = key[2];
    var type;
    var text;

    if (currentUser["email"] != null || currentUser["email"] != "") {
      type = 1;
      text = currentUser["email"];
    } else {
      type = 2;
      text = currentUser["email"];
    }

    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/join_channel?token=$token';

    try {
      final response = await http.post(Uri.parse(url),
        headers: Utils.headers,
        body: json.encode({'text': text, 'type': type}));
      final responseData = json.decode(response.body);

      if (responseData["success"] == false) {
        _message = responseData['message'];
        throw HttpException(responseData['message']);
      } else {
        _message = "Join Channel Complete !";
        sl.get<Auth>().showToastMessage("successfully", _message);
      }
    } catch (e) {
      print(e);
      // sl.get<Auth>().showErrorDialog(e.toString());
      sl.get<Auth>().showToastMessage("failure", e.toString());
    }
  }

  Future<dynamic> leaveChannel(token, workspaceId, channelId) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/leave_channel?token=$token';
    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers);
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final index = _data.indexWhere((e) => e["id"] == channelId);

        if (index != -1) {
          _data.removeAt(index);
          loadChannels(token, workspaceId);
        } else {

        }
      } else {
        throw HttpException(responseData['message']);
      }

      notifyListeners();
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  updatePinnedChannel(channelId) {
    final index = _data.indexWhere((e) => e["id"] == channelId);

    if (index != -1) {
      _data[index]["pinned"] = !_data[index]["pinned"];
  
      notifyListeners();
    }
  }

  Future<dynamic> getListIssue(token, workspaceId, channelId, page, isClosed, filters, sortBy, text) async { 
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues?token=$token&page=$page&isClosed=$isClosed&filters=$filters&text=$text';
    final index = _data.indexWhere((e) => e["id"] == channelId);

    /////Hàm này gọi 1 lần duy nhất lúc mỗi lần vào channel để lấy list assignee đc ưu tiên nhất sort lên đầu.
    getAssignees(token, workspaceId, channelId);

    try {
      setIssueLoading(true);
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({
        "isClosed": isClosed,
        "filters": filters,
        "page": page,
        "sortBy": sortBy
      }));

      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        if (index != -1) {
          _data[index]["issues"] = responseData["issues"];
          _data[index]["labels"] = responseData["labels"];
          _data[index]["milestones"] = responseData["milestones"];
          _data[index]["openIssuesCount"] = responseData["openIssuesCount"];
          _data[index]["closedIssuesCount"] = responseData["closedIssuesCount"];
          _data[index]["totalPage"] = responseData["totalPage"];
          _currentChannel = _data[index];
          notifyListeners();

          return responseData;
        }
      } else {
        throw HttpException(responseData['message']);
      }
      setIssueLoading(false);
    } catch (e) {
      setIssueLoading(false);
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  getAssignees(String token, int workspaceId, int channelId) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/get_assignee?token=$token';

    /// Check xem đã có data chưa, có rồi thì k gọi api nữa.
    if (dataAssigneeChannels["$channelId"] != null) return;
    try {
      final response = await http.get(Uri.parse(url), headers: Utils.headers);
      final responeData = json.decode(response.body);

      if (responeData["success"] == true) {
        dataAssigneeChannels["$channelId"] = (responeData["assignees"] as List).map((e)  => e as String).toList();
      } else {
        dataAssigneeChannels["$channelId"] = [];
      }
    } catch (e, t) {
      dataAssigneeChannels["$channelId"] = [];
      print("getAssignees error ${e.toString()}");
      print(t);
      return null;
    }
  }

  Future<dynamic> loadMoreIssue(token, workspaceId, channelId, page, isClosed, filters, sortBy, text) async { 
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues?token=$token&page=$page&isClosed=$isClosed&filters=$filters&text=$text';
    final index = _data.indexWhere((e) => e["id"] == channelId);

    if (!_isIssueLoading) {
      setIssueLoading(true);

      try {
        final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({
          "isClosed": isClosed,
          "filters": filters,
          "page": page,
          "sortBy": sortBy
        }));

        final responseData = json.decode(response.body);

        if (responseData["success"] == true) {
          if (index != -1) {
            _data[index]["issues"] = ( _data[index]["issues"] ?? []) + responseData["issues"];
            _currentChannel = _data[index];

            setIssueLoading(false);
            notifyListeners();

            return responseData;
          }
        } else {
          throw HttpException(responseData['message']);
        }
      } catch (e) {
        setIssueLoading(false);
        print(e);
        sl.get<Auth>().showErrorDialog(e.toString());
      }
    }
  }

  setLabelsAndMilestones(channelId, labels, milestones){
    final index = _data.indexWhere((e) => e["id"] == channelId);
    if (index != -1){
      _data[index]["labels"] = labels;
      _data[index]["milestones"] = milestones;
      notifyListeners();
    }
  }

  Future<dynamic> getLabelsStatistical(token, workspaceId, channelId) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/get_labels_statistical?token=$token');
    final index = _data.indexWhere((e) => e["id"] == channelId);
    try {
      final response = await http.get(url, headers: Utils.headers);
      final responseData = json.decode(response.body);
      if (responseData["success"]) {
        if(index != -1) {
          _data[index]["labelsStatistical"] = responseData["labels"]; 
          notifyListeners();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> getMilestoneStatiscal(token, workspaceId, channelId) async {
    final url = Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/get_milestones_statistical?token=$token');
    final index = _data.indexWhere((e) => e["id"] == channelId);

    try {
      final response = await http.get(url, headers: Utils.headers);
      final responseData = json.decode(response.body);
      if (responseData["success"]) {
        if(index != -1) {
          _data[index]["milestonesStatistical"] = responseData["milestones"];
          notifyListeners();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> createChannelLabel(token, workspaceId, channelId, label) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/create_label?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(label));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) {
          final newLabel = responseData["label"];
          _data[indexChannel]["labels"] = _data[indexChannel]["labels"] != null ? [newLabel] + _data[indexChannel]["labels"] : [newLabel]; 
        }
      } else {
        throw HttpException(responseData['message']);
      }

    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  Future<dynamic> createChannelMilestone(token, workspaceId, channelId, milestone) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/create_milestone?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(milestone));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) {
          final newMilestone = responseData["milestone"];
          _data[indexChannel]["milestones"] = _data[indexChannel]["milestones"] != null ? [newMilestone] + _data[indexChannel]["milestones"] : [newMilestone]; 
        }
      } else {
        throw HttpException(responseData['message']);
      }

    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  Future<dynamic> deleteAttribute(token, workspaceId, channelId, attributeId, type) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/delete?token=$token';
    final body = {
      "attribute_id": attributeId,
      "type": type
    };

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(body));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) {
          if (type == "label") {
            final indexLabel = _data[indexChannel]["labels"].indexWhere((e) => e["id"] == attributeId);

            if (indexLabel != -1) {
              _data[indexChannel]["labels"].removeAt(indexLabel);
            }
          } else if (type == "milestone") {
            final indexMilestone = _data[indexChannel]["milestones"].indexWhere((e) => e["id"] == attributeId);

            if (indexMilestone != -1) {
              _data[indexChannel]["milestones"].removeAt(indexMilestone);
            }
          } else {

          }
        }
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
    
    notifyListeners();
  }

  Future<dynamic> updateLabel(token, workspaceId, channelId, label) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/update_label?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(label));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) {
          final indexLabel = _data[indexChannel]["labels"].indexWhere((e) => e["id"] == label["id"]);

          if (indexLabel != -1) {
            _data[indexChannel]["labels"][indexLabel] = label;
          }
        }
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  Future<dynamic> updateMilestone(token, workspaceId, channelId, milestone) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/update_milestone?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(milestone));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) {
          final indexMilestone = _data[indexChannel]["milestones"].indexWhere((e) => e["id"] == milestone["id"]);

          if (indexMilestone != -1) {
            final newMilestone = responseData["milestone"];
            _data[indexChannel]["milestones"][indexMilestone] = newMilestone;
          }
        }
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  Future<dynamic> createIssue(token, workspaceId, channelId, issue) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/create_issue?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(issue));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        await getListIssue(token, workspaceId, channelId, 1, false, [], "newest", "");

        return responseData["issue"];
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  Future<dynamic> closeIssue(token, workspaceId, channelId, issueId, isClosed, issueClosedTab) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/close_issue?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({"issue_id": issueId, "is_closed": isClosed}));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
       
        currentChannel["openIssuesCount"] = isClosed ? currentChannel["openIssuesCount"] - 1 : currentChannel["openIssuesCount"] + 1;
        currentChannel["closedIssuesCount"] = isClosed ? currentChannel["closedIssuesCount"] + 1 : currentChannel["closedIssuesCount"] - 1;
        notifyListeners();
        // await getListIssue(token, workspaceId, channelId, 1, issueClosedTab, [], "newest", "");
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> updateIssueTitle(token, workspaceId, channelId, issueId, title, description) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/update_issue?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({"issue_id": issueId, "title": title, "data": description}));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) { 
          final indexIssue = _data[indexChannel]["issues"].indexWhere((e) => e["id"] == issueId);

          if (indexIssue != -1) {
            _data[indexChannel]["issues"][indexIssue]["updated_at"] = responseData["issue"]["updated_at"];
            _data[indexChannel]["issues"][indexIssue]["last_edit_description"] = responseData["issue"]["last_edit_description"];

            notifyListeners();
          }
        }
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Future<dynamic> closeMilestone(token, workspaceId, channelId, milestoneId, isClosed) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/close_milestone?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({"milestone_id": milestoneId, "is_closed": isClosed}));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        // await getListIssue(token: token, workspaceId: workspaceId, channelId: channelId);
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  Future<dynamic> updateComment(token, comment) async {
    final channelId = comment["channel_id"];
    final commentId = comment["from_id_issue_comment"];
    final url = Utils.apiUrl + 'workspaces/${comment["workspace_id"]}/channels/$channelId/issues/update_comment?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({"comment_id": commentId, "data": comment}));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) {
          final newComment = responseData["comment"];
          final channel = _data[indexChannel];
          final indexIssue = channel["issues"].indexWhere((e) => e["id"] == newComment["issue_id"]);

          if (indexIssue != -1) {
            final indexComment = channel["issues"][indexIssue]["comments"].indexWhere((e) => e["id"] == commentId);
            channel["issues"][indexIssue]["updated_at"] = responseData["issue"]["updated_at"];

            if (indexComment != -1) {
              channel["issues"][indexIssue]["comments"][indexComment] = newComment;
            }
          }
        }
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  Future<dynamic> submitComment(token, comment) async {
    final channelId = comment["channel_id"];
    final issueId = comment["from_issue_id"];
    final url = Utils.apiUrl + 'workspaces/${comment["workspace_id"]}/channels/$channelId/issues/submit_comment?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({"data": comment, "issue_id": issueId}));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) {
          final channel = _data[indexChannel];
          final indexIssue = channel["issues"].indexWhere((e) => e["id"] == issueId);

          if (indexIssue != -1) {
            channel["issues"][indexIssue]["updated_at"] = responseData["issue"]["updated_at"];
          }
        }
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  Future<dynamic> deleteComment(token, workspaceId, channelId, commentId, issueId) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/delete_comment?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({"comment_id": commentId, "issue_id": issueId}));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) {
          final channel = _data[indexChannel];
          final indexIssue = channel["issues"].indexWhere((e) => e["id"] == issueId);

          if (indexIssue != -1) {}
        }
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  Future<dynamic> removeAttribute(token, workspaceId, channelId, issueId, type, attributeId) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/remove_attribute?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({"issue_id": issueId, "type": type, "attribute_id": attributeId}));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) {
          final channel = _data[indexChannel];
          if (channel["issues"] != null) {
            final indexIssue = channel["issues"].indexWhere((e) => e["id"] == issueId);

            if (indexIssue != -1) {
              final issue = channel["issues"][indexIssue];

              if (type == "milestone") {
                issue["milestone_id"] = null;
              } else if (type == "label") {
                issue["labels"].removeAt(issue["labels"].indexWhere((e) => e == attributeId));
              } else {
                issue["assignees"].removeAt(issue["assignees"].indexWhere((e) => e == attributeId));
              }

              channel["issues"][indexIssue]["updated_at"] = responseData["issue"]["updated_at"];
            }
          }
        }
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  Future<dynamic> addAttribute(token, workspaceId, channelId, issueId, type, attributeId) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/add_attribute?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({"issue_id": issueId, "type": type, "attribute_id": attributeId}));
      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) {
          final channel = _data[indexChannel];
          if (channel["issues"] != null) {
            final indexIssue = channel["issues"].indexWhere((e) => e["id"] == issueId);

            if (indexIssue != -1) {
              final issue = channel["issues"][indexIssue];

              if (type == "milestone") {
                issue["milestone_id"] = attributeId;
              } else if (type == "label") {
                issue["labels"].add(attributeId);
              } else {
                issue["assignees"].add(attributeId);
              }

              channel["issues"][indexIssue]["updated_at"] = responseData["issue"]["updated_at"];
            }
          }
        }
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }

    notifyListeners();
  }

  clearBadge(channelId) {
    final index = _data.indexWhere((e) => e["id"] == channelId);

    if (index != -1) {
      _data[index]["seen"] = true;
      _data[index]["new_message_count"] = 0;
    }

    notifyListeners();
  }

  Future<dynamic> pinMessage(token, workspaceId, channelId, messageId) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/messages/pin_channel_message?token=$token';
    final body = {"message_id": messageId};
    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode(body));
      final responseData = json.decode(response.body);

      if (responseData["success"] != true) throw HttpException(responseData['message']);
    } catch (e) {
      print("pinMessage: $e");
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  void updatePinnedMessage(data) {
    var message = data['message'];
    int index = _listPinnedMessages.indexWhere((e) => e['id'] == message['channel_id']);
    if(index != -1) {
      int indexMessage = _listPinnedMessages[index]['pinnedMessages'].indexWhere((e) => e['id'] == message['id']);
      if (indexMessage != -1) {
        _listPinnedMessages[index]['pinnedMessages'][indexMessage] = message;
        notifyListeners();
      }
    }
  }

  Future<dynamic> updateChannelInfo(payload) async{
    final type = payload["type"];
    final data = payload["data"];

    if (type == "pin_message") {
      final index = _listPinnedMessages.indexWhere((e) => e["id"] == data["channel_id"]);

      if (index != -1) {
        final indexPinnedMessage = _listPinnedMessages[index]["pinnedMessages"].indexWhere((e) => e["id"] == data["id"]);

        if (indexPinnedMessage == -1) {
          _listPinnedMessages[index]["pinnedMessages"].insert(0, data);
        } else {
          _listPinnedMessages[index]["pinnedMessages"].removeAt(indexPinnedMessage);
        }
        notifyListeners();
      }
    }
  }

  Future<dynamic> bulkAction(token, workspaceId, channelId, type, attributeId, listIssue, isRemove, filters, page, sortBy, isClosed) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/bulk_action?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({
        "list_issue": listIssue, 
        "type": type, 
        "attribute_id": attributeId,
        "is_remove": isRemove
      }));

      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        await getListIssue(token, workspaceId, channelId, 1, isClosed, filters, sortBy, "");
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  

  Future<dynamic> updateUnreadIssue(token, workspaceId, channelId, issueId, userId) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/update_unread_issue?token=$token';

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({
        "issue_id": issueId
      }));

      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

        if (indexChannel != -1) {
          final channel = _data[indexChannel];
          final indexIssue = channel["issues"].indexWhere((e) => e["id"] == issueId);

          if (indexIssue != -1) {
            final issue = channel["issues"][indexIssue];
            final indexUser = issue["users_unread"].indexWhere((e) => e == userId);
            issue["comments"] = responseData["comments"];

            if (indexUser != -1) {
              issue["users_unread"].removeAt(indexUser);
            }

            notifyListeners();
          }
        }
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  getAttributesForNotify(channelId, data) {
    try {
      final index = _data.indexWhere((e) => e["id"] == channelId);
      if (index == -1) return [];
      
      if (data["type"] == "labels") {
        return _data[index]["labels"].where(
          (e) => data["added"].contains(e["id"]) || data["removed"].contains(e["id"])
        ).toList();
      } else if (data["type"] == "milestone") {
        return _data[index]["milestones"].where(
          (e) => data["added"].contains(e["id"]) || data["removed"].contains(e["id"])
        ).toList();
      } else if (data["type"] == "assignees") {
        return channelMember.where(
          (e) => data["added"].contains(e["id"]) || data["removed"].contains(e["id"])
        ).toList();
      }
    } catch (e) {
      return [];
    }
  }

  Future<dynamic> updateIssueTimeline(token, workspaceId, channelId, issueId, data) async {
    final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/add_issue_timeline?token=$token';

    List attributes = getAttributesForNotify(channelId, data);

    try {
      final response = await http.post(Uri.parse(url), headers: Utils.headers, body: json.encode({
        "issue_id": issueId,
        "data": data,
        "attributes": attributes
      }));

      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
      } else {
        throw HttpException(responseData['message']);
      }
    } catch (e) {
      print(e);
      // sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  updateChannelIssue(token, workspaceId, channelId, issueId, type, data) async {
    final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

    try {
      if (indexChannel != -1) {
        final channel = _data[indexChannel];

        if (issueId != null && channel["issues"] != null) {
          final indexIssue = channel["issues"].indexWhere((e) => e["id"] == issueId);

          if (indexIssue != -1) {
            final issue = (channel["issues"] ?? [])[indexIssue];
          
            if (type == "update_timeline") {
              if (issue["timelines"] != null) issue["timelines"].add(data);
            } else if (type == "add_assignee") {
              final index = (issue["assignees"] ?? []).indexWhere((e) => e == data);

              if (index == -1) {
                issue["assignees"] != null ? issue["assignees"].add(data) : issue["assignees"] = [data];
              }
            } else if (type == "add_label") {
              final index = (issue["labels"] ?? []).indexWhere((e) => e == data);

              if (index == -1) {
                issue["labels"] != null ? issue["labels"].add(data) : issue["labels"] = [data];
              }
            } else if (type == "add_milestone") {
              issue["milestone_id"] = data;
            } else if (type == "remove_assignee") {
              final index = (issue["assignees"] ?? []).indexWhere((e) => e == data);

              if (index != -1) {
                issue["assignees"].removeAt(index);
              }
            } else if (type == "remove_label") {
              final index = (issue["labels"] ?? []).indexWhere((e) => e == data);

              if (index != -1) {
                issue["labels"].removeAt(index);
              }
            } else if (type == "remove_milestone") {
              issue["milestone_id"] = null;
            } else if (type == "add_comment") {
              issue["comments"].add(data["comment"]);
              issue["users_unread"] = data["users_unread"];

              if (issue["comments_count"] != null) {
                issue["comments_count"] += 1; 
              }
            } else if (type == "delete_comment") {
              final index = (issue["comments"] ?? []).indexWhere((e) => e["id"] == data);

              if (index != -1) {
                issue["comments"].removeAt(index);
              }
            } else if (type == "close_issue") {
              issue["is_closed"] = data;
            } else if (type == "update_issue_title") {
              issue["title"] = data["title"];
              issue["description"] = data["description"];
              issue["last_edit_id"] = data["last_edit_id"];
            } else if (type == "update_comment") {
              final indexComment = (issue["comments"] ?? []).indexWhere((e) => e["id"] == data["id"]);

              if (indexComment != -1) {
                issue["comments"][indexComment] = data;
              }
            }
          } else {
            if (type == "new_issue") {
              channel["issues"] = [data] + channel["issues"];
            }
          }
          notifyListeners();
        } else {
          if (type == "close_milestone") {
            final indexMilestone = (_data[indexChannel]["milestones"] ?? []).indexWhere((e) => e["id"] == data["milestone_id"]);

            if (indexMilestone != -1) {
              _data[indexChannel]["milestones"][indexMilestone]["is_closed"] = data["is_closed"];
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print("type issue error $type");
      print("type data error $data");
      print(e.toString());
    }
  }

  newChannelMember(data) {
    final newUser = data["new_user"];
    List list = List.from(_channelMember);
    final index = list.indexWhere((e) => e["user_id"] == newUser["id"]);
    final channelId = newUser["channel_id"];

    if (index == -1) {
      list.add(newUser);
      _channelMember = list;

      final index = _listChannelMember.indexWhere((e) => e["id"] == channelId);

      if (index != -1) {
        _listChannelMember[index]["members"] = list;
      }

      notifyListeners();
    }
  }

  removeChannelMember(data) {
    List list = List.from(_channelMember);
    final indexMember = list.indexWhere((e) => e["user_id"] == data["channel_id"]);

    if (indexMember != -1) {
      list.removeAt(indexMember);
      _channelMember = list;

      final index = _listChannelMember.indexWhere((e) => e["id"] == data["channel_id"]);

      if (index != -1) {
        _listChannelMember[index]["members"] = list;
      }

      notifyListeners();
    }
  }

  updateMentionIssue(data) {
    final indexChannel = _data.indexWhere((e) => e["id"] == data["channel_id"]);

    if (indexChannel > -1) {
      final channel = _data[indexChannel];
      if (channel["issues"] != null) {
        if (data["type"] == "issue_comment") {
          int indexIssue = channel["issues"].indexWhere((e) => e["id"] == data["issue_id"]);
          if (indexIssue > -1) {
            final issue = channel["issues"][indexIssue];
            final indexComment = issue["comments"].indexWhere((e) => e["id"] == data["id"]);
            if (indexComment > -1) _data[indexChannel]["issues"][indexIssue]["comments"][indexComment]["mentions"] = data["mentions"];
            notifyListeners();
          }
        } else {
          int indexIssue = channel["issues"].indexWhere((e) => e["id"] == data["id"]);
          if (indexIssue > -1) _data[indexChannel]["issues"][indexIssue]["mentions"] = data["mentions"];
          notifyListeners();
        }
      }
    }
  }

  transferIssue(channelId, issueId) {
    final indexChannel = _data.indexWhere((e) => e["id"] == channelId);

    if (indexChannel != -1) {
      final channel = _data[indexChannel];

      if (issueId != null && channel["issues"] != null) {
        final indexIssue = channel["issues"].indexWhere((e) => e["id"] == issueId);

        if (indexIssue != -1) {
          channel["issues"].removeAt(indexIssue);
          notifyListeners();
        }
      }
    }
  }

  setLastChannelFromHive(List data){
    _lastChannelSelected = data;
  }

  String getChannelName(channelId) {
    var index = _data.indexWhere((element) => "${element["id"]}" == "$channelId");
    if (index == -1) return "";
    return _data[index]["name"] ?? "";
  }

  Map getChannel(channelId) {
    var index = _data.indexWhere((element) => "${element["id"]}" == "$channelId");
    if (index == -1) return {};
    return _data[index];
  }

  List getChannelMember(channelId){
    try {
      var index  = _listChannelMember.indexWhere((element) => element["id"].toString() == channelId.toString());
      return _listChannelMember[index]["members"];      
    } catch (e) {
      return [];
    }
  }

  updateAttachmentsChannel(data) {
    int index = _attachmentsChannel.indexWhere((ele) => ele['id'].toString() == data['channel_id'].toString());

    if(index != -1) {
      _attachmentsChannel[index]['files'] = data['files'] + _attachmentsChannel[index]['files'];
      notifyListeners();
    }
  }

  List getFilesChannel(channelId) {
    try{
      int index = _attachmentsChannel.indexWhere((ele) => ele['id'].toString() == channelId.toString());

      if(index != -1) return _attachmentsChannel[index]['files'];
      return [];
    } catch (e) {
      return [];
    }
  }

}