import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import "package:collection/collection.dart";
// import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/components/image_detail.dart';
import 'package:workcake/emoji/emoji.dart';
import 'package:workcake/desktop/components/attachment_card_desktop.dart';
import 'package:workcake/desktop/components/message_card_desktop.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/desktop/components/render_emoji.dart';
import 'package:workcake/desktop/components/user_profile_desktop.dart';
import 'package:workcake/models/models.dart';

class ChatItemMacOS extends StatefulWidget {
  final message;
  final isMe;
  final avatarUrl;
  final insertedAt;
  final fullName;
  final id;
  final isFirst;
  final isLast;
  final attachments;
  final count;
  final isChannel;
  final onEditMessage;
  final parentId;
  final isChildMessage;
  final userId;
  final width;
  final isThread;
  final infoThread;
  final success;
  final showHeader;
  final isSystemMessage;
  final isBlur;
  final showNewUser;
  final updateMessage;
  final reactions;
  final snippet;
  final blockCode;
  final conversationId;
  final channelId;
  final isViewMention;
  final bool isViewThread;

  ChatItemMacOS({
    Key? key,
    @required this.id,
    @required this.message,
    @required this.avatarUrl,
    @required this.insertedAt,
    @required this.fullName,
    @required this.attachments,
    @required this.isChannel,
    @required this.userId,
    @required this.isThread,
    @required this.reactions,
    @required this.isViewMention,
    this.isMe,
    this.count,
    this.isFirst,
    this.isLast,
    this.onEditMessage,
    this.parentId,
    this.isChildMessage,
    this.width,
    this.infoThread,
    this.success = true,
    this.showHeader,
    this.isSystemMessage,
    this.isBlur,
    this.updateMessage,
    this.showNewUser,
    this.snippet,
    this.blockCode,
    this.conversationId, 
    this.channelId,
    this.isViewThread = false,

  }) : super(key: key);

  @override
  _ChatItemMacOSState createState() => _ChatItemMacOSState();
}

class _ChatItemMacOSState extends State<ChatItemMacOS> {
  bool showMenu =  false;
  bool showEmoji = false;
  var colorMention = Color(0xFFffffff);

  @override
  void initState(){
    super.initState();
    Timer.run(()async{
      if (!widget.isChannel){
        if (this.mounted){
          var id = Provider.of<DirectMessage>(context, listen: false).idMessageToJump;
          if (widget.id == id){
            await Future.delayed(Duration(milliseconds: 500));
            if (this.mounted){
              this.setState(() {
                colorMention = Color(0xFFffe7ba);
              });
            }
          
            await Future.delayed(Duration(seconds: 2));
            if (this.mounted){
              Provider.of<DirectMessage>(context, listen: false).setIdMessageToJump("");
              // setState(() {
              //   colorMention = Color(0xFF323F4B80);
              // });
            }
          }
        }
      }
      
    });
  }

