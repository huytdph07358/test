import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:workcake/E2EE/GroupKey.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/direct_message/dm_confirm_shared.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/media_conversation/isolate_media.dart';
import 'package:workcake/components/media_conversation/model.dart';
import 'package:workcake/components/media_conversation/stream_media_downloaded.dart';
import 'package:workcake/controller/direct_message_controller.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/reaction_message_user.dart';
import 'package:workcake/service_locator.dart';
import 'package:workcake/services/queue.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

class DataInfoThreadConv {
  late String conversationId;
  late String messageId;
  late bool isRead;
  late int count;

  DataInfoThreadConv(this.conversationId, this.messageId, this.isRead, this.count);
  
  static DataInfoThreadConv? fromJson(Map obj) {
    late DataInfoThreadConv d;
    try {
      d = DataInfoThreadConv(obj["conversation_id"], obj["message_id"], obj["is_read"], obj["count"]);
    } catch (e, t) {
      print("$e $t $obj");
    }
    return d;
  }
}


class NumberUnreadConversation{
  int _currentTime = 0;
  int _unreadCount = 0;

  int get currentTime => this._currentTime;

  set currentTime( value) => this._currentTime = value;

  int get unreadCount => this._unreadCount;

  set unreadCount( value) => this._unreadCount = value;

  NumberUnreadConversation(int currentTime, int unreadCount){
    this._currentTime = currentTime;
    this._unreadCount = unreadCount;
  }


  updateFromObj(Map obj){
    if (obj["current_time"] < this._currentTime) return;
    this._unreadCount = obj["count"];
    this._currentTime =  obj["current_time"];
  }

  Map toJson(){
    return {
      "current_time": this._currentTime,
      "unread_count": this._unreadCount
    };
  }
}

class DataMentionUser{
  List<MentionUser> _data = [];

  int _numberUnseen = 0;

  bool _isFetching = false;

  DataMentionUser(List<MentionUser>? data, int? numberUnseen, bool? isFetching){
    this._data = data ?? [];
    this._numberUnseen = numberUnseen ?? 0;
    this._isFetching = isFetching ?? false;
  }

  List<MentionUser> get data => this._data;

  set data( value) {
    this._data = value;
  }

  get numberUnseen => this._numberUnseen;

  set numberUnseen( value) => this._numberUnseen = value;

  get isFetching => this._isFetching;

  set isFetching( value) => this._isFetching = value;
}

class ConversationMessageData {
  late String statusConversation; //": "created", //["int", "created"]
  late String  conversationId;
  late String? dummyId;
  List<Map> messages = [];
  bool active = true;
  bool isFetching = false;
  bool isFetchingUp = false;
  bool disableLoadDown = false;
  bool disableLoadUp = true;
  bool disableHiveDown = false;
  bool disableHiveUp = false;
  Scheduler queue = Scheduler();
  GroupKey? conversationKey;
  int page = 0;
  int? numberNewMessage;
  int lastCurrentTime = DateTime.now().microsecondsSinceEpoch;
  int latestCurrentTime = DateTime.now().microsecondsSinceEpoch;
  String insertedAt = DateTime.now().toString();
  String lastMessageReaded = "";
  List<DataInfoThreadConv> dataUnreadThread = <DataInfoThreadConv>[];

  ConversationMessageData(
    String statusConversation, String conversationId, bool? active, String? dummyId,
    bool? isFetching, bool? isFetchingUp, bool? disableLoadDown, bool? disableLoadUp,
    bool? disableHiveDown, bool? disableHiveUp, GroupKey? conversationKey, int? numberNewMessage,
    int? lastCurrentTime, int? latestCurrentTime, String? insertedAt, String? lastMessageReaded,
    List<Map> messages, List<DataInfoThreadConv> dataUnreadThread
   ){
    this.statusConversation = statusConversation;
    this.conversationId = conversationId;
    this.dummyId = dummyId;
    this.active =  active ?? this.active;
    this.isFetching = isFetching ?? this.isFetching;
    this.isFetchingUp = isFetchingUp ?? this.isFetchingUp;
    this.disableLoadDown = disableLoadDown ?? this.disableLoadDown;
    this.disableLoadUp = disableLoadUp ?? this.disableLoadUp;
    this.disableHiveDown = disableHiveDown ?? this.disableHiveDown;
    this.disableHiveUp = disableHiveUp ?? this.disableHiveUp;
    this.conversationKey = conversationKey ?? this.conversationKey;
    this.numberNewMessage = numberNewMessage;
    this.lastCurrentTime = lastCurrentTime ?? this.lastCurrentTime;
    this.latestCurrentTime = latestCurrentTime ?? this.latestCurrentTime;
    this.insertedAt = insertedAt ?? this.insertedAt;
    this.lastMessageReaded = lastMessageReaded ?? this.lastMessageReaded;
    this.messages = messages;
    this.dataUnreadThread = dataUnreadThread;
  }

  static ConversationMessageData parseFromJson(Map obj){
    return ConversationMessageData(
      obj["status_conversation"] ?? "created",
      obj["conversation_id"] ?? "",
      obj["active"],
      obj["dummy_id"],
      obj["is_fetching"],
      obj["is_fetching_up"],
      obj["disable_load_down"],
      obj["disable_load_up"],
      obj["disable_hive_down"],
      obj["disable_hive_up"],
      obj["conversation_key"],
      obj["number_new_message"],
      obj["last_current_time"],
      obj["latest_current_time"],
      obj["inserted_at"],
      obj["last_message_readed"],
      obj["messages"],
      obj["data_unread_thread"]
    );
  }

  Map toJson(){
    return {
      "status_conversation": this.statusConversation,
      "conversation_key": this.conversationKey?.toJson(),
      "conversation_id": this.conversationId,
      "dummy_id": this.dummyId,
      "inserted_at": this.insertedAt
    };
  }
}

class DirectMessage with ChangeNotifier {
  var _selectedId;
  List<DirectModel> _data = [];
  bool _fetching = false;
  dynamic _socket;
  dynamic _channel;
  List _dataMessage = [];
  List _messagesDirect = [];
  bool _isFetching = false;
  DirectModel _directMessageSelected = DirectModel(
      "",
      [],
      "",
      false,
      0,
      {}, false,
      0,
      {},
      "", null,
      DateTime.now().toString()
    );
  var _lengthData;
  List<ConversationMessageData> dataDMMessages = [];
  bool _selectedFriend = true;
  var _pairKey;
  bool _showDirectSetting = false;
  var _errorCode;
  bool _isLogoutDevice = false;
  Scheduler queueReGetDataDiectMessage =  Scheduler();
  DataMentionUser _dataMentionConversations = new DataMentionUser([], 0, false);
  bool _selectedMentionDM =  false;
  var _idMessageToJump;
  List _deviceCanCreateOtp = [];
  Map dataUnreadMessage = {};
  Map<String, DataInfoThreadConv> dataInfoThreadMessage = {};
  int _page = 0;
  int _limit = 20;
  bool disableCallApiLoadDirect = false;
  NumberUnreadConversation _unreadConversation = NumberUnreadConversation(0, 0);


  Map<String, List<ReactionMessageUser>> reactionMessageDMs = {};
  StreamController<Map<String, List<ReactionMessageUser>>> reactionMessageDMStream = StreamController<Map<String, List<ReactionMessageUser>>>.broadcast();

  @override
  void dispose() {
    reactionMessageDMStream.close();
    super.dispose();
  }


  // statusConversation = "init" la tao dummy cho hoi thoai, cho tao hoi thoai
  Map defaultConversationMessageData = {
    "status_conversation": "created", //["int", "created"]
    "conversation_id": "",
    "messages": <Map>[],
    "active": true,
    "is_fetching": false,
    "is_fetching_up": false,
    // "disableLoad": true,
    "disable_load_down": false,
    "disable_load_up": true,
    "disable_hive_down": false,
    "disable_hive_up": false,
    "queue": null,
    "conversation_key": null,
    "page": 0,
    "number_new_message": null,
    "last_current_time": DateTime.now().microsecondsSinceEpoch,
    "latest_current_time": DateTime.now().microsecondsSinceEpoch,
    "dataRender": [],
    "inserted_at": DateTime.now().toString(),
    "last_message_readed": null,
    "data_unread_thread": <DataInfoThreadConv>[]
  };

  NumberUnreadConversation get unreadConversation => _unreadConversation;

  bool get selectedMentionDM => _selectedMentionDM;

  DataMentionUser get dataMentionConversations => _dataMentionConversations;

  List get data => _data;

  String get selectedId => _selectedId;

  dynamic get socket => _socket;

  bool get fetching => _fetching;

  bool get isFetching => _isFetching;

  dynamic get channel => _channel;

  List get dataMessage => _dataMessage;

  List get messagesData => _messagesDirect;

  dynamic get pairKey => _pairKey;

  DirectModel get directMessageSelected => _directMessageSelected;

  int get lengthData => _lengthData;

  bool get selectedFriend => _selectedFriend;

  bool get showDirectSetting => _showDirectSetting;

  dynamic get errorCode =>  _errorCode;

  dynamic get idMessageToJump =>  _idMessageToJump;

  bool get isLogoutDevice => _isLogoutDevice;

  openDirectSetting(value) async {
    _showDirectSetting = value;
    var box = await Hive.openBox('drafts');
    box.put('openSetting', value);
    notifyListeners();
  }

  onChangeSelectedFriend(value) {
    _selectedMentionDM = false;
    _selectedFriend = value;
    notifyListeners();
  }
  onChangeProfileFriend(data){
    if(_directMessageSelected.id != ""){
      _directMessageSelected.user.map((e){
        if(e["user_id"] == data["user_id"]){
          e["avatar_url"] = data["avatar_url"];
          e["full_name"] = data["full_name"];
        }
        return e;
      }).toList();
    }
    notifyListeners();
  }
  // flow moi tao hoi thoai
  setSelectedDM(DirectModel dm, token, {bool isCreate = false}) async {
    // tat ca tao hoi thoai deu tao dummy truoc
    // chi that su tao khi gui tin nhan dau tien
    // isCreate dung de check truong hojp tao
    // neu chon 1 hoi thoai da co thif dm.id luoon luoon co gia tri, tao hoi thoai thi = ""
    var indexConv = -1;
    String conversationDummy = MessageConversationServices.shaString(dm.user.map((e) => e["user_id"]).toList());
    if (dm.id == ""){
      indexConv = _data.indexWhere((ele) {
        return MessageConversationServices.shaString((ele.user).map((e) => e["user_id"]).toList()) == MessageConversationServices.shaString(dm.user.map((e) => e["user_id"]).toSet().toList());
      });
      // hoi thoai group co the tao trung
      if ((dm.user.length > 2) && isCreate) {
        // co gang tim xem da co hoi thoai dummy hay chua, neu chua co thi tao moi, neu co roi thi dung cai cu
        indexConv = _data.indexWhere((element) => !Utils.checkedTypeEmpty(element.id) && element.id == conversationDummy);
      }
    } else {
      indexConv = _data.indexWhere((element) => element.id == dm.id);
    }
    if (indexConv != -1) dm = _data[indexConv];
    else {
      // neu select 1 hoi thoai chua co (dummy hoi thoai) can set lai 1 id, (thuong la hash id cac thanh vien)
      // them luon vao _dataMessage voi khoi taoj conversationKey = GroupKey();
      // se ban kem id gia luc tao nen va update lai khi tao thanh cong
      var dataConversationDummy = {
        ...defaultConversationMessageData,
        "conversation_id": conversationDummy,
        "conversation_key": GroupKey([], conversationDummy),
        "status_conversation": "init",
        "messages": [{
          ...MessageConversationServices.getHeaderMessageConversation(),
          "inserted_at": DateTime.now().toUtc().toString(),
          "current_time":  DateTime.now().toUtc().microsecondsSinceEpoch,
        }],
        "queue": Scheduler()
      };
      var indexDMDataMessage = dataDMMessages.indexWhere((element) => element.conversationId == conversationDummy);
      if (indexDMDataMessage == -1){
        dataDMMessages = dataDMMessages + [ConversationMessageData.parseFromJson(dataConversationDummy)];
      }
      dm.id = conversationDummy;
      dm.userRead = {
        "current_time": DateTime.now().microsecondsSinceEpoch
      };
    }
    var directId = dm.id;
    if (directId != "") {
      // mỗi khhi chon lai dm, cap nhat lai lastCurrentTime
      ConversationMessageData? currentMesssageData = getCurrentDataDMMessage(directId);
      if (currentMesssageData != null && currentMesssageData.numberNewMessage == null) {
        currentMesssageData.lastCurrentTime = DateTime.now().microsecondsSinceEpoch;
        currentMesssageData.disableHiveDown = false;
        currentMesssageData.disableLoadDown = false;
      }
      List<DirectModel> newData = List.from(_data);
      int index = newData.indexWhere((e) => e.id == dm.id);

      if (index != -1) {
        newData[index].seen = true;
        newData[index].newMessageCount = 0;
        newData[index].archive = dm.archive;
        _data = newData;
      } else {
        dm.name = dm.name;
        dm.displayName = Utils.checkedTypeEmpty(dm.displayName) ? dm.displayName :getNameDM(dm.user, "", dm.name, hasIsYou: false);
        _data = [dm] + _data;
      }
      var boxSelect = await  Hive.openBox('lastSelected');
      boxSelect.put("lastConversationId", directId);
      // boxSelect.put("isChannel", 1);
      var box = Hive.box('direct');
      var listKey = box.keys.toList();
      for (var i = 0; i < listKey.length; i++) {
        DirectModel dm = box.get(listKey[i]);
        if (dm.id == directId) {
          box.put(listKey[i],DirectModel(
            dm.id,
            dm.user,
            dm.name,
            true,
            0,
            dm.snippet,
            dm.archive,
            dm.updateByMessageTime,
            dm.userRead,
            dm.displayName,
            dm.avatarUrl,
            dm.insertedAt
          ));
        }
      }
    }

    _directMessageSelected = dm;
    _messagesDirect = [];
    _lengthData = null;
    _selectedFriend = false;
    _selectedMentionDM = false;
    notifyListeners();
  }

