import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/components/image_detail.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/link_preview.dart';
import 'package:workcake/components/media_conversation/video_conversation.dart';
import 'package:workcake/desktop/components/images_gallery.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/friends_screen/index.dart';
import 'package:workcake/screens/work_screen/issue_info.dart';
import 'package:workcake/components/video_card.dart';
import 'package:workcake/services/upload_status.dart';
import '../generated/l10n.dart';
import 'attachments/attachments.dart';
import 'call_center/call_manager.dart';
import '../desktop/components/poll.dart';
import 'chat_item.dart';
import 'direct_message/dm_action_message.dart';
import 'media_conversation/stream_media_downloaded.dart';
import 'render_issue_timeline.dart';

class AttachmentCard extends StatefulWidget {
  final attachments;
  final isChannel;
  final isChildMessage;
  final isThread;
  final id;
  final userId;
  final snippet;
  final blockCode;
  final conversationId;
  final lastEditedAt;
  final message;
  final issue;
  final onPinnedMessage;

  AttachmentCard({
    Key? key,
    this.attachments,
    this.isChannel,
    this.isChildMessage,
    this.id,
    this.userId,
    this.snippet,
    this.blockCode,
    this.conversationId,
    this.isThread,
    this.lastEditedAt,
    this.message,
    this.issue,
    this.onPinnedMessage = false
  }) : super(key: key);

  @override
  _AttachmentCardState createState() => _AttachmentCardState();
}

class _AttachmentCardState extends State<AttachmentCard> {
  bool isShift = false;
  var issue;
  List assignees = [];
  List selectedLabels = [];
  List selectedMilestone = [];


  // Regex phone number
  bool validatePhoneNumber(String value) {
    RegExp regex = new RegExp(r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$');
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }

  //mở Call dialer khả dụng dụng IOS 11+ & Andorid SDK 16+
  makingPhoneCall(String phoneNumber) async {
    var url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  
  TextSpan renderText(string) {
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    RegExp exp = new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    List list = string.replaceAll("\n", " \n").split(" ");
    return TextSpan(
      style: const TextStyle(fontSize: 16, height: 1.4),
      children: list.map<TextSpan>((e){
        Iterable<RegExpMatch> matches = exp.allMatches(e);
        bool isLink = false;
        if (e.startsWith('\n')) isLink = e.startsWith('\nhttp');
        else isLink = e.startsWith('http');
        if (matches.length > 0 && isLink) {
          return TextSpan(
            children: [
              TextSpan(
                text: e,
                style: matches.length > 0
                  ? TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, decoration: TextDecoration.underline)
                  : TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)),
                recognizer: TapGestureRecognizer()..onTap = matches.length > 0 && !isShift ? () {
                  Utils.openUrl(e);
                } : null,
              ),
              TextSpan(text: " ")
            ]
          );
        } else {
          String textRender = e;
          if(!textRender.endsWith('\n')) {
            textRender = textRender + ' ';
          }
          if(validatePhoneNumber(textRender)) {
            return TextSpan(
              text: textRender,
              style: TextStyle(color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight, decoration: TextDecoration.underline),
              recognizer: TapGestureRecognizer()..onTap = () {
                makingPhoneCall(textRender.trim());
              }
            );
          }
          else {
            return TextSpan(
              text: textRender,
              style: TextStyle(color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
            );
          }
        }
      }).toList()
    );
  }

  renderTextMention(att, isDark, user, dm) {
    return att["data"].map((e){
      if (e["type"] == "text" && Utils.checkedTypeEmpty(e["value"])) return e["value"];
      if (e["name"] == "all" || e["type"] == "all") return "@all ";

      if (e["type"] == "issue") {
        return "";
      } else {
        if (widget.isChannel) {
          return Utils.checkedTypeEmpty(e["name"]) ? "@${e["name"]} " : "";
        } else {
          var u = dm == null ? [] : dm.user.where((element) => element["user_id"] == e["value"]).toList();
          return u.length > 0 ? "@${u[0]["full_name"]} " : "";
        }
      }
    }).toList().join("");
  }

  parseTime(dynamic time) {
    var messageLastTime = "";
    if (time != null) {
      DateTime dateTime = DateTime.parse(time);
      final messageTime = DateFormat('kk:mm').format(DateTime.parse(time).add(Duration(hours: 7)));
      final dayTime = DateFormatter().getVerboseDateTimeRepresentation(dateTime, "en");

      messageLastTime = "$dayTime at $messageTime";
    }
    return messageLastTime;
  }

