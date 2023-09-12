import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/components/direct_message/backup_restore.dart';
import 'package:workcake/components/direct_message/dm_setting_auto_download.dart';
import 'package:workcake/data_channel_webrtc/list_device.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/apps_screen/index.dart';
import '../../components/channel/change_language.dart';
import '../../components/isar/message_conversation/service.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool androidAutoDownload = false;
  PanelController panelController = PanelController();
  void initState() {
    super.initState();
    Timer.run(() async {
      var box = Hive.lazyBox('pairKey');
      androidAutoDownload = (await box.get("android_auto_download")) ?? false;
      final auth = Provider.of<Auth>(context, listen: false);
      await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
    });
  }
languages(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Container(
          width: 240,
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: ChangeLanguage()
        ),
      );
    }
  );
}
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    final currentUser = Provider.of<User>(context, listen: true).currentUser;

    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          backgroundColor: isDark ? Color(0xff2E2E2E) : Colors.white,
          body: Container(
            child: Column(
              children: [
                Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff2E2E2E) : Colors.white,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED))
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(Icons.arrow_back)
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          child: Text(
                            S.current.settings,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: isDark ? Color(0xff2E2E2E) : Colors.white,
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.only( bottom: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 20, left: 12, bottom: 10),
                                  child: Text("General", style: TextStyle(fontSize: 16, color: Color(0xff949494)),),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          languages(context);
                                        },
                                        child: Container(
                                          height: 48,
                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Icon(PhosphorIcons.globeHemisphereEast, size: 18),
                                                    SizedBox(width: 8),
                                                    Text(S.current.languages, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 8),
                                                    Text('${currentUser["locale"] == "en" ? "English" : "Vietnamese"}', style: TextStyle(fontSize: 14, color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E)))
                                                  ],
                                                ),
                                              )
                                            ],
                                          )
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                        color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                                        height: 1,
                                      ),
                                      Container(
                                        height: 48,
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  Icon(PhosphorIcons.moon, size: 18),
                                                  SizedBox(width: 8),
                                                  Text( S.current.darkMode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              child: Row(
                                                children: [
                                                  FlutterSwitch(
                                                    width: 44,
                                                    height: 24,
                                                    toggleSize: 20,
                                                    value: isDark,
                                                    padding: 2,
                                                    onToggle: (value) {
                                                      if(value) {
                                                        Provider.of<Auth>(context, listen: false).theme = ThemeType.DARK;
                                                        Provider.of<User>(context, listen: false).updateTheme(auth.token, "dark");
                                                      } else {
                                                        Provider.of<Auth>(context, listen: false).theme = ThemeType.LIGHT;
                                                        Provider.of<User>(context, listen: false).updateTheme(auth.token, "light");
                                                      }
                                                    },
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        )
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20, left: 12, bottom: 10),
                                  child: Text(S.current.devices, style: TextStyle(fontSize: 16, color: Color(0xff949494)),),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  child: Column(
                                    children: [
                                      SettingAutoDownloadDm.fontSettingAutoDownload(context),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                        color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                                        height: 1,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => AppsScreen())
                                          );
                                        },
                                        child: Container(
                                          height: 48,
                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Icon(PhosphorIcons.squaresFour, size: 18),
                                                    SizedBox(width: 8),
                                                    Text("Apps", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                                                  ],
                                                ),
                                              )
                                            ],
                                          )
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                        color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                                        height: 1,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => ListDevices())
                                          );
                                        },
                                        child: Opacity(
                                          opacity: Provider.of<DirectMessage>(context, listen: false).errorCode != null ? 0.5 : 1,
                                          child: Container(
                                            height: 48,
                                            padding: EdgeInsets.symmetric(horizontal: 16),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(width: 2, color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED))
                                              )
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Icon(PhosphorIcons.deviceMobile, size: 18),
                                                      SizedBox(width: 8),
                                                      Text(S.current.devices, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(horizontal: 10),
                                        color: isDark ? Color(0xff4C4C4C) : Color(0xffDBDBDB),
                                        height: 1,
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => BackupAndRestoreDM())
                                          );
                                        },
                                        child: Opacity(
                                          opacity: Provider.of<DirectMessage>(context, listen: false).errorCode != null ? 0.5 : 1,
                                          child: Container(
                                            height: 48,
                                            padding: EdgeInsets.symmetric(horizontal: 16),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Icon(PhosphorIcons.cloudArrowUp, size: 18),
                                                      SizedBox(width: 8),
                                                      Text("Backup and restore DM", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ),
                  ),
                ),
                Platform.isIOS ? InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext c){
                        return CustomDialogNew(
                          title: S.current.alert, 
                          content: S.current.doYouWantToDeleteYourAccount,
                          confirmText: S.current.delete,
                          onConfirmClick: () async{
                            Provider.of<Auth>(context, listen: false).deleteAccount();
                            Navigator.pop(context);
                        }
                      );
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 40),
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Color(0xffFF7875)
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Icon(Icons.delete_outlined, size: 21, color: Color(0xffFF7875)),
                              SizedBox(width: 6),
                              Text(S.current.deleteAccount, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffFF7875) : Color(0xffEB5757))),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),
                ) : Container(),
              ],
            ),
          )
          // : SplashScreen(),
        ),
      ),
    );
  }
}

