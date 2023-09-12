import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/direct_message/dm_action_message.dart';
import 'package:workcake/components/thread_view.dart';
import 'package:workcake/components/reactions_dialog.dart';
import 'package:workcake/components/render_list_emoji.dart';
import 'package:workcake/controller/direct_message_controller.dart';
import 'package:workcake/emoji/itemEmoji.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/models/reaction_message_user.dart';
import 'package:workcake/provider/thread_user.dart';
import 'package:workcake/screens/friends_screen/index.dart';
import 'package:workcake/screens/work_screen/bottom_sheet_create_issue.dart';

import '../desktop/components/poll.dart';
import '../common/route_animation.dart';
import '../emoji/dataSourceEmoji.dart';
import 'attachment_card.dart';
import 'channel/change_channel_info.dart';
import 'channel/channel_info.dart';
import 'invite_member.dart';
import 'message_card.dart';
class ChatItem extends StatefulWidget {
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
  final copyMessage;
  final parentId;
  final isChildMessage;
  final userId;
  final success;
  final infoThread;
  final showHeader;
  final isAfterThread;
  final isBlur;
  final isSystemMessage;
  final showNewUser;
  final snippet;
  final blockCode;
  final reactions;
  final disableAction;
  final conversationId;
  final idMessageToJump;
  final onFirstFrameDone;
  final onTapMessage;
  final isThread;
  final channelId;
  final isThreadView;
  final isUnsent;
  final lastEditedAt;
  final firstMessage;
  final isConversation;
  // truong nay dc su dung khi tin nhan DM ko the giai ma va dang doi dc gui lai
  final waittingForResponse;
  final isUnreadThreadMessage;
  final currentTime;
  final bool isOnline;
  final bool isDark;
  final bool isMentionTab;
  final messageAction;
  final onReplyMessage;
  final workspaceId;
  final bool isInThreadDMView;

  ChatItem({
    Key? key,
    @required this.id,
    @required this.message,
    @required this.isMe,
    @required this.avatarUrl,
    @required this.insertedAt,
    @required this.fullName,
    @required this.isFirst,
    @required this.isLast,
    @required this.attachments,
    @required this.count,
    @required this.isChannel,
    @required this.userId,
    @required this.reactions,
    this.onReplyMessage,
    this.onEditMessage,
    this.copyMessage,
    this.parentId,
    this.isChildMessage,
    this.success = true,
    this.infoThread,
    this.isAfterThread = false,
    this.showHeader = false,
    this.isBlur,
    this.isSystemMessage,
    this.showNewUser,
    this.snippet,
    this.blockCode,
    this.disableAction,
    this.conversationId,
    this.idMessageToJump,
    this.onFirstFrameDone,
    this.onTapMessage,
    this.isThread = false,
    this.channelId,
    this.isThreadView,
    this.isUnsent,
    this.firstMessage,
    this.lastEditedAt,
    this.isConversation = false,
    this.waittingForResponse,
    this.isUnreadThreadMessage,
    this.currentTime,
    this.isOnline = false,
    required this.isDark,
    this.isMentionTab = false,
    this.messageAction,
    this.workspaceId,
    this.isInThreadDMView = false
  }) : super(key: key);

  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  var isHighlightMessage = false;