  @override
  Widget build(BuildContext context) {
    final appInChannel = Provider.of<Channels>(context, listen: true).appInChannels;
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    if (widget.attachments == null || widget.attachments.length  == 0) return Container();
    final token  =  Provider.of<Auth>(context, listen: false).token;
    final user = Provider.of<User>(context,listen: false).currentUser;
    var indexDM = Provider.of<DirectMessage>(context, listen: true).data.indexWhere((element) => element.id == widget.conversationId);
    final dm = indexDM  == -1 ? Provider.of<DirectMessage>(context, listen: true).directMessageSelected : Provider.of<DirectMessage>(context, listen: true).data[indexDM];
    List newAttachments = List.from(widget.attachments).where((e) => !(e["mime_type"] == "image" || e["type"] == "image")).toList();
    List images = (widget.attachments ?? []).where((e) => e["mime_type"] == "image" || e["type"] == "image").toList();
    newAttachments.add({"type": "image", "data": images});
    final index = newAttachments.indexWhere((e) => e['mime_type'] == 'share' || e['mime_type'] == "shareforwar");
    if(index != -1) {
      final share = newAttachments[index];
      newAttachments.removeAt(index);
      newAttachments.insert(0, share);
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
          newAttachments.map<Widget>((att) {
            switch (att["type"]) {
              case "preview":
                return LinkPreview(url: att["url"], info: att["web_info"]);
              case "change_issue":
              case "delete_issue":
                return RenderIssueTimeline(att: att);
              case "error_log":
                return ErrorLog(att: att);
              case "poll":
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: PollCard(att: att, message: widget.message, onPinnedMessage: widget.onPinnedMessage),
                );
              case "send_to_channel_from_thread":
                if (widget.isThread) return Container();
                var _onTapMention = TapGestureRecognizer();
                var parentMessage = att["parent_message"];
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${S.current.repliedToAThread} ",
                        style: TextStyle(color: isDark ? Colors.white70 : Color(0xFF323F4B))
                      ),
                      TextSpan(
                        text: Utils.checkedTypeEmpty(att["parent_message"]["message"])
                            ? att["parent_message"]["message"]
                            : att["parent_message"]["attachments"][0]["type"] == "mention"
                                ? renderTextMention(att["parent_message"]["attachments"][0], isDark, user, dm)
                                : att["parent_message"]["attachments"][0]["mime_type"] == "image"
                                    ? att["parent_message"]["attachments"][0]["name"]
                                    : "Parent message",
                        style: TextStyle(color: Colors.lightBlue[400], fontSize: 15, height: 1.5),
                        recognizer: _onTapMention..onTap = () =>
                            Provider.of<Messages>(context, listen: false).openThreadMessage(true, parentMessage),
                      ),
                    ]
                  )
                );
              case "order":
                return OrderAttachment(att: att, id: widget.id);
              case "message_start":
                return Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(right: 32, bottom: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFFfff7e6),
                      borderRadius: BorderRadius.circular(8)
                    ),
                  child: Text(att["data"], style: TextStyle(color: Color(0xFFfa8c16)),)
                  ),
                ) ;
              case "device_info":
                var time  = att["data"]["request_time"] == null ? "_" :  DateTime.fromMicrosecondsSinceEpoch(att["data"]["request_time"]);
                var deviceInfo = att["data"]["device_info"];
                return Container(
                  margin: EdgeInsets.only(top: 4,bottom: 10),
                  child: Column(
                    children: [
                      att["attachments_v2"] ?? false ? Column(
                        children: [
                          Text.rich(
                            TextSpan(
                              style: TextStyle(height: 1.57),
                              children: [
                                TextSpan(text: "${S.current.aNewDevice}  "),
                                TextSpan(text: "($deviceInfo)", style: TextStyle(fontWeight: FontWeight.w700)),
                                TextSpan(text:" ${S.current.request.toLowerCase()} ${S.current.syncData.toLowerCase()}"),
                              ]
                            )
                          ),
                          SizedBox(height: 4,),
                          Container(
                            margin: EdgeInsets.only(top: 9,bottom: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: isDark ?Color(0xff4C4C4C) : Color(0xffDBDBDB),
                                  width: 1.0,
                                ),
                              )
                            ),
                          )
                        ],
                      ) : SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text(S.current.deviceId, style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 14, fontWeight: FontWeight.w600),),
                        Text("${Utils.getString(att["data"]["device_id"], 20)}", overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D),))
                      ],),
                      Container(height: 5),
                      Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Text("${S.current.requestTime}:", style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D), fontSize: 14, fontWeight: FontWeight.w600)),
                        att["data"]["request_time"] == null ? Container() : Text("$time",overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D),))
                      ],),

                    ],
                  )
                );
              case "action_button":
                return Row(
                  children: att["data"].map<Widget>((ele){
                    return Expanded(
                      child: Container(
                        padding: EdgeInsets.only(bottom: 16),
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFFAAD14)),
                          ),
                          onPressed: ()async {
                            String url  = "${Utils.apiUrl}users/logout_device?token=$token";
                            LazyBox box = Hive.lazyBox('pairkey');
                            await Dio().post(url, data: {
                              "current_device": await box.get("deviceId"),
                              "data": await Utils.encryptServer({"device_id": ele["data"]["device_id"], "message_id": widget.id})
                            });

                          },
                          child: Text(S.current.logoutThisDevice, style: TextStyle( color: Color(0xff3D3D3D) )),
                        ),
                      ),
                    );
                  }).toList(),
                );
              case "mention":
                List data = att["data"];
                List newAtts = [];
                Map b = {
                  "type": data[0]["type"],
                  "data": []
                };
                
                for(final i in data){
                  String type = "";
                  if (["block_code"].contains(i["type"]) && i["isThreeBackstitch"] == true) {
                    type = "block_code";
                    if(b['data'].isNotEmpty) {
                      b['data'].last["value"] =  b['data'].last["value"].trimRight();
                    }
                  } 
                  else type = "text";
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

                Widget childText = RichText(
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
                      }
                      return WidgetSpan(
                        child: Text.rich(
                          TextSpan(
                            children: ele.map<InlineSpan>((e) {
                              if (e["type"] == "text") {
                                // return Utils.checkedTypeEmpty(e["value"].trim()) ? renderText(e["value"]) : TextSpan();
                                return renderText(e["value"]);
                              }
              
                              if (e["name"] == "all" || e["type"] == "all") {
                                return TextSpan(
                                  text: "@all ", 
                                  style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 15.5, height: 1.5)
                                );
                              }
              
                              if (e["type"] == "issue") {
                                return WidgetSpan(
                                  child: MentionIssue(e: e)
                                );
                              } else if(e['type'] == 'block_code') {
                                return TextSpan(
                                  text: '\u00A0' +  e["value"] + '\u00A0',
                                  style: GoogleFonts.robotoMono(
                                    height: 1.67,
                                    fontWeight: FontWeight.w300, fontSize: 13.5,
                                    color: isDark ? Palette.calendulaGold : Palette.dayBlue,
                                    backgroundColor: isDark ? Color(0xff1E1E1E) : Color(0xffEDEDED),
                                  ),
                                );
                              } else {
                                if (widget.isChannel) {
                                  return Utils.checkedTypeEmpty(e["name"]) ? TextSpan(
                                    text: "@${e["name"]} ",
                                    style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 15.5, height: 1.5),
                                    recognizer: user["id"] != e["value"] ? (TapGestureRecognizer()..onTap = () => !isShift ? showUserProfile(context,e["value"]) : null) : null,
                                  ) : TextSpan();
                                } else {
                                  return TextSpan(
                                    text:  "${e["trigger"] ?? "@"}${e["name"]} ",
                                    style: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, fontSize: 15.5, height: 1.5),
                                    recognizer: user["id"] != e["value"] ? (TapGestureRecognizer()..onTap = () => e["type"] == "user" ? showUserProfile(context,e["value"]) : null) : null
                                  );
                                }
                              }
                            }).toList()
                          )
                        )
                      );
                    }).toList() + [
                      widget.lastEditedAt != null
                      ? WidgetSpan(
                          child:Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text("(${S.current.edited})", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Color(0xff6c6f71), height: 1.57)),
                          ) 
                        )
                      : TextSpan()
                    ]
                  ),
                  textAlign: TextAlign.left,
                );
                return childText;

              case "block_code":
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: att["data"].map<Widget>((e){
                    if (e["type"] == "block_code" && Utils.checkedTypeEmpty(e["value"].trim())) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: isDark ? Color(0xff3d3d3d) : Color(0xffDBDBDB),
                        ),
                        padding: EdgeInsets.all(6),
                        child: SelectableText(
                          e["value"],
                          style: TextStyle(
                          fontSize: 13, height: 1.5,
                          fontFamily: 'Fira Code',
                          color: isDark ? Color(0xfff3f3f3) : Color(0xff3D3D3D),
                        ),
                        ),
                      );
                    }
                    if (e["type"] == "text" && e["value"] != "") {
                      return Container(
                        child: SelectableText(
                          e["value"],
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isDark ? Color(0xFFd8dcde) : Colors.grey[800],
                            fontWeight: FontWeight.w400, height: 1.3
                          )
                        )
                      );
                    } else {
                      return Container();
                    }
                  }).toList()
                );

              case "BizBanking":
                return defaultAtt(att);

              case "bot" :
                var appId  = att["bot"]["id"];
                var app =  appInChannel.where((element) {return element["app_id"] == appId;}).toList();
                var appName  = " ";
                if (app.length > 0) appName = app[0]["app_name"];
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Text(appName[0], style: TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),),
                          height: 35,
                          width: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFF1890FF),
                            borderRadius: BorderRadius.circular(5)
                          ),
                        ),
                        Container(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appName, style : TextStyle(fontWeight:  FontWeight.w600, fontSize: 15, color: isDark ? Color(0xFFd8dcde) : Colors.grey[800]), textAlign: TextAlign.left, overflow: TextOverflow.ellipsis,),
                            Text("/" + att["data"]["command"] + " ${att["data"]["text"] ?? ""}", style: TextStyle(color: Color(0xFFBFBFBF), fontSize: 10),  textAlign: TextAlign.left)
                          ],
                        )
                      ],
                    ),
                    att["data"]["result"] != null ?
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: isDark ?  Color(0xff4f5660) : Color(0xFFf0f0f0),
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Text(att["data"]["result"]["body"] ?? "", textAlign: TextAlign.left, style: TextStyle(fontSize: 10),),
                      )
                      : Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.all(5),
                        margin: EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: isDark ?  Color(0xff4f5660) : Color(0xFFf0f0f0),
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Text("Processing", style: TextStyle(fontSize: 10),),
                      ),
                    Container(height: 8,)
                  ],
                );

              case "befor_upload":
                return StreamBuilder(
                  stream: StreamUploadStatus.instance.status,
                  builder: (context, status) {
                    double statusUploadAtt = 0.0;
                    if (status.data != null) {
                      try {
                        statusUploadAtt = (status.data as Map)[att["att_id"]];
                      } catch (e) {
                        statusUploadAtt = 1.0;
                      }
                    }
                    return Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.only(bottom: 5, top:  att["success"] == null || att["success"] ? 0 : 5),
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xFF434343) : Color(0xFFf0f0f0),
                        borderRadius: BorderRadius.all(Radius.circular(8))
                      ),
                      child: Opacity(
                        opacity: att["success"] == null || att["success"] ? 1: 0.2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Container(child: Text((att["success"] == null || att["success"] ? "Uploading" : "Upload fail") + " ${att["name"] ?? ""}", overflow: TextOverflow.ellipsis,))),
                            Text(statusUploadAtt == 1.0 ? "processing": "${(statusUploadAtt * 100.0).round()} %"),
                          ],
                        ),
                      )
                    );
                  }
                );
              case "invite":
                final channelId = (att["data"] ?? {})["channel_id"] ?? null;
                final workspaceId = (att["data"] ?? {})["workspace_id"];
                final inviteUser = (att["data"] ?? {})["invite_user"];
                final inviteUserName = (att["data"] ?? {})["full_name"];
                final channelName = (att["data"] ?? {})["channel_name"];
                final workspaceName = (att["data"] ?? {})["workspace_name"];
                final GlobalKey key = GlobalKey();
                final isAccepted = (att["data"] ?? {})["isAccepted"] ?? null;
                final bool isWorkspace = att["data"]["is_workspace"] ?? false;

                return Container(
                  key: key,
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.only(bottom: 15),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      att["attachments_v2"] ?? false ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              style: TextStyle(height: 1.57),
                              children: [
                                TextSpan(text: inviteUserName, style: TextStyle(fontWeight: FontWeight.w700)),
                                TextSpan(text: " ${S.current.hasInviteYouTo} "),
                                TextSpan(text: isWorkspace ? workspaceName : channelName, style: TextStyle(fontWeight: FontWeight.w700)),
                                TextSpan(text: isWorkspace ? " ${S.current.workspace}" :" ${S.current.channel}"),
                              ]
                            )
                          ),
                          SizedBox(height: 4,)
                        ],
                      ) : SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor: isAccepted == null ? MaterialStateProperty.all(Colors.blue) : MaterialStateProperty.all(isDark ? Color(0xff5E5E5E): Color(0xffA6A6A6),
                                ),
                              ),
                              onPressed: isAccepted == null ? () async{
                                if (channelId != null) {
                                  Provider.of<Channels>(context, listen: false).joinChannelByInvitation(token, workspaceId, channelId, user["email"], 1, inviteUser, widget.id).then((value){
                                    showDialog(
                                      context: context,
                                      builder: (_) {
                                        return CupertinoAlertDialog(
                                          title: Text(value),
                                        );
                                      },
                                    );
                                  }
                                );
                              } else {
                                Provider.of<Workspaces>(context, listen: false).joinWorkspaceByInvitation(token, workspaceId, user["email"], 1, inviteUser, widget.id).then((value) {
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return CupertinoAlertDialog(
                                        title: Text(value),
                                      );
                                    }
                                  );
                                });
                              }
                            } : (){},
                            child: Container(
                              width: MediaQuery.of(context).size.width / 4,
                              child: Center(child: isAccepted == null || isAccepted == false ? Text(S.current.accept, style: TextStyle(color: Colors.white)) : Text(S.current.accepted, style: TextStyle(color: Color(0xffffffff))))
                            ),
                          ),
                        ),
                        SizedBox(width: 8,),
                        Expanded(
                          child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: isAccepted == null ? MaterialStateProperty.all(Colors.red) : MaterialStateProperty.all(isDark ? Color(0xff5E5E5E): Color(0xffA6A6A6)),
                            ),
                            onPressed: isAccepted == null ? () {
                              if(channelId != null){
                                Provider.of<Channels>(context, listen: false).declineInviteChannel(token, workspaceId, channelId, inviteUser, widget.id).then((value){
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return CupertinoAlertDialog(
                                        title: Text(value),
                                      );
                                    }
                                  );
                                });
                              }
                              else {
                                Provider.of<Workspaces>(context, listen: false).declineInviteWorkspace(token, workspaceId, inviteUser, widget.id).then((value){
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return CupertinoAlertDialog(
                                        title: Text(value),
                                      );
                                    }
                                  );
                                });
                              }
                            } : () {},
                            child: Container(
                              width: MediaQuery.of(context).size.width / 4,
                              child: Center(child: isAccepted == null || isAccepted == true ? Text(S.current.discard,  style: TextStyle(color: Color(0xffffffff))) : Text(S.current.discarded,  style: TextStyle(color: Colors.black)))
                            ),
                          ),
                        )
                      ],
                      ),
                    ],
                  )
                );
              case "image":
                if (att["data"].length > 0) return ImagesGallery(isChildMessage: widget.isChildMessage, att: att, isThread: false, isConversation: !(widget.isChannel ?? false), id: widget.id ?? "", conversationId: widget.conversationId,);
                return Container();

              case "assign":
                var channelId = att["data"]["channel_id"];
                var workspaceId = att["data"]["workspace_id"];
                var issueId = att["data"]["issue_id"];
                String assignUser = att["data"]["full_name"] ?? "";
                String channelName = att["data"]["channel_name"] ?? "";
                bool isAssign = att["data"]["assign"];

                return Container(
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.only(bottom: 16,),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      att["attachments_v2"] ?? false ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              style: TextStyle(height: 1.57),
                              children: [
                                TextSpan(text: assignUser, style: TextStyle(fontWeight: FontWeight.w700)),
                                TextSpan(text: " ${S.current.hass} ${isAssign ? "${S.current.assign}" : "${S.current.unassign}"} ${S.current.youInAnIssueIn} "),
                                TextSpan(text: "${S.current.channel} "),
                                TextSpan(text: channelName, style: TextStyle(fontWeight: FontWeight.w700)),
                              ]
                            )
                          ),
                          SizedBox(height: 4,)
                        ],
                      ) : SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Provider.of<Channels>(context, listen: false).selectChannel(Provider.of<Auth>(context, listen: false).token, workspaceId, channelId);
                                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
                                  return IssueInfo(
                                    issue: {
                                      "id": issueId,
                                      "channel_id": channelId,
                                      "workspace_id": workspaceId,
                                      "comments_count": 0,
                                      "is_closed": false,
                                      "title": "",
                                      "comments": [],
                                      "timelines": [],
                                      "assignees": []
                                    },
                                    isJump: true
                                  );
                                }));
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Color(0xff1890FF)),
                              ),
                              child: Text(S.current.reviewIssue, style: TextStyle(color: Color(0xffffffff)))
                            ),
                          ),
                          SizedBox(width: 8,),
                        ],
                      ),
                    ],
                  ),
                );
              case "close_issue":
                var channelId = att["data"]["channel_id"];
                var workspaceId = att["data"]["workspace_id"];
                var issueId = att["data"]["issue_id"];
                var isClosed = att["data"]["is_closed"] ?? att["data"]["is_close"];
                var assignUser = att["data"]["assign_user"];
                var channelName = att["data"]["channel_name"];
                var issueAuthor = att["data"]["issue_author"] ?? "";
                var userId = att["data"]["user_id_assign"];
                return Container(
                  margin: EdgeInsets.only(top: 4),
                  padding: EdgeInsets.only( bottom: 15),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      att["attachments_v2"] ?? false ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              style: TextStyle(height: 1.57),
                            children: att["data"]["user_watching"] ?? false ? [
                              TextSpan(
                                recognizer: new TapGestureRecognizer()..onTapUp = (_) => showInfo(context,userId),
                                text: assignUser,
                                style: TextStyle(fontWeight: FontWeight.w700,color: isDark ? Palette.calendulaGold : Palette.dayBlue , fontSize: 15)),
                              TextSpan(text: " ${S.current.hass} ${isClosed ? "${S.current.tClosed}" : "${S.current.reopen}"} ${S.current.anIssue}"),
                              TextSpan(text: issueAuthor, style: TextStyle(fontWeight: FontWeight.w500)),
                              TextSpan(text: " ${S.current.createdIn} "),
                              TextSpan(text: "${S.current.channel} "),
                              TextSpan(text: channelName),
                            ] : [
                              TextSpan(
                                recognizer: new TapGestureRecognizer()..onTapUp = (_) => showInfo(context,userId),
                                text: assignUser,
                                style: TextStyle(fontWeight: FontWeight.w700,color: isDark ? Palette.calendulaGold : Palette.dayBlue , fontSize: 15)),
                              TextSpan(text: " ${S.current.hass} ${isClosed ? "${S.current.tClosed}" : "${S.current.reopen}"} ${S.current.anIssueYouHasBeenAssignIn} "),
                              TextSpan(text: "${S.current.channel} "),
                              TextSpan(text: channelName),
                            ]
                            )
                          ),
                          SizedBox(height: 4,)
                        ],
                      ) : SizedBox(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextButton(
                              child: Text(S.current.reviewIssue, style: TextStyle(color: Colors.white)),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Colors.red),
                                // fixedSize: MaterialStateProperty.all(Size.fromWidth(165))
                              ),
                              onPressed: () {
                                Provider.of<Channels>(context, listen: false).selectChannel(Provider.of<Auth>(context, listen: false).token, workspaceId, channelId);
                                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
                                  return IssueInfo(
                                    issue: {
                                      "id": issueId,
                                      "channel_id": channelId,
                                      "workspace_id": workspaceId,
                                      "comments_count": 0,
                                      "is_closed": false,
                                      "title": "",
                                      "comments": [],
                                      "timelines": [],
                                      "assignees": []
                                    },
                                    isJump: true
                                  );
                                }));
                              },
                            ),
                          ),
                          SizedBox(width: 8,),
                          Expanded(
                            child: TextButton(
                              child: Text(isClosed ? S.current.reopenIssue : S.current.closeIssue, style: TextStyle(color: Colors.white)),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(isDark ? Color(0xff5E5E5E): Color(0xffA6A6A6)),
                              ),
                              onPressed: (){},
                            ),
                          )
                        ]
                      ),
                    ],
                  ),
                );
              case "call_terminated":
                String timerCounter = att["data"]["timerCounter"] ?? "0:00";
                String mediaType = att["data"]["mediaType"] ?? "video";
                return Container(
                  padding: EdgeInsets.all(20.0),
                  width: 150,
                  decoration: BoxDecoration(
                    color: isDark ?Colors.white38 : Colors.grey,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(mediaType == "video" ? PhosphorIcons.videoCameraLight : PhosphorIcons.phoneThin),
                          Text(timerCounter),
                        ],
                      ),
                      Divider(thickness: 1.0, color: Colors.white),
                      TextButton(
                        onPressed: (){
                          final indexOtherUser = dm.user.indexWhere((e) => e["user_id"] != user["id"]);
                          final otherUser = indexOtherUser == -1 ? {} : dm.user[indexOtherUser];

                          if (mediaType == "video") {
                            callManager.calling(context, otherUser, dm.id);
                          }
                        },
                        child: Text("Gọi lại", style: TextStyle(color: isDark ? Colors.white : Colors.black),),
                      ),
                    ],
                  ),
                );
              case 'sticker':
                return StickerFile(key: Key(widget.id.toString()), data: att['data']);
              case "timesheets_attendance":
                final attendanceType = att["data"]["type"];
                final date = att["data"]["date"];
                final isToday = DateFormat("yyyy-MM-dd").format(DateTime.now()) == date;
                final disable = att["data"]["disable"] ?? false;
                return Container(
                  child: TextButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(isToday && !disable ? Colors.yellow : Colors.grey),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    onPressed: isToday && !disable ? () {
                      final workspaceId = att["data"]["workspace_id"];
                      final shiftId = att["data"]["shift_id"];
                      if (attendanceType == "check_in") {
                         Provider.of<Workspaces>(context, listen: false).handleCheckin(context, workspaceId, shiftId);
                      }
                      else {
                        Provider.of<Workspaces>(context, listen: false).handleCheckout(context, workspaceId, shiftId);
                      }
                    } : null,
                    child: attendanceType == "check_in" ? Text("Check in") : Text("Check out"),
                  ),
                );
              case "snappy_timesheets":
                final data = att["data"];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10, top: 5),
                      child: Text(widget.message['message'])
                    ),
                    Container(
                      height: 32,
                      margin: EdgeInsets.only(right: 12, bottom: 5),
                      child: OutlinedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Palette.calendulaGold),
                        ),
                        onPressed: () => onCheckSnappyTimesheets(context, data, widget.id),
                        child: Text(
                          "Xem đơn duyệt",
                          style: TextStyle(color: isDark ? Palette.darkPrimary : Palette.defaultTextLight),),
                      ),
                    ),
                  ],
                );

              default:
                switch (att["mime_type"]) {
                  case "share":
                  // Render share Channel
                    if(att["data"]["channelId"] != null) {
                      return ShareAttachments(att: att);
                    } else return ShareAttachments(att: att, isChannel: false);
                  case "shareforwar":
                  // Render share Channel
                    if(att["data"]["channelId"] != null) {
                      return ShareAttachments(att: att);
                    } else return ShareAttachments(att: att, isChannel: false);
                  case "html":
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isDark ? Color(0xFF1D2C3B) : Colors.grey[200],
                        border: Border.all(
                          color: isDark ? Color(0xff334E68) : Colors.grey[400]!,
                          width: 0.5
                        ),
                      ),
                      padding: EdgeInsets.all(8),
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => Utils.openUrl(att["content_url"]),
                        child: Container(
                          child: RichText(
                            text: TextSpan(
                              text: widget.snippet,
                              style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 13, height: 1.5,
                                color: isDark ? Colors.white70 : Colors.grey[800]
                              ),
                              children: [
                                TextSpan(
                                  text: "\nSee more ...",
                                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13, color: Colors.blueAccent)
                                )
                              ]
                            )
                          ),
                        )
                      )
                    );

                  case "block_code":
                    return Container(
                      margin: EdgeInsets.only(right: 16, top: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isDark ? Color(0xff2E2E2E) : Color(0xffDBDBDB)
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: SelectableText(
                        widget.blockCode ?? "",
                        style: TextStyle(
                          fontSize: 13, height: 1.5,
                          fontFamily: 'Fira Code',
                          color: isDark ? Color(0xfff3f3f3) : Color(0xff3D3D3D),
                        ),
                      ),
                    );
                  case "quicktime":
                  case "mov":
                  case "MOV":
                  case "MP4":
                  case "mp4":
                    if (att["content_url"] != null) {
                      String contentUrl = att["content_url"] ?? "";
                      if (contentUrl.toLowerCase().contains(".mp4") || contentUrl.toLowerCase().contains(".mov")) {
                        if(widget.isChannel)
                          return VideoCard(
                            // key: Key(att["content_url"]),
                            contentUrl: contentUrl,
                            id: widget.id,
                            isDirect: !widget.isChannel,
                            thumnailUrl: att["url_thumbnail"],
                          );
                        else {
                          return VideoConversation(content: att, messageId: widget.id, conversationId: widget.conversationId ?? "");
                        }
                      }
                      var tag  = Utils.getRandomString(30);
                      return GestureDetector(
                        onTap: () => showBottomSheetImage(context, att["content_url"], widget.id, tag, att),
                        child: Hero(
                          tag: tag,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                              maxHeight: MediaQuery.of(context).size.height * 0.5
                            ),
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: CachedImage(
                              att["content_url"],
                              radius: 10,
                              fit: BoxFit.cover,
                            )
                          ),
                        )
                      );

                    } else return defaultAtt(att);

                  case "image":
                    var tag  = Utils.getRandomString(30);
                    return GestureDetector(
                      onTap: () => showBottomSheetImage(context, att["content_url"], widget.id, tag, att),
                      child: Hero(
                        tag: tag,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                            maxHeight: MediaQuery.of(context).size.height * 0.5
                          ),
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: CachedImage(
                            att["content_url"],
                            radius: 10,
                            fit: BoxFit.cover,
                          )
                        ),
                      )
                    );
                  case "m4a":
                    if (!widget.isChannel) return RecordDirect.build(context, att["content_url"]);
                    return AudioPlayerMessage(
                      source: AudioSource.uri(Uri.parse(att["content_url"])),
                      att: att,
                    );
                  default:
                    String type = Utils.getLanguageFile((att["mime_type"] ?? '').toLowerCase());
                    int index = Utils.languages.indexWhere((ele) => ele == type);
                    return (att["name"] ?? "").toLowerCase().contains(".heic") ? ImagesGallery(
                      isChildMessage: widget.isChildMessage, att: {"data": [att]}, isThread: widget.isThread,  isConversation: !widget.isChannel, id: widget.id, conversationId: widget.conversationId,
                    ) : (index != -1 ? TextFile(att: att, isChannel: widget.isChannel) : defaultAtt(att));
                }
            }
          }
        ).toList(),
      ),
    );
  }

  Widget defaultAtt(Map att){
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return  Container(
      margin: EdgeInsets.only(top: 3, bottom: 3),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_)  {
              return CustomDialogNew(
                title: S.current.downloadAttachment,
                content: "${S.current.doYouWantToDownload} ${att["name"]}",
                confirmText: S.current.download,
                onConfirmClick: () async {
                  if (Utils.checkedTypeEmpty(widget.conversationId)){
                    try {
                      DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.conversationId);
                      if (dm == null) {
                        Provider.of<DirectMessage>(Utils.globalContext!, listen: false).getLocalPathAtts(
                          [
                            {
                              "attachments": [att],
                              "id": "unkonw",
                              "conversation_id": "unkonw",
                              "time_create": DateTime.now().toString(),
                              "user_id": "unkonw",
                            }
                          ]
                        );
                      } else {
                        Map? m = await MessageConversationServices.getListMessageById(dm, widget.id, widget.conversationId);
                        if (m!= null) Provider.of<DirectMessage>(context, listen: false).getLocalPathAtts([m], forceDownload: true);                        
                      }
                    } catch (e) {

                    }                    
                  }
                  Provider.of<Work>(context, listen: false).addTaskDownload(att);
                  Fluttertoast.showToast(
                    msg: S.current.startDownloading,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    fontSize: 13
                  );
                  Navigator.pop(context);
                },
                quickCancelButton: true,
              );
            }
          );
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color(0xFFd9d9d9)
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            minWidth: 0.0
          ),
          child: 
          Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.download_rounded, size: 15, color: Color(0xFF595959)),
                  ),
                ),
                WidgetSpan(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 150,
                      minWidth: 0.0
                    ),
                    child: Text(att["name"] ?? "", style: TextStyle(overflow: TextOverflow.ellipsis, color: isDark ? Palette.borderSideColorDark : Color.fromARGB(255, 108, 106, 106)))),
                ),
              ]
            )
          )
        ),
      ),
    );
  }
  onCheckSnappyTimesheets(context, data, messageId) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0)),
          backgroundColor: isDark ? Palette.defaultBackgroundDark : Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 600,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey))),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Đơn ${data['type'] == 0 ? 'tăng ca' : data['type'] == 1 ? 'điều chỉnh checkin/out' : data['type'] == 2 ? 'xin ra ngoài' : data['type'] == 3 ? 'xin nghỉ phép' : 'NULL'}", style: TextStyle(fontSize: 15)),
                      ],
                    )
                  ),
                  if (data["date"] != null) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text("Ngày: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                        Text("${data["date"]}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14))
                      ],
                    )
                  ),
                  SizedBox(height: 10),
                  if (data["start_time"] != null && data["end_time"] != null && data["date"] == null) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text("Ngày: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                        Text("${DateFormat("y-M-d").format(DateTime.parse(data["start_time"]))}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14))
                      ],
                    )
                  ),
                  if (data["start_time"] != null && data["end_time"] != null) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text("Thời gian: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                        Text("${DateFormat("kk:mm").format(DateTime.parse(data["start_time"]))}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                        Text(" : "),
                        Text("${DateFormat("kk:mm").format(DateTime.parse(data["end_time"]))}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14))
                      ],
                    )
                  ),
                  if (data["reason"] != null) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text("Lý do: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                        Text("${data["reason"]}", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14))
                      ],
                    )
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Text("Người duyệt: ", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14)),
                        Text(data["approver_name"] ?? "", style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14))
                      ],
                    )
                  ),
                  Container(
                    decoration: BoxDecoration(border: Border(top: BorderSide(width: 0.2, color: Colors.grey))),
                    padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 11),
                    margin:  const EdgeInsets.only(top: 10),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        data['is_approved']
                          ? Icon(CupertinoIcons.checkmark_seal, color: Colors.green)
                          : Icon(CupertinoIcons.xmark_seal, color: Colors.red),
                        SizedBox(width: 5),
                        Text(data['is_approved'] ? "Đã phê duyệt" : "Đã huỷ")
                      ],
                    ),
                  ),
                ],
              ),
            )
          ),
        );
      }
    );
  }
}


