import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:callkeep/callkeep.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/call_center/enums_consts.dart';
import 'package:workcake/models/models.dart';
import 'package:sdp_transform/sdp_transform.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:workcake/components/call_center/call_view.dart';
import 'package:workcake/components/call_center/session_call_manager.dart';

Map<String, dynamic> _createParams(data) {
  return <String, dynamic>{
    'id': data["firebase_session_id"] ?? data["session_id"],
    'nameCaller': data["caller"] ?? data["full_name"],
    'appName': 'Panchat',
    'avatar': data["avatar_url"],
    'handle': 'call you in Pancake',
    'type': data["type"] == "video" ? 1 : 0,
    'duration': 45000,
    'android': <String, dynamic>{
      'isCustomNotification': true,
      'isShowLogo': false,
      'isShowCallback': false,
      'ringtonePath': 'incoming_sound.mp3',
      'backgroundColor': '#2a87c8',
      'actionColor': '#4CAF50'
    },
  };
}

Future<void> firebaseCallBackgroundHandler(RemoteMessage message) async {
  var params = _createParams(message.data);
  print("firebase_call_id: ${message.data["firebase_session_id"]}");
  if (message.data["incoming_notification"] == "start") await FlutterCallkitIncoming.showCallkitIncoming(params);
  if (message.data["incoming_notification"] == "end") await FlutterCallkitIncoming.endAllCalls();
}

void _androidNotifyRegister() {
  try {
    FlutterCallkitIncoming.onEvent.listen((event) {
      switch (event!.name) {
        case CallEvent.ACTION_CALL_INCOMING:
        break;

        case CallEvent.ACTION_CALL_ACCEPT:
          final session = SessionCallManager.sessionWithId(event.body["id"]);
          if (session.readyForActive) {
            session.active();
          }
        break;

        case CallEvent.ACTION_CALL_ENDED:
          final session = SessionCallManager.sessionWithId(event.body["id"]);
          if (session.readyForAbort) {
            session.abort();
          }
        break;

        case CallEvent.ACTION_CALL_DECLINE:
          final session = SessionCallManager.sessionWithId(event.body["id"]);
          if (session.readyForAbort) {
            session.abort();
          }
        break;

        case CallEvent.ACTION_CALL_TOGGLE_AUDIO_SESSION:
          break;
        default:
      }
    });
  } catch (e,trace) {
    print("$e\n$trace");
  }
}

class CallManager {
  BuildContext? _context;
  BuildContext? _rootContext;
  static CallManager get instance => _getInstance();
  static CallManager? _instance;
  FlutterCallkeep? _callKeep;
  OverlayEntry? callviewOverlayEntry;

  CallStateCallback? onCallStateChange;
  StreamStateCallback? onLocalStream;
  StreamStateCallback? onAddRemoteStream;
  RTCPeerConnection? _peerConnection;
  List<RTCIceCandidate> _remoteCandidates = [];
  RTCSessionDescription? _remoteDescription;

  MediaStream? localStream;
  late String _selfId;
  bool isMuteMic = false;
  bool isOnVideo = false;
  bool isSpeakerPhone = false;
  String sessionId = "";
  String _mediaType = "";
  String? _apnsToken;

  Map<String, dynamic> _peerIdToPeer = {};
  String? _peerId;
  

  static CallManager _getInstance () {
    if (_instance == null) {
      _instance = CallManager._internal();
    }
    return _instance!;
  }
  dynamic channel;
  var deviceId;
  CallManager._internal();

  void init(BuildContext context) async {
    try {
      this._rootContext = context;
      this._context = this._rootContext;
      channel = Provider.of<Auth>(context, listen: false).channel;
      deviceId = await Utils.getDeviceId();
      _selfId = Provider.of<User>(context, listen: false).currentUser["id"];
      if (Platform.isIOS) {
        _iosCallkitRegister();
      } else if (Platform.isAndroid) {
        _androidNotifyRegister();
        _getLastActiveCall(null);
      }      
    } catch (e, t) {
      print("$e,,,,,, $t");  
    }

  }

  String? getApnsToken() => _apnsToken;

