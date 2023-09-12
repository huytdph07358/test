// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/themes.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart' hide ImageFormat;

import 'extension.dart';
import 'widgets/create_form.dart';
import 'widgets/type.dart';

class SnappyTimeSheet extends StatefulWidget {
  const SnappyTimeSheet({ Key? key }) : super(key: key);

  @override
  _SnappyTimeSheetState createState() => _SnappyTimeSheetState();
}

class _SnappyTimeSheetState extends State<SnappyTimeSheet> {

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final currentWs =  Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final currentMember = Provider.of<Workspaces>(context, listen: false).currentMember;
    return Scaffold(
      backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: Color(0xff02E2E2E),
          child: currentWs["timesheets_config"] != null
          ? currentMember["role_id"] == 1 ? AdminViewer() : CalendarViews()
          : TimeSheetsConfig(),
        ),
      ),
    );
  }
}

class AdminViewer extends StatelessWidget {
  const AdminViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentMember = Provider.of<Workspaces>(context, listen: false).currentMember;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ListFormRequest(month: DateTime.now(), approver: currentMember["user_id"]);
                }));
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xff5E5E5E)))
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIcons.gitPullRequest, color: Color(0xffA6A6A6), size: 16),
                        SizedBox(width: 14),
                        Text("Xem đơn duyệt", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                      ],
                    ),
                    Container(
                      child: Icon(PhosphorIcons.caretRight, color: Color(0xffA6A6A6), size: 20),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Material(
                    child: SafeArea(
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
                                    "Calendar",
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
                          Expanded(child: CalendarViews()),
                        ],
                      ),
                    ),
                  );
                }));
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xff5E5E5E)))
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIcons.gitPullRequest, color: Color(0xffA6A6A6), size: 16),
                        SizedBox(width: 14),
                        Text("Xem chế độ lịch nhân viên", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                      ],
                    ),
                    Container(
                      child: Icon(PhosphorIcons.caretRight, color: Color(0xffA6A6A6), size: 20),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TimeSheetsConfig extends StatefulWidget {
  const TimeSheetsConfig({ Key? key }) : super(key: key);
  @override
  _TimeSheetsConfigState createState() => _TimeSheetsConfigState();
}

class _TimeSheetsConfigState extends State<TimeSheetsConfig> {
  DateTime checkInTime = DateTime.now();
  DateTime checkOutTime = DateTime.now();
  List listSelected = [];

  onHandleSaveConfig() async {
    final currentWs = context.read<Workspaces>().currentWorkspace;
    final auth = context.read<Auth>();
    Map workspace = new Map.from(currentWs);
    
    workspace["timesheets_config"] = {
      "start_time" : "${checkInTime.hour < 10 ? "0${checkInTime.hour}" : checkInTime.hour}:${checkInTime.minute < 10 ? "0${checkInTime.minute}" : checkInTime.minute}",
      "end_time" : "${checkOutTime.hour < 10 ? "0${checkOutTime.hour}" : checkOutTime.hour}:${checkOutTime.minute < 10 ? "0${checkOutTime.minute}" : checkOutTime.minute}",
      "wifi" : listSelected
    };
    
    await context.read<Workspaces>().changeWorkspaceInfo(auth.token, currentWs["id"], workspace);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentMember = Provider.of<Workspaces>(context, listen: false).currentMember;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    // ignore: unused_local_variable
    final configModal = Container(
      margin: EdgeInsets.only(right: 12),
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Palette.calendulaGold),
        ),
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            enableDrag: true,
            context: context,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            builder: (BuildContext context) {
              return Builder(
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: isDark ? Palette.darkPrimary : Palette.lightPrimary,
                        ),
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 30),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Setting", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xffDBDBDB))),
                                  InkWell(
                                    onTap: () {
                                      setState(() {});
                                      onHandleSaveConfig();
                                    },
                                    child: Text("Save", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xffFAAD14)))
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 12, bottom: 12),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Color(0xff5E5E5E)))
                              ),
                            ),
                            Container(
                              child: Text("Thời gian làm việc", style: TextStyle(fontSize: 16, color: Color(0xffDBDBDB), fontWeight: FontWeight.w700)),
                              margin: EdgeInsets.only(left: 16),
                            ),
                            SizedBox(height: 14),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Bắt đầu", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xffA6A6A6))),
                                        InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("Giờ Bắt đầu", textAlign: TextAlign.center,),
                                                content: Container(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      SizedBox(
                                                        height: 180,
                                                        child: CupertinoDatePicker(
                                                          use24hFormat: true,
                                                          initialDateTime: checkInTime,
                                                          mode: CupertinoDatePickerMode.time,
                                                          onDateTimeChanged: (dateTime) {
                                                            checkInTime = dateTime;
                                                          }
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {});
                                                          Navigator.pop(context);
                                                        },
                                                        child: Container(
                                                          child: Text("Xong"),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(top: 8),
                                            height: 45,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Color(0xff05E5E5E))
                                            ),
                                            child: Center(
                                              child: 
                                              Row(
                                                children: [
                                                  SizedBox(width: 12),
                                                  Icon(PhosphorIcons.clock, color: Color(0xffA6A6A6), size: 18),
                                                  SizedBox(width: 8),
                                                  Text("${(checkInTime.hour).toString()} : ${(checkInTime.minute).toString()}", style: TextStyle(fontSize: 16, color: Color(0xffDBDBDB))),
                                                ],
                                              )
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Kết thúc", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xffA6A6A6))),
                                        InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text("Giờ kết thúc", textAlign: TextAlign.center,),
                                                content: Container(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      SizedBox(
                                                        height: 180,
                                                        child: CupertinoDatePicker(
                                                          use24hFormat: true,
                                                          initialDateTime: checkOutTime,
                                                          mode: CupertinoDatePickerMode.time,
                                                          onDateTimeChanged: (dateTime) {
                                                            checkOutTime = dateTime;
                                                          }
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {});
                                                          Navigator.pop(context);
                                                        },
                                                        child: Container(
                                                          child: Text("Xong"),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(top: 8),
                                            height: 45,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Color(0xff05E5E5E))
                                            ),
                                            child: Center(
                                              child:  Row(
                                                children: [
                                                  SizedBox(width: 12),
                                                  Icon(PhosphorIcons.clock, color: Color(0xffA6A6A6), size: 18),
                                                  SizedBox(width: 8),
                                                  Text("${(checkOutTime.hour).toString()} : ${(checkOutTime.minute).toString()}", style: TextStyle(fontSize: 16, color: Color(0xffDBDBDB))),
                                                ],
                                              )
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 16, top: 30),
                              child: Text("SSID", style: TextStyle(fontSize: 16, color: Color(0xffDBDBDB), fontWeight: FontWeight.w700))
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8, left: 16, right: 16),
                              height: 45,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Color(0xff05E5E5E))
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 16),
                                  Text("${listSelected.length > 0 ? "${listSelected.length} wifi are selected" : ""}", style: TextStyle(fontSize: 16, color: Color(0xffDBDBDB))),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                await Utils.requestPermission();
                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("List wifi", textAlign: TextAlign.center,),
                                    content: Container(
                                      child: ListWifi(listWifiSelected: listSelected,)
                                    ),
                                  ),
                                ).then((value){
                                  setState(() {});
                                });
                                
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: 16, top: 8),
                                child: Row(
                                  children: [
                                    Icon(PhosphorIcons.plusCircle, color: Color(0xffFAAD14), size: 18,),
                                    SizedBox(width: 8),
                                    Text("Thêm SSID", style: TextStyle(fontSize: 14, color: Color(0xffFAAD14), fontWeight: FontWeight.w400)),
                                  ],
                                )
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  );
                }
              );
            }
          ).then((value) {
            setState(() {
              
            });
          });
        },
        child: Text(
          'Cấu hình',
          style: TextStyle(color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight)),
      ),
    );
    return Container(
      child: Center(
        child: currentMember["role_id"] > 1
        ? Text("Owner cần phải cấu hình chấm công cho workspace này trước.")
        : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bạn chưa cấu hình chấm công cho workspace này."),
            SizedBox(height: 10),
            Text("Vui lòng cấu hình chấm công trên máy tính để bàn")
          ],
        ),
      ),
    );
  }
}

