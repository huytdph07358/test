import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/desktop/workview_desktop/label.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/work_screen/issues.dart';

import '../../generated/l10n.dart';

class SelectAttribute extends StatefulWidget {
  SelectAttribute({
    Key? key,
    this.issue,
    this.type
  }) : super(key: key);

  final issue;
  final type;

  @override
  _SelectAttributeState createState() => _SelectAttributeState();
}

class _SelectAttributeState extends State<SelectAttribute> {
  String textSearch = '';
  bool onCreateAttribute = false;
  List sortedMember = [];

  @override
  void initState() {
    super.initState();
    if (widget.type == "assignee") {
      this.setState(() {
        sortedMember = getSortedListMember();
      });
    }
  }

  getSortedListMember() {
    List members = Provider.of<Channels>(context, listen: false).channelMember;
    final channelId = Provider.of<Channels>(context, listen: false).currentChannel["id"];
    Map<String, List<String>> dataAssigneeChannels = Provider.of<Channels>(context, listen: false).dataAssigneeChannels;
    List<String>? sortAssignees = dataAssigneeChannels["$channelId"];

    if (sortAssignees != null) {
      List sorted = [];
      for (var i = 0; i < sortAssignees.length; i++) {
        final idx = members.indexWhere((e) => e["id"] == sortAssignees[i]);
        if (idx != -1) {
          sorted.add(members[idx]);
        }
      }
      members = sorted + members.where((e) => !sorted.contains(e)).toList();
    }

    return members;
  }

  onSearchAttribute(value) {
    this.setState(() {
      textSearch = value;
    });
  }

  Map getDataChannel(){
    try {
      List channels = Provider.of<Channels>(context, listen: false).data;
      int index  = channels.indexWhere((element) => "${element["id"]}" == "${widget.issue["channel_id"]}");

      return {
        "channel_id": channels[index]["id"],
        ...channels[index]
      };
    } catch (e) {
      print("getDataChannel: $e");
      return {};
    }
  }

  getListAttribute(list, selectedAttribute) {
    List newList = [];

    if (textSearch.trim() != '') {
       if (widget.type == "label") {
        newList = list.where((e) => Utils.unSignVietnamese(e["name"]).contains(Utils.unSignVietnamese(textSearch)) == true).toList();
      } else if (widget.type == "assignee") {
        newList = list.where((e) => Utils.unSignVietnamese(e["full_name"]).contains(Utils.unSignVietnamese(textSearch)) == true).toList();
      } else {
        newList = list.where(
          (e) => DateFormatter().renderTime(DateTime.parse(Utils.unSignVietnamese(e["due_date"])), type: "MMMd").contains(Utils.unSignVietnamese(textSearch)) == true
        ).toList();
      }
    } else {
     newList = list;
    }

    return newList;
  }

  onCreateLabel(text, colorHex) async {
    final currentChannel = getDataChannel();
    final token = Provider.of<Auth>(context, listen: false).token;
    List labels = currentChannel["labels"];

    final index = labels.indexWhere((e) => e["name"] == text);

    if (text.trim() == "") return;

    if (index == -1) {
      Map label = {
        "name": text,
        "description": "",
        "color_hex": colorHex.toString(),
        "issues": 0
      };

      await Provider.of<Channels>(context, listen: false).createChannelLabel(token, currentChannel["workspace_id"], currentChannel["id"], label);
      this.setState(() { textSearch = ""; onCreateAttribute = false;});
    }
  }

  onCreateMilestone(text, date) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentChannel = getDataChannel();
    Map milestone = {
      "title": text,
      "description": "",
      "due_date": date.toUtc().millisecondsSinceEpoch~/1000 + 86400
    };

