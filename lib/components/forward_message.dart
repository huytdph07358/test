import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/emoji/emoji.dart';
import 'package:workcake/flutter_mentions.dart';
import 'package:workcake/models/models.dart' hide WorkspaceItem;
import 'package:workcake/src/mention_view_new.dart';

import 'attachment_card.dart';


class ForwardMessage extends StatefulWidget {
  ForwardMessage({
    Key? key,
    required this.message,
  }) : super(key: key);

  final message;

  @override
  _ForwardMessageState createState() => _ForwardMessageState();
}

enum SEARCH {
  DIRERCT,
  CHANNEL
}

class _ForwardMessageState extends State<ForwardMessage> {
  var _debounce;
  List resultMembersSearch = [];
  List channelsFilter = [];
  bool isShow = false;
  var destination;
  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
  TextEditingController controller = TextEditingController();
  SEARCH type = SEARCH.CHANNEL;
  int indexWorkspaceSelected = 0;

  getSuggestionMentions() {
    final auth = Provider.of<Auth>(context, listen: false);
    final dataUserMentions = Provider.of<User>(context, listen: false).userMentionInDirect;
    final directMessage = Provider.of<DirectMessage>(context, listen: false).directMessageSelected;
    var listUser = [] + directMessage.user + dataUserMentions;
    Map index = {};

    List<Map<String, dynamic>> dataList = [];
      for (var i = 0 ; i< listUser.length; i++){
        if (index[listUser[i]["user_id"]] != null) continue;
        Map<String, dynamic> item = {
          'id': listUser[i]["user_id"],
          'type': 'user',
          'display': listUser[i]["full_name"],
          'full_name': listUser[i]["full_name"],
          'photo': listUser[i]["avatar_url"]
        };
        index[listUser[i]["user_id"]] = true;

        if (auth.userId != listUser[i]["user_id"]) dataList += [item];
      }

    return dataList;
  }

  renderTextMention(att, isDark) {
    return att["data"].map((e){
      if (e["type"] == "text" && Utils.checkedTypeEmpty(e["value"])) return e["value"];
      if (e["name"] == "all" || e["type"] == "all") return "@all ";

      if (e["type"] == "issue") {
        return "";
      } else {
        return Utils.checkedTypeEmpty(e["name"]) ? "@${e["name"]} " : "";
      }
    }).toList().join("");
  }

