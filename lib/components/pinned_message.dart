import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/attachment_card.dart';
import 'package:workcake/components/message_card.dart';
import 'package:workcake/screens/friends_screen/index.dart';

import '../common/palette.dart';
import '../models/models.dart';

class PinnedMessages extends StatefulWidget {
  final channelId;
  PinnedMessages({
    Key? key, this.channelId,
  }) : super(key: key);


  @override
  _PinnedMessagesState createState() => _PinnedMessagesState();
}

class _PinnedMessagesState extends State<PinnedMessages> {
  List snippetList = [];
  List listBlockCode = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final  auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    final pinnedMessages = Provider.of<Channels>(context, listen: true).pinnedMessages;

    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: isDark ? Colors.transparent : Color(0xffEDEDED),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                        ),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 16),
                              width: 30,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  "Pinned messages",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  )
                                ),
                              ),
                            ),
                            Container(
                              width: 40,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: (pinnedMessages.length == 0) ? Container(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text("No items have been pinned yet!", style: TextStyle(fontSize: 14, color: isDark? Color(0xDBDBDBDB) : Colors.grey[700])),
                                SizedBox(height: 9),
                                Container(
                                  child: Text(
                                    "Open the context menu on important messages or files and choose Pin to ﻿pan-photo to stick them here.",
                                    style: TextStyle(
                                      fontSize: 11.5, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight, height: 1.5
                                    )
                                  )
                                ),
                              ],
                            )
                          ) : Container(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: pinnedMessages.length,
                              controller: ScrollController(),
                              itemBuilder: (BuildContext context, int index) {
                                var item = pinnedMessages[index];
                                List newList =  item["attachments"] != null ?  item["attachments"].where((e) => e["mime_type"] == "html").toList() : [];
                                if (newList.length > 0) {
                                  Utils.handleSnippet(newList[0]["content_url"], false).then((value) {
                                    int index = snippetList.indexWhere((e) => e["id"] == item["id"]);
                                    if (index == -1) this.setState(() {
                                      snippetList.add({
                                        "id": item["id"],
                                        "snippet": value,
                                      });
                                    });
                                  });
                                }
                                List blockCode = item["attachments"] != null ? item["attachments"].where((e) => e["mime_type"] == "block_code").toList() : [];
                                if (blockCode.length > 0) {
                                  Utils.handleSnippet(blockCode[0]["content_url"], true).then((value) {
                                    int index = listBlockCode.indexWhere((e) => e["id"] == item["id"]);
                                    if (index == -1) this.setState(() {
                                      listBlockCode.add({
                                        "id": item["id"],
                                        "block_code": value,
                                      });
                                    });
                                  });
                                }
                                final newSnippet = snippetList.where((e) => e["id"] == item["id"]).toList();
                                final newListBlockCode = listBlockCode.where((e) => e["id"] == item["id"]).toList();
                                final snippet = newSnippet.length > 0 ? newSnippet[0]["snippet"] : "";
                                final newBlockCode = newListBlockCode.length > 0 ? newListBlockCode[0]["block_code"] : "";
        
                                return PinnedMessageTile(item: item, snippet: snippet, newBlockCode: newBlockCode, isDark: isDark, channelId: widget.channelId,);
                              }
                            )
                          )
                        )
                      )
                    ]
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PinnedMessageTile extends StatefulWidget {
  final item;
  final snippet;
  final newBlockCode;
  final isDark;
  final channelId;
  const PinnedMessageTile({ Key? key, required this.item, required this.snippet, required this.newBlockCode, required this.isDark, this.channelId}) : super(key: key);

  @override
  _PinnedMessageTileState createState() => _PinnedMessageTileState();
}

class _PinnedMessageTileState extends State<PinnedMessageTile> {
  getUser(userId) {
    final users = Provider.of<Workspaces>(context, listen: false).members;
    int index = users.indexWhere((e) => e["id"] == userId || e["user_id"] == userId);

    if (index != -1) {
      return {
        "avatar_url": users[index]["avatar_url"],
        "full_name": users[index]["full_name"],
        "role_id": users[index]["role_id"]
      };
    } else {
      return {
        "avatar_url": "",
        "full_name": "Bot"
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final channels = Provider.of<Channels>(context, listen: false).data;
    final index = channels.indexWhere((e) => e['id'] == widget.channelId);
    final currentChannel = channels[index];
    
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: widget.isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB), width: 2))
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (currentUser["id"] !=  widget.item['user_id']) showUserProfile(context, widget.item['user_id']); 
              },
              child: CachedAvatar(
                widget.item["avatar_url"],
                  width: 32,
                  height: 32,
                  name: widget.item["full_name"],
                  isRound: true,
              ),
            ),
            SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(widget.item["full_name"], style: TextStyle(fontWeight: FontWeight.w700, color: Utils.checkColorRole(getUser(widget.item["user_id"])["role_id"], widget.isDark), fontSize: 14)),
                      SizedBox(width: 5),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(widget.item["inserted_at"] != null ? (DateFormatter().renderTime(DateTime.parse(widget.item["inserted_at"]), type: "dd/MM/yyyy")) : "", style: TextStyle(color: widget.isDark ? Palette.defaultBackgroundLight : Palette.defaultBackgroundDark,fontSize: 11)),
                      ),
                    ]
                  ),
                  SizedBox(height: 2.5),
                  widget.item["message"] != "" ? Container(
                    width: double.infinity,
                    child: MessageCard(
                      id: widget.item["id"], 
                      message: widget.item["message"]
                    ),
                  ) : SizedBox(),
                  AttachmentCard(
                    id: widget.item["id"],
                    attachments: widget.item["attachments"],
                    isChannel: true,
                    isChildMessage: false,
                    userId: widget.item["user_id"],
                    snippet: widget.snippet,
                    blockCode: widget.newBlockCode,
                    isThread: true,
                    message: widget.item,
                    onPinnedMessage: true,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap:() => Provider.of<Channels>(context, listen: false).pinMessage(auth.token, currentWorkspace['id'], currentChannel['id'], widget.item["id"]),
              child: Icon(PhosphorIcons.xCircle, color: widget.isDark ? Palette.topicTile : Colors.grey[700], size: 18),
            ),
          ]
        ),
    );
  }
}
