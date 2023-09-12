import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';

import '../../../common/palette.dart';
import '../../common/utils.dart';

class CreatePollDialog extends StatefulWidget {
  const CreatePollDialog({ 
    Key? key
  }) : super(key: key);

  @override
  State<CreatePollDialog> createState() => _CreatePollDialogState();
}

class _CreatePollDialogState extends State<CreatePollDialog> {
  TextEditingController _titleController = TextEditingController();
  List options = [{'id': 0, 'title': ''}];
  String title = "";
  FocusScopeNode node = FocusScopeNode();
  FocusNode titleFocus = FocusNode();
  int? currentOptionId;

  createPollMessage() {
    final auth = Provider.of<Auth>(context, listen: false);
    final user = Provider.of<User>(context, listen: false);
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    

    List attachments = [{
      'type': 'poll',
      'title': title,
      'options': options,
      'results': []
    }];

    var dataMessage  = {
      "channel_thread_id": null,
      "key": Utils.getRandomString(20),
      "message": "",
      "attachments": attachments,
      "channel_id":  currentChannel["id"],
      "workspace_id": currentWorkspace["id"],
      "count_child": 0,
      "user_id": auth.userId,
      "user": user.currentUser["full_name"] ?? "",
      "avatar_url": user.currentUser["avatar_url"] ?? "",
      "full_name": user.currentUser["full_name"] ?? "",
      "inserted_at": DateTime.now().add(new Duration(hours: -7)).toIso8601String(),
      "is_system_message": true,
      "isDesktop": true
    };

    Provider.of<Messages>(context, listen: false).sendMessageWithImage([], dataMessage, auth.token);
    Navigator.pop(context);
  }

  int generateOptionID(){
    int newID = 0;
    List listID = options.map((e) => e["id"]).toList(); 
    while(listID.contains(newID)){
      newID += 1;
    }
    return newID;
  }

  Future<dynamic> validateWarning(BuildContext context, bool isDark, String warningContent) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: isDark ? Color(0xff5E5E5E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              child: Container(
                width: 210,
                height: 130,
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Text("$warningContent"),
                    SizedBox(height: 26),
                    TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: Text("Close"),
                    ),
                  ],
                )
              )
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    var screenSize= MediaQuery.of(context).size;
    var keyboardHeight  = MediaQuery.of(context).viewInsets.bottom;

    return FocusScope(
      node: node,
      child: Container (
        decoration: BoxDecoration(
          color: isDark ? Palette.backgroundRightSiderDark : Color(0xfff8f8f8),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            topLeft: Radius.circular(8),
          ),
        ),
        height: screenSize.height * 0.85,
        width: screenSize.width,
        child: Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? Color(0xff5E5E5) : Color(0xfff3f3f3),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  topLeft: Radius.circular(8),
                ),
              ),
              width: screenSize.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    child: Text(S.current.createPoll, style: TextStyle(color: isDark ? Colors.white : Palette.defaultTextLight, fontSize: 14, fontWeight: FontWeight.w500))
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                color: isDark ? Palette.backgroundRightSiderDark : Colors.white,
              ),
              child: Column(
                children: [
                  Container(
                    width: screenSize.width,
                    margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.vertical,
                      children: [
                        Container(
                          width: screenSize.width - 24*2,
                          margin: EdgeInsets.only(top: 4, bottom: 12),
                          child: CupertinoTextField(
                            controller: _titleController,
                            focusNode: titleFocus,
                            autofocus: true,
                            textInputAction: TextInputAction.next,
                            onChanged: (e) {
                              setState(() { title = e; });
                            },
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            placeholder: S.current.whatYourPollAbout,
                            placeholderStyle: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Color(0xff828282)),
                            style: TextStyle(fontSize: 13.5, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Utils.checkedTypeEmpty(_titleController.text.trim())
                                ? isDark ? Colors.grey[600]! : Color(0xffdbdbdb)
                                : Colors.red),
                            ),
                          )
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: keyboardHeight == 0 ? screenSize.height * 0.5 : screenSize.height * 0.25,
                          ),
                          width: screenSize.width - 24*2,
                          margin: EdgeInsets.only(top: 4),
                          child: SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(12,0,12,0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDark ? Colors.grey[600]! : Color(0xffdbdbdb),
                                ),
                                color: isDark ? Color(0xff353535) : Color(0xfff8f8f8),
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: Column(
                                children: options.map<Widget>((option) {
                                  return OptionPoll(
                                    option: option,
                                    onChanged: (String value) {
                                      int index = options.indexWhere((e) => e["id"] == option["id"]);
                                      options[index]['title'] = value;
                                    },
                                    onRemovedOption: () {
                                      int index = options.indexWhere((e) => e['id'] == option['id']);
                                      setState(() => options.removeAt(index));
                                    },
                                    onFirstFrameDone: () {
                                      if(currentOptionId != null && !titleFocus.hasFocus) {
                                        node.nextFocus();
                                      }
                                    },
                                    onFocusChange: (bool value) {
                                      if(value) {
                                        currentOptionId = option['id'];
                                      } else {
                                        currentOptionId = null;
                                      }
                                    }
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        )
                      ]
                    )
                  ),
                  InkWell(
                    canRequestFocus: false,
                    onTap: () {
                      setState(() {
                        options.add({'id': generateOptionID(), 'title': ""});
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isDark ? Color(0xff5e5e5e) : Color(0xfff8f8f8)
                      ),
                      width: screenSize.width - 24*2,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      margin: EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.plusCircle, size: 20.0, color: isDark ? Palette.calendulaGold : Colors.blue),
                          SizedBox(width: 8),
                          Text(S.current.addAnOption, style: TextStyle(color: isDark ? Palette.calendulaGold : Colors.blue)),
                        ],
                      )
                    )
                  ),
                  Container(width: screenSize.width, color: isDark ? Color(0xff5e5e5e) : Color(0xffdbdbdb), height: 1),
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 24),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.redAccent
                                ),
                                borderRadius: BorderRadius.circular(4),
                                color: isDark ? Color(0xff3D3D3D) : Colors.white
                              ),
                              height: 32,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                canRequestFocus: false,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.redAccent, width: 0.5
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    color: isDark ? const Color(0xff3D3D3D) : Colors.white
                                  ),
                                  child: Text(
                                    S.current.cancel,
                                    style: const TextStyle(
                                      color: Colors.redAccent, fontSize: 14
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ),
                          ),
                          SizedBox(width: 12),
                          Flexible(
                            fit: FlexFit.tight,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.blueAccent
                              ),
                              height: 32,
                              child: InkWell(
                                onTap: () {
                                var _index = options.indexWhere((e) => !Utils.checkedTypeEmpty(e['title'].trim()));
                                if (_index == -1) {
                                  if (Utils.checkedTypeEmpty(title.trim()) && options.length != 0) {
                                    createPollMessage();
                                  } else {
                                    validateWarning(context, isDark, "A poll needs a title and options");
                                  }
                          
                                } else {
                                  validateWarning(context, isDark, "Cannot leave an option blank");
                                }
                              },
                              canRequestFocus: false,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 7),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.blueAccent
                                ),
                                width: 212, height: 32,
                                child:Text(
                                  S.current.createPoll, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                            ),
                          ),
                          SizedBox(width: 24),
                        ]
                      )
                    ),
                  )
                ],
              ),
            ),
          ]
        )
      ),
    );
  }
}


