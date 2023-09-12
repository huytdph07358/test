import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/desktop/markdown/style_sheet.dart';
import 'package:workcake/desktop/markdown/widget.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/work_screen/comment_field.dart';
import '../../generated/l10n.dart';
import 'CardItem.dart';
import 'component/attribute_panel.dart';
import 'component/edit_attachment.dart';
import 'component/edit_checklist.dart';
import 'component/edit_description.dart';
import 'component/edit_title.dart';

class CardDetail extends StatefulWidget {
  CardDetail({
    Key? key,
    this.listCardId,
    this.card
  }) : super(key: key);

  final listCardId;
  final card;

  @override
  _CardDetailState createState() => _CardDetailState();
}

class _CardDetailState extends State<CardDetail> {
  TextEditingController commentTextController = TextEditingController();
  String textComment = '';
  bool loading = false;
  bool _isFocusTitle = false;
  @override
  void initState() { 
    final token = Provider.of<Auth>(context, listen: false).token;
    CardItem card = widget.card;
    super.initState();

    Provider.of<Boards>(context, listen: false).getActivity(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id).then((res) {
      this.setState(() {
        card.activity = res["activity"];
        card.checklists = res["checklists"];
        card.attachments = res["attachments"];  
      });
    });
  }

  onEditTitle(value) {
    this.setState(() {
      widget.card.title = value;
    });
    updateCardTitleOrDescription();
  }

  onEditDescription(value) {
    this.setState(() {
      widget.card.description = value;
    });
    updateCardTitleOrDescription();
  }

  onSetPriority(value) {
    this.setState(() {
      widget.card.priority = value;
    });
    updateCardTitleOrDescription();
  }

  onSetDueDate(value) {
    this.setState(() {
      widget.card.dueDate = value;
    });
    updateCardTitleOrDescription();
  }

  updateCardTitleOrDescription() {
    final token = Provider.of<Auth>(context, listen: false).token;
    CardItem card = widget.card;
    var payload = {
      "id": card.id,
      "description": card.description,
      "title": card.title,
      "is_archived": card.isArchived,
      "due_date": card.dueDate != null ? card.dueDate!.toUtc().millisecondsSinceEpoch~/1000 + 86400 : null,
      "priority": card.priority
    };

    Provider.of<Boards>(context, listen: false).updateCardTitleOrDescription(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, payload);
    this.setState(() {});
  }

  onCreateNewCard() {
    final token = Provider.of<Auth>(context, listen: false).token;
    CardItem card = widget.card;
    final selectedBoard = Provider.of<Boards>(context, listen: false).selectedBoard;
    var payload = {
      "title": card.title,
      "description": card.description,
      "checklists": card.checklists,
      "members": card.members,
      "labels": card.labels,
      "priority": card.priority,
      "due_date": card.dueDate != null ? card.dueDate!.toUtc().millisecondsSinceEpoch~/1000 + 86400 : null,
      "attachments": card.attachments
    };

    Provider.of<Boards>(context, listen: false).createNewCard(token, selectedBoard["workspace_id"], selectedBoard["channel_id"], selectedBoard["id"], widget.listCardId, payload);
    Navigator.pop(context);
  }

  parseTime(comment) {
    final auth = Provider.of<Auth>(context, listen: false);
    DateTime dateTime = DateTime.parse(comment["inserted_at"]);
    final String messageTime = DateFormat('kk:mm').format(DateTime.parse(comment["inserted_at"]).add(Duration(hours: 7)));
    final String dayTime = DateFormatter().getVerboseDateTimeRepresentation(dateTime, auth.locale);

    return (comment["inserted_at"] != "" && comment["inserted_at"] != null)
      ? "${dayTime == S.current.today ? messageTime : DateFormatter().renderTime(DateTime.parse(comment["inserted_at"]), type: "MMMd") + " ${S.current.ats} $messageTime"}"
      : "";
  }
  List<String> list = <String>['Edit', "Delete"];

