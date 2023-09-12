import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:popover/popover.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/models/models.dart';

import '../CardItem.dart';
import 'select_assignee.dart';

class ChecklistItem extends StatefulWidget {
  ChecklistItem({
    Key? key,
    this.checklist,
    this.card,
    this.deleteChecklist
  }) : super(key: key);

  final checklist;
  final card;
  final deleteChecklist;

  @override
  _ChecklistItemState createState() => _ChecklistItemState();
}

class _ChecklistItemState extends State<ChecklistItem> {
  TextEditingController checkListController = TextEditingController();
  FocusNode checkListNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.checklist != null ) {
      checkListController.text = widget.checklist["title"] ?? "";
    }
  }
  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.checklist.toString() != widget.checklist.toString()) {
      checkListController = TextEditingController(text: widget.checklist['title']);
    }
  }
  onCreateTask(task) {
    this.setState(() {
      widget.checklist["tasks"].add(task);
    });
  }

  onDeleteChecklist(checklist) {
    widget.deleteChecklist(checklist);
  }

  updateChecklist() {
    final token = Provider.of<Auth>(context, listen: false).token;
    CardItem? card =  widget.card;
    if (card == null || checkListController.text.trim() == "") return;
    Provider.of<Boards>(context, listen: false).updateChecklist(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, widget.checklist["id"], checkListController.text);
    widget.checklist["title"] = checkListController.text;
  }

  onDeleteTask(task) {
    final token = Provider.of<Auth>(context, listen: false).token;
    CardItem? card = widget.card;
    final index = widget.checklist["tasks"].indexOf(task);
    if (index == -1) return;
    this.setState(() {
      widget.checklist["tasks"].removeAt(index);
    });

    if (card != null) {
      Provider.of<Boards>(context, listen: false).deleteChecklistOrTask(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, widget.checklist["id"], task["id"]);
    }
  }

  onCheckAll(value) {
    widget.checklist["tasks"].forEach((item) => item["is_checked"] = value);
    this.setState(() {});

    if (widget.card == null) return;
    final token = Provider.of<Auth>(context, listen: false).token;
    CardItem card = widget.card;
    Provider.of<Boards>(context, listen: false).checkAllTask(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, widget.checklist["id"], value);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: isDark ? Color(0xff3D3D3D) : Color(0xffffffff),
            border: Border(
              bottom: BorderSide(
                width: 0.5,
                color: Color(0xff5E5E5E)
              )
            )
          ),
          padding: EdgeInsets.symmetric(vertical: 11, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.caretDown, color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Focus(
                        onFocusChange: ((value) => {
                          if(!value) {
                            updateChecklist()
                          }
                        }),
                        child: CupertinoTextField(
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
                          cursorColor: Color(0xffFAAD14),
                          controller: checkListController,
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xff3D3D3D) : Color(0xffffffff),
                          ),
                          onSubmitted: (value) {
                            updateChecklist();
                          },
                          focusNode: checkListNode,
                        ),
                      ),
                    )
                  ]
                ),
              ),
              ChecklistShowMoreIcon(checklist: widget.checklist, onDeleteChecklist: onDeleteChecklist, onCheckAll: onCheckAll)
            ]
          )
        ),
        Column(
          children: [

          ]
        ),
        TaskItem(checklist: widget.checklist, onCreateTask: onCreateTask, card: widget.card, onDeleteTask: onDeleteTask),
        Column(
          children: widget.checklist["tasks"].map<Widget>((task) {
            return TaskItem(checklist: widget.checklist, task: task, card: widget.card, onCreateTask: onCreateTask, onDeleteTask: onDeleteTask);
          }).toList(),
        )
      ]
    );
  }
}

class ChecklistShowMoreIcon extends StatefulWidget {
  const ChecklistShowMoreIcon({
    Key? key,
    this.checklist,
    this.onDeleteChecklist,
    this.onCheckAll
  }) : super(key: key);

  final checklist;
  final onDeleteChecklist;
  final onCheckAll;

  @override
  State<ChecklistShowMoreIcon> createState() => _ChecklistShowMoreIconState();
}

