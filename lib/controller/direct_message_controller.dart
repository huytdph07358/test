import 'dart:isolate';

import 'package:isar/isar.dart';
import 'package:objectbox/objectbox.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/media_conversation/isolate_media.dart';
import 'package:workcake/emoji/dataSourceEmoji.dart';
import 'package:workcake/emoji/itemEmoji.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/models/reaction_message_user.dart';


DirectMessage directMessageProvider = Provider.of<DirectMessage>(Utils.globalContext!, listen: false);

class DirectMessageController {
    static handleReactionMessageDM(Map dataM) async {
    IsolateMedia.mainSendPort!.send({
      "type": "handle_reaction_message_DM_isolate",
      "data": dataM,
      "dm": directMessageProvider.getModelConversation(dataM["conversation_id"])
    });
  }

  static handleReactionMessageDMIsolate(DirectModel dm, Map dataM, SendPort isolateToMainStream, Isar? isar, Store? store) async {
    String messageId = dataM["parent_id"];
    String conversationId = dataM["conversation_id"];
    // b1: save message 
    List successIds = await MessageConversationServices.insertOrUpdateMessage(dm, dataM, isar: isar, store: store);
    // b2 cap nhat reaction
    isolateToMainStream.send({
      "type": "data_reaction_dm_messages",
      "data": [
        {
          "message_id": messageId,
          "reactions": await getReactionMessageIsolate(messageId, conversationId, isar, store),
          "success_ids": successIds,
          "conversation_id": conversationId
        }
      ]
    });
  }

  static getReactionMessages(List<String> messagesIds, String conversationId) {
    IsolateMedia.mainSendPort!.send({
      "type": "get_reaction_message_isolate",
      "message_ids": messagesIds,
      "conversation_id": conversationId
    });
  }

  static Future<List<ReactionMessageUser>> getReactionMessageIsolate(String messageId, String conversationId, Isar? isar, Store? store) async {
    List totalReactions = Map.fromIterable(
      (await MessageConversationServices.getReactionMessage(messageId, conversationId, isar, store) ?? []).where((element) => (element["attachments"] ?? []).isNotEmpty && element["attachments"][0]["type"] == "reaction_dm_message").toList(), 
      key: (v) => "${v["user_id"] ?? ""}___${v["attachments"][0]["emoji_id"] ?? ""}", 
      value: (v) => {...v, "emoji_id":  v["attachments"][0]["emoji_id"]}
    ).values.toList()
    .where((element) => element["attachments"][0]["type_reaction"] == "insert")
    .toList();
    List emojiIds = Map.fromIterable(totalReactions.map<String>((v) => v["emoji_id"]).toList(), key: (v) => v, value: (v) => v).keys.toList();
    List<ReactionMessageUser> reactions = [];
    for (var emojiId in emojiIds) {
      int indexE = dataSourceEmojis.indexWhere((element) => element["id"] == emojiId);
      List<String> userIds = totalReactions.where((e) => e["emoji_id"] == emojiId).map<String>((e) => e["user_id"]).toList();
      reactions += [
        ReactionMessageUser(emoji: ItemEmoji.castObjectToClass(dataSourceEmojis[indexE]), userIds: userIds, count: userIds.length)
      ];
    }
    return reactions;
  }

  static getReactionMessagesIsolate(List<String> messagesIds, String conversationId, SendPort isolateToMainStream, Isar? isar, Store? store) async {
    isolateToMainStream.send({
      "type": "data_reaction_dm_messages",
      "data": await Future.wait(messagesIds.map((e) async {
        return {
          "message_id": e,
          "reactions": await getReactionMessageIsolate(e, conversationId, isar, store),
          // doan nay ko can 
          "success_ids": <String>[],
          "conversation_id": conversationId
        };
      }))
    });
  }


  static sendReactionMessageDM(String conversationId, String messageId, String emojiId, String type) async {
    Auth auth =  Provider.of<Auth>(Utils.globalContext!, listen: false);
    return directMessageProvider.handleSendDirectMessage(
      {
        "id": null,
        "message": "",
        "attachments": [
          {
            "type": "reaction_dm_message",
            "type_reaction": type,
            "emoji_id": emojiId
          }
        ],
        "conversation_id": conversationId,
        "user_id": auth.userId,
        "parent_id": messageId,
        "isSend": true,
        "action": "reaction"
      },
      auth.token,
      isSendReaction: true
    );
  }
}