  setDirectMessage(DirectModel dm, token) async{
    var directId = dm.id;
    if (directId != "") {
      List<DirectModel> newData = List.from(_data);
      int index = newData.indexWhere((e) => e.id == dm.id);

      if (index != -1) {
        newData[index].newMessageCount = 0;
        newData[index].archive = dm.archive;
        _data = newData;
      }
      var box = Hive.box('direct');
      var listKey = box.keys.toList();
      for (var i = 0; i < listKey.length; i++) {
        DirectModel dm = box.get(listKey[i]);
        if (dm.id == directId) {
          box.put(listKey[i],DirectModel(
            dm.id,
            dm.user,
            dm.name,
            true,
            0,
            dm.snippet,
            dm.archive,
            dm.updateByMessageTime,
            dm.userRead,
            dm.displayName,
            dm.avatarUrl,
            dm.insertedAt
          )).then((value){
            // print("${dm.id} ${dm.archive}");
          });
        }
      }
    }

    _messagesDirect = [];
    _lengthData = null;
    _selectedFriend = false;
    _selectedMentionDM = false;
    notifyListeners();
  }

// co 2 flow tao dm
// ----- tao qua modal (modal create dm)
//      + tao moi binh thuong,
// ----- tao qua dummy direct
//      + dummy dm se co san id, vi the khi tao moi, can cap nhat lai dummy do
// data = {
//   "users": [""],
//   "name": "",
//   "dummy_id": ""(truong nay danh cho truong hoop dummy)
// };
  Future<dynamic> createDirectMessage(String token, Map data, context, String currentUserId) async {
    LazyBox box  = Hive.lazyBox('pairkey');
    final url = "${Utils.apiUrl}direct_messages/create?token=$token&device_id=${await box.get('deviceId')}";
    try {
      final response = await Dio().post(url, data: {
        "data" : await Utils.encryptServer({
          ...data,
          "users": data["users"].map((u) => u["user_id"]).toList()
        })
      });
      var res = response.data;
      if (res["success"]) {
        // reload direct message
        var dm  = DirectModel(res["conversation_id"], data["users"], data["name"] ?? "", true, 0, {}, false, 0, {}, data["display_name"] ?? "", data["avatar_url"], DateTime.now().toString());
        // tu dong chon hoi thpai do luon
        _directMessageSelected = dm;
        if (!Utils.checkedTypeEmpty(data["isDesktop"])){
          if (context != null) Navigator.pop(context);
        }
        await MessageConversationServices.insertMessageHeader(dm, DateTime.now().toString());
        // notifyListeners();
        if (data["dummy_id"] != null) {
          var indexData = _data.indexWhere((element) => element.id == data["dummy_id"]);
          if (indexData != -1){
            _data[indexData] = dm;
          }
          setSelectedDM(dm, token);

          var indexDummy = dataDMMessages.indexWhere((element) => element.conversationId == data["dummy_id"]);
          if (indexDummy != -1){
            dataDMMessages[indexDummy].conversationId = dm.id;
            dataDMMessages[indexDummy].statusConversation = "created";
            dataDMMessages[indexDummy].dummyId = data["dummy_id"];
          }
        } else {
          _data = [dm] + _data;
        }
        await getDataDirectMessage(token, currentUserId, isReset: true, forceLoad: true);
        return res["conversation_id"];
      }
      // trong truong hojp gui y/c tao conversation 1-1, ma da ton tai,thi chon conv do luon
      if (res["data"] != null ){
        Map resDM = res["data"];
        if (resDM["conversation_id"] != null){
          await getInfoDirectMessage(token, resDM["conversation_id"], forceLoad: true);
        }

        notifyListeners();

      } else {
        var indexDummy = dataDMMessages.indexWhere((element) => element.conversationId == data["dummy_id"]);
        if (indexDummy != -1){
          dataDMMessages[indexDummy].statusConversation = "init";
        }
      }
    } catch (e, t) {
      print("createDirectMessage, $e, $t");
      // sl.get<Auth>().showErrorDialog(e.toString());
    }
  }


  // message from direct_message
  // truong hop numberNewMessage != null thi se ko cap nhat vao Provider, them moi vao issar;
  onDirectMessage(List data, String userId, bool insertHive, bool isDecrypted, String token, context, {bool isInMessageView = true}) async {
    // giai ma tin nhan
    try {
      for(var i =0; i< data.length; i++){
        var indexDM  =  _data.indexWhere((element) {
          DirectModel y = element;
          return y.id == data[i]["conversation_id"];
        });
        if (indexDM == -1){
          var hasInfoDM = await getInfoDirectMessage(token, data[i]["conversation_id"]);
          if (hasInfoDM){
            onDirectMessage([data[i]],  userId, insertHive, isDecrypted, token, context, isInMessageView: isInMessageView);
            continue;
          } else {
            continue;
          }
        }
        DirectModel dm =  _data[indexDM];
        setHideConversation(dm.id, false, context);

        var dataConverstionCurrent = getCurrentDataDMMessage(data[i]["conversation_id"]);
        if (dataConverstionCurrent != null ){
          var dataM = data[i];
          if (!isDecrypted){
            var convKey = dataConverstionCurrent.conversationKey;
            var da = convKey!.decryptMessage(dataM);
            if (Utils.checkedTypeEmpty(data[i]["is_system_message"])){
              da = {
                "success": true,
                "message": data[i]
              };
            }
            if (!da["success"]) continue;
            dataM  = Utils.mergeMaps([dataM, da["message"]]);
          }
          if (dataM["action"] == "reaction") {
            if (insertHive) return DirectMessageController.handleReactionMessageDM(dataM);
            return;
          }

          // save on Hive
          if (insertHive){
            // update snippet + user_read
            List successIds = await MessageConversationServices.insertOrUpdateMessage(dm, dataM);
            updateSnippet(dataM);
            // danh dau da doc neu dang trong conversation do
            if (_directMessageSelected.id != "" && _directMessageSelected.id == dataM["conversation_id"] && token != "" && isInMessageView){
              markReadConversationV2(token, dataM["conversation_id"], successIds as List<String>, [], true);
              // markReadConversation(token, dataM["conversation_id"], lastId: data[i]["id"]);
            } else markReadConversationV2(token, dataM["conversation_id"], successIds as List<String>, [], false);
          }

          // sort direct_message

          // danh dau la da doc tin nhan khi tin nhan la cua minh hoac dang trong view tin nhan do
          dm.seen = (dataM["user_id"] == userId) || (_directMessageSelected.id == dataM["conversation_id"] && isInMessageView);
          var newIndex = _data.indexWhere((element) => element.id == dm.id);
          if (newIndex != -1){
            _data.removeAt(indexDM);
            _data.insert(0, dm);
          }

          // ktra new_id_message
          markNewMessage(dataM, context);
          // cap nhat vao provider
          // ktra numberNewMessage != null
          if (dataM["data_read"] != null)
            updateListReadConversation(dm.id, dataM["data_read"], userId);
          if (dataConverstionCurrent.numberNewMessage == null){
            List dataConversationCurrentMessage = dataConverstionCurrent.messages;
            var indexFakeId = dataConversationCurrentMessage.indexWhere((element) => (element["fake_id"] != null) && (element["fake_id"] == data[i]["fake_id"]));
            if (indexFakeId != -1) {
              dataConverstionCurrent.messages[indexFakeId]= Utils.mergeMaps([
                dataConverstionCurrent.messages[indexFakeId],
                dataM,
                {"isBlur": false, "success": true, "sending": false},
              ]);
            } else {
              dataConverstionCurrent.messages = uniqById([dataM] + dataConverstionCurrent.messages) as List<Map>;
            }

            dataConverstionCurrent.messages = sortMessagesByDay(uniqById(dataConverstionCurrent.messages), dm);
          } else {
           dataConverstionCurrent.numberNewMessage = (dataConverstionCurrent.numberNewMessage ?? 0) + 1;
          }
        }
      }
      notifyListeners();
    } catch (e, t) {
      print("_____ $e $t");
    }
  }

  // defau;t get from Hive, api will overrirde
  setData(List data, {String currentUserId = ""}) async {
    try {
      LazyBox boxKey = Hive.lazyBox("pairKey");
      // loc nhung direact message cua nguoi dung
      Map keys = {};
      List<DirectModel> uniq = [];
      for(var i in data){
        if (keys[i.id] == null) {
          keys[i.id] = true;
          uniq += [i];
        }
      }

      uniq = uniq.where((element) => element.user.indexWhere((ele) => ele["user_id"] == currentUserId) != -1).toList();
      uniq.sort((a, b) => (b.userRead["current_time"] ?? 0).compareTo(a.userRead["current_time"] ?? 0));
      _data = uniq.sublist(0, uniq.length > _limit ? _limit : uniq.length);

      dataDMMessages = await Future.wait(
        _data.map((d) async {
        // print("d.snippet    ${d.snippet} ${d.name}");
          return ConversationMessageData.parseFromJson({
            ...defaultConversationMessageData,
            "conversation_id": d.id,
            "inserted_at": d.insertedAt ?? DateTime.now().toString(),
            "queue": Scheduler(),
            "active": false,
            "conversation_key": GroupKey.parseFromJson(await boxKey.get(d.id)),
            "data_unread_thread": <DataInfoThreadConv>[]
          });
        })
      );
      var box = Hive.box("lastSelected");
      var idSelected = box.get("lastConversationId");
      var indexSelected  =  _data.indexWhere((element) => element.id == idSelected);
      if (indexSelected != -1) _directMessageSelected = _data[indexSelected];
      // notifyListeners();      
    } catch (e, t) {
      print("kkkkkkk$e, $t");
    }
    
  }

  Future saveDataFromDirectMessage(message, userId) async {
    try {
      DirectModel? dm = getModelConversation(message["conversation_id"]);
      if (dm != null) await MessageConversationServices.insertOrUpdateMessage(dm, message);
    } catch (e) {
      print(e);
    }
  }


  Future<List<Map>> processDataDirectMessage(List dataSource, String token) async {
    var direct = Hive.box('direct');
    return await Future.wait((dataSource).map((conv) async {
      var currentUserId = conv["current_user"];
      var local  = direct.get(conv["conversation_id"]);
      var snippet = local == null ? {} : local.snippet;
      // if ("I0egkXE4AYHxNdQV3uZKzApuLOLJSbtfZOFe7BzyOmU=" == conv["conversation_id"]) print("snippet: ${snippet}");
      if ((snippet as Map).isEmpty){
        var lastMessage = await MessageConversationServices.getLastMessageOfConversation(conv["conversation_id"], isCheckHasDM: false);
        if (lastMessage != null) snippet = lastMessage;
      }
      DirectModel dm  = DirectModel(
        conv["conversation_id"],
        conv["user"],
        conv["name"] ?? "",
        conv["seen"],
        conv["new_message_count"],
        snippet,
        conv["is_hide"] ?? false,
        conv["update_by_message"],
        conv["user_read"],
        getNameDM(conv["user"], currentUserId, conv["name"] ?? ""),
        conv['avatar_url'],
        conv['inserted_at']
      );
      dm..displayName = dm.getNameDM(currentUserId);
      int deleteTime = dm.getDeleteTime(currentUserId);
      if ((dm.snippet["current_time"] ?? 0 ) <= deleteTime) dm.snippet = {};
      if (conv["need_broadcast"]) {
        await dm.broadcastSharedKey(currentUserId, token);
        // sau khi broadcast xong can phai goij lai api
        return {
          "need_reload": true
        };
      }
      if (conv["update_by_message"] > (dm.snippet["current_time"] ?? 0)){
        await dm.updateSnippetLast();
      }
      if (dm.id == _directMessageSelected.id){
        _directMessageSelected = dm;
      }

      await MessageConversationServices.insertMessageHeader(
        dm, 
        deleteTime != 0 
          ? DateTime.fromMicrosecondsSinceEpoch(dm.getDeleteTime(currentUserId)).toString() 
          : DateTime.parse(conv['inserted_at']).add(Duration(hours: 7)).toString()
      );
      var indexMessageData = dataDMMessages.indexWhere((element) => element.conversationId == dm.id);
      var currentDataMessageConv = indexMessageData == -1 ? null : dataDMMessages[indexMessageData];
      if (conv["conversation_id"] == "138a37bf-b69d-40de-8d61-30cd3656d53f") print(",,,,,,,,,,${await dm.getConversationKey(currentUserId, token, conv["type"])}");
      return {
        "need_reload": false,
        "dm": dm,
        "data_message_conversation": {
          ...defaultConversationMessageData,
          "conversation_id": dm.id,
          "messages": currentDataMessageConv == null ? <Map>[] : currentDataMessageConv.messages,
          "active": false,
          "queue": currentDataMessageConv == null ? Scheduler() : currentDataMessageConv.queue,
          "type": conv["type"],
          "conversation_key": await dm.getConversationKey(currentUserId, token, conv["type"]),
          "inserted_at": conv["inserted_at"],
          "dummy_id": currentDataMessageConv == null ? null : currentDataMessageConv.dummyId,
          "data_unread_thread": (conv["data_unread_thread"] ?? []).map<DataInfoThreadConv?>((e) => DataInfoThreadConv.fromJson(e)).whereType<DataInfoThreadConv>().toList()
        }
      };
    }));
  }

  // ham nay goi de lay data tren server
  // trong truong howp pass qua plug, luon luon tra ve data[] (chua thong tin ve hoi thoai support luon tra cho moi truong ready_to_use = false)
  Future getDataDirectMessage(token, String currentUserId, {bool isReset = false, bool isLoadMore = false, bool forceLoad = false, bool hasCheckInViewMessage = false}) async {
    if (_fetching && !forceLoad) return;
    var nextPage = _page;
    if (isLoadMore) nextPage = nextPage + 1;
    if (isReset || forceLoad){
      disableCallApiLoadDirect = false;
      nextPage = 0;
    }

    if (disableCallApiLoadDirect) return;
    _errorCode =  null;
    _fetching = true;
    notifyListeners();
    var box = Hive.lazyBox('pairKey');
    Map signedKey =  await box.get("signedKey");
    var lastSelected = Hive.box('lastSelected');
    var currentId = _directMessageSelected.id != "" ? _directMessageSelected.id : lastSelected.get('lastConversationId');
    // checkReSendMessageError(token);
    final url = Utils.apiUrl + 'direct_messages/v2?token=$token&device_id=${await Utils.getDeviceId()}&limit=$_limit&page=$nextPage&current_id=$currentId';
    try {
      final response = await Dio().get(url);
      var resData = response.data;
      if (!Utils.checkedTypeEmpty(resData["success"])){
        _fetching = false;
        if ("${resData["error_code"] }"== "200") return Provider.of<Auth>(Utils.globalContext!, listen: false).logout();
        _errorCode = "${resData["error_code"]}";
        _deviceCanCreateOtp = resData["device_can_create_otp"] ?? [];
        notifyListeners();
        var responseData = await Utils.decryptServer(resData["data"]);
        await box.put("id_default_private_key", responseData["data"]["id_default_private_key"]);
        List dataResults = await processDataDirectMessage((responseData["data"] ?? {}) ["data"] ?? [], token);
        await saveDataToProvider(dataResults, isReset);
        if (isReset) removeDirectDeleted(token);
        // checkReSendMessageError(token, onlySupportDM: true);
        return;
      }
      var responseData = await Utils.decryptServer(resData["data"]);
      if (responseData["success"] == false) {
        _errorCode =  responseData["error_code"];
        _fetching = false;
        notifyListeners();
        throw HttpException(responseData["message"]);
      } else {
        // save to db
        if (signedKey["pubKey"] != responseData["data"]["pub_signed_key"]) return Provider.of<Auth>(Utils.globalContext!, listen: false).logout();
        await box.put("id_default_private_key", responseData["data"]["id_default_private_key"]);
        List dataResults = await processDataDirectMessage(responseData["data"]["data"], token);
        _unreadConversation.updateFromObj(responseData["data"]["data_unread"]);
        if (dataResults.where((element) => element["need_reload"]).toList().length > 0) {
          _fetching = false;
          _page = 0;
          disableCallApiLoadDirect = false;
          return await getDataDirectMessage(token, currentUserId, isReset: true);
        }
        int indexCurrent = dataResults.indexWhere((element) => element["dm"] != null && (element["dm"]).id == currentId);
        if (indexCurrent == -1 && Utils.checkedTypeEmpty(currentId)) {
          // _data = _data.where((element) => element.id != currentId).toList();
          // dataDMMessages = dataDMMessages.where((element) => element.conversationId != currentId).toList();
          // _directMessageSelected = _data[0];
          var direct = Hive.box('direct');
          await direct.delete(currentId);
        }
        disableCallApiLoadDirect = dataResults.length == 0;
        _errorCode= null;
        _fetching = false;
        _page = nextPage;
        await saveDataToProvider(dataResults, isReset);
        IsolateMedia.mainSendPort!.send({
          "type": "delete_message_and_media_via_delete_time",
          "data": dataResults.map((e) {
            return {
              "conversation_id": (e["dm"] as DirectModel).id,
              "delete_time": (e["dm"] as DirectModel).getDeleteTime(currentUserId),
            };
          }).toList(),
          "box_reference": IsolateMedia.storeObjectBox!.reference
        });
        getMentionUser(token);
        getDataMessageOnConversationNeed(token, responseData["data"]["data"], currentUserId);
        notifyListeners();
        loadUnreadMessage(token);
        checkCurrentDM(token, currentUserId, hasCheckInViewMessage: hasCheckInViewMessage);
        MessageConversationServices.saveSharedKeyToNative(dataDMMessages);
        ServiceMedia.autoDownloadAttDM();
        if (isReset) removeDirectDeleted(token);
        return;
      }
    } catch (e, trace) {
      print("getDataDirectMessageError: $e  $trace");
      if (e.toString().contains("Failed host lookup")) disableCallApiLoadDirect = true;
      // _data = [];
      _errorCode= null;
      _fetching = false;
      notifyListeners();
      return [];
    }
  }

