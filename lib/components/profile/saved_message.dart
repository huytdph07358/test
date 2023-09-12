import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/thread_view.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/message.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/conversation.dart';
import 'package:workcake/screens/message.dart' as MessageRenderDM;

class SavedMessages extends StatefulWidget {
  const SavedMessages({Key? key}) : super(key: key);

  @override
  State<SavedMessages> createState() => _SavedMessagesState();
}

class _SavedMessagesState extends State<SavedMessages> {

  List<Message> parseSaveMessage(List data) {
    return data.map((message) {
      Map mes = message["attachments"];
      mes = {
        ...mes,
        "avatar_url": mes["avatar_url"] ?? mes["avatarUrl"],
        "conversation_id": mes["conversation_id"] ?? mes["conversationId"],
        "current_time": mes["current_time"] ?? mes["currentTime"],
        "full_name": mes["full_name"] ?? mes["fullName"],
        "inserted_at": mes["inserted_at"] ?? mes["insertedAt"],
        "user_id": mes["user_id"] ?? mes["userId"],
        "is_channel": mes["is_channel"] ?? mes["isChannel"],
        "is_child_message": mes["is_child_message"] ?? mes["isChildMessage"],
        "is_unsent": mes["is_unsent"] ?? mes["isUnsent"],
        "last_edited_at": mes["last_edited_at"] ?? mes["lastEditedAt"],
        "workspace_id":(mes["workspace_id"] == "null" ? null : mes["workspace_id"]) ?? (mes["workspaceId"] == null ? null : mes["workspaceId"]),
        "channel_id": (mes["channel_id"] == "null" ? null : mes["channel_id"]) ?? (mes["channelId"] == null ? null : mes["channelId"]),
        "channel_thread_id": mes["channel_thread_id"] ?? mes["channelThreadId"],
        "parent_id": mes["parent_id"] ?? mes["parentId"]
      };
      String? conversationId = mes["conversation_id"] ?? mes["conversation_id"];
      Message dataMessage = conversationId != null ? MessageConv.parseFromJson(mes) : MessageChannel.parseFromJson(mes);
      
      return dataMessage;
    }).toList();
  }

