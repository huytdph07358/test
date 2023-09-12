import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/home_screen/input_field.dart';
import 'package:workcake/screens/home_screen/input_validator.dart';
import 'package:workcake/screens/home_screen/logo.dart';
import 'package:workcake/screens/home_screen/submit_button.dart';

import '../../generated/l10n.dart';

class SignUpApp extends StatefulWidget {
  final title;

  SignUpApp({Key? key, this.title}) : super(key: key);

  @override
  _SignUpAppState createState() => _SignUpAppState();
}

class _SignUpAppState extends State<SignUpApp> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String errorMessage = '';
  bool invalidCredential = false;
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  setInvalidCredential(value) {
    setState(() {
      invalidCredential = value;
    });
  }

  Widget _loginAccountLabel() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${S.current.alreadyHaveAnAccount} /',
            style: TextStyle(
              fontSize: Platform.isIOS ? 14 : 12,
              color: Color(0xff1F2933),)
          ),
          SizedBox(
            width: 4,
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Text(
              S.current.signIn,
              style: TextStyle(
                fontSize: Platform.isIOS ? 14 : 12,
                color: Color(0xff2A5298),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                width: 165,
                child: InputField(
                  controller: _firstNameController,
                  setInvalidCredential: setInvalidCredential,
                  invalidCredential: invalidCredential,
                  hintText: S.current.firstName,
                  prefix: Container(
                    child: SvgPicture.asset("assets/images/icons/User.svg")
                  )
                ),
              ),
            ),
            SizedBox(width: 12,),
            Expanded(
              child: Container(
                // width: 165,
                child: InputField(
                  controller: _lastNameController,
                  setInvalidCredential: setInvalidCredential,
                  invalidCredential: invalidCredential,
                  hintText: S.current.lastName,
                  prefix: Container(
                    child: SvgPicture.asset("assets/images/icons/User.svg")
                  )
                ),
              ),
            ),
          ],
        ),
        // InputField(
        //   controller: _userNameController,
        //   setInvalidCredential: setInvalidCredential,
        //   invalidCredential: invalidCredential,
        //   hintText: S.current.userName,
        //   prefix: Container(
        //     child: SvgPicture.asset("assets/images/icons/User.svg")
        //   )
        // ),
        InputField(
          controller: _emailController,
          setInvalidCredential: setInvalidCredential,
          invalidCredential: invalidCredential,
          keyboardType: TextInputType.emailAddress,
          hintText: S.current.yourEmailPhone,
          prefix: Container(
            child: SvgPicture.asset("assets/images/icons/User.svg")
            // child: SvgPicture.asset("assets/images/icons/@.svg")
          )
        ),
        InputPassword(
          controller: _passwordController,
          setInvalidCredential: setInvalidCredential,
          invalidCredential: invalidCredential,
          hintText: S.current.password,
          prefix: Container(
            child: SvgPicture.asset("assets/images/icons/Lock.svg")
          ),
        ),
        InputPassword(
          controller: _confirmPasswordController,
          setInvalidCredential: setInvalidCredential,
          invalidCredential: invalidCredential,
          hintText: S.current.confirmPassword,
          prefix: Container(
            child: SvgPicture.asset("assets/images/icons/Lock.svg")
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: height * 0.086),
                    Logo(),
                    SizedBox(height: height * 0.0475,),
                    Center(
                      child: Text(S.current.createAccount, style: TextStyle(fontSize: Platform.isIOS ? 24 : 18, fontWeight: FontWeight.w500, color: Color(0xff1F2933)),),
                    ),
                    SizedBox(height: height * 0.0126,),
                    Center(
                      child: Text(S.current.enterYourInformationsBelow, style: TextStyle(color: Color(0xff616E7C), fontSize: Platform.isIOS ? 14 : 12),),
                    ),
                    SizedBox(height: height * 0.03,),
                    _emailPasswordWidget(),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    Policy(),
                    SizedBox(height: height * 0.03,),
                    SubmitButton(onTap: () async {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => SignupMoreInfo())
                      // );
                      if(_firstNameController.text.trim() == '' || _lastNameController.text.trim() == '' || _emailController.text.trim() == '' || _passwordController.text.trim() == '' || _confirmPasswordController.text.trim() == '') {
                        setState(() {
                          errorMessage = "All fields must be entered";
                          invalidCredential = true;
                          FocusScope.of(context).unfocus();
                        });
                      }
                      else if(_passwordController.text.trim() != _confirmPasswordController.text.trim()){
                        setState(() {
                          errorMessage = "Password didn't match ";
                          invalidCredential = true;
                          FocusScope.of(context).unfocus();
                        });
                      } else if(_passwordController.text.trim().length < 6 || _confirmPasswordController.text.trim().length < 6){
                        setState(() {
                          errorMessage = "Password must contain at least 6 characters ";
                          invalidCredential = true;
                          FocusScope.of(context).unfocus();
                        });
                      // } else if(!Validators.validateEmail(_emailController.text.trim())) {
                      //   setState(() {
                      //     invalidCredential = true;
                      //     errorMessage = "Email is not valid!";
                      //   });
                      } else {
                        try {
                          setState(() {
                            isLoading = true;
                          });

                          var response = await Provider.of<Auth>(context, listen: false).signUp(_firstNameController.text.trim(), _lastNameController.text.trim(), _emailController.text.trim(), _passwordController.text.trim(), _confirmPasswordController.text.trim());
                          if(response != null) {
                            if(response.data["success"]) {

                              setState(() {
                                isLoading = false;
                              });

                              Navigator.push(context, MaterialPageRoute(builder: (context) => InputValidator(dataUser: {...response.data["data"], "opt_id": response.data["otp_id"], "password": _passwordController.text.trim()},)));
                            } else {
                              setState(() {
                                invalidCredential = true;
                                errorMessage = response.data["message"];
                                isLoading = false;
                              });
                              FocusScope.of(context).unfocus();
                            }
                          }
                        } catch(e) {
                          print(e);
                          setState(() {
                            isLoading = false;
                            invalidCredential = true;
                          });
                        }
                      }
                    },text: S.current.signUp, isLoading: isLoading,),
                    SizedBox(height: height * 0.025,),
                    // GestureDetector(
                    //   onTap: () async {
                    //     var response = await Provider.of<Auth>(context, listen: false).signUp(_firstName, _lastName, _emailId, _password, _confirmPassowrd);
                    //     print(response.data);
                    //     if(response.data["success"]) {
                    //       final url = "${Utils.apiUrl}users/create_otp";
                    //       var res = await Dio().post(url, data: {
                    //         "email": response.data["data"]["email"],
                    //         "user_id": response.data["data"]["id"],
                    //       });

                    //       print(res);
                    //       Navigator.push(context, MaterialPageRoute(builder: (context) => InputValidator(dataUser: response.data["data"],)));
                    //     } else {

                    //     }
                    //   },
                    //   child: SizedBox(
                    //     height: 40,
                    //     width: double.infinity,
                    //     child: Center(child: Text("Sign up now", style: TextStyle(color: Color(0xff2A5298), fontWeight: FontWeight.w500, fontSize: Platform.isIOS ? 16 : 14),))
                    //   ),
                    // ),
                    // SizedBox(height: Platform.isIOS ? height * 0.0453 : height * 0.0282,),
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
                              style: TextStyle(color: Color(0xffEB5757), fontWeight: FontWeight.w700),
                              children: [
                                TextSpan(text: " $errorMessage", style: TextStyle(fontWeight: FontWeight.w500))
                              ]
                            )
                          )
                        ],
                      ),
                    ) : SizedBox(height: 36),
                    SizedBox(height: height * 0.01,),
                    _loginAccountLabel(),
                    SizedBox(height: height * 0.048,)
                  ],
                ),
              ),
              Image(image: AssetImage("assets/images/decoLogin.png"),)
            ],
          ),
        ),
      ),
    );
  }
}

class Policy extends StatefulWidget {
  const Policy({
    Key? key,
  }) : super(key: key);

  @override
  _PolicyState createState() => _PolicyState();
}

// ignore: camel_case_types
class _PolicyState extends State<Policy> {
  bool checked = true;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          child: Transform.scale(
            scale: 0.9,
            child: Checkbox(
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
        Expanded(child: Text(S.current.iAgreeToTheTerms, style: TextStyle(color: Color(0xff1F2933), fontSize: Platform.isIOS ? 14 : 12),))
      ],
    );
  }
}