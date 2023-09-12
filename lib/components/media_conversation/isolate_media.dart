import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/components/media_conversation/model.dart';
import 'package:workcake/components/media_conversation/stream_media_downloaded.dart';
import 'package:workcake/controller/direct_message_controller.dart';
import 'package:workcake/data_channel_webrtc/device_socket.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/isar.g.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/objectbox.g.dart';
import 'package:workcake/services/upload_status.dart';

class IsolateMedia {
  static var mainSendPort;
  static Store? storeObjectBox;
  static Map<String, Media> mediaDownloadFail = {};
  static Future createIsolate() async {
    Completer completer = new Completer<SendPort>();
    ReceivePort isolateToMainStream = ReceivePort();

    isolateToMainStream.listen((data) {
      if (data is SendPort) {
        SendPort mainToIsolateStream = data;
        completer.complete(mainToIsolateStream);
      } else {
        try {
          if (data is Map && data["type"] == "media_donwload_fail") {
            mediaDownloadFail = {
              ...mediaDownloadFail,
              ...data["data"]
            };
          }
          if (data is Map && data["type"] == "remove_media_download_fail") {
            for(Media m in data["data"]) {
              mediaDownloadFail.remove("${m.localId}");
            }
          }

          if (data is Map && data["type"] == "path_in_device"){
            String remoteUrl = data["remote_url"];
            String pathInDevice =  data["path_in_device"];
            String status = data["status"];
            StreamMediaDownloaded.dataStatus[remoteUrl] = StatusDownloadedAtt("local", pathInDevice, status);
            StreamMediaDownloaded.instance.statusMediaDownloadedController.add(StreamMediaDownloaded.dataStatus);
          } 
          if (data is Map && data["type"] == "push_sync_via_file_isolate") {
            Provider.of<Auth>(Utils.globalContext!, listen: false).channel.push(
              event: "send_data_sync", 
              payload: data["data"]
            );
          } 

          if (data is Map && data["type"] == "progress_push_sync_via_file_isolate") {
            MessageConversationServices.statusSyncStatic = data["data"];
            MessageConversationServices.statusSyncController.add(data["data"]);
            if (MessageConversationServices.statusSyncStatic.statusCode == 200){
              Provider.of<Auth>(Utils.globalContext!, listen: false).channel.push(
                event: "remove_cache_data_sync", 
                payload: {}
              );
            }
          }
          if (data is Map && data["type"] == "push_sync_data_via_isolate_webRTC"){
            DeviceSocket.instance.localChannel!.send(data["data"]);
          } 
          if (data is Map && data["type"] == "summy_message_dm"){
            Map message  = data["data"];
            if (!Utils.checkedTypeEmpty(message["isThread"])){
              if (message["isSend"]) Provider.of<DirectMessage>(Utils.globalContext!, listen: false).onDirectMessage([message], message["user_id"], false, true, "", null);
              else Provider.of<DirectMessage>(Utils.globalContext!, listen: false).updateDirectMessage(message, false, null, true);
            } 
          }
          if (data is Map && data["type"] == "send_message_after_process_file"){
            String token = data["data"]["token"];
            List resultUpload = data["data"]["result_upload"];
            List noDummyAtts = data["data"]["no_dummy_atts"];
            Map message = data["data"]["message"];
            Provider.of<DirectMessage>(Utils.globalContext!, listen: false).sendMessageWithImageFromIsolate(resultUpload, noDummyAtts, message, token);
          }
          if (data is Map && data["type"] == "progress_upload_file_dm"){
            String key = data["data"]["key"];
            int count = data["data"]["count"];
            int total = data["data"]["total"];
            StreamUploadStatus.instance.setUploadStatus(key, count/total);
          }
          if (data is Map && data["type"] == "result_get_message_down_via_isolate"){
            Provider.of<DirectMessage>(Utils.globalContext!, listen: false).processDataMessageFromHiveViaIsolate(data["data"]["current_data_dm_message"], data["data"]["data_from_isar"]);
          }
          if (data is Map && data["type"] == "result_after_process_data_from_api_via_isolate"){
            List dataMergeLocal = data["data"]["data_merge_local"];
            List successIds = data["data"]["success_ids"];
            List<String> errorIds = data["data"]["error_ids"];
            Map? messageSnippet = data["data"]["message_snippet"];
            ConversationMessageData currentDataDMMessage = data["data"]["current_data_dm_message"];
            bool hasMark = data["data"]["has_mark"];
            Provider.of<DirectMessage>(Utils.globalContext!, listen: false).resultAfterProcessDataFromApiViaIsolate(dataMergeLocal, successIds, errorIds, messageSnippet, currentDataDMMessage, hasMark);
          }
          if (data is Map && data["type"] == "data_reaction_dm_messages") {
            for(var i in data["data"]) {
              directMessageProvider.reactionMessageDMs[i["message_id"]] = i["reactions"];
              directMessageProvider.markReadConversationV2(Provider.of<Auth>(Utils.globalContext!, listen: false).token, i["conversation_id"], i["success_ids"], [], false);
            }
            directMessageProvider.reactionMessageDMStream.add(directMessageProvider.reactionMessageDMs);
          }
        } catch (e, t) {
          print("isolateToMainStream.listen: $e, $t");
        }
      }
    });
    await Isolate.spawn(heavyComputationTask, isolateToMainStream.sendPort);
    return completer.future;
  }

