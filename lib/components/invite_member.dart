import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/custom_search_bar.dart';
import 'package:workcake/components/friends/friend_list.dart';
import 'package:workcake/models/models.dart';

import '../common/validators.dart';
import '../generated/l10n.dart';

class InviteMember extends StatefulWidget {
  final type;
  final channelId;

  InviteMember({this.type, this.channelId});
  @override
  _InviteMemberState createState() => _InviteMemberState();
}

extension ListX on List {
  List filter(String text) {
    final _text = Utils.unSignVietnamese(text);
    return this.where((element) => (Utils.unSignVietnamese(element["full_name"])?? "").contains(_text) 
                                  || (element["email"] ?? "").contains(_text) 
                                  || (element["phone_number"] ?? "").contains(_text))
                                  .toList();
  }
}

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = Set();
    var list = inplace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

class _InviteMemberState extends State<InviteMember> {
  final TextEditingController _invitePeopleController = TextEditingController();
  var keyCode;
  List members = [];
  List friends = [];
  List workspaceMembers = [];
  String textSearch = "";
  bool sentToAnonymous = false;
  Map currentWorkspace = {};
  bool validEmailOrNumberPhone = true;
  String messageInvite = "";
  @override
  void initState() {
    super.initState();
    renderKeyCodeInvite();
    getMembersWorkspaceAndFriends();
  }

  getMembersWorkspaceAndFriends() {
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    List membersAllWorkspace = Provider.of<Workspaces>(context, listen: false).listWorkspaceMembers;
    friends = Provider.of<User>(context, listen: false).friendList;

    workspaceMembers = membersAllWorkspace.where((member) => member["workspace_id"] == currentWorkspace["id"] && member["id"] != currentUser["id"]).toList();
  }

  renderKeyCodeInvite() {
    var channelGeneral;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final listChannelGeneral = Provider.of<Channels>(context, listen: false).data.where((e) => e["is_general"] == true).toList();
    final indexChannel = listChannelGeneral.indexWhere((e) => e['workspace_id'] == currentWorkspace["id"]);
    var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    if (indexChannel != -1) {
      channelGeneral = listChannelGeneral[indexChannel];
    }
    keyCode = (widget.type == "toWorkspace" && channelGeneral != null) ? "${getRandomString(4)}-${currentWorkspace["id"]}-${channelGeneral["id"]}" : "${getRandomString(4)}-${currentWorkspace["id"]}-${currentChannel["id"]}" ;
  }

  onSearchMemberToInvite(token, text) async {
    textSearch = text;
    sentToAnonymous = false;
    switch (widget.type) {
      case "toWorkspace":
        setState(() => members = friends.filter(text).unique((x) => x["id"]));
        break;
      case "toChannel":
        setState(() => members = (workspaceMembers).filter(text).unique((x) => x["id"]));
        break;
      default:
    }
  }
  validate(id) {
    final workspaceMembers = Provider.of<Workspaces>(context, listen: true).members;
    final channelMember = Provider.of<Channels>(context, listen: false).getChannelMember(widget.channelId);
    bool check = true;
    List list = widget.type == 'toWorkspace' ? workspaceMembers : channelMember;

    for (var member in list) {
      if (id == member["id"]) {
        check = false;
      }
    }
    return check;
  }

  _invitePeople(token, workspaceId, channelId, text) async {
    final validEmail = Validators.validateEmail(text);
    final validPhoneNumber = Validators.validatePhoneNumber(text);
    if(text==""){
      return setState(() {
        validEmailOrNumberPhone = false;
        messageInvite = S.current.inputCannotEmpty;
      });
    }
    if (validEmail || validPhoneNumber) {
      setState(() {
        validEmailOrNumberPhone = true;
      });
      if (widget.type == 'toWorkspace') {
        messageInvite = await Provider.of<Workspaces>(context, listen: false).inviteToWorkspace(token, workspaceId, text, validEmail ? 1 : 2, null);
      } else {
        messageInvite = await Provider.of<Channels>(context, listen: false).inviteToChannel(token, workspaceId, channelId, text, validEmail ? 1 : 2, null);
      }
      setState(() {});
    } else {
      setState(() {
        validEmailOrNumberPhone = false;
        messageInvite = "Invite Failure";
      });
    }
  }
  