class _ChecklistShowMoreIconState extends State<ChecklistShowMoreIcon> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    return InkWell(
      onTap: () {
        showPopover(
          context: context,
          direction: PopoverDirection.bottom,
          transitionDuration: Duration(milliseconds: 0),
          arrowWidth: 0, 
          arrowHeight: 0,
          shadow: [],
          backgroundColor: isDark ? Color(0xff3D3D3D): Color(0xffF3F3F3),
          bodyBuilder: (context) {
            return Container(
              height: 122,
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      widget.onCheckAll(true);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 150,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(PhosphorIcons.checks, size: 19),
                          SizedBox(width: 10),
                          Text("Check all")
                        ]
                      )
                    )
                  ),
                  Divider(color: Color(0xff5E5E5E), height: 1),
                  InkWell(
                    onTap: () {
                      widget.onCheckAll(false);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 150,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(PhosphorIcons.checks, size: 19),
                          SizedBox(width: 10),
                          Text("Uncheck all")
                        ]
                      )
                    )
                  ),
                  Divider(color: Color(0xff5E5E5E), height: 1),
                  InkWell(
                    onTap: () {
                      widget.onDeleteChecklist(widget.checklist);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 150,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(PhosphorIcons.trashSimple, size: 19, color: Color(0xffFF7875)),
                          SizedBox(width: 10),
                          Text("Delete", style: TextStyle(color: Color(0xffFF7875)))
                        ]
                      ),
                    ),
                  )
                ]
              )
            );
          }
        );
      },
      child: Container(
        width: 20,
        height: 20,
        child: Text("...", style: TextStyle(letterSpacing: 1.5, fontSize: 17))
      )
    );
  }
}

class TaskItem extends StatefulWidget {
  const TaskItem({
    Key? key,
    required this.checklist,
    this.onCreateTask,
    this.onDeleteTask,
    this.task,
    this.card
  }) : super(key: key);

  final checklist;
  final onCreateTask;
  final onDeleteTask;
  final task;
  final card;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  FocusNode nodeText = FocusNode();
  TextEditingController taskController = TextEditingController();
  List assignees = [];
  List attachments = [];
  bool onEdit = false;

  @override
  void initState() { 
    super.initState();
    if (widget.task != null) {
      taskController.text = widget.task["title"] ?? "";
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.task.toString() != widget.task.toString()) {
      taskController = TextEditingController(text: widget.task['title']);
    }
  }


