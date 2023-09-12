import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/call_center/call_manager.dart';
import 'package:workcake/components/keep_alive_page.dart';
import 'package:workcake/components/main_menu/right_direct_messages.dart';
import 'package:workcake/components/main_menu/right_server_details.dart';
import 'package:workcake/components/search_bar_navigation.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/provider/thread_user.dart';
import 'package:workcake/screens/mentions_screen/recent_mentions.dart';
import 'package:workcake/screens/profile_screen/index.dart';
import 'package:workcake/service_locator.dart';
import 'package:workcake/services/internet_connection.dart';
import 'package:workcake/services/sharedprefsutil.dart';

import '../common/route_animation.dart';
import '../components/main_menu/list_workspace.dart';
import '../components/workspace/workspace_settings.dart';
import '../generated/l10n.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key, this.changePageView}) : super(key: key);

  final changePageView;

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _pageController;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<Auth>(context, listen: false);
    final token = Provider.of<Auth>(context, listen: false).token;
    Provider.of<User>(context, listen: false).fetchAndGetMe(token);
    _pageController = PageController(initialPage: auth.currentMenuIndex );
    Timer.run(()async {
      Provider.of<User>(context, listen: false).fetchUserMentionInDirect(token);
      // await _initImages();
    });
  }

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
  Widget _rightSider() {
    final auth = Provider.of<Auth>(context);

    return SafeArea(
      child: Container(
        width: (MediaQuery.of(context).size.width ),
        decoration: BoxDecoration(
          color: auth.theme == ThemeType.DARK ? Color(0xff2E2E2E) : Colors.white,
          border: Border(top: BorderSide(color: auth.theme == ThemeType.DARK ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
        ),
        child: Column(
          children: [
            StatusConnectionView(),
            Expanded(
              child: RightServerDetails(changePageView: widget.changePageView)
            ),
          ],
        ),
      ),
    );
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  Widget avatarName( id, { String name = "" }) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "",
          style: TextStyle(
            color: isDark ? Colors.white : Color(0xff5E5E5E),
            fontSize: 20.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWorkspaceId = Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"];
    final isDark = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final indexMenu = Provider.of<Auth>(context, listen: false).currentMenuIndex;
    // var numberUnSeenMention = Provider.of<DirectMessage>(context, listen: true).dataMentionConversations.numberUnseen;
    return Scaffold(
      drawer: indexMenu == 1 ? ListWorksapce() : null,
      key: _scaffoldKey,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: <Widget>[
                PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: onPageChanged,
                  children: <Widget>[
                    KeepAlivePage(
                      child: SafeArea(
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 65.0),
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xff2E2E2E) : Colors.white,
                          ),
                          child: Column(
                            children: [
                              StatusConnectionView(),
                              Expanded(
                                child: RightDirectMessages(changePageView: widget.changePageView)
                              ),
                            ],
                          ),
                        ),
                      )
                    ),
                    KeepAlivePage(
                      child: SafeArea(
                        child: Scaffold(
                          body: Column(
                            children: [
                              Container(
                                height: 62,
                                decoration: BoxDecoration(
                                  color: isDark ? Color(0xff2E2E2E) : Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          height: 62,
                                          padding: EdgeInsets.only(left: 16,top: 4),
                                          child: InkWell(
                                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                                            onTap: () {
                                              _openDrawer();
                                            },
                                            child: Row(
                                              children: [
                                                currentWorkspace["avatar_url"] != "" && currentWorkspace["avatar_url"] != null
                                                ? CachedImage(currentWorkspace["avatar_url"],
                                                radius: 4, width: 35, height: 35)
                                                : avatarName( currentWorkspace['id'], name: currentWorkspace["name"] ?? ''),
                                              ],
                                            ), 
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        InkWell(
                                          onTap: () {
                                            _openDrawer();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.only(top: 14,bottom: 10,right: 20 ),
                                            child: Text(
                                              "${currentWorkspace["name"] ?? ""}",
                                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17.5, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E))
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 30,
                                          width: 32,
                                          margin: EdgeInsets.only(right: 10,top: 12, bottom: 8),
                                          decoration: BoxDecoration(
                                            color: isDark ? Color(0xff444444) : Color(0xffEDEDED),
                                            borderRadius: BorderRadius.circular(30)
                                          ),
                                          child: IconThreadWorkspace(key: Key("icon_thread_workspace"), workspaceId: currentWorkspace["id"],)
                                        ),
                                        InkWell(
                                          onTap: () =>  Navigator.of(context, rootNavigator: true).push(createRoute(WorkspaceSettings())),
                                          child: Container(
                                            height: 30,
                                            width: 32,
                                            margin: EdgeInsets.only(right: 10,top: 12, bottom: 8),
                                            decoration: BoxDecoration(
                                              color: isDark ? Color(0xff444444) : Color(0xffEDEDED),
                                              borderRadius: BorderRadius.circular(30)
                                            ),
                                            child: Icon(PhosphorIcons.gearSix, size: 18,)
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView(
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  children: <Widget>[
                                    _rightSider(),
                                  ]
                                ),
                              ),
                            ],
                          )
                        ),
                      )
                    ),
                    RecentMentions(),
                    KeepAlivePage(child: SearchBarNavigation2(currentWorkspaceId: currentWorkspaceId)),
                    KeepAlivePage(child: Profile())
                  ]
                )
                // FloatingNewMessage(),
              ]
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomNavigationBar(navigationTapped: navigationTapped,)
    );
  }

  void navigationTapped(int page) {
    Provider.of<Auth>(context, listen: false).setMenuIndex(page);
    _pageController.jumpToPage(page);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void onPageChanged(int page) {
    Provider.of<Auth>(context, listen: false).setMenuIndex(page);
  }
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
checkDirectStatus(context) {
  return Provider.of<DirectMessage>(context, listen: true).unreadConversation.unreadCount == 0;
}

class MyBottomNavigationBar extends StatefulWidget {
  final navigationTapped;
  const MyBottomNavigationBar({ Key? key, @required this.navigationTapped }) : super(key: key);

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}
class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    var numberUnSeenMention = Provider.of<DirectMessage>(context, listen: false).dataMentionConversations.numberUnseen;
    return Container(
      child: Container(
        height:(window.viewPadding.bottom == 0 && Platform.isIOS) ? 68 : Platform.isIOS ? 88.5 : 76.5,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9), width: 0.5)),
        ),
        child: BottomNavigationBar(
          backgroundColor: isDark ? Color(0xff2E2E2E) : Color(0xffF8F8F8),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Utils.getPrimaryColor(),
          unselectedItemColor: isDark ? Color(0xff828282) : Color(0xffA6A6A6),
          selectedFontSize: 10,
          unselectedFontSize: 10,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: InkWell(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 4,top: 4),
                      child: Icon(PhosphorIcons.chatCircleDots),
                    ),
                    !checkDirectStatus(context) ? Positioned(  // draw a red marble
                      top: 2.0,
                      right: 0.0,
                      child: new Icon(Icons.brightness_1, size: 12.0,
                        color: Colors.redAccent),
                    ) : Positioned(child: Container(),)
                  ],
                ),
              ),
              label: "DMs",
              // title: Container(
              //   padding: EdgeInsets.only(top: 3),
              //   child: Text("Home", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),)
              // )
            ),
            BottomNavigationBarItem(
              icon: Container(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4,top: 4),
                  child: Icon(PhosphorIcons.briefcase),
                ),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4,top: 4),
                child: Container(
                  child: Icon(PhosphorIcons.briefcase),
                ),
              ),
              label: "Work",
              // title: Container(
              //   padding: EdgeInsets.only(top: 3),
              //   child: Text("Home", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),)
              // )
            ),
            BottomNavigationBarItem(
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4,top: 4),
                      child: new Icon(
                        PhosphorIcons.at,
                        size: 24,
                      ),
                    ),
                  ),
                  numberUnSeenMention > 0 ? Positioned(  // draw a red marble
                    top: 2.0,
                    right: 0.0,
                    child: new Icon(Icons.brightness_1, size: 12.0,
                      color: Colors.redAccent),
                  ) : Positioned(child: Container(),)
                ],
              ),
              // ignore: deprecated_member_use
              label: S.current.mentions,
              // title: Container(
              //   padding: EdgeInsets.only(top: 3),
              //   child: Text("Mentions", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),)
              // )
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4,top: 4),
                child: Container(
                  child: new Icon(PhosphorIcons.magnifyingGlass,
                    size: 24,
                  ),
                ),
              ),
              // ignore: deprecated_member_use
              label: S.current.search,
              // title: Container(
              //   padding: EdgeInsets.only(top: 3),
              //   child: Text("Search", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),)
              // )
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.only(bottom: 4,top: 4),
                child: new Icon(
                  PhosphorIcons.user,
                  size: 24,
                ),
              ),
              // ignore: deprecated_member_use
              label: S.current.profile,
              // title: Container(
              //   padding: EdgeInsets.only(top: 3),
              //   child: Text("Profile", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),)
              // )
            ),
          ],
          onTap: (page){
            widget.navigationTapped(page);
          },
          currentIndex: auth.currentMenuIndex
        ),
      ),
    );
  }
}