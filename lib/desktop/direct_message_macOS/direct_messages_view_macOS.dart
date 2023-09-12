import 'dart:async';
import 'dart:math';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/direct_message/dm_input_shared.dart';
import 'package:workcake/emoji/emoji.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';

class DirectMessagesViewMacOS extends StatefulWidget {
  final handleCheckedConversation;
  DirectMessagesViewMacOS({
    Key? key,
    this.handleCheckedConversation
  }) : super(key: key);

  @override
  _DirectMessagesViewMacOSState createState() => _DirectMessagesViewMacOSState();
}

class _DirectMessagesViewMacOSState extends State<DirectMessagesViewMacOS> {
  var data = [];
  var direct;
  var deviceIp;
  var deviceInfo;

  @override
  void initState() {
    super.initState();
    initData();
    deviceInfo = DeviceInfoPlugin();
  }

  Future initData() async {
    // send data to the Provide to use
    // await Hive.openBox('direct');
    direct =  Hive.box('direct');
    setState(() {});
    // call api
  }

  disconnectDirect() {
    final channel = Provider.of<Auth>(context, listen: false).channel;
    channel.push(
      event: "disconnect_direct",
      payload: {}
    );
  }

  renderSnippet(att, dm) {
    final string = (att != null && dm != null && att.length > 0) ? (att[0]["type"] == "mention" ? att[0]["data"].map((e) {
      if (e["type"] == "text" ) return e["value"];
      return "${e["trigger"] ?? "@"} ${e["name"] ?? ""} ";
    }).toList().join() : "Sent an image") : "";

    return string;
  }

