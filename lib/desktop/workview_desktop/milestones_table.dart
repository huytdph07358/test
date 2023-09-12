import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/models/models.dart';

class MilestonesTable extends StatefulWidget {
  MilestonesTable({
    Key? key,
    this.createMilestone,
    this.closeTable,
    this.onSelectMilestone
  }) : super(key: key);

  final createMilestone;
  final closeTable;
  final onSelectMilestone;

  @override
  _MilestonesTableState createState() => _MilestonesTableState();
}

class _MilestonesTableState extends State<MilestonesTable> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  var selectedMilestone;
  DateTime dateTime = DateTime.now();
  int tab = 1;

  _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != dateTime) {
      changeMilestoneDate(picked);
    }
  }

  changeMilestoneDate(picked) async {
    this.setState(() {
      dateTime = picked;
    });
  }

  onCreateMilestone() {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    if (Utils.checkedTypeEmpty(_titleController.text)) {
      Map milestone = {
        "title": _titleController.text,
        "description": _descriptionController.text,
        "due_date": dateTime.toUtc().millisecondsSinceEpoch~/1000 + 86400
      };

      Provider.of<Channels>(context, listen: false).createChannelMilestone(token, currentWorkspace["id"], currentChannel["id"], milestone);
      _titleController.clear();
      _descriptionController.clear();
      widget.closeTable();
    }
  }

  selectMilestone(milestone) {
    _titleController.text = milestone["title"];
    _descriptionController.text = milestone["description"];

    this.setState(() {
      selectedMilestone = milestone;
    });
  }

  updateMilestone() {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    Map milestone = {
      "id": selectedMilestone["id"],
      "title": _titleController.text,
      "description": _descriptionController.text,
      "due_date": dateTime.toUtc().millisecondsSinceEpoch~/1000 + 86400
    };

    Provider.of<Channels>(context, listen: false).updateMilestone(token, currentWorkspace["id"], currentChannel["id"], milestone);
    _titleController.clear();
    _descriptionController.clear();
    widget.closeTable();
    
    this.setState(() {
      selectedMilestone = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    String dateString =  DateFormatter().renderTime(dateTime, type: "dd-MM-yyyy");
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    List milestones = currentChannel["milestones"] != null ? currentChannel["milestones"] : [];
    List openMilestones = milestones.where((e) => !e["is_closed"]).toList();
    List closedMilestones = milestones.where((e) => e["is_closed"]).toList();
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      // width: (MediaQuery.of(context).size.width - 300),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          if (widget.createMilestone || selectedMilestone != null) Container(
            width: (MediaQuery.of(context).size.width - 300),
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Color(0xff323F4B) : Color(0xfff6f8fa),
              border: Border.all(
                color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9)
              ),
              borderRadius: BorderRadius.circular(3)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 102.0,
                              child: Text("Title", style: TextStyle(fontWeight: FontWeight.w500))
                            ),
                            SizedBox(width: 16.0,),
                            Expanded(
                              child: Container(
                                height: 32.0,
                                constraints: const BoxConstraints(
                                  maxWidth: 800.0
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: isDark ? Color(0xff1F2933) : Colors.white,
                                ),
                                child: TextFormField(
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                    hintText: "Add Title",
                                    hintStyle: TextStyle(color: Color(0xff9AA5B1), fontWeight: FontWeight.w300, fontSize: 13.0),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9))),
                                  ),
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
                                  onChanged: (value) {
                                    this.setState(() {});
                                  }
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0,),
                      Container(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 102.0,
                              child: Text("Due date (Opt)", style: TextStyle(fontWeight: FontWeight.w500))
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: isDark ? Color(0xff1F2933) : Colors.white,
                                  border: Border.all(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9))
                                ),
                                child: GestureDetector(
                                  onTap: () {  
                                    _selectDate(context);
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          dateString, 
                                          style: TextStyle(color: isDark ? Colors.white.withOpacity(0.85) : Color(0xff1F2933), fontSize: 13.0, fontWeight: FontWeight.w300)
                                        ),
                                        Icon(Icons.calendar_today_outlined, size: 18.0, color: isDark ? Colors.white.withOpacity(0.85) : Color(0xff1F2933))
                                      ],
                                    ),
                                  )
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0,),
                      Container(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 102.0,
                              child: Text("Description", style: TextStyle(fontWeight: FontWeight.w500))
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Container(
                                height: 32.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  color: isDark ? Color(0xff1F2933) : Colors.white,
                                ),
                                child: TextFormField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                                    hintText: "Add Description",
                                    hintStyle: TextStyle(color: Color(0xff9AA5B1), fontWeight: FontWeight.w300, fontSize: 13.0),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9))),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9))),
                                  ),
                                  onChanged: (value) {
                                    this.setState(() {});
                                  }
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.0,),
                Container(
                  padding: EdgeInsets.only(left: 16.0),
                  width: MediaQuery.of(context).size.width - 844,
                  constraints: BoxConstraints(maxWidth: 360.0),
                  height: 116,
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9)))
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        child: TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                                side: BorderSide(color: Color(0xffFF7875))
                              ),
                            ),
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16.0)),
                            backgroundColor: MaterialStateProperty.all(
                              isDark ? Colors.transparent : Colors.white
                            )
                          ),
                          onPressed: () {
                            _titleController.clear();
                            _descriptionController.clear();
                            widget.closeTable();

                            this.setState(() {
                              selectedMilestone = null;
                            });
                          },
                          child: Text("Cancel", style: TextStyle(color: Color(0xffFF7875)),),
                        ),
                      ),
                      SizedBox(height: 8.0),
                      SizedBox(
                        width: 140,
                        child: TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              )
                            ),
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16.0)),
                            backgroundColor: MaterialStateProperty.all(isDark ? Color(0xff19DFCB) : Color(0xff2A5298))
                          ),
                          onPressed: () {
                            if (selectedMilestone == null) {
                              onCreateMilestone();
                            } else {
                              updateMilestone();
                            }
                          },
                          child: Text(selectedMilestone == null ? "Create milestone" : "Save changes", style: TextStyle(color: isDark ? Colors.black.withOpacity(0.85) : Colors.white.withOpacity(0.85)))
                        ),
                      ),
                    ],
                  ),
                )
              ]
            )
          ),
          Container(
            decoration: BoxDecoration(
             border: Border.all(
                color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9)
              ),
              borderRadius: BorderRadius.circular(4.0)
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                  // width: (MediaQuery.of(context).size.width - 300),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff323F4B) : Color(0xffF6F8FA),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(3.0), topLeft: Radius.circular(3.0))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                this.setState(() {
                                  tab = 1;
                                });
                              },
                              child: Text(
                                "${openMilestones.length} Milestones",
                                style: TextStyle(
                                  color: tab == 1
                                    ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298))
                                    : (isDark ? Color(0xffBFBFBF) : Color(0xff7B8794)),
                                    fontWeight: FontWeight.w500
                                )
                              )
                            ),
                            SizedBox(width: 12.0),
                            InkWell(
                              onTap: () {
                                this.setState(() {
                                  tab = 2;
                                });
                              },
                              child: Text(
                                "${closedMilestones.length} Closed",
                                style: TextStyle(
                                  color: tab == 2
                                    ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298))
                                    : (isDark ? Color(0xffBFBFBF) : Color(0xff7B8794)),
                                    fontWeight: FontWeight.w500
                                )
                              )
                            )
                          ],
                        )
                      ),
                      Row(
                        children: [
                         Container(child: Text("Sort", style: TextStyle(color: isDark ? Colors.white.withOpacity(0.85) : Color(0xff1F2933), fontSize: 13.5))),
                          Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white.withOpacity(0.85) : Color(0xff1F2933), size: 18.0)
                        ]
                      )
                    ]
                  )
                ),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: (MediaQuery.of(context).size.height - ((widget.createMilestone || selectedMilestone != null) ? 430 : 240))
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tab == 1 ? openMilestones.length : closedMilestones.length,
                    itemBuilder: (BuildContext context, int index) {  
                      var milestone = tab == 1 ? openMilestones[index] : closedMilestones[index];

                      return Container(
                        padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9)))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                // width: (MediaQuery.of(context).size.width - 380) / 3,
                                constraints: BoxConstraints(maxWidth: 400),
                                padding: EdgeInsets.only(bottom: 16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        widget.onSelectMilestone(milestone);
                                      },
                                      child: Text(milestone["title"], style: TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white.withOpacity(0.90) : Color(0xff1F2933).withOpacity(0.95)
                                      )),
                                    ),
                                    SizedBox(height: 8),
                                    MilestoneDetail(milestone: milestone),
                                    SizedBox(height: milestone["description"] != "" ? 8 : 0),
                                    milestone["description"] != "" ? Container(
                                      margin: EdgeInsets.only(left: 2.0),
                                      child: Text(
                                        milestone["description"],
                                        style: TextStyle(color: isDark ? Color(0xffBFBFBF) : Color(0xff615E7C), fontSize: 13.5)
                                      ),
                                    ) : SizedBox()
                                  ]
                                )
                              ),
                            ),
                            Expanded(
                              flex: 12,
                              child: Container(
                                // width: (MediaQuery.of(context).size.width - 380) / 3 * 1.8,
                                child: MilestoneProgress(milestone: milestone, selectMilestone: selectMilestone, index: index),
                              ),
                            ),
                          ]
                        )
                      );
                    }
                  ),
                )
              ]
            )
          )
        ]
      )
    );
  }
}

