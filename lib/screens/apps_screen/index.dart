import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/route_animation.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/app_detail.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';

class AppsScreen extends StatefulWidget {
  AppsScreen();
  @override
  _AppsScreenState createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  List dataApps = [];
  @override
  void initState() {
    super.initState();
    Timer.run(() async {
      final token = Provider.of<Auth>(context, listen: false).token;
      // get list Apps of user
      getListApps(token);
    });
  }

  getListApps(token) async {
    String url = "${Utils.apiUrl}app?token=$token";
    try {
      var response = await Dio().get(url);

      var resData = response.data;
      setState(() {
        dataApps = resData["data"];
      });
    } catch (e) {}
  }

  onSuccessCreateApp(app) {
    setState(() {
      dataApps = [app] + dataApps;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        bottom: false,
        child: Scaffold(
            backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
            appBar: AppBar(
              backgroundColor: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
              ),
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(PhosphorIcons.arrowLeft)),
              title: Text(S.current.appLists, style: TextStyle(fontSize: 17),),
            ),
            body: Container(
              color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark? Color(0xFF2E2E2E): Color(0xFFFFFFFF),
                        border: Border(top:BorderSide(width: 0.75, color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                        )
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: dataApps.map((app) {
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: isDark? Color(0xFF2E2E2E): Color(0xFFFFFFFF),
                              border: Border(bottom:BorderSide(width: 0.75, color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)),
                              )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).push(createRoute(AppDetail(appId: null,)));
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      height: 35,
                                      width: 35,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1890FF),
                                        borderRadius:BorderRadius.circular(5)),
                                      child: Text("${app["name"].substring(0, 1)}",style:TextStyle(color: Color(0xFFFFFFFF)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text("${app["name"]}",style: TextStyle(color: isDark? Color(0xFFDBDBDB): Color(0xFF2E2E2E),fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0, right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff1890FF),
                        border: Border.all(
                          color: Color(0xff1890FF),
                          width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                      ),
                      height: 40,
                      margin: EdgeInsets.all(20),
                      child: TextButton(
                      onPressed: (){showCreateApps(context, onSuccessCreateApp);},
                      child: Text(S.current.addApps,style: TextStyle(color: Color(0xffffffff)),),
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}

showCreateApps(context, onSuccessCreateApp) {
  onSave(appName) async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final url = "${Utils.apiUrl}app?token=$token";
    try {
      var response = await Dio().post(url, data: {"name": appName});

      var resData = response.data;
      if (resData["success"]) {
        onSuccessCreateApp(resData["data"]);
        Navigator.of(context, rootNavigator: true).pop("Discard");
      }
    } catch (e) {
      print(e);
    }
  }

  showDialog(
      context: context,
      builder: (context) {
        return CustomDialog(
          title: "CREATE APP",
          textDisplay: '',
          onSaveString: onSave,
        );
      });
}

// showInfoApp(context, appId) {
//   showModalBottomSheet(
//       isScrollControlled: true,
//       enableDrag: true,
//       context: context,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
//       backgroundColor: Color(0xFF2e3235),
//       builder: (BuildContext context) {
//         return AppDetail(appId: null,
         
//         );
//       });
// }
