import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/desktop/components/keyboard_button.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/home_screen/reset_password.dart';
import 'package:workcake/screens/home_screen/submit_button.dart';

class InputValidator extends StatefulWidget {
  final dataUser;
  final bool isResetPassword;
  InputValidator({Key? key, this.dataUser, this.isResetPassword = false}) : super(key: key);

  @override
  _InputValidatorState createState() => _InputValidatorState();
}

class _InputValidatorState extends State<InputValidator> {
  var code;
  var sec;
  int totalMessages = 0;
  int totalMessagesRecived = 0;
  String status = "waitting";
  List conversation = [];
  List<Map> conversationMessages = [];
  int indexFocus = 0;
  final _input1 = new TextEditingController();
  final _input2 = new TextEditingController();
  final _input3 = new TextEditingController();
  final _input4 = new TextEditingController();
  var channel;
  bool finishKey  =  false;
  bool finishMessage =  false;
  var _focusNode1;
  var _focusNode2;
  var _focusNode3;
  var _focusNode4;
  String errorMessage = '';

  List input = [];

  @override
  void initState() { 
    super.initState();
    channel = Provider.of<Auth>(context, listen: false).channel;

    input = [
      {"controller": _input1, "focusNode": _focusNode1},
      {"controller": _input2, "focusNode": _focusNode2},
      {"controller": _input3, "focusNode": _focusNode3},
      {"controller": _input4, "focusNode": _focusNode4},
    ];

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

    input[0]["focusNode"].requestFocus();
  }

  onChangedInput(value) {
    if (value == "Cancel") {
      _input1.clear();
      _input2.clear();
      _input3.clear();
      _input4.clear();
      Navigator.pop(context);
      return ;
    } else if (value == "del") {
      if (Utils.checkedTypeEmpty(_input4.text.trim())) indexFocus = 3;
      else if (Utils.checkedTypeEmpty(_input3.text.trim())) indexFocus = 2;
      else if (Utils.checkedTypeEmpty(_input2.text.trim())) indexFocus = 1;
      else if (Utils.checkedTypeEmpty(_input1.text.trim())) indexFocus = 0;
      if (Utils.checkedTypeEmpty(input[indexFocus]["controller"].text.trim())) {
        input[indexFocus]["controller"].text = "";
        FocusScope.of(context).requestFocus(input[indexFocus]["focusNode"]);
      }
      return ;
    }
    if (!Utils.checkedTypeEmpty(_input1.text.trim())) {
      FocusScope.of(context).requestFocus(_focusNode1);
      _input1.text = value.toString();
      indexFocus += 1;
    } else if (indexFocus > 0 && indexFocus <= 4 && Utils.checkedTypeEmpty(input[indexFocus - 1]["controller"].text.trim())
      && !Utils.checkedTypeEmpty(input[indexFocus]["controller"].text.trim())
    ) {
      FocusScope.of(context).requestFocus(input[indexFocus]["focusNode"]);
      input[indexFocus]["controller"].text = value.toString();
      indexFocus += 1;
      if (indexFocus == 4) {
        this.setState(() {
          code = _input1.text + _input2.text + _input3.text + _input4.text;
        });
        handleSubmitConfirm();
      }
    }
  }

  handleSubmitConfirm() async {
    if(widget.isResetPassword) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPassword(dataUser: {...widget.dataUser, "otp": code},)));
    } else {
      final url = "${Utils.apiUrl}users/verify_otp";
      var res = await Dio().post(url, data: {
        "email": widget.dataUser["email"],
        "phone_number": widget.dataUser["phone_number"],
        "otp": code,
        "otp_id": widget.dataUser["otp_id"],
        "user_id": widget.dataUser["id"] ?? widget.dataUser["user_id"],
        "account_id": widget.dataUser["account_id"]
      });

      if(res.data["success"]) {
        await Provider.of<Auth>(context, listen: false).loginUserPassword(widget.dataUser["email"], widget.dataUser["password"], context);
        Navigator.pushNamed(context, 'dashboard-screen');
      } else {
        setState(() {
          errorMessage = res.data["message"];
        });
      }
        return;
      }
  }
  
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.076),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.arrow_left, color: Color(0xff1F2933),),
                          SizedBox(width: 8.0,),
                          Text("Back", style: TextStyle(color: Color(0xff1F2933)),)
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.0528,),
                    Center(
                      child: Text("Enter your code", style: TextStyle(color: Color(0xff1F2933), fontSize: Platform.isIOS ? 24 : 20, fontWeight: FontWeight.w500),),
                    ),
                    SizedBox(height: 16,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Center(
                        child: Text(
                          "You'll receive a 4 digit code to verify",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xff616E7C), fontSize: Platform.isIOS ? 14 : 12)   
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.022,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: input.map<Widget>((e) {
                        return Container(
                          margin: EdgeInsets.all(16),
                          width: 48,
                          height: 48,
                          color: Color(0xffF5F7FA),
                          child: TextFormField(
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Color(0xff1F2933)),
                            controller: e["controller"],
                            focusNode: e["focusNode"],
                            decoration: new InputDecoration(
                              contentPadding: EdgeInsets.only(top: 4, left: 6),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: BorderSide(color: Color(0xffCBD2D9))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: BorderSide(color: Color(0xffCBD2D9))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(2), borderSide: BorderSide(color: Color(0xff2A5298))),
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none
                            ),
                            readOnly: true,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: height * 0.012,),
                    KeyBoardButton(
                      onChanged: (str) {
                        onChangedInput(str);
                      },
                    ),
                    SizedBox(height: height * 0.032,),
                    SubmitButton(onTap: handleSubmitConfirm, text: "Verify"),
                    SizedBox(height: height * 0.03,),
                    errorMessage.trim() != '' ? Container(
                      // height: 36,
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      decoration: BoxDecoration(
                        color: Color(0xffFFF1F0),
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Text("$errorMessage", style: TextStyle(color: Color(0xffEB5757), fontWeight: FontWeight.w500),)
                      ) : SizedBox(height: 28),
                    SizedBox(height: 24,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "If you didn't receive a code /",
                          style: TextStyle(fontSize: Platform.isIOS ? 14 : 12, color: Color(0xff1F2933)),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        GestureDetector(
                          onTap: () async {
                            final url = "${Utils.apiUrl}users/verify_otp";

                            await Dio().post(url, data: {
                              "email": widget.dataUser["email"],
                              "otp": code,
                              "user_id": widget.dataUser["id"]
                            });
                            setState(() {
                              errorMessage = '';
                            });
                          },
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              color: Color(0xff2a5298),
                              fontSize: Platform.isIOS ? 14 : 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Platform.isIOS ? height * 0.2 : height * 0.1,),
              Image(image: AssetImage("assets/images/decoLogin.png"),)
            ],
          ),
        ),
      ),
    );
  }
}