  sendRequestSync(channel, auth) async{
    // get channel.
    showDialog(context: context,
      builder: (BuildContext context){
        return Container(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            insetPadding: EdgeInsets.all(0),
            contentPadding: EdgeInsets.all(0),
            content: Container(
              width: 448,
              child: DMInputShared(type: "syncDM"),
            )
          )
        );
      }
    );
    Map data  =  {
      "deviceId": await Utils.getDeviceId(),
      "has_confirm": true,
      "flow": "file"
    };
    channel.push(
      event: "request_conversation_sync",
      payload: {
        "data": await Utils.encryptServer(data),
        "device_id": await Utils.getDeviceId(),
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDirectMessage = Provider.of<DirectMessage>(context, listen: true).directMessageSelected;
    final list = Provider.of<DirectMessage>(context, listen: true).data.toList();
    final dataConversationMessages = Provider.of<DirectMessage>(context, listen: true).dataDMMessages;
    final selectedFriend = Provider.of<DirectMessage>(context, listen: true).selectedFriend;
    final selectedMention = Provider.of<DirectMessage>(context, listen: true).selectedMentionDM;
    final auth  = Provider.of<Auth>(context, listen: true);
    final errorCode  = Provider.of<DirectMessage>(context, listen: true).errorCode;
    final channel  = Provider.of<Auth>(context, listen: true).channel;
    return Column(
      children: <Widget>[
        Container(
        decoration: BoxDecoration(
            border: Border(
              // right: BorderSide(color: Color.fromRGBO(31, 41, 51, 0.5)),
              bottom: BorderSide(color: Color.fromRGBO(31, 41, 51, 0.5)),
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          // width: 238,
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: HoverItem(
                  child: GestureDetector(
                  // color: Color(0xff1F2933),
                  onTap: () {
                  //  showSearchBar(context);
                  },
                  child: Container(
                    height: 32,
                    padding: EdgeInsets.all(7),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFF1F2933),
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child:  Text(
                      "Find or start a conversation",
                      style: TextStyle(color: Color(0xff72767d), fontWeight: FontWeight.w400, fontSize: 12)
                    ),
                  )),
                  colorHover: Color(0xFF1F2933)
                ),
              ),
             
              Container(width: 8,),
              HoverItem(
                child: GestureDetector(
                  // color: Color(0xff1F2933),
                  onTap: () async{
                    await Provider.of<DirectMessage>(context, listen: false).setSelectedMention(true);
                  },
                  child: Container(
                    height: 31,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF1F2933),
                      borderRadius: BorderRadius.circular(3)
                    ),
                    child: Text("@", style: TextStyle(color: Color(0xffF0F4F8), fontWeight: FontWeight.w400, fontSize: 12)))
                  ), 
                colorHover: Color(0xFF1F2933)
              )
            ],
          )
        ),
        Utils.checkedTypeEmpty(errorCode) ? 
          Container(
            margin: EdgeInsets.only(top: 14),
            child: "$errorCode" == "203" ?  TextButton(
              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xFF10239e)), padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 20))),
              onPressed: (){
                sendRequestSync(channel, auth);
              },
              child: Text("Sync data", style: TextStyle(color: Color(0xFFf0f0f0))),
            )
            : Container(
              margin: EdgeInsets.only(top: 14),
              padding:EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color(0xFF22075e)
              ),
              child: Text("$errorCode" == "216" ? "Please update version" : "Device is not registered", style: TextStyle(color: Color(0xFF8c8c8c)),),
            ),
          )
        : Container(),
          Expanded(
            child: Container(
              child: Container(
                // margin: EdgeInsets.only(top: 14),
                // padding: EdgeInsets.only(top: 14),
                // height: MediaQuery.of(context).size.height - 122,
                // ignore: deprecated_member_use
                child: direct == null ? Text('') : Align(
                  alignment: Alignment.topCenter,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      DirectModel directMessage = list[index];
                      if (directMessage.archive == true) return Container();
                      var messageSnippet;
                      var userSnippet;
                      var currentTime = 0; List userRead = [];
                      var indexConverMessage  =  dataConversationMessages.indexWhere((element) => element.conversationId== directMessage.id);
                      if (indexConverMessage != -1) {

                      }
                      if (directMessage.snippet != {}) {
                        final indexUser = directMessage.user.indexWhere((e) => e["user_id"] == directMessage.snippet["user_id"]);
                        userSnippet = indexUser != -1 ? directMessage.user[indexUser] : null;

                        messageSnippet = directMessage.snippet["attachments"] != null && directMessage.snippet["attachments"].length > 0
                          ? renderSnippet(directMessage.snippet["attachments"], directMessage)
                          : directMessage.snippet["message"];
                      } else {
                        // messageSnippet = "";
                        // userSnippet = "";
                      }
                      

                      return DirectMessageItem(
                        directMessage: directMessage, 
                        handleCheckedConversation: widget.handleCheckedConversation, 
                        currentDirectMessage: currentDirectMessage, 
                        currentTime: currentTime, 
                        dataConversationMessages: dataConversationMessages ,
                        index: index, 
                        indexConverMessage: indexConverMessage, 
                        messageSnippet: messageSnippet, 
                        selectedFriend: selectedFriend, 
                        selectedMention: selectedMention, 
                        userRead: userRead, 
                        userSnippet: userSnippet);
                    }
                  )
                )
              )
            )
        )
      ],
    );
  }
}

