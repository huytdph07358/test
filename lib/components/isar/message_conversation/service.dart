import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:isar/isar.dart';
import 'package:objectbox/objectbox.dart' as ObjectBox;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workcake/E2EE/e2ee.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service_ios.dart';
import 'package:workcake/components/media_conversation/isolate_media.dart';
import 'package:workcake/components/media_conversation/model.dart';
import 'package:workcake/emoji/dataSourceEmoji.dart';
import 'package:workcake/emoji/itemEmoji.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/isar.g.dart';
import 'package:crypto/crypto.dart';
import 'package:workcake/models/models.dart';
import '../../../generated/l10n.dart';
import '../../media_conversation/drive_api.dart';
import 'message_conversation.dart';
import 'package:encrypt/encrypt.dart' as En;
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:intl/intl.dart';
// IOS dang bi loi isar
// IOS se tiep dung dung Hive, ko co tinh nang search
// ko co tinh nang load message from hive khi mat ket noi
// se dung Hive den khi nao isar ho tro

class MessageConversationServices{

  static bool isBackUping = false;
  static var _statusBackUpController = StreamController<StatusBackUp>.broadcast(sync: false);
  static Stream<StatusBackUp> get statusBackUp => _statusBackUpController.stream;

  static var statusSyncController = StreamController<StatusSync>.broadcast(sync: false);
  static StatusSync statusSyncStatic = StatusSync(-1,"", "");
  static Stream<StatusSync> get statusSync => statusSyncController.stream;

  static bool isRestoring = false;
  static var _statusRestoreController = StreamController<StatusRestore>.broadcast(sync: false);
  static Stream<StatusRestore> get statusRestore => _statusRestoreController.stream;
  static Isar? _isar;

// ham nay bi bo do cac thiet bi da chay v2
  static moveMessageFromHive(List listConversations)async {
  }

  static Future<MessageConversation?> processJsonMessage(Map data, {bool moveFromHive = false, List listConversations = const []}) async {
    try {
      if(!Utils.checkedTypeEmpty(data["conversation_id"])) throw {};
      if (data["message"] == "" && data["attachments"].length == 0 && data["action"] == "insert") return null;
      if (!Utils.checkedTypeEmpty(data["id"])) return null;
      return MessageConversation()
        ..attachments = parseListString(data["attachments"])
        ..message = data["message"]
        ..messageParse = await parseStringAtt(data)
        ..conversationId = getNewConversationId(data["conversation_id"] ?? "", [])
        ..success = true
        ..count = data["count"] ?? 0
        ..fakeId = data["fake_id"]
        ..insertedAt = DateTime.fromMicrosecondsSinceEpoch( data["current_time"]?? 0, isUtc: true).toString()
        ..isBlur = !Utils.checkedTypeEmpty(data["id"])
        ..parentId = data["parent_id"] ?? ""
        ..publicKeySender = data["public_key_sender"]
        ..sending = data["sending"] ?? false
        ..currentTime =  data["current_time"] ?? DateTime.now().microsecondsSinceEpoch
        ..dataRead = []
        ..id = data["id"] ?? ""
        ..userId = data["user_id"] ?? ""
        ..infoThread = parseListString(data["info_thread"])
        ..localId =  (data["current_time"] % 100000000000000) 
        ..lastEditedAt = data["last_updated_at"] ?? ""
        ..action = data["action"] ?? "insert"
      ;      
    } catch (e) {
      print("e: $e");
      return null;
    }


  }

  static String getNewConversationId(String id, List dataConversationIds){
    var index = dataConversationIds.indexWhere((element) => element["old_id"] == id);
    if (index == -1) return id;
    return dataConversationIds[index]["conversation_id"];
  }

  static Future<String> parseStringAtt(Map data)async{
    String result = data["message"] ?? "";
    List atts = data["attachments"] ?? [];
    for (Map att in atts){
      switch (att["type"]) {
        case "mention":
          for (Map mention in att["data"]){
            switch (mention["type"]) {
              case "all":
                result += "@all";
                break;
              case "text":
                  result += mention["value"];
                break;
              default:
                result += (mention["trigger"] ?? "@") + (mention["name"] ?? "");
            }
          }
          break;
        default:
      }
    }
    return unSignVietnamese(result.trim());
  }

  static unSignVietnamese(String text){
    final _vietnamese = 'aAeEoOuUiIdDyY';
    final _vietnameseRegex = <RegExp>[
      RegExp(r'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ'),
      RegExp(r'À|Á|Ạ|Ả|Ã|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ'),
      RegExp(r'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ'),
      RegExp(r'È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ'),
      RegExp(r'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ'),
      RegExp(r'Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ'),
      RegExp(r'ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ'),
      RegExp(r'Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ'),
      RegExp(r'ì|í|ị|ỉ|ĩ'),
      RegExp(r'Ì|Í|Ị|Ỉ|Ĩ'),
      RegExp(r'đ'),
      RegExp(r'Đ'),
      RegExp(r'ỳ|ý|ỵ|ỷ|ỹ'),
      RegExp(r'Ỳ|Ý|Ỵ|Ỷ|Ỹ')
    ];

    var result = text;
    for (var i = 0; i < _vietnamese.length; ++i) {
      result = result.replaceAll(_vietnameseRegex[i], _vietnamese[i]);
    }
    return result.toLowerCase();
  }

  static List<String> parseListString(List? data){
    if (data == null) return [];
    return data.map((e) => jsonEncode(e)).toList();
  }

  static getTimeKey(key) {
    try {        
      var tkey = key.toString().split("__")[0];
      return DateTime.parse(tkey).toUtc().millisecondsSinceEpoch;
    } catch (e) {
      return 0;
    }
  }

  static getMessageFromHive(idDirectMessage, int page, int size) async{
    var directMessageBox = Hive.lazyBox("direct_$idDirectMessage");
    var dataKey = directMessageBox.keys.toList();
    var r = dataKey;
    r.sort((a, b) {
      return getTimeKey(a) < getTimeKey(b) ? -1 : 1;
    });
    var listkeyMessage = r;
    var length = listkeyMessage.length;
    var start = length - page *size;
    var end = start - size;
    if (start < 0) start = 0;
    if (end < 0) end = 0;
    var listKeys = listkeyMessage.sublist(end, start);
    var dataR = [];
     for (var i = 0; i < listKeys.length; i++) {
      // return unix to iso string;
      var key = listKeys[i];
      dataR = [await directMessageBox.get(key)] + dataR;
    }
    return dataR;
  }

  static getNameOfConverastion(String convId, List sources){
    var index  =  sources.indexWhere((element) => element.id  == convId);
    if (index == -1) return "";
    return sources[index].name ?? sources[index].user.reduce((value, element) => "$value ${element["full_name"]}");
  }

  static Future<List> getFromHive(idConversation,int page,int size)async {
    LazyBox thread =  await Hive.openLazyBox("thread_$idConversation");
    List keys = thread.keys.toList();
    List result  = [];
    for (var i = size * page ; i < min(keys.length, size * (page +1)); i++){
      if (keys[i] != null)
        result +=[await thread.get(keys[i])];
    }
    return result;
  }

  static List<Map> parseListStringToListMap(List<String>? data){
    if (data == null) return [];
    return data.map((e) => jsonDecode(e) as Map).toList();
  }

  static Map parseMessageToJson(MessageConversation message){
    var atts = parseListStringToListMap(message.attachments);
    
    return {
      "attachments": atts,
      "local_id": message.localId,
      "message": message.message ?? "",
      "conversation_id": message.conversationId ?? "",
      "success": true,
      "count": message.count ?? 0,
      "fake_id": message.fakeId ?? "",
      "time_create": DateTime.fromMicrosecondsSinceEpoch(message.currentTime ?? 0, isUtc: true).toString(),
      "is_blur": !Utils.checkedTypeEmpty(message.id),
      "parent_id": message.parentId ?? "",
      "public_key_sender": message.publicKeySender ?? "",
      "sending": message.sending ?? false,
      "current_time": message.currentTime ?? 0,
      "data_read": parseListStringToListMap(message.dataRead),
      "info_thread": parseListStringToListMap(message.infoThread),
      "id": message.id ?? "",
      "user_id": message.userId ?? "",
      "last_edit_at": message.lastEditedAt ?? "",
      "action": message.action ?? "insert",
      "is_system_message": message.id == "headerMessage" ? true : checkIsSystemMessageDM(atts),
    };
  }

  static bool checkIsSystemMessageDM(List atts){
    return atts.indexWhere((ele) =>  ele["type"] == "update_conversation" || ele["type"] == "leave_direct" || ele["type"] == "invite_direct" || ele["type"] == "change_direct_name") >= 0;
  }

