import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:hive/hive.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/bottom_sheet_server.dart';
import 'package:workcake/components/call_center/call_manager.dart';
import 'package:workcake/components/thread_view.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/keep_alive_page.dart';
import 'package:workcake/components/notification.dart';
import 'package:workcake/file_share/file_share.dart';
import 'package:workcake/file_share/view_share_to.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/provider/thread_user.dart';
import 'package:workcake/screens/conversation.dart';
import 'package:workcake/screens/dashboard.dart';
import 'package:workcake/screens/message.dart';
import 'package:workcake/service_locator.dart';
import 'package:workcake/services/internet_connection.dart';
import 'package:workcake/services/sharedprefsutil.dart';

class MainScreen extends StatefulWidget {

  MainScreen({Key? key}): super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  PageController pageController = PageController(
    initialPage: 0,
  );
  int page = 0;
  bool loaded = false;
  var subscriptionNetwork;
  PanelController panelController = PanelController();

  // Luu lai thong tin tu thong bao
  Map? dataNoti;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{
    final token = Provider.of<Auth>(context, listen: false).token;
    Provider.of<Auth>(context, listen: false).checkSocket();
    Provider.of<Auth>(context, listen: false).focusApp(state == AppLifecycleState.resumed);
    if (state == AppLifecycleState.resumed){
      // Connectivity().checkConnectivity() tron 1 so truong hop tra ve null du dang ket noi wifi => dung await InternetAddress.lookup('google.com.vn') de check internet lusc nay
      final channelSelected = Provider.of<Channels>(context, listen: false).currentChannel;
      if (channelSelected["id"] != null) {
        Provider.of<Messages>(context, listen: false).loadMoreMessages(token, channelSelected["workspace_id"], channelSelected["id"], isReset: true);
      }
      StreamStatusConnection.checkConnection();
    }
  }

  @override
  void initState() {
    Utils.checkUpdateApp(context);
    final token = Provider.of<Auth>(context, listen: false).token;
    Box box = Hive.box('direct');
    super.initState();
    final userId = Provider.of<Auth>(context, listen: false).userId;
    Timer.run(() async {
      StreamStatusConnection.instance.setConnectionStatus(await Connectivity().checkConnectivity() != ConnectivityResult.none);
      subscriptionNetwork = Connectivity().onConnectivityChanged.listen((state) {
        StreamStatusConnection.checkConnection();
      });
      MessageConversationServices.saveSharedKeyToNative([]);
      List keys = box.keys.where((element) => element is String).toList();
      List<DirectModel> d = keys.map<DirectModel>((e) => box.get(e)).toList();
      await Provider.of<DirectMessage>(context, listen: false).setData(d, currentUserId: Provider.of<Auth>(context, listen: false).userId);
      var remote = await FirebaseMessaging.instance.getInitialMessage();
      // case danh rieng cho thong bao ko phai message(request sync data)
      if (remote != null && remote.data["type"] == "request_sync_data"){
        Provider.of<DirectMessage>(context, listen: false).checkDeviceRequestSyncDataFromNotification(remote.data,  Provider.of<Auth>(context, listen: false).token, context);
      } else if (remote != null && remote.data["type"] == "check_in") {
        final workspaceId = remote.data["workspace_id"];
        final shiftId = remote.data["shift_id"];
        Provider.of<Workspaces>(context, listen: false).handleCheckin(context, workspaceId, shiftId);
      } else if (remote != null && remote.data["type"] == "check_out") {
        final workspaceId = remote.data["workspace_id"];
        final shiftId = remote.data["shift_id"];
        Provider.of<Workspaces>(context, listen: false).handleCheckout(context, workspaceId, shiftId);
      }
      if (Platform.isIOS){
        if (remote != null){
          var dataN = remote.data;
          dataNoti  = {
            "channelId":  dataN["channel_id"],
            "conversationId":  dataN["conversation_id"],
            "issueId":  dataN["issue_id"],
            "workspaceId": dataN["workspace_id"],
            "groupId":  dataN["groupId"],
            "threadId":  dataN["parent_message_id"]
          };
        }
      } else {
        try {
          var dataFromNative = await Work.platform.invokeMethod("initialLink");
          Map dataNative = jsonDecode(dataFromNative);
          if (dataNative["type"] == "data_notification"){
            // save data
            LazyBox box = Hive.lazyBox('log');
            box.add({
              "data": dataNative["data"],
              "time": DateTime.now().toString()
            });
            Map dataN = jsonDecode(dataNative["data"]);
            dataNoti = {
              "channelId":  dataN["channel_id"],
              "conversationId":  dataN["conversation_id"],
              "issueId":  dataN["issue_id"],
              "workspaceId": dataN["workspace_id"],
              "groupId":  dataN["groupId"],
              "threadId":  dataN["parent_message_id"]
            };
          } else {
            FileShare.instance.setFileFromNative(dataNative["files"]);
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) {
                  return ViewShareTo();
                }
              )
            );
          }
        } catch (e, t) {
          print("dataNative error $e $t");
        }
      }

