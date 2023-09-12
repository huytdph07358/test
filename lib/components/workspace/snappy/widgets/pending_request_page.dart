import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/themes.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

import 'animation_dialog.dart';
import 'type.dart';

class PendingRequestPage extends StatefulWidget {
  final DateTime month;
  final List records;
  final Function(PendingRequestPageState state)? onReview;
  const PendingRequestPage({Key? key, this.records = const [], required this.month, this.onReview}) : super(key: key);

  @override
  State<PendingRequestPage> createState() => PendingRequestPageState();
}

class PendingRequestPageState extends State<PendingRequestPage> {
  int tab = 0;
  List records = [];
  updateState(records) {
    setState(() {
      this.records = records;
    });
  }
  _reviewFormTimesheets(formId, status, date, senderId, reason, overtime, token) async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final workspaceId = Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"];

    final url = Utils.apiUrl + 'workspaces/$workspaceId/check_approve_form?token=$token';
    try {
      await Dio().post(url, data: json.encode({
        "success": status,
        "is_approved": true,
        "sender_id": senderId,
        'form_id': formId,
        'reason': reason,
      }));
    } catch (e, trace) {
      print("Error Channel: $trace");
    }
  }

  List get _pending => this.records.where((e) => !e["is_approved"]).toList();
  List get _accepted => this.records.where((e) => e["is_approved"] && e["success"]).toList();
  List get _denied => this.records.where((e) => e["is_approved"] && !e["success"]).toList();
  @override
  void initState() {
    super.initState();
    records = widget.records;
  }
  @override
  Widget build(BuildContext context) {
    final auth = context.read<Auth>();
    final isDark = auth.theme == ThemeType.DARK;
    List records = tab == 0 ? _pending : tab == 1 ?  _accepted : _denied;
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
      return InkWell(
        onTap: () => tab != 0 ? null : {
          showCupertinoDialog(
            barrierDismissible: true,
            context: context, 
            builder: (_) {
              return RequestConfirmDialog(
                information: "${request["full_name"]}: ${formTypeToFormTypeString[type]}",
                onAccepted: () async {
                  await _reviewFormTimesheets(request["id"], true, request["date"], request["user_id"], request["reason"], request["overtime"], auth.token);
                  widget.onReview?.call(this);
                },
                onDenied: () async {
                  await _reviewFormTimesheets(request["id"], false, request["date"], request["user_id"], request["reason"], request["overtime"], auth.token);
                  widget.onReview?.call(this);
                },
              );
            }
          )
        },
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CachedAvatar(request["avatar_url"], name: request["full_name"], width: 30, height: 30),
                  SizedBox(width: 10),
                  Text(request["full_name"]),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formTypeToFormTypeString[type]!, style: TextStyle(fontSize: 17)),
                  Text(DateFormat("kk:mm").format(DateTime.parse(request["inserted_at"])), style: TextStyle(fontSize: 12, color: Colors.grey))
                ],
              ),
              Divider(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("LÝ DO", style: TextStyle(color: Colors.grey)),
                          Flexible(child: Text(request["reason"])),
                        ],
                      ),
                    )
                  ],
                )
              ),
            ],
          ),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context), 
                    icon: Icon(Icons.arrow_back)
                  ),
                  Text("Manage Requests", style: TextStyle(fontSize: 27)),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  widgetTab(0, "Pending", _pending),
                  widgetTab(1, "Accepted", _accepted),
                  widgetTab(2, "Denied", _denied)
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
          ),
        ),
      ),
    );
  }
}