  getRandomString(int length){
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  sendForwardMessage() async{
    var auth = Provider.of<Auth>(context, listen: false);
    var user = Provider.of<User>(context, listen: false);
    var providerMessage = Provider.of<Messages>(context, listen: false);
    var fakeId = getRandomString(20);

    List attachments = [];
    final Document document = key.currentState!.document;

    attachments = Utils.checkedTypeEmpty(document.toPlainText().trim()) ? [{
      'type': "mention",
      'data': Utils.parseQuillController(document),
      'jsonText': document.toDelta().toJson()
    }] : [];

    if(destination == null) return;

    Map dataMessage = {
      "channel_thread_id": null,
      "key": Utils.getRandomString(20),
      "message": '',
      "attachments": attachments + [{
          "mime_type": "shareforwar",
          "data": {
            ...widget.message,
            'conversation_id': widget.message['conversationId'],
            "channel_id":  widget.message['channelId'] ?? 0,
            "workspace_id": widget.message['workspaceId'] ?? 0,
          }
      }],
      "conversation_id": destination['id'],
      "channel_id":  destination['id'] ?? 0,
      "workspace_id": destination['workspace_id'] ?? 0,
      "count_child": 0,
      "user_id": auth.userId,
      "user": user.currentUser["full_name"] ?? "",
      "avatar_url": user.currentUser["avatar_url"] ?? "",
      "full_name": user.currentUser["full_name"] ?? "",
      "inserted_at": DateTime.now().add(new Duration(hours: -7)).toIso8601String(),
      "is_system_message": false,
      "isDesktop": true,
      "show": true,
      "time_create": DateTime.now().add(new Duration(hours: -7)).toIso8601String(),
      "current_time": DateTime.now().microsecondsSinceEpoch,
      "count": 0,
      "isSend": true,
      "sending": true,
      "success": true,
      "fake_id": fakeId,
    };

    if (!destination['isChannel']) {
      bool isSend = await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(auth.token, destination['id']);
      if(isSend) Provider.of<DirectMessage>(context, listen: false).sendMessageWithImage([], dataMessage, auth.token);
    } else {
      await Provider.of<Workspaces>(context, listen: false).onSelectWorkspace(context, destination['workspace_id']);
      await Provider.of<Channels>(context, listen: false).onSelectedChannel(destination['workspace_id'], destination['id'], auth, providerMessage);
      await Provider.of<Messages>(context, listen: false).sendMessageWithImage([], dataMessage, auth.token);
    }

    Navigator.pop(context);
    Navigator.pop(context);
  }

  search(value, token) async {
    if(type == SEARCH.CHANNEL) {
      final data = Provider.of<Channels>(context, listen: false).data;
      final dataWorkspaces = Provider.of<Workspaces>(context, listen: false).data;

      setState(() {
        channelsFilter = data.where((ele) {
          final bool check = Utils.unSignVietnamese(ele['name']).toLowerCase().contains(Utils.unSignVietnamese(controller.text.toLowerCase())) && ele["workspace_id"] == dataWorkspaces[indexWorkspaceSelected]["id"] && !ele["is_archived"];
          return check;
        }).toList();
      });
    } else {
      String url = "${Utils.apiUrl}direct_messages/search_conversation?token=$token&text=$value";
      try {
        var response = await Dio().get(url);
        var dataRes = response.data;
        if (dataRes["success"]) {
          setState(() {
            resultMembersSearch = dataRes["data"];
          });
        } else {
          throw HttpException(dataRes["message"]);
        }
      } catch (e) { }
    }
  }

  Widget renderMessage(List newAtts, bool isDark) {
    return RichText(
      text: TextSpan(
        children: newAtts.map<InlineSpan>((ele) {
          if(ele.isEmpty) return TextSpan();
          if(ele[0]['type'] == 'block_code' && ele[0]['isThreeBackstitch'] == true) {
            return WidgetSpan(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isDark ? Color(0xff1E1E1E) : Color(0xffEDEDED),
                ),
                margin: EdgeInsets.only(right: 16, top: 4, bottom: 4),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Text.rich(
                  TextSpan(
                    children: ele.map<InlineSpan>((e) {
                      return TextSpan(
                        text: e["value"],
                        style: GoogleFonts.robotoMono(
                          height: 1.67,
                          fontWeight: FontWeight.w300, fontSize: 14,
                          color: isDark ? Color.fromARGB(255, 198, 208, 224) : Palette.defaultTextLight
                        ),
                      );
                    }).toList()
                  )
                ),
              ),
            );
          } else if (ele.length  == 1 && ele[0]['type'] == 'text' && !Utils.checkedTypeEmpty(ele[0]['value'].trim())) {
            return TextSpan();
          } else if (ele[0]["type"] == "issue") {
            return WidgetSpan(
              child: RichText(
                text: TextSpan(
                  children: ele.map<InlineSpan>((item) {
                    return WidgetSpan(
                      child: MentionIssue(e: item)
                    );
                  }).toList()
                )
              ),
            );
          }

          return WidgetSpan(
            child: Text.rich(
              TextSpan(
                children: ele.map<InlineSpan>((e) {
                  if (e["type"] == "text") {
                    return Utils.checkedTypeEmpty(e["value"].trim()) ? TextSpan(text: e["value"]) : TextSpan();
                  }

                  if (e["name"] == "all" || e["type"] == "all") {
                    return TextSpan(
                      text: "@all ", 
                      style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 15.5, height: 1.5)
                    );
                  }

                  if(e['type'] == 'block_code') {
                    return TextSpan(
                      text: '\u00A0' +  e["value"] + '\u00A0',
                      style: GoogleFonts.robotoMono(
                        height: 1.67,
                        fontWeight: FontWeight.w300, fontSize: 13.5,
                        color: Palette.dayBlue,
                        backgroundColor: Color(0xffEDEDED),
                      ),
                    );
                  } else {
                    return Utils.checkedTypeEmpty(e["name"]) ? TextSpan(
                      text: "@${e["name"]} ",
                      style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 15.5, height: 1.5),
                    ) : TextSpan();
                  }
                }).toList()
              )
            )
          );
        }).toList()
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final bool isDark = auth.theme == ThemeType.DARK;
    final dataWorkspaces = Provider.of<Workspaces>(context, listen: false).data;
    final data = Provider.of<Channels>(context, listen: true).data;
    var keyboardHeight  = MediaQuery.of(context).viewInsets.bottom;

