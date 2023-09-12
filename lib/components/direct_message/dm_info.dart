import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/components/call_center/call_manager.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/components/direct_message/dm_media.dart';
import 'package:workcake/components/direct_message/dm_member.dart';
import 'package:workcake/components/direct_message/dm_name.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';

class DMInfo extends StatefulWidget {
  DMInfo({Key? key, required this.id}) : super(key: key);
  final String id;  
  @override
  _DMInfo createState() => _DMInfo();
}

class _DMInfo extends State<DMInfo> {

  getDMInfo(DirectModel dm, field) {
    var users = dm.user;
    var result = "";
    for (var i = 0; i < users.length; i++) {
      if (i != 0) result += ", ";
      result += users[i][field];
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    DirectModel? directMessage = Provider.of<DirectMessage>(context, listen: true).getModelConversation(widget.id);
    if (directMessage == null) return Container();
    var listUser = (directMessage.id != "" ? directMessage.user : []).where((element) => element["status"] == "in_conversation" || element["status"] == null).toList();
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    var indexPanchat = listUser.indexWhere((element) => element["full_name"] == "Panchat");
    // var statusCalling = Provider.of<Calls>(context, listen: true).status;
    var indexContact = 1;

    String status = "NORMAL";
    int indexUser = listUser.indexWhere((element) => element["user_id"] == auth.userId);
    if (indexUser != -1) {
      status = listUser[indexUser]["status_notify"] ?? "NORMAL";
    }

    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: isDark ? Colors.transparent : Color(0xffEDEDED),
            child: Column(
              children: [
                Container(
                  height: 62,
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
                        Container(
                          width: 50,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          child: Text(
                            S.current.directMessageDetails,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            )
                          ),
                        ),
                        SizedBox(width: 50,)
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: isDark ? Color(0xff2E2E2E) : Color(0xffF3F3F3),
                    child: SingleChildScrollView(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                          Container(
                            child: Column(children: <Widget>[
                              Container(
                                
                                padding: EdgeInsets.only(top: 30),
                                child: Column(children: <Widget>[
                                  directMessage.avatarUrl != null ? CachedAvatar(
                                    directMessage.avatarUrl,
                                    name: directMessage.displayName,
                                    width: 160,
                                    height: 160,
                                  ) : Container(
                                    width: listUser.length <= 4 ? listUser.length * 64 - (listUser.length - 1) * 32 : 5 * 64 - 4 * 32,
                                    child: Stack(
                                      alignment: AlignmentDirectional.centerStart,
                                      children: [
                                        CachedAvatar(
                                          listUser[0]["avatar_url"],
                                          name: listUser[0]["full_name"],
                                          width: 50,
                                          height: 50,
                                        ),
                                        ...listUser.map((item) {
                                          if(item["user_id"] != listUser[0]["user_id"] && indexContact <= 6) {
                                            var avt =  Positioned(
                                              left: indexContact * 32,
                                              child: CachedAvatar(
                                                item["avatar_url"],
                                                name: item["full_name"],
                                                width: 50,
                                                height: 50,
                                              ),
                                            );
                                            indexContact++;
                                            if(indexContact >= 6) {
                                              return Positioned(
                                                left: 4 * 32,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(32),
                                                    color: isDark ? Color(0xff3D3D3D) : Color(0xffEAE8E8),
                                                  ),
                                                  width: 50,
                                                  height: 50,
                                                  child: Center(
                                                    child: Text("+ ${listUser.length - 4}", style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff000000), fontSize: 16, fontWeight: FontWeight.w500),),
                                                  ),
                                                ),
                                              ); 
                                            }
                                            else if (indexContact >= 5){
                                               return Positioned(
                                                left: 4 * 32,
                                                child: CachedAvatar(
                                                item["avatar_url"],
                                                name: item["full_name"],
                                                width: 50,
                                                height: 50,
                                               ),
                                              );
                                            }
                                            else {
                                              return avt;
                                            }
                                          } else {
                                            return Container();
                                          }
                                        })
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                                    child: Text(
                                      directMessage.displayName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 17, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontWeight: FontWeight.w700)
                                    )
                                  )
                                ]),
                              ),

                              SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Expanded(

                                      child: Container(
                                        height: 42,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: isDark ? Colors.transparent : Color(0xffC9C9C9),
                                            width: 1,
                                          )
                                        ),
                                        child: InkWell(
                                          onTap: (){
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) => NotificationOptions(
                                                conversationId: directMessage.id, 
                                                onSave: Provider.of<DirectMessage>(context, listen: false).updateSettingConversationMember
                                              )
                                            );
                                          },
                                          child: Container(
                                            height: 42,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: isDark ? Colors.transparent : Color(0xffC9C9C9),
                                                width: 1,
                                              ),
                                              color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                getIconNotificationByStatus(status, isDark),
                                                SizedBox(width: 10),
                                                Text(getShortLabelNotificationStatus(status), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))
                                              ],
                                            ),
                                          ),
                                        )
                                      )
                                    ),
                                    SizedBox(width: 12),
                                    if (indexPanchat == -1) Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          final currentUser = Provider.of<User>(context, listen: false).currentUser;
                                          final users = listUser;
                                          final index = users.indexWhere((e) => e["user_id"] != currentUser["id"]);
                                          final otherUser = index  == -1 ? {} : users[index];
                                          callManager.calling(context, otherUser, directMessage.id);
                                        },
                                        child: Container(
                                          height: 42,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: isDark ? Colors.transparent : Color(0xffC9C9C9),
                                              width: 1,
                                            ),
                                            color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(PhosphorIcons.phoneCall, size: 18),
                                              SizedBox(width: 10),
                                              Text(S.current.call, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500))
                                            ],
                                          ),
                                        ),
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                          SizedBox(height: 20),
                          Container(
                            margin: EdgeInsets.only(left: 16),
                            child: Text(S.current.messageName, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: isDark ? Color(0xff828282) : Color(0xff5E5E5E)))
                          ),
                          SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              Navigator.push(context,MaterialPageRoute(builder: (context) => DmName(id: widget.id)));
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
                                border: Border.all(
                                  color: isDark ? Colors.transparent : Color(0xffC9C9C9),
                                  width: 1,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      directMessage.displayName,
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(PhosphorIcons.pencilLine, size: 18,)
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            margin: EdgeInsets.only(left: 16),
                            child: Text(S.current.settings.toUpperCase(), style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: isDark ? Color(0xff828282) : Color(0xff5E5E5E)))
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
                              border: Border(
                                top: BorderSide(width: 1.0, color: isDark ? Colors.transparent : Color(0xffC9C9C9)),
                                bottom: BorderSide(width: 1.0, color: isDark ? Color(0xff5E5E5E) : Colors.transparent),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: InkWell(
                              onTap: () {
                                 Navigator.push(context,MaterialPageRoute(builder: (context) => DmMember(id: widget.id,)));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.users, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        S.current.members,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)),
                                      ),
                                    ],
                                  ),
                                  Icon(PhosphorIcons.caretRight, size: 18,)
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
                              border: Border(
                                top: BorderSide(width: 1.0, color: isDark ? Colors.transparent : Color(0xffC9C9C9)),
                                bottom: BorderSide(width: 1.0, color: isDark ? Color(0xff5E5E5E) : Colors.transparent),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: InkWell(
                              onTap: () {
                                 Navigator.push(context, MaterialPageRoute(builder: (context) => MediaConversationRender(id: widget.id)));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.image, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        '${S.current.photo} / ${S.current.files}',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)),
                                      ),
                                    ],
                                  ),
                                  Icon(PhosphorIcons.caretRight, size: 18,)
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
                              border: Border(
                                top: BorderSide(width: 1.0, color: isDark ? Colors.transparent : Color(0xffC9C9C9)),
                                bottom: BorderSide(width: 1.0, color: isDark ? Color(0xff5E5E5E) : Colors.transparent),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: InkWell(
                              onTap: () {
                                //  Navigator.push(context,MaterialPageRoute(builder: (context) => DmMember()));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.warning, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        S.current.reportDirectMessage,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
                              border: Border(
                                top: BorderSide(width: 1.0, color: isDark ? Colors.transparent : Color(0xffC9C9C9)),
                                bottom: BorderSide(width: 1.0, color: isDark ? Color(0xff5E5E5E) : Colors.transparent),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: InkWell(
                              onTap: () {
                                //  Navigator.push(context,MaterialPageRoute(builder: (context) => DmMember()));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.eyeSlash, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        S.current.hideDirectMessage,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
                              border: Border(
                                top: BorderSide(width: 1.0, color: isDark ? Colors.transparent : Color(0xffC9C9C9)),
                                bottom: BorderSide(width: 1.0, color: isDark ? Color(0xff5E5E5E) : Colors.transparent),
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: InkWell(
                              onTap: () {
                                 showDialog(
                                  context: context,
                                  builder: (BuildContext c) {
                                    return CustomDialogNew(
                                      title: "Delete Conversation", 
                                      content: "Are you sure want to delete this conversation?",
                                      confirmText: "Delete",
                                      onConfirmClick: ()async{
                                        
                                        if (await Provider.of<DirectMessage>(context, listen: false).leaveConversation(widget.id, auth.token, auth.userId)) {
                                          Navigator.pop(c);
                                          Navigator.pop(context);
                                        }
                                      },
                                      quickCancelButton: true,
                                    );
                                  }
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.trashSimple, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        S.current.deleteDirectMessage,
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          listUser.length > 2 ? Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
                              border: Border.all(
                                color: isDark ? Colors.transparent : Color(0xffC9C9C9),
                                width: 1,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: InkWell(
                              onTap: () {
                                onLeaveConversation(BuildContext dialogContext) async {
                                  final DirectModel? directMessage = Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.id);
                                  if (directMessage == null) return;
                                  final String token = Provider.of<Auth>(context, listen: false).token;
                                  final String userId = Provider.of<Auth>(context, listen: false).userId;
                                  var success = await Provider.of<DirectMessage>(context, listen: false).leaveConversation(directMessage.id, token, userId);
                                  if (success) {
                                    Navigator.pop(dialogContext);
                                    Navigator.pop(context);
                                  }
                                }
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return CustomDialogNew(
                                      title: "Leave Conversation", 
                                      content: "Are you sure want to leave this conversation?",
                                      confirmText: "Leave Conversation",
                                      onConfirmClick: () => onLeaveConversation(dialogContext),
                                      quickCancelButton: true,
                                    );
                                  }
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.signOut, size: 16),
                                      SizedBox(width: 8),
                                      Text(
                                        S.current.leaveGroup,
                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ) : Container(),
                    ])),
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

List optionNotificationChannel = [
  {"value": "NORMAL", "description": "${S.current.desNormalMode}", "label": "${S.current.normalMode}", "short_label": "Normal"},
  {"value": "MENTION", "description": "${S.current.justMention}", "label": "${S.current.mentionMode}",  "short_label": "Mention"},
  {"value": "SILENT", "description": "${S.current.desSilentMode}", "label": "${S.current.silentMode}",  "short_label": "Silent"},
  {"value": "OFF", "description": "${S.current.desOffMode}", "label": "${S.current.offMode}",  "short_label": "Off"},
];

List optionNotificationDms = [
  {"value": "NORMAL", "description": "${S.current.desNormalMode}", "label": "${S.current.normalMode}", "short_label": "Normal"},
  {"value": "MENTION", "description": "${S.current.justMention}", "label": "${S.current.mentionMode}",  "short_label": "Mention"},
  {"value": "OFF", "description": "${S.current.desOffMode}", "label": "${S.current.offMode}",  "short_label": "Off"},
];

Icon getIconNotificationByStatus(String status, bool isDark){
  switch (status) {
    case "NORMAL": return Icon(PhosphorIcons.bell, color: isDark ? Palette.topicTile : Color(0xff3D3D3D), size: 18);
    case "MENTION": return  Icon(PhosphorIcons.bellRinging, color: isDark ? Palette.topicTile : Color(0xff3D3D3D), size: 18);
    case "SILENT": return  Icon(PhosphorIcons.bellZ, color: isDark ? Palette.topicTile : Color(0xff3D3D3D), size: 18);
    case "OFF": return  Icon(PhosphorIcons.bellSlash, color: isDark ? Palette.topicTile : Color(0xff3D3D3D), size: 18);
    default: return Icon(PhosphorIcons.bell, color: isDark ? Palette.topicTile : Color(0xff3D3D3D), size: 18);
  }
}

String getShortLabelNotificationStatus(String value){
  int index = optionNotificationChannel.indexWhere((element) => element["value"] == value);
  if (index != -1) return optionNotificationChannel[index]["short_label"];
  return "";
}
// for dm

class NotificationOptions extends StatefulWidget {
  final String conversationId;
  final Function onSave;
  final bool isChannel;
  
  const NotificationOptions({ Key? key, required this.conversationId, required this.onSave, this.isChannel = false }) : super(key: key);

  @override
  _NotificationOptionsState createState() => _NotificationOptionsState();
}

class _NotificationOptionsState extends State<NotificationOptions> {
  String? notificationStatus;
   
  @override
  initState(){
    super.initState();
    if(widget.isChannel == true) {
      final currentMember = Provider.of<Channels>(context, listen: false).currentMember;
      notificationStatus = currentMember["status_notify"] ?? "NORMAL";
    }
    else {
      DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.conversationId);
      var userId  = Provider.of<Auth>(context, listen: false).userId;
      if (dm != null){
        var indexUser = dm.user.indexWhere((element) => element["user_id"] == userId);
        if (indexUser != -1) {
          notificationStatus = dm.user[indexUser]["status_notify"] ?? "NORMAL";
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final currentMember = Provider.of<Channels>(context, listen: false).currentMember;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
     return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4))
        ),
        titlePadding: const EdgeInsets.all(0),
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.zero,
        backgroundColor: isDark ? Color(0xFF3D3D3D ) : Colors.white,
        title: Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xff5E5E5E).withOpacity(0.5) : Color(0xffF3F3F3),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(4.0),
              topLeft: Radius.circular(4.0)
            )
          ),
          child: Container(
            padding: const EdgeInsets.only(top: 9, bottom: 9, left: 16),
            child: Text(S.current.notifySetting, style: TextStyle(fontSize: 16))
          ),
        ),
        content: Container(
          width: 729,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10)
          ),
          height: widget.isChannel ? 355 : 290,
          child: notificationStatus == null ? Container(
            child: Text("You can't change settings"),
          ) : Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 24, right: 24, top:24, bottom: 12),
                child: Column(
                  children: (widget.isChannel ? optionNotificationChannel : optionNotificationDms).map(
                    (option) => GestureDetector(
                      onTap: () {
                        setState(() {
                          notificationStatus = option["value"];
                        });
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 16),
                          margin: EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              width: 1,
                              color: Palette.borderSideColorLight,
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Radio<String>(
                                activeColor: Color(0xff096DD9),
                                value: option["value"],
                                groupValue: notificationStatus,
                                onChanged: (value) {
                                  setState(() => notificationStatus = value );
                                },
                              ),
                              Container(
                                child: getIconNotificationByStatus(option["value"], isDark),
                              ),
                              SizedBox(width: 5),
                              Text(option["label"],
                                style: TextStyle(
                                  color: isDark ? Palette.topicTile : Palette.backgroundRightSiderDark, 
                                  fontSize: 14
                                )
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(option["description"],
                                  style: TextStyle(
                                    color: isDark ? Color(0xffA6A6A6) : Color(0xff828282), 
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  
                                ),
                              )
                            ]
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),
              Divider(height: 1, thickness: 1),
              Container(
                height: 59,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 32,
                      width: 80,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          side: BorderSide(color: Color(0xffFF7875))
                        ),
                        onPressed: () { 
                          Navigator.of(context, rootNavigator: true).pop("Discard");
                        },
                        child: Text(S.current.cancel, style: TextStyle(color: Color(0xffFF7875)))
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
                      height: 32,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      margin: EdgeInsets.only(right: 12.0),
                      // color: Color(0xff1890FF),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Color(0xff1890FF)  
                      ),
                      child: TextButton(
                        onPressed: (){
                          if(widget.isChannel == true) {
                            Map member = Map.from(currentMember);
                            member["status_notify"] = notificationStatus;
                            Provider.of<Channels>(context, listen: false).changeChannelMemberInfo(auth.token, currentWorkspace["id"], currentChannel["id"], member, "changStatusNotify");
                          }
                          else {
                            widget.onSave(widget.conversationId, {
                              "status_notify": notificationStatus
                            }, auth.token, auth.userId);
                          }
                          Navigator.pop(context);
                        },
                        child: Text(S.current.save, style: TextStyle(color: Colors.white, fontSize: 13))
                      ),
                    )
                  ],
                ),
              )
            ]
          )
        ),
      )
    );
  }
}
