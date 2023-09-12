import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/desktop/components/issue_drop_bar.dart';
import 'package:workcake/desktop/workview_desktop/label.dart';
import 'package:workcake/desktop/workview_desktop/pagination.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:workcake/models/models.dart';
import 'create_issue.dart';

class IssueTable extends StatefulWidget {
  const IssueTable({
    Key? key,
    this.channelId,
    this.milestone,
    this.resetFilter,
    this.onChangeFilter,
    this.text
  }) : super(key: key);

  final channelId;
  final milestone;
  final resetFilter;
  final onChangeFilter;
  final text;

  @override
  _IssueTableState createState() => _IssueTableState();
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class _IssueTableState extends State<IssueTable> {
  List filters = [];
  List selectedAuthor = [];
  List selectedMilestone = [];
  List selectedLabel = [];
  List selectedAssignee = [];
  String sortBy = "newest";
  List selectedCheckbox = [];
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final issueClosedTab = Provider.of<Work>(context, listen: false).issueClosedTab;

    Provider.of<Work>(context, listen: false).loadDraftIssue();
    if (widget.milestone != null) {
      this.setState(() {
        selectedMilestone = [widget.milestone["id"]];
        filters = [{
          "type": "milestone",
          "name": widget.milestone["title"],
          "id": widget.milestone["id"]
        }];
        Provider.of<Channels>(context, listen: false).getListIssue(token, currentWorkspace["id"], currentChannel["id"], 1, issueClosedTab, filters, sortBy, widget.text);
      });
    } else {
      Provider.of<Channels>(context, listen: false).getListIssue(token, currentWorkspace["id"], currentChannel["id"], 1, issueClosedTab, [], sortBy, widget.text);
    }
  }

  @override
  didUpdateWidget(oldWidget) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    super.didUpdateWidget(oldWidget);

