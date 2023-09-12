import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/components/thread_view.dart';
import 'package:workcake/components/forward_message.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';

class DMActionMessage extends StatefulWidget {
  final idMessage;
  final keyDB;
  final onEditMessage;
  final copyMessage;
  final isChildMessage;
  final userId;
  final isChannel;
  final handleReactionMessage;
  final openListEmoji;
  final conversationId;
  final channelId;
  final onDeleteDM;
  final onCreateIssue;
  final messageAction;
  final onReplyMessage;
  final dataMessage;
  final parentId;
  final onSaveMessage;
  final isThreadView;


  DMActionMessage({
    Key? key,
    @required this.idMessage,
    @required this.keyDB,
    this.onEditMessage,
    this.copyMessage,
    this.isChildMessage,
    @required this.userId,
    this.isChannel,
    this.handleReactionMessage,
    this.openListEmoji,
    this.conversationId,
    this.channelId,
    this.onDeleteDM,
    this.onCreateIssue,
    this.messageAction,
    this.onReplyMessage,
    this.dataMessage, this.parentId, this.onSaveMessage, this.isThreadView,
  }) : super(key: key,);

  @override
  _DMActionMessage createState() => _DMActionMessage();
}

class _DMActionMessage extends State<DMActionMessage> {

  Future<dynamic> showDialogForwardMessage(BuildContext context, message) async {
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      builder: (BuildContext context) {
        return ForwardMessage(message: message);
      }
    );
  }

  showDialogDeleteMessage(bool isDark, String type) {
    String token = Provider.of<Auth>(context, listen: false).token;
    final workspaceId = Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"];
    final auth = Provider.of<Auth>(context, listen: false);
    final userId = widget.userId;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark ? Palette.backgroundRightSiderDark :  Colors.white,
            ),
            height: 220, width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Palette.borderSideColorDark : Color(0xffFAFAFA),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                  ),
                  child: Text(
                    S.current.deleteMessages,
                    style: TextStyle(
                      color: isDark ? Color(0xfffffffff) : Color(0xff3D3D3D), fontSize: 16, fontWeight: FontWeight.bold
                    )
                  ),
                ),
                SizedBox(height: 6,),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(12),
                    child: Text(
                      '${S.current.deleteThisMessages} ${S.current.youCanUndoThisAction}.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight, fontSize: 16 ,height: 1.57
                      )
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 14),
                  height: 1,
                  color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight,
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.isChannel ? Expanded(
                        child: InkWell(
                          onTap: () {
                            Provider.of<Messages>(context, listen: false).deleteChannelMessage(token, workspaceId, widget.channelId, widget.idMessage);
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Palette.errorColor,
                                width: 1
                              )
                            ),
                            child: Text(S.current.delete, style: TextStyle(color: Palette.errorColor, fontSize: 15, fontWeight: FontWeight.w700))
                          ),
                        ),
                      ):Container(),
                      SizedBox(width: 10,),
                      widget.isChannel ? Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isDark ? Color(0xffFFFFFF) : Color(0xff949494),
                                width: 1
                              )
                            ),
                            child: Text(S.current.cancel, style: TextStyle(color: isDark ? Color(0xffFFFFFF) : Color(0xff949494), fontSize: 15, fontWeight: FontWeight.w700))
                          ),
                        ),
                      ):Container(),
                       if (type == 'one' && widget.onDeleteDM != null) widget.isChannel ? Container() : auth.userId == userId ? Expanded(
                         child: InkWell(
                          onTap: () {
                            widget.onDeleteDM(widget.idMessage, widget.conversationId, type: "delete_for_me");
                            Navigator.pop(context);
                          },
                          child: Container(
                            // width: 250,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xffFF7875)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(S.current.deleteForMe, style: TextStyle(color: Color(0xffFF7875), fontSize: 13, fontWeight: FontWeight.w700))
                          ),
                          ),
                       ): InkWell(
                       onTap: () {
                         widget.onDeleteDM(widget.idMessage, widget.conversationId, type: "delete_for_me");
                         Navigator.pop(context);
                       },
                       child: Container(
                         width: 250,
                         alignment: Alignment.center,
                         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                         decoration: BoxDecoration(
                         border: Border.all(color: Color(0xffFF7875)),
                         borderRadius: BorderRadius.circular(4),
                         ),
                         child: Text(S.current.deleteForMe, style: TextStyle(color: Color(0xffFF7875), fontSize: 13, fontWeight: FontWeight.w700))
                       ),
                        ),
                      if(widget.conversationId != null && ((widget.messageAction ?? "insert") == "insert")) auth.userId == userId ? SizedBox(width: 8,) : Container(),
                      if(widget.conversationId != null && ((widget.messageAction ?? "insert") == "insert")) auth.userId == userId ? Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xffFF7875)),
                              borderRadius: BorderRadius.circular(4),
                          ),
                          child: InkWell(
                            onTap: () {   
                                if (widget.onDeleteDM != null) {
                                  widget.onDeleteDM(widget.idMessage, widget.conversationId);
                                }                        
                              Navigator.pop(context);
                            },
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: 120
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                              child: Text(S.current.deleteForEveryone, style: TextStyle(color: Color(0xffFF7875) , fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis,)
                            )
                          ),
                        ),
                      ): Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  getReadMessageConversation(String id, String conversationId){
    final auth = Provider.of<Auth>(context);
    int count = 0;
    final dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(conversationId);
    if (dm == null || (auth.userId != widget.userId)) return Container();
    int countDM = dm.user.where((element) => element["status"] == "in_conversation").length; 
    try {
      final dataUnreadMessage = Provider.of<DirectMessage>(context, listen: false).dataUnreadMessage;
      var unreadCount  =  dataUnreadMessage[id]["count_unread"];
      count = ( countDM - 1 - unreadCount).toInt();
    } catch (e) {
    }

    if (count == 0) return Icon(PhosphorIcons.check, size: 20);
    if ((countDM - 1) == count) return Icon(PhosphorIcons.checks, color: Color(0xFF1890ff), size: 20,);
    return Row(
      children: [
        Text("$count ", style: TextStyle(fontSize: 12)),
        Icon(PhosphorIcons.checks, color: Color(0xFFbfbfbf),size: 20)
      ]
    );
  }

  bool checkMarkSavedMessage() {
    final savedMessages = Provider.of<User>(context, listen: false).savedMessages;
    final index = savedMessages.indexWhere((e) => e["message_id"] == widget.idMessage);
    return (index != -1);
  }

  bool checkPinMessage(pinnedMessages) {
    final index = pinnedMessages.indexWhere((e) => e["id"] == widget.idMessage);

    return (index != -1);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final pinnedMessages = Provider.of<Channels>(context, listen: true).pinnedMessages;
    final isDark = auth.theme == ThemeType.DARK;
    final userId = widget.userId;
    final isChildMessage = widget.isChildMessage;
    final bool isPinned = checkPinMessage(pinnedMessages);
    final bool isSaveMessage = checkMarkSavedMessage();
    return Wrap(
      children: [
        Container(
          // height: auth.userId == userId ? isChildMessage ? 160 : 340 : isChildMessage ? 75 : 250,
          // constraints: BoxConstraints(maxHeight: 250),
          child: Column(children: [
            // List Of emoji
            InkWell(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Container(
                margin: EdgeInsets.only(top: 5),
                height: 4,
                width: 50,
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF5E5E5E) :Color(0xffC9C9C9),
                  borderRadius: BorderRadius.circular(16)
                )
              ),
            ),
            widget.conversationId != null ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: getReadMessageConversation(widget.idMessage, widget.conversationId),
              ) 
            ) : Container(),
            Container(
               padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9), width: 0.3))
              ),
              // height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                    if (widget.handleReactionMessage != null) {widget.handleReactionMessage("grinning_face_with_smiling_eyes"); Navigator.pop(context);}
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: isDark ? Color.fromARGB(243, 101, 97, 97) : Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(child: Text("😄", style: TextStyle(fontSize: 20))),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (widget.handleReactionMessage != null) {widget.handleReactionMessage("thumbs_up"); Navigator.pop(context);}
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Color.fromARGB(243, 101, 97, 97) : Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text("👍", style: TextStyle(fontSize: 20)),
                    )
                  ),
                  InkWell(
                    onTap: () {
                      if (widget.handleReactionMessage != null) {widget.handleReactionMessage("rolling_on_the_floor_laughing"); Navigator.pop(context);}
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Color.fromARGB(243, 101, 97, 97) : Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text("🤣", style: TextStyle(fontSize: 20)),
                    )
                  ),
                  InkWell(
                    onTap: () {
                      if (widget.handleReactionMessage != null) {widget.handleReactionMessage("red_heart"); Navigator.pop(context);}
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Color.fromARGB(243, 101, 97, 97) : Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text("❤", style: TextStyle(fontSize: 20)),
                    )
                  ),
                  InkWell(
                    onTap: () {
                      if (widget.handleReactionMessage != null) {widget.handleReactionMessage("clapping_hands"); Navigator.pop(context);}
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Color.fromARGB(243, 101, 97, 97) : Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text("👏", style: TextStyle(fontSize: 20)),
                    )
                  ),
                  InkWell(
                    onTap: () {
                      if (widget.handleReactionMessage != null) { widget.handleReactionMessage("crying_face");  Navigator.pop(context);}
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Color.fromARGB(243, 101, 97, 97) : Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text("😢", style: TextStyle(fontSize: 20),),
                    )
                  ),
                  InkWell(
                    onTap: () {
                      if (widget.openListEmoji != null) {Navigator.pop(context);widget.openListEmoji();}
                    },
                    child:Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Color.fromARGB(243, 101, 97, 97) : Color(0xffFAFAFA),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: SvgPicture.asset(isDark ? "assets/images/icons/emojiDark.svg" : "assets/images/icons/emojiLight.svg"),
                    )
                  ),
                ],
              ),
            ),
            !isChildMessage && !widget.isThreadView
            ? Column(
              children: [
                // ((widget.messageAction ?? "insert") == "insert") ? InkWell(
                //   onTap: () {
                //     Navigator.pop(context);
                //     widget.copyMessage(widget.keyDB);
                //   },
                //   child: Container(
                //     padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                //     child: Row(
                //       children: [
                //         Icon(PhosphorIcons.copySimple, size: 18, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)),
                //         SizedBox(width: 8),
                //         Text(S.current.copyText, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 15),)
                //       ]
                //     )
                //   ),
                // ) : Container(),
                InkWell(
                  onTap: () {
                    List _attachments = widget.dataMessage['attachments'] ?? [];
                    if (_attachments.length > 0 && widget.dataMessage['attachments'][0]['type'] == "poll") return; // ko cho reply poll in thread
                    Navigator.pop(context);
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return ThreadView(
                            isChannel: widget.isChannel,
                            idMessage: widget.idMessage,
                            keyDB: widget.keyDB,
                            idConversation: widget.conversationId,
                            channelId: widget.channelId
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9), width: 0.3))
                    ),
                    padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.chatCircleText, size: 18, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)),
                        SizedBox(width: 8,),
                        Text("Thread", style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 15))
                      ]
                    )
                  )
                ),
                InkWell(
                  onTap: () {
                    widget.onReplyMessage({"mime_type": "share", "data": widget.dataMessage});
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.arrowshape_turn_up_left, size: 18, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)),
                        SizedBox(width: 8,),
                        Text(S.current.replyThisMessage, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 15))
                      ]
                    )
                  )
                ),
              ],
            )
            : Container(),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                widget.copyMessage(widget.keyDB);
              },
              child: Container(
                padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                child: Row(
                  children: [
                    Icon(PhosphorIcons.copySimple, size: 18, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)),
                    SizedBox(width: 8),
                    Text(S.current.copyText, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 15),)
                  ]
                )
              ),
            ),
            auth.userId == userId && widget.conversationId == null
              ? InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    widget.onEditMessage(widget.keyDB);
                  },
                  // disabledColor: Color(0xFFFFFFFF).withOpacity(0.2),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.pencilLine, size: 18, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)),
                        SizedBox(width: 8),
                        Text(S.current.editMessage, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 15),)
                      ]
                    )
                  )
                )
              : Container(),
              InkWell(
                onTap: (){
                  showDialogForwardMessage(context, widget.dataMessage);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9), width: 0.3))
                  ),
                  padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.arrowshape_turn_up_right, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), size: 18),
                      SizedBox(width: 8),
                      Text(S.current.forwardMessage, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 15),)
                    ],
                  ),
                )
              ),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                  setState(() {
                    if (isSaveMessage){
                     Provider.of<User>(context, listen: false).unMarkSavedMessage(auth.token, widget.dataMessage);
                     Fluttertoast.showToast(
                        msg: "unsave",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D),
                        textColor: isDark ? Color(0xff2E2E2E) : Colors.white,
                        fontSize: 16.0
                      );
                    }else {
                      Provider.of<User>(context, listen: false).markSavedMessage(auth.token, widget.dataMessage);
                      Fluttertoast.showToast(
                        msg: "saved",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D),
                        textColor: isDark ? Color(0xff2E2E2E) : Colors.white,
                        fontSize: 16.0
                      );
                    } 
                  });  
                },
                child: Container(
                  padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                  child: Row(
                    children: [
                      isSaveMessage
                        ? Icon(CupertinoIcons.bookmark_fill, color: Colors.red, size: 17)
                        : Icon(CupertinoIcons.bookmark, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), size: 17),
                      SizedBox(width: 8),
                      Text( !isSaveMessage ? S.current.saveMessage : S.current.unsaveMessages, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 15),)
                    ],
                  ),
                )
              ),
              if(!isChildMessage && widget.isChannel) GestureDetector(
                onTap: () {
                  Provider.of<Channels>(context, listen: false).pinMessage(auth.token, widget.dataMessage['workspaceId'], widget.dataMessage['channelId'], widget.dataMessage["id"]);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                  child: Row(
                    children: [
                      Icon(!isPinned ? PhosphorIcons.pushPin : PhosphorIcons.pushPinSlash, size: 18, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)),
                      SizedBox(width: 8),
                      Text('${isPinned ? S.current.unpinMessage : S.current.pinMessages}', style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 15),)
                    ]
                  )
                )
              ),
              if(!isChildMessage && widget.isChannel) GestureDetector(
                onTap: () {
                  widget.onCreateIssue();
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9), width: 0.3))
                  ),
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.add_task_rounded, size: 18, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)),
                      SizedBox(width: 8),
                      Text(S.current.createIssue, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 15),)
                    ]
                  )
                )
              ),
              widget.isChannel ? Container() : InkWell(
                onTap: () {
                  Navigator.pop(context);
                  showDialogDeleteMessage(isDark, 'one');
                },
                child: Container(
                  padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.trash, size: 18, color: Color(0xffEB5757)),
                      SizedBox(width: 8),
                      Text(S.current.deleteMessages, style: TextStyle(color: Color(0xffEB5757), fontSize: 15))
                    ]
                  )
                )
              ),
              auth.userId == userId && widget.isChannel
                && (widget.dataMessage['current_time'] == null || DateTime.now().add(Duration(hours: -7)).microsecondsSinceEpoch - (widget.dataMessage['current_time'] ?? 0) < 86400000000)
              ? GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    showDialogDeleteMessage(isDark, 'all');
                  },
                  child: Container(
                    padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
                    child: Row(
                      children: [
                        Icon(PhosphorIcons.trash, size: 18, color: Color(0xffEB5757)),
                        SizedBox(width: 8),
                        Text(S.current.deleteMessages, style: TextStyle(color: Color(0xffEB5757), fontSize: 15))
                      ]
                    )
                  )
                )
              : Container(),
              Container(height: 20,)
          ]),
        ),
      ],
    );
  }
}