import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/components/boardview/CardItem.dart';
import 'package:workcake/models/models.dart';

import '../../../generated/l10n.dart';
import 'create_label.dart';
import 'label_item.dart';
import 'select_assignee.dart';

// ignore: must_be_immutable
class AttributePanel extends StatefulWidget {
  const AttributePanel({
    
    Key? key,
    this.assignees,
    this.labels,
    this.priority,
    this.onSetPriority,
    this.dueDate,
    this.onSetDueDate,
    this.card
  }) : super(key: key);

  final assignees;
  final labels;
  final priority;
  final onSetPriority;
  final dueDate;
  final onSetDueDate;
  final card;

  @override
  State<AttributePanel> createState() => _AttributePanelState();
}

class _AttributePanelState extends State<AttributePanel> {
  PanelController panelController = PanelController();

  onAddOrRemoveAssignee(assignee) {
    final index = widget.assignees.indexWhere((e) => e == assignee["id"]);
    if (index == -1) {
      this.setState(() {
        widget.assignees.add(assignee["id"]);
      });
    } else {
      this.setState(() {
        widget.assignees.removeAt(index);
      });
    }

    if (widget.card != null) {
      final token = Provider.of<Auth>(context, listen: false).token;
      CardItem card = widget.card;
      Provider.of<Boards>(context, listen: false).addOrRemoveAttribute(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, assignee["id"], "member");
    }
  }

  onAddOrRemoveLabel(label) {
    final index = widget.labels.indexWhere((e) => e == label["id"]);
    if (index == -1) {
      this.setState(() {
        widget.labels.add(label["id"]);
      });
    } else {
      this.setState(() {
        widget.labels.removeAt(index);
      });
    }

    if (widget.card != null) {
      final token = Provider.of<Auth>(context, listen: false).token;
      CardItem card = widget.card;
      Provider.of<Boards>(context, listen: false).addOrRemoveAttribute(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, label["id"], "label");
    }
  }

  onSetPriority(value) {
    this.setState(() {
      widget.onSetPriority(value);
    });
  }


  selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.dueDate != null ? widget.dueDate : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2049),
    );

    widget.onSetDueDate(picked);
  }

  getPriority(priority) {
    final bool isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;

    if (priority == null) return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text("No Priority", style: TextStyle(fontSize: 14, color: Color(0xffDBDBDB))),
    );

    Widget icon = priority == 1 ? Icon(PhosphorIcons.fire, color: Color(0xffFF7875), size: 22) 
      : priority == 2 ? 
        Container(
          height: 28,
          child: Stack(children: [
            Positioned(child: Icon(PhosphorIcons.caretUpThin, size: 22, color: Color(0xffFAAD14))),
            Positioned(top: 4, child: Icon(PhosphorIcons.caretUpThin, size: 22, color: Color(0xffFAAD14))),
            Positioned(top: 8, child: Icon(PhosphorIcons.caretUpThin, size: 22, color: Color(0xffFAAD14)))
          ]),
        ) 
      : priority == 3 ? 
        Container(
          height: 24,
          child: Stack(children: [
            Positioned(child: Icon(PhosphorIcons.caretUpThin, size: 22, color: Color(0xff27AE60))),
            Positioned(top: 4, child: Icon(PhosphorIcons.caretUpThin, size: 22, color: Color(0xff27AE60)))
          ]),
        ) 
      : priority == 4 ? 
        Icon(PhosphorIcons.caretUpThin, size: 22, color: Color(0xff69C0FF))
      : Icon(PhosphorIcons.minus, size: 22);

    Widget text = Text(
      priority == 1 ? S.current.urgent : priority == 2 ? S.current.hight : priority == 3 ? S.current.medium : priority == 4 ? S.current.low : S.current.none,
      style: TextStyle(
        color: priority == 1
        ? Color(0xffFF7875)
        : priority == 2
          ? Palette.calendulaGold
          : priority == 3
            ? Color(0xff27AE60)
            : priority == 4
              ? Color(0xff69C0FF)
              : (isDark ? Palette.defaultTextDark : Palette.defaultTextLight)
      )
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center, 
      children: [
        icon,
        SizedBox(width: 14),
        text
      ]
    );
  }
  findUser(id) {
    final members = Provider.of<Workspaces>(context, listen: false).members;
    final indexMember = members.indexWhere((e) => e["id"] == id);
    if (indexMember != -1) {
      return members[indexMember];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // List channelMembers = Provider.of<Channels>(context, listen: true).channelMember;
    final selectedBoard = Provider.of<Boards>(context, listen: true).selectedBoard;
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    List labels = selectedBoard["labels"].where((e) => widget.labels.contains(e["id"]) == true).toList();

    return SlidingUpPanel(
      maxHeight: 456,
      minHeight: 124,
      color: isDark ? Color(0xff3D3D3D) : Color(0xffFFFFFF),
      borderRadius: BorderRadius.circular(8),
      panel: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8)
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16, bottom: 20),
              child: Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Color(0xff828282),
                  borderRadius: BorderRadius.circular(100)
                )
              )
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          enableDrag: true,
                          context: context,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          builder: (BuildContext context) {
                            return SelectAssignee(assignees: widget.assignees, onAddOrRemoveAssignee: onAddOrRemoveAssignee);
                          }
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(S.current.members, style: TextStyle(fontSize: 14)),
                                Icon(PhosphorIcons.userPlus, size: 20)
                              ]
                            ),
                            SizedBox(height: 12),
                            Divider(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB), thickness: 1, height: 1),
                            widget.assignees.length == 0 ? Container(
                              margin: EdgeInsets.only(top: 12),
                              child: Text(S.current.noMembers, style: TextStyle(fontSize: 14, color: Color(0xffDBDBDB)))
                            ) : Column(
                              children: widget.assignees.map<Widget>((e) {
                                final member =   findUser(e);
                                return member == null ? Container() : Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)
                                      )
                                    )
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Row(
                                    children: [
                                      CachedAvatar(member["avatar_url"], name: member["full_name"], width: 24, height: 24),
                                      SizedBox(width: 12),
                                      Text(member["full_name"] ?? "", style: TextStyle(fontSize: 14))
                                    ]
                                  )
                                );
                              }).toList()
                            )
                          ]
                        )
                      )
                    ),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          enableDrag: true,
                          context: context,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          builder: (BuildContext context) {
                            return SelectLabel(labels: widget.labels, onAddOrRemoveLabel: onAddOrRemoveLabel);
                          }
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: 16, top: 12, left: 16, bottom: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(S.current.labels, style: TextStyle(fontSize: 14)),
                                Icon(PhosphorIcons.tag, size: 20)
                              ]
                            ),
                            Divider(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB), thickness: 1, height: 24),
                            labels.length == 0 ? Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(S.current.noLabel, style: TextStyle(fontSize: 14, color: Color(0xffDBDBDB))),
                            ) : Wrap(
                              children: labels.map<Widget>((e) {
                                return Container(margin: EdgeInsets.only(bottom: 8, right: 8), child: LabelItem(label: e));
                              }).toList()
                            )
                          ]
                        )
                      )
                    ),
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          enableDrag: true,
                          context: context,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          builder: (BuildContext context) {
                            return SelectPriority(onSetPriority: onSetPriority, priority: widget.priority);
                          }
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(S.current.priority, style: TextStyle(fontSize: 14)),
                                Icon(PhosphorIcons.warning, size: 20)
                              ]
                            ),
                            SizedBox(height: 4),
                            Divider(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB), thickness: 1),
                            getPriority(widget.priority)
                          ]
                        )
                      )
                    ),
                    InkWell(
                      onTap: () {
                        selectDate(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(S.current.dueDates, style: TextStyle(fontSize: 14)),
                                Icon(PhosphorIcons.calendar, size: 20)
                              ]
                            ),
                            Divider(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB), thickness: 1, height: 24),
                            Text(
                              widget.dueDate == null ? S.current.noDueDate : DateFormatter().renderTime(DateTime.parse("${widget.dueDate}"), type: "yMMMd"), 
                              style: TextStyle(fontSize: 14, color: Color(0xffDBDBDB))
                            )
                          ]
                        )
                      )
                    ),
                    SizedBox(height: 18)
                  ]
                )
              )
            )
          ]
        )
      )  
    );
  }
}

class SelectPriority extends StatefulWidget {
  const SelectPriority({
    Key? key,
    this.priority,
    this.onSetPriority
  }) : super(key: key);

  final priority;
  final onSetPriority;

  @override
  State<SelectPriority> createState() => _SelectPriorityState();
}

