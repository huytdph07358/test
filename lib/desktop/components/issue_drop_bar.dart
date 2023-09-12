import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/desktop/workview_desktop/issue_table.dart';
import 'package:collection/collection.dart';
import 'package:workcake/models/models.dart';

class IssueDropBar extends StatefulWidget {
  IssueDropBar({
    Key? key,
    this.title,
    this.listAttribute,
    this.selectedAtt,
    this.onSelectAtt,
    this.sortBy,
    this.changeSort,
    this.selectedCheckbox,
    this.tab,
    this.onFilterIssue
  }) : super(key: key);

  final title;
  final listAttribute;
  final selectedAtt;
  final onSelectAtt;
  final sortBy;
  final changeSort;
  final selectedCheckbox;
  final tab;
  final onFilterIssue;

  @override
  _IssueDropBarState createState() => _IssueDropBarState();
}

class _IssueDropBarState extends State<IssueDropBar> {
  List listAttribute = [];
  List defaultSelected = [];

  @override
  void initState() {
    super.initState();

    this.setState(() {
      listAttribute = widget.listAttribute ?? [];
    });
  }

  @override
  void didUpdateWidget (oldWidget) {
    super.didUpdateWidget(oldWidget);

    this.setState(() {
      listAttribute = widget.listAttribute ?? [];
    });
  }

  calculateDueby(due) {
    final DateTime now = DateTime. now();
    final pastDay = now.difference(DateTime.parse(due)).inDays;
    final pastMonth = pastDay ~/ 30;

    if (pastMonth > 0) {
      return "Past due by ${pastMonth.toString()} ${pastMonth > 1 ? "months" : "month"}";
    } else {
      return "Past due by ${pastDay.toString()} ${pastDay > 1 ? "days" : "day"}";
    }
  }

  renderDueDate(milestone) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final DateTime now = DateTime. now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final formatted = formatter. format(now);
    final isPast = (milestone["due_date"].compareTo(formatted) < 0);