  Future removeDirectDeleted(String token) async {
    // tai sao co dong code nay?
    // toi da mac 1 sai lam khi da luu hoi thoai chua duoc tao vao trong hive
    // va dieu nay da gay ra hau qua gi? => 1 so hoi thoai ko the tao dc
    // do app da ko goi api tao hoi thoai nua, va 1 khi dc luu lai trong hive, no dc coi la da dc tao
    // .dieu nay that ngo ngan
    // Gio t phai lam gi??????????????????????????????????????????
    // doan code trong try duoi day se xu ly dieu do
    // no se lay het conversation_id cua nguoi dung sau do se xoa nhung hoi thoai bi loi tren
    // NOTE:     trong tuong lai doan nay se dc bo
    // NOTE::::::API nay van se dc giu de khong the search ra tin nhan ko phai cua ma da dc dong bo sang
    // --------------------------------------------------------------------------------------------------------------------------------
    // toi hi vong se ko con ai mac loi nhu t nua

    try {
      var res = await Dio().get("${Utils.apiUrl}direct_messages/list_group_ids?token=$token&device_id=${await Utils.getDeviceId()}&all=true");
      List dataConversationIdExisted = res.data["data"];
      var direct = Hive.box('direct');
      var pairKey = Hive.lazyBox("pairKey");
      await pairKey.put("conversation_ids", dataConversationIdExisted);
      List needDelete = direct.keys.map((e){
        if (dataConversationIdExisted.indexWhere((element) => element == e) == -1) return e;
        return null;
      }).whereType<String>().toList();
      for (var i = 0; i < needDelete.length; i++){
        _data = _data.where((element) => element.id != needDelete[i]).toList();
        dataDMMessages = dataDMMessages.where((element) => element.conversationId != needDelete[i]).toList();
        await direct.delete(needDelete[i]);
        if (_directMessageSelected.id == needDelete[i]) _directMessageSelected = _data[0];
      }
      // save to native 
      await Work.platform.invokeMethod("save_conversation_ids", "__" + dataConversationIdExisted.join("_") + "__");
    } catch (e, t) {
      print("2345678987ytre: $e, $t");
    }
    try {
      var res = await Dio().get("${Utils.apiUrl}direct_messages/delete_or_leave?token=$token&device_id=${await Utils.getDeviceId()}");
      // List directRemotes = res.data["data"];
      List directRemotes = (await Utils.decryptServer(res.data["data"]))["data"];
      Box direct = Hive.box('direct');
      await direct.deleteAll(directRemotes.map((e) => e["conversation_id"]).toList());
      for (var i = 0; i < directRemotes.length; i++) {
        String convId = directRemotes[i]["conversation_id"];
        _data = _data.where((element) => element.id != convId).toList();
        dataDMMessages =  dataDMMessages.where((ele) => ele.conversationId != convId).toList();
        if (_directMessageSelected.id == convId) _directMessageSelected = _data[0];
      }
      IsolateMedia.mainSendPort!.send({
        "type": "delete_message_and_media_via_delete_time",
        "data": directRemotes,
        "box_reference": IsolateMedia.storeObjectBox!.reference
      });
    } catch (e, t) {
      print("removeDirectDeleted, ${Utils.apiUrl}direct_messages/delete_or_leave?token=$token&device_id=${await Utils.getDeviceId()}, $e, $t");
    }
  }

  saveDataToProvider(List dataResults, bool isReset) async {
    // isReset = false;
    var direct = Hive.box('direct');
    List<DirectModel> data = dataResults.map((e) => e["dm"] as DirectModel).toList();
    List<ConversationMessageData> dataDMMes = dataResults.map((result) {
      Map dataConver =  result["data_message_conversation"];
     
      var indexDataMessageConversations = dataDMMessages.indexWhere((element) => element.conversationId == dataConver["conversation_id"]);
      return ConversationMessageData.parseFromJson({
        ...dataConver,
         "messages": indexDataMessageConversations == -1 ? <Map>[] : dataDMMessages[indexDataMessageConversations].messages
      });
    }).toList();
    // ignore: dead_code
    if (isReset && false){
      await direct.deleteAll(direct.keys);
      _data = data;
      // do tin nhan dc lay tu local truoc khi ca api dc goin hoac bi thay doi trong vong lap ma ko cap nhat lai
      // nen khi lay data Conversation xong thi can phai merge data local tranh bi loop
      // chi merge tin nhan, cac tham so khac set ve mac dinh
      // cac tham so: last_id, latest_id se chi dc set theo gia tri cua api, khong set = dataDMMessages[indexDataMessageConversations]["messages"].last["id"]
      dataDMMessages = dataDMMes;
    } else {
      Map<String, DirectModel> index= {};
      List total = _data + data;
      for (var i=0; i <total.length; i++) {
        index[total[i].id] = total[i];
      }
      _data = index.values.toList();
      _data.sort((DirectModel a, DirectModel b) =>( b.userRead["current_time"] ?? 0).compareTo(a.userRead["current_time"] ?? 0));
      Map<String, ConversationMessageData> indexDMMess= {};
      List<ConversationMessageData> totalDMMes = (dataDMMessages + dataDMMes);
      for (var i=0; i <totalDMMes.length; i++) {
        indexDMMess[totalDMMes[i].conversationId] = totalDMMes[i];
      }
      dataDMMessages = indexDMMess.values.toList();
    }
    await direct.putAll(
      Map.fromIterable(getListCreated(data), key: (v) => v.id, value: (v) => v)
    );
  }

  List<DirectModel> getListCreated(List<DirectModel> data){
    return data.map((e) {
      ConversationMessageData? c = getCurrentDataDMMessage(e.id);
      if (c == null) return null;
      if (c.statusConversation == "created") return e;
      return null;
    }).whereType<DirectModel>().toList();
  }

  checkCurrentDM(String token, String currentUserId, {bool hasCheckInViewMessage = false}){
    try {
      DirectModel? dm = getModelConversation(_directMessageSelected.id);
      if (dm == null){
        _directMessageSelected = _data[0];
        var boxSelect = Hive.box('lastSelected');
        boxSelect.put("lastConversationId", _directMessageSelected.id);
      }
      getMessageFromApi(_directMessageSelected.id, token, true, null, currentUserId, isNotiffy: false, hasCheckInViewMessage: hasCheckInViewMessage);
    } catch (e) {
    }
  }

//
  Future<bool> getInfoDirectMessage(String token, String conversationId, {bool forceLoad = false}) async {
    try {
      var indexD = _data.indexWhere((element) => element.id == conversationId);
      if (indexD != -1 && !forceLoad) return true;
      final url = "${Utils.apiUrl}direct_messages/$conversationId?token=$token&device_id=${await Utils.getDeviceId()}";
      var response = await Dio().get(url);
      var resData  = response.data;
      if (!resData["success"]) return false;
      var responseData = await Utils.decryptServer(resData["data"]);
      List<Map> dataResults = await processDataDirectMessage(responseData["data"]["data"], token);
      if (dataResults.length == 0) return false;
      if (dataResults.where((element) => element["need_reload"]).toList().length > 0) return getInfoDirectMessage(token, conversationId);
      List<DirectModel> data = dataResults.map((e) => e["dm"] as DirectModel).toList();
      Map<String, DirectModel> index  = {};
      List total = _data + data;
      for (var i=0; i <total.length; i++) {
        if (index[total[i].id] == null) index[total[i].id] = total[i];
      }
      _data = index.values.toList();
      var direct = Hive.box('direct');
      await direct.putAll(
        Map.fromIterable(getListCreated(data), key: (v) => v.id, value: (v) => v)
      );
      dataDMMessages =(Map.fromIterable(dataDMMessages + dataResults.map((result) => ConversationMessageData.parseFromJson(result["data_message_conversation"])).toList(), key: (v) => v.conversationId, value: (v) => v as ConversationMessageData)).values.toList();
      MessageConversationServices.saveSharedKeyToNative(dataDMMessages);
      notifyListeners();
      return true;

    } catch (e, t) {
      print("getInfoDirectMessage: $e $t");
      return false;
    }

  }


  void mergeMessagesExisted(List<Map> dataSource) {
    dataDMMessages = dataSource.map((result) {
      ConversationMessageData dataConver =  result["data_message_conversation"];
      var indexDataMessageConversations = dataDMMessages.indexWhere((element) => element.conversationId == dataConver.conversationId);
      dataConver.messages = indexDataMessageConversations == -1 ? [] : dataDMMessages[indexDataMessageConversations].messages;
      return dataConver;
    }).toList();
  }

  Future getDataMessageOnConversationNeed(String token, List dataSource, String currentUserId) async {
    List listConverIdNeedGetMessage = dataSource.map((e) {
      if (e["new_message_count"] > 0) return e["conversation_id"];
      var index = _data.indexWhere((element) => element.id  == e["conversation_id"]);
      if (index == -1) return e["conversation_id"];
      return ((_data[index]).userRead["current_time"] ?? 0) == e["update_by_message"] ? null : e["conversation_id"];
    }).where((element) => element != null).toList();
    return await Future.wait(listConverIdNeedGetMessage.map((r) async {
      await getMessageFromApi(r, token, true, null, currentUserId, isNotiffy: false);
    }));
  }

  updateListReadConversation(String conversationId, Map dataUser, String userId){
    // dataUser  = {
    //   current_time: int  => thoi gian cua tin nhan cuoi cung,
    //   last_user_id_send_message: string => user_id cuar nguoi nhan tin cuoi cung
    //   user_id: string  =>  user_id cuar nguoi doc tin nhan cuoi cung
    // }
    var indexConversation = _data.indexWhere((element) => element.id == conversationId);
    if (indexConversation != -1){
      // neu currentTime > currentTime hien taij  => thay the  =  data moi
      if ((_data[indexConversation].userRead["current_time"] ?? 0) < dataUser["current_time"])
        _data[indexConversation].userRead = {
          "current_time": dataUser["current_time"],
          "last_user_id_send_message": dataUser["last_user_id_send_message"],
          "data": [dataUser["user_id"]]
        };
        // update hive
      // neu currentTime == currentTime hien taij  => then user_id moiws vafo
      else if (_data[indexConversation].userRead["currentTime"] == dataUser["currentTime"])
        _data[indexConversation].userRead["data"] =  ([] + _data[indexConversation].userRead["data"] + [dataUser["user_id"]]).toSet().toList();

      else {}
      var box  = Hive.box("direct");
      box.put(_data[indexConversation].id, _data[indexConversation]);

      // no thing
      notifyListeners();
    }
  }

  List<Map> sortMessagesByDay(List messages, DirectModel dm) {
    return MessageConversationServices.sortMessagesByDay(messages, dm);
  }

  updateDirectMessage(Map dataMessage, updateHive, _fromApi, isDecrypted, {int retryTime = 50, String? token}) async {
    // print(dataMessage["id"] + "___________" + "$retryTime");
    if (retryTime == 0) return;
    try {
      DirectModel? dm = getModelConversation(dataMessage["conversation_id"]);
      var currentDataDMMessage = getCurrentDataDMMessage(dataMessage["conversation_id"]);
      if (currentDataDMMessage == null || dm == null) {
        var hasInfoDM = await getInfoDirectMessage(token!, dataMessage["conversation_id"]);
        if (hasInfoDM){
          return updateDirectMessage(dataMessage,  updateHive, _fromApi, isDecrypted, token: token);
        }
        return;
      }


      ConversationMessageData dataConverstionCurrent = currentDataDMMessage;
      if (dataConverstionCurrent.conversationKey == null) return throw {};
      var dataM  = dataMessage;
      // print(">>>>>>> $dataM");
      if (!isDecrypted){
         var messageDe = dataConverstionCurrent.conversationKey?.decryptMessage(dataMessage);

        // ket thuc neu giai ma sai
        if (!messageDe!["success"]) return;
        dataM = messageDe["message"];
      }
      // update on Hive
      if (updateHive){
        List successIds = await MessageConversationServices.insertOrUpdateMessage(dm, dataM, type: "update");
        if (token != null)
          markReadConversationV2(token, dataMessage["conversation_id"], successIds as List<String>, [], true);
      }
      // upd""ate onProvider
      List<Map> dataConversationCurrentMessage = dataConverstionCurrent.messages;
      int indexCurrentMessage  =  dataConversationCurrentMessage.indexWhere((element) => element["id"] == dataM["id"]);
      if (indexCurrentMessage != -1 && Utils.checkedTypeEmpty(dataM["id"])){
        dataConversationCurrentMessage[indexCurrentMessage] = Utils.mergeMaps([
          dataConversationCurrentMessage[indexCurrentMessage],
          dataM,
          {"status_decrypted": "success",}
        ]);
      }
      else {
        // update by fake_id
        int indexCurrentMessageFake  =  dataConversationCurrentMessage.indexWhere((element) => element["fake_id"] == dataM["fake_id"]);
        if (indexCurrentMessageFake != -1 && Utils.checkedTypeEmpty(dataM["fake_id"])){
          dataConversationCurrentMessage[indexCurrentMessageFake] = Utils.mergeMaps([
            dataConversationCurrentMessage[indexCurrentMessageFake],
            dataM,
            {"status_decrypted": "success",}
          ]);
        }
      }

      if (isDecrypted){
        dataConverstionCurrent.messages = sortMessagesByDay(uniqById(dataConverstionCurrent.messages), dm);
      }

      notifyListeners();
    } catch (e) {
      // print("fdbfndskfbdsf______$dataMessage");
      await Future.delayed(Duration(seconds: 5));
      return updateDirectMessage(dataMessage, updateHive, _fromApi, isDecrypted, retryTime: retryTime -1);
    }
  }

  void updateCountChildMessage(dataM, String token) async{
    for (var i = 0; i< dataM.length; i++){
      Map dataMessage = dataM[i];
      var currentDataMessageConversation = getCurrentDataDMMessage(dataMessage["conversation_id"]);
      if (currentDataMessageConversation != null){
        var dataDe = currentDataMessageConversation.conversationKey!.decryptMessage(dataMessage);
        if (dataDe["success"])
          dataMessage = dataDe["message"];
        else continue;
        if (dataMessage["action"] == "reaction") continue;
        List<Map> dataConversationCurrentMessage = currentDataMessageConversation.messages;
        int indexCurrentMessage  =  dataConversationCurrentMessage.indexWhere((element) => element["id"] == dataMessage["parent_id"]);
        if (indexCurrentMessage != -1){
          dataConversationCurrentMessage[indexCurrentMessage]["count"] = dataConversationCurrentMessage[indexCurrentMessage]["count"] == null ? 0 :  (dataConversationCurrentMessage[indexCurrentMessage]["count"]+ 1);
          final newUser = {
            "user_id": dataMessage["user_id"],
            "inserted_at": dataMessage["inserted_at"],
            "avatar_url": dataMessage["avatar_url"],
            "full_name": dataMessage["full_name"],
          };
          if (dataConversationCurrentMessage[indexCurrentMessage]["info_thread"] != null) {
            dataConversationCurrentMessage[indexCurrentMessage]["info_thread"] = [] + [newUser] + dataConversationCurrentMessage[indexCurrentMessage]["info_thread"];
          } else {
            dataConversationCurrentMessage[indexCurrentMessage]["info_thread"] = [] + [newUser];
          }
        }
        DirectModel? dm = getModelConversation(dataMessage["conversation_id"]);
        List successIds = dm != null ? await MessageConversationServices.insertOrUpdateMessage(dm, dataMessage) : [];
        markReadConversationV2(token, dataMessage["conversation_id"], successIds as List<String>, [], false);
      }
    }
    notifyListeners();
  }

