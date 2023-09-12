import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/flutter_mentions.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/work_screen/list_icons.dart';

import '../../generated/l10n.dart';

class CommentField extends StatefulWidget {
  CommentField({
    Key? key,
    this.issue,
    this.text,
    this.handleSave,
    this.height,
    this.type,
  }) : super(key: key);

  final issue;
  final text;
  final handleSave;
  final height;
  final type;
  @override
  _CommentFieldState createState() => _CommentFieldState();
}

class _CommentFieldState extends State<CommentField> {
  GlobalKey<FlutterMentionsIssueState> key = GlobalKey<FlutterMentionsIssueState>();
  List<Map<String, dynamic>> suggestionMentions = [];

  FocusNode abc = FocusNode();
  int baseOffset = 0;

  @override
  void initState() { 
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  surroundTextSelection(String left, String right, type) {
    final currentTextValue = key.currentState!.controller!.value.text;
    final selection = key.currentState!.controller!.selection;
    final middle = selection.textInside(currentTextValue);
    final newTextValue = selection.textBefore(currentTextValue) + '$left$middle$right' + selection.textAfter(currentTextValue);

    key.currentState!.controller!.value = key.currentState!.controller!.value.copyWith(
      text: newTextValue,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset + left.length + middle.length,
      ),
    );
  }

  getImage(responseData) {
    final currentTextValue = key.currentState!.controller!.text;
    final selection = key.currentState!.controller!.selection;
    final after = selection.baseOffset == -1 ? "" : selection.textAfter(currentTextValue);
    final fileName = responseData["name"];
    int index = key.currentState!.controller!.text.indexOf(fileName);

    if (index != -1) {
      Timer(Duration(microseconds: 300), () {
        var text = key.currentState!.controller!.text.replaceRange(index + int.parse("${fileName.length}") + 5, index + int.parse("${fileName.length}") + 6, "${responseData["content_url"] ?? ''})");
        text = text.replaceAll("Uploading $fileName...", fileName);

        key.currentState!.controller!.value = key.currentState!.controller!.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(
            offset: text.length - after.length
          )
        );
      });
    }
  }


  getDataMentions() {
    List channelMembers = Provider.of<Channels>(context, listen: false).getChannelMember(widget.issue["channel_id"]);

    List listUser = List.from(channelMembers);
    List<Map<String, dynamic>> dataMentions = [];
    List involvedPersons = [];
    List usersAssign = (widget.issue['assignees'] is List) ? widget.issue['assignees'] : [];
    List usersComment = (widget.issue['comments'] is List)
                          ? (widget.issue['comments'] as List).map((e) => e['author_id']).toList()
                          : [];

    List usersCommentThread = (widget.issue['children'] is List)
                                ? (widget.issue['children'] as List).map((e) => e['author_id']).toList()
                                : [];

    List userIds = usersAssign + usersComment + usersCommentThread;

    for(final userId in userIds) {
      int index = involvedPersons.indexWhere((e) => e == userId);

      if(index == -1) {
        involvedPersons.add(userId);
        final int indexUser = listUser.indexWhere((ele) => ele['id'] == userId);

        if(indexUser != -1) {
          final user = listUser[indexUser];
          List newList = List.from(listUser);
          newList.removeAt(indexUser);
          listUser = [user] + newList;
        }
      }
    }

    for(final user in listUser) {
      Map<String, dynamic> item = {
        'id': user["id"],
        'type': 'user',
        'display': Utils.getUserNickName(user["id"]) ?? user["full_name"],
        'full_name': Utils.checkedTypeEmpty(Utils.getUserNickName(user["id"]))
            ? "${Utils.getUserNickName(user["id"])} • ${user["full_name"]}"
            : user["full_name"],
        'photo': user["avatar_url"],
        'username': user["username"]
      };

      dataMentions += [item];
    }

    setState(() {
      suggestionMentions = dataMentions;
    });
  }

  getSuggestionIssue() {
    List preloadIssues = Provider.of<Workspaces>(context, listen: false).preloadIssues;
    List dataList = [];

    for (var i = 0 ; i < preloadIssues.length; i++){
      Map<String, dynamic> item = {
        'id': "${preloadIssues[i]["id"]}-${preloadIssues[i]["workspace_id"]}-${preloadIssues[i]["channel_id"]}",
        'type': 'issue',
        'display': preloadIssues[i]["unique_id"].toString(),
        'title': preloadIssues[i]["title"],
        'channel_name': preloadIssues[i]["channel_name"],
        'is_closed': preloadIssues[i]["is_closed"]
      };

      dataList += [item];
    }

    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    return Stack(
      children: [
        Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[500]!, width: 0.2),
                )
              ),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(S.current.cancel, style: TextStyle(color: isDark ? Color(0xffFAAD14) : Colors.blue, fontSize: 16, fontWeight: FontWeight.w500))
                  ),
                  Text(S.current.editComment, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87)),
                  InkWell(
                    onTap: () async {
                      if(widget.type == "kanban_comment") {
                        widget.handleSave(key.currentState!.controller!.markupText, widget.issue);
                      }
                      else {
                        widget.handleSave(key.currentState!.controller!.markupText);
                      }
                    },
                    child: Text(S.current.save, style: TextStyle(color: isDark ? Color(0xffFAAD14) : Colors.blue, fontSize: 16, fontWeight: FontWeight.w500))
                  )
                ]
              )
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  height: widget.height - keyboardHeight - (keyboardHeight > 0 ? 106 : 50),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: FlutterMentionsIssue(
                      parseMention: Provider.of<Messages>(context, listen: false).checkMentions,
                      textCapitalization: TextCapitalization.sentences,
                      cursorColor: isDark ? Colors.grey[400]! : Colors.black87,
                      key: key,
                      isIssues: true,
                      afterFirstFrame: (){
                        if (key.currentState != null) {
                          key.currentState!.setMarkUpText(widget.text);
                        }
                      },
                      id: currentChannel['id'].toString(),
                      isDark: auth.theme == ThemeType.DARK,
                      style: TextStyle(fontSize: 15.5, color: isDark ? Colors.grey[300] : Colors.grey[800]),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 15 , color: isDark ? Color(0xff828282) : Colors.black.withOpacity(0.65)),
                        hintText: S.current.leaveAComment,
                      ),
                      islastEdited: false,
                      suggestionListHeight: 200,
                      onSearchChanged: (trigger, onGetMentions) {
                        if (trigger == "@") {
                          getDataMentions();
                        }
                      },
                      mentions: [
                        Mention(
                          markupBuilder: (trigger, mention, value, type) {
                            return "=======@/$mention^^^^^$value^^^^^$type+++++++";
                          },
                          trigger: '@',
                          style: TextStyle(color: Colors.lightBlue),
                          data: suggestionMentions,
                          matchAll: true,
                        ),
                        Mention(
                          markupBuilder: (trigger, mention, value, type) {
                            return "=======#/$mention^^^^^$value^^^^^$type+++++++";
                          },
                          trigger: "#",
                          style: TextStyle(color: Colors.lightBlue),
                          data: getSuggestionIssue(),
                          matchAll: true
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]
        ),
        if (keyboardHeight > 0) Positioned(
          bottom: keyboardHeight,
          child: Container(
            child: ListIcons(isDark: isDark, surroundTextSelection: surroundTextSelection, getImage: getImage)
          )
        )
      ]
    );
  }
}