// ignore: must_be_immutable
class DirectMessageItem extends StatefulWidget{
  DirectMessageItem({
    this.handleCheckedConversation,
    required this.directMessage,
    this.userSnippet,
    this.messageSnippet,
    this.userRead,
    this.currentTime,
    this.dataConversationMessages,
    this.indexConverMessage,
    this.currentDirectMessage,
    this.selectedFriend,
    this.selectedMention,
    this.index
  });
  final handleCheckedConversation;
  DirectModel directMessage;
  var userSnippet;
  var messageSnippet;
  var userRead;
  var currentTime;
  final dataConversationMessages;
  final indexConverMessage;
  final currentDirectMessage;
  final selectedFriend;
  final selectedMention;
  final index;
  @override
  State<StatefulWidget> createState() {
    return _DirectMessageItemState();
  }
}
class _DirectMessageItemState extends State<DirectMessageItem>{
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var isHover = false;
  getFieldOfListUser(List data, String field) {
    if (data.length  == 1) return data[0][field];
    var result = "";
    var userId  = Provider.of<Auth>(context, listen: false).userId;
    for (var i = 0; i < data.length; i++) {
      if (data[i]["user_id"] == userId) continue;
      if (i != 0 && result != "") result += ", ";
      result += data[i][field];
    }
    return result;
  }
  getAvatarUrl(List data) {
    if (data.length  == 1) return data[0]["avatar_url"];
    if (data.length > 1){
      var userId  = Provider.of<Auth>(context, listen: false).userId;
      for (var i = 0; i < data.length; i++) {
        if (data[i]["user_id"] == userId) continue;
        return data[i]["avatar_url"];
      }
    }
  }
  checkNewBadgeCount() {
    final channels = Provider.of<Channels>(context, listen: false).data;
    final data = Provider.of<DirectMessage>(context, listen: false).data;
    int count = 0;

    for (var c in channels) {
      if (c["new_message_count"] != null) {
        count += int.parse("${c["new_message_count"]}");
      }
    }

    for (var d in data) {
      if (d.newMessageCount != null) {
        count += int.parse("${d.newMessageCount}");
      }
    }

    return count;
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
  onSelectDirectMessage(directMessage) async {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentDirectMessage = Provider.of<DirectMessage>(context, listen: false).directMessageSelected;
    final channel = auth.channel;

    await Provider.of<DirectMessage>(context, listen: false).onChangeSelectedFriend(false);
    await Provider.of<DirectMessage>(context, listen: false).setIdMessageToJump("");

    if (currentDirectMessage.id != directMessage.id) {
      await channel.push(event: "join_direct", payload: {"direct_id": directMessage.id});
      await Provider.of<DirectMessage>(context, listen: false).setSelectedDM(directMessage, auth.token);
      await Provider.of<DirectMessage>(context, listen: false).getMessageFromApiDown(directMessage.id, true, auth.token, auth.userId);
      // widget.handleCheckedConversation(true);
    }

    updateBadge();
  }

  onHideDirectMessage(idDirectMessage,idCurrentDirectMessage, isHide) async {
    if (idDirectMessage == idCurrentDirectMessage){
      List listDm = widget.dataConversationMessages;
      List listDirectModel = Provider.of<DirectMessage>(context, listen: false).data.toList();
      var indexPanchat = listDm.indexWhere((element) => element["type"] == "panchat");
      var indexPanchatModel = listDirectModel.indexWhere((element) => element.id == listDm[indexPanchat]["conversation_id"]);
      if (indexPanchat == -1) return;
      if (indexPanchatModel != -1){
        DirectModel dm = listDirectModel[indexPanchatModel];
        await onSelectDirectMessage(dm);
      }
    }
    await Provider.of<DirectMessage>(context, listen: false).setHideConversation(idDirectMessage, isHide, context);
  }

  @override
  Widget build(BuildContext context) {
    DirectModel directMessage = widget.directMessage;
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    var userSnippet = widget.userSnippet;
    final userId = Provider.of<Auth>(context, listen: true).userId;
    List userRead = widget.userRead;
    var messageSnippet = widget.messageSnippet;
    var currentTime = widget.currentTime;
    final dataConversationMessages = widget.dataConversationMessages;
    final indexConverMessage = widget.indexConverMessage;
    final currentDirectMessage = widget.currentDirectMessage;
    final selectedFriend = widget.selectedFriend;
    final selectedMention = widget.selectedMention;
    final index = widget.index;

    if (indexConverMessage == -1) return Container();
    return InkWell(
      onHover: (hover){
        setState(() {
          isHover = hover;
        });
      },
      onTap: () async {
        onSelectDirectMessage(directMessage);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3),
        padding: EdgeInsets.only(left: 16, right: 8),
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Expanded(
            child: Row(children: [
              directMessage.user.length == 1
              ? CachedAvatar(
                getAvatarUrl(directMessage.user),
                height: 32, width: 32, radius: 16,
                isRound: true,
                name: directMessage.name != "" ? directMessage.name : directMessage.displayName,
                isAvatar: true
              )
              : directMessage.user.length > 2
                ? SizedBox(
                    width: 32,
                    height: 32,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(((index + 1) * pi * 0.1 * 0xFFFFFF).toInt()).withOpacity(1.0),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Icon(
                        Icons.group,
                        size: 16,
                        color: Colors.white
                      ),
                    ),
                  )
                : CachedAvatar(
                  getAvatarUrl(directMessage.user),
                  height: 32, width: 32, radius: 16,
                  isRound: true,
                  name: directMessage.name != "" ? directMessage.name : directMessage.displayName,
                  isAvatar: true
                ),
              SizedBox(width:8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 98,
                      child: Container(
                        child: Text( directMessage.name != "" ? directMessage.name : directMessage.displayName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Color((currentDirectMessage.id == directMessage.id && !selectedFriend && !selectedMention) ? 0xfff0f4f8 : !isHover ? 0xff8e9297 : 0xffF0F4F8))
                        )
                      ) ,
                    ),
                    userSnippet != null && userSnippet["full_name"] != "" ? Container(
                      constraints:BoxConstraints(maxHeight: 20),
                      child: userSnippet == null
                        ? Container()
                        : Row(
                          children: [
                            userSnippet["user_id"] == userId 
                            ? Container(
                              margin: EdgeInsets.only(right: 2, top: 3.5),
                              child: Icon(
                                  Icons.subdirectory_arrow_right,
                                  color: Color(0xFF616E7C),
                                  size: 13 ,
                                ),
                            )
                            : directMessage.user.length  == 2 
                              ? Container()
                              : Text(userSnippet["full_name"] + ": ", style: TextStyle(
                                // tin chuwa docj snippet mau trang, 
                                color: (userRead.indexWhere((element) => element == userId) == -1) ? Color(0xffF5F7FA) : Color(0xFF616E7C) ,
                                fontSize: 11, height: 1.5
                              ),),

                            Expanded(
                              child: Text(
                                "$messageSnippet",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  // tin chuwa docj snippet mau trang, 
                                  color: (userRead.indexWhere((element) => element == userId) == -1) ? Color(0xffF5F7FA) : Color(0xFF616E7C) ,
                                  fontSize: 11, height: 1.5
                                ),
                              ),
                            ),
                          ],
                        )           
                    ) : Container()
                  ],
                ),
              )]
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              renderUserRead(
                directMessage.seen,
                directMessage.user, 
                userId, 
                userRead,
                "$currentTime",
                dataConversationMessages[indexConverMessage]["userRead"]["last_user_id_send_message"] ?? "",
                isDark
              ),
              Container(
                // margin: EdgeInsets.only(bottom: userRead.length == 0 ? -5 : 0),
                child: ShowTime(time: currentTime),
              )
              
            ],
          ),
          isHover && (dataConversationMessages[indexConverMessage]["type"] != "panchat") ? InkWell(
            child: Container(margin: EdgeInsets.only(left: 5), width: 20, height: 20, child: Center(child: Icon(Icons.close, size: 17.0,color: Colors.white,))),
            onTap: (){
              onHideDirectMessage(directMessage.id, currentDirectMessage.id, true);
            },  
          ) : Container()
        ],),
          
        decoration: (currentDirectMessage.id == directMessage.id && !selectedFriend && !selectedMention) ? BoxDecoration(
          color: Color(0xff1F2933)
        ) : isHover ? BoxDecoration(color: Color(0x4f545c52)) : BoxDecoration(),
      )
    );
  }
}

