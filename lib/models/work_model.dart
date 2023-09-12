import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/link_preview.dart';
import 'package:workcake/components/media_conversation/model.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:workcake/services/upload_status.dart';

class Work with ChangeNotifier {
  static const MethodChannel platform = const MethodChannel("workcake.pancake.vn/channel");
  static const EventChannel eventChannel = const EventChannel("workcake.pancake.vn/events");
  static Stream eventChannelStream = eventChannel.receiveBroadcastStream();
  List _issues  = [];
  List _taskDownload = [];
  List _listIssueDraft = [];

  bool _issueClosedTab = false;
  bool _isSystemTray = true;

  var _resetFilter = 0;
  bool _connectionStatus = false;
  
  bool get isSystemTray => _isSystemTray; 
  bool get connectionStatus => _connectionStatus; 

  set isSystemTray(bool i){
    _isSystemTray = i;
    notifyListeners();
  }

  List get taskDownload  => _taskDownload;

  bool get issueClosedTab => _issueClosedTab;

  int get resetFilter => _resetFilter;

  List get listIssueDraft => _listIssueDraft;
  
  set listIssueDraff(List list){
    _listIssueDraft = list;
    notifyListeners();
  }

  setConnection(bool value){
    _connectionStatus = value;
    notifyListeners();
  }

  loadHiveSystemTray(){
    Hive.openBox("system").then((value) {
      var box = value;
      _isSystemTray = box.get("is_tray") ?? false;
    });
    notifyListeners();
  }

  loadDraftIssue() async{
    var box = await Hive.openBox("draftsComment");
    var boxGet = box.get("lastEdited");
    if (boxGet != null) {
      _listIssueDraft = List.from(boxGet);
    }
    notifyListeners();
  }

  setIssueClosedTab(bool tab) {
    _issueClosedTab = tab;
    notifyListeners();
  }

  updateResetFilter() {
    _resetFilter++;
    notifyListeners();
  }
  createNewIssue(int channelId){
    // issue moi co trang thai status = "new"
    var currentIndex  =  _issues.indexWhere((element) => element["channelId"] == channelId );
    if (currentIndex == -1){
      Map issue = {
        "channelId": channelId,
        "id": Utils.getRandomString(10),
        "title": "",
        "description": "",
        "labels": [],
        "milestone": null,
        "is_closed": false,
        "assignees": [],
        "comments": [],
      };
      _issues += [issue];
      return issue;
    }
    return _issues[currentIndex];
  }
   

  updateIssue(Map  issue){
    var currentIndex  =  _issues.indexWhere((element) => element["channelId"] == issue["channelId"]);
    if (currentIndex != -1){
      _issues[currentIndex]  = issue;
    }
  }

  deleteIssue(int channelId){
    _issues = _issues.where((element) => element["channelId"] != channelId).toList();

  }

  // task download
  // add task download

  addTaskDownload(Map download) async{
    // gen a new Id
    Map task = Utils.mergeMaps([
      download, {
        "id": Utils.getRandomString(10),
        "status": "downloading",
        "progress": 0.0
      },
      download["name"] == null ? {"name":  Utils.getRandomString(10)} : {}
    ]);
    _taskDownload = _taskDownload + [task];
    notifyListeners();
    // excute download
    await excuteDownload(task);
  }

