import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/call_center/call_manager.dart';
import 'package:workcake/components/friends/add_friend_username.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/main_menu/nearby_scan.dart';
import 'package:workcake/components/profile/user_profile.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/message.dart';

class Friends extends StatefulWidget {
  final icon;

  Friends({this.icon});
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  @override
  void initState() { 
    super.initState(); 
    final duration = const Duration(minutes: 1);
    Timer.periodic(duration, (Timer t) => {
      if (this.mounted) {
        setState((){})
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final friendList = Provider.of<User>(context, listen: true).friendList;
    final pendingList = Provider.of<User>(context, listen: true).pendingList;
    final sendingList = Provider.of<User>(context, listen: true).sendingList;
    final requestList = [...pendingList, ...sendingList];
    final onlineUsers = friendList.where((e) => e["is_online"] == true).toList();
    final offlineUsers = friendList.where((e) => e["is_online"] == false).toList();

    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: Column(
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
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: InkWell(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.arrow_back, size: 20)
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        child: Text(
                          S.current.friends,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )
                        ),
                      ),
                      Container(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: isDark ? Color(0xff2E2E2E) : Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        (requestList.length > 0) ? Row(children: [Container(margin: EdgeInsets.only(top: 16, left: 16, bottom: 8), child: Text("${S.current.pendingRequest} (${requestList.length})", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Color(0xffA6A6A6) : Color(0xff3D3D3D))))]) : Container(),
                        ListFriends(friendList: requestList, auth: auth, widget: widget, isRequest: true),
                        onlineUsers.length > 0 ? Container(margin: EdgeInsets.only(bottom: 8, top: 16, left: 16), child: Row(children: [Text("${S.current.online} (${onlineUsers.length})", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Color(0xffA6A6A6) : Color(0xff3D3D3D)))])) : Container(),
                        ListFriends(friendList: onlineUsers, auth: auth, widget: widget, isRequest: false),
                        offlineUsers.length > 0 ? Container(margin: EdgeInsets.only(bottom: 5, top: 16, left: 16), child: Row(children: [Text("${S.current.offline} (${offlineUsers.length})", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Color(0xffA6A6A6) : Color(0xff3D3D3D)))])) : Container(),
                        Opacity(opacity: 0.5, child: ListFriends(friendList: offlineUsers, auth: auth, widget: widget, isRequest: false),)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

showAddFriendsView(context) {
  final auth = Provider.of<Auth>(context, listen: false);
  final isDark = auth.theme == ThemeType.DARK;
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true, 
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    backgroundColor: Color(0xFF2e3235),
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height *.83,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
          color: isDark ? Color(0xff3d3d3d) : Colors.white
        ),
        child: DefaultTabController(
          length: 2,
          child: Container(
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, top: 16, bottom: 16),
                  child: Text(
                    S.current.addYourFriendPancake,
                    style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0XFF3D3D3D), fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      height: 48,
                      width: MediaQuery.of(context).size.width * .7,
                      constraints: BoxConstraints(minWidth: 200),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xff4C4C4C) : Color(0xffF8F8F8),
                        border: isDark ? null : Border(
                          top: BorderSide(color: Color(0xffC9C9C9)),
                          bottom: BorderSide(color: Color(0xffC9C9C9)),
                        )
                      ),
                      child: Container(
                        child: TabBar(
                          padding: EdgeInsets.all(0),
                          labelColor: isDark ? Color(0xffFAAD14) : Color(0xff1890FF),
                          labelStyle: TextStyle(fontWeight: FontWeight.w600),
                          unselectedLabelColor: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D),
                          indicatorWeight: 1,
                          indicatorColor: isDark ? Color(0xffFAAD14) : Color(0xff1890FF),
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: [
                            Container(child: Tab(text: 'Username'), width: 100),
                            Container(child: Tab(text: S.current.nearbyScan), width: 100),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xff4C4C4C) : Color(0xffF8F8F8),
                          border: isDark ? null : Border(
                            top: BorderSide(color: Color(0xffC9C9C9)),
                            bottom: BorderSide(color: Color(0xffC9C9C9)),
                          )
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      AddFriendUsername(),
                      NearbyScan(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      );
    }
  );
}


