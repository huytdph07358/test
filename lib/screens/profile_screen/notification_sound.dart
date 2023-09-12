import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

class NotificationAndSouund extends StatefulWidget {
  const NotificationAndSouund({ Key? key }) : super(key: key);

  @override
  _NotificationAndSouundState createState() => _NotificationAndSouundState();
}

class _NotificationAndSouundState extends State<NotificationAndSouund> {

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    final auth = Provider.of<Auth>(context, listen: true);
    final token = auth.token;
    final isDark = auth.theme == ThemeType.DARK;
    final offSendingSoundStatus = currentUser["off_sending_sound_status"];
    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: Container(
            color: isDark ? Colors.transparent : Color(0xffEDEDED),
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
                            "Notification & Sound",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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
                        padding: EdgeInsets.only(top: 5, bottom: 30),
                        child: Column(
                          children: [
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
                                        Icon(PhosphorIcons.speakerSimpleSlash, size: 18),
                                        SizedBox(width: 8),
                                        Text( "Turn off the message sending sound", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
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
                                          value: offSendingSoundStatus,
                                          padding: 2,
                                          onToggle: (value) async {
                                            currentUser["off_sending_sound_status"] = value;
                                            final res = await Provider.of<User>(context, listen: false).changeProfileInfo(token, currentUser);
                                            if(res["success"] != true) {
                                              print("error while changing sending sound status $res");
                                              currentUser["off_sending_sound_status"] = !value;
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
                    ),
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}