    if (oldWidget.channelId != widget.channelId || oldWidget.resetFilter != widget.resetFilter) {
      this.setState(() {
        filters = [];
        selectedAuthor = [];
        selectedMilestone = [];
        selectedLabel = [];
        selectedAssignee = [];
        sortBy = "newest";
      });

      var issueClosedTab = Provider.of<Work>(context, listen: false).issueClosedTab;

      Provider.of<Channels>(context, listen: false).getListIssue(token, currentWorkspace["id"], currentChannel['id'], 1, issueClosedTab, [], sortBy, widget.text);
    }
  }

  onSelectAtt(type, item, isRemove) async {
    if (selectedCheckbox.length > 0 ) {
      final token = Provider.of<Auth>(context, listen: false).token;
      final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
      final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
      final issueClosedTab = Provider.of<Work>(context, listen: false).issueClosedTab;
      Navigator.of(context, rootNavigator: true).pop("Discard");

      Provider.of<Channels>(context, listen: false).bulkAction(token, currentWorkspace["id"], currentChannel["id"], type, item["id"], selectedCheckbox, isRemove, filters, 1, sortBy, issueClosedTab);
    } else {
      final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
      final channelMember = Provider.of<Channels>(context, listen: false).channelMember;
      List labels = currentChannel["labels"] != null ? currentChannel["labels"]: [];
      List milestones = currentChannel["milestones"] != null ? currentChannel["milestones"] : [];

      if (type == "Author") {
        List list = List.from(selectedAuthor);
        final index = list.indexWhere((e) => e == item["id"]);

        if (index == -1) {
          this.setState(() {
            selectedAuthor = [item["id"]];
          });
        } else {
          this.setState(() {
            selectedAuthor = [];
          });
        }
      } else if (type == "Milestones") {
        List list = List.from(selectedMilestone);
        final index = list.indexWhere((e) => e == item["id"]);

        if (index == -1) {
          this.setState(() {
            selectedMilestone = [item["id"]];
          });
        } else {
          this.setState(() {
            selectedMilestone = [];
          });
        }
      } else if (type == "Label") {
        List list = List.from(selectedLabel);
        final index = list.indexWhere((e) => e == item["id"]);

        if (index == -1) {
          list.add(item["id"]);
        } else {
          list.removeAt(index);
        }

        this.setState(() {
          selectedLabel = list;
        });
      } else {
        List list = List.from(selectedAssignee);
        final index = list.indexWhere((e) => e == item["id"]);

        if (index == -1) {
          list.add(item["id"]);
        } else {
          list.removeAt(index);
        }

        this.setState(() {
          selectedAssignee = list;
        });
      }

      List newFilters = [];

      selectedAuthor.forEach((e) {
        var index = channelMember.indexWhere((ele) => ele["id"] == e);
        if (index != -1) {
          newFilters.add({
            "type": "author",
            "name": channelMember[index]["full_name"],
            "id": channelMember[index]["id"]
          });
        }
      });

      selectedAssignee.forEach((e) {
        var index = channelMember.indexWhere((ele) => ele["id"] == e);
        if (index != -1) {
          newFilters.add({
            "type": "assignee",
            "name": channelMember[index]["full_name"],
            "id": channelMember[index]["id"]
          });
        }
      });

      selectedMilestone.forEach((e) {
        
        var index = milestones.indexWhere((ele) => ele["id"] == e);
        if (index != -1) {
          newFilters.add({
            "type": "milestone",
            "name": milestones[index]["title"],
            "id": milestones[index]["id"]
          });
        }
      });

      selectedLabel.forEach((e) {
        var index = labels.indexWhere((ele) => ele["id"] == e);
        if (index != -1) {
          newFilters.add({
            "type": "label",
            "name": labels[index]["name"],
            "id": labels[index]["id"]
          });
        }
      });

      this.setState(() {
        filters = newFilters;
      });
      widget.onChangeFilter(filters);
    }
  }

  parseFilterToString() {
    bool issueClosedTab = Provider.of<Work>(context, listen: false).issueClosedTab;

    List list = issueClosedTab ? ["is:closed"] : ["is:open"];

    filters.forEach((e) => {
      list.add(" ${e["type"]}:${e["name"]}")
    });

    return list.join(" ");
  }

  changeSort(type) {
    setState(() {
      sortBy = type;
    });
  }

  parseFilter(listIssues) {
    List list = listIssues;

    filters.forEach((filter) {
      if (filter["type"] == "label") {
        list = list.where((e) => e["labels"].contains(filter["id"])).toList();
      } else if (filter["type"] == "author") {
        list = list.where((e) => e["author_id"] == filter["id"]).toList();
      } else if (filter["type"] == "milestone") {
        list = list.where((e) => e["milestone_id"] == filter["id"]).toList();
      } else {
        list = list.where((e) => e["assignees"].contains(filter["id"])).toList();
      }
    });

    if (sortBy == "newest") {
      list.sort((a, b) => b["inserted_at"].compareTo(a["inserted_at"]));
    } else if (sortBy == "oldest") {
      list.sort((a, b) => a["inserted_at"].compareTo(b["inserted_at"]));
    } else if (sortBy == "recently_updated") {
      list.sort((a, b) => b["updated_at"].compareTo(a["updated_at"]));
    } else {
      list.sort((a, b) => a["updated_at"].compareTo(b["updated_at"]));
    }

    return list;
  }

  onChangeCheckbox(id) {
    List list = List.from(selectedCheckbox);
    int index = list.indexWhere((e) => e == id);

    if (index == -1) {
      list.add(id);
    } else {
      list.removeAt(index);
    }

    this.setState(() {
      selectedCheckbox = list;
    });
  }

  onCheckAll(value) {
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    List issues = currentChannel["issues"] != null ? currentChannel["issues"] : [];

    if (value) {
      List list = [];

      for (var issue in issues) {
        list.add(issue["id"]);
      }

      this.setState(() {
        selectedCheckbox = list;
      });
    } else {
      this.setState(() {
        selectedCheckbox = [];
      });
    }
    
    this.setState(() {
      selectAll = value;
    });
  }

  onFilterIssue() {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final issueClosedTab = Provider.of<Work>(context, listen: false).issueClosedTab;

    Provider.of<Channels>(context, listen: false).getListIssue(auth.token, currentWorkspace["id"], currentChannel['id'], 1, issueClosedTab, filters, sortBy, widget.text);
  }

  @override
  Widget build(BuildContext context) {
    final isIssueLoading = Provider.of<Channels>(context, listen: true).isIssueLoading;
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final channelMember = Provider.of<Channels>(context, listen: true).channelMember;
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    List issues = currentChannel["issues"] != null ? currentChannel["issues"] : [];
    var openIssuesCount = currentChannel["openIssuesCount"];
    var closedIssuesCount = currentChannel["closedIssuesCount"];
    var issueClosedTab = Provider.of<Work>(context, listen: true).issueClosedTab;
    List labels = currentChannel["labels"] != null ? currentChannel["labels"]: [];
    List milestones = currentChannel["milestones"] != null ? currentChannel["milestones"] : [];

    return Container(
      color: isDark ? Color(0xff1F2933) : Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            // width: (MediaQuery.of(context).size.width - widthResbar - 70),
            padding: EdgeInsets.only(left: 24, right: 24),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
              ),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 3),
                                padding: EdgeInsets.symmetric(vertical: 8),
                                width: 42,
                                child: Theme(
                                  data: ThemeData(
                                    primarySwatch: Colors.blue,
                                    unselectedWidgetColor: isDark ? Color(0xff9AA5B1) : Color.fromRGBO(0, 0, 0, 0.65) // Your color
                                  ),
                                  child: Transform.scale(
                                    scale: 0.9,
                                    child: Checkbox(
                                      value: selectAll,
                                      onChanged: (value) {
                                        onCheckAll(value);
                                      },
                                    )
                                  )
                                )
                              ),
                              Expanded(
                                child: Wrap(
                                  direction: Axis.horizontal,
                                  children: [
                                    Wrap(
                                      direction: Axis.horizontal,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 4),
                                          child: openIssuesCount != null ? Icon(Icons.info_outline, color: !issueClosedTab
                                          ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298))
                                          : Color(0xff9AA5B1),
                                          size: 18) : Container()
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Provider.of<Work>(context, listen: false).setIssueClosedTab(false);
                                            Provider.of<Channels>(context, listen: false).getListIssue(auth.token, currentWorkspace["id"], currentChannel["id"], 1, false, filters, sortBy, widget.text);
                                            this.setState(() { 
                                              selectedCheckbox = [];
                                              selectAll = false;
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 8),
                                            child: Text(
                                              openIssuesCount != null ? "$openIssuesCount Open" : "",
                                              style: TextStyle(
                                                color: !issueClosedTab
                                                  ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298))
                                                  : Color(0xff9AA5B1),
                                                fontWeight: !issueClosedTab ? FontWeight.w700 : FontWeight.w400,
                                                fontSize: 14
                                              )
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 15,),
                                    Wrap(
                                      direction: Axis.horizontal,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 4),
                                          child: closedIssuesCount != null ? Icon(
                                            Icons.check, 
                                            color: issueClosedTab ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)) : Color(0xff9AA5B1),
                                            size: 18
                                          ) : Container()
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Provider.of<Work>(context, listen: false).setIssueClosedTab(true);
                                            Provider.of<Channels>(context, listen: false).getListIssue(auth.token, currentWorkspace["id"], currentChannel["id"], 1, true, filters, sortBy, widget.text);
                                            this.setState(() { 
                                              selectedCheckbox = [];
                                              selectAll = false;
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(right: 4),
                                            child: Text(
                                              closedIssuesCount != null ? "$closedIssuesCount Closed": "",
                                              style: TextStyle(
                                                color: issueClosedTab
                                                  ? (isDark ? Color(0xff19DFCB) : Color(0xff2A5298))
                                                  : Color(0xff9AA5B1),
                                                fontWeight: !issueClosedTab ? FontWeight.w400 : FontWeight.w700,
                                                fontSize: 14
                                              )
                                            )
                                          ),
                                        )
                                      ],
                                    )
                                  ]
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 8, bottom: 2),
                          width: 450,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              selectedCheckbox.length > 0 ? Container() : IssueDropBar(title: "Author", listAttribute: channelMember, onSelectAtt: onSelectAtt, selectedAtt: selectedAuthor, onFilterIssue: onFilterIssue),
                              IssueDropBar(title: "Label", listAttribute: labels, onSelectAtt: onSelectAtt, selectedAtt: selectedLabel, selectedCheckbox: selectedCheckbox, onFilterIssue: onFilterIssue),
                              IssueDropBar(
                                title: "Milestones", 
                                listAttribute: milestones.where((e) => e["is_closed"] == false).toList(), 
                                onSelectAtt: onSelectAtt, 
                                selectedAtt: selectedMilestone, 
                                selectedCheckbox: selectedCheckbox, 
                                onFilterIssue: onFilterIssue
                              ),
                              IssueDropBar(title: "Assignee", listAttribute: channelMember, onSelectAtt: onSelectAtt, selectedAtt: selectedAssignee, selectedCheckbox: selectedCheckbox, onFilterIssue: onFilterIssue),
                              selectedCheckbox.length > 0 ? Container() : IssueDropBar(title: "Sort", sortBy: sortBy, changeSort: changeSort, onFilterIssue: onFilterIssue)
                            ]
                          )
                        )
                      ]
                    )
                  ),
                  (isIssueLoading == true) ? Container(
                    margin: EdgeInsets.only(top: 40),
                    child: SpinKitFadingCircle(
                      color: isDark ? Colors.white : Color(0xff096DD9),
                      size: 35,
                    ),
                  ) : ListIssue(
                    issues: issues, 
                    filters: filters, 
                    sortBy: sortBy,
                    selectedCheckbox: selectedCheckbox,
                    onChangeCheckbox: onChangeCheckbox,
                    isClosed: issueClosedTab
                  )
                ],
              )
            )
          ),
          Pagination(channelId: currentChannel["id"], issueClosedTab: issueClosedTab, filters: filters, sortBy: sortBy, text: widget.text)
        ],
      ),
    );
  }
}

