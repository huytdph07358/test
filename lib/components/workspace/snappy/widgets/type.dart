import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

enum FormType {
  overTime, adjustAttendance, breakOut, breakAll
}

class Timesheet {
  Timesheet(
    this.subject,
    this.date,
    this.from,
    this.to,
    this.background,
    this.isAllDay,
    this.startTimeZone,
    this.endTimeZone,
    this.recurrenceRule,
    this.isOvertime,
    this.isForm,
    this.success
  );

  String subject;
  DateTime? date;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String? startTimeZone;
  String? endTimeZone;
  String? recurrenceRule;
  bool? isOvertime;
  bool? success;
  bool? isForm;
}
class TimesheetDataSource extends CalendarDataSource {
  TimesheetDataSource(this.source);

  List<Timesheet> source;
  @override
  List<Timesheet> get appointments => source;

  @override
  DateTime getStartTime(int index) {
    return source[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return source[index].to;
  }

  @override
  bool isAllDay(int index) {
    return source[index].isAllDay;
  }

  @override
  String getSubject(int index) {
    return source[index].subject;
  }

  @override
  String? getStartTimeZone(int index) {
    return source[index].startTimeZone;
  }

  @override
  String? getEndTimeZone(int index) {
    return source[index].endTimeZone;
  }

  @override
  Color getColor(int index) {
    return source[index].background;
  }

  @override
  String? getRecurrenceRule(int index) {
    return source[index].recurrenceRule;
  }
}
final Map<FormType, String> formTypeToFormTypeString = {
    FormType.adjustAttendance: "Điều chỉnh giờ checkin/out",
    FormType.breakAll: "Xin nghỉ phép",
    FormType.breakOut: "Xin ra ngoài",
    FormType.overTime: "Tăng ca"
  };