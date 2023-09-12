import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/progress.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/chat_item.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/emoji/emoji.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/direct_messages_model.dart';

import '../../models/auth_model.dart';

class ListUnreadThreadDM extends StatefulWidget {
  const ListUnreadThreadDM({Key? key, required this.conversationId});
  final String conversationId;

  @override
  State<ListUnreadThreadDM> createState() => _ListUnreadThreadDMState();
}

class _ListUnreadThreadDMState extends State<ListUnreadThreadDM> {

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    ConversationMessageData? conv = Provider.of<DirectMessage>(context, listen: true).getCurrentDataDMMessage(widget.conversationId);
    if (conv == null) return shimmerEffect(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Container(
                height: 62,
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff2E2E2E) : Colors.white,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: isDark ? null : Border(bottom: BorderSide(color: Color(0xffDBDBDB)))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 60,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        child: Text(
                          "Unread threads",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )
                        ),
                      ),
                      Container(
                        width: 60,
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      )
                    ],
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: conv.dataUnreadThread.map((e) => ListUnreadThreadDMItem(dataInfoThread: e)).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListUnreadThreadDMItem extends StatefulWidget {
  const ListUnreadThreadDMItem({Key? key, required this.dataInfoThread});
  final DataInfoThreadConv dataInfoThread;

  @override
  State<ListUnreadThreadDMItem> createState() => _ListUnreadThreadDMItemState();
}

class _ListUnreadThreadDMItemState extends State<ListUnreadThreadDMItem> {
  
  DataInfoThreadConv get dataInfoThread => widget.dataInfoThread;
  Map? parentMessage;
  bool fetching = true;

  @override
  void initState() {
    super.initState();
    getDataMessage();
  }

  getDataMessage() {

    Timer.run(() async {
      DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(dataInfoThread.conversationId);
      if (dm == null) return;
      parentMessage = await MessageConversationServices.getListMessageById(dm, dataInfoThread.messageId, dataInfoThread.conversationId);
      setState(() {
        fetching = false;
      });
    });
  }

  @override
  void didUpdateWidget(oldWidget){
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataInfoThread.count != dataInfoThread.count) {
      getDataMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataInfoThreadMessage = Provider.of<DirectMessage>(context, listen: true).dataInfoThreadMessage;
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    
    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fetching ? shimmerEffect(context, number: 1)
          : parentMessage != null ? ChatItem(
            // key:  (message["id"] != null && message["id"].trim() != "") ? Key(message["id"]) : Key(message["fake_id"]),
            idMessageToJump: "",
            onEditMessage: (keyMessage) {},
            isChannel: false,
            id: parentMessage!["id"],
            isMe: false,
            message: parentMessage!["message"],
            avatarUrl: parentMessage!["avatar_url"],
            insertedAt: parentMessage!["inserted_at"] ?? parentMessage!["time_create"],
            fullName: parentMessage!["full_name"],
            attachments: parentMessage!["attachments"],
            isFirst: true,
            // countChild: (dataInfoThreadMessage[parentMessage!.id])?.countChild ?? parentMessage!.countChild,
            isLast: true,
            isChildMessage: false,
            userId: parentMessage!["user_id"],
            success: true,
            infoThread: parentMessage!["info_thread"],
            showHeader: false,
            showNewUser: true,
            isBlur: false,
            reactions: [],
            isThread: false,
            firstMessage: true,
            isSystemMessage: parentMessage!["is_system_message"],
            conversationId: parentMessage!["conversation_id"],
            onFirstFrameDone: null,
            isDark: isDark,
            // waittingForResponse: parentMessage!.statusDecrypted == "decryptionFailed",
            isUnreadThreadMessage: ((dataInfoThreadMessage[parentMessage!["id"]])?.isRead ?? true),
            count: ((dataInfoThreadMessage[parentMessage!["id"]])?.count ?? 0),
            isUnsent: parentMessage!["action"] == "delete",
            currentTime: parentMessage!["current_time"],
            workspaceId: 0,
            isInThreadDMView: true,
          ) : HoverItem(
            child: GestureDetector(
              onTap: () async {
                final url = "${Utils.apiUrl}direct_messages/${dataInfoThread.conversationId}/thread_messages/${dataInfoThread.messageId}/messages?token=${auth.token}&device_id=${await Utils.getDeviceId()}&mark_read_thread=true";
                print(url);
                Dio().get(url);
              },
              child: Opacity(
                opacity: 0.5,
                child: Container(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("[Message not available. Tap to mark read.]", style: TextStyle(fontStyle: FontStyle.italic),),
                      Container(height: 8,),
                      Text("${(dataInfoThreadMessage[dataInfoThread.messageId])?.count} replies", style: TextStyle(fontSize: 11, color: Colors.lightBlue[400], decoration:  TextDecoration.none,))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}