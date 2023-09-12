import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/desktop/components/issue_timeline.dart';
import 'package:workcake/desktop/workview_desktop/render_markdown.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/provider/thread_user.dart';
import 'package:workcake/screens/conversation.dart';
import 'package:workcake/screens/message.dart';
import 'package:workcake/screens/work_screen/comment_and_timeline.dart';
import '../../generated/l10n.dart';
import 'comment_bottom_sheet.dart';
import 'comment_field.dart';
class IssueInfo extends StatefulWidget {
  IssueInfo({
    Key? key,
    this.issue,
    this.updateIssue,
    this.isJump
    // 
  }) : super(key: key);

  final issue;
  final updateIssue;
  final isJump;

  @override
  _IssueInfoState createState() => _IssueInfoState();
}

class _IssueInfoState extends State<IssueInfo> {
  var issue = {};
  PanelController panelController = PanelController();

  @override
  void initState(){
    super.initState();
    issue = widget.issue;
    if (Utils.checkedTypeEmpty(widget.isJump)){
      getDataIssue();
      var channel = Provider.of<Auth>(context, listen: false).channel;
      channel.on("update_issue", (dataIssue, _j, _r){
        if (!mounted || dataIssue["id"] != issue["id"]) return;
        updateIssueData(dataIssue);
      });
    }

    if (issue["id"] != null) {
      var token = Provider.of<Auth>(context, listen: false).token;
      Provider.of<ThreadUserProvider>(context, listen: false).updateThreadUnread(issue["workspace_id"], issue["channel_id"], {'id': issue["id"], 'issue_id': issue["id"]}, token);
    }
  }
  
  updateIssueData(dataIssue) {
    var data = dataIssue["data"];
    final type = dataIssue["type"]; 
    final userId = Provider.of<Auth>(context, listen: false).userId;

    if (type == "update_timeline") {
      final index = issue["timelines"].indexWhere((e) => e["id"] == data["id"]);
      if (index == -1) issue["timelines"].add(data);
    } else if (type == "add_assignee") {
      final index = issue["assignees"].indexWhere((e) => e == data);

      if (index == -1) {
        issue["assignees"].add(data);
      }
    } else if (type == "add_label") {
      final index = issue["labels"].indexWhere((e) => e == data);

      if (index == -1) {
        issue["labels"].add(data);
      }
    } else if (type == "add_milestone") {
      issue["milestone_id"] = data;
    } else if (type == "remove_assignee") {
      final index = issue["assignees"].indexWhere((e) => e == data);

      if (index != -1) {
        issue["assignees"].removeAt(index);
      }
    } else if (type == "remove_label") {
      final index = issue["labels"].indexWhere((e) => e == data);

      if (index != -1) {
        issue["labels"].removeAt(index);
      }
    } else if (type == "remove_milestone") {
      issue["milestone_id"] = null;
    } else if (type == "add_comment") {
      final index = issue["comments"].indexWhere((e) => e["id"] == data);

      if (index == -1) {
        issue["comments"].add(data["comment"]);
        issue["users_unread"] = data["users_unread"];

        if (issue["comments_count"] != null) {
          issue["comments_count"] += 1; 
        }
      }
    } else if (type == "delete_comment") {
      final index = issue["comments"].indexWhere((e) => e["id"] == data);

      if (index != -1) {
        issue["comments"].removeAt(index);
      }
    } else if (type == "close_issue") {
      issue["is_closed"] = data;
    } else if (type == "update_issue_title") {
      issue["title"] = data["title"];
      issue["last_edit_description"] = data["last_edit_description"];
      issue["last_edit_id"] = data["last_edit_id"];

      if (userId != data["last_edit_id"]) {
        issue["description"] = data["description"];
      }
    } else if (type == "update_comment") {
      final indexComment = issue["comments"].indexWhere((e) => e["id"] == data["id"]);

      if (indexComment != -1) {
        if (userId != data["last_edit_id"]) {
          issue["comments"][indexComment] = data;
        }
      }
    }
  }


