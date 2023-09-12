import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/components/boardview/CardItem.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';

import 'checklist_item.dart';

class EditChecklist extends StatefulWidget {
  const EditChecklist({
    Key? key,
    required this.checklists,
    this.card
  }) : super(key: key);

  final List checklists;
  final card;

  @override
  State<EditChecklist> createState() => _EditChecklistState();
}

class _EditChecklistState extends State<EditChecklist> {
  TextEditingController checklistController = TextEditingController();
  bool onAddChecklist = false;
  FocusNode nodeText = FocusNode();

  createChecklist() {
    // if (checklistController.text.trim() != "") {
      if (widget.card != null) {
        final token = Provider.of<Auth>(context, listen: false).token;
        CardItem card = widget.card;
        Provider.of<Boards>(context, listen: false).createChecklist(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, "Checklist").then((res) {
          this.setState(() {
            widget.checklists.insert(0, {"title": "Checklist", "tasks": [], "id": res["checklist"]["id"]});
          });
          checklistController.clear();
        });
      } else {
        this.setState(() {
          widget.checklists.insert(0, {"title": checklistController.text.trim(), "tasks": []});
        });
        checklistController.clear();
      // }
    }
    nodeText.unfocus();
  }

  deleteChecklist(checklist) {
    final index = widget.checklists.indexOf(checklist);
    if (index != -1) {
      this.setState(() {
        widget.checklists.removeAt(index);
      });

      if (widget.card != null) {
        final token = Provider.of<Auth>(context, listen: false).token;
        CardItem card = widget.card;
        Provider.of<Boards>(context, listen: false).deleteChecklistOrTask(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, checklist["id"], null);
      }
    }
  }

  KeyboardActionsConfig buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Color(0xff2E2E2E),
      nextFocus: true,
      keyboardSeparatorColor: Color(0xff2E2E2E),
      actions: [
        KeyboardActionsItem(
          focusNode: nodeText, 
          displayArrows: false,
          toolbarAlignment: MainAxisAlignment.end,
          toolbarButtons: [
            (node) {
              return  InkWell(
                onTap: () {
                  createChecklist();
                },
                child: Container(
                  alignment: Alignment.centerRight,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Color(0xff2E2E2E),
                  ),
                  height: 44,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Text("Create Checklist", style: TextStyle(color: Color(0xffFAAD14)))
                )
              );
            }
          ]
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Color(0xffA6A6A6) : Color(0xff828282),
            width: 0.25,
          ),
          bottom: BorderSide(
            color: isDark ? Color(0xffA6A6A6) : Color(0xff828282),
            width: 0.25,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: deviceWidth,
            decoration: BoxDecoration(
              color: isDark ? Color(0xff4C4C4C) : Color(0xffffffff),
              border: Border(
                bottom: BorderSide(
                  color: Color(0xff5E5E5E)
                )
              )
            ),
            padding: EdgeInsets.symmetric(vertical: 13, horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.current.checkList, style: TextStyle(fontSize: 14)),
                InkWell(
                  onTap: () {
                    createChecklist();
                  },
                  child: Icon(PhosphorIcons.plus, color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF), size: 20)
                )
              ]
            )
          ),
          onAddChecklist ? Container(
            constraints: BoxConstraints(
              minHeight: 44
            ),
            color: Color(0xff5E5E5E),
            width: deviceWidth,
            child: Wrap(
              children: [
                Container(
                  height: 44,
                  child: KeyboardActions(
                    config: buildConfig(context),
                    child: Focus(
                      onFocusChange: (focus) {
                        if (!focus) {
                          this.setState(() {
                            onAddChecklist = false;
                          });
                        }
                      },
                      child: CupertinoTextField(
                        controller: checklistController,
                        focusNode: nodeText,
                        autofocus: true,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                        cursorColor: Color(0xffFAAD14),
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: Color(0xff5E5E5E)
                        )
                      ),
                    ),
                  )
                )
              ]
            )
          ) : widget.checklists.length == 0 ? InkWell(
            onTap: () {
              createChecklist();
            },
            child: Container(
              height: 44,
              width: deviceWidth,
              color: isDark ? Color(0xff3D3D3D) : Color(0xffF8F8F8),
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 18),
              child: Text(S.current.noCheckList, style: TextStyle(fontSize: 14, color: isDark ? Color(0xffC9C9C9):Color(0xff5E5E5E)))
            )
          ) : Container(),
          Column(
            children: widget.checklists.map<Widget>((checklist) {
              return ChecklistItem(checklist: checklist, card: widget.card, deleteChecklist: deleteChecklist);
            }).toList()
          )
        ]
      ),
    );
  }
}