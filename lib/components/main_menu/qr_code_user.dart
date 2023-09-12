import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/main_menu/nearby_scan.dart';
import 'package:workcake/qr_code/qr_service.dart';
import '../../models/auth_model.dart';

class QRCodeUser extends StatefulWidget{
  QRCodeUser({
    Key? key,
  }): super(key: key);
  _QRCodeUser createState() => _QRCodeUser();
}

class _QRCodeUser extends State<QRCodeUser>{
  @override
  Widget build(BuildContext context) {
    // final currentUser = Provider.of<User>(context, listen: false).currentUser;
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Color(0xFFffffff),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(height:  50,),
          // PrettyQr(
          //   // image: NetworkImage(currentUser["avatar_url"], scale: 2),
          //   typeNumber: 3,
          //   size: 160,
          //   data: currentUser["id"],
          //   // errorCorrectLevel: QrErrorCorrectLevel.M,
          //   roundEdges: true
          // ),
          Container(height:  50,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                // highlightColor: Color(0xFF1890ff),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF1890ff))
                ),
                onPressed: (){
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => NearbyScan())
                  );
                },
                child: Text("Nearby scan", style: TextStyle(color: Color(0xFFffffff)),)
              ),
               TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFFbfbfbf))
                ),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ScanQr()));
                },
                child: Text("Scan QR code", style: TextStyle(color: Color(0xFFffffff)),)
              )
            ],
          )
        ],
      ),
    );
  }
}

class ScanQr extends StatefulWidget{
  ScanQr({
    Key? key,
  }): super(key: key);
  _ScanQr createState() => _ScanQr();
}

class _ScanQr extends State<ScanQr>{
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var result;
  var controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller, context) {
    this.controller = controller;
    if (Platform.isAndroid) {
      controller.resumeCamera();
    }
    controller.scannedDataStream.listen((scanData) {
      try {
        if ((result == null)  || (result.code != scanData.code)){
          result = scanData;
          List<String> pat = (result.code as String).split(",");
          Utils.loginQrContext = context;
          QRService.getInforDeviceFromQR(pat[0], pat[1], Provider.of<Auth>(context, listen: false).token, context);
        }

      } catch (e) {
        print("______$e");
      }
      
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              // flex: 5,
              // To ensure the Scanner view is properly sizes after rotation
              // we need to listen for Flutter SizeChanged notification and update controller
              child: NotificationListener<SizeChangedLayoutNotification>(
                onNotification: (notification) {
                  // Future.microtask(() => QRViewController?.updateDimensions());
                  return false;
                },
                child: SizeChangedLayoutNotifier(
                  key: const Key('qr-size-notifier'),
                  child: QRView(
                    overlay: QrScannerOverlayShape(),
                    key: qrKey,
                    onQRViewCreated:(controller) =>_onQRViewCreated(controller, context),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                alignment: Alignment.centerLeft,
                color: Color(0xFF262626).withOpacity(0.5),
                height: 70, width: double.infinity,
                child: GestureDetector(
                  onTap:() => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Icon(PhosphorIcons.arrowLeft, color: Color(0xFFffffff)))),
              ),
            ),
          ]
        ),
      )
    );
  }

}
