import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/flutter_mentions.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';
import 'list_icons.dart';

class BottomSheetCreateIssue extends StatefulWidget {
  BottomSheetCreateIssue({
    Key? key,
    this.message,
    this.addNewIssue
  }) : super(key: key);

  final message;
  final addNewIssue;

  @override
  _BottomSheetCreateIssueState createState() => _BottomSheetCreateIssueState();
}

class _BottomSheetCreateIssueState extends State<BottomSheetCreateIssue> {
  GlobalKey<FlutterMentionsIssueState> key = GlobalKey<FlutterMentionsIssueState>();
  List<Map<String, dynamic>> suggestionMentions = [];

  String title = '';
  String description = '';
  bool isFocus = false;

  @override
  void initState() {
    final auth = Provider.of<Auth>(context, listen: false);

    final message = widget.message;
    if(message != null) {
      DateTime dateTime = DateTime.parse(message["insertedAt"]);
      final messageTime = DateFormat('kk:mm').format(DateTime.parse(message["insertedAt"]).add(Duration(hours: 7)));
      final dayTime = DateFormatter().getVerboseDateTimeRepresentation(dateTime, auth.locale);

      final messageLastTime = (message["insertedAt"] != "" && message["insertedAt"] != null)
        ? "${dayTime == "Today" ? messageTime : DateFormatter().renderTime(DateTime.parse(message["insertedAt"]), type: "MMMd") + " at $messageTime"}"
        : "";

      String text = (message["message"] != "" && message["message"] != null) ? message["message"] : message["attachments"].length > 0 ? parseAttachments(message) : "";
      description = "$text \n\n${message['fullName']} - $messageLastTime";
    }

    super.initState();
  }

  parseAttachments(dataM) {
    String message = dataM["message"] ?? "";
    int index = (dataM['attachments'] ?? []).indexWhere((e) => e['type'] == 'mention');

    if (index != -1) {
      List mentionData =  dataM['attachments'][index]["data"] ?? [];
      message = "";

      for(final item in mentionData){
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

    return message;
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

  onSubmitNewIssue() {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen:  false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen:  false).currentChannel;
    Provider.of<Work>(context, listen: false).deleteIssue(currentChannel["id"]);
    String text = (key.currentState != null && key.currentState!.controller!.markupText != "") ? key.currentState!.controller!.markupText : "";

    if ((title = title.replaceAll(RegExp(r'\n'), ' ')).trim() != "") {
      var result = Provider.of<Messages>(context, listen: false).checkMentions(text);
      List listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];
      Map issue = {
        "title": title,
        "description": text,
        "labels": [],
        "milestone": null,
        "users": [],
        "list_mentions_old": [],
        "list_mentions_new": listMentionsNew,
        "message": widget.message,
        "type": "issues"
      };

      Provider.of<Channels>(context, listen: false).createIssue(token, currentWorkspace["id"], currentChannel["id"], issue).then((value) {
        if (value != null && widget.message == null) {
          widget.addNewIssue();
        }
      });
      Navigator.of(context, rootNavigator: true).pop("Discard");
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(S.current.titleCannotBeEmpty),
          );
        },
      );
    }
  }

  getImage(responseData) {
    final currentTextValue = key.currentState!.controller!.text;
    final selection = key.currentState!.controller!.selection;
    final after = selection.baseOffset == -1 ? "" : selection.textAfter(currentTextValue);
    final fileName = responseData["filename"];
    int index = key.currentState!.controller!.text.indexOf(fileName);

    if (index != -1) {
      Timer(Duration(microseconds: 300), () {
        var text = key.currentState!.controller!.text.replaceRange(index + int.parse("${fileName.length}") + 5, index + int.parse("${fileName.length}") + 6, responseData["content_url"] + ")");
        text = text.replaceAll("Uploading $fileName...", responseData["id"]);

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
    List channelMembers = Provider.of<Channels>(context, listen: false).channelMember;
    setState(() {
      suggestionMentions = [];

      for (var i = 0 ; i < channelMembers.length; i++) {
        Map<String, dynamic> item = {
          'id': channelMembers[i]["id"],
          "type": "user",
          'display': channelMembers[i]["full_name"],
          'full_name': channelMembers[i]["full_name"],
          'photo': channelMembers[i]["avatar_url"]
        };
        suggestionMentions += [item];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final currentChannel = Provider.of<Channels>(context, listen:  true).currentChannel;

    return Container(
      height: MediaQuery.of(context).size.height*0.9,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[500]!, width: 0.2),
                  )
                ),
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                        child: Text(S.current.cancel, style: TextStyle(color: isDark ? Color(0xffFAAD14) : Colors.blue, fontSize: 16, fontWeight: FontWeight.w500)),
                      )
                    ),
                    Text(S.current.createANewIssue, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: isDark ? Colors.white.withOpacity(0.85) : Colors.black87)),
                    InkWell(
                      onTap: () async {
                        onSubmitNewIssue();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                        child: Text(S.current.save, style: TextStyle(color: isDark ? Color(0xffFAAD14) : Colors.blue, fontSize: 16, fontWeight: FontWeight.w500)),
                      )
                    )
                  ]
                )
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  style: TextStyle(fontSize: 18),
                  keyboardType: TextInputType.text,
                  minLines: 1,
                  maxLines: 15,
                  autofocus: false,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 18 , color: isDark ? Color(0xff828282) : Colors.black.withOpacity(0.65)),
                    hintText: S.current.title,
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    title = value;
                  }
                )
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Focus(
                  onFocusChange: (value) => setState(() => isFocus = value),
                  child: FlutterMentionsIssue(
                    parseMention: Provider.of<Messages>(context, listen: false).checkMentions,
                    afterFirstFrame: (){
                      if (key.currentState != null) {
                        key.currentState!.setMarkUpText(description);
                      }
                    },
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: isDark ? Colors.grey[400]! : Colors.black87,
                    key: key,
                    isIssues: true,
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
                      hintText: S.current.leaveADescription,
                    ),
                    islastEdited: false,
                    suggestionListHeight: 200,
                    onSearchChanged: (trigger, onGetMentions) {
                      if (trigger == "@"){
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
                    ],
                  ),
                )
              )
            ]
          ),
          if (keyboardHeight > 0 && isFocus) Positioned(
            bottom: keyboardHeight,
            child: Container(
              child: ListIcons(isDark: isDark, surroundTextSelection: surroundTextSelection, getImage: getImage)
            )
          )
        ]
      )
    );
  }
}