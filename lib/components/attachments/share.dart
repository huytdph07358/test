import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/attachment_card.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';

class ShareAttachments extends StatefulWidget {
  final att;
  final bool isChannel;

  const ShareAttachments({
    Key? key,
    required this.att,
    this.isChannel = true
  }) : super(key: key);

  @override
  State<ShareAttachments> createState() => _ShareAttachmentsState();
}

class _ShareAttachmentsState extends State<ShareAttachments> {
  parseTime(dynamic time) {
    final auth = Provider.of<Auth>(context);
    var messageLastTime = "";
    if (time != null) {
      DateTime dateTime = DateTime.parse(time);
      final messageTime = DateFormat('kk:mm').format(DateTime.parse(time).add(Duration(hours: 7)));
      final dayTime = DateFormatter().getVerboseDateTimeRepresentation(dateTime, auth.locale);

      messageLastTime = "$dayTime ${S.current.ats} $messageTime";
    }
    return messageLastTime;
  }

  onSelectMessage(Map message){
    Provider.of<Messages>(context, listen: false).handleProcessMessageToJump(message, context);
  }

  Widget shareDM(auth, att, isDark) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: IntrinsicHeight(
        child: Row(
          children: [
            VerticalDivider(thickness: 3, width: 3, color: Colors.white,),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff474747) : Color(0xffDFDFDF),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4),),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Text("${S.current.repliedTo} ", style: TextStyle(fontStyle: FontStyle.italic)),
                          CachedAvatar(
                            att["data"]["avatar_url"] ?? att["data"]["avatarUrl"],
                            height: 18, width: 18,
                            isRound: true,
                            name: att["data"]["fullName"],
                            isAvatar: true,
                            fontSize: 13,
                          ),
                          SizedBox(width: 5),
                          Text(att["data"]["userId"] != auth.userId ?( att["data"]["full_name"] ?? att["data"]["fullName"] ?? "") : "Yourself")
                        ],
                      ),
                    ),
                    SizedBox(height: 3),
                    Utils.checkedTypeEmpty( att["data"]["is_unsent"] ?? att["data"]["isUnsent"])
                      ? Container(
                        height: 19,
                        child: Text(
                          S.current.thisMessageWasDeleted,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Color(isDark ? 0xffe8e8e8 : 0xff898989)
                          ),
                        )
                      )
                      : (att["data"]["message"] != "" && att["data"]["message"] != null)
                        ? Container(
                          padding: EdgeInsets.only(left: 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(att["data"]["message"]),
                              att["data"]["attachments"] != null && att["data"]["attachments"].length > 0
                                // ? Text("Attachments")
                                ? AttachmentCard(
                                  attachments: att["data"]["attachments"],
                                  isChannel: att["data"]["isChannel"],
                                  id: att["data"]["id"],
                                  isChildMessage: false,
                                  isThread: att["data"]["isThread"] ?? false,
                                  blockCode: att['data']['block_code'],
                                  // lastEditedAt: parseTime(att["data"]["lastEditedAt"])
                                )
                                : Container()
                            ],
                          ),
                        )
                        : att["data"]["attachments"] != null && att["data"]["attachments"].length > 0
                          ? Container(
                            padding: EdgeInsets.only(left: 3),
                            // child: Text("Attachments")
                            child: AttachmentCard(
                              attachments: att["data"]["attachments"],
                              isChannel: att["data"]["isChannel"] ?? att["data"]["is_channel"] ?? Utils.checkedTypeEmpty(att["data"]["channel_id"] ?? att["data"]["channelId"]),
                              id: att["data"]["id"],
                              isChildMessage: false,
                              isThread: false,
                              conversationId: att["data"]["conversationId"] ?? att["data"]["conversation_id"],
                              blockCode: att['data']['block_code'],
                              // lastEditedAt: parseTime(att["data"]["lastEditedAt"])
                            )
                          )
                          : Container(),
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget shareChannel(auth, att, isDark) {
    final channels = Provider.of<Channels>(context, listen: false).data;
    int indexCN = channels.indexWhere((e) => e['id'] == (att["data"]["channel_id"] ?? att["data"]["channelId"]));
    return indexCN == -1 ? shareDM(auth, att, isDark) : Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.only(left: 10, top: 4,bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? Color(0xff474747) : Color(0xffDFDFDF),
        border: Border(
          left: BorderSide(
            color: Color(0xffd0d0d0),
            width: 3.0,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              children: [
                CachedAvatar(
                  att["data"]["avatar_url"] ?? att["data"]["avatarUrl"] ?? "",
                  height: 18, width: 18,
                  isRound: true,
                  name: att["data"]["full_name"] ?? att["data"]["fullName"] ?? "",
                  isAvatar: true,
                  fontSize: 13,
                ),
                SizedBox(width: 5),
                Text(att["data"]["full_name"] ?? att["data"]["fullName"] ?? "")
              ],
            ),
          ),
          SizedBox(height: 3),
          Utils.checkedTypeEmpty(att["data"]["isUnsent"])
            ? Container(
              height: 19,
              child: Text(
                "[This message was deleted.]",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Color(isDark ? 0xffe8e8e8 : 0xff898989)
                ),
              )
            )
            : (att["data"]["message"] != "" && att["data"]["message"] != null)
              ? Container(
                padding: EdgeInsets.only(left: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(att["data"]["message"]),
                    att["data"]["attachments"] != null && att["data"]["attachments"].length > 0
                      // ? Text("Attachments")
                      ? AttachmentCard(
                        attachments: att["data"]["attachments"],
                        isChannel: att["data"]["isChannel"],
                        id: att["data"]["id"],
                        isChildMessage: false,
                        isThread: att["data"]["isThread"] ?? false,
                        blockCode: att['data']['block_code'],
                        // lastEditedAt: parseTime(att["data"]["lastEditedAt"])
                      )
                      : Container()
                  ],
                ),
              )
              : att["data"]["attachments"] != null && att["data"]["attachments"].length > 0
                ? Container(
                  padding: EdgeInsets.only(left: 3),
                  // child: Text("Attachments")
                  child: AttachmentCard(
                    attachments: att["data"]["attachments"],
                    isChannel: att["data"]["isChannel"],
                    id: att["data"]["id"],
                    isChildMessage: false,
                    isThread: false,
                    conversationId: att["data"]["conversationId"],
                    blockCode: att['data']['block_code'],
                  )
                ) : Container(),
          SizedBox(height: 5),
          Container(
            child: Row(
              children: [
                channels[indexCN]['is_private']
                  ? SvgPicture.asset('assets/images/icons/Locked.svg', width: 9, color: isDark ? Colors.white70 : Color(0xFF323F4B))
                  : SvgPicture.asset('assets/images/icons/iconNumber.svg', width: 9, color: isDark ? Colors.white70 : Color(0xFF323F4B)),
                SizedBox(width: 3),
                Text(channels[indexCN]["name"] ?? "", style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Color(0xFF323F4B))),
                SizedBox(width: 3),
                Container(width: 1, height: 12, color:  isDark ? Colors.white70 : Color(0xFF323F4B)),
                SizedBox(width: 3),
                Text(parseTime(att["data"]["insertedAt"]), style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Color(0xFF323F4B))),
                SizedBox(width: 3),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      onSelectMessage({
                        ...att["data"],
                        "workspace_id": att["data"]["workspaceId"],
                        "channel_id": att["data"]["channelId"]
                      });
                    },
                    child: Text(S.current.viewMessage, style: TextStyle(fontSize: 12, color: Colors.blue, overflow: TextOverflow.ellipsis)),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final bool isDark = auth.theme == ThemeType.DARK;
    final att = widget.att;

    return !widget.isChannel ? shareDM(auth, att, isDark) : shareChannel(auth, att, isDark);
  }
}