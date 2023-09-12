// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/generated/l10n.dart';
import 'dart:io' show Platform;
import 'package:workcake/models/models.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/bottom_sheet_server.dart';
class CustomDialogNew extends StatefulWidget {
  final title;
  final content;
  final cancelText;
  Function()? onCancelClick;
  final confirmText;
  Function()? onConfirmClick;
  bool hideActionButton;
  final option;
  bool quickCancelButton;
  Widget? customWidget;

  CustomDialogNew({ 
    Key? key,
    @required this.title,
    @required this.content,
    this.cancelText,
    this.onCancelClick,
    this.quickCancelButton = false,
    this.confirmText,
    this.onConfirmClick,
    this.hideActionButton = false,
    this.option = Option.alert,
    this.customWidget,
  }) : super(key: key);

  @override
  _CustomDialogNewState createState() => _CustomDialogNewState();
}

enum Option {
  alert, textField, custom
}
class _CustomDialogNewState extends State<CustomDialogNew> {
  bool isErr = false;
  @override
  void initState() {
    if(widget.onConfirmClick != null && widget.confirmText == null) {
      print("Asset Error, You need to add title for confirm button");
      setState(() {
        isErr = true;
      });
    }
    if(widget.onCancelClick != null && widget.cancelText == null) {
      print("Asset Error, You need to add title for cancel button");
      setState(() {
        isErr = true;
      });
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if(widget.option == Option.alert) {
      return alertDialog();
    }
    else if(widget.option == Option.textField) {
      return Container(
        child: widget.customWidget,
      );
    }
    else {
      return Container();
    }
  }

  Widget alertDialog () {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    return isErr ? Container() : Container(
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 300,
          height: 196,
          child: Column(
            children: [
              //Title
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff5E5E5E) : Color(0xffFAFAFA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                padding: EdgeInsets.only(top: 10,bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${widget.title}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18),
              //Body
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            margin: EdgeInsets.only(bottom: 20),
                            child: Text(
                              "${widget.content}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if(!widget.hideActionButton) Divider(),
                    if(!widget.hideActionButton) Container(
                      width: MediaQuery.of(context).size.width,
                      child: Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children: [
                          if(widget.cancelText == null && widget.confirmText == null) InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Text("OK", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700, fontSize: 14)),
                            ),
                          ),
                          if(widget.confirmText != null) Padding(
                            padding: const EdgeInsets.only(bottom: 10, top: 10,left: 15,right: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: widget.onCancelClick ?? () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.red,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text("${widget.cancelText ?? S.current.cancel}", style: TextStyle(color: Colors.red, fontSize: 14))
                                    )
                                  ),
                                ),
                                SizedBox(width: 14,),
                                Expanded(
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: widget.onConfirmClick ?? () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Color(0xff1890FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // if(widget.cancelText != null || widget.quickCancelButton) InkWell(
                          //   splashColor: Colors.transparent,
                          //   highlightColor: Colors.transparent,
                          //   onTap: widget.onCancelClick ?? () {
                          //     Navigator.pop(context);
                          //   },
                          //   child: Container(
                          //     margin: EdgeInsets.only(bottom: 12),
                          //     child: Text("${widget.cancelText ?? "Cancel"}", style: TextStyle(color: Colors.red, fontSize: 18)),
                          //   ),
                          // )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          // color: Colors.blue,
        ),
      ),
    ); 
  }
}



class ChannelNameDialog extends StatefulWidget {
  final title;
  final string;
  final onSaveString;
  final type;

  ChannelNameDialog({key, this.title, this.string, this.onSaveString, this.type}) : super(key: key);

  @override
  _ChannelNameDialogState createState() => _ChannelNameDialogState();
}

class _ChannelNameDialogState extends State<ChannelNameDialog> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState(){
    super.initState();
    _controller.text = widget.string;
    _controller.addListener(listenValueName);
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  void listenValueName() {
    if (_controller.text.contains(' ')) {
      List _splitCurrentSpace = _controller.text.split(" ");
      int _currentCaretPosition = _splitCurrentSpace[0].length +1;  
      final formatName = _controller.text.replaceAll(' ', '-');
      _controller.value = TextEditingValue(
        text: formatName,
        selection: TextSelection.fromPosition(
          TextPosition(offset: _currentCaretPosition),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    final deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      child: AlertDialog(
        insetPadding: EdgeInsets.all(20),
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: isDark ? Color(0xFF3D3D3D) : Color(0xffFFFFFF),
        content: Container(
          height: 220,
          width: (Platform.isAndroid || Platform.isIOS) ? deviceWidth : 300,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 16, bottom: 16,left: 16),
                      margin: EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14, color: isDark
                                  ? Colors.grey[300]
                                  : Colors.grey[700]))
                        ]
                      ),
                      decoration:  BoxDecoration(
                        color: isDark ? Color(0xff5E5E5E) : Color(0xffFAFAFA),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                        ),
                      ),
                    ),
                  ]
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                child: TextField(
                  maxLines: 2,
                  autofocus: true,
                  controller: _controller,
                  decoration: InputDecoration(
                    fillColor: isDark? Color(0xFF2E2E2E): Color(0xFFFAFAFA),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: isDark? Color(0xff5E5E5E): Color(0xffC9C9C9),style: BorderStyle.solid,width: 1)),
                    enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: isDark? Color(0xff5E5E5E): Color(0xffC9C9C9),style: BorderStyle.solid, width: 1)),
                    focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all( Radius.circular(2)),
                    borderSide: BorderSide(color: isDark? Color(0xff5E5E5E): Color(0xffC9C9C9),style: BorderStyle.solid,width: 1)),
                  )
                ),
              ),
              Container(
                height: 1,
                margin: EdgeInsets.only(top: 16),
                decoration:  BoxDecoration(border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey))),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15 , top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          Navigator.of(context, rootNavigator: true).pop("Discard");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(left: 12,right: 4,top: 2),
                          padding: EdgeInsets.symmetric(vertical: 10.5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xffEB5757),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(S.current.cancel, style: TextStyle(fontSize: 12, color: Color(0xffEB5757),)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 12,right: 4),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: MediaQuery.of(context).size.width,
                        child: TextButton(
                          // color: Utils.getPrimaryColor(),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color(0xff1890FF))
                          ),
                          onPressed: () {
                            if(widget.type == "title kanban") Navigator.pop(context);
                            widget.onSaveString(_controller.text);
                          },
                          child: Text(S.current.save, style: TextStyle(fontSize: 12, color: Colors.white))
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ),
        ),
      ),
    );
  }
}


