import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/call_center/call_manager.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/splash_screen.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/message.dart';
import 'dart:io' show Platform;

import '../../generated/l10n.dart';

class UserProfile extends StatefulWidget {

  UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  PanelController panelController = PanelController();
  void initState() {
    super.initState();
  }

  getFieldOfListUser(List data, String field) {
    var result = "";
    for (var i = 0; i < data.length; i++) {
      if (i != 0) result += ", ";
      result += data[i][field];
    }
    if (result.length > 20) {
      return result.substring(result.length - 20) + "...";
    }
    return result;
  }


  goDirectMessage(user) async {
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    final auth = Provider.of<Auth>(context, listen: false);
    var convId = MessageConversationServices.shaString([user["id"], currentUser["id"]]);
    bool hasConv = await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage( Provider.of<Auth>(context, listen: false).token, convId, forceLoad: true);
    var directMessage;
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
    Provider.of<DirectMessage>(context, listen: false).setSelectedDM(directMessage, "");
    if (hasConv) {
      Provider.of<DirectMessage>(context, listen: false).resetOneConversation(directMessage.id);
      await Provider.of<DirectMessage>(context, listen: false).getMessageFromHiveDown(directMessage.id, DateTime.now().microsecondsSinceEpoch, auth.token, auth.userId, isGetIsarBeforeCallApi: true, limit: 20);  
      Provider.of<DirectMessage>(context, listen: false).getMessageFromApiDown(directMessage.id, true, auth.token, auth.userId);      
    }
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
      builder: (context) {
        return Message(
          dataDirectMessage: directMessage,
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
    final otherUser = Provider.of<User>(context, listen: true).otherUser;
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    String dateString = Utils.checkedTypeEmpty(otherUser) && Utils.checkedTypeEmpty(otherUser!["date_of_birth"])
        ? DateFormatter().renderTime(DateTime.parse(otherUser["date_of_birth"]), type: "dd-MM-yyyy")
        : "";

    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, BoxConstraints constraints) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? Color(0xff2E2E2E) : Color(0xffFFFFFF)
            ),
            height: constraints.maxHeight,
            child: Column (
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff2E2E2E) : Color(0xffFFFFFF),
                  ),
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 18),
                          child: Icon(PhosphorIcons.arrowLeft, size: 20)
                        )
                      ),
                      Text(S.current.userProfile, style: TextStyle(color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight, fontSize: 18, fontWeight: FontWeight.w700)),
                      SizedBox(width: 38),
                  ]),
                ),
                Divider(
                  thickness: 1,
                ),
                otherUser != null ? Container(
                  color: isDark ? Color(0xff2E2E2E) : Color(0xffFFFFFF),
                  height: deviceHeight*.85,
                  child: Column(
                    children: [
                      Container(
                        color: isDark ? Color(0xff2E2E2E) : Color(0xffFFFFFF),
                        width: deviceWidth,
                        padding: EdgeInsets.only(top: 20, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //////////// Avatar///////////
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child:  CachedAvatar(
                                otherUser["avatar_url"],
                                height: 160, width: 160,
                                isRound: true,
                                name: otherUser["full_name"]
                              )
                            ),
                            //////////// Avatar///////////
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 10, height: 10,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        color: otherUser["is_online"] ? Colors.green : Colors.transparent
                                      ),
                                  ),
                                  SizedBox(width: 12),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: Utils.checkedTypeEmpty(otherUser["username"]) ? otherUser["username"] : otherUser["full_name"],
                                          style: TextStyle(
                                            color: isDark ? Colors.grey[200] : Colors.grey[800], 
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 18
                                          )
                                        ),
                                        TextSpan(
                                          text: "#${otherUser["custom_id"]}",
                                          style: TextStyle(fontSize: 15, color: isDark ? Color(0xffC9C9C9) : Color(0xff000000).withOpacity(0.65)),
                                        )
                                      ]
                                    ),
                                  ),
                                ],
                              )
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10, bottom: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),
                                      color: isDark ? Color(0xff707070) : Color(0xfff3f3f3),
                                    ),
                                    width: deviceWidth/5,
                                    child: TextButton(
                                      onPressed: (){
                                        goDirectMessage(otherUser);
                                      }, 
                                      child: Icon(PhosphorIcons.chat, color: isDark ? Palette.calendulaGold : Palette.dayBlue, size: 23) 
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),
                                      color: isDark ? Color(0xff707070) : Color(0xfff3f3f3),
                                    ),
                                    width: deviceWidth/5,
                                    child: TextButton(
                                      onPressed: (){}, 
                                      child: Icon(PhosphorIcons.phoneCall, color: isDark ? Palette.calendulaGold : Palette.dayBlue, size: 23) 
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),
                                      color: isDark ? Color(0xff707070) : Color(0xfff3f3f3),
                                    ),
                                    width: deviceWidth/5,
                                    child: TextButton(
                                      onPressed: (){
                                        final currentUser = Provider.of<User>(context, listen: false).currentUser;
                                        var convId = otherUser["conversation_id"];
                                        if (convId == null){
                                          convId = MessageConversationServices.shaString([currentUser["id"], otherUser["user_id"] ?? otherUser["id"]]);
                                        }
                                        callManager.calling(context, otherUser, convId);
                                      }, 
                                      child: Icon(PhosphorIcons.videoCamera, color: isDark ?Palette.calendulaGold : Palette.dayBlue, size: 23)
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),
                                      color: isDark ? Color(0xff707070) : Color(0xfff3f3f3),
                                    ),
                                    width: deviceWidth/5,
                                    child: FriendStatus(deviceWidth: deviceWidth, isDark: isDark)
                                  )
                                ]
                              ),
                            )
                          ]
                        ),
                      ),
                      Container(
                        width: constraints.maxWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(width: 0.2, color: isDark ? Colors.transparent : Color(0xFFDBDBDB)),
                              bottom: BorderSide(width: 0.2, color: isDark ? Colors.transparent : Color(0xFFDBDBDB)),
                            ),
                            color: isDark ? Color(0xff3D3D3D) : Color(0xffFAFAFA) 
                          ),
                          child: Column(children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              height: 52,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(width: 0.2, color: Colors.grey))
                                ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.user, size: 18),
                                      SizedBox(width: 8),
                                      Text(S.current.fullName, style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontWeight: FontWeight.w500, fontSize: 14)),
                                    ],
                                  ),
                                  Container(
                                    child: Text( '${otherUser["full_name"]}', style: TextStyle(color: Colors.grey, fontSize: 14) )
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              height: 52,
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(width: 0.2, color: Colors.grey)
                                  )
                                ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.envelopeSimple, size: 18),
                                      SizedBox(width: 8),
                                      Text("Email", style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontWeight: FontWeight.w500, fontSize: 14)),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(new ClipboardData(text: otherUser["email"] ?? ""));
                                      Fluttertoast.showToast(
                                        msg: "copied",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Utils.checkedTypeEmpty(otherUser["email"]) ? Icon(PhosphorIcons.copySimple, size: 18, color: Palette.greyColor) : SizedBox(),
                                        SizedBox(width: 6),
                                        Container(
                                          child: Text('${otherUser["email"]}', style: TextStyle(color: Colors.grey, fontSize: 14))
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              height: 52,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(width: 0.2, color: Colors.grey)
                                )
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.phoneCall, size: 18),
                                      SizedBox(width: 8),
                                      Text(S.current.phoneNumber, style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontWeight: FontWeight.w500, fontSize: 14 )),
                                    ],
                                  ),
                                  InkWell(
                                     onTap: () {
                                      Clipboard.setData(new ClipboardData(text: otherUser["phone_number"] ?? ""));
                                      Fluttertoast.showToast(
                                        msg: "copied",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.TOP,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Utils.checkedTypeEmpty(otherUser["phone_number"]) ? Icon(PhosphorIcons.copySimple, size: 18, color: Palette.greyColor) : SizedBox(),
                                        SizedBox(width: 6),
                                        Container(
                                          child: Text(otherUser["phone_number"] != null ? '${otherUser["phone_number"]}' : "",
                                          style: TextStyle( color: Palette.greyColor, fontSize: 14) )
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              height: 52,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(width: 0.2, color: Colors.grey)
                                )
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.genderIntersex, size: 18),
                                      SizedBox(width: 8),
                                      Text( S.current.gender, style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontWeight: FontWeight.w500, fontSize: 14 ) ),
                                    ],
                                  ),
                                  Container(
                                    child: Text(otherUser["gender"] ?? "", style: TextStyle(color: Colors.grey, fontSize: 14)
                                  )),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, right: 20),
                              height: 52,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Icon(PhosphorIcons.cake, size: 18),
                                      SizedBox(width: 8),
                                      Text( S.current.dateOfBirth, style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontWeight: FontWeight.w500, fontSize: 14 ) ),
                                    ],
                                  ),
                                  Container(
                                    child: Text( dateString, style: TextStyle(color: Colors.grey, fontSize: 14) )
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        )
                      )
                    ]
                  ) 
                ) : SplashScreen()
              ],
            ),
          );
        }
      ),
    );
  }
}

