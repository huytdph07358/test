import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:local_auth/local_auth.dart' as LocalAuth;
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:encrypt/encrypt.dart' as En;
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:location/location.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:workcake/E2EE/e2ee.dart';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/components/direct_message/dm_confirm_shared.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/models/models.dart';

import '../components/sticker_emoji.dart';
import 'package:workcake/screens/conversation.dart';
import 'package:workcake/screens/main_screen/index.dart';
import 'package:workcake/screens/message.dart';
import '../generated/l10n.dart';
class Utils {
  // Check api and socket url with mode
  static String apiUrl = 'https://chat.pancake.vn/api/';
  static String socketUrl = 'wss://chat.pancake.vn/socket/websocket';
  static String clientId = '310e01831d194a4dae4f37633cbec841';
  static String publicKey = "";
  static String privKey = "";
  static String identityKey = "";
  static Map? dataDevice;
  static String? deviceId;
  static BuildContext? globalContext;
  static BuildContext? loginQrContext;
  static String connectivityResult = "";
  static String panchatSupportId = "9e702ec5-7a22-42ed-a289-3c8c55692523";
  static int? versionAndroid;
  static GlobalKey<DMConfirmSharedState> dmConfirmSharedViewKey = GlobalKey<DMConfirmSharedState>();
  static GlobalKey<StickerEmojiWidgetState> stickerEmojiWidgetState = GlobalKey<StickerEmojiWidgetState>();
  static GlobalKey<State> globalMainScreen = GlobalKey<State>();
  static GlobalKey<State> globalKeyPush = GlobalKey<State>();

  static Future checkAndRemoveOldPush() async {
    try {
      if (Utils.globalKeyPush.currentState != null) {
        Navigator.pop(Utils.globalKeyPush.currentState!.context);
        Utils.globalKeyPush = GlobalKey<State>();
      }      
    } catch (e) {
      Utils.globalKeyPush = GlobalKey<State>();
    }
    await Future.delayed(Duration(milliseconds: 300));
  }

  static bool checkInViewMessage(){
    if (globalKeyPush.currentContext != null && globalKeyPush.currentState != null && globalKeyPush.currentState is MessageState) {
      return ModalRoute.of(globalKeyPush.currentContext!)?.isCurrent ?? false;
    }

    if (globalMainScreen.currentContext != null && globalMainScreen.currentState != null) {
      return (ModalRoute.of(globalMainScreen.currentContext!)?.isCurrent ?? false) 
        && (globalMainScreen.currentState as MainScreenState).pageController.page == 1 
        && Provider.of<Auth>(globalContext!, listen: false).currentMenuIndex == 0;
    }

    return false;
  }

  static bool checkInViewConverastion(){
    if (globalKeyPush.currentContext != null && globalKeyPush.currentState != null && globalKeyPush.currentState is ConversationState) {
      return ModalRoute.of(globalKeyPush.currentContext!)?.isCurrent ?? false;
    }      
    if (globalMainScreen.currentContext != null && globalMainScreen.currentState != null) {

      return (ModalRoute.of(globalMainScreen.currentContext!)?.isCurrent ?? false) 
        && (globalMainScreen.currentState as MainScreenState).pageController.page == 1 
        && Provider.of<Auth>(globalContext!, listen: false).currentMenuIndex != 0;
    }

    return false;
  }

  static setIdentityKey(newK){
    identityKey = newK;
  }

  static setPairKey(pairkey){
    publicKey = pairkey["pubKey"];
    privKey = pairkey["privKey"];
  }
  static String primaryColor = '0xFF2A5298';

  static bool get debugMode {
    var debug = false;
    assert(debug = true);
    return debug;
  }

  static String capitalize(string) {
    return "${string[0].toUpperCase()}${string.substring(1)}";
  }

  static checkDebugMode(String address) {
    assert(() {
      // apiUrl = 'https://db6a-27-72-63-124.ngrok.io/api/';
      // socketUrl = 'wss://db6a-27-72-63-124.ngrok.io/socket/websocket';
      apiUrl = 'https://chat.pancake.vn/api/';
      socketUrl = 'wss://chat.pancake.vn/socket/websocket';
      clientId = 'c726228820114ea4a785898f8c4f7b53';
      return true;
    }());
  }

  static Future<String> getIpDevice() async {
    var response = await Dio().get('https://api.ipify.org?format=json');
    var dataRes = response.data;
    try {
      return dataRes["ip"];
    } catch (e) {
      return "";
    }
  }

