import 'dart:convert';
import 'package:encrypt/encrypt.dart' as En;


class GroupKey {
  List<MemberKey> memberKeys;
  String conversationId;
  var nextPublicKey;

  GroupKey(this.memberKeys, this.conversationId);

  Map encryptMessage(String text, String userId, bool isThread){
    // get menberKey
    var index = memberKeys.indexWhere((element) => element.userId == userId);
    if (index != -1){
      MemberKey memberKey = memberKeys[index];
      return memberKey.encryptByMember(text);
    }
    return {
      "success": false,
      "message": "Not found user",
    };
  }

  String? getPublicKeySender(String userId){
    try {
      var indexUser = this.memberKeys.indexWhere((element) => element.userId == userId);
      return this.memberKeys[indexUser].publicKey;
    } catch (e) {
      return "getPublicKeySender ${e.toString()}";
    }
  }

  Map decryptMessage(Map message){
    var userId  = message["user_id"];
    // get menberKey
    var index = memberKeys.indexWhere((element) => element.userId == userId);

    if (index != -1){
      MemberKey memberKey = memberKeys[index];
      return memberKey.decryptMessageByMember(message);
    }
    return {
      "success": false,
      "message": "Not found user",
    };

  }

  Map toJson(){
    return {
      "conversation_id": this.conversationId,
      "member_keys": memberKeys.map((e) => e.toJson()).toList()
    };
  }

  static GroupKey? parseFromJson(Map? data){
    if (data == null) return null;
    try {
       return GroupKey(
        ((data["member_keys"] ?? []) as List).map(
          (e) => MemberKey(e["user_id"], e["conversation_id"], e["shared_key"], "", e["public_key"] ?? "", e["message_shared_key"])
        ).toList(),
        data["conversation_id"]
      );
    } catch (e, t) {
      print("parseFromJson $data $e $t");
      return GroupKey([], "");
    }
  }
}



class MemberKey {
  String userId ;
  String sharedkey;
  // truong nay dung khi 
  String defaultSharedKey;
  String conversationId;
  String publicKey;
  String messageSharedKey;

  MemberKey(this.userId, this.conversationId, this.sharedkey, this.defaultSharedKey, this.publicKey, this.messageSharedKey);

  Map toJson(){
    return {
      "user_id": this.userId,
      "shared_key": this.sharedkey,
      "conversation_id": this.conversationId,
      "message_shared_key": this.messageSharedKey,
      "public_key": this.publicKey
    };
  }

  Map encryptByMember(String text)  {
    try {
      final key = En.Key.fromBase64(this.sharedkey);
      final iv  =  En.IV.fromLength(16);
      final encrypter = En.Encrypter(En.AES(key, mode: En.AESMode.cbc));  
      return  {
        "success": true,
        "message": encrypter.encrypt(text, iv: iv).base64
      };
    } catch (e) {
      return {
        "success": false,
        "message": null
      };
    }
  }

  Map decryptMessageByMember(Map message)  {
    try {

      String messageEncrypted =  message["message"];
      final key = En.Key.fromBase64(this.sharedkey);
      final iv  =  En.IV.fromLength(16);
      final encrypter = En.Encrypter(En.AES(key, mode: En.AESMode.cbc));
      var encrypted =  En.Key.fromBase64(messageEncrypted);
      var dataDecrypt =  encrypter.decrypt(encrypted, iv: iv);
      Map resultDataDecrypted = jsonDecode(dataDecrypt);
      var dataFinalMessage  = Map.from(message);
      dataFinalMessage["message"] =  resultDataDecrypted["message"];
      dataFinalMessage["attachments"] = resultDataDecrypted["attachments"];
      dataFinalMessage["last_edited_at"] = resultDataDecrypted["last_edited_at"] ?? "";
      if (resultDataDecrypted["action"] == "reaction") {
        dataFinalMessage["action"] = resultDataDecrypted["action"];
        dataFinalMessage["parent_id"] = resultDataDecrypted["parent_id"];
      }
      // ServiceMedia.getAllMediaFromMessageViaIsolate(dataFinalMessage);
      return {
        "success": true,
        "message": dataFinalMessage
      };
    } catch (e) {
      // print("decryptMessageByMember $e");
      return {
        "success": false,
        "message": {},
        "error": e
      };
     
    }
  }
}