  renderInfoThread() {
    final List<dynamic> infoThread = widget.infoThread;
    final lastReply = infoThread[0]["inserted_at"];
    final auth = Provider.of<Auth>(context);
    final userList = groupBy(infoThread, (obj) {
      obj as Map;
      return obj["user_id"];
    }).map((key, value) => MapEntry(key, value.map((rep) {return rep;}).toList())).keys.toList();
    final channelId = widget.isChannel ? Provider.of<Channels>(context, listen: false).currentChannel["id"] : null;
    final workspaceId = widget.isChannel ? Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"] : null;
    final conversationId = widget.isChannel ? null : widget.conversationId != null ? widget.conversationId :  Provider.of<DirectMessage>(context, listen: false).directMessageSelected.id;

    DateTime dateTime = DateTime.parse(lastReply);
    final messageTime = DateFormat('kk:mm').format(DateTime.parse(lastReply).add(Duration(hours: 7)));
    final dayTime = DateFormatter().getVerboseDateTimeRepresentation(dateTime, auth.locale);

    final messageLastTime = (lastReply != "" && lastReply != null)
      ? "${dayTime == "Today" ? messageTime : DateFormatter().renderTime(DateTime.parse(widget.insertedAt), type: "MMMd") + " at $messageTime"}"
      : "";

    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Container(
        height: 24,
        padding: EdgeInsets.all(0),
        child: TextButton(
          // focusColor: !isDark ? Colors.white : Color(0xff36393f),
          // hoverColor: !isDark ? Colors.white : Color(0xff36393f),
          onPressed: () async{
            if (widget.isChildMessage == null || widget.isChildMessage || !Utils.checkedTypeEmpty(widget.id)) return;

            Map parentMessage = {
              "id": widget.id,
              "message": widget.message,
              "avatarUrl": widget.avatarUrl,
              "insertedAt": widget.insertedAt,
              "fullName": widget.fullName,
              "attachments": widget.attachments,
              "isChannel": widget.isChannel,
              "userId": widget.userId,
              "channelId": channelId,
              "workspaceId": workspaceId,
              "conversationId": conversationId,
              "reactions": widget.reactions
            };

            Provider.of<Channels>(context, listen: false).openChannelSetting(false);
            await Provider.of<Messages>(context, listen: false).openThreadMessage(true, parentMessage);
          },
          child: Container(
            height: 22,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: userList.length > 4 ? 4 : userList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.only(left: 0, right: 4),
                      child: CachedAvatar(
                        getUser(userList[index])["avatar_url"],
                        height: 22, width: 22,
                        isRound: true,
                        isAvatar: true,
                        name: getUser(userList[index])["full_name"]
                      )
                    );
                  },
                ),
                Container(
                  padding: EdgeInsets.only(left: 4),
                  child: Text("${widget.count} ${widget.count > 1 ? "replies" : "reply"}", style: TextStyle(fontSize: 11, color: Colors.lightBlue[400])),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5, right: 8),
                  child: Text(
                    "Last reply at $messageLastTime",
                    style: TextStyle(fontSize: 11, color: Color(0xFF6a6e74)),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            )
          )
        ),
      ),
    );
  }

  renderAtt(att){
    final deviceWidth = MediaQuery.of(context).size.width;
    final appInChannel = Provider.of<Channels>(context, listen: true).appInChannels;
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    if (att == null || att.length  ==0) return Container();
    final dm = Provider.of<DirectMessage>(context, listen: false).directMessageSelected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
        widget.attachments.map<Widget>((att) {
        switch (att["type"]) {
          case "message_start":
            return Text(att["data"]);
          case "mention":
            return RichText(
              text: TextSpan(
                children: att["data"].map<TextSpan>((e){
                  if (e["type"] == "text" ) return TextSpan(text: e["value"], style: TextStyle(color: isDark ? Colors.white70 : Color(0xff627D98)));
                  if (e["type"] == "all") return TextSpan(text: "@All",  style: TextStyle(color:  isDark ? Colors.yellow : Color(0xFF69c0ff)));
                  if (widget.isChannel) {
                    return TextSpan(text: "@${e["name"] ?? ""}", style: TextStyle(color: isDark ? Colors.lightBlue : Color(0xFF69c0ff)));
                  } else {
                    var u  = dm.user.where((element) => element["user_id"] == e["value"]).toList();
                    if (u.length > 0)
                      return TextSpan(text: "@${u[0]["full_name"]}", style: TextStyle(color: isDark ? Colors.lightBlue : Color(0xFF69c0ff)));
                    else
                      return TextSpan(text: "Message unavailable", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13));
                  }
                }).toList()
              ),
            );
          case "bot" :
            var appId  = att["bot"]["id"];
            var app =  appInChannel.where((element) {
              return element["app_id"] == appId;
            }).toList();
            var appName  = " ";
            if (app.length > 0) appName = app[0]["app_name"];
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 35,
                      width: 35,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFF1890FF),
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Text(
                        appName[0],
                        style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                    Container(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appName,
                          style : TextStyle(
                            fontWeight:  FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? Color(0xFFd8dcde) : Colors.grey[800]
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis
                        ),
                        Text(
                          "/" + att["data"]["command"] + " ${att["data"]["text"]}",
                          style: TextStyle(
                            color: Color(0xFFBFBFBF),
                            fontSize: 10
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left
                        )
                      ],
                    )
                  ],
                ),
                att["data"]["result"] != null ?
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: isDark ?  Color(0xff4f5660) : Color(0xFFf0f0f0),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text(att["data"]["result"]["body"], textAlign: TextAlign.left, style: TextStyle(fontSize: 10),),
                  )
                  : Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: isDark ?  Color(0xff4f5660) : Color(0xFFf0f0f0),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text("Processing", style: TextStyle(fontSize: 10),),
                  ),
                Container(height: 8,)
              ],
            );

          case "befor_upload":
            return Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(bottom: 5, top:  att["success"] == null || att["success"] ? 0 : 5),
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF434343) : Color(0xFFf0f0f0),
                borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: Opacity(
                opacity: att["success"] == null || att["success"] ? 1: 0.2,
                child: Row(
                  children: [
                    Text((att["success"] == null || att["success"] ? "Uploading" : "Upload fail") + " ${att["name"]}")
                  ],
                ),
              )
            );
          default:
            var tag  = Utils.getRandomString(30);
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return ImageDetail(url: att["content_url"], id: widget.id, full: true, tag: tag);
                }));
              },
              child: att["content_url"] == null
                ? Text("Message unavailable", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13, fontWeight: FontWeight.w200))
                : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Hero(
                    tag: tag,
                    child: Container(
                      height: widget.isChildMessage ? 350/3 : (deviceWidth - 610)/3,
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: CachedImage(
                        att["content_url"],
                        radius: 10,
                        fit: BoxFit.contain
                      )
                    ),
                  ),
                ],
              )
            );
          }
        }
      ).toList(),
    );
  }

  getUser(userId) {
    var users = Provider.of<Channels>(context, listen: false).channelMember;

    if (!widget.isChannel){
      var indexConversation = Provider.of<DirectMessage>(context, listen: false).data.indexWhere((element) => element.id == widget.conversationId);
      if (indexConversation == -1) users = [];
      else users = Provider.of<DirectMessage>(context, listen: false).data[indexConversation].user;
    }

    int index = users.indexWhere((e) => e["id"] == userId || e["user_id"] == userId);

    if (index != -1) {
      return {
        "avatar_url": users[index]["avatar_url"],
        "full_name": users[index]["full_name"]
      };
    } else {
      return {
        "avatar_url": "",
        "full_name": "Bot"
      };
    }
  }

  renderSystemMessage(attachments) {
    // final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    final messageTime = DateFormat('kk:mm').format(DateTime.parse(widget.insertedAt).add(Duration(hours: 7)));

    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 15),
      child: Column(
        children:
          attachments.map<Widget>((att) {
            final params = att["params"];

            switch (att["type"]) {
              case "create_channel":
                String listName = att["data_member"] != null ? att["data_member"].map((ele) => ele["full_name"]).toList().join(", ") : "";

                return Column(
                  children: [
                  Text.rich(
                      TextSpan( 
                        children: <InlineSpan>[ 
                          TextSpan(text: att["user"], style: TextStyle(color: Colors.grey[700])),
                          TextSpan(text: " has create a channel: ", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13)),
                          TextSpan(text: "${params["name"]}", style: TextStyle(color: Colors.grey[700])),
                          TextSpan(text: " at $messageTime. ", style: TextStyle(fontSize: 13, color: Color(0xFF6a6e74), fontWeight: FontWeight.w400)),
                        ]
                      ),
                    ),
                    if (att["data_member"] != null && att["data_member"].length > 0) 
                    Text.rich(
                      TextSpan( 
                        children: <InlineSpan>[ 
                          TextSpan(text: listName, style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13)),
                          TextSpan(text: " has invited by ${att["user"]}",style: TextStyle(color: Colors.grey[700]))
                        ]
                      )
                    )
                  ],
                );
              case "invite":
                return att["user"] == att["invited_user"] ? Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: att["invited_user"], style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                      TextSpan(text: " has joined the channel by invitation code", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      TextSpan(text: " at $messageTime", style: TextStyle(fontSize: 13, color: Color(0xFF6a6e74), fontWeight: FontWeight.w400))
                    ]
                  )
                ) : Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: att["user"], style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                      TextSpan(text: " has invite ", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13)),
                      TextSpan(text: att["invited_user"], style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                      TextSpan(text: " to channel", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      TextSpan(text: " at $messageTime", style: TextStyle(fontSize: 13, color: Color(0xFF6a6e74), fontWeight: FontWeight.w400)),
                    ]
                  )
                );
              case "leave_channel":
                return Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: att["user"], style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                      TextSpan(text: " has leave the channel", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13)),
                      TextSpan(text: " at $messageTime", style: TextStyle(fontSize: 13, color: Color(0xFF6a6e74), fontWeight: FontWeight.w400)),
                    ]
                  )
                );
              case "change_topic":
                return Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: att["user_name"], style: TextStyle(color: Colors.grey[700])),
                      TextSpan(text: " has changed channel topic to ", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13)),
                      TextSpan(text: "${params["topic"]}", style: TextStyle(color: Colors.grey[700])),
                      TextSpan(text: " at $messageTime", style: TextStyle(fontSize: 13, color: Color(0xFF6a6e74), fontWeight: FontWeight.w400))
                    ]
                  )
                );
              case "change_name":
                return Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: att["user_name"], style: TextStyle(color: Colors.grey[700])),
                      TextSpan(text: " has changed channel name to ", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13)),
                      TextSpan(text: "${params["name"]}", style: TextStyle(color: Colors.grey[700])),
                      TextSpan(text: " at $messageTime", style: TextStyle(fontSize: 13, color: Color(0xFF6a6e74), fontWeight: FontWeight.w400))
                    ]
                  )
                );
              case "change_private":
                return Text.rich(
                 TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: att["user_name"], style: TextStyle(color: Colors.grey[700])),
                      TextSpan(text: " has changed channel private to ", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13)),
                      TextSpan(text: "${params["is_private"] ? "private" : "public"}", style: TextStyle(color: Colors.grey[700])),
                      TextSpan(text: " at $messageTime", style: TextStyle(fontSize: 13, color: Color(0xFF6a6e74), fontWeight: FontWeight.w400))
                    ]
                  )
                );

              case "archived":
                return  Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: att["user_name"], style: TextStyle(color: Colors.grey[700])),
                      TextSpan(text: " has ", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13)),
                      TextSpan(text: "${params["is_archived"] ? "archived" : "unarchived"}", style: TextStyle(color: Colors.grey[700])),
                      TextSpan(text: " this channel", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13)),
                      TextSpan(text: " at $messageTime", style: TextStyle(fontSize: 13, color: Color(0xFF6a6e74), fontWeight: FontWeight.w400))
                    ]
                  )
                );
                
              default: 
                return Container();
              }
            }
        ).toList(),
      ),
    );
  }

  renderOtherReaction(List users){
    List channelMembers = Provider.of<Channels>(context, listen: false).channelMember;
    bool isMe = users.indexWhere((element) => element == Provider.of<Auth>(context, listen: false).userId) != -1;
    String name  = isMe ? "You, " :  "";
    for(var i = 0; i< users.length ; i++){
      if (users[i] != Provider.of<Auth>(context, listen: false).userId){
        var index  =  channelMembers.indexWhere((element) => element["id"] == users[i]);
        if (index != -1)
          name += channelMembers[index]["full_name"] + ", ";
      }
    }
    return name.length > 1 ? name.substring(0, name.length - 2) : '';
  }

  renderReactions(List reactions, List workspaceEmojiData){
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    List result = [];
    for(int i = 0; i < reactions.length; i++){
      int indexR = result.indexWhere((element) => element["emoji_id"] == reactions[i]["emoji_id"]);
      if (indexR == -1){
        result = result + [{
          "emoji_id": reactions[i]["emoji_id"],
          "users": [reactions[i]["user_id"]],
          "count": 1
        }];
      }
      else {
        result[indexR] = {
          "users": result[indexR]["users"] + [reactions[i]["user_id"]],
          "count": result[indexR]["count"] + 1,
          "emoji_id": result[indexR]["emoji_id"],
        };
      }
    }
    var dataEmoji  = Provider.of<Workspaces>(context, listen: false).emojis;
    return Container(
      child: Wrap(
        alignment: WrapAlignment.start,
        children: result.map((e){
          // check
          var indexDefaultEmoji =  (dataEmoji.indexWhere((element) => element.contains(e["emoji_id"] ?? "_")) );
          var indexWorkspaceEmoji = (workspaceEmojiData.indexWhere((element) => element["name"] == e["emoji_id"] || element["emoji_id"] ==  e["emoji_id"]));
          if ((indexDefaultEmoji == -1 )  && (indexWorkspaceEmoji == -1 )) return Container();
          bool isMe = e["users"].indexWhere((element) => element == Provider.of<Auth>(context, listen: false).userId) != -1;
          return HoverItem(
            showTooltip: true,
            tooltip: Container(
              child: Column(
                children: [
                   Container(
                      height: 25, width: 25,
                      margin: EdgeInsets.only(bottom: 8),
                      child: indexWorkspaceEmoji != -1 ? CachedImage(workspaceEmojiData[indexWorkspaceEmoji]["url"],width: 25, height: 25, )
                      :  Image(image: AssetImage(dataEmoji[indexDefaultEmoji]) ) 
                    ),
                  Text("${renderOtherReaction(e["users"])} reacted with :${e["emoji_id"]}",style: TextStyle(fontSize: 10,  color: isDark ? Colors.white : Colors.black, decoration: TextDecoration.none, fontWeight: FontWeight.w500), )
                ],
              ),
            ), 
            colorHover: null,
            child: GestureDetector(
              onTap: (){
                final channelId = widget.isChannel ? Provider.of<Channels>(context, listen: false).currentChannel["id"] : null;
                final workspaceId = widget.isChannel ? Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"] : null;
                Provider.of<Messages>(context, listen: false).handleReactionMessage({
                  "emoji_id": e["emoji_id"],
                  "message_id": widget.id,
                  "channel_id": channelId,
                  "workspace_id": workspaceId,
                  "user_id": Provider.of<Auth>(context, listen: false).userId,
                  "token": Provider.of<Auth>(context, listen: false).token,
                });
              },
              child: Container(
              // width: 30,
                padding: EdgeInsets.all(4),
                margin: EdgeInsets.only(right: 4, top: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isMe && !isDark ? [BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 1), // changes position of shadow
                  ),] : [],
                  color: !isDark ?  Colors.white : isMe ? Color(0xFF323F4B) : null
                ),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      height: 16, width: 16,
                      child: indexWorkspaceEmoji != -1 ? CachedImage(workspaceEmojiData[indexWorkspaceEmoji]["url"], fit: BoxFit.cover)
                      :  Image(image: AssetImage(dataEmoji[indexDefaultEmoji]))
                    ),
                    e["count"] > 0 ? Text("  ${e["count"]}", style: TextStyle(fontSize: 12, color: Color(0xFFFAAD14)) ): Text("")

                  ],
                )
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final selectedTab = Provider.of<User>(context, listen: true).selectedTab;
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final showChannelSetting = Provider.of<Channels>(context, listen: true).showChannelSetting;
    final openThread = Provider.of<Messages>(context, listen: true).openThread;
    final messageTime = DateFormat('Hm').format(DateTime.parse(widget.insertedAt).add(Duration(hours: 7)));
    final locale = Provider.of<Auth>(context, listen: false).locale;
    DateTime dateTime = DateTime.parse(widget.insertedAt);
    final dayTime = DateFormatter().getVerboseDateTimeRepresentation(dateTime, locale);
    var showDateThread = widget.isThread
      ? "${dayTime == "Today" ? messageTime : DateFormatter().renderTime(DateTime.parse(widget.insertedAt), type: "MMMd") + " at $messageTime"}"
      : widget.isViewMention || selectedTab == "thread"
        ? (dayTime == "Today" ? "Today" : DateFormatter().renderTime(DateTime.parse(widget.insertedAt), type: "MMMd")) + " at $messageTime"
        : messageTime;

    // showDateThread =  Utils.checkedTypeEmpty(widget.id)?showDateThread : "";

    final channelId = widget.isChannel ? selectedTab == "channel" ? Provider.of<Channels>(context, listen: false).currentChannel["id"] : widget.channelId : null;
    final workspaceId = widget.isChannel ? currentWorkspace["id"] : null;
    final conversationId = widget.isChannel ? null : widget.conversationId != null ?  widget.conversationId : Provider.of<DirectMessage>(context, listen: false).directMessageSelected.id;
    final showDirectSetting = Provider.of<DirectMessage>(context, listen: true).showDirectSetting;
    final token = Provider.of<Auth>(context, listen: false).token;
    List workspaceEmojiData =  (widget.isChannel && currentWorkspace["emojis"] != null) ? currentWorkspace["emojis"] : [];
    Map parentMessage = {
      "id": widget.id,
      "message": widget.message,
      "avatarUrl": widget.avatarUrl,
      "insertedAt": widget.insertedAt,
      "fullName": widget.fullName,
      "attachments": widget.attachments,
      "isChannel": widget.isChannel,
      "userId": widget.userId,
      "channelId": channelId,
      "workspaceId": workspaceId,
      "conversationId": conversationId,
      "reactions": widget.reactions
    };

    int index = (widget.attachments  == null ? [] :widget.attachments).indexWhere((e) => e["type"] == "bot");
    int indexSnippet = (widget.attachments  == null ? [] :widget.attachments).indexWhere((e) => e["mime_type"] == "html" || e["mime_type"] == "block_code");
    var id = Provider.of<DirectMessage>(context, listen: false).idMessageToJump;
    final selectedMentionDM = Provider.of<DirectMessage>(context, listen: true).selectedMentionDM;

    return Opacity(
      opacity: (widget.isBlur == null || !widget.isBlur) ? 1: 0.2,
      child: (widget.isSystemMessage != null && widget.isSystemMessage)
        ? Container(
          padding: EdgeInsets.symmetric(horizontal: 64),
          child: renderSystemMessage(widget.attachments)
        )
        : MouseRegion(
            onEnter: (event) {
              if (widget.id != null && widget.success) setState(() {
                showMenu =  true;
              });
            },
            onExit: (event) {
              if (!showEmoji && widget.id != null  && widget.success) {
                setState(() {
                  showMenu = false;
                });
              }
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 1000),
              color: id == widget.id && !isDark ? colorMention : null,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    // color: as ? Colo1 :  null,
                    color: Color(
                      showMenu && ((widget.isChannel && selectedTab != "mention") || (!widget.isChannel && !selectedMentionDM))
                        ? !isDark ? 0xFFF0F4F8 : 0xFF323F4B80
                        : isDark ? 0xFF1F2933 : 0xFFffffff
                    ),
                    margin: EdgeInsets.only(bottom: widget.isLast ? 4 : 0, left: 0),       
                    padding: EdgeInsets.only(top: widget.isViewThread && !widget.isChildMessage ? 14 : 4, bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 12, right: 8),
                          child: widget.isFirst || widget.showHeader || widget.showNewUser ? GestureDetector(
                            onTap: () {
                              if (currentUser["id"] != widget.userId) {
                                onShowUserInfo(context, widget.userId);
                              }
                            },
                            child: CachedAvatar(
                              widget.avatarUrl != null ? widget.avatarUrl : getUser(widget.userId)["avatar_url"],
                              height: 36, width: 36,
                              isRound: true,
                              name: widget.fullName,
                              isAvatar: true
                            )
                          ) : Container(width: 34),
                        ),
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: widget.width != null
                              ? widget.width.toDouble()
                              : (MediaQuery.of(context).size.width - (openThread || showChannelSetting || showDirectSetting ? 770 : 420))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (widget.isFirst || widget.showHeader || widget.showNewUser) && (!widget.isChannel ? (widget.id != null && widget.id != 1 ) : widget.isChannel)
                                ? Container(
                                  margin: EdgeInsets.only(bottom: widget.isViewMention ? 6 : 3),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (currentUser["id"] != widget.userId) {
                                            onShowUserInfo(context, widget.userId);
                                          }
                                        },
                                        child: Text(
                                          widget.fullName != null ? widget.fullName : getUser(widget.userId)["full_name"],
                                          style: TextStyle(
                                            color: widget.userId == currentUser["id"] ? Colors.lightBlue : isDark ? Color(0xffF5F7FA) : Color(0xff102A43),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.5
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 5),
                                        child: Text(
                                          Utils.checkedTypeEmpty(showDateThread) ? "$showDateThread" : DateFormat('kk:mm').format(DateTime.now()),
                                          style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Color(0xFF323F4B)),
                                        ),
                                      )
                                    ]
                                  ),
                                ) : Container(),

                                (widget.message != "" && widget.message != null)
                                  ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MessageCardDesktop(message: widget.message, id: widget.id),
                                      widget.attachments != null && widget.attachments.length > 0 
                                        ? AttachmentCardDesktop(blockCode: widget.blockCode, snippet: widget.snippet, attachments: widget.attachments, isChannel: widget.isChannel, id: widget.id, isChildMessage: widget.isChildMessage, isThread: widget.isThread)
                                        : Container()
                                    ],
                                  )
                                  : widget.attachments != null && widget.attachments.length > 0
                                    ? AttachmentCardDesktop(blockCode: widget.blockCode, snippet: widget.snippet, attachments: widget.attachments, isChannel: widget.isChannel, id: widget.id, isChildMessage: widget.isChildMessage, isThread: widget.isThread, conversationId: widget.conversationId,)
                                    : Container(),
                                    RenderEmoji(reactions: widget.reactions ?? [], isChannel: widget.isChannel, workspaceEmojiData: workspaceEmojiData, id: widget.id),
                                // renderReactions(widget.reactions == null ? [] :  widget.reactions, workspaceEmojiData),
                                (widget.count != null) && (widget.count > 0) && widget.infoThread.length > 0 ? renderInfoThread() : Container(),
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),

                  (showMenu && !showEmoji && widget.id != null && !widget.isViewMention) ? Positioned(
                    top: 4, right: 4,
                    height: 35,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDark ? Color(0xFF1F2933) : Colors.white,
                        border: Border(
                          bottom: BorderSide(width: 0.3, color: Colors.grey),
                          top: BorderSide(width: 0.3, color: Colors.grey),
                          left: BorderSide(width: 0.3, color: Colors.grey),
                          right: BorderSide(width: 0.3, color: Colors.grey)
                        )
                      ),
                      child: Row(
                        children: [
                          if (selectedTab == "channel") IconButton(
                            padding: EdgeInsets.zero,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () async {
                              await Provider.of<Channels>(context, listen: false).pinMessage(token, workspaceId, channelId, parentMessage["id"]);
                            },
                            icon: Icon(CupertinoIcons.pin, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 15)
                          ),
                          // IconButton(
                          //   padding: EdgeInsets.zero,
                          //   focusColor: Colors.transparent,
                          //   highlightColor: Colors.transparent,
                          //   hoverColor: Colors.transparent,
                          //   splashColor: Colors.transparent,
                          //   onPressed: () {
                          //     if (!widget.isChannel) return;
                          //     setState(() {
                          //       showEmoji =  true;
                          //     });
                          //     var box = context.findRenderObject();
                          //     var si = context.size;
                          //     var t  =  box == null ? Offset.zero : (box as RenderBox).localToGlobal(Offset.zero);
                          //     var isOpenThread  =  Provider.of<Messages>(context, listen: false).openThread;
                          //     showPopover(
                          //       context: context,
                          //       direction: isOpenThread && !widget.isChildMessage ? PopoverDirection.right : PopoverDirection.top,
                          //       transitionDuration: Duration(milliseconds: 0),
                          //       arrowDyOffset: isOpenThread && !widget.isChildMessage 
                          //         ? 0
                          //         : t.dy < 380 ? -si!.height : 0,
                          //       arrowWidth: 0, 
                          //       arrowHeight: 0,
                          //       arrowDxOffset: isOpenThread && !widget.isChildMessage ? -320 : 0,
                          //       shadow: [],
                          //       // barrierColor: null,
                          //       onPop: (){
                          //         if (this.mounted) this.setState(() {
                          //           showMenu = false;
                          //           showEmoji= false;
                          //         });
                          //       },
                          //       bodyBuilder: (context) => Emoji(
                          //         workspaceId: workspaceId,
                          //         reactions: widget.reactions,
                          //         messageId: widget.id,
                          //         channelId: widget.channelId,
                          //         onClose: (){
                          //           Navigator.pop(context);
                          //           setState(() {
                          //           showEmoji= false;
                          //           showMenu = false;
                          //         });}
                          //       )
                          //     );
                          //   },
                          //   icon: Icon(Icons.face, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 15)
                          // ),
                          if (selectedTab == "channel") IconButton(
                            icon: Icon(Icons.message, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 15),
                            padding: EdgeInsets.zero,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () async { 
                              if (widget.isChildMessage == null || widget.isChildMessage || !Utils.checkedTypeEmpty(widget.id)) return;
                              Provider.of<Channels>(context, listen: false).openChannelSetting(false);
                              if (widget.conversationId != null) {
                                var indexDM = Provider.of<DirectMessage>(context, listen: false).data.indexWhere((element) => element.id == widget.conversationId);
                                Provider.of<DirectMessage>(context, listen: false).setSelectedDM(Provider.of<DirectMessage>(context, listen: false).data[indexDM], "token");
                              }
                              await Provider.of<Messages>(context, listen: false).openThreadMessage(true, parentMessage);
                              // Navigator.pop(context);
                            }
                          ),
                          (index == -1 && indexSnippet == -1 && selectedTab == "channel" && widget.userId == auth.userId)  ? IconButton(
                            icon: Icon(Icons.edit, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 15),
                            padding: EdgeInsets.zero,
                            focusColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onPressed: () {
                              parentMessage["attachments"].indexWhere((e) => e["type"] == "bot");
                              handleUpdateMessage(context, parentMessage, widget.updateMessage);
                            }
                          ) : Container(),
                          // currentUser["id"] == parentMessage["userId"] ? IconButton(
                          //   padding: EdgeInsets.zero,
                          //   focusColor: Colors.transparent,
                          //   highlightColor: Colors.transparent,
                          //   hoverColor: Colors.transparent,
                          //   splashColor: Colors.transparent,
                          //   onPressed: () {
                          //     Provider.of<Messages>(context, listen: false).deleteChannelMessage(token, workspaceId, channelId, parentMessage["id"]);
                          //   },
                          //   icon: Icon(CupertinoIcons.delete, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 15)
                          // ) : Container(),
                        ],
                      ),
                    )
                  ) :Container()
                ],
              ),
            )
          )
    );
  }
}

onShowUserInfo(context, id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
        insetPadding: EdgeInsets.all(0),
        contentPadding: EdgeInsets.all(0),
        content: Container(
          width: 440,
          height: 550,
          child: UserProfileDesktop(userId: id)
        ),
      );
    }
  );
}

// RelativeRect buttonMenuPosition(BuildContext c) {
  // final RenderBox bar = c.findRenderObject();
  // final RenderBox overlay = Overlay.of(c).context.findRenderObject();
  // final RelativeRect position = RelativeRect.fromRect(
  //   Rect.fromPoints(
  //     bar.localToGlobal(bar.size.topRight(Offset.zero), ancestor: overlay),
  //     bar.localToGlobal(bar.size.topRight(Offset.zero), ancestor: overlay),
  //   ),
  //   Offset.zero & overlay.size,
  // );

  // return position;
// }

 handleUpdateMessage(context, message, updateMessage) {
  final currentUser = Provider.of<User>(context, listen: false).currentUser;
  if (currentUser["id"] == message["userId"] && message["isChannel"]) {
    updateMessage(message);
  }
}