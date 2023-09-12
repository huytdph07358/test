import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/progress.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/desktop/workview_desktop/label.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/work_screen/bottom_sheet_create_issue.dart';
import 'package:workcake/screens/work_screen/issue_info.dart';
import 'package:workcake/screens/work_screen/list_assignees.dart';

import 'filter_item.dart';

class Issues extends StatefulWidget {
  Issues({Key? key, this.changePageView, this.isNavigator}) : super(key: key);

  final changePageView;
  final isNavigator;

  @override
  _IssuesState createState() => _IssuesState();
}

class _IssuesState extends State<Issues> {
  List issues = [];
  bool isClose = false;
  List authorId = [];
  List labels = [];
  List assignees = [];
  List milestoneId = [];
  String sortBy = "newest";
  List filters = [];
  String searchString = "";
  var controller = new ScrollController();
  var currentPage = 1;
  var lastLength = 0;
  int? totalIssueClosed;

  showModalCreateIssue(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        enableDrag: true,
        context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        builder: (BuildContext context) {
          return Container(child: BottomSheetCreateIssue(addNewIssue: updateIssue));
        });
  }

  @override
  void initState() {
    super.initState();
    controller = new ScrollController()..addListener(_scrollListener);

    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace =
        Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel =
        Provider.of<Channels>(context, listen: false).currentChannel;

    totalIssueClosed = currentChannel["closedIssuesCount"];
    Timer.run(() async {
      Provider.of<Channels>(context, listen: false).getMilestoneStatiscal(token, currentWorkspace["id"], currentChannel["id"]);
      Provider.of<Channels>(context, listen: false).getLabelsStatistical(token, currentWorkspace["id"], currentChannel["id"]);
      await Provider.of<Channels>(context, listen: false)
          .getListIssue(token, currentWorkspace["id"], currentChannel["id"], 1,
              false, [], "newest", "")
          .then((value) => {
                this.setState(() {
                  issues = value["issues"];
                  lastLength = (value["issues"]).length;
                })
              });
    });
  }

  removeFilterItem(String type) {
    switch (type) {
      case "label":
        setState(() {
          labels = [];
        });
        setNewFilter(type, false);
        break;

      case "milestone":
        setState(() {
          milestoneId = [];
        });
        setNewFilter(type, false);
        break;

      case "author":
        setState(() {
          authorId = [];
        });
        setNewFilter(type, false);
        break;

      case "assignee":
        setState(() {
          assignees = [];
        });
        setNewFilter(type, false);
        break;

      default:
      print("case is invalid");
    }
  }

  onChangeFilter(type, value) {
    bool closeModal = false;

    if (type == "label") {
      final index = labels.indexWhere((e) => e == value["id"]);

      if (index == -1) {
        labels.add(value["id"]);
      } else {
        labels.removeAt(index);
      }
    } else if (type == "milestone") {
      final index = milestoneId.indexWhere((e) => e == value["id"]);

      if (index == -1) {
        if (milestoneId.length > 0) milestoneId.removeAt(0);
        milestoneId.add(value["id"]);
        closeModal = true;
      } else {
        milestoneId.removeAt(index);
      }
    } else if (type == "author") {
      final index = authorId.indexWhere((e) => e == value["id"]);

      if (index == -1) {
        if (authorId.length > 0) authorId.removeAt(0);
        authorId.add(value["id"]);
        closeModal = true;
      } else {
        authorId.removeAt(index);
      }
    } else {
      final index = assignees.indexWhere((e) => e == value["id"]);
      final indexNobody =
          assignees.indexWhere((element) => element == "is_nobody");

      if (value["is_nobody"] == true) {
        if (indexNobody != -1) {
          assignees.clear();
        } else {
          assignees.clear();
          assignees.add("is_nobody");
        }
      } else {
        if (index == -1) {
          assignees.add(value["id"]);
          if (indexNobody != -1) {
            assignees.removeAt(indexNobody);
          }
        } else {
          assignees.removeAt(index);
        }
      }
    }

    setNewFilter(type, closeModal);
  }

  setNewFilter(type, closeModal) async {
    List newFilters = [];
    final auth = Provider.of<Auth>(context, listen: false);
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final channelMember = Provider.of<Channels>(context, listen: false).channelMember;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    List labelsChannel =
        currentChannel["labels"] != null ? currentChannel["labels"] : [];
    List milestonesChannel = currentChannel["milestones"] != null
        ? currentChannel["milestones"]
        : [];

    authorId.forEach((e) {
      var index = channelMember.indexWhere((ele) => ele["id"] == e);
      if (index != -1) {
        newFilters.add({
          "type": "author",
          "name": channelMember[index]["full_name"],
          "id": channelMember[index]["id"]
        });
      }
    });

    assignees.forEach((e) {
      if (e == "is_nobody") {
        newFilters
            .add({"type": "assignee", "name": "Assigned to nobody", "id": 0});
      } else {
        var index = channelMember.indexWhere((ele) => ele["id"] == e);
        if (index != -1) {
          newFilters.add({
            "type": "assignee",
            "name": channelMember[index]["full_name"],
            "id": channelMember[index]["id"]
          });
        }
      }
    });

    milestoneId.forEach((e) {
      var index = milestonesChannel.indexWhere((ele) => ele["id"] == e);
      if (index != -1) {
        newFilters.add({
          "type": "milestone",
          "name": milestonesChannel[index]["title"],
          "id": milestonesChannel[index]["id"]
        });
      }
    });

    labels.forEach((e) {
      var index = labelsChannel.indexWhere((ele) => ele["id"] == e);
      if (index != -1) {
        newFilters.add({
          "type": "label",
          "name": labelsChannel[index]["name"],
          "id": labelsChannel[index]["id"]
        });
      }
    });

    this.setState(() {
      filters = newFilters;
    });
    if (closeModal) Navigator.pop(context);
    await Provider.of<Channels>(context, listen: false)
        .getListIssue(auth.token, currentWorkspace["id"],
            currentChannel['id'], 1, isClose, filters, sortBy, searchString)
        .then((res) => {
              this.setState(() {
                currentPage = 1;
                issues = res["issues"];
                lastLength = res["issues"].length;
              }),
              
            });
  }

  updateIssue() {
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final auth = Provider.of<Auth>(context, listen: false);
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    Provider.of<Channels>(context, listen: false)
      .getListIssue(auth.token, currentWorkspace["id"],currentChannel['id'], currentPage, isClose, filters, sortBy, searchString)
      .then((res) => {
        this.setState(() {
          currentPage = 1;
          issues = res["issues"];
          lastLength = res["issues"].length;
        }),
      });
  }

  addNewIssue(issue) {
    setState(() => issues = [issue] + issues);
  }

  onSearchFilter(value) async {
    searchString = value;

    final currentChannel =
        Provider.of<Channels>(context, listen: false).currentChannel;
    final auth = Provider.of<Auth>(context, listen: false);
    final currentWorkspace =
        Provider.of<Workspaces>(context, listen: false).currentWorkspace;

    await Provider.of<Channels>(context, listen: false)
        .getListIssue(auth.token, currentWorkspace["id"], currentChannel['id'],
            1, isClose, filters, sortBy, searchString)
        .then((res) => {
              this.setState(() {
                currentPage = 1;
                issues = res["issues"];
                lastLength = res["issues"].length;
              }),
            });
  }

  setIsCloseIssue(value) async {
    if (isClose == value) return;
    isClose = value;

    final currentChannel =
        Provider.of<Channels>(context, listen: false).currentChannel;
    final auth = Provider.of<Auth>(context, listen: false);
    final currentWorkspace =
        Provider.of<Workspaces>(context, listen: false).currentWorkspace;

    await Provider.of<Channels>(context, listen: false)
        .getListIssue(auth.token, currentWorkspace["id"], currentChannel['id'],
            1, isClose, filters, sortBy, searchString)
        .then((res) => {
              this.setState(() {
                currentPage = 1;
                issues = res["issues"];
                lastLength = res["issues"].length;
              }),
            });
  }

  bool load = false;

  _scrollListener() async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentChannel =
        Provider.of<Channels>(context, listen: false).currentChannel;
    final currentWorkspace =
        Provider.of<Workspaces>(context, listen: false).currentWorkspace;

    if (controller.position.extentAfter < 10) {
      if (lastLength >= 30 && !load) {
        load = true;
        await Provider.of<Channels>(context, listen: false)
            .loadMoreIssue(token, currentWorkspace["id"], currentChannel["id"],
                currentPage + 1, isClose, filters, sortBy, searchString)
            .then((value) => {
                  this.setState(() {
                    currentPage += 1;
                  }),
                  load = false,
                  issues = issues + value["issues"],
                  lastLength = value["issues"].length
                });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context).theme == ThemeType.DARK;
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;

    return Scaffold(
      body: Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? Color(0xff2E2E2E) : Colors.white,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            if (Utils.checkedTypeEmpty(widget.isNavigator)) {
                              Navigator.pop(context);
                            } else {
                              widget.changePageView(1);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Icon(PhosphorIcons.arrowLeft,
                              size: 20,
                              color: isDark
																? Color(0xffEDEDED)
																: Color(0xff3D3D3D)),
                          ),
                        ),
                        Text("${currentChannel["name"]}",
                          style: TextStyle(
														color: isDark
															? Color(0xffEDEDED)
															: Color(0xff3D3D3D),
														fontSize: 17,
														fontWeight: FontWeight.w700)),
                        InkWell(
                          onTap: () {
                            showModalCreateIssue(context);
                          },
                          child: Container(
														padding: EdgeInsets.symmetric(
															horizontal: 16, vertical: 12),
														child: Icon(
															PhosphorIcons.plusBold,
															color: isDark
																? Color(0xffEDEDED)
																: Color(0xff3D3D3D),
															size: 19,
														))),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      height: 40,
                      child: SearchBar(onSearchFilter: onSearchFilter)),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                      border: Border(
                        top: BorderSide(
                            color:
                                isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                        bottom: BorderSide(
                            color:
                                isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                      ),
                    ),
                    child:
                        ListView(scrollDirection: Axis.horizontal, children: [
                      SizedBox(
                        width: 8,
                      ),
                      FilterItem(
                        type: "",
                        onChangeFilter: onChangeFilter,
                        title: "Open",
                        filters: filters,
                        isClose: isClose,
                        sortBy: sortBy,
                        selectedAttribute: [],
                        setIsCloseIssue: setIsCloseIssue
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Container(
                        width: 1,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        color: isDark ? Color(0xff828282) : Color(0xffA6A6A6),
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      FilterItem(
                        type: "author",
                        onChangeFilter: onChangeFilter,
                        title: S.current.author,
                        selectedAttribute: authorId,
                        filters: filters,
                        isClose: isClose,
                        sortBy: sortBy,
                        removeFilterItem: removeFilterItem,
                      ),
                      FilterItem(
                        type: "assignee",
                        onChangeFilter: onChangeFilter,
                        title: S.current.assignees,
                        selectedAttribute: assignees,
                        filters: filters,
                        isClose: isClose,
                        sortBy: sortBy,
                        removeFilterItem: removeFilterItem,
                      ),
                      FilterItem(
                        type: "milestone",
                        onChangeFilter: onChangeFilter,
                        title: S.current.milestones,
                        selectedAttribute: milestoneId,
                        filters: filters,
                        isClose: isClose,
                        sortBy: sortBy,
                        removeFilterItem: removeFilterItem,
                      ),
                      FilterItem(
                        type: "label",
                        onChangeFilter: onChangeFilter,
                        title: S.current.labels,
                        selectedAttribute: labels,
                        filters: filters,
                        isClose: isClose,
                        sortBy: sortBy,
                        removeFilterItem: removeFilterItem,
                      ),
                    ]),
                  )
                ],
              ),
            ),
            Provider.of<Channels>(context, listen: true).isIssueLoading && issues.isEmpty
            ? Expanded(
              child: SingleChildScrollView(
                child: shimmerEffect(context),
              ),
            )
            : Expanded(
              child: Container(
								color: isDark ? Color(0xFF2E2E2E) : Colors.white,
								child: ListView.builder(
									keyboardDismissBehavior:
											ScrollViewKeyboardDismissBehavior.onDrag,
									controller: controller,
									padding: EdgeInsets.all(0),
									itemCount: issues.length,
									itemBuilder: (context, index) {
										var issue = issues[index];
										return IssueItem(issue: issue, updateIssue: updateIssue,);
									})),
            ),
          ],
        ),
      ),
    ));
  }
}