  void _iosCallkitRegister() {
    if (_callKeep == null) {
      _callKeep = FlutterCallkeep();
      _callKeep!.setup(
        _context,
        <String, dynamic>{
          'ios': {
            'appName': 'Pancake',
          },
        },
        backgroundMode: true
      );
    }
    
    _callKeep?.on(CallKeepDidDisplayIncomingCall(), _didDisplayIncomingCall);
    _callKeep?.on(CallKeepPushKitToken(), _onPushKitToken);
    _callKeep?.on(CallKeepPerformAnswerCallAction(), _onPerformAnswer);
    _callKeep?.on(CallKeepPerformEndCallAction(), _onPerformEndCall);
    _callKeep?.on(CallKeepDidActivateAudioSession(), _onDidActiveAudioSession);
  }

  Future<void> pushNotify(data) async {
    final params = _createParams(data);
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }


  void _getLastActiveCall(String? callId) async {
    if (Platform.isIOS) {
      return _sendMediaEvent("get_call_session", {
        'id': callId!
      });
    } else if (Platform.isAndroid) {
      final calls = await FlutterCallkitIncoming.activeCalls();
      final objCalls = calls is String ? json.decode(calls) : calls;
      if (objCalls is List) {
        if (objCalls.isNotEmpty) {
          final lastActiveCall = objCalls.last;
          final session = SessionCallManager.sessionWithId(lastActiveCall["id"]);
          session.active();
          return _sendMediaEvent("get_call_session", {
            'id': lastActiveCall['id']
          });
        }
      }
    }
  }

  void _onPushKitToken(CallKeepPushKitToken event) {
    print('[onPushKitToken] token => ${event.token}');
    _apnsToken = event.token;
  }

