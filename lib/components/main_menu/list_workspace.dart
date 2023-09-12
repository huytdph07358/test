import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/auth_model.dart';
import 'package:workcake/models/channels_model.dart';
import 'package:workcake/models/direct_messages_model.dart';

import '../../common/cached_image.dart';
import '../../common/utils.dart';
import '../../generated/l10n.dart';
import '../../models/messages_model.dart';
import '../../models/users_model.dart';
import '../../models/workspaces_model.dart';
import '../../provider/thread_user.dart';
import '../../service_locator.dart';
import '../../services/sharedprefsutil.dart';
import '../call_center/call_manager.dart';
import '../custom_dialog_new.dart';

class ListWorksapce extends StatefulWidget {


  @override
  State<ListWorksapce> createState() => _ListWorksapceState();
}

class _ListWorksapceState extends State<ListWorksapce> {

  checkNewBadgeCount(context) {
    final channels = Provider.of<Channels>(context, listen: false).data;
    final data = Provider.of<DirectMessage>(context, listen: false).data;
    int count = 0;

    for (var c in channels) {
      if (c["new_message_count"] != null) {
        if (c["new_message_count"] is int) {
          count += int.parse(c["new_message_count"].toString());
        } else {
          count += int.parse(c["new_message_count"]);
        }
      }
    }

    for (var d in data) {
      if (d.newMessageCount != null) {
        if (d.newMessageCount is int) {
          count += int.parse(d.newMessageCount.toString());
        } else {
          count += int.parse(d.newMessageCount);
        }
      }
    }

    return count;
  }
  
  selectWorkspace(token, workspaceId, channelId) async {
    final auth = Provider.of<Auth>(context, listen: false);
    await Provider.of<Workspaces>(context, listen: false).selectWorkspace(auth.token, workspaceId, context);
    Provider.of<Workspaces>(context, listen: false).getInfoWorkspace(token, workspaceId, context);
    final channels = Provider.of<Channels>(context, listen: false).data;
    final lastChannelSelected = Provider.of<Channels>(context, listen: false).lastChannelSelected;
    int index = lastChannelSelected.indexWhere((e) => e["workspace_id"] == workspaceId);
    List workspaceChannels = channels.where((e) => e["workspace_id"] == workspaceId).toList();
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    if (workspaceChannels.length > 0) {
      Provider.of<ThreadUserProvider>(context, listen: false).getThreadWorkspace(workspaceId, auth.token, isReset: true);
      // channel_id la duoc truyen vao lan dau tien khi mo app
      // cac lan tiep theo la truyen null => lay tu lastChannelSelected
      var channelSelectedWorkspaces= Provider.of<Channels>(context, listen: false).lastChannelSelected;
      var indexChannelSelectedId = channelSelectedWorkspaces.indexWhere((element) => element["workspace_id"] == workspaceId);
      var channelSelectedId = indexChannelSelectedId == -1 ? channelId : channelSelectedWorkspaces[indexChannelSelectedId]["channel_id"];
      final indexChannel = workspaceChannels.indexWhere((e) => e["id"] == channelSelectedId);
      final channel = indexChannel != -1 ? workspaceChannels[indexChannel] : workspaceChannels[0] ;
      Provider.of<Workspaces>(context, listen: false).tab = workspaceId;

      if (channel != null) {
        auth.channel.push(
          event: "join_channel",
          payload: {"channel_id": channel['id'], "workspace_id":workspaceId, "ssid": NetworkInfo().getWifiName()}
        );

        Provider.of<Channels>(context, listen: false).setCurrentChannel(channel['id']);
        Provider.of<Channels>(context, listen: false).loadCommandChannel(token, workspaceId, channel['id']);
        Provider.of<Channels>(context, listen: false).selectChannel(token, workspaceId, channel['id']);
        Provider.of<Messages>(context, listen: false).loadMessages(token, workspaceId, channel['id']);

        if (index == -1) {
          Provider.of<Channels>(context, listen: false).onChangeLastChannel(workspaceId, channel['id']);
        }

        await Provider.of<Channels>(context, listen: false).getChannelMemberInfo(auth.token, workspaceId, channel['id'], currentUser["id"]);
      }
    }
  }