  getLast(data){
    if (data.length ==0) return  {};
    return data.last;
  }


  getMessageFromApiDown(idDirectMessage, isReset, token, String currentUserId, {int size = 0, bool isNotiffy = false, bool forceCallViaIsolate = false, bool hasCheckInViewMessage = false}) async {
    var currentDataDMMessage = getCurrentDataDMMessage(idDirectMessage);
    DirectModel? dm = getModelConversation(idDirectMessage);
    if (currentDataDMMessage == null || dm == null || currentDataDMMessage.isFetching || currentDataDMMessage.conversationKey== null) return;
    try{
      if (isReset || !currentDataDMMessage.disableLoadDown){
        currentDataDMMessage.isFetching = true;
        if (isNotiffy)
          notifyListeners();
        if (isReset) currentDataDMMessage.lastCurrentTime = DateTime.now().microsecondsSinceEpoch;
        var url = "${Utils.apiUrl}/direct_messages/$idDirectMessage/messages?token=$token&is_desktop=true&device_id=${await Utils.getDeviceId()}&last_current_time=${currentDataDMMessage.lastCurrentTime}";
        if (size != 0 ) url += "&size=$size";
        var response = await Dio().get(url);
        var resData = response.data;
        if (resData["success"]) {
          if (hasCheckInViewMessage && Utils.checkInViewMessage() && resData["data"].length > 0 && currentDataDMMessage.messages.isNotEmpty){
            Map first = currentDataDMMessage.messages.first;
            int numbernewMessage = (resData["data"] as List).where((element) => element["current_time"] >= first["current_time"]).length;
            switch (numbernewMessage) {
              case 0:
                break;
              default:
                currentDataDMMessage.numberNewMessage = numbernewMessage;
                currentDataDMMessage.disableLoadUp = false;
                currentDataDMMessage.disableHiveUp = false;
                currentDataDMMessage.isFetching = false;
                break;
            }
            notifyListeners();
          }
          else {
            processDataMessageFromApi(idDirectMessage, resData["data"], currentDataDMMessage.lastCurrentTime, isReset, dm.getDeleteTime(currentUserId), token: token, hasMark: isNotiffy);}
        } else {
          currentDataDMMessage.isFetching = false;
          notifyListeners();
        }
      }
      if (currentDataDMMessage.disableLoadDown){
        // lay tin nhan dang co trong isar
        await getMessageFromHiveDown(idDirectMessage, currentDataDMMessage.lastCurrentTime, token, currentUserId, forceCallViaIsolate: forceCallViaIsolate);
      }
    } catch (e, t){
      print("gdhfhgjguikyt $e $t");
      // neu loi api thi disableLoadDown = true
      currentDataDMMessage.disableLoadDown = true;
      currentDataDMMessage.isFetching = false;
      notifyListeners();
    }

  }

  getMessageFromHiveUp(idDirectMessage, int rootCurrentTime, String token, String currentUserId, {bool forceLoad = false, int size = 30})async {
    var currentDataDMMessage = getCurrentDataDMMessage(idDirectMessage);
    DirectModel? dm = getModelConversation(idDirectMessage);
    if (dm == null || currentDataDMMessage == null) return;
    if (( Utils.checkedTypeEmpty(currentDataDMMessage.disableHiveUp|| currentDataDMMessage.isFetchingUp)) && !forceLoad ) return;
    currentDataDMMessage.isFetchingUp = true;
    List dataFromIsar = await MessageConversationServices.getMessageUp(idDirectMessage, dm.getDeleteTime(currentUserId), currentTime: rootCurrentTime, parseJson: true, limit: size);
    dataFromIsar = dataFromIsar.map<Map>((e) => e as Map).toList();
    await processDataMessageFromHive(idDirectMessage, dataFromIsar as List<Map>, token, type: "up");
    currentDataDMMessage.isFetchingUp = false;
    notifyListeners();
  }
  // cac truong hop scroll ve qua khu, deu goi via isolate
  // tao sao can goi qua isolate, ly do la neu dang scroll ma await API se lam scroll lag, giat => chuyen het cac tac vu await sang isolate
  // van set  currentDataDMMessage.isFetching = true o main isolate, vi isolate ko the chan dc
  getMessageFromHiveDown(String idDirectMessage, int rootCurrentTime, String token, String currentUserId, {bool isGetIsarBeforeCallApi = false, bool forceLoad = false, bool forceCallViaIsolate = false, int limit = 30}) async {
    // tra ve list data trong Hive,
    // ktra roi them nhung data chua co trong Provider
    // check disable load from Hive
    DirectModel? dm = getModelConversation(idDirectMessage);
    var currentDataDMMessage = getCurrentDataDMMessage(idDirectMessage);
    if ( dm == null || currentDataDMMessage == null) return;
    if ((Utils.checkedTypeEmpty(currentDataDMMessage.disableHiveDown || currentDataDMMessage.isFetching)) && !forceLoad ) return;
    currentDataDMMessage.isFetching = true;
    notifyListeners();
    if (forceCallViaIsolate) {
      return IsolateMedia.mainSendPort!.send({
        "type": "force_load_message_from_hive_down",
        "data": {
          "current_data_dm_message": currentDataDMMessage,
          "dm": dm,
          "root_current_time": rootCurrentTime,
          "current_user_id": currentUserId,
          "is_get_isar_before_call_api": isGetIsarBeforeCallApi,
          "type": "down",
        }
    });}
    // lay tin nhan cuoi cung
    // trong truong hop ko co id cua tin nhan cuoi cung lay tin nhan moi nhat cua hoij thoaij
    List dataFromIsar = await MessageConversationServices.getMessageDown(dm, idDirectMessage,  dm.getDeleteTime(currentUserId), currentTime: rootCurrentTime, parseJson: true);
    // List dataFromIsar = await MessageConversationServices.getMessageDown(dm, idDirectMessage,  dm.getDeleteTime(currentUserId), currentTime: rootCurrentTime, parseJson: true, limit: limit);
    dataFromIsar = dataFromIsar.map<Map>((e) => e as Map).toList();
    // dataFromIsar = dataFromIsar.where((ele) => ele["id"] != (messageLastId == null ? "" : messageLastId["id"] )).toList();// ham nay de fix loi tin 1 tin nhan bi insert nhiefu lan
    await processDataMessageFromHive(idDirectMessage,(rootCurrentTime == 0 ? <Map>[] : dataFromIsar) as List<Map>, token, isGetIsarBeforeCallApi: isGetIsarBeforeCallApi);
    currentDataDMMessage.isFetching = false;
    notifyListeners();
  }

  getMessageFromApiUp(idDirectMessage, token, String currentUserId, {int size = 0}) async {
    var currentDataDMMessage = getCurrentDataDMMessage(idDirectMessage);
    DirectModel? dm = getModelConversation(idDirectMessage);

    if (currentDataDMMessage == null || dm == null || currentDataDMMessage.isFetchingUp || currentDataDMMessage.conversationKey == null) return;
    try {
      if (!currentDataDMMessage.disableLoadUp){
        var url = "${Utils.apiUrl}/direct_messages/$idDirectMessage/messages?token=$token&device_id=${await Utils.getDeviceId()}&latest_current_time=${currentDataDMMessage.latestCurrentTime}";
        currentDataDMMessage.isFetchingUp = true;
        notifyListeners();
        if (size !=0 ) url += "&size=$size";
        var response  = await Dio().get(url);
        var resData = response.data;
        if (resData["success"] && resData["data"].length > 0) {
          processDataMessageFromApi(idDirectMessage, resData["data"], currentDataDMMessage.latestCurrentTime, false, dm.getDeleteTime(currentUserId), token: token, type: "up");
        }
        else {
          if (resData["success"] && resData["data"].length == 0) currentDataDMMessage.numberNewMessage = null;
          currentDataDMMessage.disableLoadUp = true; //
          currentDataDMMessage.isFetchingUp = false;
        }
      } else {
        await getMessageFromHiveUp(idDirectMessage, currentDataDMMessage.latestCurrentTime, token, currentUserId);
      }
    } catch (e) {
       print("getMessageFromApiUp $e");
      // neu loi api thi disableLoadDown = true
      currentDataDMMessage.disableLoadUp = true;
      currentDataDMMessage.isFetchingUp = false;
      notifyListeners();
    }

  }
  // bat buoc chuyen sang isolate de tranh lag app
  resultAfterProcessDataFromApiViaIsolate(List dataMergeLocal, List successIds, List<String> errorIds, Map? messageSnippet, ConversationMessageData currentDataDMMessage, bool hasMark) {
    try {
      String token = Provider.of<Auth>(Utils.globalContext!, listen: false).token;
      // print("resultAfterProcessDataFromApiViaIsolate");
      DirectMessageController.getReactionMessages(dataMergeLocal.map<String>((e) => e["id"]).toList(), currentDataDMMessage.conversationId);
      // markReadConversationV2(token, currentDataDMMessage.conversationId, successIds as List<String>, errorIds, hasMark);
      getLocalPathAtts(dataMergeLocal);
      getInfoUnreadMessage(
        dataMergeLocal,
        token,
        currentDataDMMessage.conversationId
      );
      if (messageSnippet != null) updateSnippet(messageSnippet);
      int indexDM  = dataDMMessages.indexWhere((element) => element.conversationId == currentDataDMMessage.conversationId || (element.dummyId ?? "_____") == currentDataDMMessage.conversationId);
      if (indexDM == -1) return null;
      currentDataDMMessage.messages = currentDataDMMessage.messages + dataDMMessages[indexDM].messages.where((element) => !Utils.checkedTypeEmpty(element["id"])).toList();
      dataDMMessages[indexDM] = currentDataDMMessage;
      notifyListeners();
      if (dataMergeLocal.isEmpty) getMessageFromHiveDown(currentDataDMMessage.conversationId, currentDataDMMessage.lastCurrentTime, token, Provider.of<Auth>(Utils.globalContext!, listen: false).userId, forceCallViaIsolate: true);
    } catch (e, t) {
      print("resultAfterProcessDataFromApiViaIsolate: $e, $t");
    }
    
  }

  processDataMessageFromApi(idDirectMessage,List dataMessage, int rootCurrentTime, isReset, int deleteTime, {String token = "", String type = "down", bool hasMark = true}) async {
    var currentDataDMMessage = getCurrentDataDMMessage(idDirectMessage);
    DirectModel? dm = getModelConversation(idDirectMessage);
    if (currentDataDMMessage == null || dm == null) return;

    IsolateMedia.mainSendPort!.send({
      "type": "process_data_message_from_api_via_isolate",
      "data": {
        "current_data_dm_message": currentDataDMMessage,
        "dm": dm,
        "has_mark": hasMark,
        "is_reset": isReset,
        "token": Provider.of<Auth>(Utils.globalContext!, listen: false).token,
        "root_current_time": rootCurrentTime,
        "type": type,
        "delete_time": deleteTime,
        "data_message": dataMessage,
        "current_user_id": Provider.of<Auth>(Utils.globalContext!, listen: false).userId,
      }
    });
  }

  // ham nay chi dc goi trong processDataMessageFromApi() va onDirectMessage()
  markReadConversationV2(String token, String conversationId, List<String> successIds, List<String> errorIds, bool hasMark) async {
    if (successIds.isEmpty && errorIds.isEmpty && !hasMark) return;
    String url = "${Utils.apiUrl}direct_messages/$conversationId/mark_read_v2?token=$token&device_id=${await Utils.getDeviceId()}&version_api=2";
    Dio().post(url, data: {
      "data": await Utils.encryptServer({
        "version_api": 2,
        "success_ids": successIds,
        "error_ids": errorIds,
        "has_mark": hasMark
      })
    });
  }

  List getMessageErrorSavedOnHive(idConv){
    var boxQueueMessage = Hive.box('queueMessages');
    List messageQueues = boxQueueMessage.values
      .where((ele) => ele["conversation_id"] == idConv)
      .map((e) {return {...e, "current_time": DateTime.now().millisecondsSinceEpoch * 1000};})
      .toList();
    return messageQueues;
  }

  markReadConversation(String token, String conversationId, {String? lastId}){
    String url = "${Utils.apiUrl}direct_messages/$conversationId/mark_read?token=$token";
    try {
      if (lastId == null){
        lastId = getCurrentDataDMMessage(conversationId)?.messages.first["id"];
      }
    } catch (e) {
    }
    url += "&id_message=$lastId";
    Dio().get(url);
  }

  List uniqById(List dataSource){
    return MessageConversationServices.uniqById(dataSource);
  }

  getLocalPathAtts(List messages, {bool forceDownload = false}){
    try {
      List total = messages.map((e){
        ServiceMedia.getAllMediaFromMessageViaIsolate(e, forceDownload: forceDownload);
        MessageConversationServices.checkShareMessageFromDM(e, false);
        if (e["attachments"] is List<Map>) return e["attachments"];
        return <Map>[];
      }).reduce((acc, ele) => acc += ele);
      for (var i = 0; i < total.length; i++){
        var y  = total[i];
        if (Utils.checkedTypeEmpty(y["content_url"])){
          if (!Utils.checkedTypeEmpty(y["key_encrypt"])){
            StreamMediaDownloaded.instance.setStreamOldFileStatus(y["content_url"]);
          } else {
            StreamMediaDownloaded.instance.setStreamDownloadedStatus(y["content_url"]);
          }
        }
      }
    } catch (e, t) {
      print("getLocalPathAtts: $e $t");
    }
  }
  processDataMessageFromHiveViaIsolate(ConversationMessageData d, List<Map> dataFromIsar){
    int indexDM  = dataDMMessages.indexWhere((element) => element.conversationId == d.conversationId || (element.dummyId ?? "_____") == d.conversationId);
    if (indexDM == -1) return null;
    dataDMMessages[indexDM] = d;
    dataDMMessages[indexDM].isFetching = false;
    DirectMessageController.getReactionMessages(dataFromIsar.map<String>((e) => e["id"]).toList(), d.conversationId);
    getInfoUnreadMessage(
      dataFromIsar,
      Provider.of<Auth>(Utils.globalContext!, listen: false).token, 
      d.conversationId
    );
    getLocalPathAtts(dataFromIsar);
    notifyListeners();
  }

  processDataMessageFromHive(idDirectMessage, List<Map> data,  String token, {String type = "down", bool isGetIsarBeforeCallApi = false}){
    var currentDataDMMessage = getCurrentDataDMMessage(idDirectMessage);
    DirectModel? dm = getModelConversation(idDirectMessage);
    try {
      if (currentDataDMMessage == null || dm == null) return;
      // chi tin  nhan chua co moi them
      List<Map> results = data;
      getInfoUnreadMessage(
        results,
        token,
        idDirectMessage
      );

      getLocalPathAtts(data);
      currentDataDMMessage.messages = uniqById(results + currentDataDMMessage.messages) as List<Map>;
      if (!isGetIsarBeforeCallApi) {
        if (type == "down") {
          currentDataDMMessage.disableHiveDown = data.length == 0;
          currentDataDMMessage.lastCurrentTime = currentDataDMMessage.messages.length == 0 ? 0 : ((currentDataDMMessage.messages).last)["current_time"];
        }
        else {
          currentDataDMMessage.disableHiveUp = data.length == 0;
          currentDataDMMessage.latestCurrentTime = currentDataDMMessage.messages.length == 0 ? DateTime.now().microsecondsSinceEpoch : ((currentDataDMMessage.messages).first)["current_time"];
        }
      }

      currentDataDMMessage.messages = sortMessagesByDay(uniqById(currentDataDMMessage.messages), dm);
    } catch (e) {
      currentDataDMMessage!.disableHiveDown = true;
    }
  }