  void _didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) async {
    _mediaType = event.hasVideo != null && event.hasVideo == true ? "video" : "audio";
    _createStream().then((stream) => {this.localStream = stream});
  }

  void _onDidActiveAudioSession(CallKeepDidActivateAudioSession event) {
  }

  void _onPerformAnswer(CallKeepPerformAnswerCallAction event) {
    final callId = event.callUUID;
    if (callId != null) {
      final session = SessionCallManager.sessionWithId(callId);
      if (session.readyForActive) {
        session.active();
      } else {
        if (!Platform.isIOS) return;
        session.readyForActive = true;
        _getLastActiveCall(callId);
      }
    }
  }

  void _onPerformEndCall(CallKeepPerformEndCallAction event) {
    final callId = event.callUUID;
    if (callId != null) {
      final session = SessionCallManager.sessionWithId(callId);
      if (session.readyForAbort) {
        session.abort();
      } else {
        session.readyForAbort = true;
      }
    }
  }

  _handleSessionAccept(String _) {
    if (_context != null) {
      // Navigator.push(_context!,
      //   PageRouteBuilder(pageBuilder: (context, ani1, ani2) => CallView(user: _peerIdToPeer[_peerId], callback: _didCompleteCallViewAnswer, session: sessionId))
      // );
      callviewOverlayEntry = OverlayEntry(
        builder: (context) {
          return CallView(user: _peerIdToPeer[_peerId], callback: _didCompleteCallViewAnswer, session: sessionId);
        }
      );
      Overlay.of(_context!)?.insert(callviewOverlayEntry!);
    }
  }

  _handleSessionAbort(String callId) {
    _handleSessionTerminate();
    this.terminateConnect();
    if (Platform.isIOS) _callKeep?.endCall(callId);
    else if (Platform.isAndroid) FlutterCallkitIncoming.endAllCalls();
  }

  _handleSessionTerminate() async {
    if (_context != null && _context?.widget is CallView) {
      final session = SessionCallManager.sessionWithId(sessionId);
      if (session.type == "offer") {
        await _createEndMessage();
      }
      callviewOverlayEntry?.remove();
      this._context = this._rootContext;
    }
  }

  _decodeRemoteDescription(String jsonRemoteDescription) async {
    final sdpSession = await jsonDecode(jsonRemoteDescription);
    String sdp = write(sdpSession, null);
    RTCSessionDescription description = new RTCSessionDescription(sdp, "offer");

    return description;
  }

  _didCompleteCallViewAnswer(BuildContext context) async {
    this._context = context;
    this.localStream = await _createStream();
    await _createConnect();
    await _peerConnection!.setRemoteDescription(_remoteDescription!);
    await _createAnswer();
    if (_remoteCandidates.length > 0) {
      _remoteCandidates.forEach((candidate) async {
        await _peerConnection!.addCandidate(candidate);
      });
      _remoteCandidates.clear();
    }
    onLocalStream?.call(localStream!);
    onCallStateChange?.call(CallConnectionState.CallStateConnected);
  }

  Future<void> onMessage (message, context) async {
    bool correctEvent = _validateCorrectEvent(message);
    if (!correctEvent) return;
    switch (message['type']) {
      case "offer":
        final peer = message["from"] as Map;
        this._peerId = peer["id"];
        this._mediaType = message["media_type"];
        this.sessionId = message["session_id"];
        _peerIdToPeer[_peerId!] = peer;
        this._remoteDescription = await _decodeRemoteDescription(message["description"]);

        final session = SessionCallManager.sessionWithId(sessionId).withType("answer");
        if (Platform.isAndroid && session.isNotActive) pushNotify({...peer, "session_id": this.sessionId, "type": message["media_type"]});

        session.onAccept(_handleSessionAccept);
        session.onAbort(_handleSessionAbort); 
      break;
      case "answer":
        final sdpSession = await jsonDecode(message["description"]);
        final String sdp = write(sdpSession, null);
        final RTCSessionDescription description = new RTCSessionDescription(sdp, "answer");
        await _peerConnection!.setRemoteDescription(description);
        onCallStateChange?.call(CallConnectionState.CallStateConnected);
      break;
      case "candidate":
        RTCIceCandidate candidate = RTCIceCandidate(message["candidate"], message["sdpMid"], message["sdpMlineIndex"]);
        if (_peerConnection != null) {
          await _peerConnection!.addCandidate(candidate);
        } else {
          _remoteCandidates.add(candidate);
        }
      break;
      case "broadcast":
        var otherDevice = message["device_id"];
        if (deviceId != otherDevice) {
          final session = SessionCallManager.sessionWithId(message["session_id"]);
          releaseConnect();
          _handleSessionTerminate();
          FlutterCallkitIncoming.endCall({'id': session.id});
          session.clean();
        }
      break;
      case "terminate":
        final sessionTerminateId = message["session_id"];
        final session = SessionCallManager.sessionWithId(sessionTerminateId);
        releaseConnect();
        _handleSessionTerminate();
        if (Platform.isIOS) _callKeep?.endCall(sessionTerminateId);
        else if (Platform.isAndroid) FlutterCallkitIncoming.endCall({'id': sessionTerminateId});
        session.clean();
      break;
    }
  }

  Future<bool> _createConnect() async {
    if (_peerConnection != null) return false;
    RTCPeerConnection pc = await createPeerConnection(CONFIGURATION, OFFERSDPCONSTRAINTS);
    pc.addStream(localStream!);
    pc.onAddStream = (stream) {
      onAddRemoteStream?.call(stream);
    };
    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        return _sendMediaEvent('candidate', {
          'from': _selfId,
          'to': _peerId,
          'candidate': e.candidate.toString(),
          'sdpMid': e.sdpMid.toString(),
          'sdpMlineIndex': e.sdpMLineIndex,
          'session_id': sessionId
        });
      }
    };
    pc.onIceConnectionState = (state) {
      print(state.toString());
    };
    this._peerConnection = pc;
    return true;
  }
  Future<void> _createOffer() async {
    try {
      RTCSessionDescription description = await _peerConnection!.createOffer({'offerToReceiveVideo': 1});
      await _peerConnection!.setLocalDescription(description);
      var sdp = parse(description.sdp as String);
      return _sendMediaEvent('offer', {
        'from': _selfId,
        'to': _peerId,
        'description': json.encode(sdp),
        'session_id': sessionId,
        'media_type': _mediaType
      }); 
    } catch (e) {
      print(StackTrace.fromString(e.toString()));
    }
  }
  Future<void> _createAnswer() async {
    try {
      RTCSessionDescription description = await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});
      await _peerConnection!.setLocalDescription(description);
      var sdp = parse(description.sdp as String);
      return _sendMediaEvent('answer', {
        'from': _selfId,
        'to': _peerId,
        'description': json.encode(sdp),
        'device_id': deviceId,
        'session_id': sessionId
      });
    } catch (e) {
    }
  }
  Future<MediaStream> _createStream() async {
    if (this.localStream != null) return this.localStream!;
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': _mediaType == "video" ? {
        'mandatory': {
          'minWidth':'640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      } : false
    };
    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    return stream;
  }

  Future<void> toggleCamera() async {
    if (this.localStream != null && this.localStream!.getVideoTracks().isNotEmpty) {
      Helper.switchCamera(this.localStream!.getVideoTracks()[0]);
    }
  }


  void _sendMediaEvent(event, data) {
    Timer.run(() {
      channel.push(event: event, payload: data);
    });
  }

  bool _validateCorrectEvent(event) {
    final type = event["type"];
    final peer = event["from"];
    final peerId = peer == null ? null : peer is Map ? peer["id"] : peer;

    switch (type) {
      case "offer":
        return this._peerId == null;
      case "answer":
        return this._peerConnection != null;
      case "terminate":
        return this._peerId != null && this._peerId == peerId 
        || this._peerConnection?.connectionState == RTCPeerConnectionState.RTCPeerConnectionStateClosed 
        || this._peerConnection?.iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateClosed;
      case "broadcast":
        return this._peerId != null;
      default:
        return this._peerId == null || this._peerId == peerId;
    }
  }

  Future<void> calling (context, peer, conversationId) async {
    if (_peerConnection != null) return;
    this._mediaType = "video";
    this._peerId = peer["id"] ?? peer["user_id"];
    this.sessionId = Uuid().v4();
    final session = SessionCallManager.sessionWithId(sessionId).withType("offer");
    session.onAbort(_handleSessionAbort);

    callviewOverlayEntry = OverlayEntry(
      builder: (context) {
        return CallView(user: peer, callback: (context) async {
          this._context = context;
          this.localStream = await _createStream();
          onLocalStream?.call(localStream!);
          final _success = await _createConnect();
          if (_success) await _createOffer();
        }, 
        conversationId: conversationId,
        session: sessionId,
        );
      }
    );
    Overlay.of(context)?.insert(callviewOverlayEntry!);
  }

  Future<void> setEnableMic(value) async {
    if (localStream != null) {
      localStream!.getAudioTracks()[0].enabled = value;
    }
  }

  Future<void> toggleSpeakerPhone(value) async {
    if (localStream != null && localStream!.getAudioTracks().isNotEmpty) {
      localStream!.getAudioTracks()[0].enableSpeakerphone(value);
    }
  }

  Future<void> setEnableVideo(value) async {
    if (localStream != null) {
      localStream!.getVideoTracks()[0].enabled = value;
    }
  } 

  Future<void> _createEndMessage() async {
    final token = Provider.of<Auth>(_context!, listen: false).token;
    final session = SessionCallManager.sessionWithId(this.sessionId);
    var dataMessage = {
      "message": _mediaType == "video" ? "Cuộc gọi video đã kết thúc" : "Cuộc gọi audio đã kết thúc",
      "attachments": [{"type": "call_terminated", "data": {"timerCounter": session.timer, "mediaType": this._mediaType}}], 
      "title": "",
      "conversation_id": (_context!.widget as CallView).conversationId,
      "show": true,
      "id": "",
      "user_id": _selfId,
      "avatar_url": (this._context!.widget as CallView).user["avatar_url"],
      "full_name": (this._context!.widget as CallView).user["full_name"],
      "time_create": DateTime.now().add(new Duration(hours: -7)).toIso8601String(),
      "count": 0,
      "sending": true,
      "success": true,
      "fake_id": Utils.getRandomString(20),
      "current_time": DateTime.now().millisecondsSinceEpoch * 1000,
      "isSend": true,
      "isDesktop": true
    };
    print("Create system message");
    await Provider.of<DirectMessage>(_context!, listen: false).handleSendDirectMessage(dataMessage, token);
  }

  void terminateConnect () {
    releaseConnect();
    return _sendMediaEvent('terminate', {
      'from': _selfId,
      'to': _peerId,
      "session_id": sessionId,
      'device_id': deviceId
    });
  }

  releaseConnect() async {
    await localStream?.dispose();
    await _peerConnection?.close();
    await _peerConnection?.dispose();
    _remoteCandidates.clear();
    _peerConnection = null;
    _peerId = null;
    localStream = null;
  }
}

final CallManager callManager = CallManager.instance;