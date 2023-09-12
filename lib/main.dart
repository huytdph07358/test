import 'dart:ffi';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workcake/common/themes.dart';
import 'package:workcake/components/call_center/call_manager.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/media_conversation/isolate_media.dart';
import 'package:workcake/desktop/components/dialog_ui.dart';
import 'package:workcake/desktop/components/drop_zone.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/objectbox.g.dart';
import 'package:workcake/provider/thread_user.dart';
import 'package:workcake/route.dart';
import 'package:workcake/screens/home_screen/login_app.dart';
import 'package:workcake/screens/main_screen/index.dart';
import 'package:workcake/service_locator.dart';
import 'components/isar/message_conversation/service_ios.dart';
import 'data_channel_webrtc/device_socket.dart';
import 'generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/splash_screen.dart';
import 'package:hive/hive.dart';
import 'models/device_provider.dart';
import 'models/models.dart';
import 'package:device_info/device_info.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await firebaseCallBackgroundHandler(message);
}

Future<String> androidtVersion()async{
  try {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      var release = androidInfo.version.release;
      return release.trim().toString().split(".").first;
    }
    return "8";
  } catch (e) {
    return "0";
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DynamicLibrary.executable();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  HttpOverrides.global = new MyHttpOverrides();

  NetworkInterface.list(includeLoopback: false, type: InternetAddressType.any)
  .then((List<NetworkInterface> interfaces) {
    interfaces.forEach((interface) {
      interface.addresses.forEach((address) {
        Utils.checkDebugMode(address.address);
      });
    });
  });

  AppRoutes.setupRouter();
  setupServiceLocator();
  setupDialogUI();
  try {
    Utils.versionAndroid = int.parse(await androidtVersion());
  } catch (e){}
  var newDir  =  await getApplicationSupportDirectory();
  var newPath  =  newDir.path + "/pancake_chat_data1";
  Hive.init(newPath);
  Hive.registerAdapter(DirectModelAdapter());
  try {
    await Hive.openBox('direct');
    await Hive.openLazyBox("messageError");
    await Hive.openLazyBox("messageDraft");
    await Hive.openLazyBox("pairKey");
    await Hive.openLazyBox("log");
    await Hive.openBox("recentEmoji");
    await Hive.openBox('lastSelected');
    await Hive.openLazyBox("messageConversation");
    await Hive.openBox("queueMessages");
    await Hive.openBox("invitationHistory");
    await Utils.initPairKeyBox();
    var newDir = await getApplicationSupportDirectory();
    var newPath = newDir.path + "/pancake_chat_data";
    IsolateMedia.storeObjectBox = Store(getObjectBoxModel(), directory: newPath);
    MessageConversationIOSServices.box =  IsolateMedia.storeObjectBox;
    // await MessageConversationIOSServices.getObjectBox();
    Utils.getDeviceInfo();
    DeviceSocket.instance.initPanchatDeviceSocket();
    IsolateMedia.mainSendPort = await IsolateMedia.createIsolate();
    IsolateMedia.mainSendPort.send!({
       "type": "get_path",
       "path": newDir.path,
       "box_reference": IsolateMedia.storeObjectBox!.reference
     });
    Connectivity().onConnectivityChanged.listen((
      ConnectivityResult result
    ) {
      Utils.connectivityResult = result.toString().split(".").last;
    });
    if (Platform.isAndroid) await MessageConversationServices.getIsar();
  } catch (e, trace) {
    print("innitn___________________________$e :$trace");
    // await Hive.deleteFromDisk();
  }

  Utils.fetchVersionApp();

  await SentryFlutter.init(
    (options){
      options.dsn = 'https://92b82c76df6e446ebe10cdc5149cf0e4@o346845.ingest.sentry.io/6554496';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () => runApp(PancakeChat()),
  );
}

class PancakeChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => new Auth()),
        ChangeNotifierProvider(create: (_) => new Workspaces()),
        ChangeNotifierProvider(create: (_) => new Channels()),
        ChangeNotifierProvider(create: (_) => new Messages()),
        ChangeNotifierProvider(create: (_) => new DirectMessage()),
        ChangeNotifierProvider(create: (_) => new User()),
        ChangeNotifierProvider(create: (_) => new Work()),
        ChangeNotifierProvider(create: (_) => new Friend()),
        ChangeNotifierProvider(create: (_) => new Windows()),
        ChangeNotifierProvider(create: (_) => new Calls()),
        ChangeNotifierProvider(create: (_) => new ThreadUserProvider()),
        ChangeNotifierProvider(create: (_) => new Boards()),
        ChangeNotifierProvider(create: (_) => new DeviceProvider())
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => Portal(
          child: StreamBuilder(
            stream: StreamDropzone.instance.currentTheme,
            builder: (context, snapshot) {
              Utils.globalContext = context;
              auth.onChangeCurrentTheme(snapshot.data, false);
              final locale = auth.locale;
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                // navigatorKey: StackedService.navigatorKey,
                localizationsDelegates: [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
                locale: Locale(locale),
                theme: auth.theme == ThemeType.DARK
                    ? Themes.darkTheme
                    : Themes.lightTheme,
                home: auth.isAuth
                    ? MainScreen(key: Utils.globalMainScreen)
                    : FutureBuilder(
                        future: auth.tryAutoLogin(),
                        builder: (ctx, authResultSnapshot) =>
                            authResultSnapshot.connectionState == ConnectionState.waiting
                                ? SplashScreen()
                                : LoginApp()),
                onGenerateRoute: AppRoutes.router.generator
              );
            }
          ),)
      ),
    );
  }
}