  ConversationMessageData? getCurrentDataDMMessage(idDirectMessage){
    int indexDM  = dataDMMessages.indexWhere((element) => element.conversationId == idDirectMessage || (element.dummyId ?? "_____") == idDirectMessage);
    if (indexDM == -1) return null;
    return dataDMMessages[indexDM];
  }

  getMessageFromApi(idDirectMessage, token, isReset, isLatest, String currentUserId,{bool isNotiffy = true, bool forceCallViaIsolate = false, bool hasCheckInViewMessage = false}) async{
    if (!Utils.checkedTypeEmpty(isLatest) ) return await getMessageFromApiDown(idDirectMessage, isReset, token, currentUserId, isNotiffy: isNotiffy, forceCallViaIsolate: forceCallViaIsolate, hasCheckInViewMessage: hasCheckInViewMessage);
    return await getMessageFromApiUp(idDirectMessage, token, currentUserId);
  }

  resetStatus(token, String currentUserId) {
    try {
      final idDirectMessage = _directMessageSelected.id;
      dataDMMessages = _data.map((d) {
        // get queue of dm
        var index = dataDMMessages.indexWhere((element) => element.conversationId == d.id);
        Scheduler queue = index == -1 ? Scheduler() : dataDMMessages[index].queue;
        String? dummyId =  index == -1 ? null : dataDMMessages[index].dummyId;
        List dataMessageSending = index == -1 ? [] : dataDMMessages[index].messages.where((element) => !Utils.checkedTypeEmpty(element["id"])).toList();
        if (d.id == idDirectMessage) {
          return ConversationMessageData.parseFromJson( {
            ...defaultConversationMessageData,
            "status_conversation": dataDMMessages[index].statusConversation,
            "conversation_id": d.id,
            "messages": sortMessagesByDay(dataDMMessages[index].messages, d),
            "queue": queue,
            "inserted_at": dataDMMessages[index].insertedAt,
            "conversation_key": dataDMMessages[index].conversationKey,
            "dummy_id": dummyId,
            "last_current_time": DateTime.now().microsecondsSinceEpoch,
            "latest_current_time": DateTime.now().microsecondsSinceEpoch,
            "data_unread_thread": dataDMMessages[index].dataUnreadThread
          });
        } else {
          return ConversationMessageData.parseFromJson({
            ...defaultConversationMessageData,
            "messages": dataMessageSending,
            "status_conversation": dataDMMessages[index].statusConversation,
            "conversation_id": d.id,
            "queue": queue,
            "inserted_at": dataDMMessages[index].insertedAt,
            "conversation_key": index == -1 ? null : dataDMMessages[index].conversationKey,
            "dummy_id": dummyId,
            "last_current_time": DateTime.now().microsecondsSinceEpoch,
            "latest_current_time": DateTime.now().microsecondsSinceEpoch,
            "data_unread_thread": dataDMMessages[index].dataUnreadThread
          });
        }
      }).toList();
      if (_directMessageSelected.id != "") getMessageFromApiDown(_directMessageSelected.id, true, token, currentUserId, isNotiffy: false, hasCheckInViewMessage: true);
      notifyListeners();
    } catch (e, t) {
      print("resetStatus: $e, $t");
    }

  }

  saveDataFromDirectMessageDraft(message)async{
    var box = Hive.lazyBox("messageDraft");
    await box.put(message["fake_id"], message);
  }

  handleSendDirectMessage(Map message, token, {bool isSendReaction = false,}) async {
    // var dataMessage = {
    //   "message": _message,
    //   "attachments": [],
    //   "title": "",
    //   "conversation_id": "1252453464ghtry34b645",
    //   "show": true,
    //   "id": "",
    //   "user_id": "fgsdgfdgd",
    //   "time_create": "",
    //   "count": 0,
    //   "sending": true,
    //   "success": true,
    //   "fake_id": fakeId,
    //   "current_time": DateTime.now().millisecondsSinceEpoch * 1000,
    //   "isSend": true,
    //   "isThread": true
    // };

    // truong hop gui tin nhan tu hoi thoai dummy, se goi api tao hoi thoaij truoc(them vafo hang doi dau tien)
    // tin nhan dummy cung se dc them vao luon
    var convId  =  message["conversation_id"];
    var indexDM = dataDMMessages.indexWhere((element) => element.conversationId == convId || convId == (element.dummyId ?? "_____"));
    if (indexDM == -1){
      if (message["from"] == "share") queueBeforeSend(Map.from(message), token, isSendReaction: isSendReaction);
      return;
    }
    var currentDataMessageConversation = dataDMMessages[indexDM];
    if (currentDataMessageConversation.numberNewMessage != null) resetOneConversation(convId);
    // set isBlur khi hang doi !=[], neu == [] ko set(mac dinh la false)
    Scheduler queue  = currentDataMessageConversation.queue;
    if (queue.getLength() != 0) message["isBlur"] = true;
    if (!Utils.checkedTypeEmpty(message["isThread"])){
      if (message["isSend"]){
        await onDirectMessage([message], message["user_id"], false, true, "", null);
      } else {
        await updateDirectMessage(message, false, false, true);
      }
    }

    if (currentDataMessageConversation.statusConversation == "init") {
      currentDataMessageConversation.statusConversation = "creating";
      var indexData = _data.indexWhere((ele) => ele.id == convId);
      queue.schedule(()async { return await createDirectMessage(
        token, {
          "dummy_id": currentDataMessageConversation.conversationId,
          "users": (_data[indexData]).user,
          "name": (_data[indexData]).name,
          "display_name": (_data[indexData]).displayName
        },
        null,
        message["user_id"]
      );});
    }
    queue.schedule(( ) async {return await queueBeforeSend(Map.from(message), token, isSendReaction: isSendReaction);});
  }

  updateIsBlurMessage(Map message){
    // find message
    var convId = message["conversation_id"];
    var fakeId  = message["fake_id"];
    var indexConv  =  dataDMMessages.indexWhere((element) => element.conversationId == convId);
    if (indexConv == -1) return;
    var indexMessage  =  dataDMMessages[indexConv].messages.indexWhere((ele) => ele["fake_id"] == fakeId);
    if (indexMessage == -1) return;
    Map providerMessage  =  dataDMMessages[indexConv].messages[indexMessage];
    // print("providerMessage $providerMessage");
    if (providerMessage["sending"]) {
      providerMessage["isBlur"] = true;
      notifyListeners();
    }
  }

  // neu tin nhan da bi mo, no chi cap nhat lai khi gui thanh cong
  Future queueBeforeSend(Map message, token, {bool isSendReaction = false}) async{
    try {
      LazyBox box  = Hive.lazyBox('pairKey');
      // sau 2s caajp nhaajt giao dien, neu chua gui xong thi cap nhat isBlur.
      if (message["isThread"] != null && !message["isThread"])
        Timer.run(() async{
          await Future.delayed(Duration(seconds: 2));
          updateIsBlurMessage(message);
      });

      // e2eMessagse
      // dam bao tim lai conversation_id doio voi cac tin gui di truoc ca khi hoi thoai dc tao
      var indexConv = dataDMMessages.indexWhere((element) => element.conversationId == message["conversation_id"] || message["conversation_id"] == (element.dummyId ?? "_____"));
      message["conversation_id"] = dataDMMessages[indexConv].conversationId;
      List listMentions =  [];
      // remove dummy uploaf file
      for (var i =0; i < message["attachments"].length; i++){
        if (message["attachments"][i]["type"] == "mention"){
          for( int u = 0; u< message["attachments"][i]["data"].length; u++){
            if (message["attachments"][i]["data"][u]["type"] == "user" || message["attachments"][i]["data"][u]["type"] == "all" ){
              listMentions += [message["attachments"][i]["data"][u]["value"]];
            }
          }
        }
        if (message["attachments"][i]["type"] == "befor_upload")
          message["attachments"][i] = {
            "content_url": message["attachments"][i]["content_url"],
            "key": message["attachments"][i]["key"],
            "mime_type":  message["attachments"][i]["mime_type"],
            "type": message["attachments"][i]["type_file"],
            "name": message["attachments"][i]["name"],
            "image_data": message["attachments"][i]["image_data"],
            "url_thumbnail" : message["attachments"][i]["url_thumbnail"],
            "key_encrypt" : message["attachments"][i]["key_encrypt"],
            "preview" : message["attachments"][i]["preview"],
            "version" : message["attachments"][i]["version"]
          };
      }

      if (listMentions.indexWhere((element) => element == message["conversation_id"]) != -1){
        listMentions =  [message["conversation_id"]];
      }
      final String rawText = Utils.getRawTextFromAttachment(message["attachments"] ?? [], message['message']);
      List previews = await Work.addPreviewToMessage(rawText);
      message["attachments"] = [] + message["attachments"] + previews;
      var dataMessageToEncrypt = {
        "message": message["message"],
        "attachments": message["attachments"],
        "last_edited_at": message["isSend"] ? null : DateTime.now().toString()
      };
      if (isSendReaction) {
        dataMessageToEncrypt = {
          ...dataMessageToEncrypt,
          "action": "reaction",
          "parent_id": message["parent_id"],
        };
      }

      var mEncrypt  =  jsonEncode(dataMessageToEncrypt);
      var resultDataToSend = Map.from({...message, "height": 0});
      resultDataToSend["attachments"] = [];
      resultDataToSend["message"] = "";
      Map dataToSend = {};

      var convKey =  dataDMMessages[indexConv].conversationKey;
      if (convKey == null){
        message["success"] = false;
        message["sending"] = false;
        message["isBlur"] = true;
        MessageConversationServices.saveLogDM({
          "type": "blur message",
          "reason": "conv_key null",
          "data": {
            "message": message,
            "conversationInfo": ({
              ...dataDMMessages[indexConv].toJson(),
              "messages": []
            }).toString()
          }
        });
        return updateDirectMessage(message, false, false, true);
      }

      var messageEn = convKey.encryptMessage(mEncrypt, message["user_id"], Utils.checkedTypeEmpty(message["isThread"]));
      if (!Utils.checkedTypeEmpty(messageEn["success"])) {
        message["success"] = false;
        message["sending"] = false;
        message["isBlur"] = true;
        MessageConversationServices.saveLogDM({
          "type": "blur message",
          "reason": "messageEn unsuccess",
          "data": {
            "messageEn": messageEn,
            "message": message,
            "conversationInfo": convKey.toJson()
          }
        });
        return updateDirectMessage(message, false, false, true);
      }
      dataToSend["message"] =  messageEn["message"];
      dataToSend["pKey_sender"] = convKey.nextPublicKey ?? messageEn["publicKey"];
      resultDataToSend["messages"] = [dataToSend];
      resultDataToSend["mentions"] = listMentions;
      if (isSendReaction) {
       resultDataToSend ["is_message_reaction"] = true;
      }

      String url = Utils.apiUrl + "direct_messages/" + message["conversation_id"] + "/messages";
      if (!Utils.checkedTypeEmpty(message["isThread"])){
        if (message["isSend"]) {
          url = url + "?token=$token&device_id=${await box.get("deviceId")}";
        } else {
          url = url + "/${message["id"]}/update_messages?token=$token&device_id=${await box.get("deviceId")}";
        }
      } else {
        if (message["isSend"]) {
          url = "${Utils.apiUrl}direct_messages/${message["conversation_id"]}/thread_messages/${message["parentId"]}/messages?token=$token&device_id=${await box.get("deviceId")}";
        } else {
          url = "${Utils.apiUrl}direct_messages/${message["conversation_id"]}/thread_messages/${message["parentId"]}/messages/${message["id"]}/update_messages?token=$token&device_id=${await box.get("deviceId")}";
        }

      }
      var response = await Dio().post(url, data: {"data": await Utils.encryptServer(resultDataToSend)});
      if (!message["isSend"]) return;
      var dataRes = response.data;
      if (dataRes["success"]) {
        var dm = getModelConversation(message["conversation_id"]);
        dataUnreadMessage[dataRes["data"]["id"]] = {
          "current_time": dataRes["data"]["current_time"],
          "data": dm!.user.map((e) => e["user_id"]).where((element) => element != message["user_id"]).toList()
        };

        await MessageConversationServices.insertOrUpdateMessage(dm, {
          ...message,
          ...dataRes["data"],
          "parent_id": message["parentId"] ?? message["parent_id"],
          "isBlur": false,
          "sending": false,
          "success": true,
        });
        if (!Utils.checkedTypeEmpty(message["isThread"])) {
          if (message["isSend"]){
            updateDirectMessage({
              ...message,
              ...dataRes["data"],
              "isBlur": false,
              "sending": false,
              "success": true,
            }, false, false, true);
            updateListReadConversation(
              message["conversation_id"], 
              {
                "current_time": dataRes["data"]["current_time"],
                "last_user_id_send_message": message["user_id"],
                "user_id": message["user_id"]
              }, 
              message["user_id"]
            );

            updateSnippet({
              ...message,
              ...dataRes["data"],
              "user_read": {
                "last_user_id_send_message": message["user_id"],
                "user_id": message["user_id"],
                "current_time": dataRes["data"]["current_time"]
              }
            });
          }
        }
        deleteDraftMessage(message["fake_id"]);
        getLocalPathAtts([{
          ...message,
          ...dataRes["data"]
        }], forceDownload: true);
      }
      if (!dataRes["success"]) {
        MessageConversationServices.saveLogDM({
          "type": "blur message",
          "reason": "send message fail",
          "data": {
            "message": message,
            "res": dataRes
          }
        });
        message["isBlur"] = true;
        message["success"] = false;
        message["sending"] = false;
        updateDirectMessage(message, false, false, true);
        if ("${dataRes["error_code"]}" ==  "219"){
          deleteDraftMessage(message["fake_id"]);
        } else{
          insetMessageErrorToReSend(message);
        }
      }
    } catch (e, trace) {
      print("queueBeforeSend $e  $trace");
      if (!message["isSend"]) return;
      MessageConversationServices.saveLogDM({
        "type": "blur message",
        "reason": "send message catch",
        "data": {
          "message": message,
          "catch": e.toString(),
          "trace": trace
        }
      });
      message["isBlur"] = true;
      message["success"] = false;
      message["sending"] = false;
      insetMessageErrorToReSend(message);
      updateDirectMessage(message, false, false, true);
        // all error 500 need to save
        // var box = Hive.lazyBox("messageError");
        // await box.put(message["fake_id"], message);
    }
  }

  insetMessageErrorToReSend(Map message) async {
    try {
      var currentDirectMessage  = getCurrentDataDMMessage(message["conversation_id"]);
      if (Utils.checkedTypeEmpty(currentDirectMessage) && Utils.checkedTypeEmpty(currentDirectMessage?.statusConversation == "created")){
        var queueBox = Hive.box('queueMessages');
        var oldData = queueBox.get(message["fake_id"]);
        queueBox.put(message["fake_id"],
          {...message, ...(oldData ?? {}), "retries": message["retries"] ?? (oldData ?? {})["retries"] ?? 5}
        );
      }
    } catch (e, t) {
      print("insetMessageErrorToReSend: $e, $t");
    }
  }


  resetData() {
    _dataMentionConversations = new DataMentionUser([], 0, false);
    _data = [];
    _dataMessage = [];
    _messagesDirect = [];
    _isFetching = false;
    dataDMMessages = [];
    _selectedFriend = false;
    _selectedMentionDM = false;
  }