showSearchBar(context) {
  // showGeneralDialog(
  //   context: context,
  //   barrierColor: Colors.black.withOpacity(0.5),
  //   barrierDismissible: true,
  //   barrierLabel: '',
  //   transitionDuration: Duration(milliseconds: 230),
  //   transitionBuilder: (context, a1, a2, widget){
  //     var begin = 1.5;
  //     var end = 1.0;
  //     var curve = Curves.easeOutBack;
  //     var curveTween = CurveTween(curve: curve);
  //     var tween = Tween(begin: begin, end: end).chain(curveTween);
  //     var offsetAnimation = a1.drive(tween);
  //     return ScaleTransition(
  //       scale: offsetAnimation,
  //       child: FadeTransition(
  //         opacity: a1,
  //         child: widget,
  //       ),
  //     );
  //   },
  //   pageBuilder: (BuildContext context, a1, a2) {
  //     return AlertDialog(
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
  //       insetPadding: EdgeInsets.all(0),
  //       contentPadding: EdgeInsets.all(0),
  //       content: Container(
  //         width: 540,
  //         height: 650,
  //         child: Center(
  //           child: SearchBarNavigation(),
  //         )
  //       ),
  //     );
  //   }
  // );
}

class ShowTime extends StatefulWidget{
  final time;

  ShowTime({
    Key? key,
    @required this.time
  });

  @override 
  _ShowTime createState() => _ShowTime();
}

class _ShowTime extends State<ShowTime> {

