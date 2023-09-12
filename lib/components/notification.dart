import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:flutter/services.dart';
import 'package:workcake/provider/thread_user.dart';
import 'package:workcake/screens/work_screen/issue_info.dart';
import 'dart:convert';
import '../models/models.dart';
import '../screens/conversation.dart';
import 'thread_view.dart';
import 'package:workcake/screens/message.dart' as panchat;

class Notifications extends StatefulWidget {
  Notifications({
    Key? key,
    this.changePageView
  }) : super(key: key);

  final changePageView;

  @override
  _NotificationsState createState() => _NotificationsState();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

class _NotificationsState extends State<Notifications> {
  MethodChannel notifyChannel = MethodChannel("notify");

  @override
  void initState() {
    super.initState();
    setUpNotify();

    Timer(Duration(seconds: 5), () {
      final channel = Provider.of<Auth>(context, listen: false).channel;

      channel.on("new_message_channel_notification", (payload, _ref, _joinRef) async {
        final message = payload["message"];
        pushNotify(message);
      });

      channel.on("dm_message", (data, _ref, _joinRef) {
        pushNotifyDirect(data["data"][0]);
      });

      channel.on("clear_badge_channel", (data, _ref, _joinRef) async {
        final channelId = data["channel_id"];
        onClearBadge(channelId);
      });

      // tin nhan thread cua dm
      channel.on("new_thread_count_conversation", (data, _f, _j){
        pushNotifyDirect(data["data"][0]);
      });

      channel.on("update_issue", (data, _ref, _joinRef) async {
        if (data["type"] == "add_comment") {
          pushNotifyIssue(data);
        }
      });
    });
  }

  pushNotifyIssue(payload) async {
    final data = payload["data"];
    final comment = data["comment"];
    final dataUserMentions = Provider.of<User>(context, listen: false).userMentionInDirect;
    final author = dataUserMentions.firstWhere((e) => e["user_id"] == comment["author_id"], orElse: null);
    String title = "${author == null ? "Someone" : author['full_name']} commented on your issue";
    String body = comment["comment"] ?? "";

    final userId = Provider.of<Auth>(context, listen: false).userId;
    if (data["users_unread"].contains(userId)) {
      pushNoti(title, body, jsonEncode({...payload, "from_issue": true}));
    }
  }

