import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/create_direct_message.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/components/custom_search_bar.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import '../search_user.dart';

class DmMember extends StatefulWidget {
  DmMember({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _DmMember createState() => _DmMember();
}

class _DmMember extends State<DmMember> {
  TextEditingController editingController = TextEditingController();
  List membersFilter = [];
  FocusNode node = FocusNode();
  String searchValue = "";

  searchDirectMember(String query, members){
   setState(() {
     searchValue = query;
   });
  }
  


  @override
  Widget build(BuildContext context) {
    var _debounce;
    double deviceWidth = MediaQuery.of(context).size.width;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    DirectModel? directMessage = Provider.of<DirectMessage>(context, listen: true).getModelConversation(widget.id);
    if (directMessage == null) return Container();
    final members = directMessage.user;
    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff2E2E2E) : Colors.white,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Icon(PhosphorIcons.arrowLeft, size: 20,)
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Text(
                              "Members",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              )
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              showSearchBar(context, directMessage);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Icon(PhosphorIcons.userPlus, size: 20,)
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: 10),
                        width: deviceWidth - 32,
                        height: 50,
                        child: CustomSearchBar(
                          controller: editingController,
                          radius: 18,
                          focusNode: node,
                          placeholder: "Search member",
                          onChanged: (text) {
                            if (_debounce?.isActive ?? false) _debounce.cancel();
                            _debounce = Timer(const Duration(milliseconds: 500), () {
                              searchDirectMember(text, members);
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListDmMember(searchValue: searchValue, directMessage: directMessage)
              ),
            ],
          )
        ),
      ),
    );
  }
}

showSearchBar(context, conv) {
  if (conv.user.length < 3)
  return  Navigator.push(context, MaterialPageRoute(builder: (context) => 
    CreateDirectMessage(
      defaultList: conv.user.map((e) => Utils.mergeMaps([
        e, {"id": e["user_id"]}
      ])).toList(),
    )
  ));

  return showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    builder: (BuildContext context) {
      return SearchUser();
    }
  );
}

class ListDmMember extends StatefulWidget {
  ListDmMember({Key? key, this.searchValue, required this.directMessage}) : super(key: key);
  final String? searchValue;
  final DirectModel directMessage;

  @override
  _ListDmMember createState() => _ListDmMember();
}