  getDataIssue() async {
    var issueData = widget.issue;
    var auth = Provider.of<Auth>(context, listen: false);
    var resData = await Dio().post(
      "${Utils.apiUrl}workspaces/${issueData["workspace_id"]}/channels/${issueData["channel_id"]}/issues?token=${auth.token}", 
      data: {
        "issue_id": issueData["id"]
      }
    );
    if (resData.data["success"] && resData.data["issues"].length > 0){
      setState(() {
        // timelines = resData.data["issues"][0]["timelines"];
        issue = Utils.mergeMaps([issue, resData.data["issues"][0]]);
        issue["comments"] = [];
      });

      Provider.of<Channels>(context, listen: false).setLabelsAndMilestones(issueData["channel_id"], resData.data["labels"], resData.data["milestones"]);
      var resComment = await Dio().post(
        "${Utils.apiUrl}workspaces/${issueData["workspace_id"]}/channels/${issueData["channel_id"]}/issues/update_unread_issue?token=${auth.token}",
        data: {
          "issue_id": issueData["id"]
        }
      );
      if (resComment.data["success"]){
        setState(() {
          issue["comments"] = resComment.data["comments"];
        });
        if (issue["comment_id"] != null){
          //  scroll toi phan tu do
        }
      }
    }
  }

  ScrollController _scrollController = ScrollController();
  bool updateIssue = false;

