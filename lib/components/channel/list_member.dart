import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/desktop/components/user_profile_desktop.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/friends_screen/index.dart';

import '../../generated/l10n.dart';

class ListMember extends StatefulWidget {
  final members;
  final isDelete;
  final type;

  ListMember({Key? key, this.isDelete, this.type, this.members}) : super(key: key);

  @override
  _ListMemberState createState() => _ListMemberState();
}

class _ListMemberState extends State<ListMember> {
  List checkboxs = [];
  List channelMember = [];

  @override
  void initState() {
    super.initState();
    filterChannelMember();
  }


//update lai list sau khi search
  @override
  void didUpdateWidget (oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.members != widget.members){
      getMember();
    }
  }

  filterChannelMember(){
    final workspaceMember = Provider.of<Workspaces>(context, listen: false).members;
    for(int i=0; i<workspaceMember.length; i++) {
      if((widget.members.indexWhere((element) => element["id"] == workspaceMember[i]["id"]) != -1)) {
        channelMember.add(workspaceMember[i]);
      }
    }
  }

  getMember(){
    channelMember.clear();
    filterChannelMember();
  }

  onSelect(value, index) {
    List list = checkboxs.toSet().toList();
    if (value) {
      list.add(index);
    } else {
      list.remove(index);
    }
    this.setState(() {
      checkboxs = list;
    });

    Provider.of<Channels>(context, listen: false).onSelectChannelMember(list);
  }
  

  checkRoleColor(memberRole, isDark) {
    switch(memberRole) {
      case 1:
        return Color(0xffFF7A45);
      case 2:
        return Color(0xff73D13D);
      case 3:
        return Color(0xff36CFC9);
      case 4:
        return isDark ? Color(0xffFFFFFF) : Color(0xff2E2E2E);
      default:
        return Color(0xffb7b4b4);
    }
  }
  

  Widget renderMember(members, currentUser, titleList, currentUserWs, isOwner, currentMember) {
    final isDark = Provider.of<Auth>(context).theme == ThemeType.DARK;
    final isDesktop = (Platform.isAndroid || Platform.isIOS) ? false : true;

    return Container(
      margin: EdgeInsets.only(bottom: 12, top: members.length == 0 ? 0 : 10),
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return InkWell(
            onTap: () async {
              if (widget.type == "channel") {
                if (currentUser["id"] != member["id"]) {
                  if (isDesktop) {
                    showUserDialog(context, member["id"]);
                  } else {
                    showUserProfile(context, member["id"]);
                  }
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(width: 0.2, color: isDark ? Colors.transparent : Colors.grey)
                            ),
                            child: CachedAvatar(member["avatar_url"], height: 26, width: 26, isRound: true, name: member["full_name"])),
                          if (titleList != "Offline") Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: titleList == "Offline" ? Color(0xffA6A6A6) : Color(0xff27AE60),
                                border: Border.all(width: 2, color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED)),
                                borderRadius: BorderRadius.circular(6)
                              ) ,
                              width: 12,
                              height: 12,
                            ),
                          )
                        ],
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${member["nickname"] ?? member["full_name"]}', 
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: member["is_online"] ?? false 
                        ? checkRoleColor(member["role_id"], isDark) 
                        : isDark ? Colors.white60 : Color(0xff3D3D3D))),
                    ]
                  ),
                  if((isOwner || (member["role_id"] != null && currentUserWs['role_id'] <= 3 && currentUserWs["role_id"] <= member["role_id"])) && (currentMember["user_id"] != member["id"])) 
                   InkWell(
                     onTap: () {
                       showDeleteMemberDialog(context, member["id"]);
                     },
                    child: Container(
                      padding: EdgeInsets.only(right: 16),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.close, size: 13),
                      )
                    ),
                  )
                ],
              ),
            ),
          );
        }
      )
    );
  }

  showDeleteMemberDialog(context, memberId) {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    showDialog(
      context: context, 
      builder: (BuildContext context){
        onDeleteMember() async {
          await Provider.of<Workspaces>(context, listen: false).deleteChannelMember(auth.token, currentWorkspace['id'], currentChannel['id'], [memberId]);
          getMember();
          Navigator.pop(context);
        }
        // return Container(
        //   child: AlertDialog(
        //     content: Container(
        //       width: 450,
        //       height: 100,
        //       child: Column(
        //         children: [
        //           Text(
        //             "Do you want to delete this member from this channel?",
        //             style: TextStyle(
        //               fontSize: 16,
                      
        //             ),
        //             textAlign: TextAlign.center,
        //           ),
        //           SizedBox(height: 12),
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceAround,
        //             children: [
        //               Container(
        //                 width: 120,
        //                 child: TextButton(
        //                   onPressed: () {
        //                     Navigator.pop(context);
        //                   }, 
        //                   child: Container(
        //                     margin: EdgeInsets.symmetric(horizontal: 12),
        //                     child: Text("Cancel", style: TextStyle(color: Color(0xff1890FF), fontWeight: FontWeight.w300, fontSize: 16))
        //                   )
        //                 ),
        //               ),
        //               SizedBox(width: 8),
        //               Container(
        //                 width: 120,
        //                 child: TextButton(
        //                   onPressed: () {
        //                     onDeleteMember();
        //                   }, 
        //                   child: Container(
        //                     margin: EdgeInsets.symmetric(horizontal: 12),
        //                     child: Text("Delete", style: TextStyle(color: Color(0xffEB5757), fontWeight: FontWeight.w700, fontSize: 16))
        //                   )
        //                 ),
        //               ),
        //             ],
        //           )
        //         ],
        //       ),
        //     ),
        //   ),
        // );
        return CustomDialogNew(
          title: "Confirm", 
          content:  "Do you want to delete this member from this channel?",
          confirmText: "Delete",
          onConfirmClick: onDeleteMember,
          quickCancelButton: true,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context).currentUser;
    double deviceWidth = MediaQuery.of(context).size.width;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final userMembers = channelMember.where((e) => e["account_type"] == "user").toList();
    final appMembers = channelMember.where((e) => e["account_type"] == "app").toList();
    final onlineMembers = userMembers.where((e) => e["is_online"] == true).toList();
    final offlineMembers = userMembers.where((e) => e["is_online"] != true).toList();
    final ownerMember = onlineMembers.where((e) => e["role_id"] == 1).toList();
    final adminMembers = onlineMembers.where((e) => e["role_id"] == 2).toList();
    final editorMembers = onlineMembers.where((e) => e["role_id"] == 3).toList();
    final fullMembers = onlineMembers.where((e) => e["role_id"] == 4).toList();
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final isOwner = currentChannel['owner_id'] == currentUser["id"];
    final currentUserWs = Provider.of<Workspaces>(context, listen: true).currentMember;
    final currentMember = Provider.of<Channels>(context, listen: true).currentMember;

    return Container(
      color: isDark ? Color(0xff2E2E2E) : Color(0xffFFFFFF),
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              //ownerMember
              ownerMember.length > 0 ? Container(
                width: deviceWidth,
                padding: EdgeInsets.only(left: 16, top: 10),
                margin: EdgeInsets.only(top: 8),
                child: Text("${S.current.owner} (${ownerMember.length})", style: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff828282), fontSize: 13, fontWeight: FontWeight.w700))
              ) : Container(),
              renderMember(ownerMember, currentUser, "", currentUserWs, isOwner, currentMember),

              //admin member
              adminMembers.length > 0 ? Container(
                width: deviceWidth,
                padding: EdgeInsets.only(left: 16),
                child: Text("${S.current.admins} (${adminMembers.length})", style: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff828282), fontSize: 13, fontWeight: FontWeight.w700))
              ) : Container(),
              renderMember(adminMembers, currentUser, "", currentUserWs, isOwner, currentMember),

              //editorMember
              editorMembers.length > 0 ? Container(
                width: deviceWidth,
                padding: EdgeInsets.only(left: 16),
                child: Text("${S.current.editors} (${editorMembers.length})", style: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff828282), fontSize: 13, fontWeight: FontWeight.w700))
              ) : Container(),
              renderMember(editorMembers, currentUser, "", currentUserWs, isOwner, currentMember),

              //members
              fullMembers.length > 0 ? Container(
                width: deviceWidth,
                padding: EdgeInsets.only(left: 16),
                child: Text("${S.current.members} (${fullMembers.length})", style: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff828282), fontSize: 13, fontWeight: FontWeight.w700))
              ) : Container(),
              renderMember(fullMembers, currentUser, "", currentUserWs, isOwner, currentMember),

              offlineMembers.length > 0 ? Container(
                width: deviceWidth,
                padding: EdgeInsets.only(left: 16),
                child: offlineMembers.length > 0 ? Text("${S.current.offline} (${offlineMembers.length})", style: TextStyle(color: isDark ? Colors.grey[400] : Color(0xff828282), fontSize: 13, fontWeight: FontWeight.w700)) : Container()
              ) : Container(),
              Opacity(
                opacity: 0.6,
                child: renderMember(offlineMembers, currentUser, "Offline", currentUserWs, isOwner, currentMember)
              ),

              appMembers.length > 0 ? Container(
                width: deviceWidth,
                padding: EdgeInsets.only(left: 16),
                child: appMembers.length > 0 ? Text("OFFLINE (${appMembers.length})", style: TextStyle(color: isDark ? Colors.grey[400] : Color(0xff828282), fontSize: 13, fontWeight: FontWeight.w700)) : Container()
              ) : Container(),
              Opacity(
                opacity: 0.6,
                child: renderMember(appMembers, currentUser, "Offline", currentUserWs, isOwner, currentMember)
              )
            ],
          ),
        ),
      ),
    );
  }
}



showUserDialog(context, id) {
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