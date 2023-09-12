import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/channel/channel_app.dart';
import 'package:workcake/components/channel/channel_member.dart';
import 'package:workcake/components/channel/render_media_channel.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/components/direct_message/dm_info.dart';
import 'package:workcake/components/pinned_message.dart';
import 'package:workcake/models/models.dart';
import '../../generated/l10n.dart';
import 'change_channel_info.dart';
import '../invite_member.dart';

class ChannelInfo extends StatefulWidget {
  final token;
  final workspaceId;
  final channelId;
  final userId;

  ChannelInfo({
    Key? key,
    this.token,
    this.workspaceId,
    this.channelId,
    this.userId
  }) : super(key: key);

  @override
  _ChannelInfoState createState() => _ChannelInfoState();
}

class _ChannelInfoState extends State<ChannelInfo> {
  @override
  initState() {
    super.initState();
    Provider.of<Channels>(context, listen: false).getChannelMemberInfo(widget.token, widget.workspaceId, widget.channelId, widget.userId);
  }

  onChangeChannelInfo() async {
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final channels = Provider.of<Channels>(context, listen: false).data;
    final indexs = channels.indexWhere((e) => e['id'] == widget.channelId);
    final currentChannel = channels[indexs];
    final auth = Provider.of<Auth>(context, listen: false);
    final listChannelGeneral = Provider.of<Channels>(context, listen: false).channelGeneral;
    final index = listChannelGeneral.indexWhere((e) => e['workspace_id'] == currentChannel["id"]);

    if (index == -1) {
      await Provider.of<Channels>(context, listen: false).changeChannelInfo(auth.token, currentWorkspace["id"], currentChannel["id"], currentChannel);
    }
  }

  
  @override
  Widget build(BuildContext context) {
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final currentMember = Provider.of<Channels>(context, listen: false).currentMember;
    final currentUserWs = Provider.of<Workspaces>(context, listen: true).currentMember;
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    final channelMember = Provider.of<Channels>(context, listen: true).getChannelMember(currentChannel["id"]);
    
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    final isChannelOwner = currentChannel["owner_id"] == currentUser["id"];

    //Validate owner Channel for listItemMember
    final listItemSettings = isChannelOwner || ((currentUserWs["role_id"] == 1 || currentUserWs["role_id"] == 2 && currentChannel["owner_id"] == currentUser["id"]  ) && currentChannel["name"] != "newsroom") ?
    [
      {"leading": Icon(PhosphorIcons.user, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "All member", "trailing": true, "text": S.current.members},
      {"leading": Icon(PhosphorIcons.userPlus, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Invite members", "trailing": true, "text": S.current.invite},
      {"leading": Icon(PhosphorIcons.pushPin, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Pinned messages", "trailing": true, "text": S.current.pinMessages},
      {"leading": Icon(PhosphorIcons.files, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Files/Photos", "trailing": true, "text": "${S.current.photo} / ${S.current.video} / ${S.current.files}"},
      {"leading": Icon(PhosphorIcons.squaresFour, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Apps", "trailing": true, "text": "App"},
      {"leading": Icon(PhosphorIcons.archiveBox, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": (currentChannel["is_archived"] == true) ? "Unarchive Channel":  "Archive Channel", "trailing": false, "text":  (currentChannel["is_archived"] == true) ? S.current.unarchiveChannel : S.current.archiveChannel},
      {"leading": Icon(PhosphorIcons.bagSimple, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Change workflow", "trailing": false, "text": S.current.changeWorkflow},
      {"leading": Icon(PhosphorIcons.signOut, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Leave channel", "trailing": false, "text": S.current.leaveChannel},
      {"leading": Icon(PhosphorIcons.trashSimple, size: 18, color: Color(0xffFF7875)), "title": "Delete channel", "trailing": false, "text": S.current.deleteChannel},
    ]: currentUserWs["role_id"] == 4 ? [
      {"leading": Icon(PhosphorIcons.user, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "All member", "trailing": true, "text": S.current.members},
      {"leading": Icon(PhosphorIcons.files, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Files/Photos", "trailing": true, "text": "${S.current.photo} / ${S.current.video} / ${S.current.files}"},
      {"leading": Icon(PhosphorIcons.pushPin, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Pinned messages", "trailing": true, "text": S.current.pinMessages},
      {"leading": Icon(PhosphorIcons.signOut, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Leave channel", "trailing": false, "text": S.current.leaveChannel},
    ] : currentUserWs["role_id"] == 3 ? [
      {"leading": Icon(PhosphorIcons.user, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "All member", "trailing": true, "text": S.current.members},
      {"leading": Icon(PhosphorIcons.userPlus, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Invite members", "trailing": true, "text": S.current.invite},
      {"leading": Icon(PhosphorIcons.files, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Files/Photos", "trailing": true, "text": "${S.current.photo} / ${S.current.video} / ${S.current.files}"},
      {"leading": Icon(PhosphorIcons.pushPin, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Pinned messages", "trailing": true, "text": S.current.pinMessages},
      {"leading": Icon(PhosphorIcons.signOut, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Leave channel", "trailing": false, "text": S.current.leaveChannel},
    ] : [
      {"leading": Icon(PhosphorIcons.user, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "All member", "trailing": true, "text": S.current.members},
      {"leading": Icon(PhosphorIcons.userPlus, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Invite members", "trailing": true, "text": S.current.invite},
      {"leading": Icon(PhosphorIcons.files, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Files/Photos", "trailing": true, "text": "${S.current.photo} / ${S.current.video} / ${S.current.files}"},
      {"leading": Icon(PhosphorIcons.pushPin, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Pinned messages", "trailing": true, "text": S.current.pinMessages},
      {"leading": Icon(PhosphorIcons.bagSimple, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Change workflow", "trailing": false, "text": S.current.changeWorkflow},
      {"leading": Icon(PhosphorIcons.signOut, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)), "title": "Leave channel", "trailing": false, "text": S.current.leaveChannel},
    ];
    // final isDesktop = (Platform.isAndroid || Platform.isIOS) ? false : true;
    final indexOwner = channelMember.indexWhere((element) => element['id'] == currentChannel['owner_id']);
    final owner = indexOwner ==  -1 ? null  : channelMember[indexOwner];
    Map member = Map.from(currentMember);
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: Container(
            color: isDark ? Colors.transparent : Color(0xffEDEDED),
            child: Column(
              children: [
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff2E2E2E) : Colors.white,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                          highlightColor: Colors.transparent,
                          onTap: () => { 
                            Navigator.of(context).pop()
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Icon(PhosphorIcons.arrowLeft, size: 20, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            S.current.channelSettings,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )
                          ),
                        ),
                        Container(
                          width: 40,
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: isDark ? Color(0xff2E2E2E) : Color(0xffEDEDED),
                    // height: MediaQuery.of(context).size.height - 136,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: isDark ? Color(0xff2E2E2E) : Color(0xffF3F3F3),
                            height: 72,
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) => NotificationOptions(
                                          conversationId: "",
                                          onSave: () {},
                                          isChannel: true
                                        )
                                      );
                                      // member["status_notify"] = !member["status_notify"];
                                      // Provider.of<Channels>(context, listen: false).changeChannelMemberInfo(auth.token, currentWorkspace["id"], currentChannel["id"], member);
                                    },
                                    child: Container(
                                      height: 40,
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: isDark ? Color(0xff5E5E5E) : Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: isDark ? null : Border.all(color: Color(0xffC9C9C9))
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          member["status_notify"] == "OFF"
                                            ? Icon(PhosphorIcons.bellSlash, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), size: 18)
                                            : member["status_notify"] == "MENTION"
                                              ? Icon(PhosphorIcons.bellRinging, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), size: 18)
                                              : member["status_notify"] == "SILENT"
                                                ? Icon(PhosphorIcons.bellZ, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), size: 18)
                                                : Icon(PhosphorIcons.bell, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), size: 18),
                                          SizedBox(width: 5),
                                          Text(
                                            member["status_notify"] == "OFF"
                                              ? S.current.off
                                              : member["status_notify"] == "MENTION"
                                                ? "${S.current.mentions}"
                                                : member["status_notify"] == "SILENT"
                                                  ? S.current.silent
                                                  : S.current.normal,
                                            style: TextStyle(
                                              color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), 
                                              fontSize: 15, 
                                              fontWeight: FontWeight.w500,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ]
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8,),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      member["pinned"] = !member["pinned"];
                                      await Provider.of<Channels>(context, listen: false).changeChannelMemberInfo(auth.token, currentWorkspace["id"], currentChannel["id"], member, "pin");
                                    },
                                    child: Container(
                                      height: member["pinned"] ? 40 : 38,
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        color: member["pinned"] ? isDark ? Color(0xff5E5E5E) : Colors.white : isDark ? Color(0xff4C4C4C) : Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: member["pinned"] ? isDark ? null : Border.all(color: Color(0xffC9C9C9)) : Border.all(color: Color(0xffFAAD14)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(member["pinned"] ? PhosphorIcons.pushPin : PhosphorIcons.pushPinSlash, size: 17.5, color: member["pinned"] ? isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D) : Color(0xffFAAD14),),
                                          SizedBox(width: 8,),
                                          Text("${member["pinned"] ? "Pin" : "Unpin"}", style: TextStyle(color: member["pinned"] ? isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D) : Color(0xffFAAD14), fontSize: 15, fontWeight: FontWeight.w500),)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: (currentUserWs["role_id"] == 1 || currentUserWs["role_id"] == 2 &&  currentChannel["owner_id"] == currentUser["id"] ) && currentChannel["name"] != "newsroom" && currentChannel["is_general"] == false ? 8 : 0,),
                                ((currentUserWs["role_id"] == 1 || currentUserWs["role_id"] == 2 &&  currentChannel["owner_id"] == currentUser["id"] ) && currentChannel["name"] != "newsroom" && currentChannel["is_general"] == false) ? Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      currentChannel["is_private"] = !currentChannel["is_private"];
                                      onChangeChannelInfo();
                                    },
                                    child: Container(
                                      height: !currentChannel["is_private"] ? 40 : 38,
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: !currentChannel["is_private"] ? isDark ? Color(0xff5E5E5E) : Colors.white : isDark ? Color(0xff4C4C4C) : Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                        border: !currentChannel["is_private"] ? isDark ? null : Border.all(color: Color(0xffC9C9C9)) : Border.all(color: isDark ? Color(0xff40A9FF) : Color(0xff1890FF)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          !currentChannel["is_private"] ? isDark ? SvgPicture.asset("assets/images/icons/pubDark.svg") : SvgPicture.asset("assets/images/icons/pubLight.svg") : isDark ? SvgPicture.asset("assets/images/icons/priDark.svg") : SvgPicture.asset("assets/images/icons/priLight.svg"),
                                          SizedBox(width: 4,),
                                          Text("${!currentChannel["is_private"] ? S.current.regular : S.current.private}", style: TextStyle(color: !currentChannel["is_private"] ? isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D) : isDark ? Color(0xff40A9FF) : Color(0xff1890FF), fontSize: 15, fontWeight: FontWeight.w500),)
                                        ],
                                      ),
                                    ),
                                  ),
                                ) : SizedBox()
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: isDark ? Color(0xFF2E2E2E) : Color(0xffF3F3F3),
                            padding: EdgeInsets.only(left: 16, bottom: 8),
                            child: Text(S.current.channelName, style: TextStyle(color: isDark ? Color(0xff828282) : Color(0xff5E5E5E), height: 1.28, fontSize: 14, fontWeight: FontWeight.w700))
                          ),
                          Container(
                            height: 76,
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff3D3D3D) : Colors.white,
                              border: isDark ? null : Border(top: BorderSide(color: Color(0xffC9C9C9)), bottom: BorderSide(color: Color(0xffC9C9C9)))
                            ),
                            padding: EdgeInsets.only(top: 10, bottom: 12, left: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          currentChannel['name'],
                                          style: TextStyle(
                                            fontSize: 15,
                                            height: 1.5,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)
                                          ),
                                        ),
                                      ),
                                      Text(
                                        // 'Private Channel - Invite Only',
                                        "${currentChannel["is_private"] ? "${S.current.privateChannel} - ${S.current.inviteOnly}" : S.current.regular}",
                                        style: TextStyle(
                                          color: isDark ? Color(0xffA6A6A6) : Color(0xff828282),
                                          fontSize: 13,
                                          height: 1.7
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                isChannelOwner || (currentUserWs['role_id'] ?? 0) <= 2 
                                ? InkWell(
                                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    showInputDialog(context,widget.channelId);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: Icon(PhosphorIcons.pencilLine, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D),),
                                  ),
                                ) : Container(
                                  width: 10,
                                  height: 10,
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: isDark ? Color(0xFF2E2E2E) : Color(0xffF3F3F3),
                            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                            child: Text(S.current.topic.toUpperCase(), style: TextStyle(color: isDark ? Color(0xff828282) : Color(0xff5E5E5E), height: 1.28, fontSize: 14, fontWeight: FontWeight.w700))
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff3D3D3D) : Colors.white,
                              border: isDark ? null : Border(top: BorderSide(color: Color(0xffC9C9C9)), bottom: BorderSide(color: Color(0xffC9C9C9)))
                            ),
                            padding: EdgeInsets.only(top: 10, bottom: 12, left: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width - 66,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SelectableText(
                                            currentChannel['topic'] ?? S.current.whatForDiscussion,
                                            style: TextStyle(
                                              fontSize: 15,
                                              height: 1.5,
                                              fontWeight: FontWeight.w500,
                                              color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)
                                            ),
                                          ),
                                          SizedBox(height: 5,),
                                          currentChannel['topic'] != "" ? RichText(
                                          text: TextSpan(
                                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                                            text: owner != null ? '${S.current.createBy} ' : '${S.current.created}',
                                            children: <TextSpan>[
                                              TextSpan(text: owner != null ? owner['full_name'] : ""),
                                              TextSpan(text: ' on '),
                                              TextSpan(text: DateFormatter().renderTime(DateTime.parse(currentChannel['inserted_at']), type: 'yMMMMd'))
                                            ]
                                          )) : Container()
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                isChannelOwner || (currentUserWs['role_id'] ?? 0) <= 2
                                ? InkWell(
                                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    showInputTopicDialog(context, widget.channelId);
                                    },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: Icon(PhosphorIcons.pencilLine, size: 18, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D),),
                                  ),
                                ) : Container(
                                  width: 10,
                                  height: 10,
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            color: isDark ? Color(0xFF2E2E2E) : Color(0xffF3F3F3),
                            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                            child: Text(S.current.settings.toUpperCase(), style: TextStyle(color: isDark ? Color(0xff828282) : Color(0xff5E5E5E), height: 1.28, fontSize: 14, fontWeight: FontWeight.w700))
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: isDark ? null : Border(top: BorderSide(color: Color(0xffC9C9C9)))
                            ),
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: listItemSettings.length,
                              itemBuilder: (BuildContext context, int index) { 
                                return ListItem(
                                  back: context,
                                  leading: listItemSettings[index]["leading"],
                                  title: listItemSettings[index]["title"],
                                  text: listItemSettings[index]["text"],
                                  trailing: listItemSettings[index]["trailing"],
                                  isLastItem: index == listItemSettings.length - 1 ? true : false,
                                  channelId: widget.channelId,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final leading;
  final title;
  final text;
  final trailing;
  final bool isLastItem;
  final channelId;
  final back;

  const ListItem({
    Key? key,
    this.title, 
    this.leading,
    this.trailing = true,
    this.isLastItem = false, 
    this.text,
    this.channelId,
    this.back
  }) : super(key: key);

  showConfirmDialog(context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final channels = Provider.of<Channels>(context, listen: false).data;
    final index = channels.indexWhere((e) => e['id'] == channelId);
    final currentChannel = channels[index];
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final listChannelGeneral = Provider.of<Channels>(context, listen: false).channelGeneral;
    final channelGeneral = listChannelGeneral.firstWhere((e) => e['workspace_id'] == currentWorkspace["id"]);

    onDeleteChannel() {
      Provider.of<Channels>(context, listen: false).deleteChannel(auth.token, currentWorkspace["id"], currentChannel["id"], channelGeneral["id"]);
      Navigator.pop(context);
      Navigator.pop(back);
    }

   showDialog(
      context: context,
      builder: (BuildContext context) {
      return CustomDialogNew(
        title: S.current.deleteChannel, 
        content: S.current.descDeleteChannel,
        quickCancelButton: true,
        onConfirmClick: onDeleteChannel,
        confirmText: "Delete Channel",
      );
    }
  );
}
onArchiveChannel(title, context) {
  final auth = Provider.of<Auth>(context, listen: false);

  final channels = Provider.of<Channels>(context, listen: false).data;
  final indexs = channels.indexWhere((e) => e['id'] == channelId);
  final currentChannel = channels[indexs];
  final unarchiveChannel = Provider.of<Channels>(context, listen: false).data
    .where((e) {
      return e["workspace_id"] == currentChannel["workspace_id"] && (e["is_archived"] == null || !e["is_archived"]);
    }).toList();
  // String suffixNameChannel(value) {
  //   int i = 0;
  //   String text = value;
  //   bool check = true;
  //   while (check) {
  //     int index = channels.indexWhere((e) => e["name"] == text);
  //     if (index == -1) break;
  //     List suffix = text.split("_");
  //     try{
  //       int indexCheck = int.parse(suffix.last);
  //       suffix[suffix.length - 1] = (indexCheck + 1).toString();
  //       text = suffix.join("_");
  //     } catch (e) {
  //       i += 1;
  //       text = text + "_$i";
  //     }
  //   }
  //   return text;
  // }

  archiveChannel() {
    Map channel = new Map.from(currentChannel);
    bool isArchived = channel["is_archived"] != null ? !channel["is_archived"] : true;
    channel["is_archived"] = isArchived;

    int indexChannelArchived = unarchiveChannel.indexWhere((e) => e["name"] == channel["name"]);
    // if(indexChannelArchived != -1 && !isArchived) {
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       String text = suffixNameChannel(currentChannel["name"]);
    //       return ChannelNameDialog(
    //         title: "CHANNEL NAME",
    //         displayText: text,
    //         onSaveString: (value) {
    //           int index = channels.indexWhere((e) => e["name"] == value);
    //           if(index == -1) {
    //             channel["name"] = value;
    //             Provider.of<Channels>(context, listen: false).changeChannelInfo(auth.token, currentWorkspace["id"], currentChannel["id"], channel, context);
    //           } else {
    //             
    //           }
    //           Timer(Duration(milliseconds: 500), () => Navigator.pop(context));
    //         }
    //       );
    //     }
    //   );
    if(indexChannelArchived != -1 && !isArchived) {
      print("Gap truong hop channel trung ten");
    }
    else {
      Provider.of<Channels>(context, listen: false).changeChannelInfo(auth.token, currentChannel["workspace_id"], currentChannel["id"], channel);
    }
    Navigator.pop(context);
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      String string = "${S.current.areYouWantTo} ${currentChannel["is_archived"] == true ? S.current.unarchived.toLowerCase() : S.current.archive.toLowerCase()} #${currentChannel["name"]} ?";

      return CustomDialogNew(title: text, content: string, onConfirmClick: archiveChannel, confirmText: "OK");
    }
  );
}


  @override
  Widget build(BuildContext context) {
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    final currentUserWs = Provider.of<Workspaces>(context, listen: true).currentMember;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;

    return InkWell(
      onTap: (){
        if (title == "All member") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChannelMember(isDelete: false,channelId: channelId,)));
        } else if (title == "Invite members") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => InviteMember(type: 'toChannel',channelId: channelId)));
        } else if (title == "Apps") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChannelApp(id: null,)));
        } else if(title == "Delete channel" && (currentChannel["name"] != "newsroom")) {
          showConfirmDialog(context);
        } else if (title == "Leave channel") {
          showLeaveChannelDialog(context, channelId);
        } else if (title == "Archive Channel" || title == "Unarchive Channel") {
          ((currentUserWs["role_id"] == 1 || currentUserWs["role_id"] == 2 || currentUserWs["role_id"] == 3 && currentChannel["owner_id"] == currentUser["id"]  ) && currentChannel["name"] != "newsroom") ? onArchiveChannel(title, context) : Container();
        } else if (title == 'Pinned messages') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PinnedMessages(channelId: channelId,)));
        } else if (title == 'Files/Photos') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RenderMediaChannel(channelId: channelId,)));
        } else if (title == "Change workflow") {
          showWorkflowDialog(title, context, channelId);      
        } 
      },
      overlayColor: MaterialStateProperty.all(Colors.transparent),
      highlightColor: Colors.transparent,
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Color(0xff3D3D3D) : Colors.white,
          border: isLastItem && isDark ? null : Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9), width: 0.4)),
          boxShadow: isLastItem && isDark ? [
            BoxShadow(
              offset: Offset(0, 4),
              blurRadius: 40,
              color: Colors.black.withOpacity(0.1)
            )
          ] : []
        ),
        child: Row(
          mainAxisAlignment: trailing ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          children: [
            Row(
              children: [
                leading,
                SizedBox(width: 8,),
                Text(text, style: TextStyle(fontSize: 16, color: title == "Delete channel" ? Color(0xffFF7875) : isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)),)
              ],
            ),
            trailing ? Icon(PhosphorIcons.caretRight, size: 20, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)) : SizedBox()
          ],
        )   
      ),
    );
  }
}