  handleScroll() {
  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  updateIssueState(value) {
    updateIssue = value;
  }

  parseDatetime(time) {
    try {
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
            if (month >= 1) return '${month.toString().padLeft(1, "")} ${month > 1 ? S.current.months : S.current.month} ${S.current.months} ${S.current.ago}';
            else return '${day.toString().padLeft(1, "")} ${day > 1 ? S.current.days : S.current.day} ${S.current.ago}';
          }
        } else if (hour > 0) {
          return '${hour.toString().padLeft(1, "")} ${hour > 1 ? S.current.hours : S.current.hour} ${S.current.ago}';
        } else if(minutes <= 1) {
          return "${S.current.months} ${S.current.ago}";
        } else {
          return '${minutes.toString().padLeft(1, "0")} ${S.current.minutesAgo}';
        }
      } else {
        return S.current.offline;
      } 
    } catch (e) {
      return "";
    }

  }

  Map getDataChannel(){
    try {
      List channels = Provider.of<Channels>(context, listen: false).data;
      int index  = channels.indexWhere((element) => "${element["id"]}" == "${issue["channel_id"]}");
      return {
        "channel_id": channels[index]["id"],
        ...channels[index]
      };
    } catch (e) {
      print("getDataChannel: $e");
      return {};
    }
  }

  onChangeCheckBox(value, elText, commentId, indexCheckbox) {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentChannel = getDataChannel();
    final channelId = currentChannel["id"];
    
    String description = issue["description"];
    String newText = Utils.onChangeCheckbox(description, value, elText, indexCheckbox);
    issue["description"] = newText;
    var result = Provider.of<Messages>(context, listen: false).checkMentions(newText);
    var listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];

    var dataDescription = {
      "description": newText,
      "channel_id":  channelId,
      "workspace_id": currentChannel["workspace_id"],
      "user_id": auth.userId,
      "type": "issues",
      "from_issue_id": issue["id"],
      "from_id_issue_comment": issue["id"],
      "list_mentions_old": issue["mentions"],
      "list_mentions_new": listMentionsNew
    };

    Provider.of<Channels>(context, listen: false).updateIssueTitle(auth.token, currentChannel["workspace_id"], channelId, issue["id"], issue["title"], dataDescription);
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
          child: CommentField(issue: issue, text: text, handleSave: handleSave, height: height,)
        );
      }
    );
  }

  onSelectDirectMessages(directId, Map? message) async {
    final auth = Provider.of<Auth>(context, listen: false);
    bool hasConv = await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(auth.token, directId);
    if (!hasConv) return;
    DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(directId);
    if (dm == null  || message == null) return;
    await Provider.of<DirectMessage>(context, listen: false).processDataMessageToJump(message, auth.token, auth.userId);
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) {
          return Message(
            dataDirectMessage: dm,
            name: "",
            id: dm.id,
            avatarUrl: "",
            isNavigator: true,
            idMessageToJump: message["id"],
            panelController: panelController
          );
        },
      )
    );
  }

  handleSave(value) {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentChannel = getDataChannel();
    var result = Provider.of<Messages>(context, listen: false).checkMentions(value.trim());
    List listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];

    var dataDescription = {
      "description": value,
      "channel_id":  currentChannel["id"],
      "workspace_id": currentChannel["workspace_id"],
      "user_id": auth.userId,
      "type": "issues",
      "title": issue["title"],
      "from_issue_id": issue["id"],
      "from_id_issue_comment": issue["id"],
      "list_mentions_old": issue["mentions"],
      "list_mentions_new": listMentionsNew
    };
    Provider.of<Channels>(context, listen: false).updateIssueTitle(auth.token, currentChannel["workspace_id"], currentChannel["id"], issue["id"], issue["title"], dataDescription);
    Navigator.of(context).pop();
  }

  parseAttachments(dataM) {
    String message = dataM["message"] ?? "";
    int index = (dataM['attachments'] ?? []).indexWhere((e) => e['type'] == 'mention');

    if (index != -1) {
      List mentionData =  dataM['attachments'][index]["data"] ?? [];
      message = "";

      for(final item in mentionData) {
        if(['user', 'all', 'issue'].contains(item["type"])) {
          if(item["type"] == 'issue') {
            message += (item["trigger"] ?? "@") + item['value'];
          } else {
            message += "=======${item["trigger"] ?? "@"}/${item["value"]}^^^^^${item["name"]}^^^^^${item["type"] ?? ((item["id"].length < 10) ? "all" : "user")}+++++++";
          }
        } else if(item['type'] == 'block_code') {
          if(item['isThreeBackstitch'] ?? false) {
            message += '\n```\n' + item['value'] + '\n```\n';
          } else {
            message += '\n`' + item['value'] + '`\n';
          }
        } else {
          message += item["value"];
        }
      }
    }

    var parse = Provider.of<Messages>(context, listen: false).checkMentions(message);
    if (parse["success"] == false) return message;
    return Utils.getStringFromParse(parse["data"]);
  }

  @override
  Widget build(BuildContext context) {
    // final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final channelMember = Provider.of<Channels>(context, listen: true).getChannelMember(issue["channel_id"]);
    final indexOwnerIssue = channelMember.indexWhere((element) => element['id'] == issue['author_id']);
    final ownerIssue = indexOwnerIssue == -1 ? {"full_name": "Unknow"} : channelMember[indexOwnerIssue];
    final message = issue['message'];
    String descriptionMessage = '';

    if(message != null) {
      descriptionMessage = (message["message"] != "") ? message["message"] : message["attachments"].length > 0 ? parseAttachments(message) : "";
    }

    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    List commentsAndTimelines = (issue["comments"] ?? []) + (issue["timelines"] ?? []);
    commentsAndTimelines.sort((a, b) => a["inserted_at"].compareTo(b["inserted_at"]));
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff2E2E2E) : Colors.white,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () { 
                            if(updateIssue && widget.updateIssue != null) {
                              widget.updateIssue();
                            }
                            Navigator.of(context, rootNavigator: true).pop("Discard");
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Icon(PhosphorIcons.arrowLeft, size: 20, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Text(
                            S.current.issueDetails,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )
                          ),
                        ),
                        Container(
                          width: 40,
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: isDark ? Color(0xff2E2E2E) : Color(0xffEDEDED),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        children: [
                          IssueTitleAndDescription(isDark: isDark, issue: issue),
                          Container(
                            margin: EdgeInsets.only(bottom: 8.0, top: 12.0),
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
                              border: isDark ? null : Border(
                                bottom: BorderSide(color: Color(0xffC9C9C9), width: 0.65),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 16.0, top: 12.0, bottom: 12.0),
                                  decoration: BoxDecoration(
                                    color: isDark ?  Color(0xff4c4c4c) : Color(0xffF8F8F8),
                                    border: Border(
                                      bottom: BorderSide(color: isDark ? Color(0xff5E5E5) : Color(0xffC9C9C9)),
                                      top: BorderSide(color:isDark ? Color(0xff5E5E5) :  Color(0xffC9C9C9)),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 16),
                                            child: CachedAvatar(
                                              ownerIssue["avatar_url"],
                                              width: 40,
                                              height: 40,
                                              radius: 20,
                                              name: ownerIssue["full_name"],
                                            ),
                                          ),
                                          SizedBox(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text( Utils.getUserNickName(ownerIssue["id"]) ?? ownerIssue["full_name"] ?? "", style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Color(0xff2E2E2E), fontWeight: FontWeight.w700)),
                                                SizedBox(height: 2,),
                                                Text("${S.current.openedThisIssue} ${parseDatetime(issue["inserted_at"])}", style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Colors.black.withOpacity(0.65), fontSize: 12))
                                              ]
                                            )
                                          )
                                        ]
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            child: Container(
                                              padding: EdgeInsets.only(right: 16, top: 12, bottom: 12, left: 12),
                                              child: Icon(PhosphorIcons.pencilLine, size: 20, color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E))
                                            ),
                                            onTap: () {
                                              showBottomSheetComment(context, issue["description"], handleSave);
                                            }
                                          )
                                        ]
                                      )
                                    ]
                                  ),
                                ),
                                Container(
                                  color: isDark ? Color(0xff1E1E1E) : Color(0xFFEDEDED),
                                  child: RenderMarkdown(
                                    stringData: (issue["description"] != null && issue["description"] != "") ? Utils.parseComment(issue["description"], false) : "_No description provided._",
                                    onChangeCheckBox: onChangeCheckBox
                                  )
                                )
                              ]
                            )
                          ),

                          if(widget.issue['message'] != null && issue['id'] != null) Padding(
                              padding: const EdgeInsets.only(left: 14.0, right: 12.0),
                            child: IssueTimeline(
                              channelId: widget.issue['channel_id'],
                              timelines: [{
                                'data': {
                                  'type': 'create_message',
                                  'description': descriptionMessage,
                                },
                                'inserted_at': issue['inserted_at'],
                                'user_id': issue['author_id']
                              }],
                              onTap: () async{
                                final data =  widget.issue['message'];
                                final message = {
                                  'id': data['id'],
                                  "avatarUrl": data["avatarUrl"] ?? "",
                                  "fullName": data["fullName"] ?? "",
                                  "workspace_id": data["workspaceId"],
                                  "channel_id": data["channelId"],
                                  'conversation_id': data['conversationId'],
                                  'inserted_at': data['insertedAt'],
                                  'current_time': DateTime.parse(data['insertedAt']).toUtc().microsecondsSinceEpoch
                                };
                                if(message['conversation_id'] == null) {
                                  await Provider.of<Messages>(context, listen: false).handleProcessMessageToJump(message, context);

                                  Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return Conversation(
                                          id: message['channel_id'], 
                                          hideInput: true, 
                                          changePageView: (page) {}, 
                                          isNavigator: true,
                                          panelController: panelController
                                        );
                                      },
                                    )
                                  );
                                } else {
                                  onSelectDirectMessages(message['conversation_id'], message);
                                }
                              },
                            ),
                          ),
                          CommentAndTimeline(
                            commentsAndTimelines: commentsAndTimelines,
                            issue: issue
                          ),
                          SizedBox(height: 145,)
                        ]
                      )
                    )
                  )
                )
              ]
            )
          ),
          CommentBottomSheet(issue: issue, handleScroll: handleScroll, updateIssueState: updateIssueState)
        ],
      )
    );
  }
}