  KeyboardActionsConfig buildConfig(BuildContext context) {
    List assignees = getAssignees();
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: isDark ? Color(0xff4C4C4C) : Color(0xffF3F3F3),
      nextFocus: true,
      // keyboardSeparatorColor: Color.fromARGB(255, 233, 31, 31),
      actions: [
        KeyboardActionsItem(
          focusNode: nodeText, 
          displayArrows: false,
          toolbarButtons: [
            (node) {
              return  Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      enableDrag: true,
                                      context: context,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      builder: (BuildContext context) {
                                        return SelectAssignee(assignees: assignees, onAddOrRemoveAssignee: onAddOrRemoveAssignee);
                                      }
                                    );
                                  },
                                  child: Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border(right: BorderSide(color: Color(0xff5E5E5E)))
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Icon(PhosphorIcons.userPlus, size: 20),
                                        SizedBox(width: 12),
                                        Text("Assignees", style: TextStyle(color: Color(0xffDBDBDB)))
                                      ]
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    openFileSelector();
                                  },
                                  child: Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border(right: BorderSide(color: Color(0xff5E5E5E)))
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Icon(PhosphorIcons.paperclip, size: 20),
                                        SizedBox(width: 12),
                                        Text("Attachments", style: TextStyle(color: Color(0xffDBDBDB)))
                                      ]
                                    )
                                  ),
                                ),
                                if(widget.task != null) InkWell(
                                  onTap: () {
                                    // widget.onDeleteTask(widget.task);
                                    showDialog(
                                      context: context, 
                                      builder: (BuildContext context) {
                                        return CustomDialogNew(
                                          title: "Delete Task", 
                                          content: "Do you want to delete task \"${widget.task["title"]}\" ?",
                                          confirmText: "Delete",
                                          onConfirmClick: () {
                                            print(widget.task);
                                            widget.onDeleteTask(widget.task);
                                            Navigator.pop(context);
                                          },
                                        );
                                      }
                                    );
                                  },
                                  child: Container(
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border(right: BorderSide(color: Color(0xff5E5E5E)))
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Icon(PhosphorIcons.trash, size: 20),
                                        SizedBox(width: 12),
                                        Text("Delete", style: TextStyle(color: Color(0xffDBDBDB)))
                                      ]
                                    )
                                  ),
                                )
                              ],
                            ),
                          ]
                        ),
                      ),
                    ),
                  ]
                )
              );
            }
          ]
        )
      ]
    );
  }

  onCreateOrChangeTask() {
    final token = Provider.of<Auth>(context, listen: false).token;
    CardItem? card = widget.card;

    if (widget.task == null) {
      if (taskController.text.trim() != "") {
        if (card == null) {
          var newTask = {"title": taskController.text.trim(), "assignees": assignees, 'attachments': attachments, 'value': false};
          widget.onCreateTask(newTask);
        } else {
          Provider.of<Boards>(context, listen: false).createOrChangeTask(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, widget.checklist["id"], taskController.text.trim(), false, null).then((res) {
            var task = res["task"];
            var newTask = {"title": task["title"], "assignees": task["assignees"], 'attachments': task["attachments"], 'value': task["is_checked"], "id": task["id"]};
            widget.onCreateTask(newTask);
          });
        }
        taskController.clear();
        assignees = [];
        attachments = [];
        nodeText.unfocus();
      }
    } else {
      this.setState(() {
        onEdit = false;
      });

      if (taskController.text.trim() == "") return;
      widget.task["title"] = taskController.text.trim();

      if (card == null) return;
      Provider.of<Boards>(context, listen: false).createOrChangeTask(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, 
        card.id, widget.checklist["id"], widget.task["title"], widget.task["is_checked"] ?? widget.task["value"] ?? false, widget.task["id"]);
    }
  }

  openFileSelector() async {
    List attachments = getAttachments();
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    List<AssetEntity> resultList = await Provider.of<Work>(context, listen: false).openFileSelector(context, maxAssets: 10);
    List results = Utils.handleFileData(resultList);
    results = results.where((e) => e.isNotEmpty).toList();

    for(var i = 0; i < results.length; i++){
      attachments.add({...results[i], 'uploading': true});
      if (!mounted) return;
      this.setState(() {});
    }

    for (var i = 0; i < attachments.length; i++) {
      if (attachments[i]["uploading"] == true) {
        var file = attachments[i];
        var dataUpload = await Provider.of<Work>(context, listen: false).getUploadData(file);
        var responseData = await Provider.of<Work>(context, listen: false).uploadImage(token, currentWorkspace["id"], dataUpload, dataUpload["mime_type"], (t) {});
      
        this.setState(() {
          attachments[i] = {...responseData, 'uploading': false, "content_id": responseData["id"]};
        });

        CardItem? card = widget.card;
        if (card != null && widget.task != null) {
          Provider.of<Boards>(context, listen: false).addTaskAttachment(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, widget.task["id"], responseData);
        }
      }
    }
  }

  onAddOrRemoveAssignee(assignee) {
    List assignees = getAssignees();
    final index = assignees.indexWhere((e) => e == assignee["id"]);
    if (index == -1) {
      this.setState(() {
        assignees.add(assignee["id"]);
      });
    } else {
      this.setState(() {
        assignees.removeAt(index);
      });
    }

    if (widget.card == null || widget.task == null) return;
    final token = Provider.of<Auth>(context, listen: false).token;
    CardItem card = widget.card;
    Provider.of<Boards>(context, listen: false).addOrRemoveTaskAssignee(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, widget.task["id"], assignee["id"]);
  }

  findUser(id) {
    final members = Provider.of<Workspaces>(context, listen: false).members;
    final indexMember = members.indexWhere((e) => e["id"] == id);

    if (indexMember != -1) {
      return members[indexMember];
    } else {
      return {};
    }
  }

  onDeleteTaskAttachment(att) {
    List attachments = getAttachments();
    final index = attachments.indexOf(att);
    if (index == -1) return;
   
    if (widget.card != null && widget.task != null) {
      final token = Provider.of<Auth>(context, listen: false).token;
      CardItem card = widget.card;
      Provider.of<Boards>(context, listen: false).removeTaskAttachment(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, widget.task["id"], widget.task["attachments"][index]["content_id"]);
    }

    this.setState(() {
      attachments.removeAt(index);
    });
  }

  getAssignees() {
    return widget.task != null ? widget.task["assignees"] : assignees;
  }

  getAttachments() {
    return widget.task != null ? widget.task["attachments"] : attachments;
  }

  onCheckTask(value) {
    this.setState(() {
      widget.task["is_checked"] = value;
    });
    
    if (widget.card == null) return;
    final token = Provider.of<Auth>(context, listen: false).token;
    CardItem card = widget.card;
    Provider.of<Boards>(context, listen: false).createOrChangeTask(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, 
      card.id, widget.checklist["id"], widget.task["title"], widget.task["is_checked"] ?? widget.task["value"] ?? false, widget.task["id"]);
  }

  @override
  Widget build(BuildContext context) {
    List assignees = getAssignees();
    List attachments = getAttachments();
    final key = widget.checklist["tasks"].indexOf(widget.task).toString();
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;

    return Slidable(
      enabled: widget.task != null,
      key: Key(key),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dragDismissible: false,
        children: [
          SlidableAction(
            backgroundColor: Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete', 
            onPressed: (BuildContext context) {  
              widget.onDeleteTask(widget.task);
            }
          )
        ]
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Color(0xff4C4C4C) : Color(0xffF3F3F3),
          border: Border(
            bottom: BorderSide(
              width: 0.25,
              color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)
            )
          )
        ),
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Transform.scale(
                        scale: 0.9,
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: Checkbox(
                            activeColor: isDark ? Palette.calendulaGold : Palette.dayBlue,
                            checkColor: Palette.defaultTextDark,
                            onChanged: (bool? value) { 
                              if (widget.task != null) {
                                onCheckTask(value);
                              }
                            }, 
                            value: widget.task != null ? widget.task["is_checked"] ?? false : false
                          )
                        )
                      ),
                      SizedBox(width: 8),
                      Container(
                        height: 30,
                        width: MediaQuery.of(context).size.width - 110,
                        child: KeyboardActions(
                          config: buildConfig(context),
                          child: CupertinoTextField(
                            onTap: () {
                              this.setState(() {
                                onEdit = true;
                              });
                            },
                            readOnly: widget.task != null && !onEdit,
                            controller: taskController,
                            focusNode: nodeText,
                            style: TextStyle(fontSize: 14, color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E)),
                            placeholderStyle: TextStyle(fontSize: 14, color: Color(0xffA6A6A6)),
                            placeholder: "Add an item",
                            cursorColor: Color(0xffFAAD14),
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff4C4C4C) : Color(0xffF3F3F3),
                            ),
                            onSubmitted: ((value) {
                              onCreateOrChangeTask();
                              nodeText.requestFocus();
                            }),
                          )
                        )
                      )
                    ]
                  ),
                  SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        enableDrag: true,
                        context: context,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        builder: (BuildContext context) {
                          return SelectAssignee(assignees: assignees, onAddOrRemoveAssignee: onAddOrRemoveAssignee);
                        }
                      );
                    },
                    child: Container(
                      height: 25,
                      width: 46,
                      child: Stack(
                        children: assignees.map<Widget>((e) {
                          var user = findUser(e);
                          double index = assignees.indexOf(e).toDouble();

                          return index < 2 || (index == 2 && assignees.length == 3) ? Positioned(
                            top: 0,
                            left: 10*index,
                            child: CachedAvatar(user["avatar_url"], name: user["full_name"], width: 24, height: 24, radius: 50)
                          ) : index == 2 ? Positioned(
                            top: 0,
                            left: 10*index,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xff2E2E2E),
                                borderRadius: BorderRadius.circular(50)
                              ),
                              width: 25,
                              height: 25,
                              child: Center(child: Text("+ ${assignees.length - 2}", style: TextStyle(fontSize: 12)))
                            )
                          ) : Container();
                        }).toList()
                      )
                    ),
                  )
                ]
              ),
            ),
            if(attachments.length > 0) Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: attachments.map<Widget>((att) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Color(0xff707070),
                        borderRadius: BorderRadius.circular(4)
                      ),
                      margin: EdgeInsets.only(right: 8),
                      width: 76,
                      height: 98,
                      child: Stack(
                        children: [
                          CachedImage(att["content_url"], width: 76, height: 98, radius: 4),
                          Positioned(
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                onDeleteTaskAttachment(att);
                              },
                              child: Icon(PhosphorIcons.x, size: 20)
                            )
                          )
                        ]
                      )
                    );
                  }).toList()
                )
              )
            )
          ]
        )
      ),
    );
  }
}