  onSelectIssue(payload) async {
    var workspaceId = payload["workspace_id"];
    var channelId = payload["channel_id"];
    final issueId = payload["data"]["comment"]["issue_id"];

    Provider.of<Channels>(context, listen: false).selectChannel(Provider.of<Auth>(context, listen: false).token, workspaceId, channelId);
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
      return IssueInfo(
        issue: {
          "id": issueId,
          "channel_id": channelId,
          "workspace_id": workspaceId,
          "comments_count": 0,
          "is_closed": false,
          "title": "",
          "comments": [],
          "timelines": [],
          "assignees": []
        },
        isJump: true
      );
    }));
  }

  pushNotifyDirect(Map dataMessage) async {
    if (Platform.isAndroid) return;
    try {
      var conversationId = dataMessage["conversation_id"];
      var parentId = dataMessage["parent_id"];
      final currentUser = Provider.of<User>(context, listen: false).currentUser;
      final userId = dataMessage["user_id"];
      if (userId == currentUser["id"]) return;
      DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(conversationId);
      if (dm == null) return;
      var indexUser = dm.user.indexWhere((element) => element["user_id"] == currentUser["id"]);
      if (indexUser == -1) return;
      String settingNoti = dm.user[indexUser]["status_notify"] ?? "NORMAL";
      if (settingNoti == "OFF") return;
      var currentDataDMMessage =  Provider.of<DirectMessage>(context, listen: false).getCurrentDataDMMessage(conversationId);
      var messageDecrypted = currentDataDMMessage?.conversationKey?.decryptMessage(dataMessage);
      var currentDM = Provider.of<DirectMessage>(context, listen: false).getModelConversation(conversationId);

      if (messageDecrypted != null && messageDecrypted["success"]) {
        if (messageDecrypted["message"]["action"] == "reaction") return;
        final directMessageSelected = Provider.of<DirectMessage>(context, listen: false).directMessageSelected;
        final parentMessage = Provider.of<Messages>(context, listen: false).parentMessage;
        // final tab = Provider.of<Workspaces>(context, listen: false).tab;

        if (directMessageSelected.id != conversationId || parentId != parentMessage["id"]) {
          await MessageConversationServices.insertOrUpdateMessage(dm, messageDecrypted["message"]);
          var title = Utils.checkedTypeEmpty(messageDecrypted["message"]["parent_id"]) ? ("${currentDM!.displayName} - thread") : (currentDM!.displayName);
          var dataMessage = messageDecrypted["message"];
          var body = getBodyNotification(currentDM, dataMessage, messageDecrypted["message"]["full_name"]);
          if (settingNoti == "MENTION" && !checkInMention(dataMessage["attachments"])) return;
        
          pushNoti(title, body, jsonEncode(messageDecrypted["message"]));
        }
      }
    } catch (e, trace) {
      print("catch: $e $trace");
    }
  }

  pushNoti(title, body, payload, {isDefault: false}) async {
    int id = int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(7));

    const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
      sound: "incoming.mp3"
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('', '');

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      iOS: iOSPlatformChannelSpecifics,
      android: androidPlatformChannelSpecifics
    );

    flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload
    );
 
    await Future.delayed(Duration(milliseconds: 1000));
    flutterLocalNotificationsPlugin.cancel(id);
  }

  onClearBadge(channelId) async {
    if (this.mounted) {
      await Provider.of<Channels>(context, listen: false).clearBadge(channelId);
    }
  }

  setUpNotify() {
    WidgetsFlutterBinding.ensureInitialized();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (payload) async {
        var newPayload = jsonDecode(payload!);
        var channelId = newPayload["channel_id"];
        var workspaceId = newPayload["workspace_id"];
        var conversationId = newPayload["conversation_id"];

        if(Utils.stickerEmojiWidgetState.currentState != null) {
          final BuildContext? stickerContext = Utils.stickerEmojiWidgetState.currentContext;

          if(stickerContext != null) {
            Navigator.pop(stickerContext);
          }
        }

        if (newPayload["from_issue"] != null) { 
          onSelectIssue(newPayload);
        } else {
          if (conversationId != null) {
            onGotoDirect(conversationId, newPayload);
          } else {
            onChangeWorkspace(workspaceId, channelId, newPayload);
          }
        }
        selectNotificationSubject.add(payload);
      }
    );
  }

  parseAttachments(att, isChannel, {var convId = ""}) {
    final attachment = att.length > 0 ? att[0] : null;

    if (attachment != null) {
      final string = attachment["type"] == "mention" ? attachment["data"].map((e) {
        if (e["type"] == "text" ) return e["value"];
        return "${e["trigger"] ?? "@"}${e["name"] ?? ""} ";
      }).toList().join() :
        attachment["type"] == "delete" ? "${attachment['delete_user_name']} was kicked from this channel." :
        attachment["type"] == "bot" ? "Sent an attachment" :
        attachment["type"] == "change_name" ? "${attachment["user_name"]} has changed channel name to ${attachment["params"]["name"]}" :
        attachment["type"] == "invite" ? "${attachment["invited_user"]} has join a channel" :
        attachment["type"] == "leave_channel" ? "${attachment["user"]} has leave the channel" :
        attachment["type"] == "change_topic" ? "${attachment["user_name"]} has changed channel topic to ${attachment["params"]["topic"]}" :
        attachment["type"] == "change_private" ? "${attachment["user_name"]} has changed channel private to ${attachment["params"]["is_private"] ? "private" : "public"}" :
        attachment["mime_type"] == "image" ? "Sent a photo" : "Sent an attachment";

      return string;
    } else {
      return "Error payload";
    }
  }

  pushNotify(payload) {
    if (Platform.isAndroid) return;
    // final tab = Provider.of<Workspaces>(context, listen: false).tab;
    final data = Provider.of<Channels>(context, listen: false).data;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    final channelId = payload["channel_id"];
    final message = payload["message"];
    final parentMessage = Provider.of<Messages>(context, listen: false).parentMessage;
    final userId = payload["user_id"];
    final attachments = payload["attachments"] ?? [];
    int index = data.indexWhere((e) => e["id"] == channelId);

    if (userId != currentUser["id"]) {
      if (index != -1) {
        if (data[index]["status_notify"] == "NORMAL" || (data[index]["status_notify"] == "MENTION" && checkInMention(attachments))) {
          if (currentChannel["id"] != channelId || (parentMessage["id"] != payload["channel_thread_id"]) ) {
            int index = data.indexWhere((e) => e["id"] == channelId);
            String title = payload["full_name"] != null ? "${payload["full_name"]} to ${data[index]["name"]}" : "Bot to ${data[index]["name"]}";
            var body = !Utils.checkedTypeEmpty(message) ? parseAttachments(attachments, true) : "${payload["message"]}";
            var newPayload = jsonEncode(payload);
            pushNoti(title, body, newPayload);
          }
        }
      }
    }
  }

  checkInMention(att) {
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    final mentions = att.where((e) => e["type"] == "mention").toList();
    bool check = false;

    if (mentions.length > 0) {
      for (var mention in mentions) {
        final data = mention["data"];

        if (data != null) {
          final indexAll = data.indexWhere((e) => (e["type"] == "user" && e["name"] == "all") || e["type"] == "all");
          final indexUser = data.indexWhere((e) => e["type"] == "user" && e["value"] == currentUser["id"]);

          if (indexAll != -1 || indexUser != -1) {
            check = true;
          }
        }
      }
    }

    return check;
  }


  getBodyNotification(DirectModel dm, Map message, String? fullName){
    if (dm.user.length == 2){
      return message["message"] == "" ? "${parseAttachments(message["attachments"], false, convId: dm.id)}" : "${message["message"]}";
    }
    return message["message"] == "" ? "$fullName: ${parseAttachments(message["attachments"], false, convId: dm.id)}" : "$fullName: ${message["message"]}";
  }

  getTitleNotification(DirectModel dm){
    if (dm.user.length == 2){
      var yourId = Provider.of<Auth>(context, listen: false).userId;
      var otherIndex = dm.user.indexWhere((element) => element["user_id"] != yourId);
      if (otherIndex == -1) return dm.name != "" ? dm.name : dm.user.map((e) => e["full_name"]).join(", ");
      return dm.user[otherIndex]["full_name"];
    }
    return dm.name != "" ? dm.name : dm.user.map((e) => e["full_name"]).join(", ");
  }

  checkNewBadgeCount() {
    final channels = Provider.of<Channels>(context, listen: false).data;
    final data = Provider.of<DirectMessage>(context, listen: false).data;
    num count = 0;

    for (var c in channels) {
      if (c["new_message_count"] != null) {
        count += int.parse(c["new_message_count"].toString());
      }
    }

    for (var d in data) {
      if (d.newMessageCount != null) {
        count += int.parse(d.newMessageCount.toString());
      }
    }
   
    return count;
  }

  changePageView(page) {}

  onChangeWorkspace(workspaceId, channelId, payload) async {
    if (workspaceId == null && channelId == null) { return; }
    final token = Provider.of<Auth>(context, listen: false).token;
    final channel = Provider.of<Auth>(context, listen: false).channel;
    final currentUser = Provider.of<User>(context, listen: false).currentUser;

    await Provider.of<Channels>(context, listen: false).setCurrentChannel(channelId);
    Provider.of<User>(context, listen: false).selectTab("channel");
    Provider.of<Workspaces>(context, listen: false).selectWorkspace(token, workspaceId, context);
    Provider.of<Workspaces>(context, listen: false).getInfoWorkspace(token, workspaceId, context);
    await Provider.of<Messages>(context, listen: false).loadMessages(token, workspaceId, channelId);
    Provider.of<Channels>(context, listen: false).selectChannel(token, workspaceId, channelId);
    Provider.of<Channels>(context, listen: false).loadCommandChannel(token, workspaceId, channelId);
    Provider.of<Channels>(context, listen: false).onChangeLastChannel(workspaceId, channelId);
    Provider.of<Channels>(context, listen: false).getChannelMemberInfo(token, workspaceId, channelId, currentUser["id"]);
    await channel.push(
      event: "join_channel",
      payload: {"channel_id": channelId, "workspace_id": workspaceId, "ssid": NetworkInfo().getWifiName()}
    );

    if (payload["channel_thread_id"] != null) {
      Provider.of<ThreadUserProvider>(context, listen: false).updateThreadUnread(workspaceId, channelId, {"id": payload["channel_thread_id"]}, token);
      final data = Provider.of<Messages>(context, listen: false).data;
      int index = data.indexWhere((e) => e["channelId"] == channelId);

      if (index != -1) {
        await Utils.checkAndRemoveOldPush();

        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
          return ThreadView(
            key: Utils.globalKeyPush,
            isChannel: true,
            idMessage: payload["channel_thread_id"],
            keyDB: "keyDB",
            channelId: channelId,
          );
        }));
      }
    } else {
      await Utils.checkAndRemoveOldPush();

      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
        return Conversation(key: Utils.globalKeyPush,id: channelId, hideInput: true, changePageView: changePageView, isNavigator: true, );
      }));
        // widget.changePageView(1);
    }
  }

  onGotoDirect(conversationId, payload) async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final userId = Provider.of<Auth>(context, listen: false).userId;
    final channel = Provider.of<Auth>(context, listen: false).channel;
    final list = Provider.of<DirectMessage>(context, listen: false).data.reversed.toList();

    int index = list.indexWhere((e) => e.id == conversationId);

    if (index != -1) {
      DirectModel directMessage = list[index];

      await channel.push(event: "join_direct", payload: {"direct_id": conversationId});
      Provider.of<Workspaces>(context, listen: false).changeToMessageView(true);
      await Provider.of<DirectMessage>(context, listen: false).onChangeSelectedFriend(false);
      await Provider.of<DirectMessage>(context, listen: false).setSelectedDM(directMessage, token);
      if (payload["parent_id"] != null) {
        final data = Provider.of<DirectMessage>(context, listen: false).dataDMMessages;
        final index = data.indexWhere((e) => e.conversationId == conversationId);

        if (index != -1) {
          DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(conversationId);
          if (dm == null) return;
          var messageOnIsar = await MessageConversationServices.getListMessageById(dm, payload["parent_id"], conversationId);
          if (messageOnIsar != null) {
            await Utils.checkAndRemoveOldPush();
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
              return ThreadView(
                key: Utils.globalKeyPush,
                isChannel: false,
                idMessage: payload["parent_id"],
                keyDB: "keyDB",
                idConversation: conversationId
              );
            }));
          }
        }
      } else {
        await Utils.checkAndRemoveOldPush();
        await Provider.of<DirectMessage>(context, listen: false).getMessageFromApiDown(conversationId, true, token, userId);
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
          return panchat.Message(
            key: Utils.globalKeyPush,
            dataDirectMessage: directMessage,
            id: conversationId,
            name: "",
            avatarUrl: "",
            isNavigator: true,
          );
        }));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}