class ListFriends extends StatelessWidget {
  const ListFriends({
    Key? key,
    @required this.friendList,
    @required this.auth,
    @required this.widget,
    this.isRequest
  }) : super(key: key);

  final friendList;
  final auth;
  final widget;
  final isRequest;

  //  goDirectMessage(user, context) {
  //   final currentUser = Provider.of<User>(context, listen: false).currentUser;
  //   final token = Provider.of<Auth>(context, listen: false).token;
  //   Map newUser = Map.from(user);
  //   newUser["conversation_id"] = "";
  //   newUser["user_id"] = newUser["id"];
  //   Map newCurrentUser = Map.from(currentUser);
  //   newCurrentUser["conversation_id"] = "";
  //   newCurrentUser["user_id"] = newCurrentUser["id"];

  //     List users = [newUser, newCurrentUser];
  //     DirectModel directMessage =
  //       Provider.of<DirectMessage>(context, listen: false).findConversationFromListUserIds([newCurrentUser["user_id"], newUser["user_id"]]) ??
  //       DirectModel("",users,"",true, 0, {}, false, 0, {}, "", null);
  //     Provider.of<DirectMessage>(context, listen: false).setSelectedDM(directMessage, token);
  //     Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
  //       builder: (context) {
  //         return Message(
  //           dataDirectMessage: directMessage,
  //           id: directMessage.id,
  //           name: "",
  //           avatarUrl: "",
  //           isNavigator: true,
  //         );
  //       },
  //     ));
  // }

  goDirectMessage(user, context) async {
    PanelController panelController = PanelController();
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    var convId = MessageConversationServices.shaString([user["id"], currentUser["id"]]);
    bool hasConv = await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage( Provider.of<Auth>(context, listen: false).token, convId, forceLoad: true);
    DirectModel? directMessage;
    if (hasConv) directMessage = Provider.of<DirectMessage>(context, listen:false).getModelConversation(convId);
    else directMessage = DirectModel(
      convId, 
      [
        {"user_id": currentUser["id"],"full_name": currentUser["full_name"], "avatar_url": currentUser["avatar_url"]}, 
        {"user_id": user["id"], "avatar_url": user["avatar_url"],  "full_name": user["full_name"],}
      ], 
      "", 
      true, 
      0, 
      {}, 
      false,
      0, {}, user["full_name"], null,
      DateTime.now().toString()
    );
    if (directMessage == null) return;
    Provider.of<DirectMessage>(context, listen: false).setSelectedDM(directMessage, "");
    if (hasConv) {
      Provider.of<DirectMessage>(context, listen: false).resetOneConversation(directMessage.id);
      await Provider.of<DirectMessage>(context, listen: false).getMessageFromHiveDown(directMessage.id, DateTime.now().microsecondsSinceEpoch, auth.token, auth.userId, isGetIsarBeforeCallApi: true, limit: 20);  
      Provider.of<DirectMessage>(context, listen: false).getMessageFromApiDown(directMessage.id, true, auth.token, auth.userId);      
    }
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (context) {
          return Message(
            dataDirectMessage: directMessage!,
            id: directMessage.id,
            name: "",
            avatarUrl: "",
            isNavigator: true,
            panelController: panelController
          );
        },
      ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context).theme == ThemeType.DARK;