  static Future<List> searchMessage(String text, {int limit = 10, int offset = 0, bool parseJson = false}) async {
    if (Platform.isIOS) return await MessageConversationIOSServices.searchMessage(text, limit: limit, offset: offset, parseJson: parseJson);
    Isar isar = await getIsar();
    LazyBox box = Hive.lazyBox("pairKey");
    List<String> convIds = (((await box.get("conversation_ids")) ?? <String>[]) as List).whereType<String>().toList();
    // var m  =  DateTime.now().microsecondsSinceEpoch;
    List<MessageConversation> dataIsar = await isar
      .messageConversations
      .where()
      .filter()
      .messageParseContains(unSignVietnamese(text))
      .and()
      .group((q) => q.repeat(convIds, (q, element) => q.conversationIdContains(element as String)))
      // .messageParseWordStartsWith(unSignVietnamese(text))
      .sortByCurrentTimeDesc()
      .distinctById()
      // .messageParseWordEqualTo(text)
      .offset(offset)
      .limit(limit)
      .findAll();
      // print(data);
    // print("DateTime.now().microsecondsSinceEpoch : ${DateTime.now().microsecondsSinceEpoch -m}  ${data.length}");
    List uniqIds = dataIsar.map((e) => e.id).toSet().toList();
    List<MessageConversation> data = uniqIds.map((e) => dataIsar.firstWhere((element) => element.id == e)).toList();
    if (parseJson){
      return data.map((e) => parseMessageToJson(e)).toList();
    }
    return data;
  }

  static Future<List> getMessageDown(DirectModel dm, String conversationId, int deleteTime, {Isar? isar, ObjectBox.Store? store, int currentTime = 0, int limit = 30, int offset = 0, bool parseJson = false, bool isParentMessage = true}) async {
    if (deleteTime >= currentTime || currentTime == 0) return [];
    if (Platform.isIOS) return MessageConversationIOSServices.getMessageDown(dm, conversationId, deleteTime, currentTime: currentTime, parseJson: parseJson, limit: limit, isParentMessage: isParentMessage, store: store);
    try {
      isar = isar != null ? isar : await getIsar();
      // print("currentTime $currentTime   $conversationId");
      List<MessageConversation> dataIsar = await isar
        .messageConversations
        .where()
        .parentIdConversationIdEqualTo("", conversationId)
        .filter()
        .currentTimeBetween(deleteTime, currentTime)
        .and()
        .not()
        .actionEqualTo("delete_for_me")
        .and()
        .not()
        .actionEqualTo("reaction")
        .sortByCurrentTimeDesc()
        .distinctById()
        .optional(offset > -1, (m) => m.offset(offset))
        .limit(limit)
        .findAll();
      // lay thong tin thread
      // print("DateTime.now().microsecondsSinceEpoch  $currentTime :${data.length} ${DateTime.now().microsecondsSinceEpoch -m}");
      if (parseJson) {
        List result = dataIsar.map((e) => parseMessageToJson(e)).toList();
        return await Future.wait(result.map((e) async{
          return await loadInfoThreadMessage(dm, e, isar: isar);
        }));
      }
      return dataIsar;
    } catch (e, t) {
      debugPrint(t.toString());
      return [];
    }
  }

  static getUserInfoMessage(DirectModel dm, Map message){
    var indexUser = dm.user.indexWhere((element) => element["user_id"] == message["user_id"]);
    Map ui = {};
    if (indexUser != -1) ui = {
      "full_name": dm.user[indexUser]["full_name"],
      "avatar_url": dm.user[indexUser]["avatar_url"]
    };
    return {
      ...message,
      ...ui
    };
  }

  static Future<Map> loadInfoThreadMessage(DirectModel dm, Map message, {Isar? isar, ObjectBox.Store? store})async{
    List threads = await getMessageThreadAll(dm, dm.id, message["id"], parseJson: true, isar: isar, store: store);
    return {
      ...(getUserInfoMessage(dm, message)),
      "info_thread": threads
    };
  }

  static Future<List> getMessageToTranfer(List convIds, { int limit = 30, int offset = -1, bool parseJson = false, ObjectBox.Store? store, Isar? isar}) async {
    if (Platform.isIOS) return MessageConversationIOSServices.getMessageToTranfer(convIds, limit: limit, offset: offset, parseJson: parseJson, store: store);
    try {
      if (isar == null) isar = await getIsar();
      List<MessageConversation> data = await isar
        .messageConversations
        .where()
        .filter()
        .group((q) => q.repeat(convIds, (q, element) => q.conversationIdContains(element as String)))
        .sortByCurrentTimeDesc()
        .distinctById()
        .optional(offset > -1, (m) => m.offset(offset))
        .limit(limit)
        .findAll();
      if (parseJson)
        return data.map((e) => parseMessageToJson(e)).toList(); 
      return data;
    } catch (e) {
      print("getMessageToTranfer $e");
      return [];
    }

  }

  static Future<List> getMessageThreadAll(DirectModel dm, String conversationId, String parentId, { bool parseJson = false, Isar? isar, ObjectBox.Store? store,}) async {
    if (Platform.isIOS) return MessageConversationIOSServices.getMessageThreadAll(dm, conversationId, parentId, parseJson: parseJson, store: store);
    try {
      if (isar == null) isar = await getIsar();
      List<MessageConversation> data = await isar
        .messageConversations
        .where()
        .filter()
        .parentIdEqualTo(parentId)
        .and()
        .not()
        .actionEqualTo("reaction")
        .sortByCurrentTimeDesc()
        .distinctById()
        .findAll();
      if (parseJson)
        return data.map((e) => getUserInfoMessage(dm, parseMessageToJson(e))).toList();
      return data;
    } catch (e, t){
      print("getMessageThreadAll $e $t");
      return [];
    }
  }

  static Future<List> getMessageUp(String conversationId, int deleteTime, {int currentTime = 0, int limit = 30, int offset = -1, bool parseJson = false, Isar? isar, ObjectBox.Store? store}) async {
    var boxDm = Hive.box("direct");
    DirectModel dm  = boxDm.get(conversationId);
    int timeGreater = deleteTime >= currentTime ? deleteTime : currentTime;

    if (Platform.isIOS) return MessageConversationIOSServices.getMessageUp(conversationId, deleteTime, currentTime: currentTime, parseJson: parseJson, limit: limit, store: store);
    try {
      isar = isar == null ? await getIsar() : isar;
      List<MessageConversation> data = await isar
        .messageConversations
        .where()
        .filter()
        .parentIdEqualTo("")
        .and()
        .conversationIdEqualTo(conversationId)
        .and()
        .currentTimeGreaterThan(timeGreater)
        .and()
        .not()
        .actionEqualTo("delete_for_me")
        .and()
        .not()
        .actionEqualTo("reaction")
        .sortByCurrentTime()
        .distinctById()
        .optional(offset > -1, (m) => m.offset(offset))
        .limit(limit)
        .findAll();
      if (parseJson) {
        List result = data.map((e) => parseMessageToJson(e)).toList();
        return await Future.wait(result.map((e) async{
          return await loadInfoThreadMessage(dm, e, isar: isar);
        }));
      }
      return data;
    } catch (e){
      print("getMessageUp  $e");
      return [];
    }
  }

  static Future<List> getListMessageByIds(List<String> ids, {bool parseJson = false}) async {
    if (Platform.isIOS) return MessageConversationIOSServices.getListMessageByIds(ids);
    try {
      Isar isar = await getIsar();
      List<MessageConversation> data = await isar
        .messageConversations
        .where()
        .filter()
        .repeat(ids, (q, String id) => q.idEqualTo(id))
        .sortByCurrentTime()
        .findAll();

      if (parseJson) 
        return data.map((e) => parseMessageToJson(e)).toList(); 
      return data;
    } catch (e) {
      print("getListMessageByIds: $e");
      return [];
    }
  }

  static Future<Map?> getListMessageById(DirectModel dm, String id, String conversationId, {Isar? isar, ObjectBox.Store? store}) async {
    if (Platform.isIOS) {
      return MessageConversationIOSServices.getListMessageById(dm, id, conversationId, store: store);
    }

    try {
      isar = isar == null ? await getIsar() : isar;
      MessageConversation? data = await isar
        .messageConversations
        .where()
        .filter()
        .idContains(id)
        .and()
        .conversationIdEqualTo(conversationId)
        .and()
        .parentIdEqualTo("")
        // .idEqualTo(id)
        // .optional(id != "", (q) => q.idEqualTo(id))
        // .optional(id == "", (q) => q.filter().conversationIdEqualTo(conversationId))
        .sortByCurrentTimeDesc()
        .findFirst();

      if (data == null) return null;
      return loadInfoThreadMessage(dm, parseMessageToJson(data), isar: isar, );      
    } catch (e){
      print("getListMessageById $e");
      return null;
    }

  }

