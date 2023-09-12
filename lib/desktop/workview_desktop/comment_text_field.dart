import 'dart:async';
import 'dart:convert';

// import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/desktop/components/drop_zone.dart';
import 'package:workcake/desktop/workview_desktop/list_icons_comment.dart';
import 'package:workcake/desktop/workview_desktop/render_markdown.dart';
import 'package:workcake/flutter_mentions.dart';
import 'package:workcake/models/models.dart';

class CommentTextField extends StatefulWidget {
  CommentTextField({
    Key? key,
    this.editComment,
    this.issue,
    this.onSubmitNewIssue,
    this.onCommentIssue,
    this.comment,
    this.onUpdateComment,
    required this.onChangeText,
    this.initialValue,
    this.isDescription,
  }) : super(key: key);

  final issue;
  final onSubmitNewIssue;
  final onCommentIssue;
  final editComment;
  final comment;
  final onUpdateComment;
  final Function? onChangeText;
  final initialValue;
  final isDescription;

  @override
  _CommentTextFieldState createState() => _CommentTextFieldState();
}

class _CommentTextFieldState extends State<CommentTextField> {
  var focusNode = FocusNode();
  bool onEdit = true;
  String text = "";
  final _textController = TextEditingController();
  var maxLine;
  int newLine = 1;
  bool isSelectAll = false;
  bool isShow = false;
  List<Map<String, dynamic>> suggestionMentions = [];
  GlobalKey<FlutterMentionsIssueState> key = GlobalKey<FlutterMentionsIssueState>();
  int spaceKey = 1;
  int lastCursorPosition = 0;

  @override
  void initState() { 
    super.initState();
    if (widget.initialValue != null) {
      text = widget.initialValue;
      _textController.text = parseMention(widget.initialValue);
    }
    getDataMentions();

    if (widget.editComment) {
      if (widget.comment != null) {
        this.setState(() {
          text = widget.comment["comment"];
        });

        _textController.text = parseMention(widget.comment["comment"]);
      } else {
        this.setState(() {
          text = parseMention(widget.issue["description"] ?? "");
        });
        _textController.text = parseMention(widget.initialValue != "" ? widget.initialValue : widget.issue["description"] ?? "");
      }
    }
    
  }

  parseMention(comment) {
    var parse = Provider.of<Messages>(context, listen: false).checkMentions(comment);
    if (parse["success"] == false) return comment;
    return Utils.getStringFromParse(parse["data"]);
  }

  handleEnterEvent() {
    List listText = text.split("\n");
    final selection = key.currentState!.controller!.selection;
    bool check = false;
    int stringLength = 0;
    var currentLine;
    int offset = selection.baseOffset;
    int newOffset = offset;
    RegExp exp = new RegExp(r"[0-9]{1,}.\s");

    for (var i = 0; i < listText.length; i++) {
      var line = listText[i];
      int lineLength = line.length;
      stringLength += lineLength;

      if (offset == stringLength + i) {
        currentLine = i;
        
        break;
      }
    }

    if (currentLine != null) {
      if (listText[currentLine].trim() == "- [ ]") {
        check = true;
        newOffset = offset - 6;
        listText[currentLine] = "";
      }

      if (listText[currentLine].trim() == "-") {
        check = true;
        newOffset = offset - 2;
        listText[currentLine] = "";
      } else {
        Iterable<RegExpMatch> matches = exp.allMatches(listText[currentLine]);
        
        if (matches.length > 0) {
          try {
            int subString = int.parse(listText[currentLine].substring(0, 1));

            if (listText[currentLine] == "$subString. ") {
              check = true;
              newOffset = offset - 3;
              listText[currentLine] = "";
            }
          } catch (e) {
            print("Parse substring to int in comment_text_field, ignore this if happen: ${e.toString()}");
          }
        }
      }

      if (listText[currentLine].length > 6) {
        if (listText[currentLine].substring(0, 7).contains("- [ ] ")) {
          check = true;
          newOffset = offset + 7;
          listText.insert(currentLine + 1, "- [ ] ");
        } else if (listText[currentLine].substring(0, 7).contains("- [x]")) {
         check = true;
          newOffset = offset + 7;
          listText.insert(currentLine + 1, "- [ ] ");
        } else if (listText[currentLine].substring(0, 2).contains("- ")) {
          check = true;
          newOffset = offset + 3;
          listText.insert(currentLine + 1, "- ");
        } else {
          Iterable<RegExpMatch> matches = exp.allMatches(listText[currentLine]);

          if (matches.length > 0) {
            int subString = int.parse(listText[currentLine].substring(0, 1));
            check = true;
            newOffset = offset + 4;
            listText.insert(currentLine + 1, "${subString + 1}. ");
          }
        }
      } else if (listText[currentLine].length > 2) {
        if (listText[currentLine].substring(0, 2).contains("- ")) {
          check = true;
          newOffset = offset + 3;
          listText.insert(currentLine + 1, "- ");
        } else {
          Iterable<RegExpMatch> matches = exp.allMatches(listText[currentLine]);

          if (matches.length > 0) {
            int subString = int.parse(listText[currentLine].substring(0, 1));
            check = true;
            newOffset = offset + 4;
            listText.insert(currentLine + 1, "${subString + 1}. ");
          }
        }
      }
    }

    if (check) {
      this.setState(() {
        text = listText.join("\n");
      });

      key.currentState!.controller!.value = key.currentState!.controller!.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(
          offset: newOffset,
        ),
      );
      
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }

