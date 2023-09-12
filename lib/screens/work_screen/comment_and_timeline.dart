import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/desktop/components/issue_timeline.dart';
import 'package:workcake/desktop/workview_desktop/render_markdown.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';
import 'comment_field.dart';

class CommentAndTimeline extends StatefulWidget {
  CommentAndTimeline({
    Key? key,
    this.commentsAndTimelines,
    this.issue
  }) : super(key: key);

  final commentsAndTimelines;
  final issue;

  @override
  _CommentAndTimelineState createState() => _CommentAndTimelineState();
}

class _CommentAndTimelineState extends State<CommentAndTimeline> {
  var selectedComment;

  getMember(userId) {
    final members = Provider.of<Workspaces>(context, listen: false).listWorkspaceMembers;
    final indexUser = members.indexWhere((e) => e["id"] == userId);

    if (indexUser != -1) {
      return members[indexUser];
    } else {
      return {};
    }
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
        if (year >= 1) return '${year.toString().padLeft(1, "")} ${year > 1 ? S.current.years : S.current.year} ${S.current.ago}';
        else {
          if (month >= 1) return '${month.toString().padLeft(1, "")} ${month > 1 ? S.current.months : S.current.month} ${S.current.ago}';
          else return '${day.toString().padLeft(1, "")} ${day > 1 ? S.current.days : S.current.day} ${S.current.ago}';
        }
      } else if (hour > 0) {
        return '${hour.toString().padLeft(1, "")} ${hour > 1 ? S.current.hours : S.current.hour} ${S.current.ago}';
      } else if(minutes <= 1) {
        return S.current.momentAgo;
      } else {
        return '${minutes.toString().padLeft(1, "0")} ${S.current.minutesAgo}';
      }
    } else {
      return "Offline";
    }
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
          child: CommentField(issue: widget.issue, text: text, handleSave: handleSave, height: height)
        );
      }
    );
  }
  
  handleSave(value) async {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentChannel = getDataChannel();

    var dataComment = {
      "comment": value,
      "channel_id":  currentChannel["id"],
      "workspace_id": currentChannel["workspace_id"],
      "user_id": auth.userId,
      "type": "issue_comment",
      "from_issue_id": widget.issue["id"],
      "from_id_issue_comment": selectedComment["id"],
      "list_mentions_old": selectedComment["mentions"] ?? [],
      "list_mentions_new": []
    };

    Provider.of<Channels>(context, listen: false).updateComment(auth.token, dataComment);
    Navigator.of(context).pop();
  }

  Map getDataChannel(){
    try {
      List channels = Provider.of<Channels>(context, listen: false).data;
      int index  = channels.indexWhere((element) => "${element["id"]}" == "${widget.issue["channel_id"]}");
      return {
        "channel_id": channels[index]["id"],
        ...channels[index]
      };
    } catch (e) {
      print("getDataChannel: $e");
      return {};
    }
  }

  showDialogDelete(context, comment) {
    showDialog(
      context: context,
      builder: (context) {
        final token = Provider.of<Auth>(context).token;
        final currentChannel = getDataChannel();
      
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            width: 200,
            height: 98,
            child: Column(
              children: [
                SizedBox(height: 8),
                Text(S.current.deleteComment),
                SizedBox(height: 6),
                Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 36,
                      width: 120,
                      child: TextButton(
                        onPressed: () {  
                          Navigator.of(context, rootNavigator: true).pop("Discard");
                        },
                        child: Text(S.current.cancel),
                      ),
                    ),
                    Container(
                      height: 36,
                      width: 120,
                      child: TextButton(
                        onPressed: () {  
                          Provider.of<Channels>(context, listen: false).deleteComment(token, currentChannel["workspace_id"], currentChannel["id"], comment["id"], widget.issue["id"]);
                          Navigator.of(context, rootNavigator: true).pop("Discard");
                        },
                        child: Text(S.current.delete, style: TextStyle(color: Colors.redAccent)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  onChangeCheckBox(value, elText, commentId, indexCheckbox) {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentChannel = getDataChannel();
    int indexComment = widget.issue["comments"].indexWhere((e) => e["id"] == commentId);
    
    if (indexComment != -1) {
      var issueComment = widget.issue["comments"][indexComment];
      String comment = widget.issue["comments"][indexComment]["comment"];
      String newText = Utils.onChangeCheckbox(comment, value, elText, indexCheckbox);
      widget.issue["comments"][indexComment]["comment"] = newText;
      var result = Provider.of<Messages>(context, listen: false).checkMentions(newText);
      var listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];
      var dataComment = {
        "comment": newText,
        "channel_id":  currentChannel["id"],
        "workspace_id": currentChannel["workspace_id"],
        "user_id": auth.userId,
        "type": "issue_comment",
        "from_issue_id": widget.issue["id"],
        "from_id_issue_comment": commentId,
        "list_mentions_old": issueComment["mentions"] ?? [],
        "list_mentions_new": listMentionsNew
      };

      Provider.of<Channels>(context, listen: false).updateComment(auth.token, dataComment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAndTimelines = widget.commentsAndTimelines;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Column(
      children: commentsAndTimelines.map<Widget>((e) {
        if (e == null) return Container();
        if (e["comment"] != null) {
          var comment = e;
          var author = getMember(comment["author_id"]);
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              boxShadow: isDark ? [
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 40,
                  color: Colors.black.withOpacity(0.1)
                )
              ] : [
                BoxShadow(
                  blurRadius: 1,
                  color: Colors.black.withOpacity(0.04)
                ),
                BoxShadow(
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.06)
                ),
                BoxShadow(
                  offset: Offset(0, 4),
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.04)
                ),
              ],
              color: isDark ? Color(0xFF3D3D3D) : Colors.white,
              border: isDark ? null : Border(
                bottom: BorderSide(color: Color(0xffC9C9C9), width: 0.65),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 12.0, left: 16.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff4C4C4C) : Color(0xffF8F8F8),
                    border: isDark ? null : Border(
                      bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                      top: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 16),
                            child: CachedImage(
                              author["avatar_url"],
                              width: 40,
                              height: 40,
                              radius: 20,
                              name: author["full_name"],
                            ),
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${ Utils.getUserNickName(author["user_id"]) ?? author["full_name"]}", style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Color(0xff2E2E2E), fontWeight: FontWeight.w700)),
                                SizedBox(height: 2,),
                                Text(comment["last_edited_id"] != null ? "• ${S.current.edited} ${parseDatetime(comment["updated_at"])}" : "${S.current.Commented} ${parseDatetime(comment["updated_at"])}",  style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Colors.black.withOpacity(0.65), fontSize: 12))
                              ]
                            ),
                          )
                        ],
                      ),
                      comment["author_id"] == auth.userId ? Row(
                        children: [
                          GestureDetector(
                            child: Container(
                              padding: EdgeInsets.only(right: 8, top: 12, bottom: 12, left: 16),
                              child: Icon(PhosphorIcons.pencilLine, size: 20, color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E))
                            ),
                            onTap: () {
                              showBottomSheetComment(context, comment["comment"], handleSave);
                              this.setState(() {
                                selectedComment = comment;
                              });
                            }
                          ),
                          // SizedBox(width: 16),
                          GestureDetector(
                            child: Container(
                              padding: EdgeInsets.only(right: 16, top: 12, bottom: 12, left: 8),
                              child: Icon(PhosphorIcons.trash, size: 20, color: isDark ? Color(0xffC9C9C9): Color(0xff5E5E5E))
                            ),
                            onTap: () {
                              showDialogDelete(context, comment);
                            }
                          ),
                        ],
                      ) : Container(),
                    ],
                  )
                ),
                Container(
                  color: isDark ? Color(0xff1E1E1E) : Color(0xFFEDEDED),
                  child: RenderMarkdown(
                    stringData: Utils.parseComment(comment["comment"], false),
                    onChangeCheckBox: onChangeCheckBox
                  )
                )
              ]
            )
          );
        } else {
          var times = [e];
          return Padding(
            padding: const EdgeInsets.only(left: 14.0, right: 12.0),
            child: IssueTimeline(timelines: times, channelId: widget.issue["channel_id"])
          );
        }      
      }).toList()
    );
  }
}