  setKey(pairKey){
    _pairKey = pairKey;
  }
  Future<dynamic> uploadThumbnail(String token, workspaceId, file, type) async {
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

  // uploadImage(String token, workspaceId, file, type, Function onSendProgress, {String key = ""}) async {
  //   Map rootFileData = file;
  //   var imageData = file["image_data"];

  //   if (type == "image") {
  //     var decodedImage = await decodeImageFromList(base64.decode(file["path"]));
  //     imageData = {
  //       "width": decodedImage.width,
  //       "height": decodedImage.height
  //     };
  //   }
  //   var result  = {};
  //   String key = "";
  //   key = (await X25519().generateKeyPair()).secretKey.toString();
  //   List<int> bytes = base64Decode(file["path"]);
  //   file = {
  //     ...file,
  //     "path": base64Decode((await Utils.encrypt(file["path"], key)))
  //   };
  //   try {
  //     final url = Utils.apiUrl + 'workspaces/$workspaceId/contents/v2?token=$token';
  //     var dataFile = MultipartFile.fromBytes(
  //       file["path"],
  //       filename: Utils.checkedTypeEmpty(file["filename"]) ? file["filename"] : DateTime.now().microsecondsSinceEpoch.toString(),
  //     );

  //     FormData formData = FormData.fromMap({
  //       "data": dataFile,
  //       "content_type": type,
  //       "mime_type": file["mime_type"],
  //       "image_data" : imageData,
  //       "filename": file["filename"],
  //     });

  //     // final url = Utils.apiUrl + 'workspaces/$workspaceId/contents?token=$token';
  //     final response = await Dio().post(url, data: formData, onSendProgress: (count, total) {
  //       // print("coount  $count");
  //       StreamUploadStatus.instance.setUploadStatus(key, count/total);
  //     },);

  //     final responseData = response.data;


  //     // remove att type  = "before_upload"
  //     if (responseData["success"]) {
  //       var res = await uploadThumbnail(token, workspaceId, file["upload"], type);
  //       result = {
  //         "success": true,
  //         "content_url":  responseData["content_url"],
  //         "type_file": file["type_file"],
  //         "mime_type": file["mime_type"],
  //         "name": file["name"] ?? "",
  //         "url_thumbnail" : res["content_url"],
  //         "image_data": imageData ?? responseData["image_data"],
  //       };
  //       await Media(responseData["content_url"].hashCode, "", responseData["content_url"], file["name"] ?? "", file["type_file"], "", bytes.length, key, "downloaded").downloadByBytes(bytes);
  //     }
  //     else result =  {
  //       "success": false,
  //       "file_data": rootFileData
  //     };

  //   } catch (e, t) {
  //     print("ERRRRRRRRR:   $e   $t");
  //     result =  {
  //       "success": false,
  //       "file_data": rootFileData
  //     };
  //   }
  //   return Utils.mergeMaps([result, {"name": file["filename"], "type": "befor_upload",'preview': file['preview'], "key": Utils.getRandomString(20), "key_encrypt": key}]);
  // }


  sendMessageWithImageFromIsolate(List resultUpload, List noDummyAtts, Map message, String token){
    try {
      // create a message that noti user atts upload fail
      List failAtt =  resultUpload.where((element) => !element["success"]).toList();
      List successAtt = resultUpload.where((element) => element["success"]).toList();
      message["attachments"].removeWhere((ele) => ele["type"] == "befor_upload");
      message["attachments"] = message["attachments"] + noDummyAtts + successAtt;
      if(message["attachments"].length > 0 || message["message"] != ""){
        handleSendDirectMessage(Map.from(message), token);
      } else {
        removeMessageNoAttAndMessage(message);
      }
      if (failAtt.length > 0){
        var messagFail = Map.from(message);
        messagFail["fake_id"] = Utils.getRandomString(20);
        messagFail["current_time"] =  messagFail["current_time"] ?? DateTime.now().microsecondsSinceEpoch + 1;
        messagFail["attachments"] = failAtt;
        messagFail["message"] = "";
        messagFail["success"] = false;
        messagFail["isBlur"] = true;
        messagFail["sending"] = false;
        createMessageUploadFail(messagFail);
      }
    } catch (e, t) {
      print("Sfrsef ___ $e $t");
      message["success"] = false;
      message["isBlur"] = true;
      MessageConversationServices.saveLogDM({
        "type": "blur message",
        "reason": "sendMessageWithImage",
        "data": {
          "message": message,
          "res": {e, t}
        }
      });
      updateDirectMessage(message, false, false, true);
    }

  }

  sendMessageWithImage(List atts, Map message, token)async {
    if (atts.length == 0) return handleSendDirectMessage(message, token);
    for(var i = 0; i< atts.length; i ++){
      atts[i]["att_id"] = Utils.getRandomString(10);
    }
    // make dummy
    try {
      return IsolateMedia.mainSendPort.send!({
        "type": "process_file_while_send_message_dm_with_files",
        "data": {
          "message": message,
          "token": token,
          "atts": atts,
          "path_temp_folder": (await getTemporaryDirectory()).path,
          "path_application_document": (await getApplicationDocumentsDirectory()).path
        }
      });
    } catch (e, trace) {
      print("Sfrsef ___ $e $trace");
      message["success"] = false;
      message["isBlur"] = true;
      MessageConversationServices.saveLogDM({
        "type": "blur message",
        "reason": "sendMessageWithImage",
        "data": {
          "message": message,
          "res": {e, trace}
        }
      });
      updateDirectMessage(message, false, false, true);
    }
    // make a message fail
  }

  removeMessageNoAttAndMessage(Map message){
    int indexConverstionCurrent  = dataDMMessages.indexWhere((element) => element.conversationId == message["conversation_id"]);
    if (indexConverstionCurrent != -1){
      dataDMMessages[indexConverstionCurrent].messages = dataDMMessages[indexConverstionCurrent].messages.where((element) => element["fake_id"] != message["fake_id"]).toList();
      notifyListeners();
    }
  }

  deleteDraftMessage(id){
    Box boxQueueMessages = Hive.box('queueMessages');
    boxQueueMessages.delete(id);
  }

// luw lai thong tin nay de gui lai
  createMessageUploadFail(message) async {
    int indexConverstionCurrent  = dataDMMessages.indexWhere((element) => element.conversationId == message["conversation_id"]);
    if (indexConverstionCurrent != -1){
      dataDMMessages[indexConverstionCurrent].messages = [message as Map] + dataDMMessages[indexConverstionCurrent].messages;
      // luwu lai file gui that bai trong getApplicationSupportDirectory()/file_upload_fail
      // se xoa ddi truoc moi lan gui
      var newDir = await getApplicationSupportDirectory();
      var newPath = newDir.path + "/file_upload_fail";
      await Directory(newPath).create(recursive: true);
      message["attachments"] = await Future.wait(
        (message["attachments"] as List).map((e)async {
          File f = await File("$newPath/${DateTime.now().microsecondsSinceEpoch.toString()}").writeAsBytes(base64.decode(e["file_data"]["path"]));
          Map fileData = e["file_data"];
          return {
            "local_path": f.path,
            "length": e["file_data"]["path"].length,
            "mime_type": fileData["mime_type"],
            "type_file": fileData["type_file"] ?? fileData["type"],
            "name": fileData["name"],
            "image_data": fileData["image_data"],
            'preview': fileData['preview'],
          };
        })
      );
      // print("message: $message");
      insetMessageErrorToReSend(message);
      notifyListeners();
    }
  }

  getUploadData(file, isDesktop)async {
    String data = base64.encode(file["file"]);
    if(file["mime_type"].toString().toLowerCase() == "mov") {
      var pathOther = await getTemporaryDirectory();
        String out = pathOther.path + "/${file["name"]}.mp4";
        await FFmpegKit.execute('-y -i ${file["path"]} -c copy $out');
        File u = File(out);
      data = base64Encode(u.readAsBytesSync());
    }

    return {
      "filename": file["name"],
      "path": data,
      "length": data.length,
      "mime_type": file["mime_type"],
      "type_file": file["type_file"] ?? file["type"],
      "name": file["name"],
      "progress": "0",
      "image_data": file["image_data"],
      "upload": file["upload"],
      "preview": file["preview"]
    };
  }

// tin nhan co action: delete, insert || null, delete_for_me,
  updateSnippet(message) async {
    var box = Hive.box('direct');
    DirectModel? dm = getModelConversation(message["conversation_id"]);
    if (dm == null) return;
    var snippetNew = {
      "message": message["message"],
      "attachments": message["attachments"],
      "conversation_id": message["conversation_id"],
      "user_id": message["user_id"],
      "current_time": message["current_time"],
      "statusSnippet": message["statusSnippet"] ?? "created",
      "message_id": message["id"]
    };
    if (message["current_time"] < (dm.snippet["current_time"] ?? 0)) return;
    if (message["action"] == "insert" || message["action"] == null){
      dm.snippet = snippetNew;
      dm.seen = message["current_time"] <= (dm.userRead["current_time"] ?? 0) ? dm.seen : false;
      box.put(dm.id, dm);
      notifyListeners();
      return;
    } else if (message["action"] == "delete"){
      dm.snippet = {
        ...(dm.snippet),
         "message": "[This message was deleted.]",
         "attachments": []
      };
      dm.seen = message["current_time"] <= (dm.userRead["current_time"] ?? 0) ? dm.seen : false;
      box.put(dm.id, dm);
      notifyListeners();
      return;
    } if (message["action"] == "delete_for_me"){
      Map? lastMessage = await MessageConversationServices.getLastMessageOfConversation(message["conversation_id"]);
      if (lastMessage != null) {
        dm.snippet = {
          "message": lastMessage["action"] == "delete" ?  "[This message was deleted.]" : lastMessage["message"],
          "attachments": lastMessage["attachments"],
          "conversation_id": lastMessage["conversation_id"],
          "user_id": lastMessage["user_id"],
          "current_time": lastMessage["current_time"],
          "statusSnippet": lastMessage["statusSnippet"] ?? "created",
          "message_id": lastMessage["id"]
        };
      } else {
        dm.snippet = {};
      }
      dm.seen = true;
        await box.put(dm.id, dm);
        notifyListeners();
    }
  }

  setDataDefault(){
    _data = [];
    notifyListeners();
  }

  handleRequestConversationSync(dataM, context)async {
    //  giai ma data de lay thong tin
    var result ;
    for (var i = 0; i < dataM["device_id"].length; i++){
      var dataDe = await Utils.decryptServer(dataM["device_id"][i]);
      if (dataDe["success"]) {
        result = dataDe["data"];
        break;
      }
    }

    if (result != null) {
      // ktra xem dang co view share nao dang chajy ko
      GlobalKey<DMConfirmSharedState> dmConfirmSharedViewKey = Utils.dmConfirmSharedViewKey;
      if (dmConfirmSharedViewKey.currentState != null){
        // ktra xem view dang trong qua trinh share hay ko
        if (dmConfirmSharedViewKey.currentState!.code != null) return;
        Navigator.pop(dmConfirmSharedViewKey.currentState!.context);
      } 
      showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        isScrollControlled: true,
        enableDrag: true,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height*0.75,
            child: DMConfirmShared(key: Utils.dmConfirmSharedViewKey, deviceId: result["device_id"], data: dataM, deviceRequestPublicKey: result["device_request_public_key"],),
          );
        },
        context: context
      );
    }
  }

  logoutDevice(data)async{
    LazyBox box  =  Hive.lazyBox('pairKey');
    var deviceId  = await box.get('deviceId');
    _isLogoutDevice = true;
    notifyListeners();
    for(var  i =0; i < data["data"].length; i++){
      Map result  =  await Utils.decryptServer(data["data"][i]);
      if (result["success"]){
        if (deviceId  ==  result["data"]["device_id"]){
          _data = [];
          dataDMMessages = [];
          _errorCode = "";
          Provider.of<Auth>(Utils.globalContext!, listen: false).logout();
          notifyListeners();
        }
      }
    }
    _isLogoutDevice = false;
    notifyListeners();
  }

  setUnreadCountConv(data) async{
    // find index
    var conversationId = data["conversation_id"];
    var index  =  _data.indexWhere((element) => element.id == conversationId);
    if (index  == -1) return;
    DirectModel dm  =  _data[index];
    dm.newMessageCount = 0;
    dm.seen = true;
    notifyListeners();
  }


  reGetDataDiectMessage(token, String currentUserId) {
    queueReGetDataDiectMessage.scheduleOne(() {
      return getDataDirectMessage(token, currentUserId, isReset: true);
    });
  }

  setSelectedMention(value){
    _selectedMentionDM  = value;
    _selectedFriend = false;
    notifyListeners();
  }

  updateOrInsertMentionUser(Map? data, BuildContext context){
    if (data == null) return;
    Map? mention  = data["data"];
    if (mention != null){
      var index =  (_dataMentionConversations.data).indexWhere((ele) => "${ele.id}" == "${mention!["id"]}");
      if (mention["type"] == "message_conversation") {
        try {
          var message = getCurrentDataDMMessage(mention["conversation_id"])!.conversationKey!.decryptMessage(mention["data"]);
          mention = {
            ...mention,
            "data": message["message"]
          };
        } catch (e) {
        }

      } else if (mention["type"] == "issue"){
        mention["data"]["description"] = data["data"]["data"]["description"];
      }

      if (index == -1) _dataMentionConversations.data = [MentionUser.parseFromObject(mention!)] + _dataMentionConversations.data;
      else _dataMentionConversations.data[index].update(mention!["data"]);
      _dataMentionConversations.numberUnseen = data["number_unseen"] ?? dataMentionConversations.numberUnseen;
      notifyListeners();
    }
  }

  deleteMentionUser(Map? data){

    if (data == null) return;
    Map? mention = data["data"];
    if (mention == null) return;
    _dataMentionConversations.data = _dataMentionConversations.data.where((ele) =>"${ele.id}" != "${mention["mention_id"]}").toList();
    _dataMentionConversations.numberUnseen = data["number_unseen"] ?? dataMentionConversations.numberUnseen;
    notifyListeners();
  }

  // lay mention cua user tai tat ca channel + conversation, check theo cungf channel_id/conversation_id
  Future<dynamic> getMentionUser(String token, {bool isMark = false, String? lastId}) async {
    if (!Utils.checkedTypeEmpty(  _dataMentionConversations.isFetching)){
      _dataMentionConversations.isFetching = true;
      notifyListeners();
      lastId = lastId == "" ? "" : _dataMentionConversations.data.length > 0 ? _dataMentionConversations.data.last.id : "";
      if (lastId == "") _dataMentionConversations.data = <MentionUser>[];
      String url = "${Utils.apiUrl}users/mentions?token=$token&is_mark=$isMark&last_id=$lastId";
      try {
        var response = await Dio().get(url);
        var resData = response.data;
        if (resData["success"]){
          List<MentionUser> dataResult = [];
          for(int i = 0; i < resData["data"].length; i++){
            var dataMention = resData["data"][i];
            if (dataMention["type"] == "message_conversation" && await getInfoDirectMessage(token, dataMention["conversation_id"])) {
              DirectModel? dm = getModelConversation(dataMention["conversation_id"]);
              var currentDM = getCurrentDataDMMessage(dataMention["conversation_id"]);
              Map? dataOnIsar, dataDecrypted;
              try {
                dataOnIsar = await MessageConversationServices.getListMessageById(dm!, dataMention["data"]["id"], dataMention["conversation_id"]);
              } catch (e) {
              }
              try {
                dataDecrypted = currentDM!.conversationKey!.decryptMessage(dataMention["data"]);
              } catch (e) {
              }
              dataMention = {
                ...dataMention,
                "data": {
                  ...dataMention["data"],
                  ...(dataOnIsar ?? {}),
                  ...(dataDecrypted != null && dataDecrypted["success"] ? dataDecrypted["message"] : {})   ,
                  "status_decrypted": (dataOnIsar == null) && (dataDecrypted == null || (!dataDecrypted["success"])) ? "decryptionFailed" : "success"
                }
              };
            } else {

            }
            if (dataMention != null) dataResult += [MentionUser.parseFromObject(dataMention)];
          }
          _dataMentionConversations.isFetching = false;
          _dataMentionConversations.numberUnseen = resData["number_unseen"];
          _dataMentionConversations.data = uniqMention((_dataMentionConversations.data + dataResult));
        }
        notifyListeners();
      } catch (e, trace) {
        _dataMentionConversations.isFetching = false;
        print("getMentionUser $e $trace");
      }
    }
  }

  List<MentionUser> uniqMention(List<MentionUser> dataSource) {
    Map index  = {};
    List<MentionUser> results  = [];
    for(int i = 0; i< dataSource.length; i++){
      if (index[dataSource[i].id] == null ){
        index[dataSource[i].id] = 1;
        results += [dataSource[i]];
      }
    }
    return results;
  }


  setMessageConversationFromMention(idDirectMessage, Map message){
    var currentDataMessageConversations = getCurrentDataDMMessage(idDirectMessage);
    if (currentDataMessageConversations == null) return;

    var indexMessage =  currentDataMessageConversations.messages.indexWhere((ele) => ele["id"] == message["id"]);
    if (indexMessage == -1){
      currentDataMessageConversations.active = true;
      currentDataMessageConversations.lastCurrentTime = message["current_time"];
      currentDataMessageConversations.latestCurrentTime = message["current_time"];
      currentDataMessageConversations.messages =  [Utils.mergeMaps([
        message,
        {"showSkeleton": true, "isFromMention": true}
      ])];
    }
    else {
      currentDataMessageConversations.messages[indexMessage] = Utils.mergeMaps([
        currentDataMessageConversations.messages[indexMessage],
        {"isFromMention": true}
      ]);
    }
    notifyListeners();

  }

  setIdMessageToJump(id){
    _idMessageToJump = id;
  }

  void checkDeviceRequestSyncDataFromNotification(Map dataDevice, String token, BuildContext context) async {
    try {
      final url = "${Utils.apiUrl}/direct_messages/check_device_request_from_notification?token=$token&device_id=${await Utils.getDeviceId()}";
      var res = await Dio().post(url, data: {
        "data": await Utils.encryptServer({
          "device_id_request": dataDevice["device_id"],
          "current_time": DateTime.now().millisecondsSinceEpoch
        })
      });

      print("_________res.data: ${res.data} \n $dataDevice");
      if (res.data["success"]){
        var data  = await Utils.decryptServer(res.data["data"]);
        GlobalKey<DMConfirmSharedState> dmConfirmSharedViewKey = Utils.dmConfirmSharedViewKey;
        if (dmConfirmSharedViewKey.currentState != null){
          // ktra xem view dang trong qua trinh share hay ko
          if (dmConfirmSharedViewKey.currentState!.code != null) return;
          Navigator.pop(dmConfirmSharedViewKey.currentState!.context);
        } 
        showModalBottomSheet(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          isScrollControlled: true,
          enableDrag: true,
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: MediaQuery.of(context).size.height*0.75,
              child: DMConfirmShared(key: Utils.dmConfirmSharedViewKey, deviceId: data["data"]["device_id_request"], data: dataDevice, deviceRequestPublicKey: data["data"]["device_request_public_key"],),
            );
          },
        );
      }
    } catch (e) {
      print("r_________ $e");
    }
  }

  setHideConversation(idDirectMessage, isHide, context) async{
    if (context == null) return;
    List listDm = Provider.of<DirectMessage>(context, listen: false).data.toList();
    var index = listDm.indexWhere((element) => element.id == idDirectMessage);
    var directMessage;

    if (index != -1) {
      directMessage = listDm[index];
      final token = Provider.of<Auth>(context, listen: false).token;
      LazyBox box = Hive.lazyBox('pairKey');
      final url = "${Utils.apiUrl}direct_messages/$idDirectMessage/set_hide?token=$token&device_id=${await box.get("deviceId")}";
      try {
        var response = await Dio().post(url, data: {"data": await Utils.encryptServer({"hide": isHide})});
        var dataRes = response.data;

        if (dataRes["success"]) {
          var newD = DirectModel(
            directMessage.id,
            directMessage.user,
            directMessage.name,
            true, 0,
            directMessage.snippet,
            isHide,
            directMessage.updateByMessageTime,
            directMessage.userRead,
            directMessage.displayName,
            directMessage.avatarUrl,
            directMessage.insertedAt
          );
          Provider.of<DirectMessage>(context, listen: false).setDirectMessage(newD, token);
        }
      } catch (e){
        print(e);
        // sl.get<Auth>().showErrorDialog(e.toString());
      }
    }
  }

  updateOnlineStatus(Map data){
    // data  = {
    //   "user_id": "",
    //   "is_online": true/false
    // }
    _data.map((e) {
      int indexUser  = (e.user).indexWhere((element) => element["user_id"] == data["user_id"]);
      if (indexUser != -1){
        e.user[indexUser]["is_online"] = data["is_online"];
      }
    }).toList();

    notifyListeners();
  }

  // khi dang ko focus app, khi dang ko trong view, va khong phai tin nhan cua minh
  markNewMessage(Map message, context){
    try {
      if (message["user_id"] == Provider.of<Auth>(context, listen: false).userId) return;
      var conversationId = message["conversation_id"];
      var isFocusApp = Provider.of<Auth>(context, listen: false).onFocusApp;
      if (
        (directMessageSelected.id != message["conversation_id"])
        || ((directMessageSelected.id == conversationId) && !isFocusApp)
      ){
        var currentDataDMMessage = getCurrentDataDMMessage(conversationId);
        if (!Utils.checkedTypeEmpty(currentDataDMMessage!.lastMessageReaded))
          currentDataDMMessage.lastMessageReaded = message["id"];
      }
    } catch (e) {
    }
  }

  removeMarkNewMessage(String idConversation){
    try {
      var conversationId = idConversation;
      var currentDataDMMessage = getCurrentDataDMMessage(conversationId);
      if (Utils.checkedTypeEmpty((currentDataDMMessage!.lastMessageReaded))){
        currentDataDMMessage.lastMessageReaded = "";
        notifyListeners();
      }
    } catch (e) {
    }
  }

  // luu lai context cua tin nhan
  // moi khi can lay height = context.size!.height ?? 0
  void updateHeightMessage(conversationId, id, BuildContext context) {
    try {
      var currentDataDMMessage = getCurrentDataDMMessage(conversationId);
      var indexMessage = (currentDataDMMessage!.messages).indexWhere((element) => element["id"] == id);
      if (indexMessage != -1){
        currentDataDMMessage.messages[indexMessage]["height"] = context;
      }
    } catch (e) {
    }
  }

  // xu ly message de nhay den nhay den
  Future<void> processDataMessageToJump(Map message, String token, String currentUserId) async {
    var conversationId = message["conversation_id"];
    DirectModel? dm = getModelConversation(conversationId);
    if (dm == null) return;
    Map? messageRoot = await MessageConversationServices.getListMessageById(dm, message["id"], message["conversation_id"]);
    if (messageRoot == null) return;
    // neu message nhay den chua co
    // + Reset tat conversationDataMessage ve mac dinh
    // goij api load 2 chiefutinhs tu message jump
    // cap nhat new_message_countve 0
    // new co tin nhan moi,
    // scroll xuong den khi nao khong the load moi dc nua
    // hoac click vafoso tin moi => reset laij hoi thoaij
    // neu gui tin moi => reset lai hoi thoai
    // viec nhay den tin nhan do view hien thi dam nhan
      var indexDataMessage = dataDMMessages.indexWhere((element) => element.conversationId == conversationId);
      if (indexDataMessage == -1) return;
      dataDMMessages[indexDataMessage] = ConversationMessageData.parseFromJson({
        ...defaultConversationMessageData,
        ...dataDMMessages[indexDataMessage].toJson(),
        "status_conversation": dataDMMessages[indexDataMessage].statusConversation,
        "conversation_key": dataDMMessages[indexDataMessage].conversationKey,
        "queue": dataDMMessages[indexDataMessage].queue,
        "latest_current_time": message["current_time"],
        "last_current_time": message["current_time"],
        "messages": <Map>[],
        "is_fetching": false,
        "is_fetching_up": false,
        "disable_load_down": false,
        "disable_load_up": false,
        "disable_hive_down": false,
        "disable_hive_up": false,
        "number_new_message": 0,
      });

    notifyListeners();
    Future getDown() async{
      await getMessageFromHiveDown(conversationId, messageRoot["current_time"], token, currentUserId, forceLoad: true);
    }

    Future getUp() async{
      await getMessageFromHiveUp(conversationId, messageRoot["current_time"], "", currentUserId, forceLoad: true, size: 10);
    }
    await Future.delayed(Duration(milliseconds: 250));
      try {
        await Future.wait([
          getDown(),
          getUp()
        ]);
      } catch (e) {
      }

    var currentDataDMMessage = getCurrentDataDMMessage(conversationId);
    if (currentDataDMMessage == null) return;
    currentDataDMMessage.messages = sortMessagesByDay(uniqById( [] + [messageRoot] + currentDataDMMessage.messages), dm);

    setIdMessageToJump(message["id"]);
    setSelectedDM(dm, "");
    setSelectedMention(false);

  }

