import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/drop_target.dart';
import 'package:workcake/desktop/components/issue_timeline.dart';
import 'package:workcake/desktop/workview_desktop/render_markdown.dart';
import 'package:workcake/desktop/workview_desktop/select_attribute.dart';
import 'package:workcake/desktop/workview_desktop/transfer_issue.dart';
import 'package:workcake/models/models.dart';
import 'comment_text_field.dart';

class CreateIssue extends StatefulWidget {
  CreateIssue({
    Key? key,
    this.issue,
    this.comments,
    this.timelines,
    this.fromMentions,
  }) : super(key: key);

  final issue;
  final comments;
  final timelines;
  final fromMentions;

  get selectedLabels => null;

  @override
  _CreateIssueState createState() => _CreateIssueState();
}

class _CreateIssueState extends State<CreateIssue> {
  var focusNode;
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  List assignees = [];
  List selectedLabels = [];
  List selectedMilestone = [];
  List comments = [];
  String text = "";
  bool onEdit = true;
  var issue;
  var selectedComment;
  bool editTitle = false;
  bool editDescription = false;
  String description = "";
  String draftComment = "";
  List timelines = [];
  ScrollController controller = new ScrollController();
  var isClosed = false;
  var channel;
  bool isFocusApp = true;
  FocusNode? focusDefault;

  @override
  void initState() {
    super.initState();
    if (widget.issue != null) {
      if (widget.fromMentions != null && widget.fromMentions) getDataIssue();

      this.setState(() {
        issue = widget.issue;
        assignees = widget.issue["assignees"] ?? [];
        selectedLabels = widget.issue["labels"] ?? [];
        selectedMilestone = widget.issue["milestone_id"] != null  ? [widget.issue["milestone_id"]] : [];
        comments = widget.comments != null ? widget.comments : [];
        timelines = widget.timelines != null ? widget.timelines : [];
        isClosed = false;
      });
      _titleController.text = issue["title"];

      onLoadDraftIssue();
    } else {
      Map currentChannel = getCurrentChannel();
      Map newIssue = Provider.of<Work>(context, listen: false).createNewIssue(currentChannel["id"]);

      _titleController.text = newIssue["title"];
      description =  newIssue["description"];
      assignees = newIssue["assignees"];
      selectedLabels = newIssue["labels"];
      selectedMilestone = newIssue["milestone"] != null ? [newIssue["milestone"]] : [];
    }

    focusDefault = FocusNode(onKey: (node, RawKeyEvent keyEvent) {
      final eventKey = keyEvent.runtimeType.toString();
      if (keyEvent.isKeyPressed(LogicalKeyboardKey.escape) && eventKey == 'RawKeyDownEvent') Navigator.pop(context);
      return KeyEventResult.ignored;
    });

    focusNode = FocusNode(onKey: (node, RawKeyEvent keyEvent) {
      final eventKey = keyEvent.runtimeType.toString();

      if (keyEvent.isKeyPressed(LogicalKeyboardKey.enter) && eventKey == 'RawKeyDownEvent') {
        handleEnterEvent();
      } else if (keyEvent.isMetaPressed && eventKey == "RawKeyDownEvent") {
        if (keyEvent.isKeyPressed(LogicalKeyboardKey.backspace) && eventKey == 'RawKeyDownEvent') {
          var newString = _titleController.text.substring(_titleController.selection.extentOffset, _titleController.text.length);
          _titleController.text = newString;
          _titleController.selection = TextSelection.fromPosition(TextPosition(offset: 0));
        }
      }

      return KeyEventResult.ignored;
    });
    if (widget.fromMentions != null && widget.fromMentions){
      channel = Provider.of<Auth>(context, listen: false).channel;
      channel.on("update_issue", (dataIssue, _j, _r){
        if (!mounted) return;
        var data = dataIssue["data"];
        final type = dataIssue["type"];
        if (type == "update_timeline") {
            issue["timelines"].add(data);
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
              if (issue["comments_count"].length == 0) {
                issue["comments_count"].add(1);
              } else {
                issue["comments_count"][0] += 1;
              }
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
          issue["description"] = data["description"];
        } else if (type == "update_comment") {
          final indexComment = issue["comments"].indexWhere((e) => e["id"] == data["id"]);

          if (indexComment != -1) {
            issue["comments"][indexComment] = data;
          }
        }
      });
    }
  }