class OptionPoll extends StatefulWidget {
  final Map option;
  final ValueChanged<String> onChanged;
  final Function() onRemovedOption;
  final ValueChanged<bool> onFocusChange;
  final Function onFirstFrameDone;

  const OptionPoll({
    Key? key,
    required this.option,
    required this.onChanged,
    required this.onRemovedOption,
    required this.onFocusChange,
    required this.onFirstFrameDone
  }) : super(key: key);


  @override
  _OptionPollState createState() => _OptionPollState();
}

class _OptionPollState extends State<OptionPoll> {
  Map get option => widget.option;
  TextEditingController _optionController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFirstFrameDone();
    });

    focusNode.addListener(_handleFocusChanged);
    _optionController = TextEditingController(text: option['title']);
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.option.toString() != widget.option.toString()) {
      _optionController = TextEditingController(text: option['title']);
    }
  }

  void _handleFocusChanged() {
    widget.onFocusChange.call(focusNode.hasFocus);
  }

  @override
  void dispose() {
    focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xff4C4C4C) : const Color(0xffdbdbdb),
            width: 1
          )
        )
      ),
      child: Container(
        width: 468-16*4,
        child: CupertinoTextField(
          key: Key(option["id"].toString()),
          autofocus: true,
          controller: _optionController,
          focusNode: focusNode,
          onChanged: widget.onChanged,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          placeholder: S.current.option,
          placeholderStyle: const TextStyle(
            fontSize: 14,
            color:Colors.red),
          style: TextStyle(fontSize: 14, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xff353535) : const Color(0xfff8f8f8),
          ),
          suffix: InkWell(
            canRequestFocus: false,
            onTap: () {
              widget.onRemovedOption();
            },
            child: Icon(PhosphorIcons.xCircle, color: isDark ? Colors.grey[400] : const Color(0xff5e5e5e), size: 18)
          )
        )
      )
    );
  }
}