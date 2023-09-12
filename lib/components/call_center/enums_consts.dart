import 'package:flutter_webrtc/flutter_webrtc.dart';

const Map<String, dynamic> CONFIGURATION = {
  "iceServers": [
    {
      'url': "turn:113.20.119.31:3478",
      'username': "panchat",
      'credential': "panchat"
    },
  ]
};
const Map<String, dynamic> OFFERSDPCONSTRAINTS = {
  "mandatory": {
    "OfferToReceiveAudio": true,
    "OfferToReceiveVideo": true,
  },
  "optional": [
    {'DtlsSrtpKeyAgreement': true}
  ],
};


enum CallConnectionState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
}

enum PIPViewCorner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}
const defaultAnimationDuration = Duration(milliseconds: 200);

typedef void CallStateCallback(CallConnectionState state);
typedef void StreamStateCallback(MediaStream stream);
typedef void OtherEventCallback(dynamic event);