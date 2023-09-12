import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/splash_screen.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';

class UserProfileDesktop extends StatefulWidget {
  final userId;

  UserProfileDesktop({Key? key, this.userId}) : super(key: key);

  @override
  _UserProfileDesktopState createState() => _UserProfileDesktopState();
}

class _UserProfileDesktopState extends State<UserProfileDesktop> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  void initState() {
    final auth = Provider.of<Auth>(context, listen: false);

    super.initState();
    Timer.run(() async {
      await Provider.of<User>(context, listen: false).getUser(auth.token, widget.userId);
    });
  }

  createDirectMessage(user) async {
    final auth = Provider.of<Auth>(context, listen: false);
    final token = auth.token;
    final channel = auth.channel;
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    List listUserDM = [user, currentUser];
    var listUserId = listUserDM.map((e) =>  e["id"]).toList();
    LazyBox box = Hive.lazyBox("pairKey");
    final url = "${Utils.apiUrl}direct_messages/create?token=$token&device_id=${await box.get("deviceId")}";

    try {
      var response = await Dio().post(url, data: {
        "data":await Utils.encryptServer({"users": listUserId, "name": ""})
      });
      var res = response.data;

      if (res["success"] == true) {
        await Provider.of<DirectMessage>(context, listen: false).getDataDirectMessage(token, auth.userId);

        if (res["conversation_id"] != null ) {
          String directMessageId = res["conversation_id"];
          Map newUser = Map.from(user);
          newUser["conversation_id"] = directMessageId;
          Map newCurrentUser = Map.from(currentUser);
          newCurrentUser["conversation_id"] = directMessageId;
          newCurrentUser["user_id"] = newCurrentUser["id"];
          newCurrentUser["is_online"] = true;

          DirectModel directMessage  = DirectModel(
            directMessageId,
            [newUser, newCurrentUser],
            "",
            true, 0, {}, false, 0, {}, newUser["full_name"], null, DateTime.now().toString()
          );

          Provider.of<Workspaces>(context, listen: false).tab = 0;
          await Provider.of<DirectMessage>(context, listen: false).setSelectedDM(directMessage, auth.token);
          await Provider.of<DirectMessage>(context, listen: false).getMessageFromApiDown(directMessageId, true, auth.token, auth.userId);
          await channel.push(event: "join_direct", payload: {"direct_id": directMessageId});
          updateBadge();
        }
      }
      else throw HttpException(res["message"] ?? res["error_code"]);
    } catch (e) {
      print("e $e");
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  goDirectMessage(user) async {

    print("________________");
    var currentUser = Provider.of<User>(context, listen: false).currentUser;
    Provider.of<Workspaces>(context, listen: false).tab = 0;
    var convId = MessageConversationServices.shaString([user["id"], currentUser["id"]]);
    bool hasConv  =  await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage( Provider.of<Auth>(context, listen: false).token, convId);
    var dm;
    if (hasConv) dm = Provider.of<DirectMessage>(context, listen:false).getModelConversation(convId);
    else dm = DirectModel(
      "", 
      [
        {"user_id": currentUser["id"],"full_name": currentUser["full_name"], "avatar_url": currentUser["avatar_url"]}, 
        {"user_id": user["id"], "avatar_url": user["avatar_url"],  "full_name": user["full_name"],}
      ], 
      "Processing...", 
      false, 
      0, 
      {}, 
      false,
      0, {}, "", null, DateTime.now().toString()
    );

    Provider.of<DirectMessage>(context, listen: false).setSelectedDM( dm, "");
  }

  updateBadge() {
    var macOSPlatformChannelSpecifics = new MacOSNotificationDetails(
      presentAlert: false, 
      presentBadge: true, 
      presentSound: false, 
      badgeNumber: checkNewBadgeCount()
    );

    var platformChannelSpecifics = NotificationDetails(macOS: macOSPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(
      0, "", "", 
      platformChannelSpecifics
    );
  }

  checkNewBadgeCount() {
    final channels = Provider.of<Channels>(context, listen: false).data;
    final data = Provider.of<DirectMessage>(context, listen: false).data;
    int count = 0;

    for (var c in channels) {
      if (c["new_message_count"] != null) {
        count += int.parse(c["new_message_count"]);
      }
    }

    for (var d in data) {
      if (d.newMessageCount != null) {
        count += int.parse(d.newMessageCount);
      }
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    var otherUser = Provider.of<User>(context, listen: true).otherUser;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    double deviceWidth = MediaQuery.of(context).size.width;
    String dateString = Utils.checkedTypeEmpty(otherUser) && Utils.checkedTypeEmpty(otherUser!["date_of_birth"])
      ? DateFormatter().renderTime(DateTime.parse(otherUser["date_of_birth"]), type: "dd-MM-yyyy")
      : "Not set";

    return otherUser != null ? Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2e3135) : Colors.grey[200],
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: otherUser["id"] == null ? Container() : Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black26 : Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5))
            ),
            width: deviceWidth,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Container(
                    //   child: PrettyQr(
                    //     image: AssetImage('images/twitter.png'),
                    //     typeNumber: 3,
                    //     size: 200,
                    //     data: 'https://www.google.ru',
                    //     // errorCorrectLevel: QrErrorCorrectLevel.M,
                    //     roundEdges: true
                    //   )
                    // ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child:  CachedAvatar(
                        otherUser["avatar_url"],
                        height: 75, width: 75,
                        isRound: true,
                        name: otherUser["full_name"]
                      )
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 8, bottom: 8, right: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            otherUser["full_name"] ?? "", 
                            style: TextStyle(
                              color: isDark ? Colors.grey[200] : Colors.grey[800], 
                              fontWeight: FontWeight.bold, 
                              fontSize: 22
                            )
                          ),
                          SizedBox(height: 16),
                          Text(
                            otherUser["is_online"] ? "Online" : "Offline", 
                            style: TextStyle(
                              color: isDark ? Colors.grey[200] : Colors.grey[800], 
                              fontSize: 12
                            )
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  child: Divider(thickness: 1)
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: TextButton(
                          onPressed: () async {
                            await goDirectMessage(otherUser);
                            Navigator.pop(context);
                          }, 
                          child: Column(children: <Widget>[
                            Icon(Icons.message, color: isDark ? Colors.grey[200] : Colors.grey[600], size: 23), 
                            Text("Message", style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 12.5))
                          ]) 
                        ),
                      ),
                      Container(
                        child: TextButton(
                          onPressed: null,
                          child: Column(children: <Widget>[
                            Icon(Icons.call, color: isDark ? Colors.grey[400] : Colors.grey[400], size: 23), 
                            Text("Call", style: TextStyle(color: Colors.grey[400], height: 1.6, fontSize: 12.5))
                          ]) 
                        ),
                      ),
                      Container(
                        child: TextButton(
                          onPressed: null,
                          child: Column(children: <Widget>[
                            Icon(Icons.video_call, color: isDark ? Colors.grey[400] : Colors.grey[400], size: 23), 
                            Text("Video", style: TextStyle(color: Colors.grey[400], height: 1.6, fontSize: 12.5))
                          ])
                        ),
                      ),
                      FriendStatus(deviceWidth: 400)
                    ]
                  ),
                )
              ]
            ),
          ),
          Container(
            width: deviceWidth,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: <Widget>[
                    Row(children: [Text("Information", style: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 15))]),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isDark ? Color(0xFF35393e) : Colors.white 
                      ),
                      padding: EdgeInsets.only(left: 20),
                      child: Column(children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(right: 15),
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 0.1, color: Colors.grey))
                            ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Text( "Full name", style: TextStyle(fontSize: 14) )
                              ),
                              Container(
                                child: Text( '${otherUser["full_name"]}', style: TextStyle(color: Colors.grey, fontSize: 14) )
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 15),
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 0.1, color: Colors.grey)
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Text( "Gender", style: TextStyle(fontSize: 14) )
                              ),
                              Container(
                                child: Text( otherUser["gender"] == null ? otherUser["gender"] : "Not set", style: TextStyle(color: Colors.grey, fontSize: 14)
                              )),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 15),
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(width: 0.1, color: Colors.grey)
                              )
                            ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Text( "Email", style: TextStyle(fontSize: 14) )
                              ),
                              Container(
                                child: Text( 
                                  '${otherUser["email"]}', 
                                  style: TextStyle( color: Color(0xff0084ff), fontSize: 14) 
                                )
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 15),
                          height: 52,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 0.1, color: Colors.grey)
                            )
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: 100,
                                child: Text( "Birthday", style: TextStyle(fontSize: 14) )
                              ),
                              Container(
                                child: Text( dateString, style: TextStyle(color: Colors.grey, fontSize: 14) )
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 15),
                          height: 52,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                  width: 100,
                                  child: Text(
                                    "Phone",
                                    style: TextStyle(fontSize: 14),
                                  )),
                              Container(
                                child: Text((otherUser["phone_number"] == null || otherUser["phone_number"] == "") ? "Not set" : '${otherUser["phone_number"]}' ,
                                style: TextStyle( color: (otherUser["phone_number"] == null || otherUser["phone_number"] == "") ? Colors.grey[400] : Color(0xff0084ff), fontSize: 14) )
                              ),
                            ],
                          ),
                        )
                      ]),
                    )
                  ],
                )
              ],
            ),
          )
        ]
      ) 
    ) : SplashScreen();
  }
}

