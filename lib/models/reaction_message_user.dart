import 'package:workcake/emoji/itemEmoji.dart';

class ReactionMessageUser {
  late ItemEmoji _emoji;
  late List<String> userIds;
  late int count;

  ItemEmoji get emoji => this._emoji;

  ReactionMessageUser({
    required ItemEmoji emoji,
    required List<String> userIds,
    required int count
  }){
    this._emoji = emoji;
    this.userIds = userIds;
    this.count = count;
  }

  static ReactionMessageUser? fromJson(Map obj) {
    late ReactionMessageUser reaction;
    try {
      reaction = ReactionMessageUser(
        emoji: obj["emoji"] is ItemEmoji ? obj["emoji"] : ItemEmoji.castObjectToClass(obj["emoji"]), 
        userIds: (obj["users"] ?? []).map<String>((e) => e as String).toList(), 
        count: obj["count"]
      );
    } catch (e) {
      // print("reactionMessageUser: $e, $t $obj");
      return null;
    }
    return reaction;
  }

  Map toJson() {
    return {
      "emoji": this._emoji.toJson(),
      "user_ids": this.userIds,
      "count": this.count
    };
  }
}