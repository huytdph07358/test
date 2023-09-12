import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

import 'type.dart';

class CreateForm extends StatefulWidget {
  final selectedDate;
  final FormType type;
  const CreateForm({Key? key, this.selectedDate, required this.type}) : super(key: key);

  @override
  State<CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<CreateForm> {
  Map? _selectedUser;
  String? _reason;
  DateTime? _startTime;
  DateTime? _endTime;
  DateTime? _date;

  _onSendFormTimesheets(token) async {
    final currentWs = context.read<Workspaces>().currentWorkspace;
    final workspaceId = currentWs["id"];
    _date = _date ?? widget.selectedDate ;

    final url = Utils.apiUrl + 'workspaces/$workspaceId/send_form_timesheet?token=$token';
    if (_selectedUser != null && (_reason != null || widget.type == FormType.overTime) && (_startTime != null && _endTime != null || widget.type == FormType.adjustAttendance)) {
      final body = {
        "approver_id": _selectedUser!["id"],
        "start_time": _startTime != null ? DateFormat("y-M-dd kk:mm:ss").format(_startTime!) : null,
        "end_time": _endTime != null ? DateFormat("y-M-dd kk:mm:ss").format(_endTime!) : null,
        "reason": _reason,
        "type": widget.type.index,
        "date": _date != null ? DateFormat("y-M-dd").format(_date!) : null
      };
      final response = await Dio().post(url, data: json.encode(body));
      var dataRes = response.data;
      if (dataRes["success"]) {
        Navigator.pop(context, true);
        showCupertinoDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) => SimpleDialog(
          children: <Widget>[
            Center(
              child: Container(
                child: Column(
                  children: [
                    Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.green),
                    SizedBox(height: 10),
                    Text(dataRes["message"] ?? "Tạo form thành công"),
                  ],
                )
              )
            )
          ])
        );
      }
    } else {
      showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(CupertinoIcons.exclamationmark_shield_fill, color: Colors.red),
                    SizedBox(height: 10),
                    Text("Vui lòng nhập đủ thông tin để tạo form")
                  ],
                ),
              )
            ],
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<Auth>();
    final isDark = auth.theme == ThemeType.DARK;
    final currentUser = context.read<User>().currentUser;
    final wsMembers = context.read<Workspaces>().members;
    final members = wsMembers.where((ele) => ele["account_type"] == 'user' && ele["role_id"] <= 2 && ele["id"] != currentUser['id']).toList();
    String typeString = widget.type == FormType.breakAll ? "Xin nghỉ phép" : widget.type == FormType.breakOut ? "Xin ra ngoài" : widget.type == FormType.overTime ? "Xin tăng ca" : widget.type == FormType.adjustAttendance ? "Điều chỉnh giờ checkin/out" : "NULL/ERROR";

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
                typeString,
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

    final approverPicker = Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("* Chọn người duyệt/Admin"),
              _selectedUser != null ? Text(_selectedUser!["full_name"]) : Text("SELECT")
            ],
          ),
        ),
        onTap: () => showModalBottomSheet(
          context: context, 
          builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Text("Chọn người duyệt/Admin"),
                    ...members.map((item) {
                      return TextButton(
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(isDark ? Palette.darkSelectedChannel : Color(0xffF3F3F3)),
                          padding: MaterialStateProperty.all(EdgeInsets.zero)
                        ),
                        onPressed: () {
                          if (_selectedUser != null && _selectedUser!["id"] == item["id"]) setState(() => _selectedUser = null);
                          else setState(() => _selectedUser = {"id": item["id"], "full_name": item["full_name"], "avatar_url": item["avatar_url"]});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: item != members.last ? Border(bottom: BorderSide(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight)) : null,
                          ),
                          padding: EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CachedAvatar(
                                    item["avatar_url"] ?? "",
                                    name: item["full_name"],
                                    width: 28,
                                    height: 28
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    item["full_name"],
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 065)
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Flexible(
                                child: Container(
                                  margin: EdgeInsets.only(right: 5),
                                  child: _selectedUser != null && _selectedUser!["id"] == item["id"]
                                    ? Icon(CupertinoIcons.checkmark_alt_circle_fill, size: 16, color: Palette.accentColor)
                                    : Container(width: 16, height: 16)
                                ),
                              ),
                            ],
                          ),
                        )
                      );
                    }).toList()
                  ],
                ),
              );
            }
          );
        },
        ).then((value) => this.setState(() {}))
      ),
    );

    final startTimePicker = Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            context: context, 
            builder: (context) {
            return DateTimePicker(
              initTime: _startTime,
              mode: CupertinoDatePickerMode.dateAndTime,
              onSelectDateTime: (value) {
                setState(() => _startTime = value);
                Navigator.pop(context);
              },
            );
          });
        },
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("*Thời gian bắt đầu"),
              _startTime != null 
                ? Text(DateFormat("y-M-d kk:mm").format(_startTime!)) : widget.selectedDate != null 
                ? Text(DateFormat("y-M-d _:_").format(widget.selectedDate)) : Text("SELECT")
            ],
          ),
        ),
      ),
    );

    final endTimePicker = Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            context: context, 
            builder: (context) {
            return DateTimePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              minimumDateTime: _startTime,
              onSelectDateTime: (value) {
                setState(() => _endTime = value);
                Navigator.pop(context);
              }
            );
          });
        },
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("*Thời gian kết thúc"),
              _endTime != null 
              ? Text(DateFormat("y-M-d kk:mm").format(_endTime!)) : widget.selectedDate != null
              ? Text(DateFormat("y-M-d _:_").format(widget.selectedDate)) : Text("SELECT")
            ],
          ),
        ),
      ),
    );

    final datePicker = Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            context: context, 
            builder: (context) {
            return DateTimePicker(
              initTime: _date,
              mode: CupertinoDatePickerMode.date,
              onSelectDateTime: (value) {
                setState(() => _date = value);
                Navigator.pop(context);
              }
            );
          });
        },
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("*Ngày điều chỉnh"),
              _date != null 
              ? Text(DateFormat("y-M-d").format(_date!)) : widget.selectedDate != null
              ? Text(DateFormat("y-M-d").format(widget.selectedDate)) : Text("SELECT")
            ],
          ),
        ),
      ),
    );

    final reasonBox = Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("*Lý do", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
          SizedBox(height: 8),
          Container(
            height: 100,
            color: isDark ? Palette.defaultBackgroundDark : Colors.white,
            child: TextFormField(
              // focusNode: _titleNode,
              autofocus: false,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Nhập lý do",
                hintStyle: TextStyle(
                  color: isDark ? Color(0xff9AA5B1) : Color.fromRGBO(0, 0, 0, 0.65),
                  fontSize: 13,
                  fontWeight: FontWeight.w300),
                contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight),
                  borderRadius: const BorderRadius.all(Radius.circular(2))
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight),
                  borderRadius: const BorderRadius.all(Radius.circular(2))
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : const Color.fromRGBO( 0, 0, 0, 0.65), fontSize: 15, fontWeight: FontWeight.normal),
              onChanged: (value) {
                _reason = value;
              },
            ),
          )
        ],
      ),
    );
    final submitButton = Container(
      decoration:  BoxDecoration(border: Border(top: BorderSide(width: 0.2, color: Colors.grey))),
      padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 120, height: 32,
            margin: EdgeInsets.only(right: 12),
            child: OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Palette.calendulaGold),
              ),
              onPressed: () => _onSendFormTimesheets(auth.token),
              child: Text(
                'Tạo yêu cầu',
                style: TextStyle(color: Palette.defaultTextLight)),
            ),
          ),
        ],
      ),
    );
    return Material(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    approverPicker,
                    if (widget.type == FormType.adjustAttendance) datePicker,
                    if (widget.type != FormType.adjustAttendance) startTimePicker,
                    if (widget.type != FormType.adjustAttendance) endTimePicker,
                    if (widget.type != FormType.overTime) reasonBox
                  ],
                ),
              ),
              submitButton
            ],
          ),
        ),
      ),
    );
  }
}

class DateTimePicker extends StatefulWidget {
  final CupertinoDatePickerMode mode;
  final DateTime? minimumDateTime;
  final Function(DateTime)? onSelectDateTime;
  final DateTime? initTime;
  const DateTimePicker({Key? key, this.mode = CupertinoDatePickerMode.dateAndTime, this.onSelectDateTime, this.initTime, this.minimumDateTime}) : super(key: key);

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateTime? timeSelected;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 3 / 4,
      child: Column(
        children: [
          Expanded(
            child: CupertinoDatePicker(
              use24hFormat: true,
              initialDateTime: widget.initTime,
              minimumDate: widget.minimumDateTime,
              mode: widget.mode,
              onDateTimeChanged: (value) {
                timeSelected = value;
              }
            ),
          ),
          TextButton(
            onPressed: () {
              widget.onSelectDateTime?.call(timeSelected ?? DateTime.now());
            }, 
            child: Text("OK")
          )
        ],
      ),
    );
  }
}