showBottomSheetImage(context, url, id, tag, att) {
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    builder: (BuildContext context) {
      return ImageDetail(url: url, id: id, full: true, tag: tag, att: att );
    }
  );
}
// thread message not replied, only edit
showBottomActionMessage(context, idMessage, keyDB, onEditMessage, copyMessage, isChildMessage, userId, isChannel){
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: true,
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    builder: (BuildContext context) {
      return DMActionMessage(
        idMessage: idMessage,
        keyDB: keyDB,
        onEditMessage: onEditMessage,
        copyMessage: copyMessage,
        isChildMessage: isChildMessage == null ? true : isChildMessage,
        userId: userId,
        isChannel: isChannel
      );
    }
  );
}
class MentionIssue extends StatefulWidget {
  MentionIssue({
    Key? key,
    this.e,
  }) : super(key: key);

  final e;

  @override
  _MentionIssueState createState() => _MentionIssueState();
}

class _MentionIssueState extends State<MentionIssue> {
  var hoveringIssue;
  bool getDataIssue = false;
  String message = "";
  bool accessIssue = true;

  @override
  void initState() {
    super.initState();

    try {
      List preloadIssues = Provider.of<Workspaces>(context, listen: false).preloadIssues;
      final index = widget.e["value"].split("-").length > 2 ?
        preloadIssues.indexWhere((e) => e["id"].toString() == widget.e["value"].split("-")[0].toString()
        && e["channel_id"].toString() == widget.e["value"].split("-")[2].toString()) : -1;
      accessIssue = index != -1;
    } catch (e) {
      print("get access issue ${e.toString()}");
    }
  }

