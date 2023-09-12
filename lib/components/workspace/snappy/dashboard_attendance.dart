import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:date_picker_timeline/extra/style.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:workcake/components/workspace/snappy/widgets/checkinout_button.dart';
import 'package:workcake/components/workspace/snappy/widgets/my_request.dart';
import 'package:workcake/models/models.dart';

import 'widgets/pending_request.dart';


class DashboardAttendance extends StatefulWidget {
  const DashboardAttendance({Key? key}) : super(key: key);

  @override
  State<DashboardAttendance> createState() => _DashboardAttendanceState();
}

class _DashboardAttendanceState extends State<DashboardAttendance> {
  // TimesheetDataSource _events = TimesheetDataSource([]);
  int statusAttendance = 0;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final isDark = context.read<Auth>().theme == ThemeType.DARK;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DatePicker(
            now.subtract(Duration(days: now.weekday - 1)),
            height: 80,
            initialSelectedDate: now,
            selectedTextColor: Colors.green,
            monthTextStyle: isDark ? defaultMonthTextStyle.copyWith(color: Colors.white) : defaultMonthTextStyle,
            dayTextStyle: isDark ? defaultDayTextStyle.copyWith(color: Colors.white) : defaultDayTextStyle,
            dateTextStyle: isDark ? defaultDateTextStyle.copyWith(color: Colors.white) : defaultDateTextStyle,
            daysCount: 7,
          ),
          CheckinOutButton(workspaceId: currentWorkspace["id"]),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Folder", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(child: PendingRequest(workspaceId: currentWorkspace["id"], month: now)),
                      SizedBox(width: 10),
                      Expanded(child: MyRequest(workspaceId:  currentWorkspace["id"], month: now))
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}