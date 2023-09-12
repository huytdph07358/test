import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';
import '../../generated/l10n.dart';
import 'component/attribute_panel.dart';
import 'component/edit_attachment.dart';
import 'component/edit_checklist.dart';
import 'component/edit_description.dart';
import 'component/edit_title.dart';

class CreateCard extends StatefulWidget {
  CreateCard({
    Key? key,
    this.listCardId
  }) : super(key: key);

  final listCardId;

  @override
  _CreateCardState createState() => _CreateCardState();
}

class _CreateCardState extends State<CreateCard> {
  String title = "";
  String description = "";
  List attachments = [];
  List checklists = [];
  List assignees = [];
  List labels = [];
  int? priority;
  DateTime? dueDate;

  onEditTitle(value) {
    this.setState(() {
      title = value;
    });
  }

  onEditDescription(value) {
    this.setState(() {
      description = value;
    });
  }

  onSetPriority(value) {
    this.setState(() {
      priority = value;
    });
  }

  onSetDueDate(value) {
    this.setState(() {
      dueDate = value;
    });
  }

  onCreateNewCard() {
    final token = Provider.of<Auth>(context, listen: false).token;
    final selectedBoard = Provider.of<Boards>(context, listen: false).selectedBoard;

    if (title.trim() == "") return;

    var card = {
      "title": title,
      "description": description,
      "checklists": checklists,
      "members": assignees,
      "labels": labels,
      "priority": priority,
      "due_date": dueDate != null ? dueDate!.toUtc().millisecondsSinceEpoch~/1000 + 86400 : null,
      "attachments": attachments
    };

    Provider.of<Boards>(context, listen: false).createNewCard(token, selectedBoard["workspace_id"], selectedBoard["channel_id"], selectedBoard["id"], widget.listCardId, card);
    Navigator.pop(context);
  }
 
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 32),
          height: deviceHeight,
          child: Stack(
            children: [
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 60),
                      EditTitle(title: title, onEditTitle: onEditTitle),
                      SizedBox(height: 12),
                      EditDescription(description: description, onEditDescription: onEditDescription),
                      SizedBox(height: 12),
                      EditChecklist(checklists: checklists),
                      SizedBox(height: 12),
                      EditAttachment(attachments: attachments),
                      SizedBox(height: 110)
                    ]
                  )
                )
              ),
              Positioned(
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff2E2E2E) : Color(0xffFFFFFF),
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xff5E5E5E)
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
                      Text(S.current.newCard, style: TextStyle(fontSize: 14)),
                      InkWell(
                        onTap: () {
                          onCreateNewCard();
                        },
                        child: InkWell(child: Text(S.current.create, style: TextStyle(fontSize: 14, color: Color(0xffFAAD14))))
                      )
                    ]
                  )
                )
              )
            ]
          )
        ),
        AttributePanel(assignees: assignees, labels: labels, priority: priority, onSetPriority: onSetPriority, dueDate: dueDate, onSetDueDate: onSetDueDate)
      ]
    );
  }
}