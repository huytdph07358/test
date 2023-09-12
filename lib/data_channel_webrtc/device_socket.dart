import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/models/device_provider.dart';
import 'package:workcake/qr_code/qr_service.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../E2EE/key.dart';
import '../E2EE/x25519.dart';
import '../common/utils.dart';

class Device {
  late final String deviceId;
  late final String ipAddress;
  late final String platform;
  late final String name;
  late final String pubIdentityKey;
  late final bool readyToUse;
  Device(this.deviceId, this.ipAddress, this.platform, this.name, this.pubIdentityKey, this.readyToUse);
}

class DataWebrtcStreamStatus{
  late String status;
  late String deviceId;
  late String targetDeviceId;
  late String sharedKey;

  DataWebrtcStreamStatus(this.status, this.deviceId, this.targetDeviceId, this.sharedKey);
}

class DeviceSocket {
  static DeviceSocket instance = DeviceSocket();

  DataWebrtcStreamStatus? dataWebrtcStreamStatus; 

  
  // local se dc su dung khi device nay gui yeu cau den device khac
  RTCPeerConnection? localPeerConnection;
  RTCDataChannel? localChannel;
  RTCDataChannelInit? localDdataChannelDict;
  RTCSessionDescription? localOfferSessionDescription;
  RTCSessionDescription? localAnswerSessionDescription;
  PhoenixSocket? socket;
  PhoenixChannel? channel;
  // String? deviceId;
  String? targetDevice;
  String? currentDevice;
  String? sharedKeyCurrentVSTarget;
  Function? callback;
  List<RTCIceCandidate> remoteIceCandidates = [];
  List<Map> chunkedFile = [];

  // final qrCodeStreamController = StreamController<String?>.broadcast(sync: false);
  final syncDataWebrtcStreamController = StreamController<DataWebrtcStreamStatus>.broadcast(sync: false);
  static DataWebrtcStreamStatus dataWebrtcStreamStatic = DataWebrtcStreamStatus("", "", "", "");
  final qrCodeStreamController = StreamController<String?>.broadcast(sync: false);
  String? dataQRCode;

  void sendRequestQrCode() async {
    var deviceInfo = await Utils.getDeviceInfo();
    channel!.push(event: "gen_qr_code_login_device", payload: {"device_info": deviceInfo});
  }

  void setPairDeviceId(String targetDeviceId, String currentDeviceId, String sharedKey){
    targetDevice = targetDeviceId;
    currentDevice = currentDeviceId;
    sharedKeyCurrentVSTarget = sharedKey;
    dataWebrtcStreamStatus = DataWebrtcStreamStatus("Connecting", currentDeviceId, targetDeviceId, sharedKey);
    syncDataWebrtcStreamController.add(dataWebrtcStreamStatus!);
  }

  Future reconnect() async {
    channel!.leave();
    channel = null;
    dataQRCode = null;
    qrCodeStreamController.add(null);
    socket!.disconnect();
    await Utils.initPairKeyBox();
    await initPanchatDeviceSocket();
  }

  // socket theo tung device
  Future<void> initPanchatDeviceSocket() async {
    try {
      socket = new PhoenixSocket(
        Utils.socketUrl, 
        socketOptions: PhoenixSocketOptions(
          heartbeatIntervalMs: 10000
        )
      );
      await socket!.connect();
      var boxKey  = await Hive.openLazyBox("pairKey");
      var identityKey  = await boxKey.get("identityKey");
      // device_public_key laf signedKey
      currentDevice = await Utils.getDeviceId();
      channel = socket!.channel("device_id:$currentDevice", {
        "device_public_key": identityKey["pubKey"],
        "device_identifier": await Utils.getDeviceIdentifier()
      });
      channel!.join();
      channel!.on("set_ice_candidate", (payload, ref, joinRef) {
        List iceCandidates = payload!["ice_candidates"];
        for (var i = 0; i < iceCandidates.length; i++){
          RTCIceCandidate remote = RTCIceCandidate(
            iceCandidates[i]["candidate"],
            iceCandidates[i]["sdpMid"],
            iceCandidates[i]["sdpMLineIndex"],
          );
          if (localPeerConnection != null) localPeerConnection!.addCandidate(remote);
          else remoteIceCandidates += [remote];
        }
      });

      channel!.on("login_status", (payload, ref, joinRef) async {
        if (payload == null) return;
        if (payload["success"]) {
          QRService.loginQrCodeController.add({
            "status": "Login success"
          });
          if (await Vibrate.canVibrate) {
            Vibrate.vibrate();
          }
          try {
            LazyBox box  = Hive.lazyBox('pairKey');
            var idKey =  await box.get("identityKey");
            String publicKeyTargetDevice = payload["data"]["public_key_target_device"];
            String sharedKey = (await X25519().calculateSharedSecret(KeyP.fromBase64(idKey["privKey"], false), KeyP.fromBase64(publicKeyTargetDevice, true))).toBase64();
            DeviceSocket.instance.setPairDeviceId(payload["data"]["device_id"], await Utils.getDeviceId(), sharedKey);
            MessageConversationServices.syncViaFile(sharedKey, payload["data"]["device_id"]);      
          } catch (e, trace) {
            print("login_status: $e  $trace");
          }

          await Future.delayed(Duration(seconds: 1));
          if (Utils.loginQrContext != null) Navigator.pop(Utils.loginQrContext!);
      } else  QRService.loginQrCodeController.add({
            "status": "Login failed(#${payload["error_code"]})"
          });
        return;
      });

      channel!.on("get_list_device", (payload, ref, joinRef){
        List<Device> devices = (payload!["data"] as List).map((e) => Device(
          e["device_id"], e["device_info"]["ip"],  e["device_info"]["platform"] ?? "unknown",  e["device_info"]["name"], e["pub_identity_key"], e["ready_to_use"]
        )).toList();
        Provider.of<DeviceProvider>(Utils.globalContext!, listen: false).setDevices(devices);
      });   
    } catch (e) {
      print("initPanchatDeviceSocket: $e");
    }
  }

  syncDataToOtherDevice(String targetDeviceId, String sharedKey) async {
    setPairDeviceId(targetDeviceId, await Utils.getDeviceId(), sharedKey);
    // DeviceSocket.instance.channel.push("connect_device_to_send")
  }
  
}