  _surroundTextSelection(String left, String right, type) {
    if (key.currentState!.focusNode.hasFocus) {
      handleAction(left, right, type);
    } else {
      key.currentState!.focusNode.requestFocus();

      Timer(Duration(microseconds: 100), () => {
        handleAction(left, right, type)
      });
    }
  }

  handleAction(left, right, type) {
    final currentTextValue = key.currentState!.controller!.value.text;
    final selection = key.currentState!.controller!.selection;
    final middle = selection.textInside(currentTextValue);
    final before = selection.textBefore(currentTextValue);
    final after = selection.textAfter(currentTextValue);
    var newTextValue;
    var offset;

    if (type == "listDash" || type == "listNumber" || type == "check") {
      List listTextLine = middle.trim().split("\n").where((e) => e.trim() != "").toList();

      if (listTextLine.length > 1) {
        for (var i = 0; i < listTextLine.length; i++) {
          if (listTextLine[i].trim() != "") {
            if (type == "listDash") {
              listTextLine[i] = "- " + listTextLine[i]; 
            } else if (type == "listNumber") {
              listTextLine[i] = "${(i+1)}. " + listTextLine[i]; 
            } else {
              listTextLine[i] = "- [ ] " + listTextLine[i]; 
            }
          }
        }

        newTextValue = before + listTextLine.join("\n") + after; 
        offset = newTextValue.length;
      } else {
        newTextValue = (before.trim() != "" ? before + '\n' : "") + '$left$middle$right' + (after.trim() != "" ? '\n' + after : "");
        offset = selection.baseOffset + left.length + middle.length + (before.trim() == "" ? 0 : 1);
      }
    } else {
      newTextValue = before + '$left$middle$right' + after;
      offset = selection.baseOffset + left.length + middle.length;
    }

    key.currentState!.controller!.value = key.currentState!.controller!.value.copyWith(
      text: newTextValue,
      selection: TextSelection.collapsed(
        offset: offset,
      ),
    );

    applyEditToPreview();
  }

  checkConditions(String string, String nextString) {
    bool check = true;

    if (nextString.length > 0) {
      if (string.contains("- [ ]") || nextString.contains("- [ ]")) {
        check = false;
      } else if (nextString[0] == "-") {
        check = false;
      } else if (string.trim() == "" || nextString.trim() == "") {
        check = false;
      } else if (nextString[0] == "." || string.contains(". ")) {
        check = false;
      }
    }
  
    return check;
  }

  handleKeyEvent(event) {
    var keyDown = (event.runtimeType.toString() == "RawKeyDownEvent");

    if (keyDown) { 
      var keyPresed = event.logicalKey.debugName == "Space";

      if (keyPresed) {
        this.setState(() {
          spaceKey = spaceKey + 1;
        }); 
      } else {
        this.setState(() {
          spaceKey = 0;
        });
      }
    }
  }

  applyEditToPreview() {
    if (key.currentState == null) return;
    final selection = key.currentState!.controller!.selection;
    String currentTextValue = key.currentState!.controller!.text;
    if (currentTextValue.length > 2) {
      if (spaceKey > 1 && lastCursorPosition + 1 == selection.baseOffset && currentTextValue.length >= 2) {
        if (currentTextValue.substring(selection.baseOffset - 2, selection.baseOffset - 1) == ".") {
          currentTextValue = currentTextValue.replaceRange(selection.baseOffset - 2, selection.baseOffset - 1, " ");

          key.currentState!.controller!.value = key.currentState!.controller!.value.copyWith(
            text: currentTextValue
          );
        } 
      }
    }

    this.setState(() {
      lastCursorPosition = selection.baseOffset;
      text = currentTextValue;
    });

    if (widget.onChangeText != null) {
      _textController.text = currentTextValue;
      widget.onChangeText!(currentTextValue);
    }
  }

