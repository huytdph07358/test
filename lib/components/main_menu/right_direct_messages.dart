import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/create_direct_message.dart';
import 'package:workcake/components/direct_message/dm_input_shared.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/desktop/direct_message_macOS/direct_messages_view_macOS.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/provider/thread_user.dart';
import 'package:workcake/screens/overlapping.dart';
import 'package:workcake/screens/thread/thread_conversation.dart';
import '../../common/progress.dart';


class RightDirectMessages extends StatefulWidget {
  final changePageView;
  final numberType;
  RightDirectMessages({
    Key? key,
    this.changePageView, 
    this.numberType, 
  }) : super(key: key);

  @override
  _RightDirectMessagesState createState() => _RightDirectMessagesState();
}

class _RightDirectMessagesState extends State<RightDirectMessages> {
  var data = [];
  var direct;
  var deviceIp;
  var deviceInfo;
  TextEditingController _controller = TextEditingController();
  FocusNode node = FocusNode();
  List filteredDirectMessageList = [];
  Timer? _debounce;
  var _scrollController  = ScrollController();
  Map streamResults = {
    "text": "",
    "data": ""
  };

  // get list of conv

  @override
  void initState() {
    super.initState();
    deviceInfo = DeviceInfoPlugin();
    getIpDevice();
    _scrollController.addListener(() {
      final auth = Provider.of<Auth>(context, listen: false);
      if (_scrollController.position.extentAfter < 50) 
        Provider.of<DirectMessage>(context, listen: false).getDataDirectMessage(auth.token, auth.userId, isLoadMore: true);
     });
  }

