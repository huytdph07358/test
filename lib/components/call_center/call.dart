// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:provider/provider.dart';
// import 'package:sdp_transform/sdp_transform.dart';
// import 'package:workcake/common/utils.dart';
// import 'package:workcake/components/main_menu/emoji.dart';
// import 'package:workcake/models/models.dart';
// // cuoc goij 1-1

// class Call extends StatefulWidget{
  
//   final callData;

//   Call({
//     Key? key,
//     @required this.callData
//   }) : super(key: key);

//   @override
//   _CallState createState() => _CallState();
// }

// class _CallState extends State<Call>{
//   bool _offer = false;
//   late RTCPeerConnection _peerConnection;
//   var _localStream;
//   RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
//   RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();
//   var top = 0.0;
//   var left = 0.0;
//   var  localOffsetDx = 0.0;
//   var  localOffsetDy = 0.0;
//   var _channel;
//   @override
//   void initState() {
//     initCall();
//     super.initState();
//   }
   

//   initCall()async {
//     try {
//       await _localRenderer.initialize();
//       await _remoteRenderer.initialize();
//       _peerConnection = await _connect();

//       if (widget.callData["mode"] == "offer")
//         await _createOffer();
//       else {
//         await _setRemoteDescription();
//         await _createAnswer();
//         this.setState(() {});
//       }

//       _channel =  Provider.of<Auth>(context, listen: false).channel;

//       _channel.on("session_answer", (data, ref, _) async{
//         if (data["call_id"] == widget.callData["call_id"]){
//           widget.callData["users"] = data["users"];
//           await _setRemoteDescription();
//         }
//       });

//       _channel.on("recive_candidate", (data, ref, _)async{
//         if (widget.callData["mode"] == "offer" && data["candidate"] != null){
//           if (data["user_id"] != widget.callData["caller_id"]){
//             dynamic session = await jsonDecode(data["candidate"]);
//             dynamic candidate = new RTCIceCandidate(session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
//             await _peerConnection.addCandidate(candidate);
//             this.setState((){});
//           }
//         }
//         if (widget.callData["mode"] == "answer"){
//           if (data["user_id"] == widget.callData["caller_id"] && data["candidate"] != null){
//             dynamic session = await jsonDecode(data["candidate"]);
//             dynamic candidate = new RTCIceCandidate(session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
//             await _peerConnection.addCandidate(candidate);
//           }
//         }
//       });
//     } catch (err){
//       print("error: $err");
//     }
//   }

//   @override
//   deactivate() async{
//     super.deactivate();
//     try {
//       if (_localStream != null) {
//         _localStream.getTracks().forEach((element) async {
//           await element.dispose();
//         });
//         await _localStream.dispose();
//         _localStream = null;
//       }
//       _peerConnection.close();
//       _peerConnection.dispose();
//       _localRenderer.dispose();
//       _remoteRenderer.dispose();
//       _peerConnection.close();
//     } catch (err){

//     }

//   }

//   _connect() async {
//     try {
//       Map<String, dynamic> configuration = {
//         "iceServers": [
//           {"url": "stun:stun.l.google.com:19302"},
//         ]
//       };

//       final Map<String, dynamic> offerSdpConstraints = {
//         "mandatory": {
//           "OfferToReceiveAudio": true,
//           "OfferToReceiveVideo": true,
//         },
//         "optional": [],
//       };
//       _localStream = await _getUserMedia();
//       RTCPeerConnection pc = await createPeerConnection(configuration, offerSdpConstraints);

//       pc.addStream(_localStream);
//       pc.onIceCandidate = _onIceCandidate;
//       pc.onIceConnectionState = _onIceConnectionState;
//       pc.onConnectionState = _onConnectionState;
//       pc.onDataChannel = _onDataChannel;
//       pc.onTrack = _onTrack;


//       return pc;
//     } catch (e) {
//       print("_____ $e");
//     }
//   }

//   _onIceCandidate(e) {
//     if (e.candidate != null) {
//       if ((e.sdpMid.toString() == "video" || e.sdpMid.toString() == "audio") && e.candidate.toString().contains('udp')) {
//         _channel.push(event: "push_candidate", payload: {
//             "user_id": Provider.of<Auth>(context, listen: false).userId,
//             "call_id": widget.callData["call_id"],
//             "conversation_id": widget.callData["conversation_id"],
//             "candidate":  json.encode({
//               'candidate': e.candidate.toString(),
//               'sdpMid': e.sdpMid.toString(),
//               'sdpMlineIndex': e.sdpMlineIndex,
//             })
//         });
//       }
//     }
//   }
//   _onIceConnectionState(e) {
//     print("onIceConnectionState $e");
//   }
//   _onConnectionState(e){
//     print("onConnectionState $e");
//   }
//   _onDataChannel(data){
//     print("data $data");
//   }
//   _onTrack(fff){
//     _remoteRenderer.srcObject = fff.streams[0];
//   }

//   _createOffer() async {
//     RTCSessionDescription description = await _peerConnection.createOffer({'offerToReceiveVideo': 1});
//     var session = parse(description.sdp as String);
//     _offer = true;
//     var indexCaller = widget.callData["users"].indexWhere((ele)  {return ele["user_id"] == widget.callData["caller_id"];});
//     if (indexCaller != -1){
//       widget.callData["users"][indexCaller]["session"] = session;
//       Provider.of<Calls>(context, listen: false).updateCall(widget.callData);
//       Provider.of<Auth>(context, listen: false).channel.push(event: "push_session_caller", payload: widget.callData);
//       _peerConnection.setLocalDescription(description);
//     }
//   }