  static Future<Map?> getLastMessageOfConversation(String conversationId, {bool isCheckHasDM = true}) async {
    var boxDm = Hive.box("direct");
    DirectModel? dm  = boxDm.get(conversationId);
    if (dm == null && isCheckHasDM) return null;
    if (Platform.isIOS) {
      return MessageConversationIOSServices.getLastMessageOfConversation(conversationId, isCheckHasDM: isCheckHasDM);
    }
    try {
      Isar isar = await getIsar();
      MessageConversation? data = await isar
        .messageConversations
        .where()
        .filter()
        .conversationIdEqualTo(conversationId)
        .and()
        .not()
        .actionEqualTo("delete_for_me")
        .and()
        .parentIdEqualTo("")
        .sortByCurrentTimeDesc()
        .findFirst();

        // print("$id $data");
      if (data == null) return null;
      if (!isCheckHasDM) return parseMessageToJson(data);
      if (dm == null) return null;
      return loadInfoThreadMessage(dm, parseMessageToJson(data));      
    } catch (e){
      print("getListMessageById $e");
      return null;
    }

  }

  static Future<List<String>> insertOrUpdateMessage(DirectModel dm, Map message, {String type = "insert", Isar? isar, ObjectBox.Store? store}) async {
    if (message["message"] == "" && message["attachments"].length == 0 && message["action"] == "insert")  return [];
    if (Platform.isIOS) {
      return await MessageConversationIOSServices.insertOrUpdateMessage(dm, message, type: type, store: store);
    }
    try {
      if (isar == null) isar = await getIsar();
      MessageConversation? dataInsert;
      if (type == "insert"){
        dataInsert = await processJsonMessage(message);
      } else {
        var messageExisted =  await isar.messageConversations.where().filter().idContains(message["id"]).findFirst();
        if (messageExisted == null) return [];
        dataInsert = await processJsonMessage({
          ...(parseMessageToJson(messageExisted)),
          ...message
        });
      }
      if (dataInsert == null) return [];
      await isar.writeTxn((isar) async => 
        await isar.messageConversations.put(dataInsert!)
      );  
      return (await Future.wait([dataInsert].map((e) async {
        try {
          return (await isar?.messageConversations.get(e.localId!))?.id;
        } catch (e) {
          return null;
        }
        
      }))).whereType<String>().toList(); 
    } catch (e) {
      print("insertOrUpdateMessage $e");
      return [];
    }
  }

  static Future<List<Map>?> getReactionMessage(String messageId, String conversationId, Isar? isar, ObjectBox.Store? store) async {
    try {
      if (Platform.isIOS) return MessageConversationIOSServices.getReactionMessage(messageId, conversationId, store);
      if (isar == null) return null;
      List<MessageConversation>? data = await isar
        .messageConversations.where()
        .parentIdConversationIdEqualTo(messageId, conversationId)
        .filter()
        .actionEqualTo("reaction")
        .findAll();

        // print("$id $data");
      if (data.isEmpty) return null;
      data.sort((a, b) => a.currentTime!.compareTo(b.currentTime!));
      return data.map((e) => parseMessageToJson(e)).toList();

    } catch (e){
      // print("getListMessageById $e");
      return null;
    }

  }

  static Future<bool> insertHiveOnIOS(Map message) async {
    try {
      // id la id cua message
      var boxIOS = Hive.lazyBox("messageConversation");
      await boxIOS.put(message["id"], message);    
      return true;  
    } catch (e) {
      return false;
    }
  }

