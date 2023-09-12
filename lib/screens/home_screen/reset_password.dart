import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/home_screen/input_field.dart';

import 'submit_button.dart';


class ResetPassword extends StatefulWidget {
  final dataUser;
  const ResetPassword({Key? key, required this.dataUser}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  String message = '';
  bool invalidCredential = false;
  bool isLoading = false;
  bool sentSuccess = false;

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
  }

  setInvalidCredential(value) {
    setState(() {
      invalidCredential = value;
    });
  }
  _resetPassword(dataUser) async {
    try {
      if(_passwordController.text != _passwordConfirmController.text) {
        setState(() {
          message = "Confirm password didn't match";
          invalidCredential = true;
        });
        FocusScope.of(context).unfocus();
        return;
      }

      setState(() {
        isLoading = true;
      });

      var res = await Provider.of<Auth>(context, listen: false).resetPassword(dataUser);
      if(res["success"]) {
        await Provider.of<Auth>(context, listen: false).loginUserPassword(dataUser["phone_number"], _passwordController.text, context);
        Navigator.pushNamed(context, 'dashboard-screen');
      } else {
        isLoading = false;
        message = res["message"];
        invalidCredential = true;
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
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
                    child: Text("Create new password", style: TextStyle(color: Color(0xff1F2933), fontSize: Platform.isIOS ? 24 : 20, fontWeight: FontWeight.w500),),
                  ),
                  SizedBox(height: 16,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Center(
                      child: Text(
                        "A strong password will help you better protect your account.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xff616E7C), fontSize: Platform.isIOS ? 14 : 12)   
                      ),
                    ),
                  ),
                  SizedBox(height: 40,),
                  InputPassword(
                    invalidCredential: invalidCredential,
                    setInvalidCredential: setInvalidCredential,
                    isLogin: true,
                    controller: _passwordController,
                    hintText: "Password",
                    prefix: SvgPicture.asset("assets/images/icons/Lock.svg"),
                  ),
                  SizedBox(height: 8,),
                  InputPassword(
                    invalidCredential: invalidCredential,
                    setInvalidCredential: setInvalidCredential,
                    isLogin: true,
                    controller: _passwordConfirmController,
                    hintText: "Confirm new password",
                    prefix: SvgPicture.asset("assets/images/icons/Lock.svg"),
                  ),
                  SizedBox(height: 24,),
                  SubmitButton(
                    onTap: () {
                      _resetPassword({...widget.dataUser, "new_password": _passwordController.text});
                    },
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
