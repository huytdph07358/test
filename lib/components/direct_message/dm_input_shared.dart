import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/E2EE/e2ee.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/isar/message_conversation/service.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../generated/l10n.dart';

class DMInputShared extends StatefulWidget {
  // type: kieu nhap ma otp
  //  co 2 gia tri "reset" hoac "sync"
  final String type;

  DMInputShared({
    Key? key,
    required this.type
  }) : super(key: key);

  @override
  _DMInputShared createState() => _DMInputShared();
}

class _DMInputShared extends State<DMInputShared> {
  var code;
  var sec;
  int totalMessages = 0;
  int totalMessagesRecived = 0;
  String status = "waitting";
  List conversation = [];
  List<Map> conversationMessages = [];
  var channel;
  String deviceIdSync = "";

  List input = [];
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState(){
    super.initState();
    channel = Provider.of<Auth>(context, listen: false).channel;

    input = input.map((e) {
      int index = input.indexWhere((ele) => ele == e);
      e["focusNode"] = new FocusNode(onKey: (node, RawKeyEvent keyEvent) {
        final eventKey = keyEvent.runtimeType.toString();
        if (keyEvent.isKeyPressed(LogicalKeyboardKey.backspace) && eventKey == 'RawKeyDownEvent') {
          e["controller"].clear();
          if (index > 0) FocusScope.of(context).requestFocus(input[index - 1]["focusNode"]);
        }
        return KeyEventResult.ignored;
      });
      return e;
    }).toList();

    channel.on("result_sync_conversation", (data, _r, _j) async{
      try {
        var dataServer  = await Utils.decryptServer(data["data"]);
        if (dataServer["success"]){
          var dataEn =  dataServer["data"];
          if (dataEn["success"]){
            LazyBox box = Hive.lazyBox('pairKey');
            Box direct =  Hive.box("direct");
            var identityKey =  await box.get("identityKey");
            var iKey  = dataEn["public_key_decrypt"];
            deviceIdSync = dataEn["device_id_sync"];
            var masterKey = await X25519().calculateSharedSecret(KeyP.fromBase64(identityKey["privKey"], false), KeyP.fromBase64(iKey, true));
            bool hasConfirm = dataEn["has_confirm"] == null ? false : dataEn["has_confirm"];
            if (hasConfirm){
              String dataInsertEncrypted = dataEn["data_insert"];
              String dataInsertDecrypted = Utils.decrypt(dataInsertEncrypted, masterKey.toBase64());
              Map dataInsertJson = jsonDecode(dataInsertDecrypted);
              await box.putAll(dataInsertJson["keys"]);
              List dataConv = dataInsertJson["convs"];
              List dConv = [];
              for(int i =0; i< dataConv.length; i++){
                DirectModel dm  = DirectModel(
                  dataConv[i]["id"],
                  [],
                  "",
                  false,
                  0,
                  dataConv[i]["snippet"] ?? {},
                  dataConv[i]["is_hide"] ?? false,
                  dataConv[i]["updateByMessageTime"] ?? 0,
                  dataConv[i]["userRead"] ?? {},
                  "",
                  null,
                  DateTime.now().toString()
                );
                dConv = dConv + [dm];
              }
              await direct.clear();
              await direct.putAll(
                Map.fromIterable(dConv, key: (v) => v.id, value: (v) => v)
              );

              pushEndSync({
                "data": await Utils.encryptServer({"random_string": dataInsertJson["random_string"]})
              });

            } else  {
              // flow nay se bi bo trong tuong lai
              String messageDeStr =  Utils.decrypt(dataEn["data"], masterKey.toBase64());
              Map dataToSave  = jsonDecode(messageDeStr);
              await box.putAll(dataToSave);
              if(dataEn["dataConv"] != null) {
                var messageDeStrConv =  Utils.decrypt(dataEn["dataConv"], masterKey.toBase64());
                var dataToSaveConv  = jsonDecode(messageDeStrConv);
                var dataConv = dataToSaveConv["conv"];
                List dConv = [];
                for(int i =0; i< dataConv.length; i++){
                  DirectModel dm  = DirectModel(
                    dataConv[i]["id"],
                    [],
                    "",
                    false,
                    0,
                    dataConv[i]["snippet"] ?? {},
                    dataConv[i]["is_hide"] ?? false,
                    dataConv[i]["updateByMessageTime"] ?? 0,
                    dataConv[i]["userRead"] ?? {},
                    "",
                    null,
                    DateTime.now().toString()
                  );
                  dConv = dConv + [dm];
                }
                await direct.clear();
                await direct.putAll(
                  Map.fromIterable(dConv, key: (v) => v.id, value: (v) => v)
                );
              }
              MessageConversationServices.statusSyncStatic = StatusSync(0, "Waitting data", dataEn["device_id_sync"]);
              MessageConversationServices.statusSyncController.add(MessageConversationServices.statusSyncStatic);
              final token = Provider.of<Auth>(context, listen: false).token;
              final userId = Provider.of<Auth>(context, listen: false).userId;
              await Provider.of<DirectMessage>(context, listen: false).getDataDirectMessage(token, userId);  
              if (this.mounted) {
                setState(() {
                  status = "done";
                });
              }
            }
          }  else {
            if (this.mounted)
              setState(() {
                status = "error";
                code = "";
              });
          } 
        } else {
          if (this.mounted)
            setState(() {
              status = "error";
              code = "";
            });
        }
     } catch (e, t) {
       print("_____________________________$e $t");
     }
    });

    channel.on("sync_status", (data, _, __) async {
      if (data["device_id_request"] == await Utils.getDeviceId() && data["device_id_sync"] == deviceIdSync) {
        if (data["success"]) {
          final auth = Provider.of<Auth>(context, listen: false);
          await Provider.of<DirectMessage>(context, listen: false).getDataDirectMessage(auth.token, auth.userId); 
          if (this.mounted) {
            setState(() {
              status = "done";
            });
          }
        }
        else {
          if (this.mounted) {
            setState(() {
              status = "fail";
            });
          }
        }
      }
    });

  }