//   _setRemoteDescription()async{
//     dynamic session ;
//     if (widget.callData["mode"] == "answer"){
//       var indexUserCaller = widget.callData["users"].indexWhere((u) => u["user_id"] == widget.callData["caller_id"]);
//       session =  widget.callData["users"][indexUserCaller]["session"];
//     }
//     else {
//       // tim session cuar nguoi nhanwidget
//       var indexUserAns = widget.callData["users"].indexWhere((u) => u["user_id"] != widget.callData["caller_id"]);
//       session =  widget.callData["users"][indexUserAns]["session"];
//     }

//     var sdp = write(session, null);

//     print(">>>>>>>>>>   ${ widget.callData["mode"] == "answer" ? "offer" : "anser"}");
//     RTCSessionDescription desp  = new RTCSessionDescription(sdp, !_offer ? "offer": "answer");
//     _peerConnection.setRemoteDescription(desp);
//   }

//   _createAnswer() async {
//     RTCSessionDescription description = await _peerConnection.createAnswer({'offerToReceiveVideo': 1},);
//     var session = parse(description.sdp as String);
//     var indexUserAns = widget.callData["users"].indexWhere((u) => u["user_id"] != widget.callData["caller_id"]);
//     if (indexUserAns != -1){
//       widget.callData["users"][indexUserAns]["session"] = session;
//       Provider.of<Auth>(context, listen: false).channel.push(event: "push_session_answer", payload: widget.callData);
//       _peerConnection.setLocalDescription(description);
//     }
//   }
  
//   _getUserMedia() async {
//     final Map<String, dynamic> mediaConstraints = {
//       'audio': true,
//       'video': true,
//     };
//     MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
//     setState(() {
//       _localRenderer.srcObject = stream;
//     });
//     return stream;
//   }

//   @override
//   Widget build(BuildContext context) {
//     var sizeScreen = MediaQuery.of(context).size;
//     return Positioned(
//       width: Utils.isDesktop() ? 500 : sizeScreen.width, height: Utils.isDesktop() ? 500: sizeScreen.height,
//       top: top, left: left,
//       child: GestureDetector(
//         onPanStart: (detail){
//           if (Utils.isDesktop()){
//             localOffsetDx = detail.localPosition.dx;
//             localOffsetDy = detail.localPosition.dy;
//           }
//         },
//         onPanUpdate: (detail){
//           if (Utils.isDesktop())
//             setState(() {
//               left  = detail.globalPosition.dx - localOffsetDx;
//               top = detail.globalPosition.dy - localOffsetDy;
//             });
//         },
//         child: Stack(
//           children: [
//             Container(
//              child: SizedBox(
//               child: Row(children: [
//                 Flexible(
//                   child: new Container(
//                     key: new Key("remote"),
//                     margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
//                     decoration: new BoxDecoration(color: Colors.black),
//                     child: new RTCVideoView(_remoteRenderer, mirror: false),
//                   ),
//                 ),
//               ])),
//             ),
//             Container(
//              child: SizedBox(
//               height: 150,
//               width: 200,
//               child: Row(children: [
//                 Flexible(
//                   child: new Container(
//                     key: new Key("local"),
//                     margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
//                     decoration: new BoxDecoration(color: Colors.black),
//                     child: new RTCVideoView(_localRenderer, mirror: true),
//                   ),
//                 ),
//               ])),
//             ),
//             Positioned(
//               bottom: 0,
//               child: Container(
//                 width: Utils.isDesktop() ? 500 : sizeScreen.width, height:100,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     HoverItem(
//                       child: GestureDetector(
//                         child: Icon(_localStream != null && _localStream.getAudioTracks()[0].enabled ? Icons.mic_off_outlined : Icons.mic_none_outlined, color: Color(0xFFf5f5f5), size: 30,),
//                         onTap: () async {
//                           if (_localStream != null)
//                             setState(() {
//                               _localStream.getAudioTracks()[0].enabled = !_localStream.getAudioTracks()[0].enabled;
//                             });
//                         },
//                       ) ,
//                     ),
//                     HoverItem(
//                       child: GestureDetector(
//                         child: Icon(Icons.call_end, color: Color(0xFFff4d4f), size: 30,),
//                         onTap: () async{
//                          if (_localStream != null) {
//                             _localStream.getTracks().forEach((element) async {
//                               await element.dispose();
//                             });
//                             await _localStream.dispose();
//                             _localStream = null;
//                           }
//                           _peerConnection.close();
//                           Provider.of<Auth>(context, listen: false).channel.push(event: "endcall", payload: {
//                             "call_id": widget.callData["call_id"],
//                             "conversation_id": widget.callData["conversation_id"]
//                           });
//                         },
//                       ) ,
//                     ),
//                      HoverItem(
//                       child: GestureDetector(
//                         child: Icon(Icons.cameraswitch_outlined, color: Color(0xFFfafafa), size: 30,),
//                         onTap: () async {
//                           setState(() {
//                             Helper.switchCamera(_localStream.getVideoTracks()[0]);
//                           });
//                         },
//                       ) ,
//                     )
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }