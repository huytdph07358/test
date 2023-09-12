import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/E2EE/e2ee.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';

import '../../generated/l10n.dart';

class DMConfirmShared extends StatefulWidget {
  final deviceId;
  final data;
  final String deviceRequestPublicKey;

  DMConfirmShared({
    Key? key,
    @required this.deviceId,
    @required this.data,
    required this.deviceRequestPublicKey
  }) : super(key: key,);

  @override
  DMConfirmSharedState createState() => DMConfirmSharedState();
}

class DMConfirmSharedState extends State<DMConfirmShared>  {

  var code;
  bool isCorrectLocalAuth = false;
  int currentStep = 0;
  String status = "waitting";
  var timer;
  int t =0;
  var channel;
  // flow dong bo tin nhan
  //  mac dinh qua socket
  bool hasConfirm = false;
  String sharedKey = "";
  

  @override
  void initState() {
    super.initState();
    channel  =  Provider.of<Auth>(context, listen: false).channel;
    hasConfirm = widget.data["has_confirm"] ?? false;
    channel.on("handle_confirm_conversation_sync", (data, _r, _j)async {
      if (code == null) return;
      if (this.mounted)
        setState(() {
          status = "handle";
        });
      await Future.delayed(Duration(seconds: 1));
      var resultRecived;
      for (var i = 0; i< data["data"].length ; i++ ){
        var t =  await Utils.decryptServer(data["data"][i]);
        if (t["success"]){
          resultRecived = t["data"];
          break;
        }
      }
      LazyBox box = Hive.lazyBox('pairkey');
      Map identityKey =  await box.get("identityKey");
      if (Utils.checkedTypeEmpty(resultRecived) && resultRecived["code"] == code && resultRecived["device_id"] == widget.deviceId){
        handleCorrectCode();
      }
      else {
        Map jsonDataResult  =  {
          "data": "", 
          "success": false, 
          "totalConversation": 0,
          "public_key_decrypt": identityKey["pubKey"],
          "device_id": resultRecived["device_id"],
          "device_id_sync": await Utils.getDeviceId()
        };

        // ma hoa tin nhan khi gui len server
        var dataEn  = await Utils.encryptServer(jsonDataResult);
        // Utils.encrypt(str, masterKey)
        channel.push(event: "result_sync_conversation", payload: {"data": dataEn, "device_id_encrypt": await box.get("deviceId")});
        if (this.mounted) {
          String subErrorCode = "";
          if (resultRecived["device_id"] != widget.deviceId) subErrorCode= "50001";
          MessageConversationServices.statusSyncStatic = StatusSync(500, "Verification has failed${subErrorCode != "" ? "($subErrorCode)" : ""}", resultRecived["device_id"]);
          MessageConversationServices.statusSyncController.add(MessageConversationServices.statusSyncStatic);
          setState(() {
            status = "fail";
            t = 0;
            code  = Utils.getRandomNumber(4);
          });
        }  
      }
    });

    channel.on("sync_status", (data, _, __) async {
      try {
        if (!this.mounted) return;
        if (data["device_id_request"] == widget.deviceId && data["device_id_sync"] == await Utils.getDeviceId()) {
          if (data["success"]) {
            MessageConversationServices.syncViaFile(sharedKey, widget.deviceId );
            setState(() {
              status = "done";
            });
          }
          else {
            this.setState(() {
              status = "fail";
            });
          }
        }        
      } catch (e, t) {
        print("__$e $t");
      }

    });
  }