  Future<List<int>?> getBytesFromUrl(String url) async {
    try {
      Response response = await Dio().get(
        url,
        //Received data with List<int>
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false, 
          receiveTimeout: 0),
        );
      return response.data;      
    } catch (e) {
      return null;
    }
  }

  excuteDownload(task)async {
    await Future.delayed(Duration(milliseconds: 1000));
    Directory? appDocDirectory;
    if (Platform.isAndroid) {
      var localPath = await ServiceMedia.getDownloadedPath(task["content_url"]);
      if (localPath != null){
        return platform.invokeMethod("saveFileDirect", {
          ...task,
          "bytes": await (File(localPath)).readAsBytes()
        });
      } else {
        if (Utils.checkedTypeEmpty(task["key_encrypt"]) && task["key_encrypt"].length > 30){
          Uint8List bytes;
          List<int> contentUrlByBytes =   (await getBytesFromUrl( task["content_url"]))!;
          if ( task["version"] == 2) bytes = Uint8List.fromList(await Utils.decryptBytes(contentUrlByBytes, task["key_encrypt"]));
          else bytes = base64Decode(Utils.decrypt(base64Encode(contentUrlByBytes), task["key_encrypt"]));

          return platform.invokeMethod("saveFileDirect", {
          ...task,
          "bytes": bytes
        });
        } else return  platform.invokeMethod("saveFile", task);
      }
    }
    if (Platform.isIOS) appDocDirectory = await getApplicationDocumentsDirectory();
    var path  = appDocDirectory!.path;
    // path = path + '/pancake_chat_files';

    new Directory(path).create(recursive: true)
    .then((Directory directory) async {
      try {
        Response response = await Dio().get(
        task["content_url"],
        onReceiveProgress: (count, total) {
          task["progress"] =  count / total;
          // notifyListeners();
        },
        //Received data with List<int>
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false, 
          receiveTimeout: 0),
        );
        final path = directory.path;
        var checkType = [];
        for (int i = 0; i <= 5; i++) {
          checkType.add(response.data[i]);
        }
        var nameFile = "${task["name"] ?? task["id"]}" + checkTypeFile(checkType);
        File file = File("$path/$nameFile");
        if (Utils.checkedTypeEmpty(task["key_encrypt"]) && task["key_encrypt"].length > 30){
          if ( task["version"] == 2) await file.writeAsBytes(await Utils.decryptBytes(response.data, task["key_encrypt"]), mode: FileMode.write);
          else  await file.writeAsBytes(base64Decode(Utils.decrypt(base64Encode(response.data), task["key_encrypt"])), mode: FileMode.write);
        }
        else await file.writeAsBytes(response.data, mode: FileMode.write);
        task["status"] = "done";
        notifyListeners();
      } catch (e) {
        task["status"] = "error";
        task["progress"] = 0.0;
        notifyListeners();
        print("download att $e");
      }
  
    }).catchError((err){
      print("excuteDownload: $err");
    });
  }

  static checkTypeFile(checkType) {
    if (checkType[0] == 255 && checkType[1] == 216 && checkType[2] == 255) return ".jpg";
    else if (checkType[0] == 137 && checkType[1] == 80 && checkType[2] == 78) return ".png";
    else if (checkType[0] == 77 && checkType[1] == 77 && checkType[2] == 0) return ".png";
    else if (checkType[0] == 73 && checkType[1] == 68 && checkType[2] == 51) return ".mp3";
    else if (checkType[0] == 71 && checkType[1] == 73 && checkType[2] == 70) return ".gif";
    else if (checkType[0] == 77 && checkType[1] == 77 && checkType[2] == 0 && checkType[3] == 42) return ".tif";
    else if (checkType[0] == 0 && checkType[1] == 0 && checkType[2] == 0 && checkType[3] == 32 && checkType[4] == 102 && checkType[5] == 116)
      return ".mp4";
    else return "";
  }

  reDownload(String taskId)async {
    var index  =  _taskDownload.indexWhere((element) => element["id"] == taskId);
    if (index != -1){
      Map task  =  _taskDownload[index];
      task["status"] =  "downloading";
      task["progress"] = 0.0;
      notifyListeners();
      await excuteDownload(task);
    }
  }

  getUploadData(file) async {
    var bytes = file["bytes"];
    var imageData = {};
    var thumbnail;
    if (file["type"] == "image") {
      var decodedImage = await decodeImageFromList(bytes);
      imageData = {
        "width": decodedImage.width,
        "height": decodedImage.height
      };
    }

    if (["mp4", "mov"].contains(file["mime_type"].toLowerCase())) {
      file["type"] = "video";
    }

    if (file["type"] == "video") {
      await VideoCompress.getByteThumbnail(
        file["path"],
        quality: 90, 
        position: -1 
      ).then((value) async {
        var decodedImage = await decodeImageFromList(value!);
        imageData = {
          "width": decodedImage.width,
          "height": decodedImage.height
        };
        thumbnail = {
          "filename": file["name"],
          "bytes": value,
          "image_data": imageData
        };
      });
    }

    imageData = {...imageData, "size": file["size"] ?? file["bytes"].length};

    return {
      "path": file["path"],
      "filename": file["name"],
      "bytes": bytes,
      "length": bytes.length,
      "mime_type": file["mime_type"],
      "type": file["type"],
      'preview': file['preview'],
      "name": file["name"],
      "progress": "0",
      "image_data": imageData,
      "thumbnail" : thumbnail,
    };
  }

  Future<dynamic> uploadThumbnail(String token, workspaceId, file, type) async {
    try {
      if (type != "video") return {};
      FormData formData = FormData.fromMap({
        "data": MultipartFile.fromBytes(
          file["bytes"], 
          filename: file["filename"],
        ),
        "content_type": "image",
        "filename": file["filename"]
      });

      final url = Utils.apiUrl + 'workspaces/$workspaceId/contents/v2?token=$token';
      final response = await Dio().post(url, data: formData);
      final responseData = response.data;
      return {...responseData, 'type': 'image', 'mime_type': 'jpeg'};
    } catch (e, t) {
      print("uploadThumbnail error: $e,  $t");
      return {};
    }
  }
   
  getContentFromApi(token, workspaceId, data) async {
    var bytes = utf8.encode(base64.encode(data)); // data being hashed
    var hashId = sha1.convert(bytes).toString().toLowerCase();

    try {
      final res = await http.get(Uri.parse(Utils.apiUrl + 'workspaces/$workspaceId/contents/$hashId?token=$token'));
      final responseData = json.decode(res.body);
      return responseData;
    } catch (e) {
      print("getContentFromApi error: $e");
      return {'success': false};
    }
  }

  uploadImage(String token, workspaceId, file, type, Function onSendProgress, {String key = "", List? pathFolder}) async {
    Map rootFileData = file;
    var imageData = file["image_data"];

    if (file["type"] == "image") {
      var decodedImage = await decodeImageFromList(file["bytes"]);
      imageData = {
        ...imageData,
        "width": decodedImage.width,
        "height": decodedImage.height
      };

      if (file["bytes"].length > 2999999 || file["mime_type"] == 'heic') {
        img.Image? imageTemp = img.decodeImage(file["bytes"]);
        if (imageTemp != null) {
          file["bytes"] = img.encodeJpg(imageTemp, quality: 70);
        }
      }
    }

    var result  = {};
    try {
      var content = await getContentFromApi(token, workspaceId, file["bytes"]);

      if (content["success"] && pathFolder == null) {
        var thumbnail = file["thumbnail"] != null ? await uploadThumbnail(token, workspaceId, file["thumbnail"], file["type"]) : {};
        result = {
          "id": content["id"],
          "success": true,
          "content_url":  content["content_url"],
          "type": file["type"],
          "mime_type": file["mime_type"],
          "name": file["name"] ?? "",
          "image_data": imageData ?? content["image_data"],
          "filename": file["filename"],
          "url_thumbnail" : thumbnail["content_url"]
        };
      } else {
        final url = pathFolder == null 
            ? Utils.apiUrl + 'workspaces/$workspaceId/contents/v2?token=$token' 
            : Utils.apiUrl + 'workspaces/$workspaceId/file_explorers?token=$token';
        num percent = 0;
        FormData formData = FormData.fromMap({
          "data": MultipartFile.fromBytes(
            file["bytes"], 
            filename: file["filename"],
          ),
          "content_type": file["type"],
          "mime_type": file["mime_type"],
          "image_data" : imageData,
          "filename": file["filename"],
          "path_folder": pathFolder != null ? json.encode(pathFolder) : null,
        });

        final response = await Dio().post(url, data: formData, onSendProgress: (count, total) {
          if ((count*100/total).round() - percent > 1) {
            percent = (count*100/total).round();
            StreamUploadStatus.instance.setUploadStatus(key, count/total);
          }
        });
        final responseData = response.data;
        if (responseData["success"]) {
          result = {
            "id": content["id"],
            "success": true,
            "content_url":  Uri.encodeFull(responseData["content_url"]),
            "mime_type": file["mime_type"],
            "name": file["name"] ?? "",
            "image_data": imageData ?? responseData["image_data"],
            "filename": file["filename"],
            "type": file["type"],
            "inserted_at": responseData["inserted_at"],
          };
          if (file["type"] == "video") {
            var res = await uploadThumbnail(token, workspaceId, file["thumbnail"], file["type"]);
            result["url_thumbnail"] = res["content_url"];
          }
        } 
        else {
          result =  {
            "success": false,
            "message": responseData["message"],
            "file_data": rootFileData
          };
          print("uploadImage error ${responseData["message"]}");
        }
      }
    } catch (e) {   
      print("uploadImage error:   $e");
      result = {
        "success": false,
        "file_data": rootFileData
      };
    }
    return Utils.mergeMaps([result, {"name": file["filename"], "uploading": false, 'preview': file['preview'], "key_encrypt": key}]);
  }


  openFileSelector(context, {int maxAssets = 10}) async {
    if (context == null) return;
    List<AssetEntity>? resultList = [];

    try {
      resultList = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: maxAssets,
          textDelegate: EnglishAssetPickerTextDelegate()
        )
      );
      if (resultList == null) return [];

      return resultList;
    } catch (e, t) {
      print("openFileSelector  ${e.toString()} , $t");
      return [];
    }
  }

  openCamera(context) async {
    final AssetEntity? pickedFile = await CameraPicker.pickFromCamera(
      context,
      pickerConfig: CameraPickerConfig(
        textDelegate: EnglishCameraPickerTextDelegate(),
        enableRecording: true,
        enableTapRecording: true
      )
    );
    return pickedFile;
  }

  static addPreviewToMessage(message) async {
    try {
      RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
      Iterable<RegExpMatch> matches = exp.allMatches(message);
      List listUrl = [];
      var info;

      if (matches.toList().isNotEmpty) {
        for (var match in matches) {
          var url = message.substring(match.start, match.end);

          if (url.contains("http")) {
            listUrl.add(url);
          }
        }
      }

      if (listUrl.length >= 3) {
        return [];
      } else {
        List previews = [];
        
        for (var i = 0; i < listUrl.length; i++) {
          var url = listUrl[i];
          info = await WebAnalyzer.getInfo(url.trim());
          if (info != null) {
            Map webInfo = {'image': info.image, 'icon': info.icon, 'title': info.title, 'description': info.description};
            previews.add({'web_info': webInfo, 'url': url, 'type': 'preview'});
          }
        }

        return previews;
      }
    } catch (e, t) {
      print("addPreviewToMessage $e,  $t");
      return [];
    }
  }
}
