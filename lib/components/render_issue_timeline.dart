import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/screens/work_screen/issue_info.dart';

import '../desktop/components/issue_timeline.dart';
import '../desktop/workview_desktop/label.dart';
import '../models/models.dart';

class RenderIssueTimeline extends StatefulWidget {
  RenderIssueTimeline({
    Key? key,
    this.att
  }) : super(key: key);

  final att;

  @override
  State<RenderIssueTimeline> createState() => _RenderIssueTimelineState();
}

class _RenderIssueTimelineState extends State<RenderIssueTimeline> {

  findLabel(labelId) {
    final index = (widget.att["data"]["attributes"] ?? []).indexWhere((e) => e["id"].toString() == labelId.toString());

    if (index == -1) {
      return null;
    } else {
      return widget.att["data"]["attributes"][index];
    }
  }

  findUser(id) {
    final dataUserMentions = Provider.of<User>(context, listen: false).userMentionInDirect;
    final indexMember = dataUserMentions.indexWhere((e) => e["user_id"].toString() == id.toString());

    if (indexMember != -1) {
      return dataUserMentions[indexMember];
    } else {
      return null;
    }
  }

  findMilestone(id) {
    final index = (widget.att["data"]["attributes"] ?? []).indexWhere((e) => e["id"] == id);

    if (index != -1) {
      return widget.att["data"]["attributes"][index];
    } else {
      return null;
    }
  }