class CustomDialog extends StatefulWidget {
  final title;
  final textDisplay;
  final onSaveString;
  final action;

  CustomDialog({
    Key? key,
    this.title,
    this.textDisplay,
    this.onSaveString,
    this.action,
  }) : super(key: key);
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  TextEditingController _controller = TextEditingController();
  @override
  void initState(){
    super.initState();
    if(widget.action != "Join or create a workspace"){
      _controller.text = widget.textDisplay;
    }
  }
  showBottomSheet(context, action) {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext context) {
        return BottomSheetWorkspace(action: action);
      }
    );
  }
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        backgroundColor: isDark ? Color(0xFF3D3D3D) : Color(0xffFFFFFF),
        content: Container(
          height: widget.action == "Join or create a workspace" ? 274 : 220,
          width: (Platform.isAndroid || Platform.isIOS) ? deviceWidth : 300,
          child: widget.action == "Join or create a workspace"
          //Dialog Create or Join Workspace
          ? Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  S.current.createWorkspace, 
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white70 : Color(0xff6B6B6B),
                    fontWeight: FontWeight.w500
                  )
                ),
                SizedBox(height: 12),
                Text(
                  S.of(context).descCreateWorkspace, 
                  style: TextStyle(
                    color: isDark ? Colors.white : Color(0xff6B6B6B),
                    fontSize: 14,
                    fontWeight: FontWeight.w200
                  ), 
                  textAlign: TextAlign.center
                ),
                SizedBox(height: 12),
                Container(
                  width: 300,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Utils.getPrimaryColor())
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showBottomSheet(context, "Create workspace");
                    }, 
                    child: Text(
                      S.current.createWorkspace,
                      style: TextStyle(color: Colors.white)
                    )
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  S.current.haveAnInviteAlready,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Color(0xff6B6B6B),
                    fontSize: 16,
                    fontWeight: FontWeight.w400
                  )
                ),
                SizedBox(height: 12),
                Container(
                  width: 300,
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color(0xff262626)
                      )
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showBottomSheet(context, "Join workspace");
                    }, 
                    child: Text(
                      S.current.joinWorkspace,
                      style: TextStyle(color: Colors.white)
                    )
                  ),
                ),
              ],
            ),
          ) 

          //Dialog Input
          : Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff5E5E5E) : Color(0xffFAFAFA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              height: 1.57,
                              fontSize: 15, color: isDark
                                  ? Color(0xffFFFFFF)
                                  : Color(0xff3D3D3D)))
                        ]
                      ),
                      decoration:  BoxDecoration(border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey))),
                    ),
                  ]
                ),
              ),
              SizedBox(height: 16,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  autofocus: true,
                  controller: _controller,
                  maxLines: 2, minLines: 1,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark? Color(0xFF2E2E2E): Color(0xFFFAFAFA),
                    contentPadding:EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: isDark? Color(0xff5E5E5E): Color(0xffC9C9C9),style: BorderStyle.solid,width: 1)),
                    enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    borderSide: BorderSide(color: isDark? Color(0xff5E5E5E): Color(0xffC9C9C9),style: BorderStyle.solid, width: 1)),
                    focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all( Radius.circular(2)),
                    borderSide: BorderSide(color: isDark? Color(0xff5E5E5E): Color(0xffC9C9C9),style: BorderStyle.solid,width: 1)),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              Container(
                height: 1,
                color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),
              ),
              SizedBox(height: 16,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          Navigator.of(context, rootNavigator: true).pop("Discard");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                               color: Color(0xffEB5757),
                               width: 1,
                               ),
                               borderRadius: BorderRadius.circular(5),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                        child: Center(child: Text(S.current.cancel, style: TextStyle(height: 1.57, fontSize: 12,color: Color(0xffEB5757))))
                   ),
                      ),
                 ),
                 SizedBox(width: 10,),
                 Expanded(
                   child: InkWell(
                     onTap: (){
                       widget.onSaveString(_controller.text);
                     },
                     child: Container(
                       decoration: BoxDecoration(
                         color: Color(0xff1890FF),
                         border: Border.all(
                           color: Color(0xff1890FF),
                           width: 1,
                           ),
                           borderRadius: BorderRadius.circular(5),
                        ),
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                      width: MediaQuery.of(context).size.width,
                      child: Center(child: Text(widget.title == "Join to Channel" ? S.current.join : S.current.save, style: TextStyle(height: 1.57, fontSize: 12, color:Colors.white)))
                     ),
                   ),
                 ),
                ],),
              )
            ]
          ),
        ),
      ),
    );
  }
}