class _SelectPriorityState extends State<SelectPriority> {
  setPriority(value) {
    this.setState(() {
      widget.onSetPriority(value);
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height/2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: Color(0xff828282),
                borderRadius: BorderRadius.circular(100)
              )
            )
          ),
          Divider(color: Color(0xff5E5E5E), thickness: 1, height: 1),
          InkWell(
            onTap: () {
             setPriority(1);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 18),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xff5E5E5E)
                  )
                )
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.fire, color: Color(0xffFF7875), size: 21),
                  SizedBox(width: 12),
                  Text(S.current.urgent, style: TextStyle(color: Color(0xffFF7875)))
                ]
              )
            ),
          ),
          InkWell(
            onTap: () {
             setPriority(2);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 18),
              padding: EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xff5E5E5E)
                  )
                )
              ),
              child: Row(
                children: [
                  Container(
                    height: 28,
                    child: Stack(children: [
                      Positioned(child: Icon(PhosphorIcons.caretUpThin, size: 19, color: Color(0xffFAAD14))),
                      Positioned(top: 4, child: Icon(PhosphorIcons.caretUpThin, size: 19, color: Color(0xffFAAD14))),
                      Positioned(top: 8, child: Icon(PhosphorIcons.caretUpThin, size: 19, color: Color(0xffFAAD14)))
                    ]),
                  ),
                  SizedBox(width: 12),
                  Text(S.current.hight, style: TextStyle(color: Color(0xffFAAD14)))
                ]
              )
            )
          ),
          InkWell(
            onTap: () {
             setPriority(3);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 18),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xff5E5E5E)
                  )
                )
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(children: [
                    Positioned(child: Icon(PhosphorIcons.caretUpThin, size: 19, color: Color(0xff27AE60))),
                    Positioned(top: 4, child: Icon(PhosphorIcons.caretUpThin, size: 19, color: Color(0xff27AE60)))
                  ]),
                  SizedBox(width: 12),
                  Text(S.current.medium, style: TextStyle(color: Color(0xff27AE60)))
                ]
              )
            ),
          ),
          InkWell(
            onTap: () {
             setPriority(4);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 18),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xff5E5E5E)
                  )
                )
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.caretUp, color: Color(0xff69C0FF), size: 20),
                  SizedBox(width: 12),
                  Text(S.current.low, style: TextStyle(color: Color(0xff69C0FF)))
                ]
              )
            ),
          ),
          InkWell(
            onTap: () {
             setPriority(5);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 18),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xff5E5E5E)
                  )
                )
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.minus, size: 20),
                  SizedBox(width: 12),
                  Text(S.current.none)
                ]
              )
            ),
          )
        ]
      )
    );
  }
}

class SelectLabel extends StatefulWidget {
  const SelectLabel({
    Key? key,
    this.labels,
    this.onAddOrRemoveLabel
  }) : super(key: key);

  final labels;
  final onAddOrRemoveLabel;

  @override
  State<SelectLabel> createState() => _SelectLabelState();
}

class _SelectLabelState extends State<SelectLabel> {
  @override
  Widget build(BuildContext context) {
    final labels = Provider.of<Boards>(context, listen: true).selectedBoard["labels"];
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      height: MediaQuery.of(context).size.height - 48,
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(PhosphorIcons.arrowLeft, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), size: 20)
                    ),
                    Text(S.current.labels, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D))),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(S.current.done, style: TextStyle(fontSize: 14, color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF), fontWeight: FontWeight.w400))
                    )
                  ]
                )
              ),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CupertinoTextField(
                  placeholder: S.current.search,
                  style: TextStyle(fontSize: 14, color: Palette.defaultTextDark),
                  padding: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB),
                    borderRadius: BorderRadius.circular(16)
                  ),
                  prefix: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(PhosphorIcons.magnifyingGlass, size: 18)
                  )
                )
              ),
              SizedBox(height: 12),
              Divider(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB), height: 1, thickness: 1),
              Column(
                children: labels.map<Widget>((e) {
                  return InkWell(
                    onTap: () {
                      this.setState(() {
                        widget.onAddOrRemoveLabel(e);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)
                          )
                        )
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  onChanged: (bool? value) {  
                                    this.setState(() {
                                      widget.onAddOrRemoveLabel(e);
                                    });
                                  }, 
                                  checkColor: Color(0xff2E2E2E),
                                  activeColor: isDark ? Color(0xffFAAD14) : Color(0xff1890FF),
                                  value: widget.labels.contains(e["id"])
                                )
                              ),
                              SizedBox(width: 14),
                              LabelItem(label: e)
                            ]
                          ),
                          Wrap(
                            children: [
                              InkWell(
                                onTap: () {},
                                child: Icon(PhosphorIcons.pencilSimpleLine, size: 18, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D))
                              ),
                              SizedBox(width: 14),
                              InkWell(
                                onTap: () {},
                                child: Icon(PhosphorIcons.trashSimple, size: 18, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D))
                              )
                            ]
                          )
                        ]
                      )
                    )
                  );
                }).toList()
              )
            ]
          ),
          Positioned(
            bottom: 56,
            right: 16,
            left: 16,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  enableDrag: true,
                  context: context,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  builder: (BuildContext context) {
                    return CreateLabel();
                  }
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xff1890FF),
                  borderRadius: BorderRadius.circular(4)
                ),
                width: MediaQuery.of(context).size.width,
                height: 40,
                child: Center(child: Text("Create a new label"))
              ),
            )
          )
        ]
      )
    );
  }
}