  handleUpdateIssues() {
    if (widget.issue == null) {
      widget.onSubmitNewIssue(key.currentState!.controller!.markupText);
    } else if (widget.editComment) {
      if (widget.comment != null) {
        widget.onUpdateComment(widget.comment, key.currentState!.controller!.markupText);
      } else {
        widget.onUpdateComment(widget.issue["title"], key.currentState!.controller!.markupText, false);
      }
    } else {
      widget.onCommentIssue(key.currentState!.controller!.markupText);
      key.currentState!.controller!.clear();
    }
  }

  onChangeCheckBox(value, elText, commentId, indexCheckbox) {
    final auth = Provider.of<Auth>(context, listen: false);
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
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
        "workspace_id": currentWorkspace["id"],
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

  openFileSelector() async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    List resultList = [];
    List text = [];

    final currentTextValue = key.currentState!.controller!.text;
    final selection = key.currentState!.controller!.selection;
    final before = selection.baseOffset == -1 ? "" : selection.textBefore(currentTextValue);
    final after = selection.baseOffset == -1 ? "" : selection.textAfter(currentTextValue);
    
    try {
      var myMultipleFiles = await Utils.openFilePicker([
        XTypeGroup(
          extensions: ['jpg', 'jpeg', 'gif', 'png'],
        )
      ]);
      for (var e in myMultipleFiles) {
        Map newFile = {
          "filename": e["name"],
          "path":  base64.encode(e["file"])
        };
        resultList.add(newFile);
        text.add("\n\n![Uploading ${e["name"]}...]()");
      }

      String newText = before + text.join("\n") + after;
      var offset = selection.baseOffset;

      key.currentState!.controller!.value = key.currentState!.controller!.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
          offset: offset + newText.length
        ),
      );