  @override
  void dispose(){
    node.dispose();
    _debounce?.cancel();
    super.dispose();
  }

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

String getTextAtt(int video, int other ,int image , int attachment){
    if (video == 1 && other == 0 && image == 0) return S.current.sentAVideo;
    if (video >1 && other == 0 && image == 0) return S.current.sentVideos(video);
    if (video == 0 && other == 1 && image == 0) return S.current.sentAFile;
    if (video == 0 && other > 1 && image == 0) return S.current.sentFiles(other);
    if (video == 0 && other == 0 && image == 1) return S.current.sentAnImage;
    if (video == 0 && other == 0 && image > 1) return S.current.sentImages(image);
    if (video == 0 && other == 0 && image == 0 && attachment == 0) return "";
    if (attachment == 1) return S.current.sentAttachments;
    return S.current.sentAttachments;
}
String renderSnippet(List att, dm) {
  Map t = getType(att, dm);
   return  getTextAtt( t['video'], t['other'], t['image'], t['attachment'])+ t['call_terminated']+ t['invite'] + t['assign'] + t['closeissue'] + t["avatar"] + t['invitechannel'] + t['sticker'] + t['share'] + t['e'] + t['mention'] + t['leavedirect'];
}

Map getType(List att, dm )  {
    Map t ={
      'video':0,
      'other':0,
      'image':0,
      'call_terminated':'',
      'attachment':0,
      'invite':'',
      'mention':'',
      'assign':'',
      'closeissue':'',
      "avatar":'',
      'invitechannel':'',
      'sticker' :'',
      'share' :'',
      'e':'',
      'leavedirect':''
    };
    if(att.length == 0){
      return t ;
    }
    final data = att[0]['data'];
    for(int i =0; i< att.length; i++){
      String? mime= att[i]['mime_type']?? '';
    try {
      if ( mime == null ) continue;
      if ( mime=='image'||mime=='jpg' || mime=='png' || mime=='heic' || mime=='jpeg' || att[0]['type']== 'image') {
        t['image'] += 1;
      } else if ( mime=="mov"||mime=="mp4"||mime=="video" ) {
        t['video']+=1;
      } else if (att[i]['type'] == 'sticker') {
        if (Utils.checkedTypeEmpty(data["character"])) {
            t['sticker']+= S.current.sticker(data["character"]);
          } else {
            t['sticker']+= S.current.sticker1;
        }
      } else if( att[i]['type']== 'invite' ) {
          if(Utils.checkedTypeEmpty(data['is_workspace'])) {
            t['invitechannel']+= S.current.inviedWorkSpace(data["full_name"], data["workspace_name"]);
          } else {
            if (Utils.checkedTypeEmpty(data['isAccepted']) ) {
            t['invitechannel']+= S.current.inviedChannels;
          } else {
            t['invitechannel']+= S.current.inviedChannel(data["full_name"], data["channel_name"]);
          }
        }
      } else if( att[i]['type']== 'assign' ) {
        if ( Utils.checkedTypeEmpty(data['assign'])) {
          t['assign']+= S.current.assignIssue(data["full_name"]) ;
        } else {
          t['assign']+= S.current.unassignIssue(data["full_name"]) ;
        }
      } else if( att[i]['type']== 'close_issue' ) {
          if( Utils.checkedTypeEmpty(data['user_watching']) ) {
          if ( Utils.checkedTypeEmpty(data['is_closed']) ) {
            t['closeissue']+= S.current.closeIssues(data["assign_user"], data["issue_author"] ?? "", data["channel_name"]);
          } else {
            t['closeissue']+= S.current.reopened(data["assign_user"], data["issue_author"] ?? "", data["channel_name"]);
          }
        } else {
          if ( Utils.checkedTypeEmpty(data['is_closed']) ) {
            t['closeissue']+= S.current.closeIssues1(data["assign_user"], data["channel_name"]);
          } else {
            t['closeissue']+= S.current.reopened1(data["assign_user"], data["channel_name"]);
          }
        }
      } else if (att[i]['mime_type'] == 'share') {
          t['share']+= S.current.reply;
      } else if (att[i]['mime_type'] == 'shareforwar') {
          t['share']+= S.current.share;
      }  else if( att[i]['type']== 'update_conversation') {
          t['avatar']+= S.current.changeAvatarDm( att[i]["user"]['name'] );
      } else if( att[i]['type'] == 'device_info' || att[i]['type'] == 'action_button' ) {
          t['attachment']+= 1;
      } else if( att[i]['type'] == 'invite_direct' ) {
          t['invite']+= S.current.invied(att[i]["user"], att[i]["invited_user"]);
      } else if ( att[i]["type"] == "mention" ){
        t['mention'] += att[i]["data"].map((e) {
          if (['user', 'all', 'issue'].contains(e["type"])) 
            return "${e["trigger"] ?? "@"}${e["name"] ?? ""} ";
          else
            return e["value"];
        }).toList().join();
      }  else if( att[i]['type'] == 'leave_direct' ) {
          t['leavedirect']+= S.current.leaveDirect;
      } else {
        t['other']+=1;
      }
    } catch (e){
      t['e']+= S.current.sentAttachments;
    }
  }
  return t;

  }

  getIpDevice() async {
    var response = await Dio().get('https://api.ipify.org?format=json');
    var dataRes = response.data;
    try {
      deviceIp = dataRes;
    } catch (e) {
      throw e;
    }
  }