  @override
  void initState(){
    super.initState();
    isHighlightMessage =  widget.id == widget.idMessageToJump && Utils.checkedTypeEmpty(widget.idMessageToJump);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Utils.checkedTypeEmpty(widget.idMessageToJump)) return;
      if (widget.id == widget.idMessageToJump)  {
        setHighlightMessage();
      }
      if (widget.onFirstFrameDone != null) {
        if (widget.isThread){
          widget.onFirstFrameDone();
        } else {
          try {
            widget.onFirstFrameDone(this.context, widget.currentTime,widget.id);
          } catch (e, t) {
            print("widget.onFirstFrameDone error: $e,   $t");
          }
        }
      }
    });
  }

  void setHighlightMessage() async {
    await Future.delayed(Duration(seconds: 5));
    if(this.mounted) {
      setState(() {
        isHighlightMessage = false;
        rebuild = false;
      });
    }
  }

  dummyReactions(Map obj){
    try {    
      final userId = Provider.of<Auth>(Utils.globalContext!, listen: false).userId;
      List beforeReactions = widget.reactions;
      int indexCurrentEmoji = beforeReactions.indexWhere((reaction) => reaction["emoji"].id == obj["emoji_id"]);
      List totalDataSource = [] + dataSourceEmojis;
      int indexReactEmoji = totalDataSource.indexWhere((emo) {
        return (emo["id"] ?? emo["emoji_id"]) == obj["emoji_id"];
      });
      // print(beforeReactions);
      if (indexCurrentEmoji == -1) {
        beforeReactions.add({"count": 1, "emoji": ItemEmoji.castObjectToClass(totalDataSource[indexReactEmoji]), "users": [userId]});
        setState(() {
          rebuild = false;
        });
      } else {
      final reactionmessageuser = beforeReactions[indexCurrentEmoji];
        int indexUser = reactionmessageuser["users"].indexWhere((uid) => uid == userId);
        if (indexUser == -1) {
          reactionmessageuser
          ..["users"] = reactionmessageuser["users"] + [userId]
          ..["count"] = reactionmessageuser["count"] + 1;
        }
        else {
          reactionmessageuser
          ..["users"] = reactionmessageuser["users"].where((uid) => uid != userId).toList()
          ..["count"] = reactionmessageuser["count"] - 1;
          if (reactionmessageuser["users"].isEmpty) beforeReactions.removeAt(indexCurrentEmoji);
        } 
        setState(() {
          rebuild = false;
        });
        
      }} catch(e, t) {
        print("$e, $t");
      }
  }

  renderSystemMessage(attachments) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final messageTime = DateFormat('kk:mm').format(DateTime.parse(widget.insertedAt).add(Duration(hours: 7)));
    // TextStyle highLightText = TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E), fontSize: 11);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 7),
      child: Column(
        children:
          attachments.map<Widget>((att) {
            final params = att["params"];
            switch (att["type"]) {
              case "change_direct_name": 
                int time = att["current_time"];
                String dTime = DateTime.fromMicrosecondsSinceEpoch(time, isUtc: true).toString();
                dTime = DateFormat('kk:mm').format(DateTime.parse(dTime).add(Duration(hours: 7)));
                String userId = att["user_id"];
                String name = att["name"];
                String userNameChange = "";
                try {
                  List r = Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.conversationId)!.user.where((ele) => ele["user_id"] == userId).toList();
                  if (r.isNotEmpty) userNameChange = r.first["user_name"] ?? r.first["full_name"];                  
                } catch(e){}

                return Container(
                  width: 650,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => showInfo(context, userId),
                        child: Text(userNameChange, style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue,fontWeight: FontWeight.w400))),
                      Text(" ${S.current.hasChangedDMNameTo} ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      Flexible(child: Container( child: Text(name, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis)))),
                      Text(" ${S.current.ats} $dTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis))
                    ],
                  ),
                );
              case "poll":
                Map parentMessage = {
                  "id": widget.id,
                  "message": widget.message,
                  "avatarUrl": widget.avatarUrl,
                  "insertedAt": widget.insertedAt,
                  "fullName": widget.fullName,
                  "attachments": widget.attachments,
                  "isChannel": widget.isChannel,
                  "userId": widget.userId,
                  "channelId": widget.channelId,
                  "reactions": widget.reactions,
                  "lastEditedAt": widget.lastEditedAt,
                  "isUnsent": widget.isUnsent,
                };
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: LayoutBuilder(
                    builder: (context, BoxConstraints constraints) {
                      return Container(
                        width: constraints.maxWidth * 0.8,
                        child: PollCard(att: att, message: parentMessage)
                      );
                    }
                  ),
                );
              case "datetime" :
                final lastMessageReaded = !widget.isChannel ?
                  (Provider.of<DirectMessage>(context, listen: true).getCurrentDataDMMessage(widget.conversationId))!.lastMessageReaded:
                  Provider.of<Channels>(context, listen: true).currentChannel["last_message_readed"] ?? null;
                return Container(
                  margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          height: 40,
                          thickness: .5,
                          color: (Utils.checkedTypeEmpty(lastMessageReaded) && att["id"] == lastMessageReaded) ? Colors.red[400] : isDark ? Color(0xff707070) : Color(0xFFB7B7B7)
                        )
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                        child: Center(
                          child: Text(
                            DateFormatter().getVerboseDateTimeRepresentation(DateFormat("yyyy-MM-dd").parse(att["value"]), auth.locale).toUpperCase(),
                            style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w400,
                              color: Color(0xFF6a6e74),
                            )
                          )
                        )
                      ),
                      Expanded(
                        child: Divider(
                          height: 40,
                          thickness: .5,
                          color: (Utils.checkedTypeEmpty(lastMessageReaded) && att["id"] == lastMessageReaded) ? Colors.red[400] : isDark ? Color(0xff707070) : Color(0xFFB7B7B7)
                        )
                      ),
                      (Utils.checkedTypeEmpty(lastMessageReaded)  && att["id"] == lastMessageReaded) ? Container(
                        margin: EdgeInsets.only(left: 14, right: 20),
                        child: Text("NEW", style: TextStyle(color: Colors.red)),
                      ) : Container()
                    ]
                  )
                );
              case "header_message_converastion":
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            height: 40,
                            color: isDark ? Color(0xff707070) : Color(0xFFB7B7B7)
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            DateFormatter().getVerboseDateTimeRepresentation(DateFormat("yyyy-MM-dd").parse(widget.insertedAt), auth.locale).toUpperCase(),
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w400,
                              color: isDark ? Color(0xff707070) : Colors.grey[800]
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            height: 40,
                            color: isDark ? Color(0xff707070) : Color(0xFFB7B7B7)
                          )
                        )
                      ]
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFFcfba91) : Color(0xFFFFF7E6),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        border: Border.all(color: Color(0xFFFFD591))
                      ),
                      child: Text(att["data"],textAlign: TextAlign.center, style: TextStyle(color: Colors.black.withOpacity(0.65)))
                    )
                  ]
                );
              case "create_channel":
                final cuttedName = params["name"].length >= 15 ? params["name"].substring(0, 15) + " ..." : params["name"];
                final currentMemWs = Provider.of<Workspaces>(context, listen: false).currentMember;
                final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
                final currentUser = Provider.of<User>(context, listen: true).currentUser;
                final currentUserWs = Provider.of<Workspaces>(context, listen: true).currentMember;
                return Material(
                  elevation: 11,
                  type: isDark ? MaterialType.transparency : MaterialType.canvas,
                  child: Container(
                    width: 350,
                    padding: EdgeInsets.all(24),
                    margin: EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xff4C4C4C) : Color(0xffFAFAFA),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Column(
                      children: [
                        Text("${S.current.welcomeTo} \#$cuttedName",
                          style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 26,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Roboto',
                            overflow: TextOverflow.fade,
                            color: isDark ? Color(0xffF3F3F3) : Colors.black
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 40),
                          child: Container(
                            child: Text("${S.current.thisIsTheStartOf} \#${params["name"]}",
                            maxLines: 2,
                            textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xffC9C9C9),
                                overflow: TextOverflow.ellipsis
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff2E2E2E) : Color(0xffEDEDED),
                                borderRadius: BorderRadius.circular(5)
                              ),
                              margin: EdgeInsets.only(top: 10),
                              child: InkWell(
                                onTap: () {
                                  currentMemWs["role_id"] <= 2 || currentMemWs['user_id'] == currentChannel['owner_id']
                                  ? currentChannel['is_general'] ? Navigator.of(context, rootNavigator: true).push(createRoute(InviteMember(type: 'toWorkspace'))) :
                                    Navigator.of(context, rootNavigator: true).push(createRoute(InviteMember(type: 'toChannel')))
                                  : showDialog(
                                      context: context,
                                      builder: (_) => SimpleDialog(
                                      children: <Widget>[
                                          new Center(child: new Container(child: new Text(S.current.youDoNotHaveSufficient)))
                                      ])
                                    );
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Icon(PhosphorIcons.userPlus, size: 22, color: isDark ? Color(0xffffffff) : Color(0xff5E5E5E)),
                                      SizedBox(width: 20,),
                                      Text(S.current.invitePeople, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E))),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: SvgPicture.asset('assets/icons/NewRightArrow.svg', color: isDark ? Palette.topicTile : Palette.backgroundRightSiderDark, width: 8),
                                        )
                                      )
                                    ],
                                  ),
                                )
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff2E2E2E) : Color(0xffEDEDED),
                                borderRadius: BorderRadius.circular(5)
                              ),
                              margin: EdgeInsets.only(top: 20),
                              child: InkWell(
                                onTap: () {
                                  if (currentMemWs["role_id"] <= 2 || currentMemWs['user_id'] == currentChannel['owner_id']){
                                    showInputTopicDialog(context, widget.channelId);
                                  } else {
                                    return;
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.arrow_right_arrow_left_square, size: 22, color: isDark ? Color(0xffffffff) : Color(0xff5E5E5E)),
                                      SizedBox(width: 20,),
                                      Text(S.current.topic, style: TextStyle(color:  isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E))),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: SvgPicture.asset('assets/icons/NewRightArrow.svg', color: isDark ? Palette.topicTile : Palette.backgroundRightSiderDark, width: 8),
                                        )
                                      )
                                    ],
                                  ),
                                )
                              ),
                            ),
                            currentChannel["name"] != "newsroom" ?
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff2E2E2E) : Color(0xffEDEDED),
                                borderRadius: BorderRadius.circular(5)
                              ),
                              margin: EdgeInsets.only(top: 20),
                              child: InkWell(
                                onTap: () {
                                  if((currentUserWs["role_id"] == 1 || currentUserWs["role_id"] == 2 &&  currentChannel["owner_id"] == currentUser["id"] ) && currentChannel["name"] != "newsroom") {
                                    showWorkflowDialog(context, widget.channelId);
                                  } else {
                                    return;
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Row(
                                    children: [
                                      Icon(PhosphorIcons.bagSimple, size: 22, color: isDark ? Color(0xffffffff) : Color(0xff5E5E5E)),
                                      SizedBox(width: 20,),
                                      Text(S.current.changeWorkflow, style: TextStyle(color:  isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E))),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: SvgPicture.asset('assets/icons/NewRightArrow.svg', color: isDark ? Palette.topicTile : Palette.backgroundRightSiderDark, width: 8),
                                        )
                                      )
                                    ],
                                  ),
                                )
                              ),
                            ): Container(),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              case "invite":
                if (att["invited_users"] != null) {
                  final first = att["invited_users"][0];
                  final second = att["invited_users"][1];
                  return Text.rich(
                    TextSpan(
                      children: <InlineSpan> [
                        TextSpan(
                          text: Utils.getUserNickName(att["user_id"]) ?? att["user"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["user_id"])
                        ),
                        TextSpan(text: " ${S.current.hasInvited} ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(
                          text: Utils.getUserNickName(first["invited_user_id"]) ?? first["invited_user"],
                          style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, first["invited_user_id"])
                        ),
                        TextSpan(text: " and ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(
                          text: Utils.getUserNickName(second["invited_user_id"]) ?? second["invited_user"],
                          style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, second["invited_user_id"])
                        ),
                        if (att["invited_users"].length > 2) TextSpan(text: " and ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        if (att["invited_users"].length > 2) WidgetSpan(
                          child: Tooltip(
                            verticalOffset: 5.0,
                            preferBelow: false,
                            triggerMode: TooltipTriggerMode.tap,
                            message: att["invited_users"].sublist(2).map((e) => Utils.getUserNickName(e["invited_user_id"]) ?? e["invited_user"]).join(','),
                            child: Text("${att["invited_users"].length - 2} other people",style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400)),
                          )
                        ),
                        TextSpan(text: " ${S.current.toChannel}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: " ${S.current.ats} $messageTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400)),
                      ]
                    )
                  );
                }
                return !Utils.checkedTypeEmpty(att["user_id"]) || att["invited_user_id"] == att["user_id"] ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: Utils.getUserNickName(att["invited_user_id"]) ?? att["invited_user"],
                          style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["invited_user_id"])
                        ),
                        TextSpan(text: " ${S.current.hasJoinedTheChannelByCode}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: " ${S.current.ats} $messageTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400))
                      ]
                    ),textAlign: TextAlign.center,
                  ),
                ) : Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: Utils.getUserNickName(att["user_id"]) ?? att["user"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["user_id"])
                        ),
                        TextSpan(text: " ${S.current.hasInvited} ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(
                          text: Utils.getUserNickName(att["invited_user_id"]) ?? att["invited_user"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["invited_user_id"])
                        ),
                        TextSpan(text: " ${S.current.toChannel}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: " ${S.current.ats} $messageTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400)),
                      ]
                    ), textAlign: TextAlign.center,
                  ),
                );
              case "invite_direct":
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: Utils.getUserNickName(att["user_id"]) ?? att["user"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["user_id"])
                        ),
                        TextSpan(text: " ${S.current.hasInvited} ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(
                          text: Utils.getUserNickName(att["invited_user_id"]) ?? att["invited_user"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["invited_user_id"])
                        ),
                        TextSpan(text: " ${S.current.toThisConversation}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: " ${S.current.ats} $messageTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400)),
                      ]
                    ), textAlign: TextAlign.center,
                  ),
                );
              case "update_conversation":
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: Utils.getUserNickName(att["user"]['id']) ?? att["user"]['name'], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["user"]['id'])
                        ),
                        TextSpan(text: "  ${S.current.hasChanged} ${att['avatar_url'] != null ? 'avatar' : 'name'} this group ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ]
                    ),textAlign: TextAlign.center,
                  ),
                );
              case "leave_direct":
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: Utils.getUserNickName(att["user_id"]) ?? att["user"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["user_id"])
                        ),
                        TextSpan(text: " ${S.current.hasLeft} ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: "${S.current.thisConversation}", style: TextStyle(color: Colors.grey[500],fontSize: 13)),
                        TextSpan(text: " ${S.current.ats} $messageTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400)),
                      ]
                    ),textAlign: TextAlign.center,
                  ),
                );
              case "leave_channel":
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: Utils.getUserNickName(att["user_id"]) ?? att["user"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["user_id"])
                        ),
                        TextSpan(text: " ${S.current.hasLeftTheChannel}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: " ${S.current.ats} $messageTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400)),
                      ]
                    ),textAlign: TextAlign.center,
                  ),
                );
              case "delete":
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text:Utils.getUserNickName(att["delete_user_id"]) ?? att["delete_user_name"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 14 ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["delete_user_id"])
                        ),
                        TextSpan(text: " ${S.current.wasKickedFromThisChannel}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: " ${S.current.ats} $messageTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400)),
                      ]
                    ),textAlign: TextAlign.center,
                  ),
                );
              case "change_topic":
                return Container(
                  width: 600,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => showInfo(context, att["user_id"]),
                        child: Text(Utils.getUserNickName(att["user_id"]) ?? att["user_name"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue,fontWeight: FontWeight.w400))),
                      Text(" ${S.current.hasChangedChannelTopicTo} ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      InkWell(
                        onTap: (){
                         showDialog (
                          context: context,
                           builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark ? Color(0xFF3D3D3D) : Colors.white,
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                padding: EdgeInsets.all(18),
                                height: 236,
                                width: 580,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(S.current.topic, style: TextStyle(fontSize: 20, color: isDark ? Colors.grey[300] : Color(0xff334E68))),
                                    SizedBox(height: 14,),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 110,
                                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.grey[400]!, width: 1),
                                        color: Colors.transparent
                                      ),
                                      child: SelectableText.rich(
                                        TextSpan(
                                         text: params["topic"], style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[300] : Color(0xff334E68), fontWeight: FontWeight.w400,overflow: TextOverflow.ellipsis)
                                        ),
                                      )
                                    ),
                                    SizedBox(height: 14,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: 38,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: Color(0xffF57572), width: 1),
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(S.current.cancel, style: TextStyle(color: Color(0xffF57572))),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                           }
                          );
                        },
                        child: Text("${S.current.channelTopic.toLowerCase()}", style: TextStyle(color: Palette.calendulaGold, fontSize: 13))),
                      // Flexible(child: Container( child: Text(params["topic"], style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400,overflow: TextOverflow.ellipsis)))),
                      Text(" ${S.current.ats} $messageTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400))
                    ],
                  ),
                );
              case "change_name":
                return Container(
                  width: 650,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => showInfo(context, att["user_id"]),
                        child: Text(Utils.getUserNickName(att["user_id"]) ?? att["user_name"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue,fontWeight: FontWeight.w400))),
                      Text(" ${S.current.hasChangedChannelNameTo} ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      Flexible(child: Container( child: Text(params["name"], style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis)))),
                      Text(" ${S.current.ats} $messageTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis))
                    ],
                  ),
                );
              case "change_private":
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: Utils.getUserNickName(att["user_id"]) ?? att["user_name"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["user_id"])
                        ),
                        TextSpan(text: " ${S.current.hasChangedChannel} ${!params["is_private"] ? S.current.privates : S.current.public} ${S.current.to} ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: "${params["is_private"] ? S.current.privates : S.current.public}", style: TextStyle(color: Colors.grey[500])),
                        TextSpan(text: " at $messageTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400))
                      ]
                    ),textAlign: TextAlign.center,
                  )
                );

              case "archived":
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: Utils.getUserNickName(att["user_id"]) ?? att["user_name"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["user_id"])
                        ),
                        TextSpan(text: " ${S.current.hass} ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: "${params["is_archived"] ? "${S.current.archived}" : "${S.current.unarchived}"}", style: TextStyle(color: Colors.grey[500])),
                        TextSpan(text: " ${S.current.thisChannel}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: " ${S.current.ats} $messageTime", style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w400))
                      ]
                    ),textAlign: TextAlign.center,
                  ),
                );

              case "change_workflow":
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: Utils.getUserNickName(att["user_id"]) ?? att["user_name"], style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue ,fontWeight: FontWeight.w400),
                          recognizer: TapGestureRecognizer()..onTapUp = (_) => showInfo(context, att["user_id"])
                        ),
                        TextSpan(text: " ${S.current.hasChangedChannelWorkflowTo} ", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: "${params["kanban_mode"] ? "${S.current.kanbanMode}" : "${S.current.devMode}"}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        TextSpan(text: " ${S.current.ats} $messageTime", style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w400))
                      ]
                    ),textAlign: TextAlign.center,
                  ),
                );
              }
              return Container(height: 0);
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
    return name.substring(0, name.length - 2);
  }

  renderReactions(List reactions, List workspaceEmojiData){
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      child: Wrap(
        alignment: WrapAlignment.start,
        children: reactions.map((e){
          bool isMe = e["users"].indexWhere((element) => element == Provider.of<Auth>(context, listen: false).userId) != -1;
          return  GestureDetector(
            onTap: (){
              // if (widget.disableAction != null) return;
              if (!widget.isChannel) return DirectMessageController.sendReactionMessageDM(widget.conversationId, widget.id, (e["emoji"] as ItemEmoji).id, !isMe ? "insert" : "remove");
              final channelId = widget.isChannel ? Provider.of<Channels>(context, listen: false).currentChannel["id"] : null;
              final workspaceId = widget.isChannel ? Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"] : null;
              dummyReactions({
                "emoji_id": (e["emoji"] as ItemEmoji).id,
                "message_id": widget.id,
                "channel_id": channelId,
                "workspace_id": workspaceId,
                "user_id": Provider.of<Auth>(context, listen: false).userId,
              });
              Provider.of<Messages>(context, listen: false).handleReactionMessage({
                "emoji_id": (e["emoji"] as ItemEmoji).id,
                "message_id": widget.id,
                "channel_id": channelId,
                "workspace_id": workspaceId,
                "user_id": Provider.of<Auth>(context, listen: false).userId,
                "token": Provider.of<Auth>(context, listen: false).token,
              });
            },
            onLongPress: (){
              if (widget.disableAction != null) return;
              // show list Of reactions
              showBottomReactionList(context, reactions, widget.conversationId);
            },
            child: Container(
              // width: 30,
              padding: EdgeInsets.all(4),
              margin: EdgeInsets.only(right: 4, top: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: isMe && !isDark ? [BoxShadow(
                  color: isMe ? (isDark ? Color(0xffFAAD14) : Color(0xff91D5FF)) : Colors.transparent,
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1), // changes position of shadow
                ),] : [],
                color: isMe
                  ? isDark ? Color(0xffFFF1B8).withOpacity(0.3): Color(0xffE6F7FF)
                  : isDark ? Color(0xff4C4C4C) : Color(0xffF3F3F3)
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    height: 16, width: 16,
                    child: Text(e["emoji"].value, style: TextStyle(fontSize: 12, height: 1.38),)
                  ),
                  e["count"] > 0 ? Text("  ${e["count"]}", style: TextStyle(fontSize: 12, color: isDark ? Color(0xFFFAAD14) : Color(0xff1890FF)) ): Text("")

                ],
              )
            ),
          );
        }).toList(),
      ),
    );
  }

  handleReactionMessage(emojiId){
    if (!widget.isChannel) return DirectMessageController.sendReactionMessageDM(widget.conversationId, widget.id, emojiId, "insert");
    dummyReactions({
      "emoji_id": emojiId,
      "message_id": widget.id,
      "channel_id": widget.isChannel ? Provider.of<Channels>(context, listen: false).currentChannel["id"] : null,
      "workspace_id":  widget.isChannel ? Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"] : null,
      "user_id": Provider.of<Auth>(context, listen: false).userId,
    });
    Provider.of<Messages>(context, listen: false)
    .handleReactionMessage({
      "emoji_id": emojiId,
      "message_id": widget.id,
      "channel_id": widget.isChannel ? Provider.of<Channels>(context, listen: false).currentChannel["id"] : null,
      "workspace_id":  widget.isChannel ? Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"] : null,
      "token": Provider.of<Auth>(context, listen: false).token,
    });
  }

  Map getDataChannel(){
    try {
      List channels = Provider.of<Channels>(context, listen: false).data;
      int index  = channels.indexWhere((element) => "${element["id"]}" == "${widget.channelId}");
      return {
        ...(channels[index]),
        "channel_id": channels[index]["id"],
      };
    } catch (e) {
      return {};
    }
  }

  openListEmoji(){
    showBottomSelectEmoji(context,
    widget.isChannel ? getDataChannel()["id"] : null,
    widget.isChannel ? getDataChannel()["workspace_id"] : null,
    () {},
    widget.id,
    "userId",
    widget.conversationId,
    dummyReactions);
  }

  onTapMessage(){
    var token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final workspaceId = widget.isChannel ? currentWorkspace["id"] : null;
    if(widget.onTapMessage != null)  return widget.onTapMessage();
    final currentChannel = getDataChannel();
    if (widget.disableAction != null) return;
    if (!widget.success || !Utils.checkedTypeEmpty(widget.id)) return;
    if (widget.isChildMessage == null || widget.isChildMessage) return;
    if (widget.isChannel) {
      List _attachments = widget.attachments ?? [];

      if (_attachments.length > 0 && widget.attachments[0]['type'] == "poll") return; // ko cho reply thread doi voi poll
      Provider.of<ThreadUserProvider>(context, listen: false).updateThreadUnread(workspaceId, widget.channelId, {"id": widget.id}, token);
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
        return ThreadView(
          isChannel: true,
          idMessage: widget.id,
          keyDB: currentChannel["id"],
          channelId: widget.channelId,
        );
      }));
    } else {
      String keyDB = "${widget.insertedAt}__${widget.id}";
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
        return ThreadView(
          isChannel: false,
          idMessage: widget.id,
          keyDB: keyDB,
          idConversation: widget.conversationId,
          channelId: widget.channelId,
        );
      }));
    }
  }

  getUser(userId) {
    List users = [];

    if (!widget.isChannel){
      var indexConversation = Provider.of<DirectMessage>(context, listen: false).data.indexWhere((element) => element.id == widget.conversationId);
      if (indexConversation == -1) users = [];
      else users = Provider.of<DirectMessage>(context, listen: false).data[indexConversation].user;
    }

    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    int index = users.indexWhere((e) => e["id"] == userId || e["user_id"] == userId);
    users = Provider.of<Workspaces>(context, listen: false).getListUsers(widget.workspaceId ?? currentWorkspace['id']);


    if (index != -1) {
      return {
        "avatar_url": users[index]["avatar_url"],
        "full_name": users[index]["full_name"],
        "role_id": users[index]["role_id"]
      };
    } else {
      return {
        "avatar_url": "",
        "full_name": "Bot",
        'role_id': 4
      };
    }
  }

  onCreateIssue() {
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;

    final message = {
      'id': widget.id,
      'message': widget.message,
      'attachments': widget.attachments,
      "avatarUrl": widget.avatarUrl ?? "",
      "fullName": widget.fullName ?? "",
      "workspaceId": widget.conversationId != null ? null : currentWorkspace['id'],
      "channelId": widget.channelId,
      'conversationId': widget.conversationId,
      'insertedAt': widget.insertedAt,
      'isChannel': widget.isChannel
    };

    Navigator.pop(context);

    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      builder: (BuildContext context) {
        return BottomSheetCreateIssue(message: message);
      }
    );
  }

  @override
  void didUpdateWidget (oldWidget) {
    if (oldWidget.message != widget.message
      || oldWidget.attachments.toString() != widget.attachments.toString()
      || oldWidget.avatarUrl != widget.avatarUrl
      || oldWidget.fullName != widget.fullName
      || oldWidget.infoThread.toString() != widget.infoThread.toString()
      || oldWidget.reactions.toString() != widget.reactions.toString()
      || oldWidget.lastEditedAt != widget.lastEditedAt
      || oldWidget.isFirst != widget.isFirst
      || oldWidget.isLast != widget.isLast
      || oldWidget.waittingForResponse != widget.waittingForResponse
      || oldWidget.isBlur != widget.isBlur
      || oldWidget.isUnreadThreadMessage != widget.isUnreadThreadMessage
      || oldWidget.isUnsent != widget.isUnsent
      || oldWidget.isOnline != widget.isOnline
      || oldWidget.isDark != widget.isDark
      || oldWidget.idMessageToJump != widget.idMessageToJump
      || oldWidget.count != widget.count
    ) {
      this.setState(() {
        rebuild = false;
      });
    }

    super.didUpdateWidget(oldWidget);
  }
  var chatItem = Container();
  bool rebuild = false;
  var indexEmojiReaction = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    final deviceWidth = MediaQuery.of(context).size.width;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    String today = formatter.format(DateTime.now());
    List workspaceEmojiData =  widget.isChannel ? Provider.of<Workspaces>(context, listen: false).currentWorkspace["emojis"] ?? [] : [];
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    if (!rebuild) {
      try {
        final messageDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.insertedAt).add(Duration(hours: 7)));
        bool isToday = today == messageDate;
        chatItem = buildChatItem(deviceWidth, context, currentUser, isDark, isToday, workspaceEmojiData);
      } catch (e, t) {
        print("$e, $t");
        chatItem = Container(child: Text("${e.toString()}"));
      }
      rebuild = true;
    }
    return chatItem;
  }

  onDeleteDM(String mid, String conversationId, {String type = "delete"}){
    var token = Provider.of<Auth>(context, listen: false).token;
    Provider.of<DirectMessage>(context, listen: false).deleteMessage(token, widget.conversationId, {
      "id": widget.id,
      "current_time": widget.currentTime,
      "parent_id": widget.parentId,
      "sender_id": widget.userId
    }, type: type);
  }

  buildChatItem(double deviceWidth, BuildContext context, Map<dynamic, dynamic> currentUser, bool isDark, bool isToday, List<dynamic> workspaceEmojiData) {
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final channelId = widget.isChannel ? widget.channelId : null;
    final workspaceId = widget.isChannel ? currentWorkspace["id"] : null;
    final conversationId = widget.isChannel ? null : widget.conversationId != null ?  widget.conversationId : Provider.of<DirectMessage>(context, listen: false).directMessageSelected.id;
    final messageTime = Utils.parseDatetime(DateTime.parse(widget.insertedAt).add(Duration(hours: 7))); 
    // ignore: close_sinks
    final _statusMediaDownloadedController = StreamController<double>.broadcast(sync: false);
    Map dataMessage = {
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
      "reactions": widget.reactions,
      "lastEditedAt": widget.lastEditedAt,
      "isUnsent": widget.isUnsent,
      "count": widget.count,
      "isChildMessage": widget.isChildMessage,
      "current_time": widget.currentTime,
      "conversation_id": conversationId
    };
    bool isAttachmentV2 = false;
    if(widget.attachments.length > 0 ) {
      int index = widget.attachments.indexWhere((e) {
        return e?["attachments_v2"] == true;
      });

      if(index != -1) {
        isAttachmentV2 = true;
      }
    }
    return Container(
      child: Opacity(
      opacity: (widget.isBlur == null || !widget.isBlur) ? 1 : 0.2,
      child: (widget.isSystemMessage != null && widget.isSystemMessage)
        ? renderSystemMessage(widget.attachments)
        : AnimatedContainer(
          duration: Duration(seconds: 1),
          color: isHighlightMessage ? isDark ? Color(0xff5E5E5E) : Color(0xffF3F3F3): null,
          child: Container(
            width: deviceWidth,
            margin: EdgeInsets.only(bottom: widget.isLast ? 7 : 0,),
            child: Container(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onLongPress: () {
                    // if (widget.disableAction != null) return;
                    String keyDB = "${widget.insertedAt}__${widget.id}";
                    if (!widget.success || !Utils.checkedTypeEmpty(widget.id)) return;
                    HapticFeedback.lightImpact();
                    bool isInThread = widget.isThreadView != null;
                    showBottomActionMessage(context, widget.id, keyDB, widget.onEditMessage, widget.copyMessage, widget.isChildMessage, widget.userId, widget.isChannel, handleReactionMessage, openListEmoji, widget.conversationId, widget.channelId, onDeleteDM, onCreateIssue, widget.messageAction, widget.onReplyMessage, dataMessage, isInThread);
                  },
                  onTap: onTapMessage,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1,),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              padding: EdgeInsets.only(left: 16, right: 8),
                              child: (widget.isFirst || widget.showHeader || widget.isAfterThread || widget.showNewUser) ? GestureDetector(
                                onTap: () {
                                  if (currentUser["id"] != widget.userId) {
                                    showUserProfile(context, widget.userId);
                                  }
                                },
                                child: Stack(
                                  children: [
                                    CachedAvatar(widget.avatarUrl, height: 32, width: 32, isRound: true, name: widget.fullName, isAvatar: true),
                                    widget.isOnline ? Positioned(
                                      top: 22,
                                      left: 22,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          color: isDark ? Color(0xff353535) : Colors.white,
                                        ),
                                        padding: EdgeInsets.all(2),
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: Color(0xff73d13d),
                                          ),
                                        ),
                                      ),
                                    ) : SizedBox()
                                  ],
                                ))
                                : Container(width: 32, child: widget.success  ? Container() : Container(alignment: Alignment.topRight, child: Icon(Icons.error_outline, size: 15, color: Color(0xFFff7875)))
                              ),
                            ),
                            (widget.isChildMessage == true && widget.isThreadView == true) ?
                            Container(
                              margin: EdgeInsets.only(top: 4,left: 8),
                              child: StreamBuilder(
                                stream: _statusMediaDownloadedController.stream,
                                initialData:  0.0,
                                builder: ((context, snapshot) {
                                  double h = (snapshot.data as double?) ?? 0.0;
                                  if (h > 45 ) h = h- 22;
                                  return Container( width: 1, color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9), height: h);
                                }),
                              ),
                            ) : SizedBox() ,
                          ],
                        ),

                        MeasureSize(
                          onChange: (Size size) {  _statusMediaDownloadedController.add(size.height); },
                          child: Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 80),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (widget.isFirst || widget.showHeader || widget.isAfterThread || widget.showNewUser) ? Container(
                                  margin: EdgeInsets.only(bottom: 1, top: 3),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (currentUser["id"] != widget.userId) {
                                            showUserProfile(context, widget.userId);
                                          }
                                        },
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width - 150
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              text: widget.fullName ?? "",
                                              style: TextStyle(
                                                color: widget.isChannel
                                                  ? Utils.checkColorRole(getUser(widget.userId)["role_id"], isDark)
                                                  : widget.userId == currentUser["id"] ? Colors.lightBlue : isDark ? Color(0xffFFFFFF): Color(0xff2E2E2E),
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15.5,),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Utils.checkedTypeEmpty(widget.id) && widget.id != 1 ? Container(
                                        margin: EdgeInsets.only(left: 4, bottom: 1),
                                        child: (widget.isThreadView == true || widget.isChildMessage) ? Text(messageTime, style: TextStyle(fontSize: 12, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),) : Text( 
                                          (isToday || !widget.isChildMessage
                                            ? DateFormatter().renderTime(DateTime.parse(widget.insertedAt))
                                            : DateFormatter().renderTime(DateTime.parse(widget.insertedAt), type: "MMMd")),
                                          style: TextStyle(fontSize: 12, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),
                                        ),
                                      ) : Container()
                                    ]
                                  ),
                                ) : Container(),
                                Utils.checkedTypeEmpty(widget.isUnsent) || Utils.checkedTypeEmpty(widget.waittingForResponse)
                                  ? Container(
                                      height: 19,
                                      child: Text(
                                        Utils.checkedTypeEmpty(widget.isUnsent)
                                            ? "[This message was deleted.]"
                                            : Utils.checkedTypeEmpty(widget.waittingForResponse)
                                              ? "[Waitting for response, tap to learn more.]"
                                              : "",
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Color(isDark ? 0xffe8e8e8 : 0xff898989)
                                        ),
                                      )
                                    )
                                  : (widget.message != "" && widget.message != null && !isAttachmentV2) ? MessageCard(message: widget.message, id: widget.id, onTap: onTapMessage, lastEditedAt: widget.lastEditedAt, isConversation: widget.isConversation,) : Container(),

                                if (!Utils.checkedTypeEmpty(widget.isUnsent) && !Utils.checkedTypeEmpty(widget.waittingForResponse)) Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: AttachmentCard(
                                    blockCode: widget.blockCode,
                                    snippet: widget.snippet,
                                    attachments: widget.attachments,
                                    isChannel: widget.isChannel,
                                    id: widget.id,
                                    isChildMessage: widget.isChildMessage,
                                    conversationId: widget.conversationId,
                                    isThread: widget.isThread,
                                    lastEditedAt: widget.lastEditedAt,
                                    message: dataMessage,
                                  ),
                                ),
                                widget.isChannel 
                                  ? renderReactions(widget.reactions == null ? [] :  widget.reactions, workspaceEmojiData)
                                  : StreamBuilder(
                                          initialData: directMessageProvider.reactionMessageDMs,
                                          stream: directMessageProvider.reactionMessageDMStream.stream,
                                          builder: (c, s) {
                                            List<ReactionMessageUser>? data = ((s.data ?? directMessageProvider.reactionMessageDMs) as Map<String, List<ReactionMessageUser>>)[widget.id];
                                            // print("datatadtadtda: ${data}");
                                            if (data == null || data.isEmpty) return Container();
                                            return renderReactions(data.map((e){
                                              return {
                                                "emoji": e.emoji,
                                                "count": e.count,
                                                "users": e.userIds
                                              };
                                            }).toList(), []);
                                          }
                                        ),
                                (widget.count != null) && (widget.count > 0) ? 
                                RenderInfoThread(
                                  infoThread: widget.infoThread,
                                  insertedAt: widget.insertedAt,
                                  // onTapMessage: onTapMessage,
                                  isChannel: widget.isChannel,
                                  count: widget.count,
                                  id: widget.id,
                                  isInThreadDMView: widget.isInThreadDMView
                                )
                                // _renderInfoThread() 
                                : Container()
                              ]
                            )
                          )
                        )
                      ]
                    )
                  )
                )
              )
            )
          )
        )
      )
    );
  }
}