////////////////////////////////////////////////////////////////////////////////////////
/////////// ISSUE ITEM ///////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

class IssueItem extends StatefulWidget {
  const IssueItem({
    Key? key,
    required this.issue,
    this.updateIssue
  }) : super(key: key);

  final issue;
  final updateIssue;

  @override
  _IssueItemState createState() => _IssueItemState();
}

class _IssueItemState extends State<IssueItem> {
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
          total += 1;
        }
        if (sub == "- [x]") {
          checked += 1;
        }
      }
    }

    return total > 0 ? Wrap(
      direction: Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.playlist_add_check_outlined,
          color: isDark
            ? Colors.grey[400]
            : Colors.black.withOpacity(0.45)),
        SizedBox(width: 2),
        Text("$checked of $total",
          style: TextStyle(
            color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E),
            fontSize: 12.5)),
        SizedBox(width: 4),
        Container(
          width: 70,
          height: 6,
          padding: EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: checked / total,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
              backgroundColor: Color(0xffD6D6D6),
            )
          )
        ),
        Platform.isAndroid || Platform.isIOS ? SizedBox(width: 12) : SizedBox()
      ]
    ) 
    : Wrap();
  }

  parseDatetime(time) {
    if (time != "") {
      DateTime offlineTime = DateTime.parse(time).add(Duration(hours: 7));
      DateTime now = DateTime.now();
      final difference = now.difference(offlineTime).inMinutes;
      final int hour = difference ~/ 60;
      final int minutes = difference % 60 + 1;
      final int day = hour ~/ 24;

      if (day > 0) {
        int month = day ~/ 30;
        int year = month ~/ 12;
        if (year >= 1)
          return '${year.toString().padLeft(1, "")} ${year > 1 ? S.current.years : S.current.year} ${S.current.ago}';
        else {
          if (month >= 1)
            return '${month.toString().padLeft(1, "")} ${month > 1 ? S.current.months : S.current.month} ${S.current.ago}';
          else
            return '${day.toString().padLeft(1, "")} ${day > 1 ? S.current.days : S.current.day} ${S.current.ago}';
        }
      } else if (hour > 0) {
        return '${hour.toString().padLeft(1, "")} ${hour > 1 ? S.current.hours  : S.current.hour } ${S.current.ago}';
      } else if (minutes <= 1) {
        return 'moments ago';
      } else {
        return '${minutes.toString().padLeft(1, "0")} minutes ago';
      }
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final workspaceMember = Provider.of<Workspaces>(context, listen: true).members;
    final indexUser = workspaceMember.indexWhere((e) => e["id"] == widget.issue["author_id"]);
    final authorName = indexUser == -1 ? null : workspaceMember[indexUser]?["nickname"]?? workspaceMember[indexUser]?["full_name"];
    List labels = currentChannel["labels"] != null ? currentChannel["labels"] : [];
    List issueLabels = widget.issue["labels"] != null
        ? labels.where((e) => widget.issue["labels"].contains(e["id"])).toList()
        : [];

    final channelMember =
        Provider.of<Channels>(context, listen: true).channelMember;
    List assignees = widget.issue["assignees"] != null
        ? channelMember
            .where((e) => widget.issue["assignees"].contains(e["id"]))
            .toList()
        : [];

    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;

    return InkWell(
      onTap: () {
        widget.issue["comments"] = [];
        Provider.of<Channels>(context, listen: false).updateUnreadIssue(auth.token, currentWorkspace["id"], currentChannel["id"], widget.issue["id"], currentUser["id"]);
        Navigator.push(context, MaterialPageRoute(builder: (context) => IssueInfo(issue: widget.issue, updateIssue: widget.updateIssue)));
      },
      child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Color(0xff8C8C8C).withOpacity(0.65),
                      width: 0.65))),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.info,
                          color: widget.issue["is_closed"]
                              ? Colors.redAccent
                              : Color(0xff27AE60),
                          size: 18),
                      SizedBox(
                        width: 8,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 58,
                        child: Text(
                          Utils.capitalize(widget.issue["title"]),
                          style: TextStyle(
                              color: isDark ? Colors.white : Color(0xff2E2E2E),
                              fontSize: 17,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        )
                      )
                    ]
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top: 2, left: 2),
                  child: Wrap(
                    children: issueLabels.map<Widget>((e) {
                      var label = e;
                      return Container(
                        padding: EdgeInsets.only(top: 2, bottom: 2),
                        child: LabelDesktop(
                          labelName: label["name"],
                          color: int.parse("0XFF${label["color_hex"]}")));
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 3, left: 1),
                  child: Text(
                    "#${widget.issue["unique_id"]} ${S.current.opened} ${parseDatetime(widget.issue["inserted_at"])} ${S.current.by} $authorName ",
                    style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 3, left: 1),
                    // width: MediaQuery.of(context).size.width - 92,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (widget.issue["description"] != null)
                                parseDescription(widget.issue["description"]),
                                if (widget.issue["comments_count"] != 0)
                                  Wrap(
                                    direction: Axis.horizontal,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Text("${widget.issue["comments_count"]}",
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: isDark
                                            ? Color(0xffA6A6A6)
                                            : Color(0xff5E5E5E))),
                                      SizedBox(width: 4),
                                      Icon(PhosphorIcons.chatCircleDots,
                                        size: 18,
                                        color: isDark
                                          ? Color(0xffA6A6A6)
                                          : Color(0xff5E5E5E)),
                                      SizedBox(width: 10),
                                    ]),
                                  if (assignees.length > 0)
                                    ListAssignees(
                                      assignees: assignees, isDark: isDark),
                                ]),
                        ])),
              ],
            ),
          )),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////////////