  static Future<bool> insertHiveOnIOSMany(List messages) async {
    try {
      var result = {};
      for(var m in messages){
        result[m["id"]] = m;
      }
      var boxIOS = Hive.lazyBox("messageConversation");
      await boxIOS.putAll(result);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<String>> insertOrUpdateMessages(List messages, {bool moveFromHive = false, Isar? isar, ObjectBox.Store? store}) async {
    if (Platform.isIOS) {
      return await MessageConversationIOSServices.insertOrUpdateMessages(messages, store: store);
    }
    try {
      isar = isar != null ? isar : await getIsar();
      List<MessageConversation?> dataInsert = await Future.wait(messages.map((e) => processJsonMessage(e, moveFromHive: moveFromHive)));
      List<MessageConversation> many = dataInsert.whereType<MessageConversation>().toList();
      await isar.writeTxn((isar) async {
        try {
          await isar.messageConversations.putAll(many);
          // for (Map message in messages){
          //   var t  = await processJsonMessage(message, moveFromHive: moveFromHive);
          //   if (t == null) continue;
          //   await isar.messageConversations.put(t);
          //   successIds += [t.id ?? ""];
          // }          
        } catch (e) {
          print("+++++++ $e");
        }

      });
      return (await Future.wait(many.map((e) async {
        try {
          return (await isar!.messageConversations.get(e.localId!))?.id;
        } catch (e) {
          return null;
        }
      }))).whereType<String>().toList();  
    } catch (e, t) {
      print(">>>> insertOrUpdateMessages: $e, $t");
      return [];
    }    
  }

  static Future<int> getTotalMessage({ObjectBox.Store? store, Isar? isar})async{
    if (Platform.isIOS) return MessageConversationIOSServices.getTotalMessage(store: store);
    if (isar == null) isar = await getIsar();
    return await isar.messageConversations.where().distinctById().count();
  }

  static Future<Isar> getIsar() async{
    if (_isar != null) return _isar!;
    var newDir = await getApplicationSupportDirectory();
    var newPath = newDir.path + "/pancake_chat_data";
    _isar = await openIsar(directory: newPath);
    return _isar!;
  }

  static List<Map> uniqById(List dataSource, {bool isRemoveDeteforMe = true}){
    // sap xep thep moi -> cu
    // uniq tren id vaf fake_id
    List<Map> results = [];
    Map index = {};
    for (var i in dataSource){
      // if (!Utils.checkedTypeEmpty(i["id"] && success)
      var key = Utils.checkedTypeEmpty(i["id"]) ? i["id"] : Utils.checkedTypeEmpty(i["fake_id"]) ? i["fake_id"] : "";
      if ( !Utils.checkedTypeEmpty(key)) continue;
      if (isRemoveDeteforMe && i["action"] == "delete_for_me") continue;
      if (index[key] == null){
         results += [i];
         index[key] = results.length -1;
      } else {
        results[index[key]] = Utils.mergeMaps([results[index[key]], i]);
      }
    }
    if (results.length <= 1) return results;
    results.sort((a,  b) => (b["current_time"] ?? ((DateTime.parse(b["inserted_at"] ?? b["time_create"])).toUtc().millisecondsSinceEpoch) ?? 0).compareTo((a["current_time"] ?? ((DateTime.parse(a["inserted_at"] ?? a["time_create"])).toUtc().millisecondsSinceEpoch) ?? 0))); 
    return results;    
  }

  static List processMessageConversationByDay(List dataMessages, DirectModel dataDirectMessage){
    List messages = uniqById(dataMessages);
    // messages la list cac tin nhan lay tu isar/api, dc sap xep theo thu tu tu cu -> moi
    // dau ra la list co dang, thoi gian dc sap xep theo thu tu moi -> cu
    //    [
    //      {"dataTime": "", "messages": []}
    //    ]
    bool showNewUser = false;
    if (messages.length  == 0 ) return [];
    int length = messages.length;
    List results = [];
    for(int index = 0; index < length; index++){
      try {
        // set = true khi do la tin nhan dau tien hoac datetime khac voi tin  nhan truoc do
        bool isShowDate = index == 0;
        DateTime dateTime = DateTime.parse(messages[index]["inserted_at"] ?? messages[index]["time_create"]);
        var isAfterThread = (index + 1) < (length)
          ? (((messages[index + 1]["count"] ?? 0) > 0))
          : true;
        List attachments =  messages[index]["attachments"] != null && messages[index]["attachments"].length > 0
          ? messages[index]["attachments"]
          : [];
        String fullName = "";
        String avatarUrl = "";
        var u = dataDirectMessage.user.where((element) => element["user_id"] == messages[index]["user_id"]).toList();
        if (u.length > 0) {
          fullName = u[0]["full_name"];
          avatarUrl = u[0]["avatar_url"] ?? "";
        }
        var isFirst = (index + 1) < length
          ? ((messages[index + 1]["user_id"] != messages[index]["user_id"]))
          : true;
        var isLast= index == 0  ? true : messages[index]["user_id"] != messages[index - 1]["user_id"] ;
        if (index >= 1){
          DateTime prevDateTime = DateTime.parse(messages[index - 1]["inserted_at"] ?? messages[index - 1]["time_create"]);  
          // print("${dateTime.day }  / ${dateTime.month }  / ${dateTime.year } -----  ${prevDateTime.day }  / ${prevDateTime.month }  / ${prevDateTime.year }");
          isShowDate = dateTime.day != prevDateTime.day || dateTime.month != prevDateTime.month ||  dateTime.year != prevDateTime.year;
        }
        if ((index + 1) < (length)) {
          showNewUser = (messages[index + 1]["current_time"] - messages[index]["current_time"]).abs() < 600000000;
        }
        var currentMessage = Utils.mergeMaps([
          messages[index],
          {
            "isAfterThread": isAfterThread,
            "attachments": attachments,
            "fullName": fullName,
            "avatarUrl": avatarUrl,
            "isFirst": isFirst,
            "isLast": isLast,
            "showNewUser": !showNewUser
          }
        ]);

        // print("isShowDate __ ${isShowDate}");
        if (isShowDate){
          results += [{
            "dateTime": dateTime,
            "messages": [currentMessage],
          }];
        } else {
          results[results.length - 1]["messages"]= [Utils.mergeMaps([
              messages[index],
              currentMessage
            ])] + results[results.length - 1]["messages"];
        }
      } catch (e) {
        // print("$e   ${messages[index]}");
      }

    }

    // print(results.reversed.toList());
    return results.reversed.toList();
  }


  static List processMessageChannelByDay(List dataSource){
    List messages = dataSource.map((mes) => Utils.mergeMaps([
      mes, 
      {
        "current_time": (DateTime.parse(mes["inserted_at"] ?? mes["time_create"])).toUtc().millisecondsSinceEpoch
      }
    ])).toList();
    // messages la list cac tin nhan lay tu isar/api, dc sap xep theo thu tu tu cu -> moi
    // dau ra la list co dang, thoi gian dc sap xep theo thu tu moi -> cu

    if (messages.length  == 0 ) return [];
    if (messages.length > 1){
      messages.sort((a,  b) => (b["current_time"] ?? 0).compareTo((a["current_time"] ?? 0)));    
    }
    int length = messages.length;
    List results = [];
    for(int index = 0; index < length; index++){
      // set = true khi do la tin nhan dau tien hoac datetime khac voi tin  nhan truoc do
      bool isShowDate = index == 0;
      var e = messages[index];
      DateTime dateTime = DateTime.parse(e["inserted_at"] ?? e["time_create"]);
      var timeStamp = dateTime.toUtc().millisecondsSinceEpoch;
      bool showNewUser = false;

      if (index > 0) {
        DateTime nextTime = DateTime.parse(messages[index - 1]["inserted_at"] ?? messages[index - 1]["time_create"]);
        isShowDate = dateTime.day != nextTime.day || dateTime.month != nextTime.month ||  dateTime.year != nextTime.year;
      }

      if ((index + 1) < (length)) {
        showNewUser = (messages[index]["current_time"] - messages[index + 1]["current_time"]) < 600000;
      }

      var isFirst = (index + 1) < length
        ? ((messages[index + 1]["user_id"] != messages[index]["user_id"]) || messages[index + 1]["is_system_message"])
        : true;
      var isLast= index == 0  ? true : messages[index]["user_id"] != messages[index - 1]["user_id"] ;
      var currentMessage = Utils.mergeMaps([
        messages[index],
        {
          "isChildMessage": false,
          "isFirst": isFirst,
          "isLast": isLast,
          "showNewUser": !showNewUser,
          "current_time": timeStamp,
          "isAfterThread": false
        }
      ]);

      if (isShowDate){
        results += [{
          "dateTime": dateTime,
          "messages": [currentMessage],
        }];
      } else {
        if (results.length > 0)
          results[results.length - 1]["messages"]= [Utils.mergeMaps([
              messages[index],
              currentMessage
            ])] + results[results.length - 1]["messages"];
      }
    }
    return results.reversed.toList();
  }

  static processReaction(List listDataSource){
    List reactions =listDataSource; 
    List resultEmoji = [];
    List totalDataSource = [] + dataSourceEmojis;
    for (int i = 0; i < reactions.length; i++) {
      // check them truong hop da xu ly reactions t
      if (reactions[i]["emoji"] != null) {
        resultEmoji += [reactions[i]];
        continue;
      }
      int indexR = resultEmoji.indexWhere((element) => (element["emoji"] as ItemEmoji).id == reactions[i]["emoji_id"]);
      int indexReactEmoji = totalDataSource.indexWhere((emo) {
        return (emo["id"] ?? emo["emoji_id"]) == reactions[i]["emoji_id"];
      });
      if (indexReactEmoji == -1) {
        continue;
      }
      if (indexR == -1){
        resultEmoji = resultEmoji + [{
          "emoji": ItemEmoji.castObjectToClass(totalDataSource[indexReactEmoji]),
          "users": [reactions[i]["user_id"]],
          "count": 1
        }];
      }
      else {
        resultEmoji[indexR] = {
          "users": resultEmoji[indexR]["users"] + [reactions[i]["user_id"]],
          "count": resultEmoji[indexR]["count"] + 1,
          "emoji": resultEmoji[indexR]["emoji"],
        };
      }
    }
    return resultEmoji;
  }

  static Future<List> processBlockCodeMessage(List data) async {
    return await Future.wait(data.map((mes)async{
      try {
        Map result = mes;
        try {
          result = {
            ...result,
            "reactions": processReaction(mes["reactions"])
          };          
        } catch (e) {
        }
        List blockCode = mes["attachments"] != null ? mes["attachments"].where((e) => e["mime_type"] == "block_code").toList() : [];
        List newListHtml = mes["attachments"] != null ? mes["attachments"].where((e) => e["mime_type"] == "html").toList() : [];
        if (newListHtml.length > 0)
          result = Utils.mergeMaps([result, {"snippet":  await Utils.handleSnippet(newListHtml[0]["content_url"], false)} ]);
        if (blockCode.length > 0) 
          result = Utils.mergeMaps([result, {"block_code": await Utils.handleSnippet(blockCode[0]["content_url"], true)} ]);
        
        int index = mes["attachments"] != null ? mes['attachments'].indexWhere((ele) => ele['mime_type'] == 'share') : -1;
        if(index != -1) {
          final List newData = await processBlockCodeMessage([mes['attachments'][index]['data']]);
          result['attachments'][index]['data'] = newData[0];
        }
        checkShareMessageFromDM(result, false);

        return result;
      } catch (e) {
        print("_____ $e");
        return mes;
      }
    }));
  }

  static shaString(List dataSource, {String typeOutPut = "hex"}){
    dataSource.sort((a, b) {
      return a.compareTo(b);
    });
    Digest y  = sha256.convert(
      utf8.encode(dataSource.join("_"))
    );
    if (dataSource.length <= 2)
      return base64Url.encode(y.bytes);
    if (typeOutPut == "hex") return y.toString();
    return base64Url.encode(y.bytes);
  }

  static Map getHeaderMessageConversation(){
    return {
      "is_system_message": true,
      "message": "",
      "attachments": [
        {
          "type": "header_message_converastion",
          "data": S.current.messagesAndCallsInThisChatWill
        }
      ],
      "id": "headerMessage",
      "user_id": "",
      "full_name": "",
      "inserted_at": DateTime.now().toString(),
      "isBlur": false,
      "count_child": 0,
      "avatar_url": "",
      "isFirst": false,
      "isLast": false,
      "current_time": 0
    };
  }

  //  hamf nay chi dc thu thi sau khi da 
  static Future<void> resendMessageConversation(String token, Map dataMessageConversation, BuildContext context, {int retryTime = 5}) async {
    var currentUser = Provider.of<User>(context, listen: false).currentUser;
    if (Utils.checkedTypeEmpty(Provider.of<DirectMessage>(context, listen: false).errorCode)) return;
    if (retryTime == 0) return;
    // check dk de tin nhan dc gui di la app da goi api getDataDirectMessage va success
        
    List listIds = dataMessageConversation["list_message_ids"];
    if (listIds.length == 0) return;
    bool readyToSend = await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(token, dataMessageConversation["conversation_id"], forceLoad: true);
    if (readyToSend && Utils.checkedTypeEmpty(currentUser["id"])){
      String conversationId = dataMessageConversation["conversation_id"];
      await Future.wait(listIds.map((id) async {
        DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(conversationId);
        if (dm == null) return;
        Map? dataLocal = await getListMessageById(dm, id, conversationId);
        if (dataLocal != null && dataLocal["user_id"] == currentUser["id"]) {
          Provider.of<DirectMessage>(context, listen: false).queueBeforeSend({
            ...dataLocal,
            "isSend": false
          }, token);
        }
      }));
    } else {
      await Future.delayed(Duration(seconds: 2));
      return resendMessageConversation(token, dataMessageConversation, context, retryTime: retryTime - 1);
    }
  }


  static Future<List> mergeDataLocal(DirectModel dm, String conversationId, List apiData, int rootCurrentTime, String type, int deleteTime, {Isar? isar, ObjectBox.Store? store}) async {
    try {
       List dataLocal = [];
      if (type == "down")
        dataLocal = await getMessageDown(dm, conversationId, deleteTime, parseJson: true, currentTime: rootCurrentTime, isar: isar, store: store);
      else dataLocal = await getMessageUp(conversationId, deleteTime, currentTime: rootCurrentTime, parseJson: true, isar: isar, store: store);
      var lengthLocal = uniqById(dataLocal).length;
      if (lengthLocal == 0) return apiData;
      List result = (uniqById([] + dataLocal + apiData, isRemoveDeteforMe: false)).where((element) => element["current_time"] >= deleteTime).toList();
      return result.sublist(0, lengthLocal );      
    } catch (e, t) {
      print("mergeDataLocal: $e, $t");
      return [];
    }
  }

  static void saveSharedKeyToNative(List<ConversationMessageData> dataDMMessages) async {
    try {
      var dataKeys = dataDMMessages.map((ele){
        try {
          return ele.conversationKey?.toJson();
        } catch (e) {
          return {};
        }
      }).toList();
      List<Map<String, String>> total = [];
      for (var i = 0; i < dataKeys.length; i++) {
        if (dataKeys[i] == null) continue;
        if (dataKeys[i]?["member_keys"] == null) continue;
        for (var j = 0; j < dataKeys[i]?["member_keys"].length; j++) {
          
          var ele = dataKeys[i]?["member_keys"][j];
          total += [
            {"key": "${ele["user_id"]}_${dataKeys[i]?["conversation_id"]}",
            "value": "${ele["shared_key"]}"}
          ];
        }
      }
      total += [
        {
          "key": "token",
          "value": Provider.of<Auth>(Utils.globalContext!, listen: false).token
        }, {
          "key": "user_id",
          "value": Provider.of<Auth>(Utils.globalContext!, listen: false).userId
        }, {
          "key": "device_id",
          "value": await Utils.getDeviceId()
        }, {
          "key": "encrypted_data",
          "value":  await Utils.encryptServer({
            "version_api": 2,
            "success_ids": [],
            "error_ids": [],
            "has_mark": true
          })
        }
      ];

      await Work.platform.invokeMethod("shared_key", total);  
    } catch (e) {
      print("________ $e");
    }
  }

  static deleteHistoryConversation(String conversationId, String userId, int deleteTime, {Isar? isar}) async {
    try {

      if (isar == null) isar = await getIsar();
      await isar.writeTxn((isar) async => 
        await isar.messageConversations.where()
        .filter()
        .conversationIdEqualTo(conversationId)
        .and()
        .currentTimeLessThan(deleteTime)
        .deleteAll());
    } catch (e, t) {
      print("deleteHistoryConversation: $e, $t");
    }
  }



  static makeBackUpMessageJsonV1(List convIds, String userId, {String keyE2E = "4PxSnVX5sa2bu3TtH+o2BE0yBWdtvhOa7APGqT5FTCE="}) async {
    try {
      isBackUping = true;
      _statusBackUpController.add(StatusBackUp(100, "Preparing  messages"));
      List<int> bytes = await getDataMessageToTranfer(convIds, keyE2E: keyE2E);
      Directory? appDocDirectory;
      await Future.delayed(Duration(milliseconds: 300));
      _statusBackUpController.add(StatusBackUp(102, "Creating backup file"));
      print("Creating backup filee");
      appDocDirectory = await getApplicationDocumentsDirectory();
      var path = appDocDirectory.path;
      String nameBackUp = "backup_message_v1_encrypted_$userId.text";
      File file = File("$path/$nameBackUp");
      await Future.delayed(Duration(milliseconds: 300));
      await file.writeAsBytes(bytes, mode: FileMode.write);
      await Future.delayed(Duration(milliseconds: 300));
      print("Uploading the backup fil");
      _statusBackUpController.add(StatusBackUp(103, "Uploading the backup file"));
      if (userId != "all")
       await DriveService.uploadFile(Media(0, "$path/$nameBackUp", "", "backup_message_v1_encrypted_$userId.text", "backup", "", bytes.length, "", "downloaded", 1));
      _statusBackUpController.add(StatusBackUp(200, "Done"));
      isBackUping = false;
    } catch (e) {
      isBackUping = false;
      _statusBackUpController.add(StatusBackUp(105, "$e"));
    }
  }

  static Future<List<int>> getDataMessageToTranfer(List convIds, {String keyE2E = "4PxSnVX5sa2bu3TtH+o2BE0yBWdtvhOa7APGqT5FTCE=", ObjectBox.Store? store, Isar? isar}) async {
    int totalMessage  = await getTotalMessage(store: store, isar: isar);
    List total = [];
    await Future.delayed(Duration(milliseconds: 300));
    var page = 1000; int totalPage = (totalMessage / page).round() + 1; int size = 1000;
    List<int> pages = List<int>.generate(totalPage, (int index) => index);
    List promissLoadMessages = await Future.wait(pages.map((i) => getMessageToTranfer(convIds, limit: size, offset: i * size, parseJson: true, store: store, isar: isar)));
    total = promissLoadMessages.reduce((value, element) => value += element);
    String text = jsonEncode(total);
    await Future.delayed(Duration(milliseconds: 300));
    _statusBackUpController.add(StatusBackUp(101, "Encrypting data"));
    final key = En.Key.fromBase64(keyE2E);
    final iv = En.IV.fromLength(16);
    final encrypter = En.Encrypter(En.AES(key, mode: En.AESMode.cbc));
    return  encrypter.encrypt(text, iv: iv).bytes;
  }

  static reStoreBackUpFile(String userId, {String keyE2E = "4PxSnVX5sa2bu3TtH+o2BE0yBWdtvhOa7APGqT5FTCE="}) async {
    try {
      // tim lai file backUp.
      await Future.delayed(Duration(milliseconds: 300));
      _statusRestoreController.add(StatusRestore(110, "Look for backups"));

      Directory? appDocDirectory;
      appDocDirectory = await getApplicationDocumentsDirectory();
      var path  = appDocDirectory.path;
      String nameBackUp = "backup_message_v1_encrypted_$userId.text";
      File file = File("$path/$nameBackUp");
      List<int> dataBackup = [];
      // uu tien tien lay tren drive truoc
      if (await DriveService.checkIsSigned()){
        await Future.delayed(Duration(milliseconds: 300));
        _statusRestoreController.add(StatusRestore(110, "Search for backup files in the cloud"));
        gdrive.File? driveBackup = await DriveService.getFileBackUpMessage(backupName: nameBackUp);
        _statusRestoreController.add(StatusRestore(111, "Getting backup files"));
        await Future.delayed(Duration(milliseconds: 300));
        if (driveBackup == null) {
          if (file.existsSync()){
            dataBackup = await file.readAsBytes();
          } 
          else  {
            _statusRestoreController.add(StatusRestore(200, "Done, file not found"));
            return;
          }
        } else {
          dataBackup = (await DriveService.getContentFile(driveBackup.id ?? ""))!;
        }
      } else {
        if (file.existsSync()){
          dataBackup = await file.readAsBytes();
        } else  {
          _statusRestoreController.add(StatusRestore(200, "Done, file not found"));
          return;
        }
      }

      await Future.delayed(Duration(milliseconds: 300));
      _statusRestoreController.add(StatusRestore(111, "Decrypt backup data"));

      final key = En.Key.fromBase64(keyE2E);
      final iv  =  En.IV.fromLength(16);
      final encrypter = En.Encrypter(En.AES(key, mode: En.AESMode.cbc));  
      var encrypted =  En.Encrypted(dataBackup as Uint8List);
      var dataDecrypt =  encrypter.decrypt(encrypted, iv: iv);

      await Future.delayed(Duration(milliseconds: 300));
      _statusRestoreController.add(StatusRestore(112, "Processing"));

      var decryptData = jsonDecode(dataDecrypt);
      // List totalPages = List.generate(totalPage, (index) => index);
      // await Future.wait(totalPages.map((i) async {
      //   print("???????____: $i");
      //   await MessageConversationServices.insertOrUpdateMessages(decryptData.sublist(i, i*page > totalMessage ? totalMessage :  (i*page)));
      // }));
      // for(int i = 0; i <= totalPage; i++){
      //   await MessageConversationServices.insertOrUpdateMessages(decryptData.sublist(i > totalMessage ? totalMessage : i, i*page > totalMessage ? totalMessage : (i*page)));
      //   await Future.delayed(Duration(milliseconds: 100));
      //   _statusRestoreController.add(StatusRestore(112, "Processing(${i * page} / $totalMessage)"));
      // }
      await MessageConversationServices.saveJsonDataMessage(decryptData);
      await Future.delayed(Duration(milliseconds: 300));
      _statusRestoreController.add(StatusRestore(200, "Done"));

    } catch (e) {
      print("reStoreBackUpFile: $e");
      _statusRestoreController.add(StatusRestore(103, "error $e"));
    }

  }

  static Future<Map?> processDataToLoginViaQr() async {
    try {
      Box direct = await  Hive.openBox('direct');
      LazyBox box = Hive.lazyBox('pairkey');
      var resultConv = [];
      for(int i =0; i< direct.keys.length; i++ ){
        resultConv += [{
          "id": direct.values.toList()[i].id,
          "snippet": direct.values.toList()[i].snippet,
          "updateByMessageTime": direct.values.toList()[i].updateByMessageTime,
          "userRead": direct.values.toList()[i].userRead,
          "insertedAt": (direct.values.toList()[i] as DirectModel).insertedAt
        }];
      }
      List keys  =  box.keys.toList();
      var result = {};
      for (var i = 0; i< keys.length; i++){
        if (keys[i] == "identityKey" || keys[i] == "deviceId") continue;
        result[keys[i]] = await box.get(keys[i]);
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final extractedUserData = json.decode((prefs.getString('userData') ?? ""));
      return {
        "direct_data": result,
        "conv_data": resultConv,
        "user_data": extractedUserData,
      };
    } catch (e, t) {
      print("_____e: $e $t");
    }
    return null;
  }

  static saveJsonDataMessage(List decryptDataEncoded, {ObjectBox.Store? store, Isar? isar}) async {
    if (Platform.isIOS) return MessageConversationIOSServices.insertOrUpdateMessages(decryptDataEncoded, store: store);
    List<Map<String, dynamic>> decryptData = await Future.wait(decryptDataEncoded.map<Future<Map<String, dynamic>>>((e) async {
      return {
        "attachments": parseListString(e["attachments"]),
        "localId": e["local_id"],
        "message": e["message"] ?? "",
        "conversationId": e["conversation_id"] ?? "",
        "success": e["success"] ?? true,
        "count": e["count"] ?? 0,
        "fakeId": e["fake_id"] ?? "",
        "timeCreate": e["time_create"],
        "isBlur": e["is_blur"] ?? false,
        "isSystemMessage": e["is_system_message"] ?? false,
        "parentId": e["parent_id"] ?? "",
        "publicKeySender": e["public_key_sender"] ?? "",
        "sending": e["sending"] ?? false,
        "currentTime": e["current_time"],
        "dataRead": [],
        "infoThread": parseListString(e["info_thread"]),
        "id": e["id"] ?? "",
        "userId": e["user_id"] ?? "",
        "lastEditedAt": e["last_edited_at"] ?? "",
        "action": e["action"] ?? "insert",
        "messageParse": await parseStringAtt(e)

      };
    }));
    try {
      if (isar == null) isar = await getIsar();
      await isar.writeTxn((isar) async {
        await isar.messageConversations.importJson(decryptData);
      });
      print("success");
    } catch (e, t) {
      print(">>>> insert fail: $e, $t");
      return [];
    }
  }

// need run in new isolate
  static Future<void> syncViaFile(String key2e2, String deviceIdTarget) async {
    LazyBox box = Hive.lazyBox('pairkey');
    var identityKey =  await box.get("identityKey");
    IsolateMedia.mainSendPort.send!({
      "type": "sync_via_file",
      "box_reference": IsolateMedia.storeObjectBox!.reference,
      "data": {
        "key2e2": key2e2,
        "device_id_target": deviceIdTarget,
        "identity_key": identityKey,
        "identity_key_server": Utils.identityKey,
        "token": Provider.of<Auth>(Utils.globalContext!, listen: false).token,
        "device_id": await Utils.getDeviceId(),
        "conversation_ids": await MessageConversationServices.getAllConversationIds()
      }
    });
  }

  static Future<void> syncViaFileIsolate(List convIds, String key2e2, String deviceIdTarget, Map identityKey, ObjectBox.Store store, String token, SendPort isolateToMainStream, String identityKeyServer, String deviceId, Isar? isar) async {
    try {
      // get bytes data
      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data": StatusSync(2, "Sync status: Getting message", deviceIdTarget)
      });
      statusSyncController.add(StatusSync(1, "Getting message", deviceIdTarget));
      List<int> bytes = await getDataMessageToTranfer(convIds, keyE2E: key2e2, store: store, isar: isar);
      // statusSyncController.add(StatusSync(1, "Uploading"));
      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data":  StatusSync(3, "Sync status: Uploading", deviceIdTarget)
      });
      // upload
      FormData formData = FormData.fromMap({
        "data": MultipartFile.fromBytes(
          bytes,
          filename: "file_sync.text",
        ),
        "content_type": "text",
        "mime_type": "text",
        "image_data": {},
        "filename": "file_sync.text"
      });

      final url = Utils.apiUrl + 'workspaces/0/contents/v2?token=$token';
      final response = await Dio().post(url, data: formData);
      String urlSyncFile = response.data["content_url"];
      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data":  StatusSync(201,  "Sync status: Done, Synchronization will take place as required by the device", deviceIdTarget)
      });
      // statusSyncController.add(StatusSync(201, "Done, Synchronization will take place as required by the device"));
      isolateToMainStream.send({
        "type": "push_sync_via_file_isolate",
        "data": {
          "data":  await Utils.encryptServer(
            {
              "data": Utils.encrypt(
                jsonEncode(
                  {
                    "url_sync_file": urlSyncFile,
                    "flow": "file",
                    "device_id_sync": deviceId
                  }
                ), 
                key2e2
              ),
              "public_key_decrypt": identityKey["pubKey"],
              "device_id": deviceIdTarget,
            },
            idKey: identityKey,
            identityKeyServer: identityKeyServer

          ),
          "device_id_encrypt": deviceId
        }
      });
      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data": StatusSync(201, "Sync status: Done, Synchronization will take place as required by the device", deviceIdTarget)
      });
      await Future.delayed(Duration(milliseconds: 10000));
      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data": StatusSync(-1, "", "")
      });
    } catch (e, t) {
      print("syncViaFile: $e, $t");
      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data": StatusSync(400, "Error sync. Tap to end.", deviceIdTarget) 
      }); 
    }
  }

