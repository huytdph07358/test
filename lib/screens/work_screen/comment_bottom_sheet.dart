import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/desktop/workview_desktop/label.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/work_screen/select_attribute.dart';

import '../../generated/l10n.dart';
import 'comment_field.dart';

class CommentBottomSheet extends StatefulWidget {
  CommentBottomSheet({
    Key? key,
    this.issue, this.handleScroll,
    this.updateIssueState
  }) : super(key: key);

  final issue;
  final handleScroll;
  final updateIssueState;

  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {

  List assigneesSelected = [];
  @override
  void initState() {
    super.initState();
    filterMember();
  }

  filterMember() {
    final issue = widget.issue;
    final assignees = issue["assignees"];
    final channelMember = Provider.of<Channels>(context, listen: false).channelMember;
    List list = [];

    for (int i=0; i < assignees.length; i++) {
      if(channelMember.indexWhere((e) => e["id"] == assignees[i]) != -1){
        list.add(assignees[i]);
      }
    }
    
    setState(() { assigneesSelected = list.toSet().toList(); });
  }

  @override
  void didUpdateWidget (oldWidget) {
    super.didUpdateWidget(oldWidget);
    filterMember();
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

  renderDueDate({milestone, isIcon = false}) {
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
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
      child: Text(
        milestone["due_date"] != null ? 
        isPast ? calculateDueby(milestone["due_date"]) :
        "${S.current.dueBy} " + (DateFormatter().renderTime(DateTime.parse(milestone["due_date"]), type: "yMMMMd")) : "",
        style: TextStyle(color: isPast ? Colors.redAccent.withOpacity(0.8) : isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: isPast ? FontWeight.w600 : FontWeight.w400)
      )
    );
  }

  calculateMilestone(milestone) {
    var channelData = getDataChannel();
    final currentChannel = channelData;
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

  handleSave(value) {
    var channelData = getDataChannel();
    final auth = Provider.of<Auth>(context, listen: false); 
    if (value.trim() != "") {
      var result = Provider.of<Messages>(context, listen: false).checkMentions(value.trim());
      List listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];

      var dataComment = {
        "comment": value,
        "channel_id":  channelData["channel_id"],
        "workspace_id": channelData["workspace_id"],
        "user_id": auth.userId,
        "from_issue_id": widget.issue["id"],
        "list_mentions_old": [],
        "list_mentions_new": listMentionsNew
      };

      Provider.of<Channels>(context, listen: false).submitComment(auth.token, dataComment);
    }
    Navigator.pop(context);
  }

  showBottomSheetComment(context, text, handleSave) {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext context) {
         var height = MediaQuery.of(context).size.height*0.9;
        return Container(
          height: height,
          child: CommentField(issue: widget.issue, text: text, handleSave: handleSave, height: height,)
        );
      }
    );
  }

  List selectedDefault = [];

  showBottomSheetAttribute(context, type) {
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    var channelData = getDataChannel();
    final channelMember = Provider.of<Channels>(context, listen: false).getChannelMember(widget.issue["channel_id"]);
    final issue = widget.issue;
    List selectedAttribute = type == "label" ? issue["labels"] != null ? channelData["labels"].where((e) => issue["labels"].contains(e["id"]) == true).toList() : []
      : type == "assignee" ? issue["assignees"] != null ? channelMember.where((e) => issue["assignees"].contains(e["id"]) == true).toList() : []
      : channelData["milestones"].where((e) => issue["milestone_id"] == e["id"]).toList();
    selectedDefault = selectedAttribute;

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
          child: SelectAttribute(issue: issue, type: type)
        );
      }
    ).then((value) => {
      updateIssueTimeline(issue, type)
    });
  }

  updateIssueTimeline(issue, type) async {
    var channelData = getDataChannel();
    final channelMember = Provider.of<Channels>(context, listen: false).getChannelMember(widget.issue["channel_id"]);
    final token = Provider.of<Auth>(context, listen: false).token;
     List selectedAttribute = type == "label" ? issue["labels"] != null ? channelData["labels"].where((e) => issue["labels"].contains(e["id"]) == true).toList() : []
      : type == "assignee" ? issue["assignees"] != null ? channelMember.where((e) => issue["assignees"].contains(e["id"]) == true).toList() : []
      : channelData["milestones"].where((e) => issue["milestone_id"] == e["id"]).toList();

    if (widget.issue != null) {
      List added = [];
      List removed = [];

      for (var item in selectedAttribute) {
        if (!selectedDefault.contains(item)) {
          added.add(item["id"]);
        }
      }

      for (var item in selectedDefault) {
        if (!selectedAttribute.contains(item)) {
          removed.add(item["id"]);
        }
      }

      if (added.length > 0 || removed.length > 0) {
        Map data = {
          "type": "${type}s".toLowerCase(),
          "added": added,
          "removed": removed
        };

        await Provider.of<Channels>(context, listen: false).updateIssueTimeline(token, channelData["workspace_id"], channelData["channel_id"], widget.issue["id"], data);
      }

      selectedDefault = [];
    }
  }

  Map getDataChannel(){
    try {
      List channels = Provider.of<Channels>(context, listen: false).data;
      int index = channels.indexWhere((element) => "${element["id"]}" == "${widget.issue["channel_id"]}");

      return {
        "channel_id": channels[index]["id"],
        ...channels[index]
      };
    } catch (e) {
      print("getDataChannel: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentChannel = getDataChannel();
    final channelMember = Provider.of<Channels>(context, listen: true).getChannelMember(widget.issue["channel_id"]);
    final issue = widget.issue;
    List labels = currentChannel["labels"] != null ? currentChannel["labels"]: [];
    List issueLabels = issue["labels"] != null ? labels.where((e) => issue["labels"].contains(e["id"])).toList() : [];
    List milestones = currentChannel["milestones"] != null ? currentChannel["milestones"] : [];
    final indexMilestone = milestones.indexWhere((e) => e["id"] == issue["milestone_id"]);
    final milestone = indexMilestone == -1 ? null : milestones[indexMilestone];
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;

    return SlidingUpPanel(
      backdropEnabled: true,
      boxShadow: [
        BoxShadow(
          offset: Offset(7, -3),
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20.0,
        )
      ],
      borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      maxHeight: MediaQuery.of(context).size.height * 0.85,
      minHeight: 110,
      color: isDark ? Color(0xff3D3D3D) : Colors.white,
      panel: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 5,
            width: 50,
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF5E5E5E) :Color(0xffC9C9C9),
              borderRadius: BorderRadius.circular(16)
            )
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showBottomSheetComment(context, "", handleSave);
                    },
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Color(0xff1890FF),
                        boxShadow: [BoxShadow(offset: Offset(0, 2), color: Color.fromRGBO(0, 0, 0, 0.016))],
                        borderRadius: BorderRadius.circular(2)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.chatBold, size: 17, color: Colors.white,),
                          SizedBox(width: 8,),
                          Text(S.current.addComment, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                        ],
                      )
                    ),
                  ),
                ),
                SizedBox(width: 12,),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      var isClosed = !issue["is_closed"];
                      this.setState(() {
                        issue["is_closed"] = isClosed;
                      });
                      final issueClosedTab = Provider.of<Work>(context, listen: false).issueClosedTab;
                      await Provider.of<Channels>(context, listen: false).closeIssue(auth.token, currentChannel["workspace_id"], currentChannel["channel_id"], widget.issue["id"], isClosed, issueClosedTab);
                      widget.handleScroll();
                      widget.updateIssueState(true);
                    },
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: issue["is_closed"] ? Colors.green : isDark ? Color(0xffFF7875) : Color(0xffFF7875))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.info, size: 17, color: issue["is_closed"] ? Colors.green : isDark ? Color(0xffFF7875) : Color(0xffFF7875),),
                          SizedBox(width: 8,),
                          Text(issue["is_closed"] ? S.current.reopenIssue :S.current.closeIssue, style: TextStyle(color: issue["is_closed"] ? Colors.green : isDark ? Color(0xffFF7875) : Color(0xffFF7875), fontSize: 15, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: MediaQuery.of(context).size.height * 0.85 - 81 ,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 18),
                  InkWell(
                    onTap: () {
                      showBottomSheetAttribute(context, "assignee");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.current.assignees, style: TextStyle(color: isDark ? Colors.white : Color(0xff3D3D3D), fontSize: 15, fontWeight: FontWeight.w600)),
                        Icon(PhosphorIcons.userPlus, size: 18, color: isDark ? Colors.white : Color(0xff3D3D3D))
                      ],
                    ),
                  ),
                  Divider(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9), height: 28, thickness: 1),
                  Container(
                    constraints: BoxConstraints(minHeight: 33),
                    child: assigneesSelected.length > 0 ? ListView.builder(
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      itemCount: assigneesSelected.length,
                      itemBuilder: (context, index) {
                        final indexMember = channelMember.indexWhere((e) => e["id"] == assigneesSelected[index]);
                        final member = indexMember == -1 ? null : channelMember[indexMember];

                        return member != null ? Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              CachedAvatar(member["avatar_url"], name: member["full_name"], width: 24, height: 24),
                              SizedBox(width: 10),
                              Text(member["full_name"], style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 15))
                            ]
                          )
                        ) : SizedBox();
                      }
                    ) : Text(S.current.noOneAssignYourself, style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E), fontSize: 14 ),),
                  ),
                  SizedBox(height: 18),
                  InkWell(
                    onTap: () {
                      showBottomSheetAttribute(context, "label");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.current.labels, style: TextStyle(color: isDark ? Colors.white : Color(0xff3D3D3D), fontSize: 15, fontWeight: FontWeight.w600)),
                        Icon(PhosphorIcons.tag, size: 18, color: isDark ? Colors.white : Color(0xff3D3D3D))
                      ]
                    ),
                  ),
                  Divider(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9), height: 28, thickness: 1),
                  Container(
                    height: issueLabels.length > 0 ? 34 : 33,
                    child: issueLabels.length > 0 ? ListView.builder(
                      padding: EdgeInsets.all(0),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: issueLabels.length,
                      itemBuilder: (context, index) {
                        var label = issueLabels[index];
                        
                        return Container(
                          padding: EdgeInsets.only(top: 4, bottom: 4),
                          child: LabelDesktop(labelName: label["name"], color: int.parse("0XFF${label["color_hex"]}"))
                        );
                      }
                    ) : Text(S.current.noneYet, style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E), fontSize: 14 ),),
                  ),
                  SizedBox(height: 18),
                  InkWell(
                    onTap: () {
                      showBottomSheetAttribute(context, "milestone");
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(S.current.milestones,style: TextStyle(color: isDark ? Colors.white : Color(0xff3D3D3D), fontSize: 15, fontWeight: FontWeight.w600)),
                        Icon(PhosphorIcons.flag, size: 18, color: isDark ? Colors.white : Color(0xff3D3D3D))
                      ]
                    ),
                  ),
                  Divider(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9), height: 28, thickness: 1),
                  milestone != null ? Container(
                    decoration: BoxDecoration(
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: LinearProgressIndicator(
                              value: calculateMilestone(milestone)["percent"]/100,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xff27AE60)),
                              backgroundColor: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),
                            )
                          ),
                        ),
                        SizedBox(height: 8,),
                        Text(
                          milestone["title"].trim() != "" ? milestone["title"].trim() : milestone["due_date"] != null ? (DateFormatter().renderTime(DateTime.parse(milestone["due_date"]), type: "MMMd")) : "",
                          style: TextStyle(color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87, fontSize: 18, fontWeight: FontWeight.w500)
                        ),
                        SizedBox(height: 8,),
                        renderDueDate(milestone: milestone, isIcon: false),
                      ],
                    )
                  ) : Text(S.current.noMilestone, style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E), fontSize: 14 ),),
                  SizedBox(height: 36),
                ]
              ),
            )
          )
        ]
      )
    );
  }
}
