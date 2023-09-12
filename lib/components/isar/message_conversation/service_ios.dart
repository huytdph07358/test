import 'package:hive/hive.dart' as HiveB;
import 'package:path_provider/path_provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/objectbox.g.dart';
import 'message_object_box.dart';

// IOS dang bi loi isar
// IOS se tiep dung dung Hive, ko co tinh nang search
// ko co tinh nang load message from hive khi mat ket noi
// se dung Hive den khi nao isar ho tro

class MessageConversationIOSServices {
  static var box;
  static Future<List> getListMessageByIds(List<String> ids, {bool parseJson = false}) async {
    return [];
  }

  static Future<MessageConversationIOS?> processJsonMessage(Map data, {bool moveFromHive = false, List listConversations = const [], bool checkExisted = true}) async {
    try {
      if (!Utils.checkedTypeEmpty(data["id"]) || !Utils.checkedTypeEmpty(data["conversation_id"])) throw {};
      if (data["message"] == "" && data["attachments"].length == 0 && data["action"] == "insert") return null;
      MessageConversationIOS result =  MessageConversationIOS(
        message: data["message"] ?? "",
        messageParse: await MessageConversationServices.parseStringAtt(data),
        conversationId: MessageConversationServices.getNewConversationId( data["conversation_id"] ?? "", []),
        currentTime: data["current_time"] ?? 100000,
        attachments:  MessageConversationServices.parseListString(data["attachments"]),
        dataRead: [],
        id: data["id"] ?? "",
        count: data["count"] ?? 0,
        success: true,
        sending: false,
        isBlur: data["is_blur"] ?? false,
        parentId: data["parent_id"] ?? "",
        insertedAt: DateTime.fromMicrosecondsSinceEpoch( data["current_time"]?? 0, isUtc: true).toString(),
        userId: data["user_id"] ?? "",
        fakeId: data["fake_id"] ?? "",
        publicKeySender: data["public_key_sender"] ?? "",
        infoThread: MessageConversationServices.parseListString(data["info_thread"]),
        lastEditedAt: data["last_edited_at"] ?? "",
        action: data["action"] ?? "insert",
        localId: (data["current_time"] % 100000000000000)  
      );
      return result;
    } catch (e) {
      print(")))))) $e:  $data");
      return null;
    }
  }

  static Map parseMessageToJson(MessageConversationIOS message) {
    var atts = MessageConversationServices.parseListStringToListMap(message.attachments);
    return {
      "attachments": atts,
      "local_id": message.localId,
      "message": message.message,
      "conversation_id": message.conversationId,
      "success": true,
      "count": message.count,
      "fake_id": message.fakeId,
      "time_create": DateTime.fromMicrosecondsSinceEpoch(message.currentTime, isUtc: true).toString(),
      "is_blur": !Utils.checkedTypeEmpty(message.id),
      "parent_id": message.parentId,
      "public_key_sender": message.publicKeySender,
      "sending": message.sending,
      "current_time": message.currentTime,
      "data_read": MessageConversationServices.parseListStringToListMap(message.dataRead),
      "info_thread": MessageConversationServices.parseListStringToListMap(message.infoThread),
      "id": message.id,
      "messageParse": message.messageParse,
      "user_id": message.userId,
      "last_edited_at": message.lastEditedAt,
      "action": message.action ?? "insert",
      "is_system_message": message.id == "headerMessage" ? true :  MessageConversationServices.checkIsSystemMessageDM(atts),
    };
  }

  static Future<List<String>> insertOrUpdateMessage(DirectModel dm, Map message, {String type = "insert", Store? store}) async {
    try {
      if (store == null) store = await getObjectBox();
      Box box = store.box<MessageConversationIOS>();
      MessageConversationIOS? data;
      if (type == "insert"){
        data = await processJsonMessage(message);
        if (data != null && await box.get(data.localId) != null) return <String>[];
      } else {
        var messageExisted =  await getListMessageById(dm, message["id"], message["conversation_id"]);
        if (messageExisted == null) return [];
        data = await processJsonMessage({
          ...messageExisted,
          ...message
        });
      }
      if (data == null) return [];
      int localId = box.put(data);

      if(localId > 0) return [message["id"]];
      return <String>[];
    } catch (e) {

      print("?????? $e");
      return <String>[];
    }
  }

  static Future<List<String>> insertOrUpdateMessages(List messages, {Store? store}) async {
    try {
      // tim xem da ton tai tin nhan do chua dua theo 
      List<MessageConversationIOS?> data = await Future.wait(messages.map((message) async {
        return await processJsonMessage(message, );
      }));
      List<MessageConversationIOS> dataNoNull = data.where((element) => element != null).cast<MessageConversationIOS>().toList();
      if (store == null) store = await getObjectBox();
      Box box = store.box<MessageConversationIOS>();
      var ids  = box.putMany(dataNoNull);

      return dataNoNull.where((e) => ids.contains(e.localId)).map((e) => e.id).toList();
    } catch (e, t) {
      print("_____ $e  $t");
      return [];
    }
  }