class ListWifi extends StatefulWidget {
  ListWifi({ Key? key, required this.listWifiSelected }) : super(key: key);
  List listWifiSelected;

  @override
  _ListWifiState createState() => _ListWifiState();
}

class _ListWifiState extends State<ListWifi> {
  List listWifi = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    Work.platform.invokeMethod("scan_wifi").then((value) async {
      listWifi = await jsonDecode(value);
      listWifi = Map.fromIterable(listWifi, key: (k) => k["ssid"], value: (v) => v as Map).values.toList();
      setState(() {
        loading = false;
      });
    } );
  }
  @override
  Widget build(BuildContext context) {
    var listSelected = widget.listWifiSelected;
    return loading == false ? Container(
      height: 500,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: listWifi.map((e) {
            return InkWell(
              onTap: () {
                (listSelected.indexWhere((element) => element == listWifi[listWifi.indexOf(e)]) != -1)
                ? listSelected.remove(e)
                : listSelected.add(e);
                setState(() {});
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                color: (listSelected.indexWhere((element) => element == listWifi[listWifi.indexOf(e)]) != -1) ? Colors.grey : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(e["ssid"], style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis,)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ) : Container(child: Text("data"),);
  }
}

class CalendarViews extends StatefulWidget {
  const CalendarViews({ Key? key }) : super(key: key);

  @override
  _CalendarViewsState createState() => _CalendarViewsState();
}

class _CalendarViewsState extends State<CalendarViews> {
  final _controller = CalendarController();
  String? selectedUser;
  int successDay = 0;
  int overTime = 0;
  int failureDay = 0;
  int outTime = 0;

  bool showFloating = true;

  TimesheetDataSource _events = TimesheetDataSource([]);
  Future<List> _getDataFromApi(DateTime month) async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final workspaceId = Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"];
    final url = Utils.apiUrl + 'workspaces/$workspaceId/index_timesheets?token=$token';

    final body = {
      'user_id': selectedUser,
      'start_date': DateFormat('yyyy-MM-dd').format(DateTime(month.year, month.month, 1)),
      'end_date': DateFormat('yyyy-MM-dd').format(DateTime(month.year, month.month + 1, 0)),
    };
    try {
      final response = await Dio().post(url, data: json.encode(body));
      var dataRes = response.data;
      if (dataRes["success"]) {
        return List.from(dataRes['data']);
      }
      else {
        throw Exception(
          "Load timesheet fail"
        );
      }

    } catch (e, trace) {
      print("$e: $trace");
      return [];
    }
  }
  Future<void> _getEventsForMonth(DateTime month) async {
    _events.appointments.clear();
    final List _dataFromApi = await _getDataFromApi(month);
    // _getReviewFormTimesheets();

    final List<Timesheet> timesheets = <Timesheet>[];
    for(int i = 0; i < _dataFromApi.length; i++) {
      Timesheet? _timesheet = _parseTimeSheet(_dataFromApi[i]);

      if (_timesheet != null) {
        timesheets.add(_timesheet);
        _events.appointments.add(_timesheet);
      }
    }
    _events.notifyListeners(CalendarDataSourceAction.reset, timesheets);
  }
    Timesheet? _parseTimeSheet(dataApi) {
    _displayDateTime(DateTime time) {
      return DateFormat ('yyyy-MM-dd').add_Hms().format(time);
    }
    try {
      final isForm = dataApi['is_form'] != null && dataApi['is_form'];
      final stringType = isForm ? FormType.values[dataApi['type']] : null;
      
      final isApproved = isForm && dataApi["is_approved"] != null && dataApi["is_approved"];
      final success = dataApi['success'];

      final isOvertime = stringType == FormType.overTime;
      final isBreakOut = stringType == FormType.breakOut;
      final isBreakAll = stringType == FormType.breakAll;
      final isAdjustAttendance = stringType == FormType.adjustAttendance;

      final date = DateTime.tryParse(dataApi['date'] ?? '');
      bool isAllDay = false;
      var from = DateTime.tryParse(dataApi['start_time'] ?? '');
      if (from == null) {
        isAllDay = true;
        from = date!;
      }
      final to = DateTime.tryParse(dataApi['end_time'] ?? '') ?? from.add(Duration(milliseconds: 1));
      _generateSubject() {
        String subject = "";
        if (!isForm && !dataApi["is_overtime"]) {
          if (dataApi['start_time'] != null) subject += "Đã check in ${_displayDateTime(from!)}\n";
          if(dataApi['end_time'] != null) subject += "Đã check out ${_displayDateTime(to)}\n";
          if (dataApi["reason"] != null) subject += dataApi["reason"];
        } 
        else if (dataApi['is_overtime'] != null && dataApi['is_overtime']) {
          subject += "Tăng ca\n";
        }
        else {
          if (isOvertime) subject += "Tăng ca\n";
          else if (isBreakOut) subject += "Xin ra ngoài\n";
          else if (isBreakAll) subject += "Xin nghỉ phép\n";
          else if (isAdjustAttendance) subject += "Điều chỉnh thời gian checkin/out\n";
          if (!isOvertime) subject += "${dataApi["reason"]}\n";
          if (!isApproved) subject += "Đang đợi duyệt từ ${dataApi['approver_name']}\n";
          else if (!success) subject += "Đã bị huỷ bởi ${dataApi['approver_name']}\n";
          else subject += "Đã được duyệt bởi  ${dataApi['approver_name']}\n";
        }
        return subject;
      }
      Color color = !success ? Colors.red : isForm ? Colors.blue : Colors.green;

    return Timesheet(
      _generateSubject(),
      date,
      from,
      to,
      color,
      isAllDay,
      null,
      null,
      '',
      isOvertime,
      isForm,
      success
    );
    } catch (e, t) {
      print("$e\n$t");
      print(dataApi);
    }
    return null;
  }

  Future<void> _showModalCheckIn(BuildContext context) async {
    bool _isLate() {
      final currentWs = context.read<Workspaces>().currentWorkspace;
      final startTime = currentWs["timesheets_config"]["start_time"];
      String _st = startTime;
      if (_st.contains("AM") || _st.contains("PM")) _st = DateFormat("HH:mm").format(DateFormat.Hm().parse(startTime));
      TimeOfDay _startTime = TimeOfDay(hour:int.parse(_st.split(":")[0]), minute: int.parse(_st.split(":")[1]));

      return Utils.compareTime(_startTime);
    }

    bool isLate = _isLate();
    
    await context.showActionDialog(
      action: () => _onHandleCheckIn(),
      actionText: isLate ? 'Vẫn checkin' : 'Checkin',
      message: isLate ? "Bạn đang checkin sau giờ quy định. Vẫn muốn checkin?" : "Xác nhận checkin?",
    );
  }
  Future<void> _onHandleCheckIn() async {
    // Navigator.of(context, rootNavigator: true).pop();
    
    // final token = Provider.of<Auth>(context, listen: false).token;
    // final currentWs = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    // final workspaceId = currentWs["id"];

    // final preCheckinResult = await context.read<Workspaces>().sendPreCheckin(workspaceId, token);
    // if (preCheckinResult["success"]) {
    //   context.showLoadingDialog();
    //   final checkinResult = await context.read<Workspaces>().sendCheckin(workspaceId, token);
    //   Navigator.pop(context);
    //   if (checkinResult["success"]) {
    //     _getEventsForMonth(DateTime.now());
    //     context.showDialogWithSuccess(checkinResult["message"]);
    //   } else {
    //     context.showDialogWithFailure(checkinResult["message"]);
    //   }
    // } else {
    //   context.showDialogWithFailure(preCheckinResult["message"]);
    // }
  }

  Future<void> _showModalCheckOut(BuildContext context) async {
    bool _isLate() {
      final currentWs = context.read<Workspaces>().currentWorkspace;
      final endTime = currentWs["timesheets_config"]["end_time"];
      String _et = endTime;
      if (_et.contains("AM") || _et.contains("PM")) _et = DateFormat("HH:mm").format(DateFormat.Hm().parse(endTime));
      TimeOfDay _endTime = TimeOfDay(hour:int.parse(_et.split(":")[0]),minute: int.parse(_et.split(":")[1]));

      return Utils.compareTime(_endTime);
    }
    
    bool isLate = _isLate();

    await context.showActionDialog(
      action: () => _onHandleCheckOut(),
      actionText: !isLate ? 'Vẫn checkout' : 'Checkout',
      message: !isLate ? "Bạn đang checkout trước giờ quy định. Vẫn muốn checkout?" : "Xác nhận checkout?", 
    );
  }
  Future<void> _onHandleCheckOut() async {
    // Navigator.of(context).pop();
    // final token = context.read<Auth>().token;
    // final currentWs = context.read<Workspaces>().currentWorkspace;
    // final workspaceId = currentWs["id"];

    // final checkoutResult = await context.read<Workspaces>().sendCheckout(workspaceId, token);

    // if (checkoutResult["success"]) {
    //   _getEventsForMonth(DateTime.now());
    //   context.showDialogWithSuccess(checkoutResult["message"]);
    // } else {
    //   context.showDialogWithFailure(checkoutResult["message"]);
    // }
  }
  // ignore: unused_element
  Future _uploadImage(token, workspaceId) async {
    String uint8ListTob64(Uint8List uint8list) {
      String base64String = base64Encode(uint8list);
      return base64String;
    }
    final AssetEntity? pickedFile =
      await CameraPicker.pickFromCamera(
        context,
        pickerConfig: CameraPickerConfig(
          textDelegate: EnglishCameraPickerTextDelegate(),
          preferredLensDirection: CameraLensDirection.front,
        ));

    if (pickedFile == null) return;

    var bytes = await pickedFile.originBytes;
    final file = await pickedFile.loadFile();
    var name = pickedFile.title;

    var files;
    if(pickedFile.type.name == "image") {
      files = {
      "name": name,
      "bytes": bytes,
      "mime_type": pickedFile.mimeType,
      "type": 'image',
      "path": file!.path
      };
    }
    else {
      var file  = await pickedFile.loadFile();
      var fileName = file!.path.split('/').last;
      var fileType = file.path.split('.').last;
      var name = fileName.replaceAll(".$fileType", "").split(".").last;
      final imageThumbnail = await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 1920,
        maxHeight: 1080,
        quality: 10,
      );
      var decodeImg = await decodeImageFromList(imageThumbnail!);
      final uploadFile = {
        "filename": "$name.$fileType",
        "bytes": uint8ListTob64(imageThumbnail),
        "image_data": {
          "width": decodeImg.width,
          "height": decodeImg.height
        }
      };

      files = {
        "att_id": Utils.getRandomString(10),
        "name" : "$name.${fileType.toLowerCase()}",
        "bytes" : bytes,
        "path" : file.path,
        "type": 'video',
        "mime_type": "${fileType.toLowerCase()}",
        "image_data": {
          "width": decodeImg.width,
          "height": decodeImg.height
        },
        "upload": uploadFile
      };
    }

    final uploadContext = Utils.globalContext;
    var _uploadFile = await Provider.of<Work>(uploadContext!, listen: false).getUploadData(files);
    final resultUpload = await Provider.of<Work>(uploadContext, listen: false).uploadImage(token, workspaceId, _uploadFile, _uploadFile["mime_type"] ?? "image", (value){});
    return resultUpload["content_url"];
  }
  @override
  Widget build(BuildContext context) {
    final auth = context.read<Auth>();
    
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scrollBehavior: ScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad
          },
        ),
        theme:  (auth.theme == ThemeType.DARK
          ? Themes.darkTheme
          : Themes.lightTheme).copyWith(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
              },
            )),
        home: Column(
          children: [
            Expanded(
              child: Container(
                child: _getViewCalendar(_events, ((viewChangedDetails){
                  _getEventsForMonth(viewChangedDetails.visibleDates[viewChangedDetails.visibleDates.length ~/2]);
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
                }), _controller),
              ),
            ),
            Center(
              child: actionButton()
            )
          ],
        ),
      ),
    );
  }

    void _showCreateForm(DateTime date) async {
      setState(() {
        showFloating = false;
      });
    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ListForm(selectedDate: date);
    }));
     setState(() {
        showFloating = true;
      });
      _getEventsForMonth(date);
  }

  SfCalendar _getViewCalendar([CalendarDataSource? calendarDataSource, ViewChangedCallback? onViewChange, CalendarController? controller]) {
    return SfCalendar(
      view: CalendarView.month,
      allowedViews: [CalendarView.day, CalendarView.month, CalendarView.schedule, CalendarView.timelineDay, CalendarView.timelineMonth, CalendarView.timelineWeek, CalendarView.timelineWorkWeek, CalendarView.week, CalendarView.workWeek],
      controller: controller,
      showDatePickerButton: true,
      allowViewNavigation: true,
      onViewChanged: onViewChange,
      dataSource: calendarDataSource,
      appointmentTimeTextFormat: 'H:mm a',
      monthViewSettings: MonthViewSettings(
        agendaStyle: AgendaStyle(
        ),
        agendaItemHeight: 105,
        showAgenda: true,
        numberOfWeeksInView: 6
      ),
      timeSlotViewSettings: TimeSlotViewSettings(
        minimumAppointmentDuration: Duration(minutes: 60)
      ),
      onLongPress: (calendarLongPressDetails) {
        final currentMember = context.read<Workspaces>().currentMember;
        if (calendarLongPressDetails.targetElement != CalendarElement.calendarCell || controller?.view != CalendarView.month) return;
        if(currentMember['role_id'] > 1) _showCreateForm(calendarLongPressDetails.date!);
      },
    );
  }

  Widget actionButton() {
    final currentMember = context.read<Workspaces>().currentMember;
    return !showFloating || currentMember['role_id'] == 1 ? 
      ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<OutlinedBorder>(
            CircleBorder(side: BorderSide())
          ),
          backgroundColor: MaterialStateProperty.all(Colors.green)
        ),
        onPressed: _adminChooseMember, 
        child: Center(child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:Icon(PhosphorIcons.userList),
        ))
      )
    : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(
              CircleBorder(side: BorderSide())
            ),
            backgroundColor: MaterialStateProperty.all(Colors.green)
          ),
          onPressed: () {
            setState(() => showFloating = false);
            _showModalCheckIn(context).then((value) => setState(() => showFloating = true));
          }, 
          child: Center(child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Icon(PhosphorIcons.mapPinLight),
          ))
        ),
        ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(
              CircleBorder(side: BorderSide())
            ),
            backgroundColor: MaterialStateProperty.all(Colors.red)
          ),
          onPressed: () {
            setState(() => showFloating = false);
            _showModalCheckOut(context).then((value) => setState(() => showFloating = true));
          }, 
          child: Center(child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Icon(PhosphorIcons.mapPinLineFill),
          ))
        ),
        ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(
              CircleBorder(side: BorderSide())
            ),
            backgroundColor: MaterialStateProperty.all(Colors.blue)
          ),
          onPressed: _showOption, 
          child: Center(child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Icon(PhosphorIcons.listBulletsBold),
          ))
        )
      ],
    );
  }
  _adminChooseMember() {
    final currentUser =  context.read<User>().currentUser;
    final wsMembers =  context.read<Workspaces>().members;
    final members = wsMembers.where((ele) => ele["account_type"] == 'user' && ele["id"] != currentUser['id']).toList();
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 500
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: Text("Chọn member"),
            ),
            SingleChildScrollView(
              child: Column(children: [
                ...members.map((e) => InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    selectedUser = e["id"];
                    _getEventsForMonth(DateTime.now());
                  },
                  child: Container(padding: EdgeInsets.all(10), width: double.infinity, child: Text(e["full_name"])),
                ))
              ]),
            ),
          ],
        ),
      );
    });
  }
  _showOption() async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => optionPage()));
  }
  Widget optionPage() {
    final auth = context.read<Auth>();
    final currentMember = context.read<Workspaces>().currentMember;
    final isDark = auth.theme == ThemeType.DARK;
    return Material(
      child: SafeArea(
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
                        "Chấm công",
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
            if (!(currentMember['role_id'] == 1)) InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return ListForm();
                }));
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xff5E5E5E)))
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIcons.gitPullRequest, color: Color(0xffA6A6A6), size: 16),
                        SizedBox(width: 14),
                        Text("Tạo yêu cầu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                      ],
                    ),
                    Container(
                      child: Icon(PhosphorIcons.caretRight, color: Color(0xffA6A6A6), size: 20),
                    )
                  ],
                ),
              ),
            ),
            if (!(currentMember['role_id'] == 1)) InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return ListFormRequest(month: DateTime.now(), user: currentMember["user_id"],); //Sửa lại đoạn này
                }));
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xff5E5E5E)))
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIcons.gitPullRequest, color: Color(0xffA6A6A6), size: 16),
                        SizedBox(width: 14),
                        Text("Xem yêu cầu đã tạo trong tháng này", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                      ],
                    ),
                    Container(
                      child: Icon(PhosphorIcons.caretRight, color: Color(0xffA6A6A6), size: 20),
                    )
                  ],
                ),
              ),
            ),
            if (currentMember['role_id'] == 1) InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return ListFormRequest(month: DateTime.now(), approver: currentMember["user_id"],); //Sửa lại đoạn này
                }));
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xff5E5E5E)))
                ),
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(PhosphorIcons.gitPullRequest, color: Color(0xffA6A6A6), size: 16),
                        SizedBox(width: 14),
                        Text("Yêu cầu cần duyệt", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                      ],
                    ),
                    Container(
                      child: Icon(PhosphorIcons.caretRight, color: Color(0xffA6A6A6), size: 20),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ListForm extends StatelessWidget {
  final DateTime? selectedDate;
  const ListForm({Key? key, this.selectedDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final titleWidget = Container(
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
                "Tạo yêu cầu",
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
    );
    Widget formItem(FormType type) {
      String typeString = type == FormType.breakAll ? "Xin nghỉ phép" : type == FormType.breakOut ? "Xin ra ngoài" : type == FormType.overTime ? "Xin tăng ca" : type == FormType.adjustAttendance ? "Điều chỉnh giờ checkin/out" : "NULL/ERROR";
      return InkWell(
        highlightColor: Colors.grey,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return CreateForm(type: type, selectedDate: selectedDate);
          }));
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xff5E5E5E)))
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(PhosphorIcons.gitPullRequest, color: Color(0xffA6A6A6), size: 16),
                  SizedBox(width: 14),
                  Text(typeString, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                ],
              ),
              Container(
                child: Icon(PhosphorIcons.caretRight, color: Color(0xffA6A6A6), size: 20),
              )
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            titleWidget,
            formItem(FormType.adjustAttendance),
            formItem(FormType.breakAll),
            formItem(FormType.breakOut),
            formItem(FormType.overTime)
          ],
        ),
      ),
    );
  }
}