  getDeviceInfo() async{
    await getIpDevice();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return "${androidInfo.product}(${androidInfo.model})";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return "${iosInfo.name}(${iosInfo.model})";
    }
  }

  sendRequestSync(channel, auth, String type) async{
    // get channel.
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      builder: (context){
        return Container(
          height: MediaQuery.of(context).size.height*0.75,
          child:  DMInputShared(type: type),
        );
      }
    );

    if (type == "reset") {
      Provider.of<User>(context, listen: false).sendRequestCreateVertifyCode(auth.token);
    } else {
      var deviceName = await getDeviceInfo();
      LazyBox box  = Hive.lazyBox('pairKey');
      Map data  =  {
        "deviceId": await box.get("deviceId"),
        "has_confirm": true,
        "flow": "file"
      };
      channel.push(
        event: "request_conversation_sync",
        payload: {
          "data": await Utils.encryptServer(data),
          "device_id": await box.get("deviceId"),
          "device_name": deviceName,
          "device_ip": deviceIp["ip"]
        }
      );      
    }
    
  }

  _onChangeText(value) async {
  
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value == "") return setState(() {
        streamResults = {
          "data": [],
          "text": ""
        };
      });
      final auth = Provider.of<Auth>(context, listen: false);
      String searchInput = value.trim();
      var url = "${Utils.apiUrl}direct_messages/search_conversation?token=${auth.token}&text=$searchInput";
      var res  = await Dio().get(url);
      List<Map> result = (res.data["data"] as List).map((e) => (e as Map)).toList();
      setState(() {
        streamResults = {
          "data": result,
          "text": value
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final directMessages  = Provider.of<DirectMessage>(context, listen: true).data;
    final directMessageSelected = Provider.of<DirectMessage>(context, listen: true).directMessageSelected;
    final errorCode  = Provider.of<DirectMessage>(context, listen: true).errorCode;
    final channel  = Provider.of<Auth>(context, listen: true).channel;
    final userId = Provider.of<Auth>(context, listen: true).userId;
    // bool fetchingDataDirectMessage =  Provider.of<DirectMessage>(context, listen: true).fetching;
    final displayList = Utils.checkedTypeEmpty(_controller.text) ? filteredDirectMessageList : directMessages;
    final isFetching = Provider.of<DirectMessage>(context, listen: true).fetching;
    return GestureDetector(
      onTap: (){
        if (node.hasPrimaryFocus) node.unfocus();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 62,
            padding: EdgeInsets.only(left: 18),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan (
                    text: S.current.directMessages, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)),
                  )
                ),
                SizedBox(width: 8,),
                Row(
                  children: [
                    // ThreadIcon(key: Key("iconThread"),),
                     InkWell(
                      child: Container(
                        height: 30,
                        width: 30,
                        margin: EdgeInsets.only(right: 18),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xff444444) : Color(0xffEDEDED),
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: Icon(PhosphorIcons.plusBold, size: 18, color: isDark ? Colors.white : Color(0xff5E5E5E),)
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateDirectMessage()));
                      }
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: 5),
          Utils.checkedTypeEmpty(errorCode) ? 
            Container(
              child: "$errorCode" == "203" ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: (){
                          sendRequestSync(channel, auth, "sync");
                        },
                        child: Container(
                          padding:  EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !isDark ? Color(0xFF1890FF).withOpacity(0.08) : Color(0xFFFAAD14).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(width: 1.0, color: isDark ? Color(0xFFD48806) : Color(0xFF69C0FF))
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                            children: [
                              SvgPicture.asset(isDark ? "assets/images/icons/panchat_dart.svg" :"assets/images/icons/homeIconActive.svg",),
                              Container(width:8),
                              Text(S.current.syncPanchatApp, style: TextStyle(
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                                fontSize: 14,
                                color: !isDark ? Color(0xFF1890FF) : Color(0xFFFAAD14)
                              ))
                            ]
                          ) 
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        child: Text(S.current.descSyncPanchat, style: TextStyle(
                          color: isDark ? Color(0xFFA6A6A6) : Color(0xFF5E5E5E),
                          fontSize: 12,
                          height: 1.3
                        )),
                      ),
                      GestureDetector(
                        onTap: () {
                          sendRequestSync(channel, auth, "reset");
                        },
                        child: Container(
                          margin: EdgeInsets.only(top:24),
                          padding:  EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !isDark ? Color(0xFF1890FF).withOpacity(0.08) : Color(0xFFFAAD14).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(width: 1.0, color: isDark ? Color(0xFFD48806) : Color(0xFF69C0FF))
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                            children: [
                              SvgPicture.asset(isDark ? "assets/images/icons/key_dart.svg" : "assets/images/icons/key_light.svg"),
                              Container(width:8),
                              Text(S.current.resetDeviceKey, style: TextStyle(
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                                fontSize: 14,
                                color: !isDark ? Color(0xFF1890FF) : Color(0xFFFAAD14)
                              ))
                            ]
                          ) 
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        child: Text(S.current.descResetDeviceKey, style: TextStyle(
                          color: isDark ? Color(0xFFA6A6A6) : Color(0xFF5E5E5E),
                          fontSize: 12,
                          height: 1.3
                        )),
                      ),
                    ],
                  )
                )
                
              : Container(
                padding:EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Color(0xFF22075e)
                ),
                child: Text("$errorCode" == "216" ? "Please update version" : "$errorCode Error with status:", style: TextStyle(color: Color(0xFF8c8c8c)),),
              )
            )
          : Container(),
          StreamBuilder(
            initialData: MessageConversationServices.statusSyncStatic,
            stream: MessageConversationServices.statusSync,
            builder: (BuildContext c, AsyncSnapshot s){
              StatusSync t = s.data ?? MessageConversationServices.statusSyncStatic;
              if (t.statusCode == -1) return Container();
              return GestureDetector(
              onTap: (){
                if (t.statusCode == 400 || t.statusCode == 401) {
                  MessageConversationServices.statusSyncStatic = StatusSync(-1, "", "");
                  return MessageConversationServices.statusSyncController.add(MessageConversationServices.statusSyncStatic);
                }
              },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  color: t.statusCode == 400 || t.statusCode == 401 ? Colors.red[100]!.withOpacity(0.8) : Palette.backgroundRightSiderDark,
                  child: Text(t.status, style: TextStyle(color: t.statusCode == 400 || t.statusCode == 401 ? Colors.red[600] : Colors.white, fontSize: 12, overflow: TextOverflow.ellipsis)),
                ),
              );
            }
          ),
          streamResults["text"] == "" ? Flexible(
            child: RefreshIndicator(
              onRefresh: () async {
                await Provider.of<DirectMessage>(context, listen: false).getDataDirectMessage(auth.token, auth.userId, isReset: true);
              },
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                controller: _scrollController,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(16, 5, 16, 5),
                      height: 44,
                      child: CupertinoTextField(
                        controller: _controller,
                        focusNode: node,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
                        ),
                        onChanged: _onChangeText,
                        padding: EdgeInsets.only(left: 8, right: 8),
                        clearButtonMode: OverlayVisibilityMode.editing,
                        prefix: Container(
                          padding: EdgeInsets.only(left: 12),
                          child: Icon(PhosphorIcons.magnifyingGlass, size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E))
                        ),
                        placeholder: "Search",
                        placeholderStyle: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),
                        style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 6.0,),
                    ...displayList.map<Widget>((e)  {
                    var index = displayList.indexWhere((element) => element.id == e.id);
                    DirectModel directMessage = e;
                    if (directMessage.archive == true || index == -1) return Container();
                    var messageSnippet;
                    var userSnippet;
                    var lastUserIdSendMessage;
                    var numberType = {};
                    if (directMessage.snippet != {}) {
                      final indexUser = directMessage.user.indexWhere((e) => e["user_id"] == directMessage.snippet["user_id"]);
                      userSnippet = indexUser != -1 ? directMessage.user[indexUser] : null;
                      
                      messageSnippet = directMessage.snippet["attachments"] != null && directMessage.snippet["attachments"].length > 0 
                        ? renderSnippet(directMessage.snippet["attachments"], directMessage) 
                        : directMessage.snippet["message"];
                      if (directMessage.snippet["action"] == "delete") {
                        messageSnippet = "[This message was deleted.]";
                      }
                      numberType = getType(directMessage.snippet["attachments"] ?? [], directMessage);
                    } else {
                      messageSnippet = "";
                    }
                    List userRead = [];
                    var currentTime = 0;
                    userRead = directMessage.userRead["data"] ?? [];
                    currentTime = directMessage.userRead["current_time"] ?? 0;
                    lastUserIdSendMessage =  directMessage.userRead["last_user_id_send_message"] ?? "";
                    ConversationMessageData? current = Provider.of<DirectMessage>(context, listen: false).getCurrentDataDMMessage(directMessage.id);
                    return Material(
                      color: isDark ? Color(0xff2E2E2E) : Colors.white,
                      child: Container(
                        key: Key(directMessage.id),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          onTap: () async {
                            // can lay tin nhan local len truon trong khi goi api
                            try {
                              ConversationMessageData? current = Provider.of<DirectMessage>(context, listen: false).getCurrentDataDMMessage(directMessage.id);
                              if (current == null) return;
                              if (current.statusConversation == "created"){
                                Provider.of<DirectMessage>(context, listen: false).resetOneConversation(directMessage.id, needCallApi: false);
                                await Provider.of<DirectMessage>(context, listen: false).getMessageFromHiveDown(directMessage.id, DateTime.now().microsecondsSinceEpoch, auth.token, auth.userId, isGetIsarBeforeCallApi: true, limit: 20);
                                Provider.of<DirectMessage>(context, listen: false).getMessageFromApiDown(directMessage.id, true, auth.token, auth.userId);
                                if (channel != null) channel.push(event: "join_direct", payload: {"direct_id": directMessage.id});
                              }
                            
                              Provider.of<DirectMessage>(context, listen: false).setSelectedDM(directMessage, auth.token);
                              widget.changePageView(1);
                              if (node.hasPrimaryFocus) node.unfocus();
                            } catch (e, t) {
                              print("____$e, $t");
                            }
                           
                            Provider.of<DirectMessage>(context, listen: false).setSelectedDM(directMessage, auth.token);
                            Overlapping.of(context)?.reveal(RevealSide.right);
                            if (node.hasPrimaryFocus) node.unfocus();
                          },
                          child: Column(
                            children: [
                              Container(
                                decoration: (directMessageSelected.id != "" && directMessageSelected.id == directMessage.id) ? BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(3)),
                                  color: auth.theme == ThemeType.DARK ? Color(0xff393d41) : Colors.grey[100]
                                ) : BoxDecoration(),
                                // height: 50,
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                // margin: EdgeInsets.only(left: 8, right: 8),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(children: [
                                            Stack(
                                              children: [
                                                // directMessage.user.length == 1 send message myselft
                                                directMessage.user.length == 1
                                                ? CachedAvatar(
                                                  getAvatarUrl(directMessage.user),
                                                  height: 48, width: 48, radius: 20,
                                                  isRound: true,
                                                  name: directMessage.name != "" ? directMessage.name : directMessage.displayName,
                                                  isAvatar: true
                                                ) 
                                                : directMessage.user.length > 2 // send message to group
                                                  ? directMessage.avatarUrl != null
                                                    ? CachedAvatar(
                                                      // avatar of people
                                                      directMessage.avatarUrl,
                                                      height: 48,
                                                      width: 48,
                                                      radius: 20,
                                                      name: directMessage.name != "" ? directMessage.name : directMessage.displayName,
                                                      isRound: true,
                                                      isAvatar: true
                                                    ) : SizedBox(
                                                      width: 48,
                                                      height: 48,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Color(((directMessage.id.hashCode + 1) * pi * 0.1 * 0xFFFFFF).toInt()).withOpacity(1.0),
                                                          borderRadius: BorderRadius.circular(30)
                                                        ),
                                                        child: Icon(
                                                          Icons.group,
                                                          size: 16,
                                                          color: Colors.white
                                                        ),
                                                      ),
                                                    )
                                                  : CachedAvatar(
                                                    // avatar of people
                                                    getAvatarUrl(directMessage.user),
                                                    height: 48,
                                                    width: 48,
                                                    radius: 20,
                                                    name: directMessage.name != "" ? directMessage.name : directMessage.displayName,
                                                    isAvatar: true
                                                  ),
                                                 directMessage.user.where((element) => element["user_id"] != userId && (element["is_online"] ?? false)).toList().length > 0 ? Positioned(
                                                  bottom: 0, right: 0,
                                                  child: Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(6),
                                                      color: directMessageSelected.id != "" && directMessageSelected.id == directMessage.id
                                                        ? isDark ? Color(0xff393D41) : Color(0xffF5F5F5)
                                                        : isDark ? Color(0xff2E2E2E) : Colors.white,
                                                    ),
                                                    padding: EdgeInsets.all(2),
                                                    child: Container(
                                                      width: 8,
                                                      height: 8,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(4),
                                                        color: Color(0xff73d13d),
                                                      ),
                                                    ),
                                                  )
                                                ) : SizedBox()
                                              ],
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 20.0),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: MediaQuery.of(context).size.width - 230,
                                                      child: RichText(
                                                        maxLines: 1,
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: directMessage.name != "" ? directMessage.name : directMessage.displayName,
                                                              style: TextStyle(
                                                                fontSize: 15.5,
                                                                overflow: TextOverflow.ellipsis,
                                                                color: isDark ? Color(0xFFffffff): Color(0xff3D3D3D),
                                                                fontWeight: FontWeight.w500
                                                              )
                                                            ),
                                                            TextSpan(
                                                              text: directMessage.user.length == 1 ? " (me)" : "",
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                color: isDark ? Color(0xFFffffff): Color(0xff3D3D3D),
                                                              )
                                                            )
                                                          ]
                                                        ),
                                                      )
                                                    ),
                                                    SizedBox(height: 2,),
                                                    userSnippet != null && userSnippet["full_name"] != "" ? Container(
                                                      constraints:BoxConstraints(maxHeight: 20),
                                                      child: userSnippet == null
                                                        ? Container()
                                                        : Row(
                                                          children: [
                                                            userSnippet["user_id"] == userId 
                                                            ? Container(
                                                              margin: EdgeInsets.only(right: 2, top: 2.5),
                                                              child: Icon(
                                                                  PhosphorIcons.arrowElbowDownRight,
                                                                  color: isDark ? Color(0xffC9C9C9) :  Color(0xFF828282),
                                                                  size: 12,
                                                                ),
                                                            )
                                                            : directMessage.user.length == 2 
                                                              ? Container()
                                                              : Text((userSnippet["full_name"]).trim().toString().split(" ").first + ": ", style: TextStyle(
                                                                // tin chuwa docj snippet mau trang, 
                                                                // color: (userRead.indexWhere((element) => element == userId) == -1) ? Color(0xffF5F7FA) : Color(0xFF616E7C) ,
                                                                color: (userRead.indexWhere((element) => element == userId) == -1) ? Color(isDark? 0xffEDEDED : 0xff3D3D3D) : Color(0xffA6A6A6),
                                                                fontSize: 13, height: 1.68
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Utils.checkedTypeEmpty(numberType["mention"]) 
                                                              ? Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(top: 1.8),
                                                                      child: Text(
                                                                        numberType["mention"] ?? directMessage.snippet["message"],
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                          color: (userRead.indexWhere((element) => element == userId) == -1) ? Color(isDark? 0xffEDEDED : 0xff3D3D3D) : Color(0xffA6A6A6), fontSize: 13,height: 1.41),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ) 
                                                              :Row(
                                                                children: [
                                                                  Utils.checkedTypeEmpty(numberType["share"]  ?? numberType["shareforwar"]) ?
                                                                  Container() :
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 4),
                                                                    child: rendericon(
                                                                      numberType["video"] ?? 0, 
                                                                      numberType["other"] ?? 0, 
                                                                      numberType["image"] ?? 0, 
                                                                      numberType["attachment"] ?? 0, 
                                                                      (userRead.indexWhere((element) => element == userId) == -1) ? Color(isDark ? 0xffEDEDED : 0xff3D3D3D) : Color(0xffA6A6A6) 
                                                                    ),
                                                                  ),
                                                                  Utils.checkedTypeEmpty(numberType["share"]  ?? numberType["shareforwar"]) ?
                                                                  Expanded(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(top: 4),
                                                                      child: Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child: Text(
                                                                              numberType["share"] ?? numberType["shareforwar"] ?? directMessage.snippet["message"],
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(
                                                                                color: (userRead.indexWhere((element) => element == userId) == -1) ? Color(isDark? 0xffEDEDED : 0xff3D3D3D) : Color(0xffA6A6A6), fontSize: 13,)
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ): 
                                                                  Expanded(
                                                                    child: Text(
                                                                      "$messageSnippet",
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: TextStyle(
                                                                        // tin chuwa docj snippet mau trang, 
                                                                        color: (userRead.indexWhere((element) => element == userId) == -1) ? Color(isDark? 0xffEDEDED : 0xff3D3D3D) : Color(0xffA6A6A6) ,
                                                                        fontSize: 13, height: 1.6
                                                                      ),
                                                                      maxLines: 1,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                            
                                                          ],
                                                        )           
                                                    ) : Container()
                                                  ],
                                                ),
                                              ),
                                            )]
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            SizedBox(height: 4,),
                                            renderUserRead(
                                              directMessage.seen,
                                              directMessage.user, 
                                              userId, 
                                              userRead,
                                              "$currentTime",
                                              lastUserIdSendMessage ?? "",
                                              isDark
                                            ),
                                            ShowTime(time: directMessage.updateByMessageTime)
                                          ]
                                        )
                                      ]
                                    ),
                                    current != null && (current.dataUnreadThread).length > 0 ? Container(
                                      margin: EdgeInsets.only(left: 48, top: 5, bottom: 0),
                                      child: Row(
                                        children: [
                                          Icon(PhosphorIcons.chat, color: Color(0xFFA6AB6A), size:14),
                                          Container(width: 8,),
                                          Text("New thread", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Color(0xFFA6AB6A)),),
                                        ],
                                      )) : Container(),                     
                                  ],
                                )
                              ),
                              // Divider(
                              //   height: 0.2,
                              //   thickness: 0.1,
                              //   indent: 90.0,
                              //   color: Color.fromARGB(255, 120, 120, 120),
                              // ),
                            ],
                          )
                        )
                      ),
                    );
                  }).toList(),
                  (isFetching ? shimmerEffect(context, number: 1) : Container())
                  ]
                )
              ),
            ),
          ) : Flexible(
            child: Container(
                // color: Colors.red,
                color: auth.theme == ThemeType.DARK ? Color(0xff2E2E2E) : Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(16, 5, 16, 5),
                        height: 38,
                        child: CupertinoTextField(
                          controller: _controller,
                          focusNode: node,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
                          ),
                          onChanged: _onChangeText,
                          padding: EdgeInsets.only(left: 8, right: 8),
                          clearButtonMode: OverlayVisibilityMode.editing,
                          prefix: Container(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(PhosphorIcons.magnifyingGlass, size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E))
                          ),
                          placeholder: "Search",
                          placeholderStyle: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),
                          style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 14),
                        ),
                      ),
                      Material(
                        child: Column(
                          children: (streamResults["data"] ?? []).map<Widget>((e) => InkWell(
                            onTap: () async {
                              var res = await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(auth.token, e["conversation_id"]);
                              if (!res) return;
                              var directMessage = Provider.of<DirectMessage>(context, listen: false).getModelConversation(e["conversation_id"]);
                              if (directMessage == null) return;
                              Provider.of<DirectMessage>(context, listen: false).setSelectedDM(directMessage, auth.token);
                              Provider.of<DirectMessage>(context, listen: false).resetOneConversation(directMessage.id);
                              Provider.of<DirectMessage>(context, listen: false).getMessageFromHiveDown(directMessage.id, DateTime.now().microsecondsSinceEpoch, auth.token, auth.userId, isGetIsarBeforeCallApi: true, limit: 20);
                              // can lay tin nhan local len truon trong khi goi api
                              Provider.of<DirectMessage>(context, listen: false).getMessageFromApiDown(directMessage.id, true, auth.token, auth.userId);
                              channel.push(event: "join_direct", payload: {"direct_id": directMessage.id});
                              if (node.hasPrimaryFocus) node.unfocus();
                              widget.changePageView(1);
                            },
                            child: Container(
                              margin: EdgeInsets.all(8),
                              child: Container(
                                child: Row(
                                  children: [
                                    e["number_users"] > 2 ? SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(((e["number_users"] + 1) * pi * 0.1 * 0xFFFFFF).toInt()).withOpacity(1.0),
                                          borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: Icon(
                                          Icons.group,
                                          size: 16,
                                          color: Colors.white
                                        ),
                                      ),
                                    ) : CachedAvatar(
                                              // avatar of people
                                      e["avatar_url"],
                                      height: 36,
                                      width: 36,
                                      radius: 20,
                                      name: e["full_name"] ??e["name"] ?? "",
                                      isAvatar: true
                                    ),
                                    Container(width: 8,),
                                    Expanded(child: Text(e["full_name"] ??e["name"] ?? "", style: TextStyle(overflow: TextOverflow.ellipsis,)))
                                  ],
                                ),
                              )
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  )
                ),
              ),
          ),
        ]
      )
    );
  }
  
  Widget rendericon(int video, int other ,int image, int attachment , Color color) {
    if (video >= 1 && other == 0 && image == 0 && attachment == 0 ){
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(PhosphorIcons.youtubeLogo, size: 13, color: color,),
      );
    }
    if (video == 0 && other >= 1 && image == 0 && attachment == 0 ){
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(PhosphorIcons.folderOpen,size: 13, color: color,),
      );
    }
    if (video == 0 && other == 0 && image >= 1 && attachment == 0 ){
      return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(PhosphorIcons.image,size: 13, color: color,),
      );
    } 
    if (video == 0 && other == 0 && image == 0 && attachment >= 1 ) 
     return Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Icon(PhosphorIcons.chatCenteredDots,size: 13, color: color,),
      );
    if (video == 0 && other == 0 && image == 0 && attachment == 0 ) return Container();

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(PhosphorIcons.folderOpen,size: 13 , color: color,),
    );
  }
}

showCreateDM(context) {
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    builder: (BuildContext context) {
      return CreateDirectMessage();
    }
  );
}

// showSearchBar(context) {
//   showModalBottomSheet(
//     isScrollControlled: true,
//     enableDrag: true,
//     context: context,
//     builder: (BuildContext context) {
//       return SearchBarNavigation();
//     }
//   );
// }

class ThreadIcon extends StatelessWidget {
  const ThreadIcon({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final auth = Provider.of<Auth>(context, listen: false);
    // final isDark = auth.theme == ThemeType.DARK;
    var threadProvider = Provider.of<ThreadUserProvider>(context, listen: true);
    return Container(
      height: 50,
      padding: EdgeInsets.only(right: 8, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
                return ThreadConversation();
              }));
            },
            child: Stack(
              children: [
                Center(child: Icon(PhosphorIcons.chatsCircleFill, size: 18,)),
                threadProvider.countUnreadThread > 0 ? Positioned(
                  right: 0,
                  top: 13,
                  child: Container(
                    padding: EdgeInsets.only(right: 8),
                    decoration:  BoxDecoration( 
                      color: Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(4))
                    ),
                    width: 8, height:  8, ),
                ) : Container()
              ],
            )
          ),
        ],
      ),
    );
  }
}