  pushEndSync(Map payload) {
    channel.push(event: "push_end_sync", payload: payload);
  }
   

  handleResutData(){
    Navigator.of(context, rootNavigator: true).pop("Discard");
  }

  sendOTPResetDeviceKey(String otp, String token) async {
  try {
      final url = "${Utils.apiUrl}users/vertify_otp_device?token=$token&device_id=${await Utils.getDeviceId()}";
      var res = await Dio().post(url, data: {
      "data": await Utils.encryptServer({
        "otp_code": otp,
      })
    });

    if (res.data["success"]){
      setState(() {
        status = "done";
      });
      Provider.of<DirectMessage>(context, listen: false).getDataDirectMessage(token, Provider.of<Auth>(context, listen: false).userId);
    } else {
      setState(() {
        status = "error";
      });
    }
    } catch (e) {
      setState(() {
        status = "error";
      });
      print("____$e");
 
    }
  }

  handleSubmitConfirm(code)async {
    final channel = Provider.of<Auth>(context, listen: false).channel;
    
    LazyBox box  = Hive.lazyBox('pairKey');
    Map payload  = {"code": code, "device_id": await box.get("deviceId")};

    channel.push(event: "confirm_code", payload: {
      "device_id": await box.get("deviceId"),
      "data": await Utils.encryptServer(payload)
    });
  }

  getBackgroundColor(){
    if (status == "success") return Color(0xFF73d13d);
    if (status == "error") return Color(0xFFff4d4f); 
    return Color(0xFFffffff);
  }

  getTextColor(){
    if (status == "success") return Color(0xFFf6ffed);
    if (status == "error") return Color(0xFFfff1f0);
    return Color(0xFFffffff);
  }

  @override
  void dispose(){
    channel.off("result_sync_conversation");
    super.dispose();
  }