    Provider.of<Channels>(context, listen: false).createChannelMilestone(token, currentChannel["workspace_id"], currentChannel["id"], milestone);
    this.setState(() { textSearch = ""; onCreateAttribute = false; });
  }

  editAttribute(attribute) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    Navigator.pop(context);

    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      builder: (BuildContext context) {     
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xff353a3e) : Colors.white,
            borderRadius: BorderRadius.circular(15.0)
          ),
          height: MediaQuery.of(context).size.height*0.85,
          child: EditAttribute(type: widget.type, attribute: attribute)
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final issue = widget.issue;
    final channelMember = sortedMember;
    final currentChannel = getDataChannel();
    List listAttribute = widget.type == "label" ? currentChannel["labels"] : widget.type == "assignee" ? channelMember : currentChannel["milestones"];
    List selectedAttribute = widget.type == "label" ? issue["labels"] != null ? listAttribute.where((e) => issue["labels"].contains(e["id"]) == true).toList() : []
      : widget.type == "assignee" ? issue["assignees"] != null ? listAttribute.where((e) => issue["assignees"].contains(e["id"]) == true).toList() : []
      : listAttribute.where((e) => issue["milestone_id"] == e["id"]).toList();
    
    listAttribute = getListAttribute(listAttribute, selectedAttribute);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xff3D3D3D) : Colors.white,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => { 
                          if (onCreateAttribute) {
                            this.setState(() {
                              onCreateAttribute = false;
                            })
                          } else {
                            Navigator.of(context).pop()
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Icon(PhosphorIcons.arrowLeft, size: 20, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)),
                        ),
                      ),
                      Container(
                        child: Text(
                          widget.type == "label" ? S.current.labels : widget.type == "assignee" ? S.current.assignees : S.current.milestones,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          )
                        )
                      ),
                      Container(child: Center(child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(S.current.done, style: TextStyle(fontSize: 16, color: isDark ? Color(0xffFAAD14) : Colors.blueAccent, fontWeight: FontWeight.w500)))), margin: EdgeInsets.only(right: 14)
                      )
                    ]
                  )
                ),
                Container(
                  color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: SearchBar(onSearchAttribute: onSearchAttribute)
                  )
                ),
                (onCreateAttribute) ? widget.type == "label"
                  ? CreateAttribute(textSearch: textSearch, onCreateLabel: onCreateLabel) 
                  : CreateAttribute(textSearch: textSearch, onCreateMilestone: onCreateMilestone) 
                  : Expanded(
                  child: Container(
                    padding: EdgeInsets.only(bottom: 72),
                    child: SingleChildScrollView(
                      child: ListAttribute(listAttribute: listAttribute, isDark: isDark, issue: issue, type: widget.type, selectedAttribute: selectedAttribute, editAttribute: editAttribute)
                    )
                  )
                )
              ]
            ),
            if (!onCreateAttribute) Positioned(
              bottom: 24,
              left: 30,
              child: InkWell(
                onTap: () {
                  this.setState(() {
                    onCreateAttribute = true;
                  });
                },
                child: widget.type == "assignee" ? Container() : Container(
                  height: 36,
                  width: MediaQuery.of(context).size.width - 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isDark ? Color(0xffFAAD14) : Colors.blueAccent
                  ),
                  child: Center(child: Text(widget.type == "label" ? S.current.createNewLabel : S.current.createNewMilestone)),
                ),
              ),
            )
          ]
        )
      )
    );
  }
}

class CreateAttribute extends StatefulWidget {
  const CreateAttribute({
    Key? key,
    this.textSearch,
    this.onCreateLabel,
    this.onCreateMilestone,
    this.type
  }) : super(key: key);

  final textSearch;
  final onCreateLabel;
  final onCreateMilestone;
  final type;

  @override
  _CreateAttributeState createState() => _CreateAttributeState();
}