class ListIssue extends StatefulWidget {
  const ListIssue({
    Key? key,
    this.issues,
    this.filters,
    this.sortBy,
    this.isClosed,
    this.page,
    this.selectedCheckbox, 
    this.onChangeCheckbox
  }) : super(key: key);

  final issues;
  final filters;
  final sortBy;
  final isClosed;
  final page;
  final selectedCheckbox;
  final onChangeCheckbox;

  @override
  _ListIssueState createState() => _ListIssueState();
}

class _ListIssueState extends State<ListIssue> {

  selectCheckbox(id) {
    widget.onChangeCheckbox(id);
  }

  @override
  Widget build(BuildContext context) {
    List issues = widget.issues.where((e) => e["is_closed"] == widget.isClosed).toList();
    ScrollController controller = new ScrollController();
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    var totalPage = currentChannel["totalPage"] != null ? currentChannel["totalPage"] : 0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: (MediaQuery.of(context).size.height - (totalPage > 1 ? 170 : 150) - 26 - 50)
      ),
      child: ListView.builder(
        controller: controller,
        shrinkWrap: true,
        itemCount: issues.length,
        itemBuilder: (BuildContext context, int index) {
          final issue = issues[index];
          return IssueItem(issue: issue, selectCheckbox: selectCheckbox, selectedCheckbox: widget.selectedCheckbox);
        },
      )
    );
  }
}

