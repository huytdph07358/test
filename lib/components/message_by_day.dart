
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/desktop/components/chat_item_macOS.dart';
import 'package:workcake/models/models.dart';

class MessageByDay extends StatefulWidget {
  const MessageByDay({
    Key? key,
    required this.theme,
    required this.locale,
    required this.currentChannel,
    this.day,
    this.updateMessage
  }) : super(key: key);

  final ThemeType theme;
  final String locale;
  final Map currentChannel;
  final day;
  final updateMessage;

  @override
  State<MessageByDay> createState() => _MessageByDayState();
}

class _MessageByDayState extends State<MessageByDay> {
  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<Auth>(context, listen: true).userId;

    return StickyHeader(
      overlapHeaders: true,
      callback: (value) {},
      header: Container(
        height: 50,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: widget.theme == ThemeType.DARK ? Color(0xFF35393f) : Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(color: Color(0xFFbfbfbf), width: 1),
            ),
            child: Text(
              DateFormatter().getVerboseDateTimeRepresentation(widget.day["dateTime"], widget.locale),
              style: TextStyle(fontSize: 12, color: Color(0xFF6a6e74), fontWeight: FontWeight.w500),
            ),
          ),
        )
      ),
      content: ChatContainer(widget: widget, userId: userId, updateMessage: widget.updateMessage, day: widget.day)
    );
  }
}

class ChatContainer extends StatefulWidget {
  const ChatContainer({
    Key? key,
    required this.widget,
    required this.userId,
    required this.updateMessage,
    required this.day
  }) : super(key: key);

  final MessageByDay widget;
  final String userId;
  final updateMessage;
  final day;

  @override
  State<ChatContainer> createState() => _ChatContainerState();
}

class _ChatContainerState extends State<ChatContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 10, right: 20),
                child: Divider(height: 50)
              )
            )
          ]
        ),
        Column(
          children: (widget.widget.day["messages"] as List).map((message) {
            return ChatItemMacOS(
              userId: message["user_id"],
              isChildMessage: false,
              id: message["id"],
              isMe: message["user_id"] == widget.userId,
              message: message["message"],
              avatarUrl: message["avatar_url"],
              insertedAt: message["inserted_at"],
              fullName: message["full_name"],
              attachments: message["attachments"] == null ?  [] : message["attachments"],
              isFirst: message["isFirst"],
              isLast:  message["isLast"],
              isChannel: true,
              isThread: false,
              count: message["count_child"],
              infoThread: message["info_thread"] != null ? message["info_thread"] : [],
              success: message["success"] == null ? true : message["success"],
              showHeader: false,
              showNewUser: message["showNewUser"] || widget.day["messages"].first["id"] == message["id"],
              isSystemMessage: message["is_system_message"] ?? false,
              isBlur: message["isBlur"],
              updateMessage: widget.updateMessage,
              reactions: message["reactions"],
              snippet: message["snippet"] ?? "",
              blockCode: message["block_code"] ?? "",
              isViewMention: false,
              channelId: widget.widget.currentChannel["id"],
            );
          }).toList(),
        )
      ]
    );
  }
}