  static Future<String> getDeviceName()async{
    try {
      var deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      }
      return "";
    } catch (e) {
    return "";
    }
  }

  static Future<Map?> getDeviceInfo() async {
    try {
      if (Utils.checkedTypeEmpty(dataDevice)) return dataDevice;
      dataDevice = {
        "ip": await getIpDevice(),
        "name": await getDeviceName(),
        "platform":  Platform.operatingSystem.toLowerCase()
      };
      return dataDevice;
    } catch (e) {
      return {};
    }
  }

  static getPrimaryColor() {
    return Color(0xFF1890FF);
  }

  static getUnHighlightTextColor(){
    return Color(0xffcce6ff);
  }
  static getHighlightTextColor(){
    return Color(0xffffffff);
  }

  static const headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8'
  };

  _parseAndDecode(String response) {
    return jsonDecode(response);
  }

  parseJson(String text) {
    return compute(_parseAndDecode, text);
  }

  static postHttp(String url, Map body) async {
    try {
      Response response = await Dio().post(url, data: json.encode(body));
      return json.decode(response.data);
    } catch (e) {
      print(e);
    }
  }

  static getHttp(String url) async {
    try {
      Response response = await Dio().get(url);
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static deleteHttp(String url) async {
    try {
      Response response = await Dio().delete(url);
      return response.data;
    } catch (e) {
      print(e);
    }
  }

  static checkedTypeEmpty(data) {
    if (data == "" || data == null || data == false) {
      return false;
    } else {
      return true;
    }
  }

  static parseLocale(locale) {
    switch (locale) {
      case "vi":
        return "Vietnamese";
      case "en":
        return "English";
      default:
        return "English";
    }
  }

  static getRandomString(int length){
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static getRandomNumber(length){
    const _chars = '1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static showFileSize(int? fileSize) {
    const suffixes = [" B", " KB", " MB", " GB", " TB"];
    if (fileSize == 0 || fileSize == null) return 'Unknown';
    var i = (log(fileSize) / log(1024)).floor();
    return ((fileSize / pow(1024, i)).toStringAsFixed(2)) + suffixes[i];
  }

  static getString(String string, length) {
    // if (string  == null) return "";
    var lengthS  =  string.length;
    if (lengthS <= length) return string;
    return string.substring(0, length - 1) + "...";
  }
  static Map mergeMaps(List<Map> arr) {
    if (arr.length == 0 ) return {};

    Map result  = Map.from(arr[0]);
    int lengthArr  =  arr.length;
    for (var  i = 1; i< lengthArr; i++){
      Map draft = Map.from(arr[i]);
      draft.forEach((key, value) {
        if (key == "id"){
          if (checkedTypeEmpty(value)) result[key] = value;
        }
        else result[key] = value;
    });
    }
    return result;
  }

  static String encrypt(String str, String masterKey){
    final key = En.Key.fromBase64(masterKey);
    final iv  =  En.IV.fromLength(16);
    final encrypter = En.Encrypter(En.AES(key, mode: En.AESMode.cbc));
    return  encrypter.encrypt(str, iv: iv).base64;
  }

  static String decrypt(String str, String masterKey){
    final key = En.Key.fromBase64(masterKey);
    final iv  =  En.IV.fromLength(16);
    final encrypter = En.Encrypter(En.AES(key, mode: En.AESMode.cbc));
    var encrypted =  En.Key.fromBase64(str);
    return encrypter.decrypt(encrypted, iv: iv);
  }


  static encryptBytes(List<int> bytes, String masterKey){
    final key = En.Key.fromBase64(masterKey);
    final iv  =  En.IV.fromLength(16);
    final encrypter = En.Encrypter(En.AES(key, mode: En.AESMode.cbc));
    return  encrypter.encryptBytes(bytes, iv: iv).bytes;
  }

  static decryptBytes(List<int> bytes, String masterKey){
    final key = En.Key.fromBase64(masterKey);
    final iv  =  En.IV.fromLength(16);
    final encrypter = En.Encrypter(En.AES(key, mode: En.AESMode.cbc));
    var encrypted =  En.Encrypted(bytes as Uint8List);
    // var encrypted =  En.Encrypted(Uint8List.fromList(bytes));
    return encrypter.decryptBytes(encrypted, iv: iv);
  }

  static decryptMessage(Map message, String sharedKey){
    try {
      var decryptData  = decrypt(message["message"], sharedKey);
      var jsonData = jsonDecode(decryptData);
      var resultData  = Map.from(message);
      // resultData["message"] = decryptData["message"];
      // resultData["attachments"] = decryptData["attachments"];
      return {
        "success": true,
        "message": resultData,
        "data": jsonData
        };
      } catch (e, t) {
        print("$t, $e");
        return {
        "success": false,
        "message": "Error"
        };
      }
  }

  static getMimeTypeFromEntity(AssetEntity entity) async {
    String? mimeType = Platform.isIOS ? await entity.mimeTypeAsync : entity.mimeType;

    try {
      return (mimeType ?? "").split("/")[1];
    } catch (e, t) {
      print("getMimeTypeFromEntity  ${e.toString()} , $t");
      return '';
    }
  }

  static handleFileData(List<AssetEntity> resultList) async {
    List results = [];

    try {
      for(var i = 0; i < resultList.length; i++){
        var entity = resultList[i];
        final File? file = await entity.loadFile();
        if (file == null) continue; 
        var bytes = await entity.originBytes;
        var fileName = file.path.split('/').last;
        var mimeType = await getMimeTypeFromEntity(entity);
        var path = file.path;

        if (bytes == null) {
          results+=[{}];
        } else {
          if (bytes.length > 100000000) {
            Fluttertoast.showToast(
              msg: "File size more than 100MB",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              fontSize: 13
            );
            results+=[{}];

          } else {
            if (mimeType == 'heic') {
              String? jpegPath = await HeicToJpg.convert(path);
              File jpeg = File.fromUri(Uri.parse(jpegPath!));
              bytes = await jpeg.readAsBytes();
            }

            results+=[{
              "id": i,
              "name": fileName,
              "bytes": bytes,
              "path": path,
              "mime_type": mimeType,
              "type": resultList[i].type.name
            }];
          }
        }
      }

      return results;
    } catch (e, t) {
      print("handleFileData  ${e.toString()} , $t");
      return [];
    }
  }

  static initPairKeyBox()async{
    var boxKey  = await Hive.openLazyBox("pairKey");
    var deviceId = await boxKey.get('deviceId');
    var identityKey = await boxKey.get("identityKey");
    var signedKey  = await boxKey.get("signedKey");
    // gen new Curve25519
    if (deviceId == null || identityKey ==  null ||  signedKey == null){
      // gen a pairKey identity(dinh danh device voi server)
      var identityKey = await X25519().generateKeyPair();
      await boxKey.put("identityKey", {
        "pubKey": identityKey.publicKey.toBase64(),
        "privKey": identityKey.secretKey.toBase64()
      });
      final signedKey = await X25519().generateKeyPair();// dinmh danh nguoi dung
      // print("_____${signedKey.publicKey.toBase64()} ____ ${signedKey.secretKey.toBase64()}");
      await boxKey.put('signedKey', {
        "pubKey": signedKey.publicKey.toBase64(),
        "privKey": signedKey.secretKey.toBase64()
      });

      var newId  = "v4_" + MessageConversationServices.shaString([
        identityKey.publicKey.toBase64(),
        await Utils.getDeviceIdentifier(),
        // key nay se ko dc truyen di theo bat ky api nao, ko dc thay doi
        "fhl9gBRZa8jLmT2wwTmMdS2M6YHiqLsHNpb85oEStNM="
      ]);
      await boxKey.put("deviceId", newId);
    }
  }

  static encryptServer(Map data,{Map? idKey, String? identityKeyServer}) async{
    if (idKey == null){
      LazyBox box  = Hive.lazyBox('pairKey');
      idKey =  await box.get("identityKey");
    }

    var masterKey = await X25519().calculateSharedSecret(KeyP.fromBase64(idKey?["privKey"], false), KeyP.fromBase64( identityKeyServer ?? identityKey, true));
    var e = jsonEncode(data);
    return Utils.encrypt(e, masterKey.toBase64());
  }

  static decryptServer(String dataM)async {
    LazyBox box  =  Hive.lazyBox('pairKey');
    Map idKey =  await box.get("identityKey");
    var sharedKey = await X25519().calculateSharedSecret(KeyP.fromBase64(idKey["privKey"], false), KeyP.fromBase64(identityKey, true));
    return Utils.decryptMessage({"message" :dataM}, sharedKey.toBase64());
  }

  static genSharedKeyOnGroupByUser() async {
    var pairKey  = await X25519().generateKeyPair();
    return pairKey.secretKey.toBase64();
  }

  static openFilePicker(List<XTypeGroup>? optionGroup) async {
    final files = await FileSelectorPlatform.instance.openFiles(acceptedTypeGroups: optionGroup ?? []);
    final paths = files.map((e){
    return "file://${e.path}";
    });
    var dataFiles = await Future.wait(
      paths.map((e) async{
        try {
          var file = File.fromUri(Uri.parse(e));
          var name = e.split("/").last;
          var type = name.split(".").last;
          if (type == "png" || type == "jpg" || type == "jpeg") type = "image";
          if (type == "") type = "text";
          var fileData  = await file.readAsBytes();
          var checkfile = Work.checkTypeFile(fileData);
          if (checkfile  == ".png" || checkfile == ".jpg" || checkfile == ".jpeg" ||checkfile == ".gif") type = "image";
          else type = checkfile ?? type;
          return {
            "name": name,
            "mime_type": type,
            "path": e,
            "file": fileData
          };
        } catch (e) {
          return null;
        }
      })
    );

    return dataFiles.where((element) => element != null).toList();
  }

  static handleSnippet(url, value) async{
    try {
      String myBackspace(String str) {
        Runes strRunes = str.runes;
        str = String.fromCharCodes(strRunes, 0, strRunes.length - 1);
        return str;
      }

      String responseBody = await onRenderSnippet(url);
      var responseBodyTrim = responseBody.replaceAll('<p>', '').replaceAll('</p>', '\n').replaceAll('</div></body></html>', '')
        .replaceAll('<html><head><title>snippet</title><meta name="viewport" content="width=device-width, initial-scale=1"><meta charset="UTF-8"></head><body><div style="padding:12px">', '');
      final splitSnippet = responseBodyTrim.split("\n");
      int lengthString = splitSnippet.length >= 16 ? 16 : splitSnippet.length;

      List newMessage = [];
      for(int i = 0; i < lengthString; i++) {
        newMessage.add(splitSnippet[i]);
      }

      return !value ? newMessage.join("\n").trim().length > 500 ? myBackspace(newMessage.join("\n").trim().substring(0, 500)) + "..." : newMessage.join("\n").trim() : responseBodyTrim.trim();
    } catch (e) {
      return "Error!!!!!";
    }

  }

  static parseDatetime(DateTime? time) {
    if (time != null) {
      DateTime offlineTime = time;
      DateTime now = DateTime.now();
      final difference = now.difference(offlineTime).inMinutes;
      final int hour = difference ~/ 60;
      final int minutes = difference % 60;
      final int day = hour ~/24;

      if (day > 0) {
        int month = day ~/30;
        int year = month ~/12;
        if (year >= 1) return '${year.toString().padLeft(1, "")} ${year > 1 ? S.current.years : S.current.year} ${S.current.ago}';
        else {
          if (month >= 1) return '${month.toString().padLeft(1, "")} ${month > 1 ? S.current.months : S.current.month} ${S.current.ago}';
          else return '${day.toString().padLeft(1, "")} ${day > 1 ? S.current.days : S.current.day} ${S.current.ago}';
        }
      } else if (hour > 0) {
        return '${hour.toString().padLeft(1, "")} ${hour > 1 ? S.current.hours : S.current.hour} ${S.current.ago}';
      } else if(minutes <= 1) {
        return S.current.momentAgo;
      } else {
        return '${minutes.toString().padLeft(1, "0")} ${S.current.minutesAgo}';
      }
    } else {
      return "Offline";
    }
  }

  static getDeviceId()async{
    // if (Utils.checkedTypeEmpty(deviceId)) return deviceId;
    var box = Hive.lazyBox('pairKey');
    deviceId =  await box.get("deviceId");
    return deviceId;
  }

  // server chi update cho nhung device chua co thong tin device (ip, name, ...)
  static uploadDeviceInfo(String token) async {
    var url  = "${Utils.apiUrl}users/update_device_info?token=$token&device_id=${await getDeviceId()}";
    Dio().post(url, data: {
      "data": await encryptServer({
        "device_info": await getDeviceInfo()
      })
    });
  }

  static String getStringFromParse(List parses){
    return parses.map((e) {
      if (e["type"] == "text") return e["value"];
      return "${e["trigger"]}${e["name"]}";
    }).toList().join("");
  }

  static Color checkColorRole(roleId, isDark) {
    switch (roleId) {
      case 1:
        return Color(0xffFF7A45);
      case 2:
        return Color(0xff73D13D);
      case 3:
        return Color(0xff36CFC9);
      case 4:
        return isDark ? Color(0xffFFFFFF) : Color(0xff2E2E2E);
      default:
        return Color(0xffb7b4b4);
    }
  }

  static unSignVietnamese(String text) {
    final _vietnamese = 'aAeEoOuUiIdDyY';
    final _vietnameseRegex = <RegExp>[
      RegExp(r'à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ'),
      RegExp(r'À|Á|Ạ|Ả|Ã|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ'),
      RegExp(r'è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ'),
      RegExp(r'È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ'),
      RegExp(r'ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ'),
      RegExp(r'Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ'),
      RegExp(r'ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ'),
      RegExp(r'Ù|Ú|Ụ|Ủ|Ũ|Ư|Ừ|Ứ|Ự|Ử|Ữ'),
      RegExp(r'ì|í|ị|ỉ|ĩ'),
      RegExp(r'Ì|Í|Ị|Ỉ|Ĩ'),
      RegExp(r'đ'),
      RegExp(r'Đ'),
      RegExp(r'ỳ|ý|ỵ|ỷ|ỹ'),
      RegExp(r'Ỳ|Ý|Ỵ|Ỷ|Ỹ')
    ];

    var result = text;
    for (var i = 0; i < _vietnamese.length; ++i) {
      result = result.replaceAll(_vietnameseRegex[i], _vietnamese[i]);
    }
    return result.toLowerCase();
  }

  static convertCharacter(String text) {
    final _vietnamese = 'aâăAÂĂeêEÊoôơOÔƠuưUƯyY';
    final _vietnameseRegex = <RegExp>[
      RegExp(r'à|á|ạ|ả|ã'),
      RegExp(r'â|ầ|ấ|ậ|ẩ|ẫ'),
      RegExp(r'ă|ằ|ắ|ặ|ẳ|ẵ'),
      RegExp(r'À|Á|Ạ|Ả|Ã'),
      RegExp(r'Â|Ầ|Ấ|Ậ|Ẩ'),
      RegExp(r'Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ'),
      RegExp(r'è|é|ẹ|ẻ|ẽ'),
      RegExp(r'ê|ề|ế|ệ|ể|ễ'),
      RegExp(r'È|É|Ẹ|Ẻ|Ẽ'),
      RegExp(r'Ê|Ề|Ế|Ệ|Ể|Ễ'),
      RegExp(r'ò|ó|ọ|ỏ|õ'),
      RegExp(r'ô|ồ|ố|ộ|ổ|ỗ'),
      RegExp(r'ơ|ờ|ớ|ợ|ở|ỡ'),
      RegExp(r'Ò|Ó|Ọ|Ỏ|Õ'),
      RegExp(r'Ô|Ồ|Ố|Ộ|Ổ|Ỗ'),
      RegExp(r'Ơ|Ờ|Ớ|Ợ|Ở|Ỡ'),
      RegExp(r'ù|ú|ụ|ủ|ũ'),
      RegExp(r'ư|ừ|ứ|ự|ử|ữ'),
      RegExp(r'Ù|Ú|Ụ|Ủ|Ũ'),
      RegExp(r'Ư|Ừ|Ứ|Ự|Ử|Ữ'),
      RegExp(r'ỳ|ý|ỵ|ỷ|ỹ'),
      RegExp(r'Ỳ|Ý|Ỵ|Ỷ|Ỹ')
    ];

    var result = text;
    for (var i = 0; i < _vietnamese.length; ++i) {
      result = result.replaceAll(_vietnameseRegex[i], _vietnamese[i]);
    }
    return result.toLowerCase();
  }

  static List parseQuillController(Document document) {
    List data = [];
    List<Node> nodes = document.root.children.toList();
    int lastNodeNotEmpty = nodes.lastIndexWhere((Node ele) => ele.toPlainText().trim() != '');
    nodes = nodes.sublist(0, lastNodeNotEmpty + 1);

    for(final i in nodes) {
      bool isCodeBlockOfNode = i.style.keys.toList().contains("code-block");
      List deltaOfNode = i.toDelta().toList();

      if(isCodeBlockOfNode) {
        if(checkedTypeEmpty(i.toPlainText().trim())) {
          data.add({
            'type': 'block_code',
            'value': i.toPlainText().trim(),
            'isThreeBackstitch': true
          });
        }
        continue;
      }

      for(Operation t in deltaOfNode){
        if(t.attributes == null) {
          data.add({
            'type': 'text',
            'value': t.value
          });
        } else {
          if(t.hasAttribute('code')) {
            data.add({
              'type': 'block_code',
              'value': t.value.toString().trim(),
              'isThreeBackstitch': false
            });
          } else if(t.hasAttribute('link')) {
            data.add({
              'type': 'text',
              'value': t.value
            });
          } else if(t.hasAttribute('mention')) {
            String value = t.attributes?.values.first;
            String type = value.contains("=======#") ? "issue" : "user";
            Map? dataMention;

            if (type == "issue") {
              final String text = value.replaceAll("=======#/", "").replaceAll("+++++++", "");
              final String id = text.split("^^^^^")[0];
              final String name = text.split("^^^^^")[1];
              final List<String> list = id.split("-");

              dataMention = {
                "type": type,
                "value": id,
                "trigger": "#",
                "name": name,
                "id": list[0],
                "workspace_id": list[1],
                "channel_id": list[2],
              };
            } else {
              final String text = value.replaceAll("=======@/", "").replaceAll("+++++++", "");
              final String id  = text.split("^^^^^")[0];
              final String name = text.split("^^^^^")[1];

              try {
                type = text.split("^^^^^")[2];
              } catch (e) {}

              dataMention = {
                "type": type,
                "value": id,
                "trigger": "@",
                "name": name
              };
            }
            data.add(dataMention);
          }
        }
      }
    }

    data.last['value'] = data.last['value'].trimRight();
    if(data.first['type'] != 'text') {
      data.insert(0, {
        'type': 'text',
        'value': ''
      });
    }

    return data;
  }

  static Map<String, MentionUser> getBeforeAndAfterMention(List<MentionUser> mentions, int index){
    MentionUser? before, after;
    try {
      before = mentions[index - 1];
    }catch (e) {
    }
    try {
       after = mentions[index + 1];
    } catch (e) {
    }
    return {"before": before ?? MentionUser.parseFromObject({}), "after": after ??  MentionUser.parseFromObject({})};
  }

  static void setDeviceId(param0) {
    deviceId = param0;
  }

  static fetchVersionApp()async {
    var box = Hive.lazyBox('pairKey');
    if (!checkedTypeEmpty(await box.get("android_auto_download"))) return;
    if (Platform.isIOS) return;
    try {
      var res = await Dio().get("${Utils.apiUrl}app/version_app?type=android");
      if (res.data["android"] != null)
        Work.platform.invokeMethod("android_native_install", res.data["android"]);
    } catch (e) {
    }

  }

  static Future<bool> localAuth() async {
    bool result = true;
    try {
      if ((await LocalAuth.LocalAuthentication().getAvailableBiometrics()).isNotEmpty)
        result = await LocalAuth.LocalAuthentication().authenticate(
          localizedReason: 'Please authenticate to continue',
          options: const AuthenticationOptions(biometricOnly: true)
        );
    } catch (e) {
      print("[[[[[[$e");
      if (e is PlatformException){
        if (e.code == "auth_in_progress" || e.code == "PermanentlyLockedOut" || e.code == "LockedOut" || (Platform.isIOS && e.code == "NotAvailable")) {
          result = false;
          Fluttertoast.showToast(
            msg: "An error occurred",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 13
          );
        }
      }
    }
    return result;
  }

  static Future<String> getDeviceIdentifier() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS){
      return (await deviceInfo.iosInfo).identifierForVendor.toString();
    }
    if (Platform.isAndroid){
      return (await deviceInfo.androidInfo).androidId.toString();
    }
    return "";
  }

  static String? getUserNickName(String? userId) {
    List members = Provider.of<Workspaces>(Utils.globalContext!, listen: false).members;
    List nickNameMembers = members.where((ele) => Utils.checkedTypeEmpty(ele['nickname'])).toList();
    int indexNickName = nickNameMembers.indexWhere((user) => userId == user["id"]);

    return indexNickName == -1 ? null : (nickNameMembers[indexNickName]["nickname"] ?? nickNameMembers[indexNickName]['full_name']);
  }

  static compareTime(TimeOfDay time) {
    TimeOfDay now = TimeOfDay.now();
    if (now.hour < time.hour) return false;
    if (now.hour > time.hour) return true;
    if (now.minute <= time.minute) return false;
    if (now.minute > time.minute) return true;
  }

  static parseMention(comment) {
    var context = globalContext;
    var parse = Provider.of<Messages>(context!, listen: false).checkMentions(comment);
    if (parse["success"] == false) return comment;
    return Utils.getStringFromParse(parse["data"]);
  }

  static parseComment(comment, bool value) {
    var commentMention = parseMention(comment);
    List list = value ? commentMention.split("\n") :  comment.split("\n");

    if (list.length > 0) {
      for (var i = 0; i < list.length; i++) {
        var item = list[i];

        if (i - 1 >= 0) {
          if ((list[i-1].contains("- [ ]") || list[i-1].contains("- [x]")) && !(item.contains("- [ ]") || item.contains("- [x]"))) {
            list[i-1] = list[i-1] + " " + item;
            list[i] = "\n";
          }
        }
        if (item.contains("- [ ]") || item.contains("- [x]")) {
          if (i + 2 < list.length) {
            if (list[i+1].trim() == "") {
              list[i+1] = "\n";
            }
          }
        } else {
          if (i < list.length - 1 && list[i] == "" && list[i+1] == "") {
            list[i] = "```";
            list[i+1] = "```";
          }
        }
      }
    }
    return list.join("\n");
  }

  static List<String> languages = [
    "c", "cc", "h", "c++", "h++", "hpp", "hh", "hxx", "cxx", "csharp", "c#", "pb", "pbi"
    'asc', 'apacheconf', 'osascript', 'arcade', 'arm', 'ahk', 'sh', 'zsh', 'cmake.in', "coffee", "cson", "iced",
    'jinja', 'docker', "bat", "cmd", 'erl', 'elixir', 'gms', 'golang', 'gql', 'https', 'http', 'hylang',
    'jsp', "js", "jsx", "mjs", "cjs", 'kt', 'ls', "mk", "mak", "md", "mkdown", "mkd", 'moon', 'nginxconf', 'nixos', "mm", "objc", "obj-c",
    'ml', 'scad', "pl", "pm", 'pf.conf', "postgres", "postgresql", "php", "php3", "php4", "php5", "php6", "php7", "ps", "ps1", 'pp',
    "py", "gyp", "ipython", "k", "kdb", 'qt', 're', "graph", "instances", "routeros", "mikrotik", "rb", "gemspec", "podspec", "thor", "irb",
    'rs', "sas", "SAS", 'sci', 'console', 'smali', 'st', 'ml', 'sol', 'sqf', 'stanfuncs', 'do', 'ado', "p21", "step", "stp", 'styl', 'tk',
    'craftcms', 'ts', 'vb', 'vbs', "v", "sv", "svh", 'tao', "html", "xhtml", "rss", "atom", "xjb", "xsd", "xsl", "plist", "wsf", "svg",
    "xpath", "xq", "yml", "YAML", "yaml", 'zep', 'dart', 'json', 'sql', 'swift', 'txt'
  ];

  static getLanguageFile(String text) {
    switch (text) {
      case 'cc':
      case 'c':
      case 'h':
      case 'cpp':
        return 'c';

      case 'sh':
      case 'zsh':
        return 'zsh';

      case 'ex':
      case 'exs':
        return 'elixir';

      case 'mm':
      case 'm':
        return 'objc';

      case 'py':
      case 'gyp':
      case 'ipy':
        return 'py';

      case "yml":
      case "YAML":
      case "yaml":
        return 'yaml';

      case 'go':
        return 'golang';

      default:
        return text;
    }
  }

  static Future<String> onRenderSnippet(url, {String? keyEncrypt }) async{
    try{
      if (keyEncrypt != null) {
        Response response = await Dio().get(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: 0
            ),
          );
        var string = utf8.fuse(base64).decode(decrypt(base64Encode(response.data) ,keyEncrypt));
        return string;
      } else {
        var client = HttpClient();
        const utf8 = const Utf8Codec();
        var uri = Uri.parse(url);

        var request =  await client.getUrl(uri);
        var response =  await request.close().timeout(const Duration(seconds: 2));
        var responseBody = await response.transform(utf8.decoder).join();
        return responseBody;
      }
    } on TimeoutException catch (e) {
      return e.toString();
    } on SocketException catch (e) {
      return e.toString();
    } catch (err) {
      return err.toString();
    }
  }

  static Future checkUpdateApp(context) async {
    try {
      if (kDebugMode) return;
      if (Platform.isAndroid){
        InAppUpdate.checkForUpdate().then((res) {
          print("_________________________________________________checkUpdateApp: $res");
          if (res.immediateUpdateAllowed)
            InAppUpdate.performImmediateUpdate();
        });
      } else {
        String url = "https://itunes.apple.com/lookup?bundleId=vn.pancake.chat";
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        String versionCurrent = packageInfo.version;
        var res = await Dio().get(url);
        var versionCurrentStore = (jsonDecode(res.data))["results"][0]["version"];
        if (int.parse("${versionCurrentStore.split(".").join()}") > int.parse("${versionCurrent.split(".").join()}")){
          return showDialog(
            context: context,
            builder: (BuildContext c){
            return CustomDialogNew(
              title: "An update is available",
              content: "Please update the app to the latest version",
              confirmText: "Update",
              onConfirmClick: (){
                Navigator.pop(context);
                Utils.openUrl("https://apps.apple.com/vn/app/pancake/id1527053006");
              },
              quickCancelButton: true,
            );
          });
        }
      }      
    } catch (e, t) { 
      print("_________________________________________________checkUpdateApp Error: $e \n $t");
    }
  }

  static Future<List<PlatformFile>> pickedFileOther() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

      return result?.files ?? [];
    } catch (e, t) {
      print("pickedFile: $e, $t");
      return [];
    }
  }

  static handleFileOtherData(List<PlatformFile> files) async {
    List results = [];

    try {
      for(PlatformFile file in files) {
        if(file.size == 0) {
          results+=[{}];
        } else if (file.size > 100000000) {
          Fluttertoast.showToast(
            msg: "File size more than 100MB",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            fontSize: 13
          );
          results+=[{}];
        } else {
          final String typeFile = file.name.split('.').last.toLowerCase();
          String type = 'other';
          Uint8List? bytes = await (File.fromUri(Uri.parse(file.path ?? ""))).readAsBytes();
          Map dataFile = {};

          if(['mov', 'mp4'].contains(typeFile)) {
            type = 'video';
            final imageThumbnail = await VideoThumbnail.thumbnailData(
              video: file.path ?? "",
              imageFormat: ImageFormat.JPEG,
              maxWidth: 1920,
              maxHeight: 1080,
              quality: 10,
            );
            var decodeImg = await decodeImageFromList(imageThumbnail!);

            final uploadFile = {
              "filename": file.name,
              "path": base64Encode(imageThumbnail),
              "image_data": {
                "width": decodeImg.width,
                "height": decodeImg.height
              }
            };

            dataFile = {
              "image_data": {
                "width": decodeImg.width,
                "height": decodeImg.height
              },
              "upload": uploadFile
            };
          } else if(['jpg', 'jpeg', 'heic', 'png', 'webp'].contains(typeFile)) {
            type = 'image';
            if (typeFile == 'heic') {
              final bytesImage = await File.fromUri(
                Uri.parse(
                  (await HeicToJpg.convert(file.path ?? '')) ?? ""
                )
              ).readAsBytes();

              bytes = bytesImage;
            }
          }

          results+=[{
            "name": file.name,
            "path": file.path,
            "mime_type": file.extension,
            "type": type,
            "bytes": bytes,
            ...dataFile,
          }];
        }
      }

      return results;
    } catch (e, t) {
      print("handleFileData  ${e.toString()} , $t");
      return [];
    }
  }

  static Future<List<Map>> pickedFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
      return (await Future.wait((result?.files ?? []).map((file)async {
        try {
          String? preview;
          String? mimeType;
          String fileName = file.name;
          Uint8List? bytes = await (File.fromUri(Uri.parse(file.path ?? ""))).readAsBytes();
          String path = file.path ?? "";
          String extentionImage = ".png,.jpg,.jpeg,.heic";
          String extentionVideo = ".mp4,.mov";
          try {
            mimeType = file.extension ?? "";
            preview = (await File(file.path ?? "").readAsString()).substring(0, 100);
          } catch (e) {}
          // file video
          if (mimeType != null && extentionVideo.contains(mimeType.toLowerCase())){
            final imageThumbnail = await VideoThumbnail.thumbnailData(
              video: file.path ?? "",
              imageFormat: ImageFormat.JPEG,
              maxWidth: 1920,
              maxHeight: 1080,
              quality: 10,
            );
            var decodeImg = await decodeImageFromList(imageThumbnail!);
            final uploadFile = {
              "filename": "${fileName.split(".").first}.$mimeType",
              "path": base64Encode(imageThumbnail),
              "image_data": {
                "width": decodeImg.width,
                "height": decodeImg.height
              }
            };
            return {
              "name":  "${fileName.split(".").first}.$mimeType",
              "path": path,
              "file": file,
              "bytes": bytes,
              "mime_type": mimeType,
              "type": "video",
              "image_data": {
                "width": decodeImg.width,
                "height": decodeImg.height
              },
              "upload": uploadFile
            };
          }
          // file image
          if (mimeType != null && extentionImage.contains(mimeType.toLowerCase())){
            if (".heic".contains(mimeType)){
              bytes = await (
                File.fromUri(
                  Uri.parse(
                    (await HeicToJpg.convert(path)) ?? ""
                  )
                )
              ).readAsBytes();
            }
            return {
              "name": "${fileName.split(".").first}.$mimeType",
              "file": file,
              "bytes": bytes,
              "type": "image",
              "mime_type": mimeType,
              "path": path
            };
          }
          // other
          return {
            "name": "${file.name}",
            "bytes": await File(file.path ?? "").readAsBytes(),
            "file": file,
            "mime_type": "${file.name.split(".").last}",
            "type": "other", 
            "preview": preview,
            "path": path
          };         
        } catch (e) {
          return null;
        }
      }))).whereType<Map>().toList();
    } catch (e, t) {
      print("pickedFile: $e, $t");
      return <Map>[];
    }
  }

  static String getRawTextFromAttachment(List att, String message) {
    String text = '';
    int index = att.indexWhere((e) => e['type'] == 'mention');
    List mentions = [];
    if(index != -1) mentions = att[index]['data'] ?? [];

    for(final item in mentions) {
      if(item['type'] == 'text') {
        text += item['value'];
      }
    }

    return text + message;
  }

  static Future<bool> requestPermission() async {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false; 
      }
    }
    return true;
  }
  // hàm này để lưu lại thông tin conversationId để ktra xem thông báo với conversation_id đó có phù hợp với người hiện tại hay ko?
  static saveListConversationIdToNative(List conversationIds) async {
    await Work.platform.invokeMethod("conversation_ids", conversationIds); 
  }

  // hàm này để lưu lại thông tin channelIds để ktra xem thông báo với channelId đó có phù hợp với người hiện tại hay ko?
  static saveListChannelIdToNative(List channelIds) async {
    await Work.platform.invokeMethod("channel_ids", channelIds); 
  }

  static openUrl(String? url) async{
    Uri uri = Uri.parse(url ?? "");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $e';
    }
  }

  static List<String> parseStringToMarkdown(String string) {
    List list = string.split('\n');
    int length = list.length;
    List<String> data = [];
    bool startBlockCode = false;

    for (var i = 0; i < length; i++) {
      String item = list[i] ?? "";

      if (item.trim().startsWith("```") && startBlockCode == false) {
        startBlockCode = true;
        data.add(item);
        continue;
      }

      if (startBlockCode) {
        data.last = data.last + "\n" + item;
        if (item.trim().endsWith("```")) {
          startBlockCode = false;
        }
      } else if ( i > 0 && (list[i-1].contains("- [ ]") || list[i-1].contains("- [x]")) && !(item.contains("- [ ]") || item.contains("- [x]")) ) {
        data.last = data.last + "\n" + item;
      } else {
        data.add(item);
      }
    }

    return data;
  }

  static String onChangeCheckbox(String intputString, bool value, String elText, int indexCheckbox) {
    List<String> stringData = Utils.parseStringToMarkdown(intputString);
    // int indexElText = stringData[indexCheckbox].indexOf(elText.trim());
    // String subString = stringData[indexCheckbox].substring(0, indexElText);
    // List listSubString = subString.split('');
    // var indexString;

    // for (var i = listSubString.length - 1; i >= 0; i--) {
    //   if (listSubString[i] == "]") {
    //     indexString = i - 1;
    //     break;
    //   }
    // }

    // print(stringData[indexCheckbox]);
    // if (indexString == -1 || indexString == null) return intputString;

    // String newText = stringData[indexCheckbox].replaceRange(indexString, indexString + 1, value ? "x" : " ");
    String newText = stringData[indexCheckbox];
    if (newText.startsWith('- [ ]')) {
      newText = newText.replaceFirst('- [ ]', '- [x]');
    } else if (newText.startsWith('- [x]') || newText.startsWith('-  [x]')) {
      newText = newText.replaceFirst('- [x]', '- [ ]');
      newText = newText.replaceFirst('-  [x]', '- [ ]');
    }
    stringData[indexCheckbox] = newText;
    return stringData.join('\n');
  }

  static String generateUUIDfromTimestamp({int? timestamp}) {
    return Uuid().v1(options: {'mSec': timestamp ?? DateTime.now().microsecondsSinceEpoch});
  }
}