  @override
  void didUpdateWidget (oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.selectedLabels != selectedLabels) {
      this.setState(() {

      });
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
        timelines =  resData.data["issues"][0]["timelines"];
        issue =  Utils.mergeMaps([issue, resData.data["issues"][0]]);
        issue["comments"] = [];
        assignees = issue["assignees"];
        selectedLabels = issue["labels"];
        selectedMilestone = issue["milestone"] != null ? [issue["milestone"]] : [];
      });

      Provider.of<Channels>(context, listen: false).setLabelsAndMilestones(issueData["channel_id"], resData.data["labels"], resData.data["milestones"]);
      // ham nay se ktra neu channel da dc goi se ko goi nua.
      Provider.of<Channels>(context, listen: false).selectChannel(auth.token, issueData["workspace_id"], issueData["channel_id"]);
      // get issue comment
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

  getCurrentWorkspace(){
    try {
      var workspaceId = widget.issue["workspace_id"];
      var workspaces  = Provider.of<Workspaces>(context, listen: false).data;
      var index = workspaces.indexWhere((element) => element["id"] == workspaceId);
      if (index  == -1) return {};
      return workspaces[index];
    } catch (err) {
      return Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    }
  }

  getCurrentChannel(){
    try {
      var workspaceId = widget.issue["channel_id"];
      var channels = Provider.of<Channels>(context, listen: true).data;
      var index = channels.indexWhere((element) => element["id"] == workspaceId);
      if (index == -1) return {};
      return channels[index];
    } catch (err) {
      return Provider.of<Channels>(context, listen: false).currentChannel;
    }
  }

  handleEnterEvent() {
    List listText = text.split("\n");
    final selection = _commentController.selection;
    bool check = false;

    if (_commentController.value.text.length >= selection.baseOffset) {
      if (listText.length > 0) {
        String lastText = listText[listText.length - 1];

        if (lastText.length > 6) {
          if (lastText.substring(0, 6) == "- [ ] ") {
            listText.add("- [ ] ");
            check = true;
          } else if (lastText.length > 2) {
            if (lastText.substring(0, 2) == "- " && !lastText.contains("- [ ]")) {
              listText.add("- ");
              check = true;
            }
          }
        } else if (lastText.length > 2) {
          if (lastText.substring(0, 2) == "- " && !lastText.contains("- [ ]")) {
            listText.add("- ");
            check = true;
          }
        } else {
          RegExp exp = new RegExp(r"[0-9]{1,}.\s");
          Iterable<RegExpMatch> matches = exp.allMatches(lastText);

          if (matches.length > 0) {
            int index = lastText.indexOf(".");
            int subString = int.parse(lastText.substring(0, index));
            listText.add("${subString + 1}. ");
            check = true;
          }
        }
      }

      if (check) {
        this.setState(() {
          text = listText.join("\n");
        });

        _commentController.value = _commentController.value.copyWith(
          text: listText.join("\n"),
          selection: TextSelection.collapsed(
            offset: listText.join("\n").length,
          ),
        );
      }
    }
  }

  onSubmitNewIssue(text) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = getCurrentWorkspace();
    final currentChannel = getCurrentChannel();
    Provider.of<Work>(context, listen: false).deleteIssue(currentChannel["id"]);

    if (_titleController.text.trim() != "") {
      var milestone = selectedMilestone.length > 0 ? selectedMilestone[0] : null;
      var result = Provider.of<Messages>(context, listen: false).checkMentions(text);
      var listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];
      Map issue = {
        "title":  _titleController.text,
        "description": text,
        "labels": selectedLabels,
        "milestone": milestone,
        "users": assignees,
        "list_mentions_old": [],
        "list_mentions_new": listMentionsNew,
        "type": "issues"
      };

      Provider.of<Channels>(context, listen: false).createIssue(token, currentWorkspace["id"], currentChannel["id"], issue);
      Provider.of<Work>(context, listen: false).setIssueClosedTab(false);
      Navigator.of(context, rootNavigator: true).pop("Discard");
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Title cannot be empty"),
          );
        },
      );
    }
  }

  onSaveDraftIssue() async{
     Map draffIssue = {
      "id": issue["id"],
      "description": description,
      "editDescription": editDescription,
      "draftComment": draftComment,
      // "selectedComment": selectedComment,
      // "comment": _commentController.text
    };
    var box = await Hive.openBox("draftsComment");
    List? boxGet = box.get("lastEdited");
    List listDraftIssue = [];

    if (boxGet != null) {
      listDraftIssue = List.from(boxGet);
    }

    var index = listDraftIssue.indexWhere((element) => element["id"] == issue["id"]);

    if (index != -1){
      listDraftIssue[index] = draffIssue;
    } else {
        listDraftIssue.add(draffIssue);
    }
    if (listDraftIssue.length > 10){
      listDraftIssue.removeAt(0);
    }
    if (selectedComment == null && editDescription == false && draftComment == "" && index != -1){
      listDraftIssue.removeAt(index);
    }
    Provider.of<Work>(context, listen: false).listIssueDraff = listDraftIssue;
    box.put("lastEdited", listDraftIssue);
  }

  onLoadDraftIssue() {
    List listDraftIssue = Provider.of<Work>(context, listen: false).listIssueDraft;
    var index = listDraftIssue.indexWhere((element) => element["id"] == issue["id"]);

    if (index != -1) {
      this.setState(() {
        editDescription = listDraftIssue[index]["editDescription"] ?? false;
        description = listDraftIssue[index]["description"];
        draftComment = listDraftIssue[index]["draftComment"];
        // selectedComment = listDraftIssue[index]["selectedComment"];
        // _commentController.text = listDraftIssue[index]["comment"];
      });
    }
  }

  onUpdateIssue(title, description, isCancel) async {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentWorkspace = getCurrentWorkspace();
    final currentChannel = getCurrentChannel();
    final channelId = issue != null && issue["channel_id"] != null ? issue["channel_id"] : currentChannel["id"];

    if (isCancel) this.setState(() {
      editDescription = false;
      description = issue["description"];
    });

    if (title != "") {
      var result = Provider.of<Messages>(context, listen: false).checkMentions(description);
      var listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];
      var dataDescription = {
        "description": description,
        "channel_id":  channelId,
        "workspace_id": currentWorkspace["id"],
        "user_id": auth.userId,
        "type": "issues",
        "from_issue_id": issue["id"],
        "from_id_issue_comment": issue["id"],
        "list_mentions_old": issue["mentions"],
        "list_mentions_new": listMentionsNew
      };

      final now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      Provider.of<Channels>(context, listen: false).updateIssueTitle(auth.token, currentWorkspace["id"], channelId, issue["id"], title, dataDescription).then((value) => {
        this.setState(() {
          issue["last_edit_description"] = formattedDate;
          issue["title"] = title;
          issue["description"] = description;
          editDescription = false;
        })
      });
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Title cannot be empty"),
          );
        },
      );

      this.setState(() {
        editDescription = false;
      });
    }
  }

  changeAssignees(user) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = getCurrentWorkspace();
    final currentChannel = getCurrentChannel();
    List list = List.from(assignees);
    final index = list.indexWhere((e) => e == user["id"]);
    final channelId = issue != null && issue["channel_id"] != null ? issue["channel_id"] : currentChannel["id"];

    if (index != -1) {
      list.removeAt(index);
      if (issue != null) {
        Provider.of<Channels>(context, listen: false).removeAttribute(token, currentWorkspace["id"], channelId, widget.issue["id"], "assignee", user["id"]);
      }
    } else {
      list.add(user["id"]);

      if (issue != null) {
        Provider.of<Channels>(context, listen: false).addAttribute(token, currentWorkspace["id"], channelId, widget.issue["id"], "assignee", user["id"]);
      }
    }

    this.setState(() {
      assignees = list;
    });
  }

  changeLabels(label) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = getCurrentWorkspace();
    final currentChannel = getCurrentChannel();
    List list = List.from(selectedLabels);
    final index = list.indexWhere((e) => e == label["id"]);
    final channelId = issue != null && issue["channel_id"] != null ? issue["channel_id"] : currentChannel["id"];

    if (index != -1) {
      list.removeAt(index);

      if (issue != null) {
        Provider.of<Channels>(context, listen: false).removeAttribute(token, currentWorkspace["id"], channelId, widget.issue["id"], "label", label["id"]);
      }
    } else {
      list.add(label["id"]);

      if (issue != null) {
        Provider.of<Channels>(context, listen: false).addAttribute(token, currentWorkspace["id"], channelId, widget.issue["id"], "label", label["id"]);
      }
    }

    this.setState(() {
      selectedLabels = list;
    });
  }

  changeMilestone(milestone) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = getCurrentWorkspace();
    final currentChannel = getCurrentChannel();
    final channelId = issue != null && issue["channel_id"] != null ? issue["channel_id"] : currentChannel["id"];

    if (selectedMilestone.length == 0) {
      Map data = {
        "type": "milestone",
        "added": [milestone["id"]],
        "removed": []
      };

      this.setState(() {
        selectedMilestone = [milestone["id"]];
      });

      if (issue != null) {
        Provider.of<Channels>(context, listen: false).addAttribute(token, currentWorkspace["id"], channelId, widget.issue["id"], "milestone", milestone["id"]);
        Provider.of<Channels>(context, listen: false).updateIssueTimeline(token, currentWorkspace["id"], channelId, widget.issue["id"], data);
      }

      Navigator.of(context, rootNavigator: true).pop("Discard");
    } else {
      if (selectedMilestone[0] == milestone["id"]) {
        this.setState(() {
          selectedMilestone = [];
        });

        if (issue != null) {
          Provider.of<Channels>(context, listen: false).removeAttribute(token, currentWorkspace["id"], channelId, widget.issue["id"], "milestone", milestone["id"]);
        }
      } else {
        Map data = {
          "type": "milestone",
          "added": [milestone["id"]],
          "removed": selectedMilestone
        };

        this.setState(() {
          selectedMilestone = [milestone["id"]];
        });

        if (issue != null) {
          Provider.of<Channels>(context, listen: false).addAttribute(token, currentWorkspace["id"], channelId, widget.issue["id"], "milestone", milestone["id"]);
          Provider.of<Channels>(context, listen: false).updateIssueTimeline(token, currentWorkspace["id"], channelId, widget.issue["id"], data);
        }

        Navigator.of(context, rootNavigator: true).pop("Discard");
      }
    }
  }

  onCommentIssue(text) {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentWorkspace = getCurrentWorkspace();
    final currentChannel = getCurrentChannel();
    final channelId = issue != null && issue["channel_id"] != null ? issue["channel_id"] : currentChannel["id"];
    var result = Provider.of<Messages>(context, listen: false).checkMentions(text);
    var listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];

    var dataComment = {
      "comment": text,
      "channel_id":  channelId,
      "workspace_id": currentWorkspace["id"],
      "user_id": auth.userId,
      "type": "issue_comment",
      "from_issue_id": issue["id"],
      "list_mentions_old": [],
      "list_mentions_new": listMentionsNew
    };

    if (text.trim() != "") {
      Provider.of<Channels>(context, listen: false).submitComment(auth.token, dataComment);
    }
  }

  onChangeCheckBox(value, elText, commentId, indexCheckbox) {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentWorkspace = getCurrentWorkspace();
    final currentChannel = getCurrentChannel();
    int indexComment = issue["comments"].indexWhere((e) => e["id"] == commentId);
    final channelId = issue != null && issue["channel_id"] != null ? issue["channel_id"] : currentChannel["id"];

    if (elText.length >= 3) {
      if (indexComment != -1) {
        var issueComment = widget.issue["comments"][indexComment];
        String comment = issue["comments"][indexComment]["comment"];
        String newText = Utils.onChangeCheckbox(comment, value, elText, indexCheckbox);
        issue["comments"][indexComment]["comment"] = newText;
        var result = Provider.of<Messages>(context, listen: false).checkMentions(newText);
        var listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];

        var dataComment = {
          "comment": newText,
          "channel_id":  channelId,
          "workspace_id": currentWorkspace["id"],
          "user_id": auth.userId,
          "type": "issue_comment",
          "from_issue_id": issue["id"],
          "from_id_issue_comment": issueComment["id"],
          "list_mentions_old": issueComment["mentions"] ?? [],
          "list_mentions_new": listMentionsNew
        };

        Provider.of<Channels>(context, listen: false).updateComment(auth.token, dataComment);
      } else {
        String description = issue["description"];
        String newText = Utils.onChangeCheckbox(description, value, elText, indexCheckbox);
        issue["description"] = newText;
        var result = Provider.of<Messages>(context, listen: false).checkMentions(newText);
        var listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];

        var dataDescription = {
          "description": newText,
          "channel_id":  channelId,
          "workspace_id": currentWorkspace["id"],
          "user_id": auth.userId,
          "type": "issues",
          "from_issue_id": issue["id"],
          "from_id_issue_comment": issue["id"],
          "list_mentions_old": issue["mentions"],
          "list_mentions_new": listMentionsNew
        };

        Provider.of<Channels>(context, listen: false).updateIssueTitle(auth.token, currentWorkspace["id"], channelId, issue["id"], issue["title"], dataDescription);
      }
    }
  }

  onUpdateComment(comment, text) {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentWorkspace = getCurrentWorkspace();
    final currentChannel = getCurrentChannel();
    final channelId = issue != null && issue["channel_id"] != null ? issue["channel_id"] : currentChannel["id"];

    var result = Provider.of<Messages>(context, listen: false).checkMentions(text);
    var listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];
    var dataComment = {
      "comment": text,
      "channel_id":  channelId,
      "workspace_id": currentWorkspace["id"],
      "user_id": auth.userId,
      "type": "issue_comment",
      "from_issue_id": issue["id"],
      "from_id_issue_comment": comment["id"],
      "list_mentions_old": comment["mentions"] ?? [],
      "list_mentions_new": listMentionsNew
    };

    if (comment["comment"] != text) {
      Provider.of<Channels>(context, listen: false).updateComment(auth.token, dataComment);
    }

    this.setState(() {
      _commentController.text = comment["comment"];
      selectedComment = null;

    });
  }

  getMember(userId) {
    final channelMember = Provider.of<Channels>(context, listen: false).channelMember;
    final indexUser = channelMember.indexWhere((e) => e["id"] == userId);

    if (indexUser != -1) {
      return  {
        ...channelMember[indexUser],
        "full_name": channelMember[indexUser]["nickname"] ?? channelMember[indexUser]["full_name"]
      };
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
      final int minutes = difference % 60;
      final int day = hour ~/24;

      if (day > 0) {
        int month = day ~/30;
        int year = month ~/12;
        if (year >= 1) return '${year.toString().padLeft(1, "")} ${year > 1 ? "years" : "year"} ago';
        else {
          if (month >= 1) return '${month.toString().padLeft(1, "")} ${month > 1 ? "months" : "month"} months ago';
          else return '${day.toString().padLeft(1, "")} ${day > 1 ? "days" : "day"} ago';
        }
      } else if (hour > 0) {
        return '${hour.toString().padLeft(1, "")} ${hour > 1 ? "hours" : "hour"} ago';
      } else if(minutes <= 1) {
        return 'moments ago';
      } else {
        return '${minutes.toString().padLeft(1, "0")} minutes ago';
      }
    } else {
      return "Offline";
    }
  }

  handleFocus(keyEvent) {
    final eventKey = keyEvent.runtimeType.toString();
    if (keyEvent.isKeyPressed(LogicalKeyboardKey.escape) && eventKey == 'RawKeyDownEvent') Navigator.pop(context);
    return KeyEventResult.ignored;
  }

  listAssignee() {
    final channelMember = Provider.of<Channels>(context, listen: true).channelMember;
    final workspaceMember = Provider.of<Workspaces>(context, listen: true).members;
    List list = [];

    for (var item in assignees) {
      final index = workspaceMember.indexWhere((e) => e["id"] == item);
      final indexMember = channelMember.indexWhere((e) => e["id"] == item);

      if (index != -1 && indexMember == -1) {
        list.add(workspaceMember[index]);
      }
    }

    return channelMember + list;
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = getCurrentWorkspace();
    final currentChannel = getCurrentChannel();
    final labels = currentChannel["labels"] != null ? currentChannel["labels"] : [];
    final milestones = currentChannel["milestones"] != null ? currentChannel["milestones"] : [];
    var author = issue != null ? getMember(issue["author_id"]) : null;
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    if (issue != null) onSaveDraftIssue();

    if (issue == null) {
      Map newIssue = {
        "channelId": currentChannel["id"],
        "assignees": assignees,
        "milestone": selectedMilestone.length > 0 ? selectedMilestone[0] : null,
        "labels":  selectedLabels,
        "title":  _titleController.text,
        "description": description,
      };

      Provider.of<Work>(context, listen: true).updateIssue(newIssue);
    }

    List commentsAndTimelines = (widget.fromMentions != null && widget.fromMentions ?  issue["comments"] : comments) + timelines;
    commentsAndTimelines.sort((a, b) => a["inserted_at"].compareTo(b["inserted_at"]));

    return FocusScope(
      onKey: (node, RawKeyEvent keyEvent) => handleFocus(keyEvent),
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              color: Color(0xff323F4B),
              padding: EdgeInsets.symmetric(horizontal: 26),
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  (editTitle && issue != null) ? Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 3/5
                          ),
                          height: 32,
                          child: TextFormField(
                            autofocus: true,
                            decoration: InputDecoration(
                              contentPadding :EdgeInsets.symmetric(horizontal: 16),
                              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff19DFCB)), borderRadius: BorderRadius.all(Radius.circular(2))),
                              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xff19DFCB)), borderRadius: BorderRadius.all(Radius.circular(2))),
                            ),
                            focusNode: focusNode,
                            controller: _titleController,
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500 )
                          ),
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          onTap: () {
                            onUpdateIssue(_titleController.text, issue["description"], false);
                            this.setState(() {
                              editTitle = false;
                            });
                          },
                          child: Container(
                            height: 32,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Color(0xff19DFCB),
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: Text("Save"),
                          ),
                        ),
                        SizedBox(width: 16),
                        InkWell(
                          onTap: () {
                            this.setState(() {
                              editTitle = false;
                            });
                          },
                          child: Container(
                            height: 32,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: Color(0xffFF7875))
                            ),
                            child: Text("Cancel", style: TextStyle(color: Color(0xffFF7875)))
                          )
                        )
                      ]
                    ),
                  ) : (issue != null && !editTitle) ? Row(
                    children: [
                      Text(
                        "${issue["title"]} #${issue["unique_id"]}",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,)
                      ),
                      SizedBox(width: 16,),
                      InkWell(
                        onTap: () {
                          this.setState(() {
                            editTitle = true;
                          });
                        },
                        child: Icon(Icons.edit, color: isDark ? Colors.white : Colors.white, size: 17)
                      ),
                    ]
                  ,) : Text(
                    "New Issue",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,)
                  ),
                  InkWell(
                    child: Container(
                      height: 22,
                      // color: Colors.red,
                      child: Icon(CupertinoIcons.xmark_circle, color: Colors.white, size: 20,)
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      if(isClosed == true) {
                        Provider.of<Work>(context, listen: false).updateResetFilter();
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: isDark ? Color(0xff1F2933) : Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              if(issue == null) Container(
                                height: 48,
                                color: isDark ? Color(0xff323F4B) : Color(0xffE4E7EB),
                                child: TextFormField(
                                  autofocus: true,
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    hintText: "Title",
                                    hintStyle: TextStyle(color: isDark ? Color(0xFFD9D9D9) : Color.fromRGBO(0, 0, 0, 0.35),
                                fontSize: 14, fontWeight: FontWeight.w300),
                                    contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Color(0xffCBD2D9) : Color(0xff2A5298)), borderRadius: BorderRadius.all(Radius.circular(2))),
                                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Color(0xffCBD2D9) : Color(0xff2A5298)), borderRadius: BorderRadius.all(Radius.circular(2))),
                                  ),
                                  style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 15, fontWeight: FontWeight.normal),
                                ),
                              ),
                              if (issue != null) Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: (issue["is_closed"] != null && issue["is_closed"]) ? Color(0xff27AE60) : (isDark ? Color(0xff19DFCB) : Color(0xff2A5298)),
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Row(
                                      children: [
                                        Icon((issue["is_closed"] != null && issue["is_closed"]) ? Icons.check_circle_outline : Icons.info_outline, color: isDark && !issue["is_closed"] ? Color.fromRGBO(0, 0, 0, 0.65) : Colors.white, size: 17),
                                        SizedBox(width: 4),
                                        Text((issue["is_closed"] != null && issue["is_closed"]) ? "Closed" : "Open", style: TextStyle(color: isDark && !issue["is_closed"] ? Color.fromRGBO(0, 0, 0, 0.65) : Colors.white, fontWeight: FontWeight.w500)),
                                      ]
                                    )
                                  ),
                                  SizedBox(width: 8),
                                  Text("${getMember(issue["author_id"])["full_name"]}"),
                                  SizedBox(width: 4),
                                  Text("opened this issue ${parseDatetime(issue["inserted_at"])}", style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))),
                                  Text(" . ", style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))),
                                  Text("${issue["comments"].length} comments", style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65)))
                                ]
                              ),
                              SizedBox(height: 24,),
                              author == null ? Container() : Container(
                                margin: EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isDark ? Color(0xff323F4B) : Color(0xffCBD2D9)),
                                  color: Colors.transparent
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDark ? Color(0xff323F4B) : Color(0xffE4E7EB),
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CachedImage(
                                                author["avatar_url"],
                                                width: 26,
                                                height: 26,
                                                radius: 50,
                                                name: author["full_name"],
                                              ),
                                              SizedBox(width: 4),
                                              Text("${author["full_name"]}", style: TextStyle(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))),
                                              SizedBox(width: 4),
                                              Text(
                                                issue["last_edit_description"] != null
                                                  ? "edited ${parseDatetime(issue["last_edit_description"])}"
                                                  : "commented ${parseDatetime(issue["inserted_at"])}",
                                                style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))
                                                ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                width: 30,
                                                child: IconButton(
                                                  focusColor: Colors.transparent,
                                                  hoverColor: Colors.transparent,
                                                  highlightColor: Colors.transparent,
                                                  splashColor: Colors.transparent,
                                                  icon: Icon(Icons.edit, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), size: 17),
                                                  onPressed: () {
                                                    this.setState(() {
                                                      if (editDescription == true) {
                                                        description = issue["description"];
                                                        FocusScope.of(context).unfocus();
                                                      }
                                                      editDescription = !editDescription;
                                                    });
                                                  }
                                                )
                                              )
                                            ]
                                          )
                                        ]
                                      )
                                    ),
                                    editDescription ? Container(
                                      padding: EdgeInsets.all(8),
                                      child:  StreamBuilder(
                                        stream: DropTarget.instance.dropped,
                                        initialData: [],
                                        builder: (context, files){
                                          return CommentTextField(
                                            initialValue: issue["description"],
                                            editComment: true,
                                            issue: issue,
                                            isDescription: true,
                                            onUpdateComment: onUpdateIssue,
                                            onChangeText: (value) {
                                              this.setState(() {
                                                description = value;
                                              });
                                            }
                                          );
                                        }
                                      )
                                    ) : RenderMarkdown(stringData: issue["description"] != null && issue["description"] != "", onChangeCheckBox: onChangeCheckBox)
                                  ]
                                )
                              ),
                              if (issue != null) Container(
                                child: Column(
                                  children: commentsAndTimelines.map<Widget>((e) {
                                    if (e == null) return Container();
                                    if (e["comment"] != null) {
                                      var comment = e;
                                      var author = getMember(comment["author_id"]);
                                    return Container(
                                        margin: EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: isDark ? Color(0xff323F4B) : Color(0xffd2e1f7), width: 1),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: isDark ? Color(0xff323F4B) : Color(0xfff1f8ff),
                                                borderRadius: BorderRadius.only(topRight: Radius.circular(4), topLeft: Radius.circular(4))
                                              ),
                                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      CachedImage(
                                                        author["avatar_url"],
                                                        width: 26,
                                                        height: 26,
                                                        radius: 50,
                                                        name: author["full_name"],
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text("${author["full_name"]}", style: TextStyle(fontWeight: FontWeight.w500, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65))),
                                                      SizedBox(width: 4),
                                                      Text(comment["last_edited_id"] != null ? "edited ${parseDatetime(comment["updated_at"])}" : "commented ${parseDatetime(comment["updated_at"])}", style: TextStyle(color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65)))
                                                    ],
                                                  ),
                                                  comment["author_id"] == auth.userId ? Row(
                                                    children: [
                                                      Container(
                                                        width: 30,
                                                        child: IconButton(
                                                          focusColor: Colors.transparent,
                                                          hoverColor: Colors.transparent,
                                                          highlightColor: Colors.transparent,
                                                          splashColor: Colors.transparent,
                                                          icon: Icon(Icons.edit, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), size: 17),
                                                          onPressed: () {
                                                            if (selectedComment == comment["id"]) {
                                                              this.setState(() {
                                                                _commentController.text = comment["comment"];
                                                                selectedComment = null;
                                                                FocusScope.of(context).unfocus();
                                                              });
                                                            } else {
                                                              this.setState(() {
                                                                selectedComment = comment["id"];
                                                              });
                                                            }
                                                          }
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 30,
                                                        child: IconButton(
                                                          focusColor: Colors.transparent,
                                                          hoverColor: Colors.transparent,
                                                          highlightColor: Colors.transparent,
                                                          splashColor: Colors.transparent,
                                                          icon: Icon(Icons.delete_outline, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), size: 18),
                                                          onPressed: () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return AlertDialog(
                                                                  contentPadding: EdgeInsets.all(0),
                                                                  content: Container(
                                                                    padding: EdgeInsets.symmetric(vertical: 12),
                                                                    width: 200,
                                                                    height: 94,
                                                                    child: Column(
                                                                      children: [
                                                                        Text("Delete this comment ?"),
                                                                        SizedBox(height: 6),
                                                                        Divider(),
                                                                        Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                          children: [
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Navigator.of(context, rootNavigator: true).pop("Discard");
                                                                              },
                                                                              child: Text("Cancel"),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                Provider.of<Channels>(context, listen: false).deleteComment(token, currentWorkspace["id"], currentChannel["id"], comment["id"], issue["id"]);
                                                                                Navigator.of(context, rootNavigator: true).pop("Discard");
                                                                              },
                                                                              child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
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
                                                        ),
                                                      ),
                                                    ],
                                                  ) : Container(),
                                                ],
                                              )
                                            ),
                                            // Divider(height: 0.5, color: isDark ? Colors.white54 : Color(0xffd2e1f7), thickness: 1),
                                            selectedComment == comment["id"] ? Container(
                                              padding: EdgeInsets.all(8),
                                              child: CommentTextField(
                                                initialValue: _commentController.text,
                                                comment: comment,
                                                editComment: true,
                                                issue: issue,
                                                isDescription: false,
                                                onUpdateComment: onUpdateComment,
                                                onChangeText: (value) {
                                                  this.setState(() {
                                                  _commentController.text = value;
                                                });
                                                // onSaveDraftIssue();
                                                },
                                              ),
                                            ) : RenderMarkdown(stringData: Utils.parseComment(comment["comment"], false), onChangeCheckBox: onChangeCheckBox)
                                          ]
                                        )
                                      );
                                    } else {
                                      var times = [e];
                                      return IssueTimeline(timelines: times, channelId: widget.issue["channel_id"],);
                                    }
                                  }).toList()
                                )
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 12),
                                child: CommentTextField(
                                  onChangeText: (value){
                                    if (issue == null){
                                    setState(() {
                                      description = value;
                                    });
                                  } else{
                                      this.setState(() {
                                        draftComment = value;
                                      });
                                      // onSaveDraftIssue();
                                    }
                                  },
                                  initialValue: issue != null ? draftComment : description,
                                  editComment: false,
                                  issue: issue,
                                  isDescription: widget.issue == null,
                                  onSubmitNewIssue: onSubmitNewIssue,
                                  onCommentIssue: onCommentIssue
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: isDark ? Color(0xff616E7C): Color(0xffCBD2D9)))
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: 300
                                ),
                                width: (MediaQuery.of(context).size.width *1/4),
                                child: SelectAttribute(
                                  issue: issue,
                                  title: "Assignees",
                                  icon: Icon(CupertinoIcons.person_crop_circle_badge_plus, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), size: 18),
                                  listAttribute: listAssignee(),
                                  selectedAtt: assignees,
                                  selectAttribute: changeAssignees,
                                  selectFocus: () => focusDefault!.requestFocus()
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: 300
                                ),
                                width: MediaQuery.of(context).size.width *1/4,
                                child: SelectAttribute(
                                  issue: issue,
                                  title: "Labels",
                                  icon: Icon(CupertinoIcons.tag, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), size: 18),
                                  listAttribute: labels,
                                  selectedAtt: selectedLabels,
                                  selectAttribute: changeLabels,
                                  selectFocus: () => focusDefault!.requestFocus()
                                )
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: 300
                                ),
                                width: (MediaQuery.of(context).size.width *1/4),
                                child: SelectAttribute(
                                  issue: issue,
                                  title: "Milestone",
                                  icon: Icon(CupertinoIcons.flag, color: isDark ? Colors.white : Color.fromRGBO(0, 0, 0, 0.65), size: 18),
                                  listAttribute: milestones.where((e) => e["is_closed"] == false).toList(),
                                  selectedAtt: selectedMilestone,
                                  selectAttribute: changeMilestone,
                                  selectFocus: () => focusDefault!.requestFocus()
                                )
                              ),
                              issue != null ? TransferIssue(issue: issue) : SizedBox()
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}