  saveFirebaseToken(id) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      FlutterAppBadger.updateBadgeCount(checkNewBadgeCount(context));
    });

    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      sound: true, badge: true, alert: true, provisional: true
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission 1');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    final accessToken = Provider.of<Auth>(context, listen: false).token;

    FirebaseMessaging.instance.getToken().then((String? token) async {
      assert(token != null);
      sl.get<SharedPrefsUtil>().setFirebaseToken(token);
      String os = Platform.operatingSystem;

      await Provider.of<Channels>(context, listen: false).addDevicesToken(accessToken, id, token, os);
    });
    String? apnsToken = callManager.getApnsToken();
    if(apnsToken != null) await Provider.of<Channels>(context, listen: false).addApnsToken(accessToken, id, apnsToken);
  }

  checkWorkspaceStatus(workspaceId) {
    bool check = true;
    final channels = Provider.of<Channels>(context, listen: true).data;
    List workspaceChannels = channels.where((e) => e["workspace_id"] == workspaceId).toList();

    for (var c in workspaceChannels) {
      if (c["seen"] != null && c["seen"] == false) {
        if (c["new_message_count"] != null && c["new_message_count"] > 0) {
          check = false;
        }
      }
    }

    return check;
  }

  checkNewMessage(workspaceId) {
    bool check = false;
    final channels = Provider.of<Channels>(context, listen: true).data;
    List workspaceChannels = channels.where((e) => e["workspace_id"] == workspaceId).toList();

    for (var c in workspaceChannels) {
      if (!Utils.checkedTypeEmpty(c["seen"]) && c["status_notify"] != "OFF" && (c["status_notify"] != "MENTION" || (c["status_notify"] == "MENTION" && (c["new_message_count"] != null && c["new_message_count"] > 0)))) {
        check = true;
      }
    }

    return check;
  }

    // checkDirectStatus() {
  Widget avatarName(currentTab, id, { String name = "" }) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: currentTab == id ? Color.fromARGB(255, 28, 28, 28) : isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "",
          style: TextStyle(
            color: currentTab == id || isDark ? Colors.white : Color(0xff5E5E5E),
            fontSize: 20.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isHover = false;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final data = Provider.of<Workspaces>(context).data;
    final currentTab = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    return SafeArea(
      bottom: false,
      child: Drawer(
        elevation: 100.0,
        width: MediaQuery.of(context).size.width * 0.85,
        child: Container(
          color: isDark ? Color(0xff2E2E2E) : Color(0xffFFFFFF),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 16),
                Container(
                  margin: EdgeInsets.only(left: 14),
                  width:  MediaQuery.of(context).size.width,
                  child: Text(S.current.workspace, style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.w700),)),
                SizedBox(height: 16),
                Column(
                  children: data.map((item) =>
                    Stack(
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context);
                                selectWorkspace(auth.token, item["id"], null);
                                saveFirebaseToken(item["id"]);
                                FocusScope.of(context).unfocus();
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: currentTab["id"] == item["id"] ? isDark ? Color(0xff444444): Color(0xffEDEDED) : Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            item['avatar_url'] == "" || item['avatar_url'] == null ?
                                            avatarName(currentTab, item['id'], name: item['name']) :
                                            Center(
                                              child: CachedImage(
                                                item['avatar_url'],
                                                width: 35,
                                                height: 35,
                                                radius: 8,
                                              ),
                                            ),
                                            checkWorkspaceStatus(item["id"]) ?
                                            Positioned(child: Container(),) 
                                            : Positioned( 
                                              top: -1.0,
                                              right: -1.0,
                                              child: new Icon(Icons.brightness_1, size: 13.0,
                                                color: Colors.redAccent),
                                            )
                                          ],
                                        ),
                                        SizedBox(width: 10,),
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context).size.width * 2/3.4
                                          ),
                                          child: Text(
                                            "${item["name"] ?? ""}",
                                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: currentTab["id"] == item["id"] || isHover || checkNewMessage(item["id"]) ? 2 : 0,
                                      height: 48,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8)
                          ],
                        ),
                      ]
                    ),
                  ).toList(),
                ),
                InkWell(
                  onTap: () async {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return CustomDialog(
                          action: "Join or create a workspace",
                          title: "Join or create a workspace",
                        );
                      }
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(width: 4,),
                      Container(
                        width: 35,
                        height: 35,
                        margin: EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        child: Icon(PhosphorIcons.plusBold, size: 20, color: Color(0xff1890FF)),
                      ),
                      Container(width: 10,),
                      Container(
                        width: MediaQuery.of(context).size.width * 2/3,
                        child: Text("${S.current.newworkspace} / ${S.current.joinWorkspace}", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)), overflow: TextOverflow.ellipsis,)),
                      Container(width: 4,)
                    ],
                  )
                ),
                SizedBox(height: 35,)
              ]
            ),
          ),
        ),
      ),
    );
  }
}