  Future onTapMessage(Message e) async {
    Map message = e.toJson();

    if (e is MessageChannel) {
      if (!Utils.checkedTypeEmpty(message["channel_thread_id"])) {
        // dismissKeybroad();
        await Provider.of<Messages>(context, listen: false).handleProcessMessageToJump(message, context);
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) {
              return Conversation(
                id: message["channel_id"], 
                hideInput: true, 
                changePageView: (page) {}, 
                isNavigator: true,
                // panelController: panelController
              );
            },
          )
        );
      } else {
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
          return ThreadView(
            isChannel: true ,
            idMessage: message["channel_thread_id"],
            keyDB: message["key"],
            channelId: message["channel_id"],
            idMessageToJump: message["id"]
          );
        }));
      }
    }
    if (e is MessageConv) {
      String directId = e.conversationId;
      final auth = Provider.of<Auth>(context, listen: false);
      var hasConv = await  Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(auth.token, directId);
      if (hasConv) {
        DirectModel? model = Provider.of<DirectMessage>(context, listen: false).getModelConversation(directId);
        if (model == null) return;
        if (!Utils.checkedTypeEmpty(message["parent_id"])){
          // dismissKeybroad();
          await Provider.of<DirectMessage>(context, listen: false).processDataMessageToJump(message, auth.token, auth.userId);
          await Future.delayed(Duration(milliseconds: 300));
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) {
                return MessageRenderDM.Message(
                  dataDirectMessage: model,
                  id: model.id,
                  name: "",
                  avatarUrl: "",
                  isNavigator: true,
                  idMessageToJump: message["id"],
                  // panelController: panelController
                );
              },
            )
          );
        } else {
          var messageOnIsar = await MessageConversationServices.getListMessageById(model, message["parent_id"], directId);
          final directMessageSelected =  Provider.of<DirectMessage>(context, listen: false).getModelConversation(directId);
          if (directMessageSelected == null) return;
          List users = directMessageSelected.user;
          final indexUser = users.indexWhere((e) => e["user_id"] == message["user_id"]);
          if (indexUser != -1 && messageOnIsar != null) {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
              return ThreadView(
                isChannel: false ,
                idMessage: message["parent_id"],
                keyDB: message["parent_id"],
                idConversation: message["conversation_id"],
                channelId: "",
                idMessageToJump: message["id"],
              );
            }));
          }
        }
      }
    }
  }

  Widget _renderAction(auth, isDark, message) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 16),
      child: Wrap(
        children: [
          InkWell(
            onTap: (){
              Navigator.pop(context);
              Provider.of<User>(context, listen: false).unMarkSavedMessage(auth.token, message);
      
              Fluttertoast.showToast(
                msg: "unsave",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D),
                textColor: isDark ? Color(0xff2E2E2E) : Colors.white,
                fontSize: 16.0
              );
            },
            child: Container(
              padding: EdgeInsets.only(left: 10, top: 12, bottom: 12),
              child: Row(
                children: [
                  Icon(CupertinoIcons.bookmark_fill, color: Colors.red, size: 17),
                  SizedBox(width: 8),
                  Text(S.current.unsaveMessages, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 15),)
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
   
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final data = Provider.of<User>(context, listen: true).savedMessages;
    final List<Message> messagesFromApi = parseSaveMessage(data);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 62,
              decoration: BoxDecoration(
                color: isDark ? Color(0xff2E2E2E) : Colors.white,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: isDark ? null : Border(bottom: BorderSide(color: Color(0xffDBDBDB)))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Provider.of<Messages>(context, listen: false).openThreadMessage(false, {});
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 60,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      child: Text(
                        "Saved Messages",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      ),
                    ),
                    Container(
                      width: 60,
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: messagesFromApi.map<Widget>((e) {
                    String? workspaceName, channelName;
                    bool? isPrivate;
                    if (e is MessageChannel) {
                      try {
                        int indexW = Provider.of<Workspaces>(context, listen: false).data.indexWhere((element) => element["id"] == e.workspaceId);
                        int indexC = Provider.of<Channels>(context, listen: false).data.indexWhere((element) => "${element["id"]}" == "${e.channelId}");
                        workspaceName = indexW == -1 ? null :  Provider.of<Workspaces>(context, listen: false).data[indexW]["name"];
                        channelName = indexC == -1 ? null :  Provider.of<Channels>(context, listen: false).data[indexC]["name"];
                        isPrivate = indexC == -1 ? null :  Provider.of<Channels>(context, listen: false).data[indexC]["is_private"];
                      } catch (e,t) {
                        print("dsfsfsdfsdf $e $t");
                      }
                      
                    }
                    return Container(
                      margin: EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 32,
                            margin: EdgeInsets.only(bottom: 2),
                            padding: EdgeInsets.only(top: 8, bottom: 8, left: 12),
                            decoration: BoxDecoration(
                              color: isDark ? Color(0xff5E5E5E) : Color(0xFFEAE8E8),
                              borderRadius: BorderRadius.all(Radius.circular(3))
                            ),
                            child:  Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                e is MessageChannel ? Row(
                                  children: [
                                    Icon(CupertinoIcons.briefcase, size: 13, color: isDark ? Colors.white70 : Color(0xFF323F4B)),
                                    SizedBox(width: 3),
                                    Text(workspaceName ?? "", style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Color(0xFF323F4B))),
                                    SizedBox(width: 5,),
                                    Container(width: 1, height: 13, color: isDark ? Colors.white70 : Color(0xFF323F4B)),
                                    SizedBox(width: 5,),
                                    Utils.checkedTypeEmpty(isPrivate)
                                      ? SvgPicture.asset('assets/icons/Locked.svg', width: 11, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight)
                                      : SvgPicture.asset('assets/icons/iconNumber.svg', width: 11, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                                    SizedBox(width: 3,),
                                    Text(channelName ?? "", style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Color(0xFF323F4B)))
                                  ]
                                ) : Row(
                                  children: [
                                    Icon(CupertinoIcons.bubble_left_bubble_right, size: 13, color: isDark ? Colors.white70 : Color(0xFF323F4B)),
                                    SizedBox(width: 3),
                                    Text("Direct Message", style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Color(0xFF323F4B))),
                                  ],
                                ),

                                IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      enableDrag: true,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                      builder: (context) {
                                        return _renderAction(auth, isDark, e.toJson());
                                      }
                                    );
                                  },
                                  icon: Icon(PhosphorIcons.dotsThreeVertical, size: 18, color: isDark ? Colors.white : Colors.black),
                                  padding: EdgeInsets.zero,
                                )
                              ],
                            ),
                          ),
                         
                          e.render(context, onTapMessage: () => onTapMessage(e))
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}