class _CreateAttributeState extends State<CreateAttribute> {
  List colors = [
    "1CE9AE", "0E8A16", "0052CC", "5319E7", "FF2C65", "FBA704", "D93F0B", "B60205", "CECECE",
    "57B99D", "65C87A", "5097D5", "925EB1", "D63964", "EAC545", "D8823B", "D65745", "98A5A6",
    "397E6B", "448852", "346690", "693B86", "9F2857", "B87E2E", "9C481B", "8D3529", "667C89"
  ];
  Random random = new Random();
  var pickedColor;
  var selectedDate = DateTime.now();
  TextEditingController textController = TextEditingController();

  @override
  void initState() { 
    super.initState();
    pickedColor = random.nextInt(26);
  }

  @override
  Widget build(BuildContext context) {  
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: isDark ? 0.8 : 0.4, color: isDark ? Color(0xff2e3235) : Colors.grey[400]!))
      ),
      child: Column(
        children: [
          Divider(),
          Container(
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: CupertinoTextField(
              controller: textController,
              decoration: BoxDecoration(
                color: isDark ? Color(0xff5E5E5E) : Color(0xffF3F3F3),
                borderRadius: BorderRadius.circular(4)
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15
              ),
              autofocus: true,
              placeholder: widget.onCreateLabel != null ? S.current.labelsName: S.current.milestoneTitle,
              placeholderStyle: TextStyle(
                color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E),
                fontSize: 16
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              onChanged: (value) {
                this.setState(() {});
              }
            )
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 22, right: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.onCreateLabel != null) Text("${S.current.createNewLabel}:  "),
                    widget.onCreateLabel != null ? LabelDesktop(
                      labelName: textController.text.trim(),
                      color: int.parse("0XFF${colors[pickedColor]}"), 
                    ) : Container(
                      width: MediaQuery.of(context).size.width - 44,
                      child: Column(
                        children: [
                          CalendarDatePicker(
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now().add(new Duration(days: 365)),
                            onDateChanged: (DateTime value) { 
                              setState(() {
                                selectedDate = value;
                              });
                            }
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                textController.text.trim() != "" ? textController.text.trim() 
                                : (DateFormatter().renderTime(DateTime.parse(selectedDate.toString()), type: "MMMd")), 
                                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20)
                              ),
                              SizedBox(width: 24),
                              InkWell(
                                onTap: () {
                                  widget.onCreateMilestone(textController.text.trim(), selectedDate); 
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: isDark ? Color(0xffFAAD14) : Colors.blueAccent
                                  ),
                                  child: Text(S.current.create, style: TextStyle(color: Colors.white, fontSize: 14))
                                )
                              )
                            ]
                          )
                        ]
                      )
                    ) 
                  ]
                ),
                if (widget.onCreateLabel != null && textController.text.trim() != "") InkWell(
                  onTap: () {
                    widget.onCreateLabel(textController.text, colors[pickedColor]);
                  },
                  child: Icon(Icons.add)
                )
              ]
            ),
          ),
          SizedBox(height: 16),
          if (widget.onCreateLabel != null) GridView.count(
            padding: EdgeInsets.only(top: 4, bottom: 12, left: 22, right: 22),
            shrinkWrap: true,
            primary: false,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            crossAxisCount: 9,
            children: colors.map((e) => 
              InkWell(
                onTap: () {
                  this.setState(() {
                    pickedColor = colors.indexWhere((color) => color == e);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(int.parse("0xFF$e")),
                    borderRadius: BorderRadius.circular(4.0)
                  ),
                  height: 10.0,
                  width: 10.0
                ),
              )
            ).toList(),
          )
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

class ListAttribute extends StatefulWidget {
  const ListAttribute({
    Key? key,
    required this.listAttribute,
    required this.isDark,
    this.issue,
    this.type,
    this.isFilter = false,
    this.onChangeFilter,
    this.selectedAttribute,
    this.editAttribute
  }) : super(key: key);

  final List listAttribute;
  final bool isDark;
  final issue;
  final type;
  final isFilter;
  final onChangeFilter;
  final selectedAttribute;
  final editAttribute;

  @override
  _ListAttributeState createState() => _ListAttributeState();
}

class _ListAttributeState extends State<ListAttribute> {
  List selectedAttribute = [];

  @override
  void initState() { 
    super.initState();
    selectedAttribute = widget.selectedAttribute;
  }

  Map getDataChannel(){
    try {
      List channels = Provider.of<Channels>(context, listen: false).data;
      int index  = channels.indexWhere((element) => "${element["id"]}" == "${widget.issue["channel_id"]}");
      return {
        "channel_id": channels[index]["id"],
        ...channels[index]
      };
    } catch (e) {
      print("getDataChannel: $e");
      return {};
    }
  }

  changeLabels(label) {
    final currentChannel = getDataChannel();
    List labels = currentChannel["labels"] != null ? currentChannel["labels"] : [];
    List selectedLabels = widget.issue["labels"] != null ? labels.where((e) => widget.issue["labels"].contains(e["id"])).toList() : [];
    final token = Provider.of<Auth>(context, listen: false).token;
    List list = List.from(selectedLabels);
    final index = list.indexWhere((e) => e["id"] == label["id"]);

    if (index != -1) {
      list.removeAt(index);

      if (widget.issue != null) {
        final indexT = selectedAttribute.indexWhere((e) => e["id"] == label["id"]);
        if (indexT != -1) setState(() { selectedAttribute.removeAt(indexT); });
        
        Provider.of<Channels>(context, listen: false).removeAttribute(token, currentChannel["workspace_id"], currentChannel["id"], widget.issue["id"], "label", label["id"]);
      }
    } else {
      list.add(label["id"]);

      if (widget.issue != null) { 
        final indexT = selectedAttribute.indexWhere((e) => e["id"] == label["id"]);
        if (indexT == -1) setState(() {selectedAttribute.add(label); });
        
        
        Provider.of<Channels>(context, listen: false).addAttribute(token, currentChannel["workspace_id"], currentChannel["id"], widget.issue["id"], "label", label["id"]);
      } 
    }

    this.setState(() {selectedLabels = list;});
  }

  changeAssignees(user) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentChannel = getDataChannel();
    final index = widget.issue["assignees"].indexWhere((e) => e == user["id"]);

    if (index != -1) {
      if (widget.issue != null) {
        final indexT = selectedAttribute.indexWhere((e) => e["id"] == user["id"]);
        if (indexT != -1) setState(() => selectedAttribute.removeAt(indexT));

        Provider.of<Channels>(context, listen: false).removeAttribute(token, currentChannel["workspace_id"], currentChannel["id"], widget.issue["id"], "assignee", user["id"]);
      }
    } else {
      if (widget.issue != null) {
        final indexT = selectedAttribute.indexWhere((e) => e["id"] == user["id"]);
        if (indexT == -1) setState(() => selectedAttribute.add(user));

        Provider.of<Channels>(context, listen: false).addAttribute(token, currentChannel["workspace_id"], currentChannel["id"], widget.issue["id"], "assignee", user["id"]);
      }
    }
  }

  changeMilestone(milestone) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentChannel = getDataChannel();
    final channelId = currentChannel["id"];
    final milestoneId = widget.issue["milestone_id"];

    if (milestoneId == null) {
      Map data = {
        "type": "milestone",
        "added": [milestone["id"]],
        "removed": []
      };

      if (widget.issue != null) { 
        final indexT = selectedAttribute.indexWhere((e) => e["id"] == milestone["id"]);
        if (indexT == -1) setState(() { selectedAttribute.add(milestone); });

        Provider.of<Channels>(context, listen: false).addAttribute(token, currentChannel["workspace_id"], channelId, widget.issue["id"], "milestone", milestone["id"]);
        Provider.of<Channels>(context, listen: false).updateIssueTimeline(token, currentChannel["workspace_id"], channelId, widget.issue["id"], data);
      }

      Navigator.of(context, rootNavigator: true).pop("Discard");
    } else {
      if (milestoneId == milestone["id"]) {
        if (widget.issue != null) { 
          final indexT = selectedAttribute.indexWhere((e) => e["id"] == milestone["id"]);
          if (indexT != -1)  setState(() { selectedAttribute.removeAt(indexT); });
        
          Provider.of<Channels>(context, listen: false).removeAttribute(token, currentChannel["workspace_id"], channelId, widget.issue["id"], "milestone", milestone["id"]);
        }
      } else {
        Map data = {
          "type": "milestone",
          "added": [milestone["id"]],
          "removed": [milestoneId]
        };

        if (widget.issue != null) {
          setState(() { selectedAttribute = [milestone]; });

          Provider.of<Channels>(context, listen: false).addAttribute(token, currentChannel["workspace_id"], channelId, widget.issue["id"], "milestone", milestone["id"]);
          Provider.of<Channels>(context, listen: false).updateIssueTimeline(token, currentChannel["workspace_id"], channelId, widget.issue["id"], data);
        }

        Navigator.of(context, rootNavigator: true).pop("Discard");
      }
    }
  }

  calculateDueby(due) {
    final DateTime now = DateTime. now();
    final pastDay = now.difference(DateTime.parse(due)).inDays;
    final pastMonth = pastDay ~/ 30;

    if (pastMonth > 0) {
      return "${S.current.pastDueBy} ${pastMonth.toString()} ${pastMonth > 1 ? S.current.months : S.current.month}";
    } else {
      return "${S.current.pastDueBy} ${pastDay.toString()} ${pastDay > 1 ? S.current.days : S.current.day}";
    }
  }

  renderDueDate({milestone}) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final DateTime now = DateTime. now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final formatted = formatter. format(now);
    final isPast = (milestone["due_date"].compareTo(formatted) < 0);
    
    return Container(
      child: Text(
        milestone["due_date"] != null ? 
        isPast ? calculateDueby(milestone["due_date"]) :
        "${S.current.dueBy} " + (DateFormatter().renderTime(DateTime.parse(milestone["due_date"]), type: "yMMMMd")) : "",
        style: TextStyle(color: isPast ? Color(0xffEB5757) : isDark ? Color(0xffA6A6A6) : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 12, fontWeight: isPast ? FontWeight.w600 : FontWeight.w400)
      )
    );
  }

  changeFilter(value) {
    if (widget.isFilter) {
      widget.onChangeFilter(widget.type, value);
      this.setState(() {});
    } 
  }
  
  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime now = DateTime. now();
    final formatted = formatter. format(now);
    final isDark = Provider.of<Auth>(context).theme == ThemeType.DARK;
    return Container(
      color: isDark ? Color(0xff3D3D3D) : Colors.white,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        itemCount: widget.listAttribute.length,
        itemBuilder: (BuildContext context, int index) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onLongPress: () async {
                final act = CupertinoActionSheet(
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                      child: Text(widget.type == "label" ? "Edit label" : "Edit milestone"),
                      onPressed: () {
                        widget.editAttribute(widget.listAttribute[index]);
                      }
                    ),
                    CupertinoActionSheetAction(
                      child: Text(widget.type == "label" ? "Delete label" : "Delete milestone", style: TextStyle(color: Colors.redAccent)),
                      onPressed: () {

                      }
                    )
                  ]
                );
                await showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => act
                );
              },
              onTap: () {
                changeFilter(widget.listAttribute[index]);
                if (widget.isFilter) return;
          
                if (widget.type == "label") {
                  changeLabels(widget.listAttribute[index]);
                } else if (widget.type == "assignee") {
                  changeAssignees(widget.listAttribute[index]);
                } else {
                  changeMilestone(widget.listAttribute[index]);
                }
              },
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(width: isDark ? 0.8 : 0.4, color: isDark ? Color(0xff5E5E5E) : Colors.grey[400]!), top: index == 0 ? BorderSide(width: isDark ? 0.8 : 0.4, color: isDark ? Color(0xff5E5E5E) : Colors.grey[400]!) : BorderSide.none)
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.type == "label" ? Container(
                          margin: EdgeInsets.only(left: 18),
                          child: LabelDesktop(
                            color: int.parse("0XFF${widget.listAttribute[index]["color_hex"]}"), 
                            labelName:  widget.listAttribute[index]["name"]
                          ),
                        )
                        : (widget.type == "assignee" || widget.type == "author")
                        ? Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SizedBox(width: 18),
                            widget.listAttribute[index]["is_nobody"] != true
                                ? CachedAvatar(widget.listAttribute[index]["avatar_url"], name: widget.listAttribute[index]["full_name"], width: 26, height: 26)
                                : SizedBox(),
                            SizedBox(width: 10),
                            widget.listAttribute[index]["is_nobody"] == true ? Text(widget.listAttribute[index]["full_name"], style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff000000).withOpacity(0.65), fontSize: 16))  
                            : Text(Utils.getUserNickName(widget.listAttribute[index]["id"]) ?? widget.listAttribute[index]["full_name"], style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff000000).withOpacity(0.65), fontSize: 16))
                          ]
                        ) : Container(
                          margin: EdgeInsets.only(left: 18),
                          child: Row(                         
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(widget.listAttribute[index]["due_date"].compareTo(formatted) < 0 ? Icons.warning_amber_outlined : Icons.calendar_today_outlined,
                                size: 19,
                                color: widget.listAttribute[index]["due_date"].compareTo(formatted) < 0 ? Color(0xffEB5757) : isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.listAttribute[index]["title"].trim() != "" ? widget.listAttribute[index]["title"].trim() : widget.listAttribute[index]["due_date"] != null ? (DateFormatter().renderTime(DateTime.parse(widget.listAttribute[index]["due_date"]), type: "MMMd")) : "",
                                    style: TextStyle(color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)
                                  ),
                                  SizedBox(height: 4),
                                  renderDueDate(milestone: widget.listAttribute[index])
                                ]
                              )
                            ]
                          )
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 16),
                          child: Icon(
                            widget.isFilter
                              ? selectedAttribute.contains(widget.listAttribute[index]["id"])
                                || ((widget.listAttribute[index]["is_nobody"] == true && selectedAttribute.contains("is_nobody")))
                                  ? Icons.check : Icons.close
                                : selectedAttribute.indexWhere((e) => e['id'] == widget.listAttribute[index]["id"]) != -1 ? CupertinoIcons.checkmark_alt_circle_fill 
                              : null,
                            size: 18,
                            color: widget.isFilter
                              ? (selectedAttribute.contains(widget.listAttribute[index]["id"])
                                || (widget.listAttribute[index]["is_nobody"] == true && selectedAttribute.contains("is_nobody")))
                                  ? Colors.grey[700]
                                  : Colors.transparent
                              : isDark ? Color(0xffFAAD14) : Colors.blueAccent
                          )
                        )
                      ]
                    )
                  )
                ]
              )
            ),
          );
        }
      )
    );
  }
}