showInfo(context, userId) {
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    if (userId != null && currentUser["id"] != userId) showUserProfile(context, userId);
  }
// thread message not replied, only edit
showBottomActionMessage(context, idMessage, keyDB, onEditMessage, copyMessage, isChildMessage, userId, isChannel, handleReactionMessage, openListEmoji, conversationId, channelId, onDeleteDM, onCreateIssue, messageAction, onReplyMessage, message, isInThread){
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    backgroundColor: Color(0xff),
    constraints: BoxConstraints(),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    builder: (BuildContext dialogContext) {
      final auth = Provider.of<Auth>(context);
      final isDark = auth.theme == ThemeType.DARK;
      return InkWell(
        splashColor: Color(0xff),
        onTap: (){
          Navigator.pop(dialogContext);
        },
        child: Column(
          children: [
            Expanded(child: Container()),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Color(0xff3D3D3D) : Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
                border: Border.all(
                color: isDark ? Color(0xff707070) : Color(0xFFB7B7B7),
                width: 0.5
              ),
              ),
              child: DMActionMessage(
                idMessage: idMessage,
                keyDB: keyDB,
                onEditMessage: onEditMessage,
                copyMessage: copyMessage,
                isChildMessage: isChildMessage == null ? true : isChildMessage,
                userId: userId,
                isChannel: isChannel,
                handleReactionMessage: handleReactionMessage,
                openListEmoji: openListEmoji,
                conversationId: conversationId,
                channelId: channelId,
                onDeleteDM: onDeleteDM,
                onCreateIssue: onCreateIssue,
                messageAction: messageAction,
                onReplyMessage: onReplyMessage,
                dataMessage: message,
                isThreadView: isInThread,
              ),
            )
          ],
        ),
      );
    }
  );
}