class ListFormRequest extends StatefulWidget {
  final user;
  final approver;
  final DateTime month;
  const ListFormRequest({Key? key, required this.month, this.user, this.approver}) : super(key: key);

  @override
  State<ListFormRequest> createState() => _ListFormRequestState();
}

class _ListFormRequestState extends State<ListFormRequest> {
  List formReview = [];
  @override
  void initState() {
    _loadRequest(userId: widget.user, approverId: widget.approver);
    super.initState();

  }
  _loadRequest({userId, approverId, isApproved}) async {
    final token = context.read<Auth>().token;
    final workspaceId = context.read<Workspaces>().currentWorkspace["id"];

    final startDate = DateFormat('yyyy-MM-dd').format(DateTime(widget.month.year, widget.month.month, 1));
    final endDate = DateFormat('yyyy-MM-dd').format(DateTime(widget.month.year, widget.month.month + 1, 0));

    // final url = Utils.apiUrl + 'workspaces/$workspaceId/index_timesheets_form?token=$token';
    var url = Utils.apiUrl + 'workspaces/$workspaceId/index_timesheets_form?token=$token&&start_date=$startDate&&end_date=$endDate';
    url = url + (userId != null ? "&&user_id=$userId" : "") + (approverId != null ? "&&approver_id=$approverId" : "") + (isApproved != null ? "&&is_approved=$isApproved" : "");
    try {
      final response = await Dio().get(url);
      var dataRes = response.data;
      if (dataRes["success"]) {
        setState(() {
          formReview = dataRes["data"];
        });
      }
    } catch (e, trace) {
      print("Error Channel: $trace");
    }
  }