/////////// FILTERITEM ///////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

class SearchBar extends StatefulWidget {
  SearchBar({
    Key? key,
    this.onSearchFilter,
    this.onSearchAttribute,
  }) : super(key: key);

  final onSearchFilter;
  final onSearchAttribute;

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController controller = TextEditingController();
  var _debounce;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;

    return CupertinoTextField(
      controller: controller,
      decoration: BoxDecoration(
        color: isDark ? Color(0xff5E5E5E) : Color(0xffF3F3F3),
        borderRadius: BorderRadius.circular(4),
      ),
      style: TextStyle(
        color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E),
        fontSize: 16
      ),
      autofocus: false,
      placeholder: S.current.search,
      placeholderStyle: TextStyle(
        color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E),
        fontSize: 16
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      prefix: Container(
        padding: EdgeInsets.only(left: 12),
        child: Icon(
          PhosphorIcons.magnifyingGlass,
          color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E),
          size: 20
        )
      ),
      suffix: controller.text != "" ? InkWell(
        onTap: () {
          controller.clear();
          if (widget.onSearchFilter != null)
            widget.onSearchFilter("");
          if (widget.onSearchAttribute != null)
            widget.onSearchAttribute("");
        },
        child: Container(
          padding: EdgeInsets.only(left: 6, right: 12),
          child: Icon(PhosphorIcons.x, size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),
        )
      ) : Container(),
      onChanged: (value) {
        if (widget.onSearchAttribute != null)
          widget.onSearchAttribute(value);

        if (_debounce?.isActive ?? false) _debounce.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () async {
          if (widget.onSearchFilter != null) widget.onSearchFilter(value);
        });
      }
    );
  }
}
