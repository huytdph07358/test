import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/flutter_mentions.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/work_screen/list_icons.dart';

import '../../../generated/l10n.dart';

class EditDescription extends StatefulWidget {
  const EditDescription({
    Key? key,
    required this.description,
    this.onEditDescription,
    this.text,
  }) : super(key: key);

  final String description;
  final onEditDescription;
  final text;

  @override
  State<EditDescription> createState() => _EditDescriptionState();
}

class _EditDescriptionState extends State<EditDescription> {
  TextEditingController descriptionController = TextEditingController();
  GlobalKey<FlutterMentionsIssueState> key = GlobalKey<FlutterMentionsIssueState>();
  bool editDescription = false;
  List<Map<String, dynamic>> suggestionMentions = [];

  @override
  void initState() {
    descriptionController.text = widget.description;
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    try {
      super.didUpdateWidget(oldWidget);
      descriptionController.text = widget.description;
    } catch (e) {
    }
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return  Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Color(0xffA6A6A6) : Color(0xff828282),
            width: 0.25,
          ),
          bottom: BorderSide(
            color: isDark ? Color(0xffA6A6A6) : Color(0xff828282),
            width: 0.25,
          ),
        ),
      ),
      child: Wrap(
        children: [
          Container(
            // height: 44,
            width: deviceWidth,
            color: isDark ? Color(0xff4C4C4C) : Color(0xffffffff),
            padding: EdgeInsets.symmetric(vertical: 13, horizontal: 18),
            child: Text(S.current.description, style: TextStyle(fontSize: 14))
          ),
          InkWell(
            onTap: () {
             showModalBottomSheet(
                isScrollControlled: true,
                enableDrag: true,
                context: context,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                builder: (BuildContext context) {
                  final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                  return Stack(
                    children: [
                      Container(
                        // height: (MediaQuery.of(context).size.height*85) - keyboardHeight - (keyboardHeight > 0 ? 106 : 50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12)
                        ),
                        height: deviceHeight*.9,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: 28, left: 16, right: 16),
                              height: 44,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () { Navigator.pop(context); },
                                    child: Text(S.current.cancel, style: TextStyle(fontSize: 16, color: Color(0xffFAAD14)))),
                                  Text(S.current.addDescription, style: TextStyle(fontSize: 16)),
                                  InkWell(
                                    onTap: () {
                                      widget.onEditDescription(key.currentState!.controller!.markupText);
                                      Navigator.pop(context);
                                    },
                                    child: Text(S.current.confirm, style: TextStyle(fontSize: 16, color: Color(0xffFAAD14))))
                                ]
                              )
                            ),
                            Divider(height: 36),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Container(
                                  height: deviceHeight,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    child: FlutterMentionsIssue(
                                      controller: descriptionController,
                                      parseMention: Provider.of<Messages>(context, listen: false).checkMentions,
                                      textCapitalization: TextCapitalization.sentences,
                                      cursorColor: isDark ? Colors.grey[400]! : Colors.black87,
                                      key: key,
                                      autofocus: true,
                                      isIssues: true,
                                      afterFirstFrame: (){},
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
                                      // textInputAction: TextInputAction.done,
                                      islastEdited: false,
                                      suggestionListHeight: 200,
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
                                  ),
                                ),
                              ),
                            ),
                          ]
                        )
                      ),
                      if (keyboardHeight > 0) Positioned(
                        bottom: keyboardHeight,
                        child: Container(
                          child: ListIcons(isDark: isDark, surroundTextSelection: surroundTextSelection, getImage: getImage)
                        )
                      )
                    ],
                  );
                }
              );
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 300
              ),
              child: SingleChildScrollView(
                child: Container(
                  width: deviceWidth,
                  color: isDark ? Color(0xff3D3D3D) : Color(0xffF8F8F8),
                  padding: EdgeInsets.symmetric(vertical: 13, horizontal: 18),
                  child: Text(widget.description.trim() != "" ? widget.description : S.current.addMoreDetailed, style: TextStyle(fontSize: 14, color: isDark ? Color(0xffC9C9C9):Color(0xff5E5E5E)))
                ),
              ),
            )
          )
        ]
      ),
    );
  }
}