class FriendStatus extends StatelessWidget {
  const FriendStatus({
    Key? key,
    @required this.deviceWidth
  }) : super(key: key);

  final deviceWidth;

  @override
  Widget build(BuildContext context) {
    final otherUser = Provider.of<User>(context, listen: true).otherUser;
    final isSended = otherUser!["is_sended"] == 1 ? true : false;
    final isRequested = otherUser["is_requested"] == 1 ? true : false;
    final token = Provider.of<Auth>(context, listen: false).token;

    return Container(
      width: deviceWidth/5,
      child: TextButton(
        onPressed: () async {
          if (isSended == true && isRequested == true) {
            await showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text("Block", style: TextStyle(color: Color(0xffEF5350))),
                  onPressed: () {

                  }
                ),
                CupertinoActionSheetAction(
                  child: Text("Remove Friend"),
                  onPressed: () async {
                    await Provider.of<User>(context, listen: false).removeRequest(token, otherUser["id"]);
                    Navigator.pop(context);
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
                    await Provider.of<User>(context, listen: false).acceptRequest(token, otherUser["id"]);
                    Navigator.pop(context);
                  }
                ),
                CupertinoActionSheetAction(
                  child: Text("Reject", style: TextStyle(color: Colors.red[400])),
                  onPressed: () async {
                    await Provider.of<User>(context, listen: false).removeRequest(token, otherUser["id"]);
                    Navigator.pop(context);
                  }
                )
              ])
            );
          } else if (isSended) {
            await Provider.of<User>(context, listen: false).removeRequest(token, otherUser["id"]);
            Navigator.pop(context);
          } else {
            await Provider.of<User>(context, listen: false).addFriendRequest(otherUser["id"],token);
          }
        }, 
        child: Column(
          children: <Widget>[
            Icon(
              (isRequested == true && isSended == true) ? Icons.check : (isRequested == true || isSended == true) ? Icons.replay : Icons.person_add, 
              color: Color(0xff0084ff), size: 23
            ), 
            Text(
              (isRequested == true && isSended == true ) ? "Accepted" : isRequested == true ? "Response" : isSended ? "Cancel" : "Add Friend", 
              style: TextStyle(color: Color(0xff0084ff), height: 1.6, fontSize: 12.5)
            )
          ]
        )
      ),
    );
  }
}
