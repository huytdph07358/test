import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/components/image_detail.dart';
import 'package:workcake/models/models.dart';

import 'CardItem.dart';

class ListActivity extends StatefulWidget {
  ListActivity({
    Key? key,
    required this.card
  }) : super(key: key);

  final CardItem card;

  @override
  _ListActivityState createState() => _ListActivityState();
}



class _ListActivityState extends State<ListActivity> {
  TextEditingController controller = TextEditingController();

  parseTime(comment) {
    final auth = Provider.of<Auth>(context, listen: false);
    DateTime dateTime = DateTime.parse(comment["inserted_at"]);
    final messageTime = DateFormat('kk:mm').format(DateTime.parse(comment["inserted_at"]).add(Duration(hours: 7)));
    final dayTime = DateFormatter().getVerboseDateTimeRepresentation(dateTime, auth.locale);

    return (comment["inserted_at"] != "" && comment["inserted_at"] != null)
      ? "${dayTime == "Today" ? messageTime : DateFormatter().renderTime(DateTime.parse(comment["inserted_at"]), type: "MMMd") + " at $messageTime"}"
      : "";
  }

  onDeleteComment(comment) {
    CardItem card = widget.card;
    final token = Provider.of<Auth>(context, listen: false).token;
    int index = card.activity.indexWhere((e) => e["id"] == comment["id"]);

    if (index == -1) return;

    Provider.of<Boards>(context, listen: false).deleteComment(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, comment["id"]);
    card.activity.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    CardItem card = widget.card;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      color: isDark ? Colors.black54 : Color(0xfff4f5f7),
      margin: EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 2, left: 3),
                width: 16, 
                child: Icon(Icons.comment, color: isDark ? Colors.white70 : Colors.grey[700], size: 22)
              ),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${card.activity.length} ${card.activity.length > 1 ? 'comments' : 'comment'}", style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontSize: 15, fontWeight: FontWeight.w600)),
                ]
              )
            ]
          ),
          SizedBox(height: 16),
          Column(
            children: card.activity.map((e) {
              final comment = e;
              final author = comment["author"];

              return  Container(
                margin: EdgeInsets.only(bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedAvatar(author["avatar_url"], name: author["full_name"], width: 30, height: 30),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.end,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 2),
                                  child: Text(Utils.getUserNickName(author["id"]) ?? author["full_name"], style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 14))
                                ),
                                SizedBox(width: 6),
                                Text("${parseTime(comment)}", style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700], fontSize: 12))
                              ],
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[900] : Color.fromARGB(255, 235, 236, 240),
                                borderRadius: BorderRadius.circular(14)
                              ),
                              child: Markdown(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                physics: NeverScrollableScrollPhysics(),
                                imageBuilder: (uri, title, alt) {
                                  var tag  = Utils.getRandomString(30);
              
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          barrierDismissible: true,
                                          barrierLabel: '',
                                          opaque: false,
                                          barrierColor: Colors.black.withOpacity(1.0),
                                          pageBuilder: (context, _, __) => ImageDetail(url: "$uri", id: tag, full: true, tag: tag)
                                        )
                                      );
                                    },
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: 400,
                                        maxWidth: 750
                                      ),
                                      child: CachedImage(uri.toString())
                                    )
                                  );
                                },
                                shrinkWrap: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(fontSize: 15.5, height: 1, color: isDark ? Colors.white70 : Colors.grey[700]),
                                  a: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                  code: TextStyle(fontSize: 15, fontStyle: FontStyle.italic)
                                ),
                                checkboxBuilder: (value) {
                                  return Text("- [ ]", style: TextStyle(fontSize: 15.5, height: 1));
                                },
                                onTapLink: (link, url, uri) {
                                  Utils.openUrl(url);
                                },
                                selectable: true,
                                data: comment["comment"]
                              )
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                SizedBox(width: 2),
                                InkWell(
                                  onTap: () {},
                                  child: Text("Edit", style: TextStyle(color: Colors.grey[600], decoration: TextDecoration.underline))
                                ),
                                SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialogNew(
                                          title: "Delete comment",
                                          content: "Are you sure you want to delete this comment?",
                                          confirmText: "Delete",
                                          quickCancelButton: true,
                                          onConfirmClick: () async {
                                            final token = Provider.of<Auth>(context, listen: false).token;
                                            int index = card.activity.indexWhere((e) => e["id"] == comment["id"]);

                                            if (index == -1) return;

                                            Provider.of<Boards>(context, listen: false).deleteComment(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, comment["id"]);
                                            setState(() { card.activity.removeAt(index); });
                                          },
                                        );
                                      }
                                    );
                                  },
                                  child: Text("Delete", style: TextStyle(color: Colors.grey[600], decoration: TextDecoration.underline))
                                )
                              ]                              
                            )
                          ]
                        )
                      )
                    )
                  ]
                )
              );
            }).toList()
          )
        ]
      )
    );
  }
}