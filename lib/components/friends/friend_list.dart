import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';

class FriendList extends StatefulWidget {
  final type;
  final channelId;

  FriendList({
    key,
    this.type, this.channelId
  }) : super(key: key);

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  final _controller = ScrollController();
  List friendList = [];
  String token = "";
  Map currentWorkspace = {};
  Map currentChannel = {};
  bool doneChecking = false;

  checkInvite(userId, workspaceId, channelId) async{
    bool check = false;
    var url;
    var resData;
    if (widget.type == "toWorkspace"){
      url = Utils.apiUrl + "/workspaces/$workspaceId/get_invite?token=$token";
      final response = await http.post(Uri.parse(url),headers: Utils.headers,
        body: json.encode({"user_id": userId})
      );
      resData = json.decode(response.body);
      doneChecking = true;
    } else {
      url = Utils.apiUrl + "/workspaces/$workspaceId/channels/$channelId/get_invite?token=$token";
      final response = await http.post(Uri.parse(url), headers: Utils.headers,
        body: json.encode({"user_id": userId})
      );
      resData = json.decode(response.body);
      doneChecking = true;
    }

    if (resData["success"] == true){
      check = resData["is_invited"];
    }
    return check ? "Invited" : "Invite";
  }
    @override
  void initState() {
    super.initState();

    this.setState(() {
      friendList = Provider.of<User>(context, listen: false).friendList;
      token = Provider.of<Auth>(context, listen: false).token;
      currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
      currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    });

    final workspaceMembers = Provider.of<Workspaces>(context, listen: false).members;

    List list = widget.type == 'toWorkspace' ? friendList : workspaceMembers;
    friendList = list;


    friendList.map((e) {
      int index = friendList.indexWhere((element) => element == e);
      var a = e;
      checkInvite(friendList[index]["id"], currentWorkspace["id"], currentChannel["id"]).then((ele) {
        if (this.mounted) setState(() {
          a["invite"] = ele;
        });
      });
      return a;
    }).toList();
  }
  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    final workspaceMembers = Provider.of<Workspaces>(context, listen: true).members;
    final channelMember = Provider.of<Channels>(context, listen: false).getChannelMember(widget.channelId);
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;

    _invite(user) async {
      String invite = user["email"] ?? user["phone_number"];
      if (widget.type == 'toWorkspace') {
        await Provider.of<Workspaces>(context, listen: false).inviteToWorkspace(token, currentWorkspace["id"], invite, Utils.checkedTypeEmpty(user["email"]) ? 1 : 2, user["id"]);
      } else {
        if (currentChannel["is_private"]) {
          Provider.of<Channels>(context, listen: false).inviteToChannel(token, currentWorkspace["id"], currentChannel["id"], invite, Utils.checkedTypeEmpty(user["email"]) ? 1 : 2, user["id"]);
        } else {
          Provider.of<Channels>(context, listen: false).inviteToPubChannel(token, currentWorkspace["id"], currentChannel["id"], user["id"]);
        }
      }
    }

    validate(id) {
      bool check = true;
      List list = widget.type == 'toWorkspace' ? workspaceMembers : channelMember;

      for (var member in list) {
        if (id == member["id"]) {
          check = false;
        }
      }
      return check;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      height: deviceHeight,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        itemCount: friendList.length,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CachedAvatar(
                      friendList[index]["avatar_url"],
                      height: 26, width: 26,
                      isRound: true,
                      name: friendList[index]["full_name"],
                    ),
                    SizedBox(width: 8,),
                    Text("${ Utils.getUserNickName(friendList[index]["id"]) ?? friendList[index]["full_name"]}", style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: friendList[index]["invite"] == "Invite" || isDark ? Colors.transparent : Color(0xffF3F3F3) ,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: friendList[index]["invite"] == "Invite" && !validate(friendList[index]["id"]) == false  ? isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E) : isDark ? Color(0xff5E5E5E) : Color(0xffB7B7B7))
                  ),
                  child: validate(friendList[index]["id"]) == false ? 
                    Text(S.current.acceptInvite, style: TextStyle(fontSize: 13, color: isDark ? Color(0xff5E5E5E) : Color(0xffB7B7B7)))
                    : friendList[index]["invite_${currentWorkspace["id"]}_${widget.type == "toChannel" ? currentChannel["id"] : ""}"] == null ? InkWell(
                        child: Text(S.current.invite, style: TextStyle(fontSize: 13, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E),),),
                        onTap: () {
                          _invite(friendList[index]);

                          this.setState(() {
                            friendList[index]["invite_${currentWorkspace["id"]}_${widget.type == "toChannel" ? currentChannel["id"] : ""}"] = true;
                          });
                        }
                    ) : Text(
                      S.current.invited, style: TextStyle(fontSize: 13, color: isDark ? Color(0xff5E5E5E) : Color(0xffB7B7B7))),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}