class FriendStatus extends StatelessWidget {
  const FriendStatus({
    Key? key,
    @required this.deviceWidth,
    @required this.isDark,
  }) : super(key: key);

  final deviceWidth;
  final isDark;

  @override
  Widget build(BuildContext context) {
    final otherUser = Provider.of<User>(context, listen: true).otherUser;
    final isSended = otherUser!["is_sended"] == 1 ? true : false;
    final isRequested = otherUser["is_requested"] == 1 ? true : false;
    final token = Provider.of<Auth>(context, listen: true).token;

    return Container(
      child: TextButton(
        onPressed: () async {
          if (isSended == true && isRequested == true) {
            await showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text("Block", style: TextStyle(color: Colors.red[400])),
                  onPressed: () {

                  }
                ),
                CupertinoActionSheetAction(
                  child: Text("Remove Friend"),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Container(
                        child: AlertDialog(
                          insetPadding: EdgeInsets.all(20),
                          contentPadding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          backgroundColor: isDark ? Color(0xFF3D3D3D) : Color(0xffFFFFFF),
                          content: Container(
                            height: 195,
                            width: (Platform.isAndroid || Platform.isIOS) ? deviceWidth : 300,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 0),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(top: 16, bottom: 16, left: 24),
                                        margin: EdgeInsets.only(bottom: 20),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Unfriend",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16, color: isDark ? Colors.white : Colors.grey[700]
                                              )
                                            ),
                                            Divider(thickness: 1, color: isDark ? Colors.transparent : Color(0xFF5e5e5e)),
                                            Container()
                                          ]
                                        ),
                                        decoration:  BoxDecoration(
                                          color: isDark ? Color(0xff5E5E5E) : Color(0xffFAFAFA),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            topRight: Radius.circular(5),
                                          ),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                                  child: Text("Are you sure you want to unfriend?")
                                ),
                                Container(
                                  height: 1,
                                  margin: EdgeInsets.only(top: 16),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  child: Divider(thickness: 1)),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: (){
                                            Navigator.of(context, rootNavigator: true).pop("Discard");
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(vertical: 10.5),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Color(0xffEB5757),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text("Cancel", style: TextStyle(fontSize: 14, color: Color(0xffEB5757),)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async{
                                            await Provider.of<User>(context, listen: false).removeFriendRequest(otherUser["id"], token);
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(vertical: 10.5),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.blue,
                                                width: 1,
                                              ),
                                              color: Colors.blue,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text("Unfriend", style: TextStyle(fontSize: 14, color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                            ),
                          ),
                        ),
                      )
                    );
                  } 
                )
              ])
            );
          } else if (isRequested) {
            await showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) =>  CupertinoActionSheet(
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text("Confirm"),
                  onPressed: () async{
                    await Provider.of<User>(context, listen: false).addFriendRequest(otherUser["id"], token);
                    Navigator.pop(context);
                  }
                ),
                CupertinoActionSheetAction(
                  child: Text("Reject", style: TextStyle(color: Colors.red[400])),
                  onPressed: () async {
                    await Provider.of<User>(context, listen: false).removeFriendRequest(otherUser["id"], token);
                    Navigator.pop(context);
                  }
                )
              ])
            );
          } else if (isSended) {
            await Provider.of<User>(context, listen: false).removeFriendRequest(otherUser["id"], token);
          } else {
            await Provider.of<User>(context, listen: false).addFriendRequest(otherUser["id"], token);
          }
        }, 
        child: Column(
          children: <Widget>[
            isRequested && isSended
            ? SvgPicture.asset("assets/icons/user_check.svg", color: isDark ? Palette.calendulaGold : Palette.dayBlue, width: 24)
            : Icon(
              (isRequested == true || isSended == true) ? Icons.replay : PhosphorIcons.userPlus, 
              color: isDark ? Palette.calendulaGold : Palette.dayBlue, size: 23
            ), 
          ]
        )
      ),
    );
  }
}