class IssueItem extends StatefulWidget {
  const IssueItem({
    Key? key,
    @required this.issue,
    this.selectCheckbox,
    this.selectedCheckbox,
  }) : super(key: key);

  final issue;
  final selectCheckbox;
  final selectedCheckbox;

  @override
  _IssueItemState createState() => _IssueItemState();
}

class _IssueItemState extends State<IssueItem> {
  var channel;
  var issue;

  @override
  void initState() {
    super.initState();

    this.setState(() {
      issue = widget.issue;
    });
  }

  parseDatetime(time) {
    if (time != "") {
      DateTime offlineTime = DateTime.parse(time).add(Duration(hours: 7));
      DateTime now = DateTime.now();
      final difference = now.difference(offlineTime).inMinutes;
      final int hour = difference ~/ 60;
      final int minutes = difference % 60 + 1;
      final int day = hour ~/24;

      if (day > 0) {
        int month = day ~/30;
        int year = month ~/12;
        if (year >= 1) return '${year.toString().padLeft(1, "")} ${year > 1 ? "years" : "year"} ago';
        else {
          if (month >= 1) return '${month.toString().padLeft(1, "")} ${month > 1 ? "months" : "month"} ago';
          else return '${day.toString().padLeft(1, "")} ${day > 1 ? "days" : "day"} ago';
        }
      } else if (hour > 0) {
        return '${hour.toString().padLeft(1, "")} ${hour > 1 ? "hours" : "hour"} ago';
      } else if(minutes <= 1) {
        return 'moments ago';
      } else {
        return '${minutes.toString().padLeft(1, "0")} minutes ago';
      }
    } else {
      return "";
    }
  }