  _reviewFormTimesheets(formId, status, senderId, reason, token) async {
    final token = context.read<Auth>().token;
    final workspaceId = context.read<Workspaces>().currentWorkspace["id"];

    final url = Utils.apiUrl + 'workspaces/$workspaceId/check_approve_form?token=$token';
    try {
      final response = await Dio().post(url, data: json.encode({
        "success": status,
        "is_approved": true,
        "sender_id": senderId,
        'form_id': formId,
        'reason': reason,
      }));
      var dataRes = response.data;
      if (dataRes["success"]) {
        // Navigator.of(context, rootNavigator: true).pop("Discard");
        // _getReviewFormTimesheets();
        _loadRequest(userId: widget.user, approverId: widget.approver);
      } else {
        print("aprroved failed");
      }
    } catch (e, trace) {
      print("Error Channel: $trace");
    }
  }
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Material(
      child: SafeArea(
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
                        "Danh sách công duyệt",
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...formReview.map((ele) {
                      final type = FormType.values[ele["type"]];
                      final isApproved = ele["is_approved"];
                      String typeString = type == FormType.breakAll ? "Xin nghỉ phép" : type == FormType.breakOut ? "Xin ra ngoài" : type == FormType.overTime ? "Xin tăng ca" : type == FormType.adjustAttendance ? "Điều chỉnh giờ checkin/out" : "NULL/ERROR";
                      return Card(
                        color: isDark ? null : Colors.grey[200],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey))),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                              margin: EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Đơn $typeString ${widget.approver != null ? "của ${ele["full_name"]}": ""}", style: TextStyle(fontSize: 15)),
                                ],
                              )
                            ),
                            if (ele["date"] != null) Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  Text("Ngày: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                                  Text("${ele["date"]}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14))
                                ],
                              )
                            ),
                            SizedBox(height: 10),
            
                            if (ele["start_time"] != null && ele["end_time"] != null && ele["date"] == null) Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  Text("Ngày: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                                  Text("${DateFormat("y-M-d").format(DateTime.parse(ele["start_time"]))}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14))
                                ],
                              )
                            ),
            
                            if (ele["start_time"] != null && ele["end_time"] != null) Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  Text("Thời gian: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                                  Text("${DateFormat("kk:mm").format(DateTime.parse(ele["start_time"]))}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                                  Text(" : "),
                                  Text("${DateFormat("kk:mm").format(DateTime.parse(ele["end_time"]))}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14))
                                ],
                              )
                            ),
            
                            if (ele["reason"] != null) Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  Text("Lý do: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                                  Text("${ele["reason"]}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14))
                                ],
                              )
                            ),
            
                            if (widget.approver == null) Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  Text("Người duyệt: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                                  Text("${ele["approver_full_name"]}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14))
                                ],
                              )
                            ),
            
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                children: [
                                  Text("Trạng thái: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                                  Text("${ !ele["is_approved"] ? "Chưa duyệt" : !ele["success"] ? "Đã huỷ" : "Đã duyệt"}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14))
                                ],
                              )
                            ),
            
                            SizedBox(height: 20,),
            
                            if (!isApproved && widget.approver != null) Container(
                              decoration: BoxDecoration(border: Border(top: BorderSide(width: 0.2, color: Colors.grey))),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                              margin: EdgeInsets.only(top: 16),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 100, height: 32,
                                    margin: EdgeInsets.only(right: 12),
                                    child: OutlinedButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Palette.calendulaGold),
                                      ),
                                      onPressed: () => _reviewFormTimesheets(ele["id"], true, ele["user_id"], ele["reason"], auth.token),
                                      child: Text(
                                            'Duyệt',
                                            style: TextStyle(color: isDark ? Colors.black : Palette.defaultTextLight),),
                                    ),
                                  ),
                                  Container(
                                    width: 100, height: 32,
                                    margin: EdgeInsets.only(right: 12),
                                    child: OutlinedButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Colors.red),
                                      ),
                                      onPressed: () => _reviewFormTimesheets(ele["id"], false, ele["user_id"], ele["reason"], auth.token),
                                      child: Text(
                                            'Từ chối',
                                            style: TextStyle(color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),),
                                    ),
                                  ),
                                ],
                              )),
                            // ) : Row(
                            //   children: [
                            //     Container(
                            //       margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                            //       decoration: BoxDecoration(border: Border(top: BorderSide(width: 0.2, color: Colors.grey))),
                            //       width: 100, height: 32,
                            //       child: OutlinedButton(
                            //         style: ButtonStyle(
                            //           backgroundColor: MaterialStateProperty.all(Colors.grey),
                            //         ),
                            //         onPressed: null,
                            //         child: Text(
                            //               ele['success'] ? 'Đã duyệt' : 'Đã huỷ',
                            //               style: TextStyle(color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),),
                            //       )
                            //     ),
                            //   ],
                            // )
                          ],
                        ),
                      );
                    }).toList()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}