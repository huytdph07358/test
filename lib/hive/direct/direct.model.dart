import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:isar/isar.dart';
import 'package:objectbox/objectbox.dart' as OB;
import 'package:workcake/components/isar/message_conversation/message_object_box.dart';
import 'package:workcake/components/isar/message_conversation/service_ios.dart';
import 'package:workcake/isar.g.dart';
import 'package:workcake/E2EE/GroupKey.dart';
import 'package:workcake/E2EE/e2ee.dart' as E2E;
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/message_conversation.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/objectbox.g.dart';
part 'direct.model.g.dart';

@HiveType(typeId: 4)
class DirectModel {
  @HiveField(0)
  String id = "";
  @HiveField(1)

  // require when dm has created
  // when dummy, only (user_id, avatar_url, avatar_url)
  // user = [
  //   {
  //     "user_id": "",
  //     "delete_time": 0,
  //     "avatar_url": "",
  //     "avatar_url": "",
  //     "status": "in_conversation" || "leave_conversation",
  //     "status_notify": "NORMAL" || "OFF" || "MENTION"
  //     "public_key": "",
  //     "message_shared_key": ""
  //     "conversation_id": ""
  //   }
  // ]
  List user;
  @HiveField(2)
  String name = "";
  @HiveField(3)
  bool seen;
  @HiveField(4)
  int newMessageCount;
  @HiveField(5, defaultValue: {})
  Map snippet;
  @HiveField(6, defaultValue: false)
  bool archive;
  @HiveField(7, defaultValue: 0)
  int updateByMessageTime;

  // flow moi currentTime se dc an trong userRead
  // userRead = {
  //   "current_time": conv["update_by_message"] || 0, thoi gian tin nhan cuoi cungf dc gui
  //   "last_user_id_send_message": conv["last_user_id_send_message"] || "", userId nguoi gui tin cuoi cung
  //   "data" => [""] danh sach nguoi da doc tin nhan cuoi cung
  // }

  @HiveField(8, defaultValue: {})
  Map userRead;

  //  truong nay dc su dung de hien thi ten hoi thaoi khi ma this.name  = ""
  @HiveField(9, defaultValue: "")
  String displayName;

  //  truong nay dc su dung de hien thi ten hoi thaoi khi ma this.name  = ""
  @HiveField(10)
  String? avatarUrl;

  @HiveField(11, defaultValue: "")
  String? insertedAt;

  DirectModel(this.id, this.user, this.name, this.seen, this.newMessageCount, this.snippet, this.archive, this.updateByMessageTime, this.userRead, this.displayName, this.avatarUrl, this.insertedAt);

  Map toJson(){
    return {
      "conversation_id": this.id,
      "user": this.user,
      "name": this.name,
      "seen": this.seen,
      "snippet": this.snippet,
      "updateByMessageTime": this.updateByMessageTime,
      "displayName": this.displayName,
      'avatarUrl': this.avatarUrl
    };
  }

  Future<GroupKey?> getConversationKey(String currentUserId, String token, String type) async {
    try {
      List users =  this.user;
      LazyBox box = Hive.lazyBox("pairKey");
      Map signedKey  = await box.get("signedKey");
      String idDefaultPrivateKey = await box.get('id_default_private_key');

      var oldData = await box.get(this.id);
      if (oldData == null) oldData = {};
      List<MemberKey> memberKeys = [];
      // print("___VVFDVFDBFD:$users");
      for(var i = 0; i < users.length; i++){
        if (users[i]["public_key"] == null && type != "support") continue;
        try {
          Map? uKey = getDataKeyOfUserInConversation(oldData, users[i]["user_id"]);
          if (uKey != null && uKey["public_key"] == users[i]["public_key"] && Utils.checkedTypeEmpty(uKey["shared_key"]) && (uKey["shared_key"] ==  users[i]["message_shared_key"])){
            memberKeys = memberKeys + [MemberKey(users[i]["user_id"], this.id, uKey["shared_key"], "", users[i]["public_key"], users[i]["message_shared_key"] ?? "")];
          } else {
            if (type == "panchat" || type == "support"){
              var dataPanchat = (users.where((element) => element["user_id"] != currentUserId).toList())[0];
              var defaultKey;
              try {
                defaultKey = await E2E.X25519().calculateSharedSecret(
                  E2E.KeyP.fromBase64(idDefaultPrivateKey, false),
                  E2E.KeyP.fromBase64(dataPanchat["id_default_public_key"], true)
                );
              } catch (e) {
                print("+++++++++ $e");
              }
              memberKeys = memberKeys + [MemberKey(users[i]["user_id"], this.id, defaultKey.toBase64(), defaultKey.toBase64(), users[i]["public_key"] ?? "", users[i]["message_shared_key"] ?? "")];
            }
            else {
              var skey =  await E2E.X25519().calculateSharedSecret(
                E2E.KeyP.fromBase64(signedKey["privKey"], false),
                E2E.KeyP.fromBase64(users[i]["public_key"], true)
              );
              var keyDe = (users[i]["message_shared_key"] == null) ? "null" : Utils.decrypt(users[i]["message_shared_key"], skey.toBase64());
              memberKeys = memberKeys + [MemberKey(users[i]["user_id"], this.id, keyDe, "", users[i]["public_key"], users[i]["message_shared_key"] ?? "")];
            }
          }
        } catch (e) {
          // print("______ $e");
        }
      }
      GroupKey group = GroupKey(memberKeys, this.id);
      await box.put(group.conversationId, {
        ...(oldData as Map),
        ...group.toJson()
      });
      return group;
    } catch (e, t) {
      print("getConversationKey $e $t");
      return null;
    }
  }