  showBottomSheetComment(context, text, handleSave, comment) {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext context) {
        var height = MediaQuery.of(context).size.height*0.9;
        return Container(
          height: height,
          child: CommentField(text: text, handleSave: handleSave, height: height, issue: comment, type: "kanban_comment")
        );
      });
  }

  handleSaveComment(value, comment) async {
    CardItem card = widget.card;
    if(value != "") {
      final token = Provider.of<Auth>(context, listen: false).token;
      await Provider.of<Boards>(context, listen: false).editCommentCard(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, value.trim(), comment["id"], [], []);
      Navigator.pop(context);
    }
  }

  onFocusTitleChange(bool isFocusTitle) {
    this.setState((){
      _isFocusTitle = isFocusTitle;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    CardItem card= widget.card;
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
      print("_isFocusTitle: $_isFocusTitle");
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 32, bottom: _isFocusTitle ? 0 : 32),
          height: deviceHeight,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Scaffold(
                  body: Container(
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 60),
                          EditTitle(title: card.title, onEditTitle: onEditTitle, onFocusTitleChange: onFocusTitleChange),
                          SizedBox(height: 12),
                          EditDescription(description: card.description, onEditDescription: onEditDescription),
                          SizedBox(height: 12),
                          EditChecklist(checklists: card.checklists, card: widget.card),
                          SizedBox(height: 12),
                          EditAttachment(attachments: card.attachments, card: widget.card),
                          SizedBox(height: 20),
                          Container(
                            margin: EdgeInsets.only(left: 16),
                            child: Text("Comments")
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 2),
                                      child: CachedAvatar(currentUser["avatar_url"], name: currentUser["full_name"], width: 30, height: 30)
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 150,
                                        margin: EdgeInsets.symmetric(horizontal: 8),
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)),
                                          borderRadius: BorderRadius.circular(4)
                                        ),
                                        child: TextFormField(
                                          minLines: 1,
                                          maxLines: 7,
                                          controller: commentTextController,
                                          style: TextStyle(fontSize: 14, height: 1.55, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                                          decoration: InputDecoration(
                                            hintText: "Write a comment",
                                            hintStyle: TextStyle(fontSize: 14),
                                            contentPadding: EdgeInsets.all(8),
                                            border: InputBorder.none
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              textComment = value;
                                            });
                                          },
                                        )
                                      )
                                    )
                                  ],
                                ),
                              ),
                              if(textComment.trim() != "") Container(
                                margin: EdgeInsets.only(right: 22, top: 8),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF),
                                  borderRadius: BorderRadius.all(Radius.circular(4))
                                ),
                                child: InkWell(
                                  onTap: loading ? null : () async {
                                    setState(() {
                                      loading = true;
                                    });
                                    FocusScope.of(context).unfocus();
                                    final token = Provider.of<Auth>(context, listen: false).token;
                                    await Provider.of<Boards>(context, listen: false).sendCommentCard(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, textComment.trim());
                                    await Provider.of<Boards>(context, listen: false).getActivity(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id).then((res) {
                                      this.setState(() {
                                        card.activity = res["activity"];
                                        textComment = "";
                                        commentTextController.clear();
                                        loading = false;
                                      });
                                      
                                    });
                                  },
                                  child: Container(
                                    child: Text( loading ? "Sending..." : "Submit", style: TextStyle(color: isDark ? Colors.black : Colors.white),),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 32),
                          Column(
                            children: card.activity.map((e) {
                              return Container(
                                margin: EdgeInsets.only(top: 16, left: 16, right: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 15),
                                      child: CachedAvatar(e["author"]["avatar_url"], name: e["author"]["full_name"], width: 30, height: 30)
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Wrap(
                                                  crossAxisAlignment: WrapCrossAlignment.end,
                                                  children: [
                                                    Text(Utils.getUserNickName(e["author"]["id"]) ?? e["author"]["full_name"],),
                                                    SizedBox(width: 10),
                                                    Text(parseTime(e), style: TextStyle(color: Color(0xffA6A6A6), fontSize: 12))
                                                  ],
                                                ),
                                                currentUser["id"] == e["author"]["id"] ? Container(
                                                  child: DropdownButton(
                                                    underline: Container(),
                                                    icon: Icon(PhosphorIcons.dotsThree),
                                                    items: list.map<DropdownMenuItem<String>>((e) {
                                                      return DropdownMenuItem<String>(
                                                        value: e,
                                                        child: Text(e, style: TextStyle(color: e == "Delete" ? Colors.red : null, fontSize: 14),)
                                                      );
                                                    }).toList(), 
                                                    onChanged: (value) { 
                                                      if(value == "Delete") { 
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return CustomDialogNew(
                                                              title: "Delete comment", 
                                                              content: "Do you want to delete this comment ?",
                                                              confirmText: "Delete",
                                                              onConfirmClick: () async {
                                                               final token = Provider.of<Auth>(context, listen: false).token;
                                                                int index = widget.card.activity.indexWhere((e) => e["id"] == e["id"]);
                                                                await Provider.of<Boards>(context, listen: false).deleteComment(token, widget.card.workspaceId, widget.card.channelId, widget.card.boardId, widget.card.listCardId, widget.card.id, e["id"]);
                                                                setState(() { widget.card.activity.removeAt(index); });
                                                                Navigator.pop(context);
                                                              },
                                                              quickCancelButton: true,
                                                            );
                                                          }
                                                        );
                                                      }
                                                      else if (value == "Edit") {
                                                        showBottomSheetComment(context, e["comment"], handleSaveComment, e);
                                                      }
                                                    }
                                                  ),
                                                ) : Container(width: 45, height: 45)
                                              ],
                                            ),
                                            // SizedBox(height: 4),
                                            Container(
                                              width: MediaQuery.of(context).size.width,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)),
                                                borderRadius: BorderRadius.circular(4)
                                              ),
                                              child: Markdown(
                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                shrinkWrap: true,
                                                styleSheet: MarkdownStyleSheet(
                                                  p: TextStyle(fontSize: 14, height: 1.55, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                                                  a: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, decoration: TextDecoration.underline, fontSize: 14, height: 1.55),
                                                  code: TextStyle(fontSize: 15, fontStyle: FontStyle.italic)
                                                ),
                                                physics: NeverScrollableScrollPhysics(),
                                                selectable: true,
                                                data: e["comment"],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 110),
                        ]
                      )
                    )
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff2E2E2E) : Color(0xffFFFFFF),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)
                      )
                    )
                  ),
                  width: deviceWidth,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(PhosphorIcons.caretLeft)
                      ),
                      SizedBox(width: 10),
                      Expanded(child: Text(card.title, style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: InkWell(child: Text(S.current.done, style: TextStyle(fontSize: 14, color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF))))
                      )
                    ]
                  )
                )
              )
            ]
          )
        ),
        AttributePanel(assignees: card.members, labels: card.labels, priority: card.priority, onSetPriority: onSetPriority, dueDate: card.dueDate, onSetDueDate: onSetDueDate, card: widget.card)
      ]
    );
  }
}
