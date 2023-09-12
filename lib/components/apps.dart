import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/themes.dart';
import 'package:workcake/components/workspace/snappy/dashboard_attendance.dart';
import 'package:workcake/models/auth_model.dart';

class Apps extends StatefulWidget {
  const Apps({ Key? key, required this.app }) : super(key: key);
  final app;
  @override
  _AppsState createState() => _AppsState();
}

class _AppsState extends State<Apps> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
   
    return Theme(
      data: (auth.theme == ThemeType.DARK
        ? Themes.darkTheme
        : Themes.lightTheme).copyWith(textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        )),
      child: Scaffold(
        backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: Container(
            color: isDark ? Color(0xff3D3D3D) : Color.fromARGB(255, 255, 255, 255),
            child: Column(
              children: [
                Container(
                  height: 62,
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
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            width: 60,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          child: Text(
                            "${widget.app["name"]}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )
                          ),
                        ),
                        Container(
                          width: 60,
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: widget.app["id"] == 13 ? DashboardAttendance() : Center(
                    child: Text("This feature under development"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}