showWorkflowDialog(context,channelId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Container(
          width: 240,
          height: 160,
          child: ChangeChannelInfo(type: 3,channelId: channelId,)
        ),
      );
    }
  );
}

showBottomReactionList(context, reactions, String? conversationId){
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    builder: (BuildContext context) {
      // List channelMembers =  Provider.of<Channels>(context, listen: true).channelMember;
      // final auth = Provider.of<Auth>(context);
      // final isDark = auth.theme == ThemeType.DARK;
      return ReactionsDialog(reactions: reactions, conversationId: conversationId);
    }
  );
}

showBottomSelectEmoji(context, channelId, workspaceId, onClose, messageId, userId, String? conversationId, dummyReactions) {
  final auth = Provider.of<Auth>(context, listen: false);
  final bool isDark = auth.theme == ThemeType.DARK;
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    builder: (BuildContext context) {
      return Container(
        height: 440, margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark ? Palette.backgroundRightSiderDark : Colors.white,
          border: Border.all(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight.withOpacity(0.75)),
          borderRadius: BorderRadius.all(Radius.circular(8))
        ),
        child: ListEmojiWidget(
          workspaceId: workspaceId ?? 0,
          onClose: () => Navigator.pop(context),
          onSelect: (emoji) {
            if (conversationId != null) return DirectMessageController.sendReactionMessageDM(conversationId, messageId, emoji.id, "insert");
            dummyReactions({
              "message_id": messageId,
              "channel_id": channelId,
              "workspace_id": workspaceId,
              "token": Provider.of<Auth>(context, listen: false).token,
              "emoji_id": emoji.id
            });
            Provider.of<Messages>(context, listen: false)
              .handleReactionMessage({
              "message_id": messageId,
              "channel_id": channelId,
              "workspace_id": workspaceId,
              "token": Provider.of<Auth>(context, listen: false).token,
              "emoji_id": emoji.id
            });
          },
        ),
      );
    }
  );
}

