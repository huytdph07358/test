import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:objectbox/objectbox.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/components/attachments/audio_player_message.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/media_conversation/model.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/direct_messages_model.dart';

class StatusDownloadedAtt {
  String type = "local";
  String path = "";
  String status = "donloaded";

  StatusDownloadedAtt(String type, String path, String status){
    this.type = type;
    this.path = path;
    this.status = status;
  }

  Map toJson(){
    return {
      "type": this.type,
      "path": this.path,
      "status": this.status
    };
  }
}
class StreamMediaDownloaded extends ValueNotifier<bool>{
  static final instance = StreamMediaDownloaded();
  static Map<String, StatusDownloadedAtt> dataStatus = {};
  final _statusMediaDownloadedController = StreamController<Map>.broadcast(sync: false);

  get statusMediaDownloadedController => _statusMediaDownloadedController;
  StreamMediaDownloaded(): super(false);
  Stream<Map> get status => _statusMediaDownloadedController.stream;

  setStreamDownloadedStatus(String remoteUrl) async {
    var pathInDevice = await ServiceMedia.getDownloadedPath(remoteUrl);
    if (pathInDevice != null){
      dataStatus[remoteUrl] = StatusDownloadedAtt("local", pathInDevice, "donloaded");
      _statusMediaDownloadedController.add(dataStatus);      
    }
  }

  setStreamDownloadedStatusFromIsolate(String remoteUrl, Store store) async {
    var pathInDevice = await ServiceMedia.getDownloadedPathFromIsolate(remoteUrl, store);
    if (pathInDevice != null){
      dataStatus[remoteUrl] =  StatusDownloadedAtt("local", pathInDevice, "donloaded");
      _statusMediaDownloadedController.add(dataStatus);      
    }
  }

  setStreamOldFileStatus(String remoteUrl) async {
    dataStatus[remoteUrl] =  StatusDownloadedAtt("remote", remoteUrl, "donloaded");
    _statusMediaDownloadedController.add(dataStatus); 
  }
}


class ImageDirect {
  static Widget build(BuildContext context, String contentUrl,  String messageId, String? conversationId, Map att, {Function? customBuild}){
    return StreamBuilder(
      stream: StreamMediaDownloaded.instance.status,
      initialData: StreamMediaDownloaded.dataStatus,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) { 
        Map<String, StatusDownloadedAtt> data = snapshot.data ?? {};
        if (data[contentUrl] != null){
          if (data[contentUrl]!.path == "" || data[contentUrl]!.status == "downloading") return Center(child: Text("Loading..."));
          if (data[contentUrl]!.type == "local"){
            if (customBuild != null){
              return customBuild(data[contentUrl]!.path);
            }
            return Container(
              child: Image.file(
                File(data[contentUrl]!.path), 
                fit: BoxFit.cover
              ),
            );
          }
          return CachedImage(data[contentUrl]!.path);
        } return GestureDetector(
          onTap: () async {
            DirectModel? dm = Provider.of<DirectMessage>(context, listen: false).getModelConversation(conversationId ?? "");
            // dm == null => forceDownload, vi day co the la share tu 1 conv ko co minh, danh conversation_id = "unknow", user_id = "unknow"
            if (dm == null) {
              return Provider.of<DirectMessage>(context, listen: false).getLocalPathAtts([{
                "attachments": [att],
                "id": "unkonw",
                "conversation_id": "unkonw",
                "time_create": DateTime.now().toString(),
                "user_id": "unkonw",
              }], forceDownload: true);
            }
            Map? message  = await MessageConversationServices.getListMessageById(dm, messageId, conversationId ?? "");
            if (message != null) {
              Provider.of<DirectMessage>(context, listen: false).getLocalPathAtts([message], forceDownload: true);
            } else {
              Provider.of<DirectMessage>(context, listen: false).getLocalPathAtts([{
                "attachments": [att],
                "id": "unkonw",
                "conversation_id": "unkonw",
                "time_create": DateTime.now().toString(),
                "user_id": "unkonw",
              }], forceDownload: true);
            }
            // Provider.of<DirectMessage>(context, listen: false).getLocalPathAtts(messages);
          },
          child: Container(
            child: Container(
              color: Color(0xFFbfbfbf),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIcons.download),
                  Container(height: 16, width: 1),
                  Text("Tap to view photo")
                ],
              ))
          ),
        );
      }, 
    );
  }
}

class RecordDirect {
  static Widget build(BuildContext context, String contentUrl, {Function? customBuild}){
    return StreamBuilder(
      stream: StreamMediaDownloaded.instance.status,
      initialData: StreamMediaDownloaded.dataStatus,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) { 
        Map data = snapshot.data ?? {};
        if (data[contentUrl] != null) {
          if (data[contentUrl]["type"] == "local") {
            if (customBuild != null){
              return customBuild(data[contentUrl]["path"]);
            }
            return AudioPlayerMessageDirect(
              path: data[contentUrl]["path"],
            );
          }
          return AudioPlayerMessageDirect(
            path: data[contentUrl]["path"],
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                height: 32,
              )
            ],
          ),
        );
      }, 
    );
  }
}