  String timeString = "";
  var timer;

  @override
  void initState() {
    super.initState();
    initTime();
  }

  @override
  void didUpdateWidget(oldWidget){
    super.didUpdateWidget(oldWidget);
    if (widget.time != oldWidget.time){
      if (timer != null) {timer.cancel(); timer = null;}
      initTime();
    }
  }

  initTime(){
    if (timer == null)
      timer =  new Timer.periodic(Duration(seconds: 60), (t){
        genNewString();
      });
    setState(() {
      timeString = getTimeString();
    });
  }

  genNewString(){
    String newString = getTimeString();
    if (this.mounted && newString != timeString)
    this.setState(() {
      timeString = newString;
    });
  }

  getTimeString(){
    int time = widget.time;

    if (time == 0) return "";

    int now = DateTime.now().microsecondsSinceEpoch;
    int diff  = now - time;
    DateTime t =  DateTime.fromMicrosecondsSinceEpoch(time);

    if (DateTime.now().year != t.year) return "${t.year}";
    if (diff < 60000000) return S.current.now;
    if (diff < 60000000 * 60) return "${(diff / 60000000).round()}m";
    if (diff < 60000000 * 60 * 24) return  "${(diff / 60000000 / 60).round()}h";
    if (diff < 60000000 * 60 * 24 * 7) return "${listDay[t.weekday % 7]}";
    return "${getStringMonth(t.month)} ${t.day}";
  }


  var listDay  =  ["Sun", "Mon", "Tue", "Wed", "Thur", "Fri", "Sat"];

  getStringMonth(month){
    switch (month) {
      case 1: return "Jan";
      case 2: return "Feb";
      case 3: return "Mar";
      case 4: return "Apr";
      case 5: return "May";
      case 6: return "Jun";
      case 7: return "Jul";
      case 8: return "Aug";
      case 9: return "Sep";
      case 10: return "Oct";
      case 11: return "Nov";
      case 12: return "Dec";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      margin: EdgeInsets.only(top: 6, bottom: 6),
      child: Text(timeString, style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xFF828282), fontSize: 10, height: 1.5),
    ));
  }
}

renderUserRead(bool seen, List users, String userId, List userRead, currentTime, String lastUserIdSendMessage, isDark) {
  if ("$currentTime" == "0") return Container();
  var indexUser  = userRead.indexWhere((element) => element == userId);
  List otherUserAvatarUrl  = (userRead.where((element) => element != userId && element != lastUserIdSendMessage).toList().map((e) {
    var indexUser  =  users.indexWhere((element) => element["user_id"] == e);
    if (indexUser == -1) return null;
    return {
      "avatar_url": users[indexUser]["avatar_url"],
      "name": users[indexUser]["full_name"]
    };
  }).where((element) => element != null)).toList();

  List renderUserAvatarUrl = otherUserAvatarUrl.take(2).toList();

  if (indexUser == -1 || !seen) {
    return Container(
      height: 8, width: 8,
      margin: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? Color(0xffFAAD14) : Color(0xFF1890FF),
        borderRadius: BorderRadius.circular(4))
    );}
  if (userRead.length == 1) 
    return Container(
      margin: EdgeInsets.only(top: 3),
      child: Icon(PhosphorIcons.checkCircleFill, size: 12, color: isDark ? Color(0xffC9C9C9) : Color(0xffA6A6A6),),
    );
  if (otherUserAvatarUrl.length == 0) return Container(height: 0,);
  return Container(
    margin: EdgeInsets.only(top: 2),
    child: Row(
      children: [
        Row(
          children: renderUserAvatarUrl.map((e) => Container(
            margin: EdgeInsets.only(left: 3),
            child: CachedAvatar(e["avatar_url"], width: 10, height: 10, radius: 5, name: e["name"], fontSize: 5,))).toList(),
        ),
        renderUserAvatarUrl.length < otherUserAvatarUrl.length 
          ? Container(
            margin: EdgeInsets.only(left: 3),
            height: 10, width: 10,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Color(0xFFffffff)
            ),
            child: Text("+ ${ otherUserAvatarUrl.length - renderUserAvatarUrl.length }", style: TextStyle(fontSize: 5, color: Color(0xFF262626)),),
          )
          : Container()
      ],
    )
  );
}
