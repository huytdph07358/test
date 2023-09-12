import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/media_conversation/model.dart';
import 'package:workcake/components/media_conversation/stream_media_downloaded.dart';
import 'package:workcake/components/video_card.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/direct_messages_model.dart';
import 'package:workcake/models/models.dart';

class VideoConversation extends StatefulWidget {
  const VideoConversation({Key? key,
    required this.conversationId,
    required this.messageId,
    required this.content, 
    this.customBuild
  }) : super(key: key);

  final content;
  final String messageId;
  final String conversationId;
  final Function? customBuild;

  @override
  State<VideoConversation> createState() => _VideoConversationState();
}

class _VideoConversationState extends State<VideoConversation> {
  String? pathInDevice;

  @override
    initState(){
    super.initState();
    Timer.run(() async {
      try {
        pathInDevice  = await ServiceMedia.getDownloadedPath(widget.content["content_url"]);       
      } catch (e, trace) {
        print("______$e  $trace");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contentUrl = widget.content["content_url"];

    return StreamBuilder(
      stream: StreamMediaDownloaded.instance.status,
      initialData: StreamMediaDownloaded.dataStatus,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) { 
        Map<String, StatusDownloadedAtt> data = snapshot.data ?? {};
        if (data[contentUrl] != null && data[contentUrl]!.status == "downloading"){
          return Container(
            height: 200,
            width: 200,
            child: Center(
              child: Text("Loading..."),
            ),
          );
        }
        if (data[contentUrl] != null) {
          return Container(
            constraints: BoxConstraints(minHeight: 150),
            child: VideoCard(
              id: widget.messageId,
              contentUrl: contentUrl,
              isDirect: true,
              thumnailUrl: null,
              data: data[contentUrl]!.toJson()
            ),
          );
        }

        return GestureDetector(
          onTap: () async {
            DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(widget.conversationId);
            // dm == null => forceDownload, vi day co the la share tu 1 conv ko co minh, danh conversation_id = "unknow", user_id = "unknow"
            if (dm == null) {
              return Provider.of<DirectMessage>(context, listen: false).getLocalPathAtts([{
                "attachments": [widget.content],
                "id": "unkonw",
                "conversation_id": "unkonw",
                "time_create": DateTime.now().toString(),
                "user_id": "unkonw",
              }], forceDownload: true);
            }
            var message  = await MessageConversationServices.getListMessageById(dm, widget.messageId, widget.conversationId);
            if (message != null) {
              Provider.of<DirectMessage>(context, listen: false).getLocalPathAtts([message], forceDownload: true);
            } else {
              Provider.of<DirectMessage>(context, listen: false).getLocalPathAtts([{
                "attachments": [widget.content],
                "id": "unkonw",
                "conversation_id": "unkonw",
                "time_create": DateTime.now().toString(),
                "user_id": "unkonw",
              }], forceDownload: true);
            }
          },
          child: Container (
            child: Container(
              height: 200,
              width: 200,
              color: Color(0xFFbfbfbf),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(PhosphorIcons.download),
                        Container(height: 16, width: 1),
                        Text("Tap to view video")
                      ],
                    ),
                  )
                ],
              ))
          ),
        );
      }
    );
  }
}