class StackAvatar extends StatelessWidget {
  final currentChannel;
  final channelId;
  const StackAvatar({Key? key, @required this.currentChannel, this.channelId }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            child: currentChannel["avatar_url"] != null ? CachedAvatar(currentChannel["avatar_url"], radius: 50, width: 75, height: 75, name: '',) :
            CircleAvatar(
              backgroundColor: Utils.getPrimaryColor(),
              radius: 32,
              child: Text(
                currentChannel["name"].substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Colors.white
                ),
              ),
            ),
          ),
          currentChannel["avatar_url"] != null ? Positioned(
            bottom: 3, right: 3, 
            child: Transform.rotate(
              angle: 36.1,
              child: Icon(Icons.edit, size: 24, color: isDark ? Colors.grey[300] : Colors.grey[600])
            )
          ) : Positioned(right: 0, child: Icon(Icons.add_photo_alternate, size: 28, color: isDark ? Colors.grey[300] : Colors.grey[600]))
        ]
      ),
    );
  }
}

onShowMemberChannelDialog(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        content: Container(
          height: 465.0,
          width: 400.0,
          child: Center(
            child: ChannelMember(isDelete: false),
          )
        ),
      );
    }
  );
}

showSelectDialog(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Container(
          width: 240,
          height: 160,
          child: ChangeChannelInfo(type: 2)
        ),
      );
    }
  );
}
showWorkflowDialog(title, context,channelId) {
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
showLeaveChannelDialog(context,channelId) {
  final auth = Provider.of<Auth>(context, listen: false);
  final channels = Provider.of<Channels>(context, listen: false).data;
  final index = channels.indexWhere((e) => e['id'] == channelId);
  final currentChannel = channels[index];
  final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;

  showDialog(
    context: context,
    builder: (BuildContext context) {

      onLeaveChannel() {
        Provider.of<Channels>(context, listen: false).leaveChannel(auth.token, currentWorkspace["id"], currentChannel["id"]);
        Navigator.pop(context);
      }
      return CustomDialogNew(
        title: S.current.leaveChannel, 
        content: S.current.descLeaveChannel,
        confirmText: "Leave Channel",
        onConfirmClick: onLeaveChannel,
        quickCancelButton: true,
      );
    }
  );
}

showConfirmDialog(context, channelId) {
    final auth = Provider.of<Auth>(context, listen: false);
    final channels = Provider.of<Channels>(context, listen: false).data;
    final index = channels.indexWhere((e) => e['id'] == channelId);
    final currentChannel = channels[index];
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final listChannelGeneral = Provider.of<Channels>(context, listen: false).channelGeneral;
    final channelGeneral = listChannelGeneral.firstWhere((e) => e['workspace_id'] == currentWorkspace["id"]);

    onDeleteChannel() {
      Provider.of<Channels>(context, listen: false).deleteChannel(auth.token, currentWorkspace["id"], currentChannel["id"], channelGeneral["id"]);
      Navigator.pop(context);
    }

   showDialog(
      context: context,
      builder: (BuildContext context) {
       return CustomDialogNew(
        title: "Delete Channel", 
        content: "Are you sure want to delete channel?\nThis action cannot be undone.",
        confirmText: "Delete",
        onConfirmClick: onDeleteChannel,
        quickCancelButton: true,
      );
    }
  );
}

showInputDialog(context, channelId) {
  final channels = Provider.of<Channels>(context, listen: false).data;
  final index = channels.indexWhere((e) => e['id'] == channelId);
  final currentChannel = channels[index];
  final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
  final auth = Provider.of<Auth>(context, listen: false);
  String string = currentChannel["name"];
  String title = S.current.channelName;
  
  onChangeChannelInfo(value) async {
    if (value != "") {
      Map channel = new Map.from(currentChannel);
      channel["name"] = value;

      await Provider.of<Channels>(context, listen: false).changeChannelInfo(auth.token, currentWorkspace["id"], currentChannel["id"], channel);
      Navigator.of(context, rootNavigator: true).pop("Discard");
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ChannelNameDialog(title: title, string: string, onSaveString: onChangeChannelInfo);
    }
  );
}

showInputTopicDialog(context, channelId) {
  final channels = Provider.of<Channels>(context, listen: false).data;
  final index = channels.indexWhere((e) => e['id'] == channelId);
  final currentChannel = channels[index];
  final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
  final auth = Provider.of<Auth>(context, listen: false);
  final String string = currentChannel["topic"] ?? "";
  final String title = S.current.topic;
  
  onChangeChannelInfo(value) async {
    if (value != "") {
      Map channel = new Map.from(currentChannel);
      channel["topic"] = value;

      await Provider.of<Channels>(context, listen: false).changeChannelInfo(auth.token, currentWorkspace["id"], currentChannel["id"], channel);
      Navigator.of(context, rootNavigator: true).pop("Discard");
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(title: title, textDisplay: string, onSaveString: onChangeChannelInfo);
    }
  );
}