    return Row(
      children: [
        Container(
          child: Icon(
            isPast ? Icons.info_outline : Icons.calendar_today_outlined, size: 20, 
            color: isPast ? Color(0xffcb2431) : isDark ? Colors.white70 : Colors.grey[700]
          )
        ),
        SizedBox(width: 6),
        Text("", style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontSize: 15)),
        SizedBox(width: 3),
        Text(
          milestone["due_date"] != null ? 
          isPast ? calculateDueby(milestone["due_date"]) :
          "Due by " + (DateFormatter().renderTime(DateTime.parse(milestone["due_date"]), type: "yMMMMd")) : "",
          style: TextStyle(color: isPast ? Color(0xffcb2431) : isDark ? Colors.white70 : Colors.grey[700], fontSize: 15)
        ),
      ]
    );
  }

  changeSort(type) {
    widget.changeSort(type);
  }

  onFilterAttribute(value) {
    if (value.trim() != "") {
      List list = List.from(widget.listAttribute).where((e) {
        if (widget.title == "Assignee") {
          return e["full_name"].toLowerCase().contains(value);
        } else if (widget.title == "Label") {
          return e["name"].toLowerCase().contains(value);
        } else {
          return e["title"].toLowerCase().contains(value);
        }
      }).toList();

      setState(() {
        listAttribute = list;
      });
    } else {
      setState(() {
        listAttribute = widget.listAttribute;
      });
    }
  }

  checkIssueCount(item) {
    if (widget.selectedCheckbox != null && widget.selectedCheckbox.length > 0) {
      final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
      List issues = currentChannel["issues"] != null ? 
        currentChannel["issues"].where((e) => widget.selectedCheckbox.contains(e["id"]) == true).toList()
        : [];

      List openIssues = issues.where((e) => !e["is_closed"]).toList();
      List closedIssues = issues.where((e) => e["is_closed"]).toList();
      int count;
      var issueClosedTab = Provider.of<Work>(context, listen: false).issueClosedTab;
      if (widget.title == "Milestones") {
        count = (!issueClosedTab ? openIssues : closedIssues)
        .where((e) => e["milestone_id"] == item["id"]).toList().length;
      } else {
        count = (!issueClosedTab ? openIssues : closedIssues)
        .where((e) => e[(widget.title == "Label" ? "labels" : "assignees")]
        .contains(item["id"])).toList().length;
      }

      if (count == 0) {
        return 0;
      } else if (count < widget.selectedCheckbox.length) {
        return 1;
      } else {
        return 2;
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    return InkWell(
      onTap: () {
        this.setState(() {
          defaultSelected = widget.selectedAtt != null ? List.from(widget.selectedAtt) : [];
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  backgroundColor: isDark ? Color(0xff1F2933) : Colors.white,
                  elevation: 0,
                  child: widget.title == "Sort" ? SortList(sortBy: widget.sortBy, changeSort: widget.changeSort) : Container(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    height: 480,
                    width: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 18),
                          child: Text(
                            widget.title == "Assignee" ? widget.selectedCheckbox != null ? "Assign someone" : "Filter by who’s assigned" : 
                            widget.title == "Milestones" ? widget.selectedCheckbox != null ? "Set milestone" : "Filter by milestone" :
                            widget.title == "Label" ? widget.selectedCheckbox != null ? "Apply labels" : "Filter by label" 
                            : "Filter by author",
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5)
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: isDark ? Color(0xff323F4B) : Colors.grey[300]!),
                              bottom: BorderSide(color: isDark ? Color(0xff323F4B) : Colors.grey[300]!)
                            )
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                          child: CupertinoTextField(
                            onChanged: (value) {
                              onFilterAttribute(value.toLowerCase());

                              Timer(Duration(milliseconds: 100), () {
                                setState(() {});
                              });
                            },
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            style: TextStyle(fontSize: 14, color: isDark ? Colors.white54 : Colors.grey[700]),
                            placeholder: widget.title == "Milestones" ? "Filter milestone" : widget.title == "Labels" ? "Filter labels" : "Type or choose a name",
                            placeholderStyle: TextStyle(fontFamily: "Roboto"),
                          ),
                        ),
                        Container(
                          height: 368,
                          child: SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: listAttribute.length,
                              itemBuilder: (BuildContext context, int index) {
                                var item = listAttribute[index];

                                return InkWell(
                                  onTap: () async {
                                    var count = checkIssueCount(item);
                                    await widget.onSelectAtt(widget.title, item, count == 2 ? true : false);

                                    if (!(widget.selectedCheckbox != null && widget.selectedCheckbox.length > 0 && widget.title == "Milestones")) {
                                      Timer(Duration(milliseconds: (widget.selectedCheckbox != null && widget.selectedCheckbox.length > 0) ? 0 : 100), () {
                                        if (this.mounted) {
                                          setState(() {});
                                        }
                                      });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: isDark ? Color(0xff323F4B) : Colors.grey[300]!))
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            (widget.selectedCheckbox != null && checkIssueCount(item) == 2) ? 
                                            Icon(Icons.check, size: 20, color: Colors.grey[700]) :
                                            (widget.selectedCheckbox != null && checkIssueCount(item) == 1) ? 
                                            Icon(Icons.remove_rounded, size: 20, color: Colors.grey[700]) :
                                            widget.selectedAtt.contains(item["id"]) ? 
                                            Icon(Icons.check, size: 20, color: Colors.grey[700]) : Container(width: 20, height: 20),
                                            
                                            SizedBox(width: 4),
                                            
                                            if (widget.title != "Milestones") (widget.title == "Label") ?
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                color: Color(int.parse("0xFF${listAttribute[index]["color_hex"]}")),
                                                borderRadius: BorderRadius.circular(50)
                                              ),
                                            ) : CachedImage(
                                              item["avatar_url"],
                                              height: 28,
                                              width: 28,
                                              radius: 50,
                                              name: item["full_name"],
                                            ),

                                            if (widget.title != "Milestones") SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                widget.title == "Milestones" ? item["title"] :  widget.title == "Label" ? item["name"] : item["full_name"],
                                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ]
                                        ),
                                        SizedBox(height: 6),
                                        if (widget.title != "Author" && widget.title != "Assignee") Row(children: [
                                          SizedBox(width: 24),
                                          Container(
                                            constraints: BoxConstraints(maxWidth: 340),
                                            child: widget.title == "Milestones" ? renderDueDate(item) :
                                            Text(item["description"], style: TextStyle(color: Colors.grey[700]))),
                                          ],
                                        )
                                      ]
                                    )
                                  )
                                );
                              }
                            ),
                          ),
                        ),
                      ],
                    )
                  )
                );
              }
            );
          }
        ).then((val){
          this.setState(() {
            listAttribute = widget.listAttribute ?? [];
          });

          if (!ListEquality().equals(widget.selectedAtt, defaultSelected)) {
            widget.onFilterIssue();
          }
        });
      },
      child: Container(
        padding: EdgeInsets.only(left: 6, right: 1, top: 2, bottom: 2),
        decoration: BoxDecoration(
          color: (widget.selectedAtt != null && widget.selectedAtt.length > 0) ? isDark ? Color(0xff1f354a) : Colors.lightBlue[50] : isDark ? Color(0xff323F4B) : Color(0xffeeeef1),
          border: Border.all(color: (widget.selectedAtt != null && widget.selectedAtt.length > 0) ? Colors.blue : isDark ? Color(0xff616E7C) :Color(0xffe9e9ec), width: 1),
          borderRadius: BorderRadius.circular(6)
        ),
        child: Row(
          children: [
            Container(child: Text("${widget.title}", style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontWeight: FontWeight.w500))),
            SizedBox(width: 4,),
            Icon(Icons.arrow_drop_down, color: isDark ? Colors.white : Colors.grey[700], size: 20)
          ],
        ),
      ),
    );
  }
}