class RenderInfoThread extends StatefulWidget {
  RenderInfoThread({
    Key? key, this.infoThread, this.insertedAt, this.onTapMessage, this.isChannel, this.count, this.id, this.isInThreadDMView = false
  }) : super(key: key);

  final infoThread;
  final insertedAt;
  final onTapMessage;
  final isChannel;
  final count;
  final id;
  final bool isInThreadDMView;

  @override
  State<RenderInfoThread> createState() => _RenderInfoThreadState();
}

class _RenderInfoThreadState extends State<RenderInfoThread> {
  bool rebuild = true;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> infoThread = widget.infoThread;
    if (infoThread.length == 0)  return Container();
    final lastReply = infoThread[0]["inserted_at"] ?? infoThread[0]["time_create"];
    final auth = Provider.of<Auth>(context);
    final userList = infoThread.map((e) => e["user_id"]).toSet().toList();
    final isDark = auth.theme == ThemeType.DARK;

    DateTime dateTime = DateTime.parse(lastReply);
    final messageTime = DateFormat('kk:mm').format(DateTime.parse(lastReply).add(Duration(hours: 7)));
    final dayTime = DateFormatter().getVerboseDateTimeRepresentation(dateTime, auth.locale);
    List channelMembers =  Provider.of<Channels>(context, listen: true).channelMember;
    if (channelMembers.length == 0) {
      this.setState(() {
        rebuild = false;
      });
    }