final listAllApp = [
  {
    "id": 1,
    "name": "Snappy",
    "avatar_app": "assets/images/logo_app/snappy.jpg",
    "description": "Bring Snappy into Pancake Chat."
  },
  {
    "id": 2,
    "name": "POS",
    "avatar_app": "assets/images/logo_app/pos_app.png",
    "description": "Đồng bộ tin nhắn từ những trạng thái cấu hình POS."
  },
  {
    "id": 3,
    "name": "Zimbra",
    "avatar_app": "assets/images/logo_app/zimbra.png",
    "description": "Send emails into Pancake Chat to discuss them with your teammates."
  },
  {
    "id": 4,
    "name": "Biz Banking",
    "avatar_app": "assets/images/logo_app/bank_app.png",
    "description": "Thông báo biến động tài khoản ngân hàng."
  },
  {
    "id": 5,
    "name": "Github",
    "avatar_app": "assets/images/logo_app/github.png",
    "description": "Get updates from the world’s leading development platform on Pancake Chat."
  },
  {
    "id": 6,
    "name": "Trello",
    "avatar_app": "assets/images/logo_app/trello.png",
    "description": "Collaborate on Trello projects without leaving Pancake Chat."
  },
  {
    "id": 7,
    "name": "Twitter",
    "avatar_app": "assets/images/logo_app/twitter.png",
    "description": "Bring tweets into Pancake Chat."
  },
  {
    "id": 8,
    "name": "Google Calendar",
    "avatar_app": "assets/images/logo_app/google-calendar.png",
    "description": "See your schedule, respond to invites, and get event updates."
  },
  {
    "id": 9,
    "name": "Pancake Chat for Gmail",
    "avatar_app": "assets/images/logo_app/gmail.png",
    "description": "Send emails into Pancake Chat to discuss them with your teammates."
  },
  {
    "id": 10,
    "name": "Zoom",
    "avatar_app": "assets/images/logo_app/zoom.png",
    "description": "Easily start a Zoom video meeting directly from Pancake Chat."
  },
  {
    "id": 11,
    "name": "Google Drive",
    "avatar_app": "assets/images/logo_app/google-drive.png",
    "description": "Get notifications about Google Drive files within Pancake Chat."
  },
  // {
  //   "id": 12,
  //   "name": "VIB",
  //   "avatar_app": "assets/images/logo_app/logo-vib.png",
  //   "description": "Log in vib account"
  // }
  {
    "id": 13,
    "name": "${S.current.attendance}",
    "avatar_app": "assets/images/logo_app/Attendance.png",
    "description": "Control working-day of employee"
  }
];