// khoi phuc 1 conversation ve mac dinh
  resetOneConversation(String conversationId, {bool isNotify = true, bool needCallApi = true}){
    var indexDataMessage = dataDMMessages.indexWhere((element) => element.conversationId == conversationId);
    if (indexDataMessage == -1) return;
    dataDMMessages[indexDataMessage] = ConversationMessageData.parseFromJson({
      ...defaultConversationMessageData,
      "status_conversation": dataDMMessages[indexDataMessage].statusConversation,
      "conversation_id": conversationId,
      "inserted_at": dataDMMessages[indexDataMessage].insertedAt,
      "conversation_key": dataDMMessages[indexDataMessage].conversationKey,
      "queue": dataDMMessages[indexDataMessage].queue,
      "dummy_id": dataDMMessages[indexDataMessage].dummyId,
      "data_unread_thread": dataDMMessages[indexDataMessage].dataUnreadThread
    });
    Auth auth = Provider.of<Auth>(Utils.globalContext!, listen: false);
    if (needCallApi) getMessageFromApi(conversationId, auth.token, true, null, auth.userId);
    if (isNotify || true) notifyListeners();
  }

  findConversationFromListUserIds(List userids){
    try {
      var index = _data.indexWhere((element) =>
        MessageConversationServices.shaString((element.user).map((u) => u["user_id"]).toList())
        == MessageConversationServices.shaString(userids)
      );
      return _data[index];
    } catch (e) {
      return null;
    }
  }

  getTextDescriptionSyncData(){
    try {
      if ("$errorCode" == "203" ){
        if (_deviceCanCreateOtp.length == 0) return "You must logout all device";
        String nameDevice = _deviceCanCreateOtp.map((e) => e["name"]).toList().join(" or ");
        return "Open Panchat app on $nameDevice to get OTP and tap 'Sync data'";
      }
      return "";
    } catch (e) {
      return "Open Panchat app on others devices to get OTP and tap 'Sync data'";
    }
  }

  bool sendErrorMessage = false;
  checkReSendMessageError(token, conversationId, {bool onlySupportDM = false, threadId}) async {
    try {
      if (sendErrorMessage) {
        await Future.delayed(Duration(seconds: 10));
        return checkReSendMessageError(token, conversationId);
      }
      sendErrorMessage = true;
      var box = Hive.box('queueMessages');
      // ignore: unnecessary_null_comparison
      List queueMessages = box.values.toList().where((e) => Utils.checkedTypeEmpty(e["conversation_id"]) && e["conversation_id"] == conversationId).toList();
      queueMessages.sort((a, b) => a["current_time"].compareTo(b["current_time"]));

      if (threadId != null) {
        queueMessages.where((e) => e["isThread"] == true && e["parentId"] == threadId).toList();
      } else {
        queueMessages.where((e) => e["isThread"] == false).toList();
      }

      for(var i = 0; i< queueMessages.length; i++){
        var dataMessage = queueMessages[i];
        if (onlySupportDM){
          if (dataMessage["conversation_id"] != MessageConversationServices.shaString([Utils.panchatSupportId, dataMessage["user_id"]])) continue;
        }
        if (dataMessage["retries"] == 0 || (!Utils.checkedTypeEmpty(dataMessage["message"]) && dataMessage["attachments"].length == 0)) {
          await box.delete(dataMessage["fake_id"]);
          continue;
        }
        queueMessages[i] = {
          ...(queueMessages[i] as Map),
          "retries": ((queueMessages[i] as Map)["retries"] ?? 5) - 1
        };
        box.delete(dataMessage["fake_id"]);
        // lay lai data file da luwu trpmg getApplicationSupportDirectory
        List files = (await Future.wait(
          (queueMessages[i]["attachments"] as List).map((e) async {
            if (Utils.checkedTypeEmpty(e["local_path"])) {
              Map re =  {
                "filename": e["name"],
                "file": await File(e["local_path"]).readAsBytes(),
                "length": e["length"],
                "mime_type": e["mime_type"],
                "type": e["type_file"],
                "name": e["name"],
                "progress": "0",
                "image_data": e["image_data"],
                "upload" : e["upload"],
                'preview': e['preview'],
              };
              await File(e["local_path"]).delete();
              return re;
            } else return null;
          })
        ));
        queueMessages[i] = {
          ...(queueMessages[i]),
          "attachments": (queueMessages[i]["attachments"] as List).where((e) => !Utils.checkedTypeEmpty(e["local_path"])).toList()
        };
        sendMessageWithImage(files, queueMessages[i], token);
      }
      sendErrorMessage = false;
    } catch (e, t) {
      sendErrorMessage = false;
      print("checkReSendMessageError, $e, $t");
    }
  }

  // roi hoi thaoi, set lai _directMessageSelected
  Future<bool> leaveConversation(String conversationId, String token, String currentUserId, {String? targetMemberId}) async {
    try {
      var url ="${Utils.apiUrl}/direct_messages/leave_conversation?token=$token&device_id=${await Utils.getDeviceId()}";
      return Dio().post(
        url,
        data: {
          "data": await Utils.encryptServer({
            "conversation_id": conversationId,
            "key": Utils.getRandomString(10),
            ...(targetMemberId != null ? {"user_id_leave": targetMemberId} : {})
          })
        }
      ).then((value) async {
        if(value.data["success"]) {
          if (targetMemberId == null) {
            int index = _data.indexWhere((ele) => ele.id == conversationId);
            if(index != -1) _data.removeAt(index);

            dataDMMessages =  dataDMMessages.where((ele) => ele.conversationId != conversationId).toList();
            var box = Hive.box("direct");
            box.delete(conversationId);

            if (_directMessageSelected.id == conversationId){
              leaveOrDeleteConversation(conversationId, currentUserId);
            }
            notifyListeners();
          } else {
            DirectModel? dm = getModelConversation(conversationId);
             if (dm != null) {
            int indexUser = dm.user.indexWhere((element) => element["user_id"] == targetMemberId);
              if (indexUser != -1) {
                dm.user[indexUser]["status"] = "leave_conversation";
                notifyListeners();
              }
            }
          }
          getDataDirectMessage(token, currentUserId, isReset: true);
          return true;
        }
        return false;
      });
    } catch (e, t) {
      print("value: $e $t");
      return false;
    }
  }

  leaveOrDeleteConversation(String conversationId, String currentUserId) async {
    _data = _data.where((element) => element.id != conversationId).toList();
    _directMessageSelected = _data.where((element) => element.id != conversationId).toList()[0];
    var boxSelect = await  Hive.openBox('lastSelected');
    boxSelect.put("lastConversationId", _directMessageSelected.id);
    var box = Hive.box("direct");
    box.delete(conversationId);
    dataDMMessages = dataDMMessages.where((ele) => ele.conversationId != conversationId).toList();
  }


  DirectModel? getModelConversation(String? idConversation){
    try {
      var index  = _data.indexWhere((element) {
        return  "${element.id}" == "$idConversation";
      });
      return _data[index];
    } catch (e) {
      return null;
    }
  }

  String getNameDM(List users, String userId, String name, {bool hasIsYou = true}){
    try {
      if (name != "") return name;
      if (users.length == 1) return users[0]["full_name"];
      var result = "";
      List userInConv = users;
      bool isGroup = userInConv.length > 2;
      for (var i = 0; i < userInConv.length; i++) {
        if (userInConv[i]["user_id"] == userId || (userInConv[i]["status"] != null && userInConv[i]["status"] != "in_conversation")) continue;
        if (i != 0 && result != "") result += ", ";
        result += userInConv[i]["full_name"];
      }
      return (isGroup && hasIsYou ? "You, " : "" )+  result;
    } catch (e) {
      return "";
    }
  }

  processDataFromAndroidNative(Map data) {
    MessageConversationServices.insertOrUpdateMessages(data.values.toList());
  }

  getInfoUnreadMessage(List messages, String token, String conversationId) async {
    try {
      final url = "${Utils.apiUrl}direct_messages/$conversationId/get_info_message?token=$token&device_id=${await Utils.getDeviceId()}";
      final response = await Dio().post(url, data: {
        "data" : await Utils.encryptServer({
          "message_ids": messages.map((e) => e["id"]).toList()
        })
      });

      // save data
      Map dataThread = response.data["data_thread"] ?? {};
      dataInfoThreadMessage = {
        ...dataInfoThreadMessage,
        ...(
          Map.fromIterable(
            dataThread.keys.map<DataInfoThreadConv?>((k) => DataInfoThreadConv.fromJson(dataThread[k])).whereType<DataInfoThreadConv>().toList(),
            key: (v) => v.messageId, value: (v) => v)
          )
      };
      // await Future.wait((response.data["data_thread"] as Map).keys.map((idMessage) async {
      //   DirectModel? dm = getModelConversation(conversationId);
      //   if (dm != null) MessageConversationServices.insertOrUpdateMessage(dm, {
      //     "id": idMessage,
      //     "count": dataInfoThreadMessage[idMessage]["count"],
      //     "conversation_id": conversationId
      //   }, type: "update");
      // }));

      dataUnreadMessage = {
        ...dataUnreadMessage,
        ...(response.data["data"])
      };

      // notifyListeners();
    } catch (e) {
    }
  }

  dataMessageUnread(data){
    List keys = (data as Map).keys.toList();
    for(var i = 0; i < keys.length ; i++){
      var key = keys[i];
      var oldData = dataUnreadMessage[key] ?? {};
      if (int.parse("${data[key]["current_time"]}") > int.parse("${(oldData[key] ?? {})["current_time"] ?? 0}")) dataUnreadMessage[key] = data[key];
    }
  }

  updateThreadUser(data){
    try {
      var newData = data["data"]["data_thread"];
      // newData  = %{
      //   "thread_id" => id_thread,
      //   "message_id" => message_id,
      //   "is_read" => true
      // }
      if (dataInfoThreadMessage[newData["message_id"]] != null){
        dataInfoThreadMessage[newData["message_id"]]!.isRead = newData["is_read"];
        dataInfoThreadMessage[newData["message_id"]]!.count = newData["count"];
      } else {
        dataInfoThreadMessage[newData["message_id"]] = DataInfoThreadConv.fromJson(newData)!;
      }

      ConversationMessageData? currentDataDMMessage = getCurrentDataDMMessage(newData["conversation_id"]);
      if (currentDataDMMessage != null) {
        if (newData["is_read"]) {
          currentDataDMMessage.dataUnreadThread = currentDataDMMessage.dataUnreadThread.where((ele) => ele.messageId != newData["message_id"]).toList();
        }
        else{
          int indexM = currentDataDMMessage.dataUnreadThread.indexWhere((element) => element.messageId == newData["message_id"]).toInt();
          if (indexM == -1) return currentDataDMMessage.dataUnreadThread = currentDataDMMessage.dataUnreadThread + [DataInfoThreadConv.fromJson(newData)!];
          currentDataDMMessage.dataUnreadThread[indexM].count = newData["count"];
        }
      }
      notifyListeners();
    } catch (e, t) {
      print("updateThreadUser: $e, $t");
    }

  }

  Future loadUnreadMessage(String token) async {
    try {
      final url = '${Utils.apiUrl}direct_messages/get_all_message_unread?token=$token&device_id=${await Utils.getDeviceId()}';
      var response = await Dio().get(url);
      var res = response.data;
      List dataMessages =  res["data"] as List;
      List dataSuccess =(await Future.wait(dataMessages.map((message) async {
        try {
          if (message["action"] == "delete" || message["action"] == "delete_for_me") return message;
          var currentDataDMMessage = getCurrentDataDMMessage(message["conversation_id"]);
          var convKey = currentDataDMMessage!.conversationKey;
          var decrypted = convKey!.decryptMessage(message);
          if (decrypted["success"]){
            return decrypted["message"];
          }
          return null;
        } catch (e) {
          return null;
        }

      }))).where((element) => element != null).toList();
      List successIdMessages = await MessageConversationServices.insertOrUpdateMessages(dataSuccess);
      // if (successIdMessages.length > 0) resetStatus(token);
      var grouped = dataSuccess.groupBy("conversation_id");
      grouped.map((dataConv){
        var convId  = ((dataConv as Map).keys.toList())[0];
        List<String> successIds = (dataConv[convId] as List).map((e) => e["id"].toString()).where((element) => successIdMessages.contains(element)).toList();
        // update laij snippet
        try {
          updateSnippet((dataConv[convId] as List).where((ele) =>  successIdMessages.contains(ele["id"]) && !Utils.checkedTypeEmpty(ele["parent_id"])).toList()[0]);
        } catch (e, t) {
          print("update snnnnn: $e  $t");
        }

        markReadConversationV2(token, convId, successIds, [], false);
      }).toList();
    } catch (e) {
      print("loadUnreadMessage: $e");
    }
  }

  deleteMessage(String token, String convId, Map message, {String type = "delete"})async{
    // message =  %{
    //   "id": "",
    //   "current_time": 232342
    //   "sender_id": "senderId"
    // }

    final url = "${Utils.apiUrl}direct_messages/$convId/delete_messages?device_id=${await Utils.getDeviceId()}&token=$token";
    var response = await Dio().post(url, data: {
      "data": await Utils.encryptServer({
        "data_messages": [message],
        "type": type
      })
    });
    var res = response.data;
    if (res["success"]){
      updateDeleteMessage(token, convId, message["id"], type: type);
    }
  }

  updateDeleteMessage(String token, String conversationId, String messageId, {String type = "delete"}) async {
    try {
      var currentDataDMMessage = getCurrentDataDMMessage(conversationId);
      DirectModel? dm = getModelConversation(conversationId);
      if (dm == null || currentDataDMMessage == null) return;
      String messageSnippetId = dm.snippet["message_id"] ?? "__________";
      Map? localMessage  = await MessageConversationServices.getListMessageById(dm, messageId, conversationId);
      List successIds = await MessageConversationServices.insertOrUpdateMessage(dm, {
        "conversation_id": conversationId,
        "id": messageId,
        "action": localMessage!["action"] == "delete_for_me" ? "delete_for_me" : type,
        "message": "",
        "attachments": [],
      }, type: "update");
      var indexM = (currentDataDMMessage.messages).indexWhere((element) => element["id"] == messageId);
      if (indexM != -1) {
        currentDataDMMessage.messages[indexM]["action"] = currentDataDMMessage.messages[indexM]["action"] == "delete_for_me" ? "delete_for_me" : type;
        if (type == "delete_for_me") currentDataDMMessage.messages= sortMessagesByDay(uniqById(currentDataDMMessage.messages), dm);
      }
      if (successIds.contains(messageSnippetId)){
        updateSnippet({
          ...dm.snippet,
          "action": type
        });
      }

      markReadConversationV2(token, conversationId, successIds as List<String>, [], false);
      notifyListeners();
    } catch (e) {
      print("updateDeleteMessage: $e");
    }
  }

  Future updateSettingConversationMember(String convId, Map change, String token, String userId) async {
    try {
      String url = "${Utils.apiUrl}direct_messages/$convId/setting_member?token=$token&device_id=${await Utils.getDeviceId()}";
      var response = await Dio().post(url, data: {
        "data": await Utils.encryptServer(change)
      });
      if (response.data["success"]){
        DirectModel? dm = getModelConversation(convId);
        if (dm == null) return;
        var indexUser = dm.user.indexWhere((element) => element["user_id"] == userId);
        if (indexUser == -1) return;
        dm.user[indexUser] = {
          ...(dm.user[indexUser] as Map),
          ...change
        };
        if (_directMessageSelected.id == convId) {
          _directMessageSelected = dm;
          notifyListeners();
        }
      }
    } catch (e) {
    }
  }

  changeNameConvDummy(value, idConversation) {
    var indelInData = _data.indexWhere((element) => element.id == idConversation);
    if (indelInData == -1) return;
    DirectModel currentDataConv = _data[indelInData];
    currentDataConv.name =  Utils.checkedTypeEmpty(value) ? value : getNameDM(currentDataConv.user, "", currentDataConv.name, hasIsYou: false);

    if (_directMessageSelected.id == idConversation) _directMessageSelected = currentDataConv;
    notifyListeners();

  }

  inviteMemberWhenConversationInDummy(user, idConversation){
    var indelInData = _data.indexWhere((element) => element.id == idConversation);
    if (indelInData == -1) return;
    DirectModel currentDataConv = _data[indelInData];
    var isExisted = currentDataConv.user.indexWhere((element) => element["user_id"] == user["id"]);
    var newDataConvUser = isExisted != -1
    ? currentDataConv.user.where((element) => element["user_id"] != user["id"]).toList()
    : ([] + currentDataConv.user + [{...user, "user_id": user["id"]}]);
    // only remove
    if (newDataConvUser.length < 3) return;
    currentDataConv.user = newDataConvUser;
    currentDataConv.name = getNameDM(newDataConvUser, "", currentDataConv.name, hasIsYou: false);
    if (_directMessageSelected.id == idConversation) _directMessageSelected = currentDataConv;
    notifyListeners();

  }

  void changeConversationName(Map? data, String currentUserId) {
    try {
      if (data == null) return;
      var convId = data["conversation_id"];
      var dm = getModelConversation(convId);
      if (dm != null) {
        dm.name = data["name"];
        dm.displayName = getNameDM(dm.user, currentUserId, data["name"]);
        var box = Hive.box("direct");
        box.put(dm.id, dm);
        notifyListeners();
      }
    } catch (e) {
    }
  }

  updateUnreadConversation(Map? obj){
    if (obj == null) return;
    _unreadConversation.updateFromObj(obj["data"]);
    var option= obj["option"];
    DirectModel? dm = getModelConversation(option["conversation_id"]);
    if (dm != null) {
      dm.seen = option["status"] == "read";
    }
    notifyListeners();
  }

  void deleteHistoryConversation(Map? data, userId) {
    try {
      if (data == null) return;
      var convId = data["conversation_id"];
      var time = data["time"];
      MessageConversationServices.deleteHistoryConversation(convId, userId, time);
      DirectModel? dm = getModelConversation(convId);
      if (dm == null) return;
      if ((dm.snippet["current_time"] ?? 0 )<= time) dm.snippet = {};
      var box = Hive.box('direct');
      box.put(dm.id, dm);
      int indexUser = dm.user.indexWhere((element) => element["user_id"] == userId);
      dm.user[indexUser]["delete_time"] = time;
      resetOneConversation(convId);
    } catch (e) {
    }
  }

  Future deleteHistoryConversationApi(String token, String conversationId, String currentUserId) async {
    try {
      DirectModel? dm = getModelConversation(conversationId);
      if(dm == null) return;
      var url = "${Utils.apiUrl}direct_messages/${dm.id}/delete_history?token=$token&device_id=${await Utils.getDeviceId()}";
      var response = await Dio().post(url, data: {
        "data": await Utils.encryptServer({
          "conversation_id": dm.id,
        })
      });
      if (response.data["success"]){

      }
    } catch (e) {
    }
  }

  void updateConversation(data, token, userId) {
    int index = _data.indexWhere((DirectModel ele) => ele.id == data['conversation_id']);

    if(index != -1) {
      _data[index]..avatarUrl = data['changes']['avatar_url'];
      if(_directMessageSelected.id == data['conversation_id']) _directMessageSelected..avatarUrl = data['changes']['avatar_url'];
      notifyListeners();
    }
  }

  Future markSeenMentionUser(MentionUser mention) async {
    String token = Provider.of<Auth>(Utils.globalContext!, listen: false).token;
    String url = "${Utils.apiUrl}users/unread_mention_item_from_mobile?token=$token";
    var res = await Dio().post(url, data: {
      "mention_id": mention.id
    });
    var resData = res.data;
    if (resData["success"]){
      updateSeenMention(mention.id, numberUnseen: resData["number_unseen"] ?? _dataMentionConversations.numberUnseen);
    }
  }

  void updateSeenMention(String mentionId, {int? numberUnseen}) {
    if (numberUnseen != null) _dataMentionConversations.numberUnseen = numberUnseen;
    int index = _dataMentionConversations.data.indexWhere((element) => element.id == mentionId);
    if (index != -1){
      _dataMentionConversations.data[index].seen = true;
      notifyListeners();
    }
  }

  // chi update da doc khi mention MentionUserWorkspaceMessage
  void updateSeemMentionWhenJoinChannel(int numberUnseen, int workspaceId, int channelId){
    _dataMentionConversations.numberUnseen = numberUnseen;
    _dataMentionConversations.data = _dataMentionConversations.data.map((element) {
      if (element is MentionUserWorkspaceMessage){
        if (element.channelId == channelId && element.workspaceId == workspaceId){
          element.seen = true;
        }
      }
      return element;
    });
    notifyListeners();
  }

  closeModalSync(Map data) {
    String deviceIdRequest = data["device_id_request"];
    GlobalKey<DMConfirmSharedState> dmConfirmSharedViewKey = Utils.dmConfirmSharedViewKey;
    if (dmConfirmSharedViewKey.currentState != null && dmConfirmSharedViewKey.currentState!.mounted ){
      if (dmConfirmSharedViewKey.currentState!.widget.deviceId == deviceIdRequest){
        Navigator.pop(dmConfirmSharedViewKey.currentState!.context);
      }
    }
  }

  void updateDirectByMessageTime(Map? dataUpdate) {
    if (dataUpdate  == null) return;
    String conversationId = dataUpdate["conversation_id"];
    int updateByMessageTime = dataUpdate["update_by_message_time"];
    DirectModel? dm = getModelConversation(conversationId);
    if (dm == null) return;
    dm.updateByMessageTime = updateByMessageTime;
    data.sort((a, b) => b.updateByMessageTime.compareTo(a.updateByMessageTime));
    notifyListeners();
  }

}

 extension UtilListExtension on List{
  groupBy(String key) {
    try {
      List<Map<String, dynamic>> result = [];
      List<String> keys = [];

      this.forEach((f) => keys.add(f[key]));

      [...keys.toSet()].forEach((k) {
        List data = [...this.where((e) => e[key] == k)];
        result.add({k: data});
      });

      return result;
    } catch (e) {
      // printCatchNReport(e, s);
      return this;
    }
  }
}