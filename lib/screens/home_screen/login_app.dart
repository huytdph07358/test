import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/validators.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/home_screen/forgot_password.dart';
import 'package:workcake/screens/home_screen/signup_app.dart';
// import 'package:workcake/screens/home_screen/signup_app.dart';

// import 'forgot_password.dart';
import 'input_field.dart';
import 'logo.dart';
import 'submit_button.dart';

class LoginApp extends StatefulWidget {
  final title;
  final controller;

  LoginApp({Key? key, this.title, this.controller}) : super(key: key);

  @override
  _LoginAppState createState() => _LoginAppState();
}

class _LoginAppState extends State<LoginApp> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool invalidCredential = false;
  String errorMessage = '';
  bool isLoading = false;

  setInvalidCredential(value) {
    setState(() {
      invalidCredential = value;
    });
  }

  // Future<void> _submit() async {
  //   await Provider.of<Auth>(context, listen: false).loginUserPassword(_emailId, _password, context);
  // }

  Widget _createAccountLabel() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => SignUpApp()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "${S.current.notRegisteredYet} /",
              style: TextStyle(fontSize: Platform.isIOS ? 14 : 12, color: Color(0xff1F2933)),
            ),
            SizedBox(
              width: 4,
            ),
            Text(
              S.current.createAnAccount,
              style: TextStyle(
                color: Color(0xff2a5298),
                fontSize: Platform.isIOS ? 14 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        InputField(
          invalidCredential: invalidCredential,
          setInvalidCredential: setInvalidCredential,
          isLogin: true,
          controller: _emailController,
          hintText: "${S.current.email} ${S.current.or} ${S.current.phoneNumber}",
          prefix: Container(
            // padding: EdgeInsets.only(top: 2, left: 16),
            child: SvgPicture.asset("assets/images/icons/@.svg")
          )
        ),
        SizedBox(height: 8,),
        InputPassword(
          invalidCredential: invalidCredential,
          setInvalidCredential: setInvalidCredential,
          isLogin: true,
          controller: _passwordController,
          hintText: S.current.password,
          prefix: SvgPicture.asset("assets/images/icons/Lock.svg"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: height,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: height * 0.086),
                  Logo(),
                  SizedBox(height: height * 0.082),
                  Column(
                    children: [
                      Text(S.current.welcome, style: TextStyle(color: Color(0xff1F2933), fontSize: Platform.isIOS ? 28 : 22, fontWeight: FontWeight.w500),),
                      SizedBox(height: height * 0.017),
                      Text(S.current.weSoExcitedToSeeYou, style: TextStyle(color: Color(0xff616E7C), fontSize: Platform.isIOS ? 14 : 12),),
                      SizedBox(height: height * 0.024,),
                    ],
                  ),
                  _emailPasswordWidget(),
                  SizedBox(height: height * 0.017),
                  RememberMe(),
                  SizedBox(height: height * 0.017),
                  SubmitButton(
                    onTap: () async {
                      if(_emailController.text.trim() == '' || _passwordController.text.trim() == '') {
                        setState(() {
                          errorMessage = "All fields must be entered";
                          invalidCredential = true;
                        });
                      } else if(_emailController.text.contains('@') && !Validators.validateEmail(_emailController.text.trim())) {
                        setState(() {
                          invalidCredential = true;
                          errorMessage = 'Email is not valid';
                        });
                      } else {
                        setState(() {
                          isLoading = true;
                        });

                        var login = await Provider.of<Auth>(context, listen: false).loginUserPassword(_emailController.text.trim(), _passwordController.text, context);
                       
                        setState(() {
                          isLoading = false;
                        });

                        if(login == true) {
                          Provider.of<Auth>(context, listen: false).setMenuIndex(0);
                          return;
                        }
                        

                        if(login.message != null) {
                          setState(() {
                            errorMessage = login.message;
                            invalidCredential = true;
                          });
                          FocusScope.of(context).unfocus();
                        }
                      }
                    },
                    text: S.current.signIn,
                    isLoading: isLoading,
                  ),
                  SizedBox(height: 24,),
                  invalidCredential ? Container(
                    height: 36,
                    padding: EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: Color(0xffFFF1F0),
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_outlined, size: 18, color: Color(0xffEB5757),),
                        SizedBox(width: 8,),
                        Text.rich(
                          TextSpan(
                            text: "{Oops}!!!",
                            style: TextStyle(color: Color(0xffEB5757), fontWeight: FontWeight.w700),
                            children: [
                              TextSpan(text: " $errorMessage", style: TextStyle(fontWeight: FontWeight.w500))
                            ]
                          )
                        )
                      ],
                    ),
                  ) : SizedBox(height: 36,),
                  // _divider(),
                  // _pancakeIDButton(),
                  // _facebookButton(),
                  // SizedBox(height: Platform.isIOS ? height * 0.055 : height *  0.06),
                  _createAccountLabel(),
                  // SizedBox(height: Platform.isIOS ? height * 0.052 : 0),
                ],
              ),
            ),
            // Positioned(top: 40, left: 0, child: _backButton()),
            Image(image: AssetImage("assets/images/decoLogin.png"),)
          ],
        ),
    ));
  }
}

class RememberMe extends StatefulWidget {
  const RememberMe({
    Key? key,
  }) : super(key: key);

  @override
  _RememberMeState createState() => _RememberMeState();
}

// ignore: camel_case_types
class _RememberMeState extends State<RememberMe> {
  bool checked = true;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              child: Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  activeColor: Colors.blue,
                  side: BorderSide(color: Color(0xff1F2933)),
                  splashRadius: 1.0,
                  value: checked,
                  onChanged: (value) {
                    setState(() {
                      checked = !checked;
                    });
                  }
                ),
              ),
            ),
            SizedBox(width: 8.0,),
            Text(S.current.rememberMe, style: TextStyle(color: Color(0xff1F2933), fontSize: Platform.isIOS ? 14 : 12),)
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: Platform.isIOS ? 10 : 8),
            alignment: Alignment.centerRight,
            child: Text('${S.current.forgotPassword} ?', style: TextStyle(fontSize: Platform.isIOS ? 14 : 12, color: Color(0xff2A5298))),
            
          ),
        ),
      ],
    );
  }
}