class _ListDmMember extends State<ListDmMember> {
  @override
  Widget build(BuildContext context) {
    final onlineMembers = widget.directMessage.user.where((e) => 
      e["is_online"] == true && 
      (e["status"] == "in_conversation" || e["status"] == null) &&  
      Utils.unSignVietnamese(e["full_name"]).contains(Utils.unSignVietnamese(widget.searchValue ?? ""))
    ).toList();
    final offlineMembers = widget.directMessage.user.where((e) => 
      e["is_online"] != true && 
      (e["status"] == "in_conversation" || e["status"] == null) &&  
      Utils.unSignVietnamese(e["full_name"]).contains(Utils.unSignVietnamese(widget.searchValue ?? ""))
    ).toList();
    double deviceWidth = MediaQuery.of(context).size.width;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    String? roleCurrentUser = widget.directMessage.getRoleMember(currentUser["id"]);

    return Container(
      color: isDark ? Color(0xff2E2E2E) : Color(0xffFFFFFF),
      child: SingleChildScrollView(
          child: Container(
          child:Column(
            children: [
              Container(
                width: deviceWidth,
                padding: EdgeInsets.only(left: 16, top: 16),
                child: Text("ONLINE (${onlineMembers.length})", style: TextStyle(color: Color(0xff828282), fontSize: 13, fontWeight: FontWeight.w700, height: 1.67))
              ),
              Container(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: onlineMembers.length,
                  itemBuilder: (context, index) {
                    String? roleMember = widget.directMessage.getRoleMember(onlineMembers[index]["user_id"]);
                    Color? colorRole = widget.directMessage.getColorRoleMember(onlineMembers[index]["user_id"]);
                    return Container(
                      margin: EdgeInsets.only(left: 16, bottom: 2, top: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                child: Stack(
                                  children: [
                                    CachedAvatar(onlineMembers[index]["avatar_url"], height: 26, width: 26, isRound: true, name: onlineMembers[index]["full_name"]),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xff27AE60),
                                          borderRadius: BorderRadius.circular(5)
                                        ) ,
                                        width: 8,
                                        height: 8,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(width: 8,),
                              Text('${onlineMembers[index]["full_name"]}', style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 15, fontWeight: FontWeight.w500)),
                              SizedBox(width: 5),
                              roleMember == "admin" ? Container(
                                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: colorRole,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                child: Text("owner", style: TextStyle(color: Colors.white, fontSize: 11)),
                              ) : Container(),
                            ],
                          ),
                          (roleCurrentUser != "admin") ? Container()
                            : Container(
                              margin: EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) {
                                      return CustomDialogNew(
                                        title: "Kick Member", 
                                        content: "Are you sure want to kick this member?",
                                        confirmText: "Kick",
                                        onConfirmClick: () async {
                                          if (await Provider.of<DirectMessage>(context, listen: false).leaveConversation(widget.directMessage.id, Provider.of<Auth>(context, listen: false).token, currentUser["id"], targetMemberId: onlineMembers[index]["user_id"])) {
                                          Navigator.pop(context);
                                          }
                                        },
                                        quickCancelButton: true,
                                      );
                                    }
                                );
                                },
                                child: Icon(PhosphorIcons.x, size: 14,),
                              ),
                            )
                        ],
                      )
                    );
                  },
                )
              ),
              SizedBox(height: 16),
              Container(
                width: deviceWidth,
                padding: EdgeInsets.only(left: 16),
                child: Text("OFFLINE (${offlineMembers.length})", style: TextStyle(color: Color(0xff828282), fontSize: 13, fontWeight: FontWeight.w700, height: 1.67))
              ),
              Opacity(
                opacity: 0.7,
                child: Container(
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: offlineMembers.length,
                    itemBuilder: (context, index) {
                      String? roleMember = widget.directMessage.getRoleMember(offlineMembers[index]["user_id"]);
                      Color? colorRole = widget.directMessage.getColorRoleMember(offlineMembers[index]["user_id"]);
                      return Container(
                        margin: EdgeInsets.only(left: 16, bottom: 2, top: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Stack(
                                    children: [
                                      CachedAvatar(offlineMembers[index]["avatar_url"], height: 26, width: 26, isRound: true, name: offlineMembers[index]["full_name"]),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xffA6A6A6),
                                            borderRadius: BorderRadius.circular(5)
                                          ) ,
                                          width: 8,
                                          height: 8,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8,),
                                Text('${offlineMembers[index]["full_name"]}', style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 15, fontWeight: FontWeight.w400)),
                                roleMember == "admin" ? Container(
                                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: colorRole ?? Colors.red,
                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                  ),
                                  child: Text("owner", style: TextStyle(color: Colors.white, fontSize: 11)),
                                ) : Container(),
                              ],
                            ),
                            (roleCurrentUser != "admin") ? Container()
                              : Container(
                                margin: EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return CustomDialogNew(
                                          title: "Kick Member", 
                                          content: "Are you sure want to kick this member?",
                                          confirmText: "Kick",
                                          onConfirmClick: () async {
                                             if (await Provider.of<DirectMessage>(context, listen: false).leaveConversation(widget.directMessage.id, Provider.of<Auth>(context, listen: false).token, currentUser["id"], targetMemberId: offlineMembers[index]["user_id"])) {
                                              Navigator.pop(context);
                                             }
                                          },
                                          quickCancelButton: true,
                                        );
                                      }
                                    );
                                  },
                                  child: Icon(PhosphorIcons.x, size: 14,),
                                ),
                              )
                          ],
                        )
                      );
                    },
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