      for (var file in resultList) {
        final url = Utils.apiUrl + 'workspaces/${currentWorkspace["id"]}/contents?token=$token';
        final body = {
          "file": file,
          "content_type": "image",
          "mime_type": "image"
        };

        // final response = await Dio(url, headers: Utils.headers, body: json.encode(body));
        final response = await Dio().post(url, data: json.encode(body));
        final responseData = response.data;
        final fileName = responseData["file_name"];
        int index =  key.currentState!.controller!.text.indexOf(fileName);

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
      StreamDropzone.instance.initDrop();
    } on Exception catch (e) {
      print("$e Cancel");
    }
  }

  onPasteImage(listFiles) async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    List resultList = [];
    List text = [];

    final currentTextValue = key.currentState!.controller!.text;
    final selection = key.currentState!.controller!.selection;
    final before = selection.baseOffset == -1 ? "" : selection.textBefore(currentTextValue);
    final after = selection.baseOffset == -1 ? "" : selection.textAfter(currentTextValue);
    
    for (var e in listFiles) {
      var existed = resultList.indexWhere((element) => element["path"] == e["path"]);
      if(existed != -1) continue;
      Map newFile = {
        "filename": e["name"],
        "mime_type": "image",
        "path":  base64.encode(e["file"])
      };

      resultList.add(newFile);
      text.add("\n\n![Uploading ${e["name"]}...]()");
    }

    String newText = before + text.join("\n") + after;
    var offset = selection.baseOffset;

    key.currentState!.controller!.value = key.currentState!.controller!.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: offset + newText.length
      ),
    );

    for (var file in resultList) {
      final url = Utils.apiUrl + 'workspaces/${currentWorkspace["id"]}/contents?token=$token';
      final body = {
        "file": file,
        "content_type": "image",
        "mime_type": "image"
      };

      // final response = await http.post(url, headers: Utils.headers, body: json.encode(body));
      Response response = await Dio().post(url, data: json.encode(body));
      final responseData = response.data;
      final fileName = responseData["file_name"];
      int index =  key.currentState!.controller!.text.indexOf(fileName);

      if (index != -1) {
        Timer(Duration(microseconds: 300), () {
          var first = index + fileName.length + 5;
          var last = index + fileName.length + 6;
          var text = key.currentState!.controller!.text.replaceRange(int.parse(first.toString()), int.parse(last.toString()), responseData["content_url"] + ")");
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
  }
  
  @override
  Widget build(BuildContext context) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      height: widget.issue == null ? 525 : 350,
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9)),
        borderRadius: BorderRadius.circular(4),
        color: isDark ? Color(0xff1F2933) : Colors.white
      ),
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: (MediaQuery.of(context).size.width)*(3/4),
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  height: 32,
                  width: 268,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3)
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: onEdit ? (isDark ? Color(0xFF323F4B) : Color(0xffE4E7EB)) : (isDark ? Color(0xff1F2933) : Colors.white),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            widget.isDescription ? "Description" : "Edit comment",
                            style: TextStyle(
                              color: onEdit ? (!isDark ? Color.fromRGBO(0, 0, 0, 0.65) : Colors.white70) : (!isDark ? Color.fromRGBO(0, 0, 0, 0.55) : Colors.grey[400]),
                              fontWeight: onEdit ? FontWeight.w500 : FontWeight.w400
                            )
                          ),
                        ),
                        onTap: () {
                          this.setState(() {
                            onEdit = true;
                          });
                        },
                      ),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                            color: !onEdit ? (isDark ? Color(0xFF323F4B) : Color(0xffE4E7EB)) : (isDark ? Color(0xff1F2933) : Colors.white),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            widget.isDescription ? "Preview" : "Preview Comment",
                            style: TextStyle(
                              color: !onEdit ? (!isDark ? Color.fromRGBO(0, 0, 0, 0.65) : Colors.white70) : (!isDark ? Color.fromRGBO(0, 0, 0, 0.55) : Colors.grey[400]),
                              fontWeight: !onEdit ? FontWeight.w500 : FontWeight.w400
                            )
                          )
                        ),
                        onTap: () {
                          if (onEdit) {
                            this.setState(() {
                              onEdit = false;
                            });
                          }
                        },
                      )
                    ]
                  ),
                ),
                !onEdit ? Container(height: 40, width: 280) : ListIcons(surroundTextSelection: _surroundTextSelection, isDark: isDark),
              ],
            ),
          ),
          SizedBox(height: 10),
          !onEdit ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9)),
              color: Colors.transparent
            ),
            height: widget.issue == null ? 439 : 260,
            child: RenderMarkdown(
              stringData: Utils.parseComment(text, false),
              onChangeCheckBox: onChangeCheckBox,
            )
          ) : Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.transparent
              ),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: DropZone(
                      stream: StreamDropzone.instance.dropped,
                      initialData: [],
                      builder: (context, files){
                        List listFiles = [];
                        if (files.data.length > 0) {
                          for (var item in files.data) {
                            int index = listFiles.indexWhere((e) => e["path"] == item["path"]);
                              if (index == -1) {
                                listFiles.add(item);
                              }
                          }
                        }
                        if (listFiles.length > 0) {
                          if (key.currentState!.focusNode.hasFocus) {
                            onPasteImage(listFiles);
                          }
                          else{
                            key.currentState!.focusNode.requestFocus();
                            key.currentState!.controller!.value = key.currentState!.controller!.value.copyWith(
                              text: key.currentState!.controller!.text,
                              selection: TextSelection.collapsed(offset: key.currentState!.controller!.text.length)
                            );
                            onPasteImage(listFiles);
                          }
                       
                          listFiles = [];
                          StreamDropzone.instance.initDrop();
                        }

                        return Container(
                          child: RawKeyboardListener(
                            focusNode: focusNode,
                            onKey: (event) async {
                              if (event.logicalKey.debugName == "Space") {
                                await handleKeyEvent(event);
                              } else {
                                if (spaceKey != 0) {
                                  this.setState(() {
                                    spaceKey = 0;
                                  });
                                }
                              }
                            },
                            child: FlutterMentionsIssue(
                              parseMention: Provider.of<Messages>(context, listen: false).checkMentions,
                              style: TextStyle(
                                fontSize: 15.5,
                                color: auth.theme == ThemeType.DARK ? Colors.grey[300] : Colors.grey[800]
                              ),
                              controller: _textController,
                              key: key,
                              isIssues: true,
                              cursorColor: auth.theme == ThemeType.DARK ? Colors.grey[400] : Colors.black87,
                              onChanged: (value) async {
                                Timer(Duration(milliseconds: 0), () {
                                  applyEditToPreview();
                                });
                              },
                              isDark: auth.theme == ThemeType.DARK,
                              islastEdited: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.only(left: 10, bottom: 10, top: 16),
                                hintText: "Add a more detailed... ",
                                hintStyle: TextStyle(
                                  color: isDark ? Color(0xFFD9D9D9) : Color.fromRGBO(0, 0, 0, 0.35),
                                  fontSize: 14, fontWeight: FontWeight.w300
                                )
                              ),
                              onSearchChanged: (trigger,value) {
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
                                  style: TextStyle(
                                    color: Colors.lightBlue,
                                  ),
                                  data: suggestionMentions,
                                  matchAll: true,
                                ),
                              ]
                            ),
                          )
                        );
                      }
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    // padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 32,
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(39, 174, 96, 0.2)),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                    side: BorderSide(color: Color(0xff27AE60))
                                  )),
                                  padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(horizontal: 20)
                                  )
                                ),
                                onPressed: () {  
                                  if (key.currentState!.focusNode.hasFocus) {
                                    openFileSelector();
                                  } else {
                                    key.currentState!.focusNode.requestFocus();

                                    Timer(Duration(microseconds: 100), () => {
                                      openFileSelector()
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text("Upload", style: TextStyle(color: Color(0xff27AE60), fontWeight: FontWeight.w400)),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Text("Attach image to comment.", style: TextStyle(color: isDark ? Color(0xffD9D9D9) : Colors.black45))
                          ],
                        ),
                        Row(
                          children: [
                            if (widget.issue != null) Container(
                              height: 32,
                              child: TextButton(
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 20)),
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                    side: widget.issue["is_closed"] ? BorderSide(color: Color(0xff9AA5B1)) :BorderSide(color: Color(0xffFF7875))
                                  )),
                                  backgroundColor: MaterialStateProperty.all(isDark ? Colors.transparent : (widget.issue["is_closed"] ? Color(0xffF5F7FA) : Color(0xffFFF1F0))),
                                ),
                                onPressed: () async {
                                  if (widget.editComment) {
                                    if (widget.comment != null) {
                                      widget.onUpdateComment(widget.comment, widget.comment["comment"]);
                                    } else {
                                      widget.onUpdateComment(widget.issue["title"], widget.issue["description"], true);
                                    }
                                  } else {
                                    var text = (key.currentState != null && key.currentState!.controller!.value.text != "") ? key.currentState!.controller!.value.text : "";

                                    if (text != "") {
                                      var result = Provider.of<Messages>(context, listen: false).checkMentions(text);
                                      var listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];

                                      var dataComment = {
                                        "comment": text,
                                        "channel_id":  currentChannel["id"],
                                        "workspace_id": currentWorkspace["id"],
                                        "user_id": auth.userId,
                                        "from_issue_id": widget.issue["id"],
                                        "list_mentions_old": [],
                                        "list_mentions_new": listMentionsNew
                                      };
                                      await Provider.of<Channels>(context, listen: false).submitComment(token, dataComment);
                                      key.currentState!.controller!.clear();
                                    }
                                    final issueClosedTab = Provider.of<Work>(context, listen: false).issueClosedTab;
                                    await Provider.of<Channels>(context, listen: false).closeIssue(token, currentWorkspace["id"], currentChannel["id"], widget.issue["id"], !widget.issue["is_closed"], issueClosedTab);
                                  }
                                }, 
                                child: !widget.issue["is_closed"] ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: 3),
                                      child: !widget.editComment ? Icon(CupertinoIcons.exclamationmark_circle, size: 17, color: Color(0xffFF7875)) : Container(),
                                    ),
                                    SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        widget.editComment ? "Cancel" : 
                                        (key.currentState != null && key.currentState!.controller!.value.text != "") ?
                                        "Close with comment" : "Close issue",
                                        style: TextStyle(color: Color(0xffFF7875), fontWeight: FontWeight.w400)
                                      ),
                                    ),
                                  ],
                                ) : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    "Reopen issue",
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Color(0xff9AA5B1),
                                      fontWeight: FontWeight.w400
                                    )
                                  ),
                                ),
                              ),
                            ),
                            widget.issue != null ? Container() : Container(
                              height: 32,
                              child: TextButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                    side: BorderSide(color: Color(0xffFF7875))
                                  )),
                                  backgroundColor: MaterialStateProperty.all(isDark ? Colors.transparent : Color(0xffFFF1F0)),
                                ),
                                
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text("Cancel", style: TextStyle(color: Color(0xffFF7875), fontWeight: FontWeight.w400)),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              height: 32,
                              child: TextButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  )),
                                  backgroundColor: MaterialStateProperty.all(isDark ? Color(0xFF19DFCB) : Color(0xff2A5298)),
                                ),
                                onPressed: () {
                                  handleUpdateIssues();
                                }, 
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  child: Text(
                                    widget.editComment ? "Update comment" : widget.issue != null ? "Comment" : "Submit new issue",
                                    style: TextStyle(
                                      color: isDark ? Color.fromRGBO(0, 0, 0, 0.75) : Colors.white,
                                      fontWeight: FontWeight.w400
                                    )
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  )
                ]
              )
            ),
          )
        ]
      ),
    );
  }
}