    parseDatetime(time) {
      DateTime offlineTime = DateTime.parse(time).add(Duration(hours: 7));
      DateTime now = DateTime.now();
      final difference = now.difference(offlineTime).inMinutes;

      final hour = difference ~/ 60;
      final minutes = difference % 60;
      final day = hour ~/24;
      // final hourLeft = hour % 24;
      
      if (day > 0) {
        return '${S.current.active} ${day.toString().padLeft(2, "")} ${day > 1 ? S.current.days : S.current.day} ${S.current.ago}';
      } else if (hour > 0) {
        return '${S.current.active} ${hour.toString().padLeft(2, "")} ${hour > 1 ? S.current.hours : S.current.hour} ${S.current.ago}';
      } else {
        if (minutes <= 1) return "${S.current.months} ${S.current.ago}";
        else return '${S.current.active} ${minutes.toString().padLeft(2, "0")} ${S.current.minutesAgo}';
      }
    }

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: friendList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            showUserProfile(context, friendList[index]["id"]);
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: <Widget>[
                Container(
                  constraints: BoxConstraints(maxHeight: 42, maxWidth: 42),
                  child: Stack(
                    children: <Widget>[
                      CachedImage(
                        friendList[index]["avatar_url"],
                        radius: 21,
                        width: 42,
                        height: 42,
                        isAvatar: true,
                        name: friendList[index]["full_name"]
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(friendList[index]["full_name"], style: TextStyle(fontSize: 15, height: 1.5, color: isDark ? Colors.white :  Color(0xff3D3D3D), fontWeight: FontWeight.w500)),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                widget.icon ?? Container(),
                                Text(
                                  isRequest
                                    ? friendList[index]["is_pending"] ? S.current.incomingFriendRequest : S.current.outgoingFriendRequest
                                    : friendList[index]["is_online"] != true
                                      ? Utils.checkedTypeEmpty(friendList[index]["offline_at"])
                                        ? parseDatetime(friendList[index]["offline_at"])
                                        : ""
                                      : S.current.active,
                                  style: TextStyle(fontSize: 13, color: Color(0xffA6A6A6)),
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(
                          child: Row(
                            children: [
                              isRequest && !friendList[index]["is_pending"]
                                ? Container()
                                : InkWell(
                                  onTap: () async {
                                    if (isRequest) {
                                      await Provider.of<User>(context, listen: false).acceptRequest(auth.token, friendList[index]["id"]);
                                    }
                                    else {
                                      final currentUser = Provider.of<User>(context, listen: false).currentUser;
                                      Map newUser = Map.from(friendList[index]);
                                      Map newCurrentUser = Map.from(currentUser);
                                      newUser["user_id"] = newUser["id"];
                                      newCurrentUser["user_id"] = newCurrentUser["id"];
                                      List users = [newUser, newCurrentUser];
                                      DirectModel directMessage =
                                      Provider.of<DirectMessage>(context, listen: false).findConversationFromListUserIds([newCurrentUser["user_id"], newUser["user_id"]]) ??
                                      DirectModel("",users,"",true, 0, {}, false, 0, {}, "", null, DateTime.now().toString());
                                      await callManager.calling(context, friendList[index], directMessage.id);
                                    }
                                  },
                                  child: Container(
                                    // padding: EdgeInsets.all(10),
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isDark
                                        ? Color(0xff4C4C4C)
                                        : Color(0xffF3F3F3),
                                      borderRadius: BorderRadius.all(Radius.circular(100))
                                    ),
                                    child: Icon(
                                      isRequest ? PhosphorIcons.checkBold : PhosphorIcons.phoneCall,
                                      size: 16.5,
                                      color: isRequest ? Color(0xff27AE60) : isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E),
                                    ),
                                  ),
                                ),
                              SizedBox(width: 10),
                              InkWell(
                                onTap: () async {
                                  isRequest
                                    ? await Provider.of<User>(context, listen: false).removeRequest(auth.token, friendList[index]["id"])
                                    : goDirectMessage(friendList[index], context);
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Color(0xff4C4C4C)
                                        : Color(0xffF3F3F3),
                                    borderRadius: BorderRadius.all(Radius.circular(100))
                                  ),
                                  child: Icon(
                                    isRequest ? PhosphorIcons.xBold : PhosphorIcons.chatCircleDots,
                                    size: 16.5,
                                    color: isRequest ? Color(0xffEB5757) : isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}

showUserProfile(context, userId) async {
  final auth = Provider.of<Auth>(context, listen: false);
  await Provider.of<User>(context, listen: false).getUser(auth.token, userId);
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    builder: (BuildContext context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight * 0.95,
            child: UserProfile()
          );
        }
      );
    }
  );
}
