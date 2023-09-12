import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/E2EE/e2ee.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/models/device_provider.dart';
import '../common/utils.dart';
import '../generated/l10n.dart';
import '../models/auth_model.dart';
import 'device_socket.dart';

class ListDevices extends StatefulWidget {
  const ListDevices({ Key? key }) : super(key: key);

  @override
  State<ListDevices> createState() => _ListDevicesState();
}

class _ListDevicesState extends State<ListDevices> {

  @override
  void initState(){
    super.initState();
    Timer.run((){
      DeviceSocket.instance.channel!.push(event: "get_list_device");
    });
  }

  logoutDevice(String token, String targetDeviceId)async{
    if (!await Utils.localAuth()) return;
    String url  = "${Utils.apiUrl}users/logout_device?token=$token";
    LazyBox box = Hive.lazyBox('pairkey');
    try{
      var res = await Dio().post(url, data: {
        "current_device": await box.get("deviceId"),
        "data": await Utils.encryptServer({"device_id": targetDeviceId})
      });
      if(res.data["success"]){
        DeviceSocket.instance.channel!.push(event: "get_list_device");
      } 
    } catch(e){
      // sl.get<Auth>().showErrorDialog(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    List<Device> devices = Provider.of<DeviceProvider>(context, listen: true).devices;
    Device? currentDevice;
    try {
      currentDevice = devices.firstWhere((element) => element.deviceId == Utils.deviceId);
    } catch (e) {
    }
    return Scaffold(
      backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 62,
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff2E2E2E) : Colors.white,
                  
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: isDark ? null : Border(bottom: BorderSide(color: Color(0xffDBDBDB))) ,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Icon(PhosphorIcons.arrowLeft, size: 20, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            // await Navigator.push(context, MaterialPageRoute(builder: (context) => DMInfo(id: widget.id)));
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  S.current.devices,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle( fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                          ),
                        ),
                      )),
                      InkWell(
                        onTap: () async {
                            
                          },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Icon(PhosphorIcons.dotsThreeVerticalBold, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E))
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: (devices).map<Widget>((device){
                      return Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical:4),
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF262626) : Color(0xffA6A6A6),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(device.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                                  Row(
                                    children: [
                                      Text(device.platform + "  ", style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 10)),
                                      Text((device.deviceId).substring(0, 10) + "...", style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 10)),
                                    ],
                                  )
                                ],
                              ),
                            ),

                            Utils.deviceId == device.deviceId || currentDevice == null || !currentDevice.readyToUse || !device.readyToUse ? Container() : StreamBuilder(
                              stream: MessageConversationServices.statusSync,
                              initialData: MessageConversationServices.statusSyncStatic,
                              builder: (context, snapshot){
                                StatusSync status = (snapshot.data as StatusSync?) ?? MessageConversationServices.statusSyncStatic;
                                if (status.targetDeviceId != device.deviceId){
                                  return InkWell(
                                    onTap: () async {
                                      bool didAuthenticate = await Utils.localAuth();
                                      if (!didAuthenticate) return;
                                      LazyBox box  = Hive.lazyBox('pairKey');
                                      var idKey =  await box.get("identityKey");
                                      String sharedKey = (await X25519().calculateSharedSecret(KeyP.fromBase64(idKey["privKey"], false), KeyP.fromBase64(device.pubIdentityKey, true))).toBase64();
                                      DeviceSocket.instance.setPairDeviceId(device.deviceId, await Utils.getDeviceId(), sharedKey);
                                      MessageConversationServices.syncViaFile(sharedKey, device.deviceId);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 4, horizontal:8),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1890ff),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      margin: EdgeInsets.only(left: 8),
                                      child: Text("Sync")
                                    ),
                                  );
                                } 
                                return Expanded(
                                  child: Container(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(status.status, style: TextStyle(overflow: TextOverflow.ellipsis))
                                    )
                                  )
                                );
                              }
                            ),
                            Utils.deviceId == device.deviceId || currentDevice == null || !currentDevice.readyToUse  ? Container() : InkWell(
                              onTap: (){
                                logoutDevice(
                                  Provider.of<Auth>(context, listen: false).token,
                                  device.deviceId
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 4, horizontal:8),
                                decoration: BoxDecoration(
                                  color: Color(0xFFf5222d),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                margin: EdgeInsets.only(left: 8),
                                child: Text("Logout"),
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList()
                    ,
                  ),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}