  static heavyComputationTask(SendPort isolateToMainStream) async {
    try {
      ReceivePort mainToIsolateStream = ReceivePort();
      isolateToMainStream.send(mainToIsolateStream.sendPort);
      Isar? isar;
      Store? store;
      mainToIsolateStream.listen((data) {
        try {
          if (data["type"] == "redownload_media_fail") {
            Store store = Store.fromReference(getObjectBoxModel(), data["data"]["box_reference"]);
            Map<String, Media> mediaError = data["data"]["media_error"];
            for(String k in mediaError.keys){
              ServiceMedia.reDownloadMediaFail(mediaError[k]!, store, data["data"]["path_save_file"], isolateToMainStream);
            }
          }
          if (data["type"] == "get_path"){
            store = Store.fromReference(getObjectBoxModel(), data["box_reference"]);
            Hive.init("${data["path"]}/pancake_chat_data1");
            Hive.openLazyBox("pairKey");
            Hive.registerAdapter(DirectModelAdapter());
            Hive.openBox("direct");
            S.load(Locale('en'));
            S.load(Locale('vi'));
            initializeDateFormatting('en_EN', null);
            // luu y, tren ios dang ko chay isar product(release mode)
            if (Platform.isAndroid){
              openIsar(directory: "${data["path"]}/pancake_chat_data").then((i) => isar = i);
            }
          }
          if (data["type"] == "get_all_media_from_message"){
            Store store = Store.fromReference(getObjectBoxModel(), data["box_reference"]);
            ServiceMedia.getAllMediaFromMessageIsolate(data["data"], store, data["path_save_file"], isolateToMainStream, data["setting_auto_download_network"] ?? {}, data["force_download"] ?? false);
          }
          if (data["type"] == "delete_message_and_media_via_delete_time"){
            Store store = Store.fromReference(getObjectBoxModel(), data["box_reference"]);
            List dataConv  = data["data"];
            for(int i = 0; i < dataConv.length; i++){
              MessageConversationServices.deleteMessageOnConversationByDeleteTime(dataConv[i]["delete_time"], dataConv[i]["conversation_id"], store, isar);
              ServiceMedia.deleteMediaByDeleteTime(dataConv[i]["delete_time"], dataConv[i]["conversation_id"], store);
            }
          }
          if (data["type"] == "sync_via_file") {
            Store store = Store.fromReference(getObjectBoxModel(), data["box_reference"]);
            String key2e2 = data["data"]["key2e2"];
            String deviceIdTarget = data["data"]["device_id_target"];
            String token = data["data"]["token"];
            String identityKeyServer = data["data"]["identity_key_server"];
            Map identityKey = data["data"]["identity_key"];
            String deviceId = data["data"]["device_id"];
            List conversationIds = data["data"]["conversation_ids"];
            MessageConversationServices.syncViaFileIsolate(conversationIds, key2e2, deviceIdTarget, identityKey, store, token, isolateToMainStream, identityKeyServer, deviceId, isar);
          }
          if (data["type"] == "handle_via_file") {
            String key2e2 = data["data"]["key2e2"];
            Store store = Store.fromReference(getObjectBoxModel(), data["box_reference"]);
            String url = data["data"]["url"];
            String deviceIdTarget = data["data"]["device_id_target"];
            MessageConversationServices.handleSyncViaFileIsolate(key2e2, url, isolateToMainStream, store, isar, deviceIdTarget);
          }

          if (data["type"] == "process_file_while_send_message_dm_with_files"){
            Map message = data["data"]["message"];
            String token = data["data"]["token"];
            List atts = data["data"]["atts"];
            String pathTempFolder = data["data"]["path_temp_folder"];
            String pathApplicationDocument = data["data"]["path_application_document"];
            MessageConversationServices.processFileWhileSendMessageDmWithFiles(atts, message, token, isolateToMainStream, pathTempFolder, pathApplicationDocument, store!);
          }
          if (data["type"] == "download_video_channel"){
            String url = data["data"]["url"];
            String cachePath =  data["data"]["cache_path"];
            String extentionName  = url.split(".").last;
            if (extentionName == "") extentionName = "mp4";
            Media(url.hashCode, null, url, DateTime.now().microsecondsSinceEpoch.toString() + ".$extentionName", "file", "", 0, "", "not_download", 1).downloadToDevice(store!, cachePath, isolateToMainStream);
          }
          if (data["type"] == "force_load_message_from_hive_down"){
            ConversationMessageData currentDataDMMessage = data["data"]["current_data_dm_message"];
            DirectModel dm = data["data"]["dm"];
            int rootCurrentTime = data["data"]["root_current_time"];
            String currentUserId = data["data"]["current_user_id"];
            bool isGetIsarBeforeCallApi = data["data"]["is_get_isar_before_call_api"];
            String type = data["data"]["type"];
            MessageConversationServices.getMessageDownViaIsoLate(currentDataDMMessage, dm, rootCurrentTime, currentUserId, isar, store, isGetIsarBeforeCallApi, type, isolateToMainStream);
          }
          if (data["type"] == "process_data_message_from_api_via_isolate"){
            ConversationMessageData currentDataDMMessage = data["data"]["current_data_dm_message"];
            DirectModel dm = data["data"]["dm"];
            bool hasMark = data["data"]["has_mark"];
            bool isReset = data["data"]["is_reset"];
            String token = data["data"]["token"];
            int rootCurrentTime = data["data"]["root_current_time"];
            String type = data["data"]["type"];
            int deleteTime = data["data"]["delete_time"];
            List dataMessage = data["data"]["data_message"];
            String currentUserId = data["data"]["current_user_id"];
            MessageConversationServices.processDataMessageFromApi(dataMessage, rootCurrentTime, isReset, deleteTime, token, type, hasMark, isar, store, isolateToMainStream, currentDataDMMessage, dm, currentUserId);
          }
          if (data["type"] == "handle_reaction_message_DM_isolate") {
            DirectMessageController.handleReactionMessageDMIsolate(data["dm"], data["data"], isolateToMainStream, isar, store);
          }
          if (data["type"] == "get_reaction_message_isolate") {
            DirectMessageController.getReactionMessagesIsolate(data["message_ids"], data["conversation_id"], isolateToMainStream, isar, store);
          }
        } catch (e, t) {
          print("dsfsdfdsfdsfds, $e, $t");
        }
      });      
    } catch (e, t) {
      print("heavyComputationTask: $e, $t");
    }
    
  }
}