showCustomDialog(context, type) {
  final currentUser = Provider.of<User>(context, listen: false).currentUser;
  final auth = Provider.of<Auth>(context, listen: false);

  String nickname = currentUser["full_name"] != null ? currentUser["full_name"] : "";
  String phone = currentUser["phone_number"] != null ? currentUser["phone_number"] : "";
  String title = type == 1 ? "CHANGE NICKNAME" : "CHANGE PHONE NUMBER";

  String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
  RegExp regExp = new RegExp(pattern);

  onChangeProfile(value) async {
    if (value != "") {
      Map user = new Map.from(currentUser);

      if (type == 1) {
        if (value.length < 3 || value.length > 20) {

        } else {
          user["full_name"] = value;
          await Provider.of<User>(context, listen: false).changeProfileInfo(auth.token, user);
          await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
        }
      } else {
        if (!regExp.hasMatch(value)) {

        } else {
          user["phone_number"] = value;
          await Provider.of<User>(context, listen: false).changeProfileInfo(auth.token, user);
          await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
        }
      }

      Navigator.of(context, rootNavigator: true).pop("Discard");
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialog(title: title, textDisplay: type == 1 ? nickname : phone, onSaveString: onChangeProfile);
    }
  );
}
class DailogBackUp extends StatefulWidget {
  const DailogBackUp({ Key? key,  }) : super(key: key);

  @override
  State<DailogBackUp> createState() => _DailogBackUpState();
}

class _DailogBackUpState extends State<DailogBackUp> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 100, width: 100,
        // color: Colors.red,
        child: StreamBuilder(
          initialData: StatusBackUp(100, "Starting up"),
          stream: MessageConversationServices.statusBackUp,
          builder: (context, snapshot){
            StatusBackUp data  = snapshot.data == null ?  StatusBackUp(100, "Starting up") : ((snapshot.data) as StatusBackUp);
            return Container(
              child: Center(
                child: Text(data.status),
              )
            );
          }
        ),
      ),
    );
  }
}

class DailogRestore extends StatefulWidget {
  const DailogRestore({ Key? key,  }) : super(key: key);

  @override
  State<DailogRestore> createState() => _DailogRestoreState();
}

class _DailogRestoreState extends State<DailogRestore> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 100, width: 100,
        // color: Colors.red,
        child: StreamBuilder(
          initialData: StatusRestore(100, "Starting up"),
          stream: MessageConversationServices.statusRestore,
          builder: (context, snapshot){
            StatusRestore data  = snapshot.data == null ?  StatusRestore(100, "Starting up") : ((snapshot.data) as StatusRestore);
            return Container(
              child: Center(
                child: Text(data.status),
              )
            );
          }
        ),
      ),
    );
  }
}