  _invite(token, workspaceId, channelId , user) async {
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    String invite = user["email"] ?? user["phone_number"];
    if (widget.type == 'toWorkspace') {
      Provider.of<Workspaces>(context, listen: false).inviteToWorkspace(token, workspaceId, invite, Utils.checkedTypeEmpty(user["email"]) ? 1 : 2, user["id"]);
    } else {
      if (currentChannel["is_private"]) {
        Provider.of<Channels>(context, listen: false).inviteToChannel(token, workspaceId, channelId,invite, Utils.checkedTypeEmpty(user["email"]) ? 1 : 2, user["id"]);
      } else {
        Provider.of<Channels>(context, listen: false).inviteToPubChannel(token, currentWorkspace["id"], currentChannel["id"], user["id"]);
      }
      
    }
  }

  getListInvitation(currentWorkspace) {
    var key = "${currentWorkspace['id']}";
    var box = Hive.box('invitationHistory');
    List invitationHistory = box.get(key) ?? [];
    List list = [];

    final members = Provider.of<Workspaces>(context, listen: true).members;

    for (var i = 0; i < invitationHistory.length; i++) {
      if (DateTime.now().isBefore(invitationHistory[i]['date'].add(Duration(days: 29)))) {
        final index = members.indexWhere((e) => e["email"] == invitationHistory[i]['email']);
        bool isAccepted = index != -1;
        invitationHistory[i]['isAccepted'] = isAccepted;
        list.add(invitationHistory[i]);
      }
    }
    
    box.put(key, list);

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final isDark = auth.theme == ThemeType.DARK;
    var _debounce;

    List invitationHistory = getListInvitation(currentWorkspace);
    
    return Scaffold(
      body: Container(
        color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff2E2E2E) : Colors.white,
                ),
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                      ),
                    ),
                    Text(S.current.inviteMember, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 17, fontWeight: FontWeight.w700),),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Text(S.current.done, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF)),)
                      ),
                    )
                  ],
                ),
              ),
              Container(
                color: isDark ? Color(0xff2E2E2E) : Colors.white,
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: CustomSearchBar(
                  placeholder: widget.type == "toWorkspace" ? "Type an email or phone number to invite" : S.current.search,
                  controller: _invitePeopleController,
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce.cancel();
                      _debounce = Timer(const Duration(milliseconds: 500), () {
                        if (value != "") {
                          onSearchMemberToInvite(auth.token, value);
                        } else {
                          setState(() => {members = [], textSearch = ""});
                        }
                      }
                    );
                  },
                ),
              ),
              if (invitationHistory.length > 0 && widget.type == "toWorkspace") Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 4, left: 24, bottom: 4),
                    child: Text(
                      "Invitation history:",
                      style: TextStyle(color: isDark ? Color(0xffC9C9C9): Color(0xff828282), fontSize: 15, fontWeight: FontWeight.w500, fontFamily: "Roboto")
                    )
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: 150,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 24),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: invitationHistory.length,
                      itemBuilder: (context, index){
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                invitationHistory[index]["email"],
                                style: TextStyle(color: isDark ? Color(0xffC9C9C9): Color(0xff828282), fontSize: 13.5, fontWeight: FontWeight.w400, fontFamily: "Roboto")
                              ),
                              Text(
                                invitationHistory[index]['isAccepted'] ? "Acccepted  " : "Sent  ",
                                style: TextStyle(color: isDark ? Color(0xffC9C9C9): Color(0xff828282), fontSize: 13.5, fontWeight: FontWeight.w400, fontFamily: "Roboto")
                              )
                            ]
                          )
                        );
                      }
                    )
                  )
                ]
              ),
              Container(
                height: 1,
                color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: isDark ? Color(0xff2E2E2E) : Colors.white,
                child: Row(
                  children: [
                     Text(
                      "${S.current.codeInvite}:",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontStyle: FontStyle.italic)
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(new ClipboardData(text: keyCode));
                        Fluttertoast.showToast(
                          msg: "Copied to clipboard",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          backgroundColor: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D),
                          textColor: isDark ? Color(0xff2E2E2E) : Colors.white,
                          fontSize: 13
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              keyCode,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xff27AE60),
                                fontSize: 14.5,
                              )
                            ),
                          ),
                          Icon(PhosphorIcons.copy, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), size: 16),
                        ],
                      )
                    )
                  ],
                ),
              ),
              members.length > 0 || (textSearch != "" && widget.type == "toChannel") ? Expanded(
                child: Container(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CachedImage(
                          members[index]["avatar_url"],
                          width: 35,
                          height: 35,
                          isAvatar: true,
                          radius: 20,
                          name: members[index]["full_name"]
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${Utils.getUserNickName(members[index]["id"]) ?? members[index]["full_name"]}", style: TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: isDark ? Color(0xffffffff):Color(0xff3D3D3D)),),
                            SizedBox(height: 2,),
                            Text("${members[index]["email"]}", style: TextStyle(fontSize: 12,fontWeight: FontWeight.w400,color: Color(0xffA6A6A6)),),
                          ],
                        ),
                        trailing: Container(
                          height: 34,
                          width: 80,
                          child: validate(members[index]["id"]) == false ? 
                            Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
                              child: Center(child: Text(S.current.acceptInvite, style: TextStyle(fontSize: 13, color: Colors.grey)),)
                              )
                            : members[index]["invite_${currentWorkspace["id"]}_${widget.type == "toChannel" ? currentChannel["id"] : ""}"] == null ? TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(isDark ? Colors.transparent : Color(0xffEDEDED)),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    side: BorderSide(color: isDark ? Color(0xffEAE8E8) : Color(0xff5E5E5E)),
                                  )),
                                ),
                                child: Text(S.current.invite, style: TextStyle(fontSize: 13, color: isDark ? Color(0xffEAE8E8) : Color(0xff5E5E5E))),
                                onPressed: () {
                                  _invite(auth.token, currentWorkspace["id"], currentChannel["id"], members[index]);
                                  this.setState(() {
                                   members[index]["invite_${currentWorkspace["id"]}_${widget.type == "toChannel" ? currentChannel["id"] : ""}"] = true;
                                  }); 
                                }
                            ) : Center(child: Text(S.current.sent, style: TextStyle(fontSize: 13, color: Colors.grey))),
                        ),
                      );
                    }
                  ),
                ),
              ) : widget.type == "toWorkspace" && textSearch != "" ? Container(
                color:  isDark ? Color(0xff2E2E2E) : Colors.white,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(textSearch),
                      sentToAnonymous ? Text("Sent", style: TextStyle(fontSize: 13, color: Colors.grey)) : Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color:  isDark ? Colors.transparent : Color(0xffF3F3F3) ,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color:isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E))
                        ),
                        child: InkWell(
                          onTap: (){
                            _invitePeople(auth.token, currentWorkspace["id"], currentChannel["id"], textSearch);
                            setState(() {
                              sentToAnonymous = true;
                            });
                          },
                          child: Text("Invite", style: TextStyle(color: Colors.white))
                        ),
                      ),
                    ],
                  ),
                ),
              ) :
                Expanded(
                child: Container(
                  color: isDark ? Color(0xff2E2E2E) : Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(padding: EdgeInsets.only(left: 16, top: 12), child: Text(S.current.yourFriend, style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 15))),
                      Expanded(
                        child: FriendList(type: widget.type,channelId: widget.channelId,)
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}