class IssueTitleAndDescription extends StatefulWidget {
  const IssueTitleAndDescription({
    Key? key,
    this.isDark,
    this.issue
  }) : super(key: key);

  final isDark;
  final issue;

  @override
  _IssueTitleAndDescriptionState createState() => _IssueTitleAndDescriptionState();
}

class _IssueTitleAndDescriptionState extends State<IssueTitleAndDescription> {
  bool onEdit = false;
  final TextEditingController controller = TextEditingController();
  FocusNode focusNode = new FocusNode();
  
  @override
  void initState() {
    super.initState();
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

  changeTitle() {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentChannel  = getDataChannel();

    var dataDescription = {
      "description": widget.issue["description"],
      "channel_id":  currentChannel["id"],
      "workspace_id": currentChannel["workspace_id"],
      "user_id": auth.userId,
      "type": "issues",
      "from_issue_id": widget.issue["id"],
      "from_id_issue_comment": widget.issue["id"],
      "list_mentions_old": widget.issue["mentions"],
      "list_mentions_new": []
    };


    if (controller.text.trim() != "") {
      Provider.of<Channels>(context, listen: false).updateIssueTitle(auth.token, currentChannel["workspace_id"], currentChannel["id"], widget.issue["id"], controller.text, dataDescription);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            color: Colors.black.withOpacity(0.04)
          ),
          BoxShadow(
            blurRadius: 2,
            color: Colors.black.withOpacity(0.06)
          ),
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 4),
            color: Colors.black.withOpacity(0.04)
          )
        ],
        color: widget.isDark ? Color(0xFF4C4C4C) :Colors.white,
        border: isDark ? null : Border(
          bottom: BorderSide(color: Color(0xffC9C9C9), width: 0.65)
        ),
      ),
      padding: EdgeInsets.only(bottom: 16, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          onEdit ? Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CupertinoTextField(
                    focusNode: focusNode,
                    controller: controller,
                    decoration: BoxDecoration(
                      color: widget.isDark ? Color(0xff2E2E2E) : Color(0xffEDEDED),
                    ),
                    style: TextStyle(color: widget.isDark ? Colors.white.withOpacity(0.9) : Color(0xff3D3D3D), fontSize: 15, fontWeight: FontWeight.w600),
                  )
                ),
                Row(
                  children: [
                    SizedBox(width: 10),
                    InkWell(
                      onTap:() {
                        this.setState(() { onEdit = false; });
                      } ,
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: EdgeInsets.only(right: 8),
                        child: Icon(PhosphorIcons.xCircle, size: 20, color: Color(0xffEB5757)),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffEB5757)),
                          borderRadius: BorderRadius.circular(2)
                        ),
                      ),
                    ),
                    InkWell(
                      onTap:() {
                        this.setState(() { onEdit = false; });
                        changeTitle();
                      } ,
                      child: Container(
                        width: 30,
                        height: 30,
                        margin: EdgeInsets.only(right: 16),
                        child: Icon(PhosphorIcons.floppyDiskBack, size: 20, color: Color(0xffFFFFFF)),
                        decoration: BoxDecoration(
                          color: Color(0xff1890FF),
                          borderRadius: BorderRadius.circular(2)
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ) : Container(

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 16),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 76,
                  ),
                  child: Text(
                    widget.issue["title"] ?? "", 
                    style: TextStyle(color: widget.isDark ? Colors.white.withOpacity(0.85) : Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)
                  )
                ),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.only(right: 16, top: 16, left: 16, bottom: 3),
                    child: Icon(PhosphorIcons.pencilLine, size: 20, color: widget.isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E))
                  ), 
                  onTap: () {  
                    this.setState(() { onEdit = true; });
                    focusNode.requestFocus();
                    controller.text = widget.issue["title"];
                  }
                )
              ]
            ),
          ),
          SizedBox(height: 12,),
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: widget.issue["is_closed"] ? Color(0xff27AE60) : Color(0xff1890ff)
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(PhosphorIcons.info, color: Colors.white, size: 16,),
                      Text(widget.issue["is_closed"] ? " ${S.current.tClosed}" : " ${S.current.tOpen}", style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w500))
                    ]
                  )
                ),
                SizedBox(width: 8,),
                Text(widget.issue["comments_count"]  < 1 ? "" : widget.issue["comments_count"]  == 1 ? "1 comment" : "${widget.issue["comments_count"]} ${S.current.comment}", style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black.withOpacity(0.65), fontSize: 12)) 
              ],
            ),
          )
        ]
      )
    );
  }
}
