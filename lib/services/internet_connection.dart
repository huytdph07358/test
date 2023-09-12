import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

class StreamStatusConnection extends ValueNotifier<bool>{
  static final instance = StreamStatusConnection();
  final _statusConnectionController = StreamController<bool>.broadcast(sync: false);

  StreamStatusConnection(): super(false);
  Stream<bool> get status => _statusConnectionController.stream;

  setConnectionStatus(bool value) {
    _statusConnectionController.add(value);
  }

  static Future checkConnection() async {
    var resultPing;
    try {
      await Future.delayed(Duration(seconds: 1));
      resultPing = await InternetAddress.lookup('google.com.vn');
    } catch(e){
    }
    StreamStatusConnection.instance.setConnectionStatus(resultPing != null);
  }
}

class StatusConnectionView extends StatelessWidget{
  ///Hàm này để update thông tin wifi user để phục vụ việc auto chấm công
  updateWifiConnection() async {
    final auth = Provider.of<Auth>(Utils.globalContext!, listen: false);
    final info = NetworkInfo();
    String ssid = await info.getWifiName() ?? "";
    auth.channel.push(event: "update_user_wifi", payload: {"ssid": ssid});
  }

  @override
  Widget build(BuildContext context) {
    bool connectionStatus = Provider.of<Work>(context, listen: false).connectionStatus;

    return Container(
      child: StreamBuilder(
        initialData: true,
        stream: StreamStatusConnection.instance.status,
        builder: (context, snappshort){
          if (snappshort.data != null && snappshort.data != connectionStatus) {
            Timer.run(() { 
              Provider.of<Work>(context, listen: false).setConnection(snappshort.data as bool);
            });
            updateWifiConnection();
          } 

          return Container(
            child: (snappshort.data as bool) ? Container(): Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100]!.withOpacity(0.8),
                 borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)
                  // topRight: Radius.circular(10)
                ),
              ),
              child: Center(child: Text("You don't connect to Internet", style: TextStyle(color: Colors.red[600]),)),
            ),
          );
        },
      ),
    );
  }
}