  Map? getDataKeyOfUserInConversation(Map dataConversationOnHive, String userId){
    try {
      List mKeys = dataConversationOnHive["member_keys"];
      int indexU =  mKeys.indexWhere((element) => element["user_id"] == userId);
      return mKeys[indexU];
    } catch (e) {
      return null;
    }
  }

  Future broadcastSharedKey( String currentUserId, String token) async {
    try {
      List users = this.user;
      LazyBox box  = Hive.lazyBox('pairKey');
      Map signedKey  =  await box.get('signedKey');
      var currentDataKeyConv  =  await box.get(this.id);
      String sharedKey  = (currentDataKeyConv == null) || (currentDataKeyConv["sharedKey"] == null)  ?  await Utils.genSharedKeyOnGroupByUser() : currentDataKeyConv["sharedKey"];
      List dataMessageToSend =  [];

      // lwu thong tin key cua nguoi dung
      await box.put(this.id, Utils.mergeMaps([
        currentDataKeyConv == null  ? {} :currentDataKeyConv,
        {"sharedKey": sharedKey}
      ]));
      for (var i = 0; i< users.length ; i++){
        if (users[i]["public_key"] == null) continue;
        var sercertKey  = await E2E.X25519().calculateSharedSecret(
          E2E.KeyP.fromBase64(signedKey["privKey"], false),
          E2E.KeyP.fromBase64(users[i]["public_key"], true)
        );
        var message  = Utils.encrypt(sharedKey, sercertKey.toBase64());
        dataMessageToSend = dataMessageToSend  + [{
          "message": message,
          "creator_id": currentUserId,
          "reciver_id" : users[i]["user_id"],
          "conversation_id": this.id
        }];
      }
      final url  = "${Utils.apiUrl}/direct_messages/${this.id}/send_message_shared?token=$token&device_id=${await box.get("deviceId")}";
      await Dio().post(url, data: {
        "data": await Utils.encryptServer({
        "data": dataMessageToSend
        })
      });
    } catch (e) {
      print("broadcastSharedKey $e");
    }
  }


  String getNameDM(String userId, {bool hasIsYou = true, bool isPrint = false}){
    try {
      if (name != "") return name;
      if (this.user.length == 1) return user[0]["full_name"];
      List userInConv = this.user;
      bool isGroup = userInConv.length > 2;
      String result = userInConv.where((us) => !(us["user_id"] == userId || (us["status"] != null && us["status"] != "in_conversation"))).map((e) => e["full_name"]).join(", ");
      if (Utils.checkedTypeEmpty(result)) return result;
      if (isGroup) return "Your group direct message";
      return "Your direct message";
    } catch (e) {
      print(e);
      return "";
    }
  }

  Future markUnreadMessage(String token, String userId) async {
    try {
      String url = "${Utils.apiUrl}direct_messages/${this.id}/mark_unread_conversation?token=$token&device_id=${await Utils.getDeviceId()}";
      var res = await Dio().post(url, data: {
        "data": await Utils.encryptServer({
          "conversation_id": this.id
        })
      });
      if (res.data["success"]){
        this.seen = false;
      }
    } catch (e) {
    }
  }

  int getDeleteTime(String userId){
    try {
      var index = this.user.indexWhere((element) => element["user_id"] == userId);
      return this.user[index]["delete_time"];
    } catch (e) {
      return 0;
    }
  }

  Future updateSnippetLast() async {
    try {
      if (Platform.isIOS){
        OB.Store store = await MessageConversationIOSServices.getObjectBox();
        OB.Box box = store.box<MessageConversationIOS>();
        final qBuilder;
        var conditionQuery = MessageConversationIOS_.conversationId.contains(this.id);
        conditionQuery = conditionQuery.and(MessageConversationIOS_.action.notEquals("delete_for_me"));
        conditionQuery = conditionQuery.and(MessageConversationIOS_.parentId.equals(""));
        qBuilder = box.query(conditionQuery)
        ..order(MessageConversationIOS_.currentTime, flags: Order.descending);
        final fBuild = qBuilder.build();
        fBuild
        ..limit = 1;
        List<MessageConversationIOS> data = fBuild.find();
        if (data.length > 0) this.snippet = MessageConversationIOSServices.parseMessageToJson(data[0]);

      }
      else {
        Isar isar = await MessageConversationServices.getIsar();
        MessageConversation? dataIsar =  await isar
          .messageConversations
          .where()
          .parentIdConversationIdEqualTo("", this.id)
          .filter()
          .not()
          .actionEqualTo("delete_for_me")
          .sortByCurrentTimeDesc()
          .limit(1)
          .findFirst();
        if (dataIsar == null) return;
        this.snippet = MessageConversationServices.parseMessageToJson(dataIsar);
      }

      var box = Hive.box("direct");
      box.put(this.id, this);
    } catch (e,t){
      print("updateSnippetLast: $e, $t");
    }

  }

  String? getRoleMember(String userId) {
    try {
      int indexUser = this.user.indexWhere((element) => element["user_id"] == userId);
      return this.user[indexUser]["role"];
    } catch (e) {
      return null;
    }
  }

  Color? getColorRoleMember(String userId) {
    try {
      switch (this.getRoleMember(userId)) {
        case "admin": return Color(0xFFff4d4f);
        case "member":  return Color(0xFFbfbfbf);
          
        default: return null;
      }
    } catch (e) {
      return null;
    }
  }

}