  parseDescription(description) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    int checked = 0;
    int total = 0;

    List list = description.split("\n");

    for (var item in list) {
      if (item.length > 5) {
        String sub = item.substring(0, 5);

        if (sub == "- [ ]" || sub == "- [x]") {
          total +=1;
        }
        if (sub == "- [x]") {
          checked +=1;
        }
      }
    }

    return total > 0 ? Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.playlist_add_check_outlined, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        SizedBox(width: 4),
        Text(
          "$checked of $total",
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontSize: 12.5
          )
        ),
        SizedBox(width: 6),
        Container(
          width: 70,
          height: 6,
          padding: EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: checked/total,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
              backgroundColor: Color(0xffD6D6D6),
            )
          )
        ),
      ]
    ) : Wrap();
  }

  @override
  Widget build(BuildContext context) {
    issue = widget.issue;
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final workspaceMember = Provider.of<Workspaces>(context, listen: true).members;
    final indexUser = workspaceMember.indexWhere((e) => e["id"] == issue["author_id"]);
    final author = indexUser == -1 ? null : workspaceMember[indexUser];
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final issueClosedTab = Provider.of<Work>(context, listen: true).issueClosedTab;

    List labels = currentChannel["labels"] != null ? currentChannel["labels"]: [];
    List milestones = currentChannel["milestones"] != null ? currentChannel["milestones"] : [];
    List assignees = issue["assignees"] != null ? workspaceMember.where((e) => issue["assignees"].contains(e["id"])).toList() : [];
    List issueLabels = issue["labels"] != null ? labels.where((e) => issue["labels"].contains(e["id"])).toList() : [];

    final indexMilestone = milestones.indexWhere((e) => e["id"] == issue["milestone_id"]);
    final milestone = indexMilestone == -1 ? null : milestones[indexMilestone];
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;

    return Container(
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(2),
        color: isDark ? Color(0xff323F4B) : Color(0xffF7F7F8),
         border: Border(
          left: BorderSide(
            color: (issue["users_unread"] != null ? issue["users_unread"] : []).contains(currentUser["id"]) ? Colors.blue : Colors.transparent,
            width: 3.0,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 4),
      margin: EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 8,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 18,
                  width: 42,
                  child: Theme(
                    data: ThemeData(
                      primarySwatch: Colors.blue,
                      unselectedWidgetColor: isDark ? Colors.grey[500] : Colors.grey[700], // Your color
                    ),
                    child: Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: widget.selectedCheckbox.contains(issue["id"]),
                        onChanged: (value) { 
                          widget.selectCheckbox(issue["id"]);
                        }
                      )
                    )
                  )
                ),
                Container(
                  margin: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.info_outline,
                    color: !issueClosedTab ? (isDark ? Color(0xff19DFCB) :Color(0xff27AE60)) : Colors.redAccent, size: 18),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 300 - 300),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              await Provider.of<Channels>(context, listen: false).updateUnreadIssue(token, currentWorkspace["id"], currentChannel["id"], issue["id"], currentUser["id"]);
                              
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  transitionDuration: Duration(milliseconds: 150),
                                  reverseTransitionDuration: Duration(milliseconds: 75),
                                  pageBuilder: (context, _, __) => CreateIssue(issue: issue, timelines: issue["timelines"], comments: issue["comments"]),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    var begin = 1.2;
                                    var end = 1.0;
                                    var curve = Curves.ease;
                                    var curveTween = CurveTween(curve: curve);
                                    var tween = Tween(begin: begin, end: end).chain(curveTween);
                                    var offsetAnimation = animation.drive(tween);
                                    return ScaleTransition(
                                      scale: offsetAnimation,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                )
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(right: 8, top: 4, bottom: 4),
                              child: Text(
                                "${issue["title"]}",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.7),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16
                                ),
                                maxLines: 10
                              )
                            ),
                          ),
                          Container(
                            child: Wrap(
                              children: issueLabels.map<Widget>((e) {
                                var label = e;
                                return Container(
                                  padding: EdgeInsets.only(top: 4, bottom: 4),
                                  child: LabelDesktop(labelName: label["name"], color: int.parse("0XFF${label["color_hex"]}"))
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      
                      if (author != null) Container(
                        // margin: EdgeInsets.only(top: 2),
                        // width: MediaQuery.of(context).size.width - 300 - 300,
                        child: Wrap(
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(right: 4, top: 4, bottom: 4),
                              child: Text(
                                "#${issue["unique_id"]} opened ${parseDatetime(issue["inserted_at"])} by ${author["full_name"]} ",
                                style: TextStyle(
                                  color: isDark ? Color(0xffcbd2d9) : Color.fromRGBO(0, 0, 0, 0.65),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12
                                )
                              ),
                            ),
                            issue["description"] != null ? parseDescription(issue["description"]) : Wrap(),
                            milestone != null ? Container(
                              margin: EdgeInsets.only(bottom: 2),
                              child: Wrap(
                                direction: Axis.horizontal,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.flag, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                                  Text(
                                    milestone["due_date"] != null ? (DateFormatter().renderTime(DateTime.parse(milestone["due_date"]), type: "MMMd")) : "",
                                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 12.5)
                                  )
                                ]
                              ),
                            ) : Container()
                          ]
                        ),
                      )
                    ]
                  ),
                )
              ]
            ),
          ),
          SizedBox(width: 12),
          Container(
            width: 100,
            height: 36,
            child: Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: [
                assignees.length == 0 ? Container() :
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(1),
                  width: 32,
                  height: 32,
                  child: CachedImage(
                    (assignees[0])["avatar_url"],
                    width: 30,
                    height: 30,
                    isAvatar: true,
                    radius: 50,
                    name: (assignees[0])["full_name"]
                  )
                ),
                assignees.length <= 1 ? Container() : 
                Positioned(
                  right: assignees.length == 2 ? 25 : assignees.length == 3 ? 20 : assignees.length == 4 ? 15 : assignees.length == 5 ? 12.5 : 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(1),
                    width: 32,
                    height: 32,
                    child: CachedImage(
                      (assignees[1])["avatar_url"],
                      width: 30,
                      height: 30,
                      isAvatar: true,
                      radius: 50,
                      name: (assignees[1])["full_name"]
                    )
                  ),
                ),
                assignees.length <= 2 ? Container() : 
                Positioned(
                  right: assignees.length == 3 ? 40 : assignees.length == 4 ? 30 : assignees.length == 5 ? 25 : 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(1),
                    width: 32,
                    height: 32,
                    child: CachedImage(
                      (assignees[2])["avatar_url"],
                      width: 30,
                      height: 30,
                      isAvatar: true,
                      radius: 50,
                      name: (assignees[2])["full_name"]
                    )
                  ),
                ),
                assignees.length <= 3 ? Container() : 
                Positioned(
                  right: assignees.length == 4 ? 45 : assignees.length == 5 ? 37.5 : 30,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(1),
                    width: 32,
                    height: 32,
                    child: CachedImage(
                      (assignees[3])["avatar_url"],
                      width: 30,
                      height: 30,
                      isAvatar: true,
                      radius: 50,
                      name: (assignees[3])["full_name"]
                    )
                  ),
                ),
                assignees.length <= 4 ? Container() : 
                Positioned(
                  right: assignees.length == 5 ? 50 : 40,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(1),
                    width: 32,
                    height: 32,
                    child: CachedImage(
                      (assignees[4])["avatar_url"],
                      width: 30,
                      height: 30,
                      isAvatar: true,
                      radius: 50,
                      name: (assignees[4])["full_name"]
                    )
                  ),
                ),
                assignees.length <= 5 ? Container() :
                Positioned(
                  right: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(1),
                    width: 32,
                    height: 32,
                    child: Container(
                      decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? Color(0xff52606D) : Color(0xffE4E7EB),
                    ),
                      padding: EdgeInsets.symmetric(vertical: 7, horizontal: assignees.length > 9 ? 2 : 6),
                      width: 30,
                      height: 30,
                      child: Text("+${assignees.length - 5}", style: TextStyle(color: isDark ? Colors.white: Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: FontWeight.w400))
                    ),
                  ),
                ),
              ]
            ),
          ),
          Expanded(
            child: (issue["comments"] != null && issue["comments"].length > 0) ? Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              children: [
                Icon(CupertinoIcons.bubble_right, size: 16),
                SizedBox(width: 3),
                Text("${issue["comments_count"] != null ? issue["comments_count"][0] : issue["comments"].length}")
              ],
            ) : Container(),
          ),
        ]
      )
    );
  }
}

