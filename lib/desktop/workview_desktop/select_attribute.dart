import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/models/models.dart';

import 'label.dart';

class SelectAttribute extends StatefulWidget {
  const SelectAttribute({
    Key? key,
    this.issue,
    @required this.title,
    @required this.icon,
    @required this.listAttribute,
    @required this.selectedAtt,
    @required this.selectAttribute,
    this.selectFocus
  }) : super(key: key);

  final issue;
  final title;
  final icon;
  final listAttribute;
  final selectedAtt;
  final selectAttribute;
  final Function? selectFocus;

  @override
  _SelectAttributeState createState() => _SelectAttributeState();
}

class _SelectAttributeState extends State<SelectAttribute> {
  List listAttribute = [];
  List selectedDefault = [];

  @override
  void initState() { 
    super.initState();
    this.setState(() {
      listAttribute = widget.listAttribute;
    });
  }

  @override
  void didUpdateWidget(oldWidget){
    if (oldWidget.listAttribute != widget.listAttribute)
      listAttribute = widget.listAttribute;
    super.didUpdateWidget(oldWidget);
  }

  String text = "";

  getListLabel() {
    var listLabel = [];
    for(int index = 0; index < widget.selectedAtt.length; index++) {
      var itemIndex = widget.listAttribute.indexWhere((e) => e["id"] == widget.selectedAtt[index]);
      var item = itemIndex != -1 ? widget.listAttribute[itemIndex] : null;
      if(item == null) {
        return [];
      }
      listLabel.add(item);
    }
    return listLabel;
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

  renderDueDate({milestone, isIcon = false}) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final DateTime now = DateTime. now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final formatted = formatter. format(now);
    final isPast = (milestone["due_date"].compareTo(formatted) < 0);
    
    return isIcon ? Container(
      padding: EdgeInsets.only(left: 16),
      child: Icon(isPast ? Icons.warning_amber_outlined : Icons.calendar_today_outlined,
      size: 19,
      color: isPast ? Color(0xffEB5757) : isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))
    ) : Container(
      child:
        Text(
          milestone["due_date"] != null ? 
          isPast ? calculateDueby(milestone["due_date"]) :
          "Due by " + (DateFormatter().renderTime(DateTime.parse(milestone["due_date"]), type: "yMMMMd")) : "",
          style: TextStyle(color: isPast ? Color(0xffEB5757) : isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 12, fontWeight: isPast ? FontWeight.w600 : FontWeight.w400)
        ),
    );
  }

  getColorHex(labelId) {
    final index = widget.listAttribute.indexWhere((e) => e["id"] == labelId);

    if (index != -1) {
      return widget.listAttribute[index]["color_hex"];
    } else {
      return 000000;
    }
  }

  calculateMilestone(milestone) {
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final List milestonesStatistical = currentChannel["milestonesStatistical"] ?? [];

    int closed = 0;
    int open = 0;
    double percent = 0;
    for(var ms in milestonesStatistical) {
      if(ms["id"] == milestone["id"]) {
        closed = ms["close_issue"].length == 0 ? 0 : ms["close_issue"][0];
        open = ms["open_issue"].length == 0 ? 0 : ms["open_issue"][0];
        percent = open + closed > 0 ? closed / (open + closed) * 100 : 0;
        break;
      }
    }

    return {
      "closed": closed,
      "open": open,
      "percent": percent
    };
  }

  onRemoveAttribute(attributeId) {
    final index = widget.listAttribute.indexWhere((e) => e["id"] == attributeId);

    if (index != -1) {
      widget.selectAttribute(widget.listAttribute[index]);
    }
  }

  onFilterAttribute(value) {
    if (value.trim() != "") {
      List list = widget.listAttribute.where((e) {
        if (widget.title == "Assignees") {
          return e["full_name"].toLowerCase().contains(value) ? true : false;
        } else if (widget.title == "Labels") {
          return e["name"].toLowerCase().contains(value) ? true : false;
        } else {
          return e["title"].toLowerCase().contains(value) ? true : false;
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final channelMember = Provider.of<Channels>(context, listen: true).channelMember;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final workspaceMember = Provider.of<Workspaces>(context, listen: true).members;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            this.setState(() {
              selectedDefault = List.from(widget.selectedAtt);
            });
            // FocusScope.of(context).unfocus();

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Dialog(
                      backgroundColor: isDark ? Color(0xff1F2933) : Colors.white,
                      elevation: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4)
                        ),
                        padding: EdgeInsets.only(bottom: 12),
                        height: 480,
                        width: 400,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xff52606D),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(3), topRight: Radius.circular(3))
                              ),
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              child: Text(
                                widget.title == "Labels" ? "Apply labels to this issue" : widget.title == "Milestone" ? "Set milestone" : "Assign up to ${channelMember.length} people to this issue", 
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5, color: Colors.white)
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: isDark ? Color(0xff323F4B) : Color(0xffCBCD2D9)),
                                  bottom: BorderSide(color: isDark ? Color(0xff323F4B) : Color(0xffCBCD2D9))
                                )
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                              height: 64,
                              child: TextFormField(
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: widget.title == "Milestone" ? "Filter milestone" : widget.title == "Labels" ? "Filter labels" : "Type or choose a name",
                                  hintStyle: TextStyle(color: isDark ? Color(0xFFD9D9D9) : Color.fromRGBO(0, 0, 0, 0.35),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                    fontFamily: "Roboto"
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Color(0xff323F4B) : Color(0xffCBCD2D9)), borderRadius: BorderRadius.all(Radius.circular(4))),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Color(0xff323F4B) : Color(0xffCBCD2D9)), borderRadius: BorderRadius.all(Radius.circular(4))),
                                ),
                                style: TextStyle(color:isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 13, fontWeight: FontWeight.w400),
                                onChanged: (value) {
                                  onFilterAttribute(value.toLowerCase());
                                  setState(() {});
                                },
                              ),
                            ),
                            Container(
                              height: 362,
                              child: SingleChildScrollView(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: listAttribute.length, 
                                  itemBuilder: (BuildContext context, int index) {
                                    var item = listAttribute[index];

                                    return InkWell(
                                      onTap: () async {
                                        await widget.selectAttribute(item);
                                        Timer(Duration(milliseconds: 100), () {
                                          setState(() {
                                          });
                                        });

                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: isDark ? Color(0xff323F4B) : Color(0xffCBCD2D9)),
                                          ),
                                          color: widget.selectedAtt.contains(item["id"]) && widget.title == "Milestone" ? (isDark ? Color(0xff323F4B) : Color(0xffE4E7EB)) : Colors.transparent,
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                        child: Row(
                                          children: [
                                            if(widget.title == "Milestone")
                                            renderDueDate(milestone: item, isIcon: true),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    widget.selectedAtt.contains(item["id"]) && widget.title != "Milestone" ? Icon(CupertinoIcons.checkmark_alt_circle_fill, size: 16, color: isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : Container(width: 16, height: 16),
                                                    if (widget.title != "Milestone") SizedBox(width: 12),

                                                    if (widget.title == "Assignees")
                                                    CachedImage(
                                                      item["avatar_url"],
                                                      height: 24,
                                                      width: 24,
                                                      radius: 50,
                                                      name: item["full_name"],
                                                    ),

                                                    if (widget.title == "Assignees") SizedBox(width: 12),

                                                    Container(
                                                      padding: EdgeInsets.symmetric(vertical: widget.title != "Milestone" ? 4 : 0, horizontal: widget.title == "Labels" ? 8 : 0),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(16),
                                                        color: widget.title == "Labels" ? Color(int.parse("0xFF${listAttribute[index]["color_hex"]}")) : Colors.transparent,
                                                      ),
                                                      child: Text(
                                                        widget.title == "Milestone" ? item["title"] :  widget.title == "Labels" ? item["name"] : item["full_name"], 
                                                        style: TextStyle(color: widget.title == "Labels" ? Colors.white : (isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 065)), fontWeight: widget.title == "Labels" ? FontWeight.w400 : FontWeight.w600, fontSize: widget.title == "Labels" ? 12 : 14)
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                if (widget.title == "Milestone") Container(
                                                  margin: EdgeInsets.only(top: 6),
                                                  child: Row(children: [
                                                    Container(
                                                      margin: EdgeInsets.only(left: 16),
                                                      child: widget.title == "Milestone" ? renderDueDate(milestone: item) : 
                                                      Text(item["description"], style: TextStyle(color: Colors.grey[700]))),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
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
            ).then((e) async {
              if (widget.issue != null) {
                List added = [];
                List removed = [];

                for (var item in widget.selectedAtt) {
                  if (!selectedDefault.contains(item)) {
                    added.add(item);
                  }
                }

                for (var item in selectedDefault) {
                  if (!widget.selectedAtt.contains(item)) {
                    removed.add(item);
                  }
                }

                if (added.length > 0 || removed.length > 0) {
                  Map data = {
                    "type": widget.title.toLowerCase(),
                    "added": added,
                    "removed": removed
                  };

                  await Provider.of<Channels>(context, listen: false).updateIssueTimeline(auth.token, currentWorkspace["id"], currentChannel["id"], widget.issue["id"], data);
                }

                setState(() {
                  listAttribute = widget.listAttribute;
                  selectedDefault = [];
                });
              }
              if (widget.selectFocus != null) {
                widget.selectFocus!();
              }
            });
          },
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 300
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isDark ? Color(0xff52606D) : Color(0xffE4E7EB),
            ),
            width: (MediaQuery.of(context).size.width *1/4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${widget.title}", style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: FontWeight.w700)),
                widget.icon
              ]
            )
          )
        ),

        widget.selectedAtt.length == 0 ? Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  height: 24,
                  child: Text(
                    widget.title == "Milestone" ? "No milestone" : widget.title == "Labels" ? "None yet" : "No one-assign yourself", 
                    style: TextStyle(color: isDark ? Color(0xffD9D9D9) : Color.fromRGBO(0, 0, 0, 0.45), fontSize: 12)
                  ),
                ),
              ),
            ],
          ),
        )
        : widget.title != "Labels" ? Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: widget.selectedAtt.length,
            itemBuilder: (BuildContext context, int index) {
              var itemIndex = (widget.title == "Assignees" ? workspaceMember : widget.listAttribute).indexWhere((e) => e["id"] == widget.selectedAtt[index]);
              var item = itemIndex != -1 ? (widget.title == "Assignees" ? workspaceMember : widget.listAttribute)[itemIndex] : null;

              return item == null ? Container() : Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.title == "Milestone" ? Container(
                      margin: EdgeInsets.only(top: 4),
                      height: 5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          value: calculateMilestone(item)["percent"]/100,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff27AE60)),
                          backgroundColor: Color(0xffD6D6D6),
                        ),
                      ),
                    )
                    : Container(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (widget.title == "Assignees") Container(
                              margin: EdgeInsets.only(right: 8),
                              child: CachedImage(
                                item["avatar_url"],
                                height: 24,
                                width: 24,
                                radius: 50,
                                name: item["full_name"],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: widget.title == "Milestone" ? 12 : 0),
                              child: Text(
                                widget.title == "Milestone" ? item["title"] : item["full_name"], 
                                style: TextStyle(fontWeight: widget.title != "Milestone" ? FontWeight.w400 : FontWeight.w700, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      ]
                    )
                  ]
                )
              );
            }
          ),
        ) : Container(
          child: widget.selectedAtt.length == 0 ? Container(
            child: Text("None yet"),
          ) : Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Wrap(
              children: getListLabel().map<Widget>((e) {
                var label = e;
                return Container(
                  padding: EdgeInsets.only(top: 4, bottom: 4, right: 4),
                  child: LabelDesktop(labelName: label["name"], color: int.parse("0XFF${label["color_hex"]}"))
                );
              })?.toList()
            )
          )
        )
      ]
    );
  }
}
