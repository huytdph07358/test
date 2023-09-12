import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

import '../extension.dart';

class CheckinOutButton extends StatefulWidget {
  final workspaceId;
  final Function()? onPressed;
  const CheckinOutButton({Key? key, this.workspaceId, this.onPressed}) : super(key: key);

  @override
  State<CheckinOutButton> createState() => _CheckinOutButtonState();
}

class _CheckinOutButtonState extends State<CheckinOutButton> {
  List shiftsAttendance = [{"shift_id": null, "status": 0}];
  Map currentShift = {};
  bool loading = true;

  Future _getStatusAttendanceToday(BuildContext context, int workspaceId) async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final url = Utils.apiUrl + 'workspaces/$workspaceId/get_status_attendance_today_v2?token=$token';
    try {
      final response = await Dio().get(url);
      var dataRes = response.data;
      return dataRes["listshift_today"];
    } catch (e) {
      print(e);
    }
  }
  Future<void> _onHandleCheckIn() async {
    final token = Provider.of<Auth>(context, listen: false).token;
    setState(() => loading = true);

    final preCheckinResult = await context.read<Workspaces>().sendPreCheckin(widget.workspaceId, token);
    if (preCheckinResult["success"]) {
      context.showLoadingDialog();
      final checkinResult = await context.read<Workspaces>().sendCheckin(widget.workspaceId, currentShift["shift_id"], token);
      Navigator.pop(context);
      if (checkinResult["success"]) {
        _reloadStatusAttendanceToday();
        context.showDialogWithSuccess(checkinResult["message"]);
      } else {
        setState(() => loading = false);
        context.showDialogWithFailure(checkinResult["message"]);
      }
    } else {
      setState(() => loading = false);
      context.showDialogWithFailure(preCheckinResult["message"]);
    }
  }
  Future<void> _showModalCheckOut(BuildContext context) async {

    await context.showActionDialog(
      action: () => _onHandleCheckOut(),
      actionText: 'Checkout',
      message: "Xác nhận checkout?", 
    );
  }
  Future<void> _onHandleCheckOut() async {
    Navigator.of(context).pop();
    final token = context.read<Auth>().token;

    final checkoutResult = await context.read<Workspaces>().sendCheckout(widget.workspaceId, currentShift["shift_id"], token);

    if (checkoutResult["success"]) {
      _reloadStatusAttendanceToday();
      context.showDialogWithSuccess(checkoutResult["message"]);
    } else {
      setState(() => loading = false);
      context.showDialogWithFailure(checkoutResult["message"]);
    }
  }
  _reloadStatusAttendanceToday() async {
    final currentWorkspace = context.read<Workspaces>().currentWorkspace;
    await _getStatusAttendanceToday(
      context, 
      currentWorkspace["id"]
    ).then((value) => setState(() {
      loading = false;
      shiftsAttendance = value;
      currentShift = shiftsAttendance.first;
    }));
  }

  void executeOnMinute(void Function() callback) {
    var now = DateTime.now();
    var nextMinute = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    Timer(nextMinute.difference(now), () {
      Timer.periodic(const Duration(minutes: 1), (timer) {
        callback();
      });
      callback();
    });
  }
  @override
  void initState() {
    super.initState();
    _reloadStatusAttendanceToday();
    currentShift = shiftsAttendance.first;
    
    executeOnMinute(() {
      if (this.mounted) setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(currentShift["status"] == 0 ? Colors.green.shade400 : currentShift["status"] == 1 ? Colors.red : Colors.grey),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))
      ),
      onPressed: loading ? null : () async {
        if (currentShift["status"] == 0) await _onHandleCheckIn();
        else if (currentShift["status"] == 1) await _showModalCheckOut(context);
      }, 
      child: Container(
        width: double.infinity, 
        height: 70,
        padding: EdgeInsets.all(10),
        child: loading ? Center(child: Text("Loading", style: TextStyle(fontSize: 20))) : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(currentShift["status"] == 0 ? "Check in" : currentShift["status"] == 1 ? "Check out" : "Complete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 24)),
                Expanded(
                  child: Row(
                    children: [
                      Text(DateFormat('kk:mm').format(DateTime.now()), style: TextStyle(color: Colors.white)),
                      InkWell(
                        onTap: shiftsAttendance.length > 1 ? () async {
                          await context.showCustomDialog(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ...shiftsAttendance.map((e) => TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      currentShift = e;
                                    });
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width * 3/4,
                                    child: Text(e["shift_name"], style: TextStyle(color: Colors.white),)
                                  )
                                ))
                              ],
                            )
                          );
                        } : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            // color: Colors.green.shade200,
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(currentShift["shift_id"] != null ? currentShift["shift_name"]: "CA KHONG XAC DINH", style: TextStyle(color: Colors.white)),
                                if (shiftsAttendance.length > 1) Icon(Icons.arrow_drop_down_outlined, color: Colors.white,)
                              ],
                            )
                          )
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white
              ),
              child: Icon(Icons.fingerprint, size: 30, color: Colors.black),
            )
          ],
        )
      )
    );
  }
}