  handleCorrectCode() async {
    try {
      LazyBox box = Hive.lazyBox('pairkey');
      Map identityKey =  await box.get("identityKey");
      sharedKey = (await X25519().calculateSharedSecret(KeyP.fromBase64(identityKey["privKey"], false), KeyP.fromBase64(widget.deviceRequestPublicKey, true))).toBase64();
      if (this.mounted)
        setState(() {
          currentStep = 1;
        });
      Box direct = await  Hive.openBox('direct');
      List keys  =  box.keys.toList();
      var result = {};
      for (var i = 0; i< keys.length; i++){
        if (keys[i] == "identityKey" || keys[i] == "deviceId") continue;
        result[keys[i]] = await box.get(keys[i]);
      }
      // ma hoa de may nhan dcgiai
      var dataDe = Utils.encrypt(jsonEncode(result), sharedKey);
      var resultConv = [];
      for(int i =0; i< direct.keys.length; i++ ){
        resultConv += [{
          "id": direct.values.toList()[i].id,
          "snippet": direct.values.toList()[i].snippet,
          "updateByMessageTime": direct.values.toList()[i].updateByMessageTime,
          "userRead": direct.values.toList()[i].userRead
        }];

      }
      var dataConv = Utils.encrypt(jsonEncode({"conv": resultConv}), sharedKey);
      String randomString =  Utils.getRandomString(10);
      Map jsonDataResult  =  {
        "data_insert": Utils.encrypt(
          jsonEncode(
            {
              "convs": resultConv,
              "keys": result,
              "random_string": randomString
            }
          ), sharedKey
        ),
        //  3 truong nay se bi bo
        "data": dataDe,
        "dataConv": dataConv,
        "totalMessages": 0,
        //
        "success": true,
        // server luu lai ramdomString
        "has_confirm": hasConfirm,
        "random_string": randomString,
        "public_key_decrypt": identityKey["pubKey"],
        "device_id_sync": await Utils.getDeviceId(),
        "device_id_request": widget.deviceId
      };

      // ma hoa tin nhan khi gui len server
      var dataEn  = await Utils.encryptServer(jsonDataResult);

      // Utils.encrypt(str, masterKey)
      channel.push(event: "result_sync_conversation", payload: {"data": dataEn, "device_id_encrypt": await box.get("deviceId")});
      if (this.mounted && !isCorrectLocalAuth)
        setState(() {
          timer.cancel();
        });
      if (!hasConfirm) {
        MessageConversationServices.syncViaFile(sharedKey, widget.deviceId );
        if (this.mounted)
          setState(() {
            status = "done";
          });
        await Future.delayed(Duration(seconds: 2));
        Navigator.pop(context);
      }
      else return;      
    } catch (e, t) {
      print("_____$e $t");
      
    }
  }

  @override
  void dispose(){
    channel.off("handle_confirm_conversation_sync");
    super.dispose();
  }

  Future getFromHive(idConversation,int page,int size)async {
    LazyBox thread =  await Hive.openLazyBox("thread_$idConversation");
    List keys = thread.keys.toList();
    List result  = [];
    for (var i = size * page ; i < min(keys.length, size * (page +1)); i++){
      if (keys[i] != null)
        result +=[await thread.get(keys[i])];
    }
    return result;
  }


  getNameOfConverastion(String convId, List sources){
    var index  =  sources.indexWhere((element) => element.id  == convId);
    if (index == -1) return "";
    return sources[index].name ?? sources[index].user.reduce((value, element) => "$value ${element["full_name"]}");
  }

  @override
  didChangeDependencies(){
    super.didChangeDependencies();    
  }

  handleGenCode() async {
    if ((await LocalAuthentication().getAvailableBiometrics()).isNotEmpty) {
      if (await Utils.localAuth()) {
        setState(() {
          isCorrectLocalAuth = true;
        });
        MessageConversationServices.statusSyncStatic = StatusSync(10, "Waiting for a response from the requesting device", widget.deviceId);
        MessageConversationServices.statusSyncController.add(StatusSync(10, "Waiting for a response from the requesting device", widget.deviceId));
        await Future.delayed(Duration(milliseconds: 300));
        handleCorrectCode();
        return;
      }
    }
    
    if (this.mounted){
      setState(() {
        code  = Utils.getRandomNumber(4);
      });
      MessageConversationServices.statusSyncStatic = StatusSync(0, "Waiting for verification", widget.deviceId);
      timer = Timer.periodic(new Duration(seconds: 1), (timer) { 
        if (this.mounted) 
        setState(() {
          t= t+1;
          if (t % 30 == 0) {
            code  = Utils.getRandomNumber(4);
            status = "waitting";
          }
        });
      });
    }
  }