class MilestoneProgress extends StatefulWidget {
  const MilestoneProgress({
    Key? key,
    this.milestone,
    this.selectMilestone,
    this.index
  }) : super(key: key);

  final milestone;
  final selectMilestone;
  final index;

  @override
  _MilestoneProgressState createState() => _MilestoneProgressState();
}

class _MilestoneProgressState extends State<MilestoneProgress> {

  calculateMilestone(index) {
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final milestonesStatistical = currentChannel["milestonesStatistical"] != null ? currentChannel["milestonesStatistical"] : [];
    final milestone = widget.milestone;

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

  onCloseMilestone() {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    Provider.of<Channels>(context, listen: false).closeMilestone(token, currentWorkspace["id"], currentChannel["id"], widget.milestone["id"], !widget.milestone["is_closed"]);
  } 

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            child: LinearProgressIndicator(
              value: calculateMilestone(widget.index)["percent"]/100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
              backgroundColor: Color(0xffD6D6D6),
            ),
          ),
        ),
        SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Wrap(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                width: 286,
                child: Row(
                  children: [
                    Text("${calculateMilestone(widget.index)["percent"].toStringAsFixed(0)} %", style: TextStyle(color: isDark ? Colors.white : Color(0xff1F2933))),
                    SizedBox(width: 3),
                    Text("complete", style: TextStyle(color: isDark ? Color(0xffBFBFBF) : Color(0xff616E7C))),
                    SizedBox(width: 18),
                    Text("${calculateMilestone(widget.index)["open"]}", style: TextStyle(color: isDark ? Colors.white : Color(0xff1F2933))),
                    SizedBox(width: 3),
                    Text("open", style: TextStyle(color: isDark ? Color(0xffBFBFBF) : Color(0xff616E7C))),
                    SizedBox(width: 18),
                    Text("${calculateMilestone(widget.index)["closed"]}", style: TextStyle(color: isDark ? Colors.white : Color(0xff1F2933))),
                    SizedBox(width: 3),
                    Text("closed", style: TextStyle(color: isDark ? Color(0xffBFBFBF) : Color(0xff616E7C)))
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                width: 142,
                child: Row(
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {
                        widget.selectMilestone(widget.milestone);
                      },
                      child: Text("Edit", style: TextStyle(color: Colors.blue))
                    ),
                    SizedBox(width: 12),
                    InkWell(
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {
                        onCloseMilestone();
                      },
                      child: Text(!widget.milestone["is_closed"] ? "Close" : "Reopen", style: TextStyle(color: Colors.blue))),
                    SizedBox(width: 18),
                    InkWell(
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {
                        showConfirmDialog(context, widget.milestone["id"]);
                      },
                      child: Text("Delete", style: TextStyle(color: Colors.red))
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MilestoneDetail extends StatelessWidget {
  const MilestoneDetail({
    Key? key,
    @required this.milestone,
  }) : super(key: key);

  final milestone;

  calculateDueby(due) {
    final DateTime now = DateTime. now();
    final pastDay = now.difference(DateTime.parse(due)).inDays;
    final pastMonth = pastDay ~/ 30;

    if (pastMonth > 0) {
      return " ${pastMonth.toString()} ${pastMonth > 1 ? "months" : "month"}";
    } else {
      return " ${pastDay.toString()} ${pastDay > 1 ? "days" : "day"}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final DateTime now = DateTime. now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final formatted = formatter. format(now);
    final isPast = (milestone["due_date"].compareTo(formatted) < 0);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 22,
          child: Icon(
            isPast ? Icons.warning_amber_outlined : Icons.calendar_today_outlined, 
            size: 18.0,
            color: isPast ? Color(0xffEB5757) : isDark ? Color(0xffBFBFBF) : Color(0xff615E7C)
          )
        ),
        SizedBox(width: 6),
        Container(
          padding: EdgeInsets.symmetric(vertical: 3),
          height: 22,
          child: Text(isPast ? "Past due by" : "Due by ", style: TextStyle(color: isPast ? Color(0xffEB5757) : isDark ? Color(0xffBFBFBF) : Color(0xff615E7C), fontSize: 13.5))
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 3),
          height: 22,
          child: Text(
            isPast ? calculateDueby(milestone["due_date"]) :
            milestone["due_date"] != null ? (DateFormatter().renderTime(DateTime.parse(milestone["due_date"]), type: "yMMMMd")) : "",
            style: TextStyle(color: isPast ? Color(0xffEB5757) : isDark ? Color(0xffBFBFBF) : Color(0xff615E7C), fontSize: 13.5)
          ),
        ),
      ],
    );
  }
}

showConfirmDialog(context, labelId) {
  final token = Provider.of<Auth>(context, listen: false).token;
  final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
  final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
  
  onDeleteLabel() {
    Provider.of<Channels>(context, listen: false).deleteAttribute(token, currentWorkspace["id"], currentChannel["id"], labelId, "milestone");
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialogNew(
        title: "Delete Milestone", 
        content: "Are you sure want to delete miletsone?\nThis action cannot be undone.",
        confirmText: "Delete Milestone",
        onConfirmClick: onDeleteLabel,
        quickCancelButton: true,
      );
    }
  );
}