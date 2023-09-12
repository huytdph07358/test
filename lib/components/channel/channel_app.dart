import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/components/channel/add_app.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';

class ChannelApp extends StatefulWidget {
  final id;

  ChannelApp({Key? key, @required this.id}) : super(key: key);

  @override
  _ChannelAppState createState() => _ChannelAppState();
}

class _ChannelAppState extends State<ChannelApp> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final appInChannels =
        Provider.of<Channels>(context, listen: true).appInChannels;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF3D3D3D) : Color(0xffEDEDED),
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10),),
            color: isDark ? Color(0xff2E2E2E) : Color(0xffffffff),
          ),
          child: Column(
            children: [
              Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: isDark ? Color(0xff2E2E2E) : Color(0xffffffff),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 50,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              PhosphorIcons.arrowLeft,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          child: Text(S.current.appLists,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              )),
                        ),
                        Container(
                          width: 30,
                          child: InkWell(
                            onTap: () {showAddAppChannel(context);},
                            child: Container(
                              margin: EdgeInsets.only(right: 12),
                              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                              child: Icon(
                                PhosphorIcons.circlesThreePlus,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Container(
                child: ListView(
                  shrinkWrap: true,
                  children: appInChannels.map((app) {
                    return Container(
                      height: 60,
                       decoration: BoxDecoration( 
                         color: isDark? Color(0xFF2E2E2E): Color(0xFFFFFFFF),
                         border: Border(bottom: BorderSide(width: 0.75, color: isDark ? Color(0xff5E5E5E): Color(0xffDBDBDB)),
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Center(
                              child: Container(
                                height: 35,
                                width: 35,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Color(0xFF1890FF),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text(
                                  "${app["app_name"].substring(0, 1)}",
                                  style:
                                      TextStyle(fontSize: 15,color: Color(0xFFFFFFFF)),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              "${app["app_name"]}",
                              style: TextStyle(fontSize: 15,
                                  color:
                                      isDark ? Color(0xFFDBDBDB) : Color(0xFF2E2E2E)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

showAddAppChannel(context) {
  showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext context) {
        return Container(child: AddApp());
      });
}
