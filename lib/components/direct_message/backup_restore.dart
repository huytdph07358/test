import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/media_conversation/drive_api.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';
import '../../screens/profile_screen/setting.dart';

class BackupAndRestoreDM extends StatefulWidget {
  const BackupAndRestoreDM({Key? key}) : super(key: key);

  @override
  State<BackupAndRestoreDM> createState() => _BackupAndRestoreDMState();
}

class _BackupAndRestoreDMState extends State<BackupAndRestoreDM> {

  bool isLoginedGD = false;

  @override
  void initState(){
    super.initState();
    checkLoginDrive();
  }

  void checkLoginDrive() async {
    isLoginedGD = await DriveService.checkIsSigned();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff2E2E2E) : Colors.white,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        highlightColor: Colors.transparent,
                        onTap: () => { 
                          Navigator.of(context).pop()
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Icon(PhosphorIcons.arrowLeft, size: 20, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          "Backup and restore DM",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )
                        ),
                      ),
                      Container(
                        width: 40,
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  if (Provider.of<DirectMessage>(context, listen: false).errorCode != null) return;
                  showDialog(
                    context: context,
                    builder: (BuildContext b) => DailogBackUp()

                  );
                  await Future.delayed(Duration(milliseconds: 300));
                  if (!MessageConversationServices.isBackUping){
                    MessageConversationServices.makeBackUpMessageJsonV1(await MessageConversationServices.getAllConversationIds(), Provider.of<Auth>(context, listen: false).userId);
                  }
                },
                child: Opacity(
                  opacity: Provider.of<DirectMessage>(context, listen: false).errorCode != null ? 0.5 : 1,
                  child: Container(
                    height: 51,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.3, color: Colors.grey)
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.cloudArrowUp, size: 18),
                              SizedBox(width: 8),
                              Text(S.current.backupDM, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
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

              InkWell(
                onTap: () async {
                  if (Provider.of<DirectMessage>(context, listen: false).errorCode != null) return;
                  showDialog(
                    context: context,
                    builder: (BuildContext b) => DailogRestore()
                  );
                  MessageConversationServices.reStoreBackUpFile(Provider.of<Auth>(context, listen: false).userId);
                },
                child: Opacity(
                  opacity: Provider.of<DirectMessage>(context, listen: false).errorCode != null ? 0.5 : 1,
                  child: Container(
                    height: 51,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.3, color: Colors.grey)
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.cloudArrowDown, size: 18),
                              SizedBox(width: 8),
                              Text(S.current.restoreDM, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
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

              InkWell(
                onTap: () async {
                  DriveService.login();
                },
                child: Opacity(
                  opacity: Provider.of<DirectMessage>(context, listen: false).errorCode != null ? 0.5 : 1,
                  child: Container(
                    height: 51,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.3, color: Colors.grey)
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Icon(PhosphorIcons.googleLogo, size: 18),
                              SizedBox(width: 8),
                              Text("Google Drive", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Switch(value: isLoginedGD, onChanged: (bool value) async {
                                if (isLoginedGD) {
                                  await DriveService.logout();
                                  checkLoginDrive();
                                } else {
                                  await DriveService.login();
                                  checkLoginDrive();
                                }
                              })
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
        )
      ),
    );
  }
}