// need run in new isolate
  static Future<void> handleSyncViaFileIsolate(String key2e2, String url, SendPort isolateToMainStream, ObjectBox.Store? store, Isar? isar, String deviceIdTarget, {int retries = 5}) async {
    if (retries == 0) return isolateToMainStream.send({
      "type": "progress_push_sync_via_file_isolate",
      "data": StatusSync(402, "Sync status: NetWork error, please try again later.", deviceIdTarget)
    });  
    try {
      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data": StatusSync(4, "Sync status: Downloading data", deviceIdTarget)
      });  
      await Future.delayed(Duration(milliseconds: 500));
      var response = await Dio().get(
        url,
        onReceiveProgress: (int i, int t){
            statusSyncController.add(StatusSync(8, "$i / $t", deviceIdTarget)); 
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false, 
          receiveTimeout: 0),
      );
      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data": StatusSync(5, "Sync status: Processing data", deviceIdTarget)
      });  

      var de = Utils.decrypt(base64Encode(response.data), key2e2);

      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data": StatusSync(6, "Sync status: Saving ", deviceIdTarget)
      }); 
      List messages = jsonDecode(de);
      if (Platform.isIOS){
        var page = (messages.length / 500).round();
        for (var i = 0; i <= page; i++){
          statusSyncController.add(StatusSync(6, "Saving ${i * 500} / ${messages.length}", deviceIdTarget));
          await MessageConversationIOSServices.insertOrUpdateMessages(messages.sublist(i * 500, min(messages.length, (i + 1)* 500)), store: store);
        }
        }
      else await saveJsonDataMessage(messages, isar: isar);

      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data": StatusSync(200, "Sync status: Done", deviceIdTarget)
      }); 
      await Future.delayed(Duration(milliseconds: 10000));
      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data": StatusSync(-1, "", "")
      });      
    } catch (e) {
      if (e.toString().contains("DioError")){
        await Future.delayed(Duration(seconds: 2));
        return handleSyncViaFileIsolate(key2e2, url, isolateToMainStream, store, isar, deviceIdTarget, retries: retries - 1); 
      }
      isolateToMainStream.send({
        "type": "progress_push_sync_via_file_isolate",
        "data": StatusSync(401, "Error sync. Tap to end.", deviceIdTarget)
      }); 
    }
  }

  static Future<void> handleSyncViaFile(String key2e2, String url, String deviceIdTarget) async {
    IsolateMedia.mainSendPort.send!({
      "type": "handle_via_file",
      "box_reference": IsolateMedia.storeObjectBox!.reference,
      "data": {
        "key2e2": key2e2,
        "url": url,
        "device_id_target": deviceIdTarget
      }
    });
  }

  static saveLogDM(Map data) async {
    try {
      LazyBox box = Hive.lazyBox('log');
      await box.put(DateTime.now().toString(), data.toString());
    } catch (e) { 
    }
  }


  //  run on an isolate 
  static Future<void> deleteMessageOnConversationByDeleteTime(int deleteTime, String conversationId, ObjectBox.Store store, Isar? isar) async {
    if (Platform.isIOS) MessageConversationIOSServices.deleteHistoryConversationByDeleteTime(conversationId, store, deleteTime);
    if (Platform.isAndroid)
    try {
      deleteHistoryConversation(conversationId, "", deleteTime, isar: isar);
    } catch (e, t) {
      print("deleteMessageOnConversationByDeleteTime: $e, $t");
    }
  }

  static Future processFileWhileSendMessageDmWithFiles(List atts, Map message, String token, SendPort isolateToMainStream, String pathTempFolder, String pathApplicationDocument, ObjectBox.Store store) async {
    try {
      var noDummyAtts = atts.where((element) => element["content_url"] != null && element["mime_type"] != "share").toList();
      var dummyAtts = atts.where((element) => element["content_url"] == null && element["mime_type"] != "share").map((e) {
        return {
          "att_id": e["att_id"],
          "name": e["name"],
          "type": "befor_upload",
          "progress": "0"
        };
      }).toList();
      message["attachments"] =  [] + (Utils.checkedTypeEmpty(message["attachments"]) ? message["attachments"] : []) + dummyAtts + noDummyAtts;
      // send to mainThread
      isolateToMainStream.send({
        "type": "summy_message_dm",
        "data": message
      });

      List resultUpload = await Future.wait(
        atts.where((element) => element["content_url"] == null  && element["mime_type"] != "share").map((file) async{
          var uploadFile ={
            "att_id": file["att_id"],
            "path": file["path"],
            "bytes": file["bytes"],
            "length": file["bytes"].length,
            "mime_type": file["mime_type"],
            "type": file["type"],
            "name": file["name"],
            "progress": "0",
            "image_data": file["image_data"],
            "thumbnail": file["thumbnail"],
            "preview": file["preview"]
          };
          return await uploadFileToServer(token, uploadFile, pathApplicationDocument, store, isolateToMainStream);
        })
      );

      isolateToMainStream.send({
        "type": "send_message_after_process_file",
        "data": {
          "token": token,
          "result_upload": resultUpload,
          "no_dummy_atts": noDummyAtts,
          "message": message,
        }
      });
    } catch (e, t) {
      print("processFileWhileSendMessageDmWithFiles: $e, $t");
    }

  }

  static Future<Map> uploadFileToServer(String token, Map file, String pathApplicationDocument, ObjectBox.Store store, SendPort isolateToMainStream) async {
    Map rootFileData = file;
    var imageData = file["image_data"];
    String type  = file["type"] ?? "";
    var result  = {};
    String key = "";
    key = (await X25519().generateKeyPair()).secretKey.toString();
    List<int> bytes = file["bytes"];
    file = {...file, "bytes": await Utils.encryptBytes(bytes, key)};

    try {
      final url = Utils.apiUrl + 'workspaces/0/contents/v2?token=$token';
      var dataFile = MultipartFile.fromBytes(
        file["bytes"], 
        filename: Utils.checkedTypeEmpty(file["name"]) ? file["name"] : DateTime.now().microsecondsSinceEpoch.toString(),
      );

      FormData formData = FormData.fromMap({
        "data": dataFile,
        "content_type": type,
        "image_data" : imageData,
        "filename": file["name"],
      });

      final response = await Dio().post(url, data: formData, onSendProgress: (count, total) {
        isolateToMainStream.send({
          "type": "progress_upload_file_dm",
          "data": {
            "count": count,
            "total": total,
            "key": file["att_id"]
          }
        });
      });

      final responseData = response.data;
      if (responseData["success"]) {
        var res = await uploadThumbnail(token, 0, file["thumbnail"], type);
        result = {
          "success": true,
          "content_url":  responseData["content_url"],
          "type": file["type"],
          "mime_type": file["mime_type"],
          "name": file["name"] ?? "",
          "url_thumbnail": res["content_url"],
          "image_data": imageData ?? responseData["image_data"],
          "version": 2
        };

        await Media(responseData["content_url"].hashCode, "", responseData["content_url"], file["name"] ?? "", file["type"], "", bytes.length, key, "downloaded", 1).downloadByBytes(bytes, pathApplicationDocument, store);
      }
      else result =  {
        "success": false,
        "file_data": rootFileData
      };
      
    } catch (e, t) {   
      print("ERRRRRRRRR:   $e   $t");
      result =  {
        "success": false,
        "file_data": rootFileData
      };
    }
    return Utils.mergeMaps([result, {"name": file["name"], "type": file["type"], 'preview': file['preview'], "key": Utils.getRandomString(20), "key_encrypt": key}]);
  }
  
  static Future<dynamic> uploadThumbnail(String token, workspaceId, file, type) async {
    try {
      if (type != "video") return {};
      FormData formData = FormData.fromMap({
        "data": MultipartFile.fromBytes(
          file["bytes"], 
          filename: file["filename"],
        ),
        "content_type": "image",
        "filename": file["filename"]
      });

      final url = Utils.apiUrl + 'workspaces/$workspaceId/contents/v2?token=$token';
      final response = await Dio().post(url, data: formData);
      final responseData = response.data;
      return {...responseData, 'type': 'image', 'mime_type': 'jpeg'};
    } catch (e, t) {
      print("uploadThumbnail error: $e,  $t");
      return {};
    }
  }


  static checkShareMessageFromDM(Map message, bool isParentMessageIsShareMessage) async {
    await Future.wait((message["attachments"] as List).map((att) async {
      if ((att["mime_type"] == 'share' || att["mime_type"] == 'shareforwar')) {
        await checkShareMessageFromDM(att["data"], true);
      } else {
        // download
        if (isParentMessageIsShareMessage) Provider.of<DirectMessage>(Utils.globalContext!, listen: false).getLocalPathAtts(
          [
            {
              "attachments": [att],
              "id": "unkonw",
              "conversation_id": "unkonw",
              "time_create": DateTime.now().toString(),
              "user_id": "unkonw",
            }
          ]
        );
      }
    }));
  }

  static List<Map> sortMessagesByDay(messages, DirectModel dm) {
    messages = messages.where((e) => e["is_datetime"] == null).toList();
    List<Map> listMessages = [];

    for (var i = 0; i < messages.length; i++) {
      try {
        listMessages.add(messages[i]);

        if ((i + 1) < messages.length) {
          if (messages[i+1]["time_create"] == null ||  messages[i]["time_create"] == null) continue;
          var currentDay = DateFormat('MM-dd').format(DateTime.parse(messages[i]["time_create"]).add(Duration(hours: 7)));
          var nextday = DateFormat('MM-dd').format(DateTime.parse(messages[i+1]["time_create"]).add(Duration(hours: 7)));
          if (nextday != currentDay) {
            var stringDay = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(messages[i]["time_create"]).add(Duration(hours: 7)));
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
      } catch (e, t) {
        print("sortMessagesByDay: $e $t");
        continue;
      }
    }

    for (var index = 0; index < listMessages.length; index++) {
      try {
        int length = listMessages.length;
        var isFirst = (index + 1) < length ? ((listMessages[index + 1]["user_id"] != listMessages[index]["user_id"]) || listMessages[index + 1]["is_system_message"] == true) : true;
        var isLast = index == 0 ? true : listMessages[index]["user_id"] != listMessages[index - 1]["user_id"];
        bool showNewUser = false;

        if ((index + 1) < length) {
          showNewUser = (listMessages[index + 1]["current_time"] == null || listMessages[index]["current_time"] == null) ? false : (listMessages[index]["current_time"] - listMessages[index + 1]["current_time"]).abs() > 600000000;
        }

        var firstMessage = index + 1 < length && listMessages[index + 1]["is_datetime"] != null;
        var isAfterThread = (index + 1) < length ? (((listMessages[index +  1]["count_child"] ?? 0) > 0)) : false;
        String fullName = "";
        String avatarUrl = "";

        var u = dm.user.where((element) => element["user_id"] == listMessages[index]["user_id"]).toList();
        if (u.length > 0) {
          fullName = u[0]["full_name"];
          avatarUrl = u[0]["avatar_url"] ?? "";
        }

        listMessages[index]["isFirst"] = isFirst;
        listMessages[index]["isLast"] = isLast;
        listMessages[index]["showNewUser"] = showNewUser;
        listMessages[index]["firstMessage"] = firstMessage;
        listMessages[index]["index"] = index;
        listMessages[index]["isAfterThread"] = isAfterThread;
        listMessages[index]["fullName"] = fullName;
        listMessages[index]["avatarUrl"] = avatarUrl;
      } catch (e) {
        continue;
      }
    }

    return listMessages;
  }

  static getMessageDownViaIsoLate(ConversationMessageData currentDataDMMessage, DirectModel dm, int rootCurrentTime, String currentUserId, Isar? isar, ObjectBox.Store? store, bool isGetIsarBeforeCallApi, String type, SendPort isolateToMainStream) async {
    List dataFromIsar = await MessageConversationServices.getMessageDown(dm, dm.id,  dm.getDeleteTime(currentUserId), currentTime: rootCurrentTime, parseJson: true, isar: isar, store: store);
     try {
      dataFromIsar = dataFromIsar.map<Map>((e) => e as Map).toList();
      List<Map> results = dataFromIsar.whereType<Map>().toList();
      // getInfoUnreadMessage(
      //   results,
      //   token, 
      //   idDirectMessage
      // );

      // getLocalPathAtts(data); 
      currentDataDMMessage.messages = uniqById(results + currentDataDMMessage.messages);
      if (!isGetIsarBeforeCallApi) {
        if (type == "down") {
          currentDataDMMessage.disableHiveDown = dataFromIsar.length == 0;
          currentDataDMMessage.lastCurrentTime = currentDataDMMessage.messages.length == 0 ? 0 : ((currentDataDMMessage.messages).last)["current_time"];   
        }
        else {
          currentDataDMMessage.disableHiveUp = dataFromIsar.length == 0;
          currentDataDMMessage.latestCurrentTime = currentDataDMMessage.messages.length == 0 ? DateTime.now().microsecondsSinceEpoch : ((currentDataDMMessage.messages).first)["current_time"];   
        }        
      }

      currentDataDMMessage.messages = sortMessagesByDay(uniqById(currentDataDMMessage.messages), dm);
    } catch (e, t) {
      print("dataFromIsar: $e $t");
      currentDataDMMessage.disableHiveDown = true;
    }

    isolateToMainStream.send({
      "type": "result_get_message_down_via_isolate",
      "data": {
        "current_data_dm_message": currentDataDMMessage,
        "data_from_isar": dataFromIsar,
      }
    });
  }

  static processDataMessageFromApi(List dataMessage, int rootCurrentTime, bool isReset, int deleteTime, String token, String type, bool hasMark, Isar? isar, ObjectBox.Store? store, SendPort isolateToMainStream, ConversationMessageData currentDataDMMessage, DirectModel dm, String currentUserId) async {
    try {
      var messageIsSnippet;
      List resultUpdate = [];
      List<String> errorMessageIds = [];
      List dataDecrypt = await Future.wait(dataMessage.map((message) async {
        try {
          if (message["action"] == "delete" || message["action"] == "delete_for_me") return {
            "success": true,
            "message": {
              ...message,
              "conversation_id": currentDataDMMessage.conversationId
            }
          };
          var dataM, messageOnHive;
          // giai tin nhan + get from isar can boc trong tung try {} catch() {} de tranh xit 1 cai dan den catch => mat data
          try {
            dataM = currentDataDMMessage.conversationKey!.decryptMessage(message);
          } catch (e) {
            print("_________ $e");
          }
          try {
            messageOnHive = await MessageConversationServices.getListMessageById(dm, message["id"], currentDataDMMessage.conversationId, isar: isar, store: store);
          } catch (e) {
            print("+_+++++++++++ $e");
          }

          if (messageOnHive != null){
            messageOnHive = {
              "success": true,
              "message": messageOnHive
            };
          }

          if (Utils.checkedTypeEmpty(message["is_system_message"])){
            dataM = {
              "success": true,
              "message": message
            };
          }

          // gop data local va data api
          // neu ko giai dc se lay data local
          // trong truong hop ko giai dc, ko co local thi van them vao danh sach nhwung ko render ra nua,
          var dataMessageEnd = Utils.mergeMaps([
            message,
            {
              "message": "",
              "attachments": [],
              "last_edited_at": null
            },
            messageOnHive != null && messageOnHive["success"] ? messageOnHive["message"] : {},
            dataM != null && dataM["success"] ? dataM["message"] : {},
            {"conversation_id": currentDataDMMessage.conversationId}
          ]);
          
          if ((dataM == null || (dataM != null && !dataM["success"])) && messageOnHive == null) {
            return {
              "success": false,
              "message": {
                ...dataMessageEnd,
                "status_decrypted": "decryptionFailed"
              }
            };
          } else {
            return {
              "success": true,
              "message": dataMessageEnd
            };
          
          }
        } catch (e) {
          print("_______23232323232$e");
          return {
            "success": false,
              "message": {
                ...message,
                "status_decrypted": "decryptionFailed"
              }

          };
          
        }
      }));
      // errorIds se loai bo tin giai that bai nhung la cua minh
      errorMessageIds = errorMessageIds + dataDecrypt
        .where((element) => !element["success"])
        .where((element) => !(element["message"]["status_decrypted"] == "decryptionFailed" && element["message"]["user_id"] == currentUserId))
        .map<String>((e) => e["message"]["id"]).toList();
      resultUpdate = resultUpdate + dataDecrypt.where((element) => element["success"]).map((e) => e["message"]).toList();
      messageIsSnippet = resultUpdate.length > 0 ? resultUpdate.first : null;    
      List dataMergeLocal = await MessageConversationServices.mergeDataLocal(
        dm, currentDataDMMessage.conversationId, 
        dataDecrypt.map((e) => e["message"]).toList()
          // loai bo tin reaction
          .where((element) => element["action"] != "reaction")
          // loai bo tin giai ma that bai nhung la cua minh
          .where((element) => !(element["status_decrypted"] == "decryptionFailed" && element["user_id"] == currentUserId))
          .toList(), 
        rootCurrentTime, type, deleteTime, isar: isar, store: store);
      if (type == "down"){
        currentDataDMMessage.lastCurrentTime = dataMergeLocal.length == 0 ? 0 : dataMergeLocal.last["current_time"];
        currentDataDMMessage.isFetching = false;
        currentDataDMMessage.disableLoadDown = dataMessage.length == 0;
      }
      if (type == "up"){
        currentDataDMMessage.latestCurrentTime = dataMergeLocal.length == 0 ? DateTime.now().microsecondsSinceEpoch : dataMergeLocal.first["current_time"];
        currentDataDMMessage.isFetchingUp= false;
        currentDataDMMessage.disableLoadUp = dataMessage.length == 0;
      }

      List successIds = await MessageConversationServices.insertOrUpdateMessages(resultUpdate, isar: isar, store: store);
      if (isReset) {
        currentDataDMMessage.messages = sortMessagesByDay(uniqById([] + dataMergeLocal), dm);
      } else {
        currentDataDMMessage.messages = sortMessagesByDay(uniqById([] +  currentDataDMMessage.messages + dataMergeLocal), dm);
      }
      isolateToMainStream.send({
        "type": "result_after_process_data_from_api_via_isolate",
        "data": {
          "data_merge_local": dataMergeLocal,
          "success_ids": successIds,
          "error_ids": errorMessageIds,
          "message_snippet": messageIsSnippet!= null && type == "down" ? Utils.mergeMaps([messageIsSnippet, {"conversation_id": currentDataDMMessage.conversationId}]) : null,
          "current_data_dm_message": currentDataDMMessage,
          "has_mark": hasMark
        }
      });

    } catch (e){
      print("processDataMessageFromApi: $e");
    }
  }

  // only run on main isolate
  static Future<List> getAllConversationIds() async {
    LazyBox box = Hive.lazyBox("pairKey");
    return (await box.get("conversation_ids") ?? []);
  }

  static Future insertMessageHeader(DirectModel dm, String insertedAt) async {
    await MessageConversationServices.insertOrUpdateMessage(dm, {
      "is_system_message": true,
      "message": "",
      "attachments": [
        {
          "type": "header_message_converastion",
          "data": S.current.messagesAndCallsInThisChatWill
        }
      ],
      "id": "headerMessage",
      "user_id": "",
      "full_name": "",
      "inserted_at": insertedAt,
      "conversation_id": dm.id,
      "isBlur": false,
      "count_child": 0,
      "avatar_url": "",
      "isFirst": false,
      "isLast": false,
      "current_time": DateTime.parse(insertedAt).microsecondsSinceEpoch
    });
  }
    
}


class StatusBackUp {
  late int statusCode; 
  late String status; 
  StatusBackUp(this.statusCode, this.status);
}
class StatusRestore {
  late int statusCode; 
  late String status; 
  StatusRestore(this.statusCode, this.status);
}

class StatusSync {
  late int statusCode; 
  late String status; 
  late String targetDeviceId;
  StatusSync(this.statusCode, this.status, this.targetDeviceId);
}

// -1          No thing      
// 0           Waitting data(recie)     
// 1           Processing(send)
// 2           Getting message(send)
// 3           Uploading(send)
// 4           Downloading data(recive)
// 5           Processing(recive, decrypt)
// 6           Saving data(recive )
// 7
// 8
// 9
// 10          waiting for a response from the requesting device
// 200          Done(recive data)
// 201          Done, Synchronization will take place as required by the device(send file)

// 400         Error(send)

// 401         Error(recive)

