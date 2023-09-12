import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/workspace/snappy/widgets/my_request_page.dart';
import 'package:workcake/models/models.dart';

class MyRequest extends StatefulWidget {
  final int workspaceId;
  final DateTime month;
  const MyRequest({Key? key, required this.workspaceId, required this.month}) : super(key: key);

  @override
  State<MyRequest> createState() => _MyRequestState();
}

class _MyRequestState extends State<MyRequest> {
  List _formRecords = [];

  List get myRequest => _formRecords.where((e) => !e["is_approved"]).toList();
  List get accepted => _formRecords.where((e) => e["is_approved"] && e["success"]).toList();
  List get denied => _formRecords.where((e) => e["is_approved"] && !e["success"]).toList();

  _getReviewFormTimesheets() async {
    final token =context.read<Auth>().token;
    final workspaceId = context.read<Workspaces>().currentWorkspace["id"];
    final userId = context.read<Auth>().userId;

    final startDate = DateFormat('yyyy-MM-dd').format(DateTime(widget.month.year, widget.month.month, 1));
    final endDate = DateFormat('yyyy-MM-dd').format(DateTime(widget.month.year, widget.month.month + 1, 0));

    var url = Utils.apiUrl + 'workspaces/$workspaceId/index_timesheets_form?token=$token&start_date=$startDate&end_date=$endDate&user_id=$userId';
    try {
      final response = await Dio().get(url);
      var dataRes = response.data;
      if (dataRes["success"]) {
        setState(() => _formRecords = List.from(dataRes["data"]));
      }
    } catch (e, trace) {
      print("Error $e: $trace");
    }
  }
  @override
  void initState() {
    super.initState();
    _getReviewFormTimesheets();
  }
  @override
  Widget build(BuildContext context) {
    final isDark = context.read<Auth>().theme == ThemeType.DARK;
    return InkWell(
      onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyRequestPage(
          month: widget.month,
          myRequest: myRequest,
          accepted: accepted,
          denied: denied,
        ))),
      child: Container(
        padding: EdgeInsets.all(10),
        height: 100,
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5)
        ),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("My Requests", style: TextStyle(fontSize: 17)),
              Row(
                children: [
                  Container(
                    alignment: Alignment.center,
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.red.shade100
                    ),
                    child: Text("${myRequest.length}")
                  ),
                  SizedBox(width: 5),
                  Container(
                    alignment: Alignment.center,
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.green.shade100
                    ),
                    child: Text("${accepted.length}")
                  ),
                  SizedBox(width: 5),
                  Container(
                    alignment: Alignment.center,
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.red.shade100
                    ),
                    child: Text("${denied.length}")
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}