    final dataMessageShared = widget.message;
    final attachment = dataMessageShared["attachments"];

    List newAtts = [];

    int index = (attachment ?? []).indexWhere((e) => e['type'] == 'mention');

    if(index != -1) {
      List data = attachment[index]["data"];

      Map b = {
        "type": data[0]["type"],
        "data": []
      };
      
      for(final i in data) {
        String type = "";
        if (["block_code"].contains(i["type"]) && i["isThreeBackstitch"] == true) {
          type = "block_code";
          if(b['data'].isNotEmpty) {
            b['data'].last["value"] =  b['data'].last["value"].trimRight();
          }
        } else if(i['type'] == 'issue') {
          type = 'issue';
        } else type = "text";

        if (b["type"] == type){
          b["data"] = [] + b["data"] + [i];
        } else {
          newAtts = [] + newAtts + [b["data"]];
          b = {
            "type": type,
            "data": [i]
          };
        }
      }

      newAtts = [] + newAtts + [b["data"]];
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            color: isDark ? Palette.darkPrimary : Palette.lightPrimary,
          ),
          width: constraints.maxWidth,
          height: constraints.maxHeight * 0.95,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor)
                  )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "Forward this message",
                        style: TextStyle(
                          color: isDark ? Colors.white : Palette.defaultTextLight, 
                          fontSize: 14, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        PhosphorIcons.xCircle, size: 20,
                        color: isDark ? Colors.white : Palette.defaultTextLight,
                      ),
                    )
                  ],
                )
              ),
              Container(
                height: keyboardHeight == 0 ? constraints.maxHeight * 0.8 : constraints.maxHeight * 0.39,
                child: SingleChildScrollView(
                  controller: ScrollController(),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      PortalEntry(
                        visible: isShow,
                        portalAnchor: Alignment.topCenter,
                        childAnchor: Alignment.bottomCenter,
                        portal: Container(
                          margin: EdgeInsets.only(top: destination != null ? 32 : 20),
                          width: 400,
                          decoration: BoxDecoration(
                            border: isDark ? Border() : Border.all(
                              color: Color(0xffA6A6A6), width: 0.2
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            color: isDark ? Color(0xff2f3136) : Color(0xFFf0f0f0),
                            ),
                          constraints: BoxConstraints(
                            maxHeight: keyboardHeight == 0 ? constraints.maxHeight * 0.4 : constraints.maxHeight * 0.3,
                            minHeight: 0,
                          ),
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () { 
                                        type = SEARCH.DIRERCT;
                                        search(controller.text, auth.token);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(CupertinoIcons.chat_bubble_2, size: 18.0, color:  isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                                            SizedBox(width: 8.0,),
                                            Text("Direct Message", style: TextStyle(color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight))
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () { 
                                        type = SEARCH.CHANNEL;
                                        search(controller.text, auth.token);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Icon(CupertinoIcons.list_dash, size: 18.0, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                                            SizedBox(width: 8.0,),
                                            Text("Workspace", style: TextStyle(color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              type == SEARCH.CHANNEL ? Container(
                                height: keyboardHeight == 0 ? constraints.maxHeight * 0.35 : constraints.maxHeight * 0.25,
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: isDark ? const Color(0xff5E5E5E) : const Color(0xffEAE8E8),
                                      ),
                                      height: 40,
                                      // child: ScrollConfiguration(
                                        // behavior: MyCustomScrollBehavior(),
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: dataWorkspaces.length,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  indexWorkspaceSelected = index;
                                                  channelsFilter = data.where((ele) {
                                                    final bool check = Utils.unSignVietnamese(ele['name']).toLowerCase().contains(Utils.unSignVietnamese(controller.text )) && ele["workspace_id"] == dataWorkspaces[index]["id"] && !ele["is_archived"];
                                                    return check;
                                                  }).toList();
                                                });
                                              },
                                              child: WorkspaceItem(
                                                imageUrl: dataWorkspaces[index]["avatar_url"] ?? "",
                                                workspaceName: dataWorkspaces[index]["name"] ?? "",
                                                isSelected: indexWorkspaceSelected == index,
                                              ),
                                            );
                                          },
                                        ),
                                      // ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: isDark ? const Color(0xff2E2E2E) : Colors.white,
                                            border: isDark ? null : Border.all(color: const Color(0xffC9C9C9)),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16),
                                                decoration: BoxDecoration(
                                                  color: isDark ? const Color(0xff4C4C4C) : const Color(0xffF8F8F8),
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(3),
                                                    topRight: Radius.circular(3),
                                                  )
                                                ),
                                                child: Text("List channel", style: TextStyle(color: isDark ? Colors.white :  const Color(0xff3D3D3D), fontWeight: FontWeight.w500, fontSize: 14))
                                              ),
                                              Expanded(
                                                child: Container(
                                                  decoration: isDark ? null : BoxDecoration(
                                                    border: Border(top: isDark ? BorderSide.none : const BorderSide(color: Color(0xffC9C9C9))),
                                                  ),
                                                  child: ListView.builder(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    itemCount: channelsFilter.length,
                                                    controller: ScrollController(),
                                                    itemBuilder: (context, index) {
                                                      int indexWorkspace = dataWorkspaces.indexWhere((ele) => ele['id'] == channelsFilter[index]['workspace_id']);
                                                      if (indexWorkspace == -1) {
                                                        return Container();
                                                      }
                                                      return InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            destination = {
                                                              'id': channelsFilter[index]['id'],
                                                              'isChannel': true,
                                                              'workspace_id': channelsFilter[index]['workspace_id'],
                                                              'name': channelsFilter[index]['name'],
                                                            };
                                                            isShow = false;
                                                          });
                                                        },
                                                        child: HoverItem(
                                                          colorHover: Colors.grey.withOpacity(0.1),
                                                          child: Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                            child: Row(
                                                              children: [
                                                                channelsFilter[index]['is_private']
                                                                  ? SvgPicture.asset('assets/images/icons/Locked.svg', color: isDark ? const Color(0xffDBDBDB) : const Color(0xff3D3D3D))
                                                                  : SvgPicture.asset('assets/images/icons/iconNumber.svg', width: 13, color: isDark ? const Color(0xffDBDBDB) : const Color(0xff3D3D3D)),
                                                                const SizedBox(width: 8),
                                                                Expanded(child: Text(channelsFilter[index]['name'], overflow: TextOverflow.ellipsis, style: TextStyle(color: isDark ? const Color(0xffDBDBDB) : const Color(0xff3D3D3D), fontSize: 14,),)),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ) : Container(
                                height: keyboardHeight == 0 ? constraints.maxHeight * 0.35 : constraints.maxHeight * 0.25,
                                child: ListView.builder(
                                  itemCount: resultMembersSearch.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          destination = {
                                            'id': resultMembersSearch[index]['id'] ?? resultMembersSearch[index]['conversation_id'],
                                            'isChannel': resultMembersSearch[index]['workspace_id'] != null,
                                            'workspace_id': resultMembersSearch[index]['workspace_id'],
                                            'name': resultMembersSearch[index]['name'],
                                            'avatar_url': resultMembersSearch[index]['avatar_url']
                                          };
                                          isShow = false;
                                        });
                                        FocusScope.of(context).unfocus();
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(color: index == resultMembersSearch.length - 1 ? Colors.transparent : Colors.grey[500]!, width: 0.2),
                                            top: BorderSide(color: index == 0 ? Colors.transparent : Colors.grey[500]!, width: 0.2)
                                          )
                                        ),
                                        child: Row(
                                          children: [
                                            CachedAvatar(
                                              resultMembersSearch[index]['avatar_url'],
                                              height: 32, width: 32, radius: 16,
                                              isRound: true,
                                              name: resultMembersSearch[index]["name"],
                                              isAvatar: true
                                            ),
                                            const SizedBox(width: 8),
                                            Text(resultMembersSearch[index]['name'] ?? '')
                                          ],
                                        )
                                      ),
                                    );
                                  }
                                ),
                              ),
                            ],
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                          child: FocusScope(
                            onFocusChange: (value) => setState(() => isShow = value),
                            child: Container(
                              height: 40,
                              child: TextFormField(
                                style: TextStyle(fontSize: 14),
                                onChanged: (value) {
                                  if (_debounce?.isActive ?? false) _debounce.cancel();
                                  _debounce = Timer(const Duration(milliseconds: 500), ()async {
                                    search(value, auth.token);
                                  });
                                },
                                onTap: () {
                                  setState((){
                                    isShow = !isShow;
                                  });
                                  search('', auth.token);
                                },
                                controller: controller,
                                decoration: InputDecoration(
                                  hoverColor: isDark ?Color(0xff5E5E5E) : Color(0xffEDEDED),
                                  hintText: "Search your channels",
                                  hintStyle: TextStyle(fontSize: 14),
                                  contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                  filled: true,
                                  fillColor: isDark ? Color(0xFF353535) : Color(0xffFAFAFA),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                                    borderRadius: BorderRadius.all(Radius.circular(4))),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                                    borderRadius: BorderRadius.all(Radius.circular(4)))
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      destination != null
                        ? Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                          child: Row(
                            children: [
                              destination['isChannel'] ? Container(
                                child: Text(
                                  destination['name'], overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: isDark ? const Color(0xffDBDBDB) : const Color(0xff3D3D3D), fontSize: 14,)
                                ),
                              ) : Row(
                                children: [
                                  CachedAvatar(
                                    destination['avatar_url'],
                                    height: 20, width: 20, radius: 10,
                                    isRound: true,
                                    name: destination["name"],
                                    isAvatar: true
                                  ),
                                  const SizedBox(width: 8),
                                  Text(destination['name']),
                                ],
                              ),
                              SizedBox(width: 8),
                              InkWell(
                                child: Icon(
                                  PhosphorIcons.xCircle, size: 16,
                                ),
                                onTap: () {
                                  setState(() => destination = null);
                                },
                              )
                            ],
                          )
                        ) : SizedBox(height: 20),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xff2e2e2e) : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: isDark ? Border() : Border.all(
                            color: Color(0xffA6A6A6), width: 0.5
                          ),
                        ),
                        child: FlutterMentions(
                          key: key,
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[800]),
                          cursorColor: isDark ? Colors.grey[400]! : Colors.black87,
                          autofocus: true,
                          isForwardMessage: true,
                          isDark: isDark,
                          islastEdited: false,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                            hintText: "Type a message...",
                            hintStyle: TextStyle(color: isDark ? Color(0xff9AA5B1) : Color.fromRGBO(0, 0, 0, 0.65), fontSize: 13.5, height: 1)
                          ),
                          onSearchChanged: (trigger, value) { },
                          mentions: [
                            Mention(
                              markupBuilder: (trigger, mention, value, type) {
                                return "=======@/$mention^^^^^$value^^^^^$type+++++++";
                              },
                              trigger: '@',
                              style: TextStyle(
                                color: Colors.lightBlue,
                              ),
                              data: getSuggestionMentions(),
                              matchAll: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xff5E5E5E) : Color(0xffF3F3F3),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                          child: Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Color(0xffd0d0d0),
                                  width: 4.0,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.arrowshape_turn_up_left_fill, color: isDark ? Color(0xffA6A6A6) : Color(0xff828282), size: 17),
                                      SizedBox(width: 5,),
                                      Text("Share this message", style: TextStyle(fontStyle: FontStyle.italic)),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  child: Row(
                                    children: [
                                      CachedAvatar(
                                        dataMessageShared["avatarUrl"],
                                        height: 20, width: 20,
                                        isRound: true,
                                        name: dataMessageShared["fullName"],
                                        isAvatar: true,
                                        fontSize: 13,
                                      ),
                                      SizedBox(width: 5),
                                      Text(dataMessageShared["fullName"])
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Utils.checkedTypeEmpty(dataMessageShared["isUnsent"])
                                  ? Container(
                                    height: 19,
                                    child: Text(
                                      "This message is deleted",
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Color(isDark ? 0xffe8e8e8 : 0xff898989)
                                      ),
                                    )
                                  )
                                  : (dataMessageShared["message"] != "" && dataMessageShared["message"] != null)
                                    ? Container(
                                      padding: EdgeInsets.only(left: 3),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(dataMessageShared["message"]),
                                          dataMessageShared["attachments"] != null && dataMessageShared["attachments"].length > 0
                                            ? Text("Attachments")
                                            // ? AttachmentCardDesktop(attachments: dataMessageShared["attachments"], isChannel: dataMessageShared["isChannel"], id: dataMessageShared["id"], isChildMessage: false, isThread: dataMessageShared["isThread"], lastEditedAt: parseTime(dataMessageShared["lastEditedAt"]))
                                            : Container()
                                        ],
                                      ),
                                    )
                                    : dataMessageShared["attachments"] != null && dataMessageShared["attachments"].length > 0
                                      ? Container(
                                    padding: EdgeInsets.only(left: 3),
                                    child: attachment[0]["type"] == "mention"
                                    ? renderMessage(newAtts, isDark)
                                    : RichText(
                                      text: TextSpan(
                                        text: Utils.checkedTypeEmpty(dataMessageShared["message"])
                                          ? dataMessageShared["message"]
                                          : attachment[0]["mime_type"] == "image"
                                            ? attachment[0]["name"]
                                            : 'Parent message',
                                      )
                                    )
                                  ) : Container(),
                              ],
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                onTap: () => isShow == true ? setState((){isShow = false;}) : null,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      HoverItem(
                        colorHover: Color(0xffFF7875).withOpacity(0.2),
                        child: TextButton(
                          style: ButtonStyle(
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: BorderSide(width: 1, color: Colors.red, style: BorderStyle.solid)
                              ),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child:Text("Cancel", style: TextStyle(color: Colors.red))
                        ),
                      ),
                      SizedBox(width: 7),
                      HoverItem(
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.blue),
                            overlayColor: MaterialStateProperty.all(Colors.blue[400]),
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: BorderSide(width: 1, color: Colors.blue, style: BorderStyle.solid)
                              ),
                            ),
                          ),
                          onPressed: destination != null ?  sendForwardMessage : null,
                          child: Text("Forward message", style: TextStyle(color: Colors.white))
                        ),
                      ),
                    ],
                  )
                ),
              )
            ],
          ),
        );
      }
    );
  }
}

class WorkspaceItem extends StatelessWidget {
  const WorkspaceItem({Key? key, required this.imageUrl, required this.workspaceName, this.isSelected = false}) : super(key: key);
  final String imageUrl;
  final String workspaceName;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom:  BorderSide(color: isSelected ? isDark ? const Color(0xffFAAD14) : const Color(0xff1890FF) : Colors.transparent, width: 2))
      ),
      child: Row(
        children: [
          CachedImage(imageUrl, name: workspaceName, width: 24, height: 24, radius: 4),
          const SizedBox(width: 8,),
          isSelected ? Text("$workspaceName  ", style: TextStyle(color: isDark ? Colors.white : const Color(0xff3D3D3D), fontSize: 14, fontWeight: FontWeight.w500)) : const SizedBox()
        ],
      )
    );
  }
}