  parseDatetime(time) {
    if (time != "") {
      DateTime offlineTime = DateTime.parse(time).add(Duration(hours: 7));
      DateTime now = DateTime.now();
      final difference = now.difference(offlineTime).inMinutes;

      final hour = difference ~/ 60;
      final minutes = difference % 60;
      final day = hour ~/24;

      if (day > 0) {
        int month = day ~/30;
        int year = month ~/12;
        if (year >= 1) return ' ${year.toString().padLeft(1, "")} ${year > 1 ? "years" : "year"} ago';
        else {
          if (month >= 1) return ' ${month.toString().padLeft(1, "")} ${month > 1 ? "months" : "month"} ago';
          else return ' ${day.toString().padLeft(1, "")} ${day > 1 ? "days" : "day"} ago';
        }
      } else if (hour > 0) {
        return ' ${hour.toString().padLeft(1, "")} ${hour > 1 ? "hours" : "hour"} ago';
      } else if(minutes <= 1) {
        return ' moment ago';
      } else {
        return ' ${minutes.toString().padLeft(1, "0")} minutes ago';
      }
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataUserMentions = Provider.of<User>(context, listen: true).userMentionInDirect;
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final token = auth.token;
    var att = widget.att;
    var authorId = att["data"]["user_id_change"];
    var type = att["type"];
    final indexMember = dataUserMentions.indexWhere((e) => e["user_id"] == authorId);
    final author = indexMember != -1 ? dataUserMentions[indexMember] : null;
    var timeline = Container();

    try {
      if (type == "change_issue") {
        var changes = att["data"]["changes"]["data"] ?? att["data"]["changes"]["issue"];
        var type = changes["type"];
        var added = changes["added"];
        var removed = changes["removed"];
        var channelId = att["data"]["channel_id"];
        var workspaceId = att["data"]["workspace_id"];
        var issueId = att["data"]["issue_id"];
        timeline = renderTimeline(added, type, author, isDark, removed, context, token, workspaceId, channelId, issueId);
      } else if (type == "delete_issue") {
        timeline = renderDeletedIssue(author, isDark, att["data"]["data"]);
      }
    
    } catch (e, t) {
      timeline = Container(child: Text("renderTimeline error: $e, $t"));
    }

    return timeline;
  }

  renderDeletedIssue(author, isDark, issue) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AuthorTimeline(author: author, isDark: isDark, type: "delete", showAvatar: false),
              Text("an issue you had followed: "),
              Text("${issue['title']} #${issue['unique_id']} ", style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue))
            ]
          )
        ]
      )
    );
  }

  renderTimeline(added, type, author, bool isDark, removed, BuildContext context, String token, workspaceId, channelId, issueId) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  children: [
                    added.length > 0 ? TextSpan(
                      children: added.map<InlineSpan>((e) {
                        final index = (added ?? []).indexWhere((ele) => ele == e);
                        var label = type == "labels" ? findLabel(e) : null;
                        var user = type == "assignees" ? findUser(e) : null;
                        var milestone = type == "milestone" ? findMilestone(e) : null;

                        if (label != null || user != null || milestone != null) {
                          return type == "labels" && label != null ? TextSpan(
                            children: [
                              TextSpan(
                                children: [
                                  if (index == 0)WidgetSpan(
                                    child:AuthorTimeline(author: author, isDark: isDark, type: "added", showAvatar: false),
                                  )
                                ]
                              ),
                              TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: LabelDesktop(fromPanchat: true, labelName: label["name"], color: int.parse("0XFF${label["color_hex"]}")),
                                  )
                                ]
                              ),
                            ]
                          ) : type == "assignees" ? TextSpan(
                            children: [
                            TextSpan(
                              children: [
                                if (index == 0)WidgetSpan(
                                  child:AuthorTimeline(author: author, isDark: isDark, type: "added", showAvatar: false),
                                )
                              ]
                            ),
                            TextSpan(
                              text: "${user["nickname"] ?? user["full_name"]}", style: TextStyle( fontWeight: FontWeight.w700, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))
                              ),
                            ]
                          ) : milestone != null ? 
                            TextSpan(
                              children: [
                              TextSpan(
                                children: [
                                  if (index == 0)WidgetSpan(
                                    child:AuthorTimeline(author: author, isDark: isDark, type: "added", showAvatar: false),
                                  )
                                ]
                              ),
                              TextSpan(
                                text: milestone["due_date"] != null ? (DateFormatter().renderTime(DateTime.parse(milestone["due_date"]), type: "MMMd")) : "",
                                style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: FontWeight.w700)
                              ),
                              TextSpan(
                                text: ' milestone ', style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))
                              )
                              ]
                            ) : TextSpan();
                          } else {
                            return TextSpan();
                          }
                      }).toList()
                    ) : TextSpan()
                  ]
                ),
                TextSpan( 
                  children: removed.map<InlineSpan>((e) { 
                    var label = findLabel(e); 
                    var user = findUser(e); 
                    var milestone = type == "milestone" ? findMilestone(e) : null; 
                    final index = (removed ?? []).indexWhere((ele) => ele == e); 
                    if (label != null || user != null || milestone != null) {
                      return type == "labels" && label != null ? TextSpan( 
                        children: [ 
                          TextSpan( 
                            children: [ 
                              if (index == 0)WidgetSpan( 
                                child:AuthorTimeline(author: author, isDark: isDark, type: "removed", showAuthor: !(added.length > 0), showAvatar: false), 
                              ) 
                            ] 
                          ), 
                          TextSpan( 
                            children: [ 
                              WidgetSpan( 
                                child:  Padding( 
                                  padding: const EdgeInsets.only(top: 8), 
                                  child: LabelDesktop(labelName: label["name"], color: int.parse("0XFF${label["color_hex"]}")), 
                                ), 
                              ) 
                            ] 
                          ), 
                        ] 
                      ) : type == "assignees" ? TextSpan( 
                        children: [ 
                        TextSpan( 
                          children: [ 
                            if (index == 0)WidgetSpan( 
                              child:AuthorTimeline(author: author, isDark: isDark, type: "removed", showAuthor: !(added.length > 0), showAvatar: false), 
                            ) 
                          ] 
                        ), 
                        TextSpan( 
                          text: "${user["nickname"] ?? user["full_name"]}", style: TextStyle( fontWeight: FontWeight.w700, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65)) 
                          ), 
                        ] 
                      ) : milestone != null ?  
                        TextSpan( 
                          children: [ 
                          TextSpan( 
                            children: [ 
                              if (index == 0)WidgetSpan( 
                                child:AuthorTimeline(author: author, isDark: isDark, type: "removed", showAuthor: !(added.length > 0), showAvatar: false), 
                              ) 
                            ] 
                          ), 
                          TextSpan( 
                            text: milestone["due_date"] != null ? (DateFormatter().renderTime(DateTime.parse(milestone["due_date"]), type: "MMMd")) : "", 
                            style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: FontWeight.w700) 
                          ), 
                          TextSpan( 
                            text: ' milestone', style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65)) 
                          ) 
                          ] 
                        ) : TextSpan(); 
                      } else { 
                        return TextSpan(); 
                      } 
                    }
                  ).toList() 
                ),
                TextSpan (
                  text : " ${S.current.inAnIssueYouHadFollowed}",
                  style: TextStyle(fontSize: 14, height: 1.57),
                )
              ]),
            textAlign: TextAlign.left,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: TextButton(
              onPressed: () async {
                Provider.of<Workspaces>(context, listen: false).selectWorkspace(token, workspaceId, context);
                Provider.of<Workspaces>(context, listen: false).getInfoWorkspace(token, workspaceId, context);
                Provider.of<Channels>(context, listen: false).setCurrentChannel(channelId);
                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
                  return IssueInfo(
                    issue: {
                      "id": issueId,
                      "channel_id": channelId,
                      "workspace_id": workspaceId,
                      "comments_count": 0,
                      "is_closed": false,
                      "title": "",
                      "comments": [],
                      "timelines": [],
                      "assignees": []
                    },
                    isJump: true
                  );
                }));
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xff1890FF)),
                fixedSize: MaterialStateProperty.all(Size.fromWidth(120))
              ),
              child: Text("${S.current.reviewIssue}", style: TextStyle(color: Colors.black87))
            ),
          )
        ],
      )
    );
  }
}