  static Future<Store> getObjectBox() async {
    if (box == null){
      var newDir = await getApplicationSupportDirectory();
      var newPath = newDir.path + "/pancake_chat_data";
      box =  await openStore(directory: newPath);
    }
    return box;
  }

  static Future<List> searchMessage(String text, {int limit = 10, int offset = 0, bool parseJson = false, bool isLimit = true}) async {
    try {
      HiveB.LazyBox boxPairKey = HiveB.Hive.lazyBox("pairKey");
      List<String> convIds = (((await boxPairKey.get("conversation_ids")) ?? <String>[]) as List).whereType<String>().toList();
      // ios bi loi neu chi co text.length = 1 => them " " + text
      Store store = await getObjectBox();
      Box box = store.box<MessageConversationIOS>();
      var quey = box.query(MessageConversationIOS_.messageParse.contains(MessageConversationServices.unSignVietnamese(text)).and(MessageConversationIOS_.conversationId.oneOf(convIds.whereType<String>().toList())))
      ..order(MessageConversationIOS_.currentTime, flags: Order.descending);
      var fQuery = quey.build();
      if (isLimit)
        fQuery
        ..limit = limit
        ..offset = offset;
    
      List data = fQuery.find();
       if (parseJson)
        return MessageConversationServices.uniqById(data.map((e) => parseMessageToJson(e)).toList()); 
      return data;
    } catch (e) {
      print("_________ $e");
      if (e.toString().contains("10001 Query limit/offset")) return searchMessage(text, limit: limit, offset: offset, parseJson: parseJson, isLimit: false);
      return [];
    }
  }

  static Future<int> getTotalMessage({Store? store })async{
    try {
      if (store == null) store = await getObjectBox();
      Box box = store.box<MessageConversationIOS>();
      return box.count();
    } catch (e) {
      return 0;
    }
  }

  static Future<List> getMessageDown(DirectModel dm, String conversationId, int deleteTime, {Store? store, int currentTime = 0, int limit = 30, int offset = 0, bool parseJson = false, bool isParentMessage = true}) async {
    try {
      if (deleteTime >= currentTime || currentTime == 0) return [];
      store = store != null ? store : await getObjectBox();
      Box box = store.box<MessageConversationIOS>();
      final qBuilder;
      var conditionQuery = MessageConversationIOS_.conversationId.contains(conversationId);
      conditionQuery = conditionQuery.and(MessageConversationIOS_.action.notEquals("delete_for_me"));
      conditionQuery = conditionQuery.and(MessageConversationIOS_.action.notEquals("reaction"));
      if (isParentMessage) conditionQuery = conditionQuery.and(MessageConversationIOS_.parentId.equals(""));
      if (currentTime != 0) conditionQuery = conditionQuery.and(MessageConversationIOS_.currentTime.between(deleteTime, currentTime));
      qBuilder = box.query(conditionQuery)
        ..order(MessageConversationIOS_.currentTime, flags: Order.descending);
      final fBuild = qBuilder.build();
      fBuild
      ..limit = limit;
      List data = fBuild.find();
      if (parseJson){
        List result = data.map((e) => parseMessageToJson(e)).toList();
        return MessageConversationServices.uniqById(await Future.wait(result.map((e) async{
          return await loadInfoThreadMessage(dm, e, store: store);
        })));
      }
      return data;
    } catch (e, t) {
      print("getMessageDown: $e, $t");
      return [];
    }
  }

  static Future<List> getMessageUp(String conversationId, int deleteTime, {int currentTime = 0, int limit = 30, int offset = 0, bool parseJson = false, bool isParentMessage = true, Store? store}) async {
    try {
      var boxDm = HiveB.Hive.box("direct");
      DirectModel dm  = boxDm.get(conversationId);
      int timeGreater = deleteTime >= currentTime ? deleteTime : currentTime;
      store = store == null ? await getObjectBox() : store;
      Box box = store.box<MessageConversationIOS>();
      final qBuilder;
      var conditionQuery = MessageConversationIOS_.conversationId.contains(conversationId);
      conditionQuery = conditionQuery.and(MessageConversationIOS_.action.notEquals("delete_for_me"));
      conditionQuery = conditionQuery.and(MessageConversationIOS_.action.notEquals("reaction"));
      if (isParentMessage) conditionQuery = conditionQuery.and(MessageConversationIOS_.parentId.equals(""));
      if (currentTime != 0) conditionQuery = conditionQuery.and(MessageConversationIOS_.currentTime.greaterThan(timeGreater));
      qBuilder = box.query(conditionQuery)
      ..order(MessageConversationIOS_.currentTime);
      final fBuild = qBuilder.build();
      fBuild
      ..limit = limit;
      List data = fBuild.find();
      if (parseJson){
        List result = data.map((e) => parseMessageToJson(e)).toList();
        // print("getMessageUp: $currentTime, $result");
        return await Future.wait(result.map((e) async{
          return await loadInfoThreadMessage(dm, e, store: store);
        }));
      }
      return data;
    } catch (e) {
      return [];
    }
  }