  renderStatus(){
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    switch (status) {
      case "waiting":
        if (widget.type != "reset") return Container();
        return Container(
          margin: EdgeInsets.only(top: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("If you don't receive a code /", style: TextStyle(
                color: isDark ? Color(0xffEDEDED) : Color(0xff5e5e5e),
                fontSize: 15,
                height: 23/14,
              )),
              Text(" Resend", style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xffD48806),
                fontSize: 15,
                height: 23/14,
              ))
            ],
          )
        );
        case "error": 
          return Container(
          margin: EdgeInsets.only(top: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(S.current.wrongCodePleaseTryAgain, style: TextStyle(
                color: Color(0xffFF7875),
                fontSize: 15,
                height: 23/14,
              )),
            ],
          )
        );

        case "success":
          if (widget.type == "reset") return Container();
          return Container(
            margin: EdgeInsets.only(top: 32),
            child: Column(
              children: [
                Container(
                  color: Color(0xff27AE60),
                  width: 240,
                  margin: EdgeInsets.symmetric( vertical: 9),
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.checkmark_circle,color: Color(0xffFFFFFF), size: 15),
                      Text("  ${S.current.success}", style: TextStyle(color: Color(0xffFFFFFF)))
                    ],
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${S.current.gettingData} ",  style: TextStyle(color: Color(0xffA6A6A6),)),
                      Text('$totalMessagesRecived / $totalMessages',  style: TextStyle(color: Color(0xffA6A6A6), fontWeight: FontWeight.bold)),
                      Text(" ${S.current.messages}",  style: TextStyle(color: Color(0xffA6A6A6),),)
                    ]
                  )
                ),
              ],
            ),
          );
        case "done":
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.only(top: 250),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xff27AE60),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    // width: 240,
                    margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(S.current.done, style: TextStyle(fontSize: 14, height:22/14, color: Color(0xFFFFFFFF)))
                      ],
                    )
                  ),
                ],
              ),
            ),
          );
          
      default: return Container();
    }
  }

  get3CharPhoneNumber(){
    try {
      final user = Provider.of<User>(context);
      String email = user.currentUser["email"] ?? "";
      if (user.currentUser["is_verified_email"]) return email.replaceFirstMapped(RegExp(r'[^@]{1,}@'), (map){
        return (map.group(0) ?? "").split("").map((e) => "*").join();
      });
      String phoneNumber = user.currentUser["phone_number"] ?? "";
      return "*******" + phoneNumber.substring(phoneNumber.length - 3, phoneNumber.length);
    } catch (e) {
      return "";
    }

  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final isLogoutDevice = Provider.of<DirectMessage>(context, listen: true).isLogoutDevice;
    if (isLogoutDevice) {
      Navigator.pop(context);
    }

    return Container(
      // height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF3D3D3D) : Color(0xffffffff),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))
      ),
      child: Column(
        // header
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(width: 1, color: isDark ? Color(0xFF5E5E5E) : Color(0xFFc9c9c9))
              )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {Navigator.pop(context);},
                  child: Container(
                    padding: EdgeInsets.all(18),
                    child: Icon(PhosphorIcons.arrowLeft, size: 16)
                  ),
                ),
                Container(
                  child: Text(
                    widget.type == "reset" ? S.current.resetDeviceKey :S.current.syncData,
                    style: TextStyle(
                      color: isDark ? Color(0xFFEDEDED) : Color(0xFF3d3d3d),
                      height: 22/14,
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    )
                  )
                ),
                Container(
                  width: 50,
                )
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.only(top: 68),
            child: Text(
              S.current.enterYourCode,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: !isDark ? Color(0xFF3d3d3d) : Color(0xFFEDEDED),
                height: 32/24,
                fontSize: 25,
                fontWeight: FontWeight.w500
              )
            ),
          ),

          widget.type == "reset" ? Container(
            child: Column(
              children: [
                Text(S.current.anMessageHasBeenSend, style: TextStyle(
                  color: isDark ? Color(0xffEDEDED) : Color(0xff5e5e5e),
                  fontSize: 15,
                  height: 23/14,
                )),
                Text(get3CharPhoneNumber(), style: TextStyle(
                  color: isDark ? Color(0xffffffff) : Color(0xff2e2e2e),
                  fontSize: 15,
                  height: 23/14,
                )),
                Text(S.current.toResetYourDevice, style: TextStyle(
                  color: isDark ? Color(0xffEDEDED) : Color(0xff5e5e5e),
                  fontSize: 15,
                  height: 23/14,
                ))
              ],
            )
          ) : Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(S.current.enterYourCodeOnOtherDevices, style: TextStyle(
              color: Color(0xffA6A6A6),
              fontSize: 15,
              height: 23/14,
            ))
            
          ),

          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(height: MediaQuery.of(context).size.height*1/20),
                Container(
                  margin: EdgeInsets.only(top: 32),
                  child: Container(
                    width: 260,
                    child: PinCodeTextField(
                        appContext: context,
                        pastedTextStyle: TextStyle(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                        length: 4,
                        autoFocus: true,
  
                        blinkWhenObscuring: true,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          activeColor: isDark ? Color(0xFF2E2E2E) : Color(0xFFA6A6A6),
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          borderWidth: 0,
                          fieldHeight: 56,
                          fieldWidth: 56,
                          activeFillColor: isDark ? Color(0xFF2E2E2E) : Color(0xFFf3f3f3),
                          inactiveColor: isDark ? Color(0xFF2E2E2E) : Color(0xFFf3f3f3),
                          inactiveFillColor: isDark ? Color(0xFF2E2E2E) : Color(0xFFf3f3f3),
                          selectedFillColor: isDark ? Color(0xFF2E2E2E) : Color(0xFFf3f3f3),
                        ),
                        cursorColor: Colors.black,
                        animationDuration: Duration(milliseconds: 300),
                        enableActiveFill: true,
                        controller: textEditingController,
                        keyboardType: TextInputType.number,
                        boxShadows: [
                          BoxShadow(
                            offset: Offset(0, 1),
                            color: Colors.black12,
                            blurRadius: 1,
                          )
                        ],
                        onCompleted: (otp) {
                          if (widget.type == "reset") return sendOTPResetDeviceKey(otp, auth.token);
                          return handleSubmitConfirm(otp);
                        },
                        beforeTextPaste: (text) {
                          //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                          //but you can show anything you want here, like your pop up saying wrong paste format or etc
                          return false;
                        }, 
                        onChanged: (String value) {  },
                      ),
                  )),
              ],
            )
          ),
          renderStatus()
        ],
      ),
    );
  }
}