    final messageLastTime = (lastReply != "" && lastReply != null)
      ? "${dayTime == "Today" ? messageTime : DateFormatter().renderTime(DateTime.parse(widget.insertedAt), type: "MMMd") + " ${S.current.ats} $messageTime"}"
      : "";
    final dataInfoThreadMessage = Provider.of<DirectMessage>(context, listen: false).dataInfoThreadMessage;

    var listUsers = widget.isChannel ? channelMembers : infoThread;
    var listIndex = [];
    var count = userList.length > 4 ? 4 : userList.length;
    for (var i = 0 ; i < count; i++) {
      var indexDataUser = listUsers.indexWhere((e) => e["id"] == userList[i] || e["user_id"] == userList[i]);
      if (indexDataUser != -1) {
        listIndex.add(indexDataUser);
      }
    }
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Container(
        height: 20,
        child: GestureDetector(
          onTap: widget.onTapMessage,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 22*listIndex.length - 7*(listIndex.length - 1),
                child: Stack(
                  children: [
                    for (var i = 0; i < listIndex.length; i++)
                      Positioned(
                        left: 15.0*i,
                        child: Container(
                          padding: EdgeInsets.only(left: 0, right: 2),
                          child: CachedAvatar(
                            listUsers[listIndex[i]]["avatar_url"],
                            width: 20,
                            height: 20,
                            isAvatar: true,
                            radius: 10,
                            name: listUsers[listIndex[i]]["full_name"] ?? "P"
                          )
                        ),
                      )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 8),
                child: Text("${widget.count} ${widget.count > 1 ? S.current.replies : S.current.replys}", style: TextStyle(fontSize: 10, color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF))),
              ),
              widget.isInThreadDMView ? Container(width: 8,) : Container(
                margin: EdgeInsets.only(left: 8, right: 8),
                child: Text(
                  "${S.current.lastReplyAt} $messageLastTime",
                  style: TextStyle(fontSize: 10, color: Color(0xff828282)),
                  overflow: TextOverflow.ellipsis,
                )
              ),
              ((dataInfoThreadMessage[widget.id])?.isRead ?? true) ? Text("") : Text("NEW", style: TextStyle(fontSize: 11, color: Colors.red))
            ]
          )
        )
      )
    );
  }
}