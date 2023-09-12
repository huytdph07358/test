import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/themes.dart';
import 'package:workcake/models/models.dart';

import 'animation_dialog.dart';
import 'type.dart';

class MyRequestPage extends StatefulWidget {
  final DateTime month;
  final List myRequest;
  final List accepted;
  final List denied;
  const MyRequestPage({Key? key, required this.month, this.myRequest = const [], this.accepted = const [], this.denied = const []}) : super(key: key);

  @override
  State<MyRequestPage> createState() => _MyRequestPageState();
}

class _MyRequestPageState extends State<MyRequestPage> {
  int tab = 0;
  List myRequest = [];
  List accepted = [];
  List denied = [];
  @override
  void initState() {
    super.initState();
    myRequest = widget.myRequest;
    accepted = widget.accepted;
    denied = widget.denied;
  }
  @override
  Widget build(BuildContext context) {
    final auth = context.read<Auth>();
    final isDark = auth.theme == ThemeType.DARK;
    List records = tab == 0 ? myRequest : tab == 1 ? accepted : denied;
    Widget widgetTab(int tab, String tabName, List data) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            border: this.tab == tab ? Border(bottom: BorderSide(width: 2.0, color: Colors.green)) : null
          ),
          child: TextButton(
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(this.tab == tab ? Colors.green : isDark ? Colors.white : Colors.black)
            ),
            onPressed: () => setState(() => this.tab = tab), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("$tabName"),
                Container(
                  width: 21,
                  height: 21,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tab == 0 ? Colors.red.shade100 : tab == 1 ? Colors.green.shade100 : Colors.red.shade100,
                  ),
                  child: Center(child: Text('${data.length}', style: TextStyle(color: Colors.black, fontSize: 10))),
                ),
              ],
            )
          ),
        ),
      );
    }
    Widget widgetRequest(Map request) {
      final type = request["type"] != null ?  FormType.values[request["type"]] : null;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 10,
            color: Colors.black.withOpacity(0.1)
          )]
        ),
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("Người duyệt", style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 20),
                      Text(request["approver_full_name"]),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formTypeToFormTypeString[type]!, style: TextStyle(fontSize: 17, color: Colors.blue)),
                      Text(DateFormat("kk:mm").format(DateTime.parse(request["inserted_at"])), style: TextStyle(fontSize: 12, color: Colors.grey))
                    ],
                  ),
                  Divider(),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (request["date"] != null) Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("NGÀY", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    Text(DateFormat("dd/MM/yyyy").format(DateTime.parse(request["date"]))),
                                  ],
                                ),
                              ),
                              if (request["date"] == null && request["start_time"] != null)  Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("NGÀY", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    Text(DateFormat("dd/MM/yyyy").format(DateTime.parse(request["start_time"]))),
                                  ],
                                ),
                              ),
                              if (request["start_time"] != null) Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("BẮT ĐẦU", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    Text(DateFormat("kk:mm").format(DateTime.parse(request["start_time"]))),
                                  ],
                                ),
                              ),
                              if (request["end_time"] != null) Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("KẾT THÚC", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                    Text(DateFormat("kk:mm").format(DateTime.parse(request["end_time"]))),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        if (request["reason"] != null) Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Lý do".toUpperCase(), style: TextStyle(color: Colors.grey)),
                                    Flexible(child: Text(request["reason"])),
                                  ],
                                ),
                              ),
                              if (tab == 0) Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    onPressed: () => showCupertinoDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (_) {
                                        return InformationDialog(information: "Tính năng đang được phát triển");
                                      }
                                    ),
                                    icon: Icon(Icons.delete, color: Colors.red,)
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  )
                ],
              ),
            )
          ],
        ),
      );
    }
    return Theme(
      data: (auth.theme == ThemeType.DARK
        ? Themes.darkTheme
        : Themes.lightTheme).copyWith(textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        )),
      child: Material(
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context), 
                    icon: Icon(Icons.arrow_back)
                  ),
                  Text("Manage my requests", style: TextStyle(fontSize: 27)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  widgetTab(0, "My request", myRequest),
                  widgetTab(1, "Accepted", accepted),
                  widgetTab(2, "Denied", denied)
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...records.map((e) => widgetRequest(e))
                    ],
                  ),
                ),
              )
            ],
          )
        )
      )
    );
  }
}