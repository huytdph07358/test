// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/work_screen/select_attribute.dart';

import '../../generated/l10n.dart';
import 'issues.dart';

class FilterItem extends StatefulWidget {
  FilterItem({
    Key? key,
    this.title,
    this.onChangeFilter,
    this.selectedAttribute,
    this.filters,
    this.isClose,
    this.sortBy,
    this.setIsCloseIssue,
    this.removeFilterItem,
    required this.type
  }) : super(key: key);

  final title;
  final onChangeFilter;
  final selectedAttribute;
  final filters;
  final isClose;
  final sortBy;
  final setIsCloseIssue;
  Function? removeFilterItem;
  String? type;

  @override
  _FilterItemState createState() => _FilterItemState();
}

class _FilterItemState extends State<FilterItem> {
  List sortedMember = [];

  changeFilter(type, value) {
    widget.onChangeFilter(type, value);
  }

  @override
  void initState() {
    super.initState();
    if (widget.title == S.current.author || widget.title == S.current.assignees) {
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

  showBottomSheetFilter(type) {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (context) {
        String textSearch = "";

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            onSearchAttribute(value) {
              setState(() {
                  textSearch = Utils.unSignVietnamese(value);
                }
              );
            }

            final channelMember = sortedMember;
            final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
            final List<dynamic> assignedToNobody = [{
              "is_nobody": true,
              "full_name": S.current.assignedNobody
            }];
            final type = widget.title == S.current.labels
                ? "label"
                : widget.title == S.current.milestones
                    ? "milestone"
                    : widget.title == S.current.author
                        ? "author"
                        : "assignee";
            final listAttribute = type == "label"
                ? currentChannel["labels"]
                : type == "milestone"
                    ? currentChannel["milestones"]
                    : type == "assignee"
                        ? assignedToNobody + channelMember
                        : channelMember;
            final filterAttribute = textSearch.trim() == ""
                ? listAttribute
                : widget.title == "Label"
                    ? listAttribute.where((e) => Utils.unSignVietnamese(e["name"]).contains(textSearch) == true).toList()
                    : widget.title == "Milestone"
                        ? listAttribute.where((e) => Utils.unSignVietnamese(e["title"]).contains(textSearch) == true).toList()
                        : listAttribute.where((e) => Utils.unSignVietnamese(e["full_name"]).contains(textSearch) == true).toList();

            return Container(
              height: MediaQuery.of(context).size.height*0.9,
              child: Column(
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 20, bottom: 20),
                          width: MediaQuery.of(context).size.width - 30,
                          height: 85,
                          child: SearchBar(
                            onSearchAttribute: onSearchAttribute
                          )
                        )
                      ]
                    )
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height*0.9 - 85,
                    child: SingleChildScrollView(
                      child: ListAttribute(
                        onChangeFilter: changeFilter,
                        type: type,
                        isDark: false,
                        listAttribute: filterAttribute,
                        isFilter: true,
                        selectedAttribute: widget.selectedAttribute
                      )
                    )
                  )
                ]
              )
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context).theme == ThemeType.DARK;
    final type = widget.type;

    return GestureDetector(
      onTap: () {
        if (widget.title != "Open") {
          showBottomSheetFilter(type);
        }
      },
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.only(top: 6, left: 6.5, right: 9.5),
        decoration: BoxDecoration(
          color: widget.selectedAttribute.length > 0 ? isDark ? Color(0xff2e3235) : Colors.lightBlue[50] : isDark ? Color(0xff828282) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: widget.title == "Open" ? 
        Container(
          child: PopupMenuButton(
            onSelected: (value) { widget.setIsCloseIssue(value); },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(width: 0.5, color: Colors.white70 )),
            // padding: EdgeInsets.all(0),
            itemBuilder: (BuildContext context) {  
              return List.generate(2, (index) {
                return index == 0 ? PopupMenuItem(
                  value: false,
                  child: Container(
                    width: 100,
                    child: Text(S.current.tOpen)
                  )
                ) : PopupMenuItem(
                  value: true,
                  child: Container(
                    width: 100,
                    child: Text(S.current.tClose)
                  )
                );
              });
            },
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(PhosphorIcons.caretDownBold, size: 15, color: isDark ? Colors.white : Color(0xff5E5E5E),),
                SizedBox(width: 4,),
                Text(widget.isClose ? S.current.tClosed : S.current.tOpen, style: TextStyle(color: isDark ? Colors.white : Color(0xff5E5E5E))),
              ]
            ),
          ),
        ) : Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(PhosphorIcons.caretDownBold, size: 17, color: isDark ? Colors.white : Color(0xff5E5E5E),),
            SizedBox(width: 4,),
            Text(widget.title, style: TextStyle(color: isDark ? Colors.white : Color(0xff5E5E5E))),
            SizedBox(width: 4),
            if(widget.selectedAttribute.length > 0) InkWell(
              onTap: () {
                if(widget.removeFilterItem == null) return;
                widget.removeFilterItem!(type);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(PhosphorIcons.x, size: 16, color: isDark ? Colors.white : Color(0xff5E5E5E),)
              ),
            ),
          ]
        )
      )
    );
  }
}