class EditAttribute extends StatefulWidget {
  const EditAttribute({
    Key? key,
    this.type,
    this.attribute
  }) : super(key: key);

  final type;
  final attribute;

  @override
  _EditAttributeState createState() => _EditAttributeState();
}

class _EditAttributeState extends State<EditAttribute> {
  List colors = [
    "1CE9AE", "0E8A16", "0052CC", "5319E7", "FF2C65", "FBA704", "D93F0B", "B60205", "CECECE",
    "57B99D", "65C87A", "5097D5", "925EB1", "D63964", "EAC545", "D8823B", "D65745", "98A5A6",
    "397E6B", "448852", "346690", "693B86", "9F2857", "B87E2E", "9C481B", "8D3529", "667C89"
  ];
  Random random = new Random();
  var pickedColor;
  var selectedDate = DateTime.now();
  TextEditingController textController = TextEditingController();

  @override
  void initState() { 
    super.initState();
    if (widget.type == 'label') {
      textController.text = widget.attribute["name"];
      pickedColor = colors.indexWhere((e) => e == widget.attribute["color_hex"]);
    } else {
      textController.text = widget.attribute["title"];
    }
  }

  editLabel() {
    if (textController.text.trim() == "") return;
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    Map newLabel = {...widget.attribute, 'name': textController.text, "color_hex": colors[pickedColor].toString()};
    Provider.of<Channels>(context, listen: false).updateLabel(token, currentWorkspace["id"], currentChannel["id"], newLabel);
    Navigator.pop(context);
  }