  onHovering(value) async {
    if (this.mounted){
      this.setState(() {
        hoveringIssue = value;
      });
    }

    if (!getDataIssue && value != null) {
      try {
        final token = Provider.of<Auth>(context, listen: false).token;
        var issueId = value.split("-")[0];
        var workspaceId = value.split("-")[1];
        var channelId = value.split("-")[2];
        final url = Utils.apiUrl + 'workspaces/$workspaceId/channels/$channelId/issues/get_access_issue?token=$token&issue_id=$issueId';
        final response = await Utils.getHttp(url);

        if (response["success"] == true) {
        } else {
          setState(() {
            message = response['message'] ?? "";
          });
        }
        getDataIssue = true;
      } catch (e) {
        print("onHovering attachment_card_desktop ${e.toString()}");
        getDataIssue = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.e;
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    var channelId = e["channel_id"];
    var workspaceId = e["workspace_id"];
    var issueId = e["id"];
    return PortalEntry(
      visible: e["value"] == hoveringIssue,
      portalAnchor: Alignment.bottomCenter,
      childAnchor: Alignment.topCenter,
      portal: message == "" ? Container() : Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Color(0xff1E1E1E),
          borderRadius: BorderRadius.all(Radius.circular(4))
        ),
        child: Text(message, style: TextStyle(color: Palette.defaultTextDark)),
      ),
      child: InkWell(
        onTap: accessIssue ? () {
          Provider.of<Channels>(context, listen: false).selectChannel(Provider.of<Auth>(context, listen: false).token, workspaceId, channelId);
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
            return IssueInfo(
              issue: {
                "id": issueId,
                "channel_id": channelId,
                "workspace_id": workspaceId,
                "comments_count": 0,
                "is_closed": false,
                "title": "",
                "comments": [],
                "timelines": [],
                "assignees": []
              },
              isJump: true
            );
          }));
        } : null,
        child: MouseRegion(
          onExit: (value) { onHovering(null); },
          onEnter: (value) { onHovering(e["value"]); },
          child: Container(
            height: 21.5,
            child: Text(
              "#${e["name"]}",
              style: TextStyle(color: accessIssue ? (isDark ? Palette.calendulaGold : Palette.dayBlue) : Colors.grey[600], fontSize: 15.2, height: 1.5)
            ),
          )
        )
      )
    );
  }
}