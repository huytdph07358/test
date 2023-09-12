import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

import '../E2EE/key.dart';
import '../E2EE/x25519.dart';
import '../components/isar/message_conversation/service.dart';
import '../data_channel_webrtc/device_socket.dart';

class QRService {
  static final loginQrCodeController = StreamController<Map>.broadcast(sync: false);


  static getInforDeviceFromQR(String deviceIdRequest, String hash, String token, BuildContext context) async {
    try {
      showModalProgress(context);
      String currentDeviceId = await Utils.getDeviceId();
      var url = "${Utils.apiUrl}devices/get_infor_device_request?token=$token&device_id=$currentDeviceId";
      var response = await Dio().post(url, data: {
        "data": await Utils.encryptServer({
          "device_id_request": deviceIdRequest,
          "hash": hash
        })
      });
      var body = response.data;
      if (body["success"]){
        String randomString = Utils.getRandomString(50);
        Map? dataTransfer = await MessageConversationServices.processDataToLoginViaQr();
        var oneTimePerKey = await X25519().generateKeyPair();
        DeviceSocket.instance.channel!.push(event: "tranfer_data_qrcode", payload: {
          "data": Utils.encrypt(
            jsonEncode({
              ...(dataTransfer ?? {}),
              "random_string": randomString
            }),
            (await X25519().calculateSharedSecret(
              oneTimePerKey.secretKey, 
              KeyP.fromBase64(body["data"]["device_public_key"], true)
            )).toBase64()
          ),
          "one_time_public_key": oneTimePerKey.publicKey.toBase64(),
          "target_device_id": deviceIdRequest,
          "random_string": randomString,
          "device_id": await Utils.getDeviceId(),
          "user_id": Provider.of<Auth>(context, listen: false).userId
          
        });
      } else {
        loginQrCodeController.add({
          "status": "Login failed(#${body["error_code"]})"
        });
      }
    } catch (e) {
      loginQrCodeController.add({
          "status": "Login failed(${e.toString()})"
        });
      print("getInforDeviceFromQR: $e");
    }
  }

  static showModalProgress(BuildContext context){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          content: Container(
            child: StreamBuilder(
              stream: QRService.loginQrCodeController.stream,
              initialData: {
                "status": "Login processing"
              },
              builder: (context, snapshot) {
                Map data = (snapshot.data ?? {}) as Map;
                return  Text(data["status"] ??  "Login processing");
              }
            ),
          ),
        );
      }
    ).then((value) => Navigator.pop(context));
  }
}





// flow dang nha qr code

// B1: 

// desktop join "device_id:<desk_top_device>" voi params = {
//   "device_public_key": signedKey["pubKey"]
// }

// thong tin device_public_key dc luw trong assigns cua socket cua device
// socket
//   |> assign(:device_id, device_id)
//   |> assign(:device_public_key, device_public_key)
// b2:

// desktop ban event = "gen_qr_code_login_device" voi payload = {
//   device_info: device_info
// }

// server tra ve ma qr_code qua event = "qr_code" voi payload = {
//   "qr_code": <ma qr_code>
// }
// ma qr_code se het han trong 60s.
// chi gen ma qr_code khi device do ko dang trong 1 qua trinh nhan data nao het
// rdb_key_dang_dang nhap = "login:<device_id>" voi payload = {
//   "device_id_
// }

// rdb_key tren server  =  :crypto.hash(:sha256, "#{current_time}_#{device_id}_#{device_public_key}")
// data cua rdb_key = {
//   %{device_id: device_id, device_public_key: device_public_key, current_time: current_time} 
//   |> Map.merge(deviceInfo) 
// }

// desktop hien ma qr_code = <desktop_device_id>,<ma qr_code>


// b3

// mobile scan qr_code de lay dc thong tin device_id_reqauest + hash(ma qr_code do server tra ve desktop)
// mobile goi getInforDeviceFromQR(String deviceIdRequest, String hash, String token, BuildContext context) de lay dc thong tin chi tiet cua device can dang nhap
// mobile tao 1 chuoi randomString, 1 cap key X25519(oneTimePerKey)
// mobile chuan bi ma hoa data voi desktop 
//   dataTransfer = {
//     "direct_data": {},
//     "user_data": {},
//   }
//   data_encrypted = Utils.encrypt(
//     jsonEncode({
//       ...(dataTransfer ?? {}),
//       "random_string": randomString
//     })
//   )
// mobile ban thong tin len server voi event = "tranfer_data_qrcode", payload  = {
//   "data": data_encrypted,
//   "one_time_public_key": oneTimePerKey.publicKey.toBase64(),
//   "target_device_id": deviceIdRequest,
//   "random_string": randomString,
//   "device_id": await Utils.getDeviceId()
// }

// b4 
// server luu lai randomString, 
// ban event ve cho desktop voi event = "tranfer_data_qrcode", payload  = {
//   "data": "",
//   "one_time_public_key": one_time_public_key
// }

// b5

// desktop giai ma thong tin, luwu lai thong tin, roi ban 1 event len server bao la da luw thanh cong
// event = "push_end_login"
// payload = {
//   "random_string": <random String giai ma dc>,
//   "user_id": <user_id>
// }


