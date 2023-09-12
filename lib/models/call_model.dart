import 'package:flutter/material.dart';
import 'package:workcake/components/call_center/call_manager.dart';

class Calls extends ChangeNotifier {
  bool _isCallViewShowFloat = false;
  Map user = {}; 

  bool get isCallViewShowFloat => _isCallViewShowFloat;
  set isCallViewShowFloat(value) {
    _isCallViewShowFloat = value;
    notifyListeners();
  }

  void onMessage(message, context) {
    callManager.onMessage(message, context);
  }
}