      var snapshot = await Hive.openBox("snapshotData_$userId");
      Provider.of<Workspaces>(context, listen: false).setData(snapshot.get("workspaces") ?? []);
      Provider.of<Channels>(context, listen: false).setDataChannels(snapshot.get("channels") ?? []);

      if (dataNoti == null) {
        goToLastChannel();
      } else {
        onClickNoti(dataNoti);
      }

      Provider.of<Auth>(context, listen: false).connectSocket(context, userId, {},(){});

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data["type"] != null && message.data["type"] == "request_sync_data"){
          Provider.of<DirectMessage>(context, listen: false).checkDeviceRequestSyncDataFromNotification(message.data,  Provider.of<Auth>(context, listen: false).token, context);
        } else if (message.data["type"] != null && message.data["type"] == "check_in") {
          final workspaceId = message.data["workspace_id"];
          final shiftId = message.data["shift_id"];
          Provider.of<Workspaces>(context, listen: false).handleCheckin(context, workspaceId, shiftId);
        } else if (message.data["type"] != null && message.data["type"] == "check_out") {
          final workspaceId = message.data["workspace_id"];
          final shiftId = message.data["shift_id"];
          Provider.of<Workspaces>(context, listen: false).handleCheckout(context, workspaceId, shiftId);
        } else {
          var dataN = message.data;
          onClickNoti( {
            "channelId":  dataN["channel_id"],
            "conversationId":  dataN["conversation_id"],
            "issueId":  dataN["issue_id"],
            "workspaceId": dataN["workspace_id"],
            "groupId":  dataN["groupId"],
            "threadId":  dataN["parent_message_id"]
          });
        }
      });

      Provider.of<DirectMessage>(context, listen: false).getDataDirectMessage(token, userId, isReset: true);
      WidgetsBinding.instance.addObserver(this);
      ////////////////////////////////////////
      //////////Handle event android///////////
      /// ////////////////////////////////////////
      Work.eventChannelStream.listen((event) {
        if (event== "null" || event ==  null) return;
        try {
          Map data = jsonDecode(event);
          switch (data["type"]) {
            case "data_notification":
              Map dataN = jsonDecode(data["data"]);
              Map dataParse = {
                "channelId":  dataN["channel_id"],
                "conversationId":  dataN["conversation_id"],
                "issueId":  dataN["issue_id"],
                "workspaceId": dataN["workspace_id"],
                "groupId":  dataN["groupId"],
                "threadId":  dataN["parent_message_id"]
              };
              onClickNoti(dataParse, dataMessage: dataN["data_message"] == null ? null : {
                ...(dataN["data_message"]),
                "avatar_url": dataN["avatar_url"],
                "full_name": dataN["full_name"],
                "time_create": DateTime.now().toString(),
                "current_time": DateTime.now().microsecondsSinceEpoch
              });
              break;
            case "intent_action_send": 
              //  hien tai chi ho tro share files. tat ca cac case con lai deu ko xu ly
              FileShare.instance.setFileFromNative(data["files"]);
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ViewShareTo();
                  },
                )
              );
              break;
            default:
          } 
        } catch (e, trace) {
          // goToLastChannel();
          print("receiveBroadcastStream$e $trace");
        }
      });
      //////////////////////////////////////////////////
      /// //////////////////////////////////////////////////
      var boxKey  = Hive.lazyBox("pairKey");
      var deviceId = await boxKey.get('deviceId');
      var identityKey = await boxKey.get("identityKey");
      var signedKey  = await boxKey.get("signedKey");
      // gen new Curve25519
      if (deviceId == null || identityKey ==  null ||  signedKey == null) {
        Provider.of<Auth>(context, listen: false).logout();
        Provider.of<Channels>(context, listen: false).deleteDevicesToken(token);
        Provider.of<Channels>(context, listen: false).deleteApnsToken(token);
      } else {
        await Utils.uploadDeviceInfo(token);
      }
    });
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    if(subscriptionNetwork != null) subscriptionNetwork.cancel();
    super.dispose();
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

  Future checkAndRemoveOldPush() async {
    await Utils.checkAndRemoveOldPush();
  }

  onClickNoti(Map? payload, {Map? dataMessage}) async {
    if(Utils.stickerEmojiWidgetState.currentState != null) {
      final BuildContext? stickerContext = Utils.stickerEmojiWidgetState.currentContext;

      if(stickerContext != null) {
        Navigator.pop(stickerContext);
      }
    }

    try {
      // payload: chua thong tin co ban nhu convId, ..
      // dataMessage:  chua cac thong tin rong how
      var auth = Provider.of<Auth>(context, listen: false);
      if(payload == null) return;
      pageController.jumpToPage(0);
      if (Utils.checkedTypeEmpty(payload["conversationId"])){
        final hasConv = await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(auth.token, payload["conversationId"]);
        final dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(payload["conversationId"]);
        if (dm == null) return;
        Provider.of<Workspaces>(context, listen: false).tab = 0;

        if (hasConv) {
          if (!Utils.checkedTypeEmpty(Provider.of<DirectMessage>(context, listen: false).errorCode)){
            Provider.of<DirectMessage>(context, listen: false).setSelectedDM(dm, payload["conversationId"]);
            Provider.of<Workspaces>(context, listen: false).setTab(0);

            if (Utils.checkedTypeEmpty(payload["threadId"])){
              await checkAndRemoveOldPush();
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
                return ThreadView(
                  key: Utils.globalKeyPush,
                  isChannel: false,
                  idMessage: payload["threadId"],
                  keyDB: "keyDB",
                  idConversation: payload["conversationId"]
                );
              }));
            } else {
              Timer.run(() async {
                await Future.delayed(Duration(seconds: 2));
                Provider.of<Auth>(context, listen: false).channel.push(
                  event: "join_direct",
                  payload: {"direct_id": payload["conversationId"]}
                );
              });
              await Provider.of<DirectMessage>(context, listen: false).getMessageFromHiveDown(dm.id, DateTime.now().microsecondsSinceEpoch, auth.token, auth.userId, isGetIsarBeforeCallApi: true, limit: 20);
              Provider.of<DirectMessage>(context, listen: false).setSelectedDM(dm, auth.token);
              Provider.of<DirectMessage>(context, listen: false).getMessageFromApiDown(dm.id, true, auth.token, auth.userId);
              await checkAndRemoveOldPush();
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
                return Message(
                  key: Utils.globalKeyPush,
                  dataDirectMessage: dm,
                  id: dm.id,
                  name: "",
                  avatarUrl: "",
                  isNavigator: true,
                  // panelController: panelController
                );
              }));
            }
          }
        }
      } else {
        // final token = Provider.of<Auth>(context, listen: false).token;
        int workspaceId = int.parse("${payload["workspaceId"]}");
        int channelId = int.parse("${payload["channelId"]}");
        // Provider.of<Channels>(context, listen: false).onChangeLastChannel(workspaceId, channelId);
        // Provider.of<Channels>(context, listen: false).selectChannel(token, workspaceId, channelId);
        onSelectWorkspace(workspaceId, channelId, threadId: payload["threadId"]);


        if (Utils.checkedTypeEmpty(payload["threadId"])){
          await checkAndRemoveOldPush();
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
            return ThreadView(
              key: Utils.globalKeyPush,
              isChannel: true,
              idMessage: payload["threadId"],
              keyDB: "keyDB",
              channelId: channelId,
            );
          }));
        } else {
          Timer.run(() async {
            try {
              await Future.delayed(Duration(seconds: 2));
              Provider.of<Auth>(context, listen: false).channel.push(
                event: "join_channel",
                payload: {
                  "channel_id": int.parse(payload["channelId"]), 
                  "workspace_id": int.parse(payload["workspaceId"]),
                  "ssid": NetworkInfo().getWifiName()
                }
              );
            } catch (e) {
              print("_____rejoinnnn: $e");
            }
          });
          Provider.of<Workspaces>(context, listen: false).setTab(workspaceId);
          // bat buoc goi API de lay data moi nhat
          Provider.of<Messages>(context, listen: false).loadMoreMessages(auth.token, int.parse("${payload["workspaceId"]}"), int.parse("${payload["channelId"]}"), isReset: true);
          await checkAndRemoveOldPush();
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
            return Conversation(key: Utils.globalKeyPush, id: payload["channelId"], hideInput: true, changePageView: changePageView, isNavigator: true, );
          }));
        }
      }

      Work.platform.invokeMethod("clear_notification", {
        "group_id": payload["groupId"].toString()
      });
    } catch (e, t) {
      print("onClickNoti ${e.toString()} $t");
    }
  }

  goToLastChannel() async {
    if (dataNoti != null) return;
    try {
      var box = Hive.box('lastSelected');
      var lastConversationId = box.get('lastConversationId');
      var lastChannelId = box.get('lastChannelId');
      var isChannel = box.get('isChannel');
      var lastChannelSelected = box.get("lastChannelSelected");
      Provider.of<Channels>(context, listen: false).setLastChannelFromHive(lastChannelSelected ?? []);
      final auth = Provider.of<Auth>(context, listen: false);
      final channels = Provider.of<Channels>(context, listen: false).data;

      if (isChannel == 1) {
        int index = channels.indexWhere((e) => e["id"] == lastChannelId);

        if (index != -1) {
          final channel = channels[index];
          final workspaceId = channel["workspace_id"];

          Provider.of<Workspaces>(context, listen: false).tab = workspaceId;
          onSelectWorkspace(workspaceId, lastChannelId);
        } else {
          final listDataDirect = Provider.of<DirectMessage>(context, listen: false).data;
          Provider.of<Workspaces>(context, listen: false).tab = 0;
  
          if (listDataDirect.length > 0) {
            if (!Utils.checkedTypeEmpty(Provider.of<DirectMessage>(context, listen: false).errorCode)){
              pageController.jumpToPage(0);
              Provider.of<DirectMessage>(context, listen: false).setSelectedDM(listDataDirect[0], auth.token);
            }
          }
        }
      } else {
        Provider.of<Workspaces>(context, listen: false).tab = 0;
        var hasConversation = await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(auth.token, lastConversationId);
        if (!Utils.checkedTypeEmpty(Provider.of<DirectMessage>(context, listen: false).errorCode) && hasConversation){
          onSelectDirectMessages(lastConversationId);
        } else {
          final listDataDirect = Provider.of<DirectMessage>(context, listen: false).data;
          Provider.of<DirectMessage>(context, listen: false).setSelectedDM(listDataDirect[0], auth.token);
        }
      }
      
      this.setState(() { loaded = true; });
    } catch (e) {
       this.setState(() { loaded = true; });

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
      print('User granted permission');
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

  onSelectDirectMessages(directId) async {
    final auth = Provider.of<Auth>(context, listen: false);
    final listDataDirect = Provider.of<DirectMessage>(context, listen: false).data;
    final index = listDataDirect.indexWhere((ele) => ele.id == directId);

    if (index != -1) {
      Provider.of<DirectMessage>(context, listen: false).onChangeSelectedFriend(false);
      if (auth.channel != null) auth.channel.push(event: "join_direct", payload: {"direct_id": directId});
      Provider.of<DirectMessage>(context, listen: false).setSelectedDM(listDataDirect[index], auth.token);
      Provider.of<DirectMessage>(context, listen: false).getMessageFromApiDown(directId, true, auth.token, auth.userId);
    } else {
      final listDataDirect = Provider.of<DirectMessage>(context, listen: false).data;
      Provider.of<Workspaces>(context, listen: false).tab = 0;

      if (listDataDirect.length > 0) {
        Provider.of<DirectMessage>(context, listen: false).setSelectedDM(listDataDirect[0], auth.token);
        auth.channel.push(event: "join_direct", payload: {"direct_id": listDataDirect[0].id});
      }
    }
  }

  onSelectWorkspace(workspaceId, channelId, {threadId}) async {
    final auth = Provider.of<Auth>(context, listen: false);
    if (threadId != null) {
      await Provider.of<ThreadUserProvider>(context, listen: false).updateThreadUnread(workspaceId, channelId, {"id": threadId}, auth.token);
    }
    Provider.of<ThreadUserProvider>(context, listen: false).getThreadWorkspace(workspaceId, auth.token, isReset: true);
    
    selectWorkspace(auth.token, workspaceId, channelId);
    saveFirebaseToken(workspaceId);
  }

  selectWorkspace(token, workspaceId, channelId) async {
    final auth = Provider.of<Auth>(context, listen: false);
    Provider.of<Workspaces>(context, listen: false).selectWorkspace(auth.token, workspaceId, context);
    Provider.of<Workspaces>(context, listen: false).getInfoWorkspace(token, workspaceId, context);
    // final channels = Provider.of<Channels>(context, listen: false).data;
    // final lastChannelSelected = Provider.of<Channels>(context, listen: false).lastChannelSelected;
    // int index = lastChannelSelected.indexWhere((e) => e["workspace_id"] == workspaceId);
    // List workspaceChannels = channels.where((e) => "${e["workspace_id"]}" == "$workspaceId").toList();
    final userId = Provider.of<Auth>(context, listen: false).userId;

    // if (workspaceChannels.length > 0) {
      // channel_id la duoc truyen vao lan dau tien khi mo app
      // cac lan tiep theo la truyen null => lay tu lastChannelSelected
      // var channelSelectedWorkspaces= Provider.of<Channels>(context, listen: false).lastChannelSelected;
      // var indexChannelSelectedId = channelSelectedWorkspaces.indexWhere((element) => element["workspace_id"] == workspaceId);
      // var channelSelectedId = indexChannelSelectedId == -1 ? channelId : channelSelectedWorkspaces[indexChannelSelectedId]["channel_id"];
      // final indexChannel = workspaceChannels.indexWhere((e) => e["id"] == channelSelectedId);
      // final channel = indexChannel != -1 ? workspaceChannels[indexChannel] : null ;
    Provider.of<Workspaces>(context, listen: false).tab = workspaceId;

    if (channelId != null) {
      Provider.of<Channels>(context, listen: false).setCurrentChannel(channelId);
      Provider.of<Channels>(context, listen: false).loadCommandChannel(token, workspaceId, channelId);
      Provider.of<Channels>(context, listen: false).selectChannel(token, workspaceId, channelId);
      Provider.of<Messages>(context, listen: false).loadMessages(token, workspaceId, channelId);
      // if (index == -1) {
      Provider.of<Channels>(context, listen: false).onChangeLastChannel(workspaceId, channelId);
      // }
      Provider.of<Channels>(context, listen: false).getChannelMemberInfo(auth.token, workspaceId, channelId, userId);
    } else {
      Provider.of<Channels>(context, listen: false).setNullCurrentChannel();
    }
    // }
  }

  changePageView(page) {
    pageController.animateToPage(page, curve: Curves.ease, duration: Duration(milliseconds: 300));
    if(panelController.isAttached) {
      panelController.show();
    }
    if (FocusScope.of(context).hasFocus) FocusScope.of(context).unfocus();
  }


  Widget _rightSideConversation() {
    final auth = Provider.of<Auth>(context);
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final indexMenu = Provider.of<Auth>(context, listen: false).currentMenuIndex;
    final directMessage = Provider.of<DirectMessage>(context, listen: true).directMessageSelected;
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xff2e3235) : Colors.white,
      ),
      child: indexMenu == 0 ? directMessage.id != ""
        ? Message(
          dataDirectMessage: directMessage,
          id: directMessage.id,
          name: directMessage.displayName,
          avatarUrl: "",
          changePageView: changePageView,
          panelController: panelController
        )
        : Container()
      : currentChannel["id"] != null
        ? Conversation(id: currentChannel["id"], hideInput: true, changePageView: changePageView,  panelController: panelController,) 
        : Container(),
    );
  }

  _onWillPop() {
    if (pageController.page == 1) {
      changePageView(0);
      
    } else {
      MoveToBackground.moveTaskToBack();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final auth = Provider.of<Auth>(context, listen: false);
    final isHomePage = Provider.of<Auth>(context, listen: false).currentMenuIndex;

    final directMessage = Provider.of<DirectMessage>(context, listen: true).directMessageSelected;
    final channel = Provider.of<Channels>(context, listen: true).currentChannel;
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Stack(
        children: [
          PageView(
            physics: isHomePage == 1 || isHomePage == 0 ? CustomPageViewScrollPhysics() : NeverScrollableScrollPhysics(),
            onPageChanged: (page) {
              Provider.of<Workspaces>(context, listen: false).page = page;
              if (page == 1 && Provider.of<Workspaces>(context, listen: false).tab == 0) {
              //  danh dau da doc khi chuyen sang page 1
                Provider.of<DirectMessage>(context, listen: false).markReadConversationV2(auth.token, Provider.of<DirectMessage>(context, listen: false).directMessageSelected.id, [], [], true);
              }
              if (page != 1 && FocusScope.of(context).hasFocus) {
                FocusScope.of(context).unfocus();
                Provider.of<Messages>(context, listen: false).openConversation(false);
              } else {
                Provider.of<Messages>(context, listen: false).openConversation(true);
              }
            },
            controller: pageController,
            children: [
              KeepAlivePage(
                child: DashboardScreen(
                  changePageView: changePageView,
                ),
              ),
              if((directMessage.id != "" && isHomePage == 0) || (channel["id"] != null && isHomePage == 1)) KeepAlivePage(child: _rightSideConversation()),
            ]
          ),
          Notifications(changePageView: changePageView)
        ]
      )
    );
  }

  @override
  bool get wantKeepAlive => true;
}

showBottomSheet(context) {
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    builder: (BuildContext context) {
      return BottomSheetWorkspace();
    }
  );
}


class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 80,
    stiffness: 100,
    damping: 1,
  );
}