  logoutDevice(String token)async{
    if (!await Utils.localAuth()) return;
    String url  = "${Utils.apiUrl}users/logout_device?token=$token";
    LazyBox box = Hive.lazyBox('pairkey');
    try{
      var res = await Dio().post(url, data: {
        "current_device": await box.get("deviceId"),
        "data": await Utils.encryptServer({"device_id": widget.deviceId})
      });
      Navigator.pop(context);
      if(res.data["success"] == false) throw HttpException(res.data["message"]);
    }catch(e){
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final token  =  Provider.of<Auth>(context, listen: false).token;
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;

    getStatus() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(right: 4, top: 10),
            child: Icon(
              status == "done"
                ? CupertinoIcons.checkmark_circle
                : status == "fail" ? CupertinoIcons.xmark_circle : CupertinoIcons.clock,
              color: status == "done" ? Color(0xff27AE60) : status == "fail" ? Colors.red : isDark ? Colors.white70 : Color(0xFF3D3D3D),
              size: 20
            )
          ),
          StreamBuilder(
            stream: MessageConversationServices.statusSync,
            initialData: MessageConversationServices.statusSyncStatic,
            builder: (BuildContext c, AsyncSnapshot s){
              StatusSync d = s.data ?? MessageConversationServices.statusSyncStatic;
              return Container(
                padding: EdgeInsets.only(top: 10),
                constraints: BoxConstraints(
                  maxWidth: 300,
                  minWidth: 0.0
                ),
                child: Text(
                  d.status,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: status == "done" ? Color(0xff27AE60) : status == "fail" ? Colors.red : isDark ? Colors.white70 : Color(0xFF3D3D3D)
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }
          )
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF3D3D3D) : Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        )
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Color(0xFF5E5E5E) : Color(0xFFC9C9C9),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Icon(PhosphorIcons.arrowLeft, color: isDark ? Colors.white : Color(0xFF3D3D3D),size: 20,)),
                ),
                Text(S.current.syncData,
                style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500, color: isDark ? Colors.white : Color(0xFF3D3D3D),),),
                Container(
                  width: 30,
                )
              ],
            )),
          Container(
            width: MediaQuery.of(context).size.width * 0.8, 
            height: MediaQuery.of(context).size.height * 0.2,
            child: Image.asset(
              isDark ? "assets/images/sync_data_dark.png" : "assets/images/sync_data_light.png",
              width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.height * 0.2,
            ),
          ),
          Utils.checkedTypeEmpty(code) || isCorrectLocalAuth
            ? Container(
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                children: [
                  isCorrectLocalAuth ? Container() : Text(
                    code ?? "",
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                      color: isDark ? Colors.white70 : Color(0xFF3D3D3D),
                    )
                  ),
                   isCorrectLocalAuth ? Container() : Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                      "${S.current.autoRefeshIn} ${(30 - t % 30)} ${S.current.second}(s)",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Color(0xFF3D3D3D),
                        fontWeight: FontWeight.w400,
                        fontSize: 12
                      )
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 16),
                    child: getStatus(),
                  )
                ],
              ),
            )
          : Container(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 32, right: 32),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "${S.current.aNewDevice} ",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Color(0xFF3D3D3D),
                        fontSize: 14.5,
                        height: 1.5,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: "(${widget.data["device_name"]}, ${widget.data["device_ip"]}, Hanoi)",
                          style: TextStyle(
                            fontWeight: FontWeight.w700
                          )
                        ),
                        TextSpan(
                          text: " ${S.current.justLoggeInAndRequested}",
                        ),
                      ]
                    )
                  )
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "${S.current.ifYouDontMakeThatRequest},",
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Color(0xFF3D3D3D),
                      fontSize: 14.5,
                      height: 2,
                    )
                  )
                ),
                Container(
                  padding: EdgeInsets.only(left: 12, right: 12),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "${S.current.pleaseChoose} ",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Color(0xFF3D3D3D),
                        fontSize: 14.5,
                        height: 2,
                      ),
                      children: [
                        TextSpan(
                          text: S.current.logoutThisDevice,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700
                          )
                        )
                      ]
                    )
                  ),
                ),
                Container(
                  child: Text(
                    S.current.allowToSyncFromThisDevice,
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w700,
                      height: 4,
                      color: isDark ? Colors.white70 : Color(0xFF3D3D3D),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 32,
                        child: TextButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xFF19DFCB))),
                          child: Text(S.current.accept, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400)),
                          onPressed: () {
                            handleGenCode();
                          },
                        
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 32,
                        child: TextButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color(0xFFEB5757))),
                          child: Text(
                            S.current.logoutThisDevice,
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontWeight: FontWeight.w400
                            ),
                          ),
                          // minWidth: 162,
                          onPressed:  () {
                            logoutDevice(token);
                          },
                        )
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 32,
                        child: TextButton(
                          child: Text(S.current.doNotSync, style: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.w400)),
                          onPressed:  (){
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey[400])),
                        )
                      ),
                    ],
                  ),
                )
              ],
            )
          )
        ]
      ),
    );
  }
}