  editMilestone() {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    Map milestone = {...widget.attribute,
      "title": textController.text,
      "due_date": selectedDate.toUtc().millisecondsSinceEpoch~/1000 + 86400
    };

    Provider.of<Channels>(context, listen: false).updateMilestone(token, currentWorkspace["id"], currentChannel["id"], milestone);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {  
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xff3D3D3D) : Colors.white,
        border: Border(bottom: BorderSide(width: isDark ? 0.8 : 0.4, color: isDark ? Color(0xff2e3235) : Colors.grey[400]!))
      ),
      child: Column(
        children: [
          Divider(),
          Container(
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            child: CupertinoTextField(
              controller: textController,
              decoration: BoxDecoration(
                color: isDark ? Color(0xff5E5E5E) : Color(0xffF3F3F3),
                borderRadius: BorderRadius.circular(4)
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 15
              ),
              autofocus: true,
              placeholder: widget.type == "label" ? "Label name" : "Milestone title",
              placeholderStyle: TextStyle(
                color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E),
                fontSize: 16
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              onChanged: (value) {
                this.setState(() {});
              }
            )
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 22, right: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.type == 'label') Text("Edit Label:  "),
                    widget.type == 'label' ? LabelDesktop(
                      labelName: textController.text.trim(),
                      color: int.parse("0XFF${colors[pickedColor]}"), 
                    ) : Container(
                      width: MediaQuery.of(context).size.width - 44,
                      child: Column(
                        children: [
                          CalendarDatePicker(
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now().add(new Duration(days: 365)),
                            onDateChanged: (DateTime value) { 
                              setState(() {
                                selectedDate = value;
                              });
                            }
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                textController.text.trim() != "" ? textController.text.trim() 
                                : (DateFormatter().renderTime(DateTime.parse(selectedDate.toString()), type: "MMMd")), 
                                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20)
                              ),
                              SizedBox(width: 24),
                              InkWell(
                                onTap: () {
                                  editMilestone();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: isDark ? Color(0xffFAAD14) : Colors.blueAccent
                                  ),
                                  child: Text("Confirm", style: TextStyle(color: Colors.white, fontSize: 14))
                                )
                              )
                            ]
                          )
                        ]
                      )
                    ) 
                  ]
                )
              ]
            )
          ),
          SizedBox(height: 16),
          if (widget.type == 'label') GridView.count(
            padding: EdgeInsets.only(top: 4, bottom: 12, left: 22, right: 22),
            shrinkWrap: true,
            primary: false,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            crossAxisCount: 9,
            children: colors.map((e) => 
              InkWell(
                onTap: () {
                  this.setState(() {
                    pickedColor = colors.indexWhere((color) => color == e);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(int.parse("0xFF$e")),
                    borderRadius: BorderRadius.circular(4.0)
                  ),
                  height: 10.0,
                  width: 10.0
                ),
              )
            ).toList()
          ),
          SizedBox(height: 18),
          if(widget.type == 'label') InkWell(
            onTap: () {
              editLabel();
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? Color(0xffFAAD14) : Colors.blueAccent,
                borderRadius: BorderRadius.circular(4)
              ),
              child: Text("Confirm")
            )
          )
        ]
      )
    );
  }
}