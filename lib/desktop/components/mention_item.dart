import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/render_list_emoji.dart';
import 'package:workcake/desktop/components/chat_item_macOS.dart';
import 'package:workcake/desktop/workview_desktop/create_issue.dart';
import 'package:workcake/desktop/workview_desktop/render_markdown.dart';
import 'package:workcake/models/models.dart';

class MentionItem extends StatefulWidget {
  MentionItem({Key? key, this.sourceName, this.mentions, this.index, this.issueUniq, this.text, this.showDateThread}) : super(key: key);

  final sourceName;
  final mentions;
  final index;
  final issueUniq;
  final text;
  final showDateThread;
  @override
  _MentionItemState createState() => _MentionItemState();
}

class _MentionItemState extends State<MentionItem> {
  bool _isHover = false;
  bool showEmoji = false;

  getUser(userId) {
    final workspaceMember = Provider.of<Workspaces>(context, listen: false).members;
    int index = workspaceMember.indexWhere((e) => e["id"] == userId);

    if (index != -1) {
      return {
        "avatar_url":workspaceMember[index]["avatar_url"],
        "full_name":workspaceMember[index]["full_name"]
      };
    }else {
      return {
        "avatar_url": "",
        "full_name": "Bot"
      };
    }
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  onSelectChannel(channelId) async {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentUser = Provider.of<User>(context, listen: false).currentUser;

    await Provider.of<Channels>(context, listen: false).setCurrentChannel(channelId);
    Provider.of<Channels>(context, listen: false).onChangeLastChannel(currentWorkspace["id"], channelId);
    Provider.of<Messages>(context, listen: false).loadMessages(auth.token, currentWorkspace["id"], channelId);
    Provider.of<Channels>(context, listen: false).selectChannel(auth.token, currentWorkspace["id"], channelId);
    Provider.of<Channels>(context, listen: false).loadCommandChannel(auth.token, currentWorkspace["id"], channelId);
    Provider.of<Channels>(context, listen: false).getChannelMemberInfo(auth.token, currentWorkspace["id"], channelId, currentUser["id"]);

    auth.channel.push(
      event: "join_channel",
      payload: {"channel_id": channelId, "workspace_id": currentWorkspace["id"], "ssid": NetworkInfo().getWifiName()}
    );

    updateBadge();
  }

  updateBadge() {
    var macOSPlatformChannelSpecifics = new MacOSNotificationDetails(
      presentAlert: false,
      presentBadge: true,
      presentSound: false,
      badgeNumber: checkNewBadgeCount()
    );

    var platformChannelSpecifics = NotificationDetails(macOS: macOSPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(
      0, "", "",
      platformChannelSpecifics
    );
  }

  checkNewBadgeCount() {
    int count = 0;

    if (this.mounted) {
      final channels = Provider.of<Channels>(context, listen: false).data;
      final data = Provider.of<DirectMessage>(context, listen: false).data;

      for (var c in channels) {
        if (c["new_message_count"] != null) {
          count += int.parse(c["new_message_count"].toString());
        }
      }

      for (var d in data) {
        if (d.newMessageCount != null) {
          count += int.parse("${d.newMessageCount}");
        }
      }
    }
    
    return count;
  }
  
  @override
  Widget build(BuildContext context) {
    final auth  = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    var index  =  widget.index;
    var mentions = widget.mentions;

    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _isHover = true;
        });
      },
      onExit: (event) {
        setState(() {
          _isHover = false;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(4.0)
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 32,
                  margin: EdgeInsets.only(bottom: 2.0),
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 12.0),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0XFF323F4B) :Color(0xFFE4E7EB),
                    borderRadius: BorderRadius.all(
                      Radius.circular(3.0)
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Color(0xFF1F2933)),
                          children: <TextSpan>[
                            TextSpan(text: mentions[index]["creator_name"], style: TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(text: ' mentioned you in '),
                            TextSpan(
                              text: widget.sourceName,
                              style: TextStyle(fontWeight: Utils.checkedTypeEmpty(mentions[index]["channel_id"])
                                  ? FontWeight.bold
                                  : FontWeight.normal)
                            ),
                            Utils.checkedTypeEmpty(widget.issueUniq) ? TextSpan(
                              text: " #" + widget.issueUniq,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Color(0XFF1F2933)
                              )
                            ) : TextSpan(),
                          ],
                        ),
                      ),
                      !_isHover ? Container() : Row(
                        children: [
                          mentions[index]["conversation_id"] == null
                          ? Container(
                            width: 18,
                            child: mentions[index]["issue"]["id"] == null ? IconButton(
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              iconSize: 18,
                              constraints: BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  showEmoji =  true;
                                });
                                var box = context.findRenderObject();
                                var si = context.size;
                                var t  =  box == null ? Offset.zero : (box as RenderBox).localToGlobal(Offset.zero);
                                var isOpenThread  =  Provider.of<Messages>(context, listen: false).openThread;
                                showPopover(
                                  context: context,
                                  direction: isOpenThread ? PopoverDirection.right : PopoverDirection.top,
                                  transitionDuration: Duration(milliseconds: 0),
                                  arrowDyOffset: isOpenThread
                                    ? 0
                                    : t.dy < 380 ? -si!.height : 0,
                                  arrowWidth: 0, 
                                  arrowHeight: 0,
                                  arrowDxOffset: isOpenThread ? - 320 : 0,
                                  shadow: [],
                                  // barrierColor: null,
                                  onPop: (){
                                    setState(() {
                                      showEmoji= false;
                                    });
                                  },
                                  bodyBuilder: (context) => ListEmojiWidget(
                                    onClose: (){
                                      Navigator.pop(context);
                                      setState(() {
                                      showEmoji= false;
                                    });},
                                    onSelect: (id){
                                      Provider.of<Messages>(context, listen: false)
                                        .handleReactionMessage({
                                        "message_id": mentions[index]["message"]["id"],
                                        "channel_id": mentions[index]["channel_id"],
                                        "workspace_id": mentions[index]["workspace_id"],
                                        "token": Provider.of<Auth>(context, listen: false).token,
                                        "emoji_id": id
                                      });
                                    },
                                  )
                                );
                              },
                              icon: Icon(CupertinoIcons.smiley)
                            ) : Container(),
                          )
                          : Container(),
                          Container(
                            width: 18,
                            margin: EdgeInsets.symmetric(horizontal: 12),
                            child: IconButton(
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if ( mentions[index]["conversation_id"] == null){
                                  var jumpToIssue = mentions[index]["issue"]["id"] != null ? true : false;
                                  if(jumpToIssue) {
                                    var issue = mentions[index]["issue"];
                                    if (mentions[index]["issue_comment"]["id"] == null)
                                    issue["mention_id"] = mentions[index]["issue_comment"]["id"];
                                    issue["channel_id"] = mentions[index]["channel_id"];
                                    issue["workspace_id"] = mentions[index]["workspace_id"];
                                    issue["comments"] = [];
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(pageBuilder: (context, _, __) =>
                                        CreateIssue(issue: issue, timelines: issue["timelines"], comments: issue["comments"], fromMentions: true)
                                        
                                      )
                                    );
                                  } else {
                                    Provider.of<Workspaces>(context, listen: false).changeToMessageView(true);
                                    Provider.of<User>(context, listen: false).selectTab("channel");
                                    onSelectChannel(mentions[index]["channel_id"]);
                                  } 
                                } else {
                                  var indexConverastion = Provider.of<DirectMessage>(context, listen: false).data.indexWhere((element) => element.id == mentions[index]["conversation_id"]);
                                  if (indexConverastion  != -1){
                                    // trong truong hojp hoi thoai chua dc load hoac tin nhan ko trong hoi thoaij
                                    // set ["messages"] = [{tin nhan}]
                                    Provider.of<DirectMessage>(context, listen: false).setIdMessageToJump(mentions[index]["message"]["id"]);
                                    Provider.of<DirectMessage>(context, listen: false).setMessageConversationFromMention(mentions[index]["conversation_id"], mentions[index]["message"]);
                                    Provider.of<DirectMessage>(context, listen: false).setSelectedDM(Provider.of<DirectMessage>(context, listen: false).data[indexConverastion], ""); 
                                    Provider.of<DirectMessage>(context, listen: false).setSelectedMention(false);
                                  }
                                }      
                              },
                              icon: Icon(CupertinoIcons.arrow_turn_up_left)
                            ),
                          ),
                          Container(
                            width: 18,
                            margin: EdgeInsets.only(right: 10),
                            child: IconButton(
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              onPressed: () {},
                              icon: Icon(CupertinoIcons.bookmark)
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        // margin: EdgeInsets.only(left: 4),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 5),
                                  Container(
                                    child: 
                                      mentions[index]["type"] == "channel" || mentions[index]["conversation_id"] != null
                                      ? ChatItemMacOS(
                                          conversationId: mentions[index]["conversation_id"],
                                          id: mentions[index]["message"]["id"],
                                          userId: mentions[index]["message"]["user_id"],
                                          isChildMessage: mentions[index]["message"]["parent_id"] != null,
                                          isMe: mentions[index]["message"]["user_id"] == auth.userId,
                                          message: mentions[index]["message"]["message"] ?? "",
                                          avatarUrl: mentions[index]["creator_url"] ?? "",
                                          insertedAt: mentions[index]["message"]["inserted_at"] ?? mentions[index]["message"]["time_create"],
                                          fullName: mentions[index]["creator_name"],
                                          attachments: mentions[index]["message"]["attachments"],
                                          isFirst: true,
                                          isChannel: mentions[index]["conversation_id"] == null,
                                          isThread: false,
                                          count: 0,
                                          infoThread:  [],
                                          success: true,
                                          showHeader: false,
                                          showNewUser: true,
                                          isLast: true,
                                          isBlur: false ,
                                          reactions:  Utils.checkedTypeEmpty(mentions[index]["message"]["reactions"]) ? mentions[index]["message"]["reactions"]  : [],
                                          isViewMention: true,
                                          channelId: mentions[index]["channel_id"],
                                        )
                                        : Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.only(left: 12, right: 8),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (currentUser["id"] != mentions[index]["creator_id"]) {
                                                    onShowUserInfo(context, mentions[index]["creator_id"]);
                                                  }
                                                },
                                                child: CachedImage(
                                                  getUser(mentions[index]["creator_id"])["avatar_url"],
                                                  radius: 34,
                                                  // isRound: true,
                                                  width: 34,
                                                  height: 34,
                                                  name: mentions[index]["creator_name"],
                                                  isAvatar: true
                                                )
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (currentUser["id"] != mentions[index]["creator_id"]) {
                                                            onShowUserInfo(context, mentions[index]["creator_id"]);
                                                          }
                                                        },
                                                        child: Text(
                                                          mentions[index]["creator_name"],
                                                          style: TextStyle(
                                                            color: mentions[index]["creator_id"] == currentUser["id"] ? Colors.lightBlue : isDark ? Color(0xffF5F7FA) : Color(0xff102A43),
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 14.5
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(left: 5, top: 2),
                                                        child: Text(
                                                          widget.showDateThread,
                                                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white : Color(0XFF323F4B)),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(top: 4.0, bottom: 8.0),
                                                    child: RenderMarkdown(stringData: Utils.parseComment(widget.text, false), onChangeCheckBox: (value, stringComment, commentId, indexComment){})
                                                  )
                                                ]
                                              )
                                            )
                                          ]
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
