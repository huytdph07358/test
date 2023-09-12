import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/desktop/workview_desktop/label.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';

class IssueTimeline extends StatefulWidget {
  IssueTimeline({
    Key? key,
    this.timelines,
    required this.channelId,
    this.onTap
  }) : super(key: key);

  final timelines;
  final channelId;
  final Function? onTap;

  @override
  _IssueTimelineState createState() => _IssueTimelineState();
}

class _IssueTimelineState extends State<IssueTimeline> {
  findLabel(id) {
    final currentChannel = getDataChannel();
    final labels = currentChannel["labels"] != null ? currentChannel["labels"] : [];
    final index = labels.indexWhere((e) => e["id"] == id);

    if (index != -1) {
      return labels[index]; 
    } else {
      return null;
    }
  }

  findUser(id) {
    final workspaceMember = Provider.of<Workspaces>(context, listen: true).members;
    final index = workspaceMember.indexWhere((e) => e["id"] == id);

    if (index != -1) {
      return workspaceMember[index];
    } else {
      return null;
    }
  }

  findMilestone(id) {
    final currentChannel = getDataChannel();
    final milestones = currentChannel["labels"] != null ? currentChannel["milestones"] : [];
    final index = milestones.indexWhere((e) => e["id"] == id);

    if (index != -1) {
      return milestones[index];
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
        if (year >= 1) return ' ${year.toString().padLeft(1, "")} ${year > 1 ? S.current.years : S.current.year} ${S.current.ago}';
        else {
          if (month >= 1) return ' ${month.toString().padLeft(1, "")} ${month > 1 ? S.current.months : S.current.month} ${S.current.ago}';
          else return ' ${day.toString().padLeft(1, "")} ${day > 1 ? S.current.days : S.current.day} ${S.current.ago}';
        }
      } else if (hour > 0) {
        return '${hour.toString().padLeft(1, "")} ${hour > 1 ? S.current.hours : S.current.hour} ${S.current.ago}';
      } else if(minutes <= 1) {
        return "${S.current.momentAgo}";
      } else {
        return '${minutes.toString().padLeft(1, "0")} ${S.current.minutesAgo}';
      }
    } else {
      return "";
    }
  }

  Map getDataChannel(){
    try {
      List channels = Provider.of<Channels>(context, listen: false).data;
      int index  = channels.indexWhere((element) => "${element["id"]}" == "${widget.channelId}");
      return {
        "channel_id": channels[index]["id"],
        ...channels[index]
      };
    } catch (e) {
      print("getDataChannel: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final channelMember = Provider.of<Channels>(context, listen: true).getChannelMember(widget.channelId);
    final timelines = widget.timelines;

    return Container(
      margin: EdgeInsets.only(left: 6),
      child: Column(
        children: timelines.map<Widget>((e) {
          final timeline = e;

          if (timeline["data"] == null) {
            return Container();
          } else {
            List? added = timeline["data"]["added"];
            List? removed = timeline["data"]["removed"];
            final type = timeline["data"]["type"];
            final indexMember = channelMember.indexWhere((e) => e["id"] == timeline["user_id"]);
            final author = indexMember != -1 ? channelMember[indexMember] : null;

            if(type == 'create_message') {
              return TimelineTile(
                indicatorStyle: IndicatorStyle(
                  width: 25,
                  color: isDark ? Color(0xff2E2E2E) : Color(0xffEDEDED),
                  iconStyle: IconStyle(
                    iconData: Icons.person_outline,
                    fontSize: 18,
                    color: isDark ? Colors.white : Color(0xff2A5298)
                  )
                ),
                beforeLineStyle: LineStyle(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9), thickness: 1),
                afterLineStyle: LineStyle(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9), thickness: 1),
                endChild: Container(
                  margin: EdgeInsets.only(left: 12),
                  padding: EdgeInsets.symmetric(vertical: 8),
                  width: MediaQuery.of(context).size.width,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: CachedImage(author["avatar_url"] ?? "", height: 28, width: 28, radius: 50, name: author["full_name"] ?? "P"),
                        ),
                        TextSpan(
                          text: ' ${author["full_name"]}  ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65),
                          )
                        ),
                        TextSpan(
                          text: '${S.current.createdByMessage}: ${timeline['data']['description']}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            decoration: TextDecoration.underline,
                            height: 1.25,
                            fontWeight: FontWeight.w300
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () => widget.onTap != null ? widget.onTap!() : null,
                        ),
                      ]
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  )
                )
              );
            }

            return TimelineTile(
              indicatorStyle: IndicatorStyle(
                width: 25,
                color: isDark ? Color(0xff2E2E2E) : Color(0xffEDEDED),
                iconStyle: IconStyle(
                  iconData: type == "labels" ? Icons.local_offer_outlined : type == "assignees" ? Icons.person_outline : type == "milestone" ? Icons.flag_outlined : type == "close_issue" ? Icons.do_disturb_alt_outlined : Icons.radio_button_checked_outlined,
                  fontSize: type == "labels" || type =="close_issue" ? 18 : 19,
                  color: isDark ? Color(0xffC9C9C9) : Colors.black.withOpacity(0.9)
                )
              ),
              beforeLineStyle: LineStyle(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9), thickness: 1),
              afterLineStyle: LineStyle(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9), thickness: 1),
              endChild: Container(
                margin: EdgeInsets.only(left: 12),
                padding: EdgeInsets.symmetric(vertical: 8),
                width: MediaQuery.of(context).size.width,
                child: Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    type == "close_issue" ? Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AuthorTimeline(author: author, isDark: isDark, showAction: false),
                        Text("${S.current.closedThis} ", style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))),
                      ],
                    ) : Text(""),
                    type == "open_issue" ? Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AuthorTimeline(author: author, isDark: isDark, showAction: false),
                        Text("${S.current.reopenedThis} ", style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))),
                      ],
                    ) : Text(""),
                    type == "close_issue" || type == "open_issue" ? Text(parseDatetime(timeline["inserted_at"]), style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))) : Text(""),
                    Text.rich(
                      TextSpan(
                        children: [
                          added != null && added.length > 0 ? TextSpan(
                            children: added.map<InlineSpan>((e){
                              final index = added.indexWhere((ele) => ele == e);
                              var label = type == "labels" ? findLabel(e) : null;
                              var user = type == "assignees" ? findUser(e) : null;
                              var milestone = type == "milestone" ? findMilestone(e) : null;

                              if (label != null || user != null || milestone != null) {
                                return type == "labels" ? TextSpan(
                                  children: [
                                    TextSpan(
                                      children: [
                                        if (index == 0)WidgetSpan(
                                          child:AuthorTimeline(author: author, isDark: isDark, type: "added", showAvatar: true),
                                        )
                                      ]
                                    ),
                                    TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 1, left: 2),
                                            child: LabelDesktop(fromPanchat: true, labelName: label["name"], color: int.parse("0XFF${label["color_hex"]}")),
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
                                        child: AuthorTimeline(author: author, isDark: isDark, type: "added"),
                                      )
                                    ]
                                  ),
                                  WidgetSpan(
                                    child: CachedImage(user != null ? user["avatar_url"] : "", height: 22, width: 22, radius: 50, name: user != null ? user["full_name"] : "P"),
                                  ),
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 3,right: 2),
                                      child: Text(" ${user["nickname"] ?? user["full_name"]}", style: TextStyle( fontWeight: FontWeight.w700, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))),
                                    ),
                                  ),
                                  ]
                                ) : milestone != null ? 
                                TextSpan(
                                  children: [
                                  TextSpan(
                                    children: [
                                      if (index == 0)WidgetSpan(
                                        child:AuthorTimeline(author: author, isDark: isDark, type: "added"),
                                      )
                                    ]
                                  ), 
                                  milestone["due_date"] != null ? WidgetSpan( 
                                    child: Padding( 
                                      padding: const EdgeInsets.only( bottom: 3), 
                                      child: Text ( 
                                        (DateFormatter().renderTime(DateTime.parse(milestone["due_date"]), type: "MMMd")), 
                                        style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: FontWeight.w700) 
                                      ), 
                                    ), 
                                  ) : TextSpan(), 
                                  WidgetSpan( 
                                    child:Padding( 
                                      padding: const EdgeInsets.only(bottom:  3), 
                                      child: Text( ' milestone ', style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))), 
                                      ) 
                                    )
                                  ]
                                ) : TextSpan();
                                
                              } else {
                                return TextSpan();
                              }
                            }).toList()
                          ): TextSpan(),
                          removed != null && removed.length == 0 ? WidgetSpan(
                            child:Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Text(parseDatetime(timeline["inserted_at"]), style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))),
                            ) 
                          ) : TextSpan()
                        ]
                      ),
                    ),

                   removed != null && removed.length > 0 ? Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: added != null && added.length > 0 ? 4 :0),
                              child: Text(added != null && added.length > 0 ? " ${S.current.and} " : "", style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))),
                            ),
                          ),
                          TextSpan( 
                          children: removed.map <InlineSpan>((e) {
                              var label = findLabel(e);
                              var user = findUser(e);
                              var milestone = type == "milestone" ? findMilestone(e) : null;
                              final index = removed.indexWhere((ele) => ele == e);

                            if (label != null || user != null || milestone != null) {
                              return type == "labels" && label != null ? TextSpan( 
                                children: [ 
                                  TextSpan( 
                                    children: [ 
                                      if (index == 0)WidgetSpan( 
                                        child: Padding(
                                          padding: EdgeInsets.only( bottom: added != null && added.length > 0 ? 5 :0), 
                                          child: AuthorTimeline(author: author, isDark: isDark, type: "removed", showAuthor: !(added!.length > 0)),
                                        ),
                                      ) 
                                    ] 
                                  ), 
                                  TextSpan( 
                                    children: [ 
                                      WidgetSpan( 
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: added != null && added.length > 0 ? 2 : 0, left: 2),
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
                                      child:Padding(
                                        padding: EdgeInsets.only( bottom: added != null && added.length > 0 ? 4 : 0,right: 2), 
                                        child: AuthorTimeline(author: author, isDark: isDark, type: "removed", showAuthor: !(added!.length > 0)),
                                      ),
                                    ) 
                                  ] 
                                ), 
                                WidgetSpan(
                                    child: CachedImage(user != null ? user["avatar_url"] : "", height: 22, width: 22, radius: 50, name: user != null ? user["full_name"] : "P"),
                                  ),
                                  WidgetSpan(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: added!.length > 0 ? 4 : 4),
                                      child: Text(" ${user["nickname"] ?? user["full_name"]} ", style: TextStyle( fontWeight: FontWeight.w700, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))),
                                    ),
                                  ),
                                ] 
                              ) : milestone != null ?  
                                TextSpan( 
                                  children: [ 
                                  TextSpan( 
                                    children: [ 
                                      if (index == 0)WidgetSpan( 
                                        child:Padding(
                                          padding: EdgeInsets.only( bottom: added != null && added.length > 0 ? 4 :0), 
                                          child: AuthorTimeline(author: author, isDark: isDark, type: "removed", showAuthor: !(added!.length > 0)),
                                        ),
                                      ) 
                                    ] 
                                  ), 
                                  milestone["due_date"] != null ? WidgetSpan( 
                                    child: Padding( 
                                      padding: EdgeInsets.only( bottom: added != null && added.length > 0 ? 4 : 0), 
                                      child: Text ( 
                                        (DateFormatter().renderTime(DateTime.parse(milestone["due_date"]), type: "MMMd")), 
                                        style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 14, fontWeight: FontWeight.w700) 
                                      ), 
                                    ), 
                                  ) : TextSpan(), 
                                  WidgetSpan( 
                                    child:Padding( 
                                      padding: EdgeInsets.only(bottom: added != null && added.length > 0 ? 4 : 0), 
                                      child: Text( ' milestone ', style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))), 
                                      ) 
                                    )
                                  ] 
                                ) : TextSpan(); 
                              } else { 
                                return TextSpan(); 
                              } 
                            }
                          ).toList() 
                        ),
                         WidgetSpan(
                          child:Padding(
                            padding: EdgeInsets.only(bottom: added!.length > 0 ? 4 :3),
                            child: Text(parseDatetime(timeline["inserted_at"]), style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))),
                          ) 
                        ) 
                      ]
                    )
                  ) : Text.rich(TextSpan()),
                  ]
                )
              )
            );
          }
        }).toList()
      )
    );
  }
}

class AuthorTimeline extends StatelessWidget {
  const AuthorTimeline({
    Key? key,
    required this.author,
    required this.isDark,
    this.type = "added",
    this.showAuthor = true,
    this.showAction = true,
    this.showAvatar = true
  }) : super(key: key);

  final author;
  final isDark;
  final type;
  final showAuthor;
  final showAction;
  final showAvatar;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (showAuthor && showAvatar) CachedImage(author != null ? author["avatar_url"] : "", height: 22, width: 22, radius: 50, name: author != null ? author["full_name"] : "P"),
        if (showAuthor && showAvatar) SizedBox(width: 8),
        if (showAuthor) Text(
          "${author != null ? author["full_name"] : "Unknown"} ", 
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))
        ),
        if (showAction) Text(type == "added" ? "${S.current.added.toLowerCase()} " : "${S.current.removed.toLowerCase()} ")
      ],
    );
  }
}