  static Future<List<Map>?> getReactionMessage(String messageId, String conversationId, Store? store) async {
    try {
      if (store == null)  store = await getObjectBox();
      Box box = store.box<MessageConversationIOS>();
      var conditionQuery = MessageConversationIOS_.conversationId.contains(conversationId)
      .and(MessageConversationIOS_.parentId.equals(messageId))
      .and(MessageConversationIOS_.action.equals("reaction"));

      List data = box.query(conditionQuery).build().find();
      data.sort((a, b) => a.currentTime!.compareTo(b.currentTime!));
      return data.map((e) => parseMessageToJson(e)).toList();
    } catch (e) {
      print("?????? $e");
      return <Map>[];
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

  static Future<Map> loadInfoThreadMessage(DirectModel dm, Map message, {Store? store})async{
    List threads = await getMessageThreadAll(dm, dm.id, message["id"], parseJson: true, store: store);
    return {
      ...(getUserInfoMessage(dm, message)),
      "info_thread": threads
    };
  }

  static Future<List> getMessageToTranfer(List convIds, { int limit = 30, int offset = -1, bool parseJson = false, Store? store}) async {
    try {
      if (store == null) store = await getObjectBox();
      Box box = store.box<MessageConversationIOS>(); 
      var fQuery = box.query(MessageConversationIOS_.conversationId.oneOf(convIds.whereType<String>().toList()))
        ..order(MessageConversationIOS_.currentTime, flags: Order.descending);
      var query = fQuery.build();
      query
      ..limit = limit
      ..offset = offset;
      List data = query.find();
      if (parseJson)
        return data.map((e) => parseMessageToJson(e)).toList(); 
      return data;

    } catch (e) {
      print("getMessageToTranfer $e");
      return [];
    }
  }

  static Future<List> getMessageThreadAll(DirectModel dm, String conversationId, String parentId, { bool parseJson = false, Store? store}) async {
    try {
      store = store != null ? store : await getObjectBox();
      Box box = store.box<MessageConversationIOS>(); 
      var query = box.query(
        MessageConversationIOS_.parentId.equals(parentId)
        .and(MessageConversationIOS_.action.notEquals("reaction"))
      ).build();
      List data = query.find();
      if (parseJson)
        return MessageConversationServices.uniqById(data.map((e) => getUserInfoMessage(dm, parseMessageToJson(e))).toList()); 
      return data;      
    } catch (e) {
      print("dsfjbdshjgsdfgdsfhjkg $e");
      return [];
    }
  }

  static Future<Map?> getListMessageById(DirectModel dm, String id, String conversationId, {Store? store}) async {
    try {
      store = store == null ? await getObjectBox() : store;
      Box box = store.box<MessageConversationIOS>(); 
      var query = box.query(MessageConversationIOS_.id.contains(id).and(MessageConversationIOS_.conversationId.startsWith(conversationId))).build();
      var data =  query.findFirst();
      if (data == null) return null;
      return loadInfoThreadMessage(dm, parseMessageToJson(data), store: store);    
    } catch (e) {
      print("iosL: $e $id $conversationId");
      return null;
    }
  }

  static Future<Map?> getLastMessageOfConversation(String conversationId, {bool isCheckHasDM = true}) async {
    try {
      var boxDm = HiveB.Hive.box("direct");
      DirectModel? dm  = boxDm.get(conversationId);
      if (dm == null && isCheckHasDM) return null;
      Store store = await getObjectBox();
      Box box = store.box<MessageConversationIOS>(); 
      var query = (
        box.query(
          MessageConversationIOS_.parentId.equals("")
          .and(MessageConversationIOS_.action.notEquals("delete_for_me"))
          .and(MessageConversationIOS_.conversationId.equals(conversationId))
        )
        ..order(MessageConversationIOS_.currentTime, flags: Order.descending)
      )
      .build();
      var data =  query.findFirst();
      if (data == null) return null;
      if (!isCheckHasDM) return parseMessageToJson(data);
      if (dm == null) return null;
      return loadInfoThreadMessage(dm, parseMessageToJson(data));    
    } catch (e) {
      print("getLastMessageOfConversation: $e $conversationId");
      return null;
    }
  }

  static deleteHistoryConversation(String conversationId, String userId, int deleteTime) async {
    if (deleteTime == 0) return;
    // Store store = await getObjectBox();
    // Box box = store.box<MessageConversationIOS>(); 
    // var query = box.query(
    //   MessageConversationIOS_.conversationId.equals(conversationId)
    //   .and(MessageConversationIOS_.currentTime.lessThan(deleteTime))
    // ).build();

    // query.remove();
  }

  static deleteHistoryConversationByDeleteTime(String conversationId, Store store, int deleteTime) async {
    if (deleteTime == 0) return;
    Box box = store.box<MessageConversationIOS>(); 
    var query = box.query(
      MessageConversationIOS_.conversationId.equals(conversationId)
      .and(MessageConversationIOS_.currentTime.lessThan(deleteTime))
    ).build();

    query.remove();
  }
}