class ListLabel extends StatelessWidget {
  const ListLabel({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          // margin: EdgeInsets.symmetric(horizontal: 2),
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
          decoration: BoxDecoration(
            color: Color(0xff22863a),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Text("feature", style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
          decoration: BoxDecoration(
            color: Color(0xff28a745),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Expanded(
            child: Text("platform: desktop", style: TextStyle(color: Colors.white, fontSize: 13))
          ),
        )
      ]
    );
  }
}

class SortList extends StatefulWidget {
  const SortList({
    Key? key,
    this.sortBy,
    this.changeSort
  }) : super(key: key);

  final sortBy;
  final changeSort;

  @override
  _SortListState createState() => _SortListState();
}

class _SortListState extends State<SortList> {
  var sortBy;

  @override
  void initState() {
    super.initState();
    this.setState(() {
      sortBy = widget.sortBy;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      height: 186,
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text("Sort by", style: TextStyle(fontWeight: FontWeight.w500))
          ),
          Divider(height: 0),
          Container(
            constraints: BoxConstraints(
              minWidth: 320
            ),
            child: TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 18))
              ),
              child: Row(
                children: [
                  sortBy == "newest" ? Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(Icons.check, size: 18),
                  ) : SizedBox(width: 42, height: 18),
                  Text("Newest", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[800], fontWeight: FontWeight.w400)),
                ],
              ),
              onPressed: () {
                widget.changeSort("newest");
                setState(() {
                  sortBy = "newest";
                });
                Navigator.of(context).pop();
              },
            ),
          ),
          Divider(height: 0),
          Container(
            constraints: BoxConstraints(
              minWidth: 320
            ),
            child: TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 18))
              ),
              child: Row(
                children: [
                  sortBy == "oldest" ? Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(Icons.check, size: 18),
                  ) : SizedBox(width: 42, height: 18),
                  Text("Oldest", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[800], fontWeight: FontWeight.w400)),
                ],
              ),
              onPressed: () {
                widget.changeSort("oldest");
                setState(() {
                  sortBy = "oldest";
                });
                Navigator.of(context).pop();
              },
            ),
          ),
          Divider(height: 0),
          Container(
            constraints: BoxConstraints(
              minWidth: 320,
            ),
            child: TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 18))
              ),
              child: Row(
                children: [
                  sortBy == "recently_updated" ? Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(Icons.check, size: 18),
                  ) : SizedBox(width: 42, height: 18),
                  Text("Recently updated", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[800], fontWeight: FontWeight.w400)),
                ],
              ),
              onPressed: () {
                widget.changeSort("recently_updated");
                setState(() {
                  sortBy = "recently_updated";
                });
                Navigator.of(context).pop();
              },
            ),
          ),
          Divider(height: 0),
          Container(
            constraints: BoxConstraints(
              minWidth: 320,
            ),
            child: TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 18))
              ),
              child: Row(
                children: [
                  sortBy == "least_recently_updated" ? Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(Icons.check, size: 18),
                  ) : SizedBox(width: 42, height: 18),
                  Text("Least recently updated", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[800], fontWeight: FontWeight.w400)),
                ],
              ),
              onPressed: () {
                widget.changeSort("least_recently_updated");
                setState(() {
                  sortBy = "least_recently_updated";
                });
                Navigator.of(context).pop();
              },
            ),
          )
        ]
      ),
    );
  }
}
