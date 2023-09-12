import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/home_screen/input_field.dart';
import 'package:workcake/screens/home_screen/input_validator.dart';

import 'submit_button.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _inputController = TextEditingController(text: "");
  String message = '';
  bool invalidCredential = false;
  bool isLoading = false;
  bool sentSuccess = false;

  @override
  void dispose() {
    super.dispose();
    _inputController.dispose();
  }

  setInvalidCredential(value) {
    setState(() {
      invalidCredential = value;
    });
  }
  _resetPassword() async {
    if(_inputController.text.isEmpty) {
      setState(() {
        invalidCredential = true;
        sentSuccess = false;
        message = "input can't empty";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    String type = _inputController.text.contains("@") ? "email" : "phone_number";

    try {
      setState(() {
        isLoading = true;
      });

      var res = await Provider.of<Auth>(context, listen: false).forgotPassword(_inputController.text, type);

      if(type == "email" || !res["success"]) {
        setState(() {
          isLoading = false;
          invalidCredential = true;
          message = res["message"];
          if(res["success"]) {
            sentSuccess = true;
          } else {
            sentSuccess = false;
          }
        });
        FocusScope.of(context).unfocus();
      } else {
        setState(() {
          isLoading = false;
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => InputValidator(dataUser: res["data"], isResetPassword: true,)));
      }
    } catch (e) {
      print(e);
    }

  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(PhosphorIcons.arrowLeft, size: 22, color: Color(0xff1F2933),),
                          SizedBox(width: 8.0,),
                          Text("Back", style: TextStyle(color: Color(0xff1F2933)),)
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.0928,),
                  Center(
                    child: Text("Reset password", style: TextStyle(color: Color(0xff1F2933), fontSize: Platform.isIOS ? 24 : 20, fontWeight: FontWeight.w500),),
                  ),
                  SizedBox(height: 16,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Center(
                      child: Text(
                        "Enter the email associated with your account and we will send a verification code to your registered email.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xff616E7C), fontSize: Platform.isIOS ? 14 : 12)   
                      ),
                    ),
                  ),
                  SizedBox(height: 40,),
                  InputField(
                    controller: _inputController,
                    keyboardType: TextInputType.emailAddress,
                    invalidCredential: invalidCredential,
                    setInvalidCredential: setInvalidCredential,
                    hintText: "Your email or phone number",
                    prefix: Container(
                      child: SvgPicture.asset("assets/images/icons/@.svg")
                    )
                  ),
                  SizedBox(height: 24,),
                  SubmitButton(
                    onTap: _resetPassword,
                    text: "Send",
                    isLoading: isLoading,
                  ),
                  SizedBox(height: 24,),
                  invalidCredential ? Container(
                    padding: EdgeInsets.only(left: 12, top: 4, bottom: 4),
                    child: Text("$message", style: TextStyle(fontWeight: FontWeight.w400, color: sentSuccess ? Color(0xff5ac45a) : Color(0xffEB5757)))      
                    ) : SizedBox(),
                  SizedBox(height: Platform.isIOS ? 0 : height * 0.2,)
                ],
              ),
            ),
            Image(image: AssetImage("assets/images/decoLogin.png"),)
          ],
        ),
      ),
    );
  }
}
