import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/screens/home_screen/submit_button.dart';

class SignupMoreInfo extends StatefulWidget {
  SignupMoreInfo({Key? key}) : super(key: key);

  @override
  _SignupMoreInfoState createState() => _SignupMoreInfoState();
}

class _SignupMoreInfoState extends State<SignupMoreInfo> {
  var dateTime = "--/--/--";
  var birthDay;
  String gender = "male";

  _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(new Duration(days: -7300)),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if(picked == null) {
        return;
      }

      final dateFormatted = DateFormatter().renderTime(DateTime.parse("$picked"), type: "yMMMd");
      if (dateFormatted != "" && dateFormatted != dateTime) {
        setState(() {
          dateTime = dateFormatted;
          birthDay = DateFormatter().renderTime(DateTime.parse("$picked"), type: "yyyy-MM-dd");
        });
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.086),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.arrow_left),
                          SizedBox(width: 8.0,),
                          Text("Back")
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.069,),
                    Center(
                      child: Stack(
                        children: [
                          SvgPicture.asset("assets/images/icons/AVT.svg"),
                          Positioned(
                            top: 40,
                            left: 42,
                            child: Column(
                              children: [
                                SvgPicture.asset("assets/images/icons/CloudUpload.svg"),
                                SizedBox(height: 8.0,),
                                Text("Avatar")
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.03,),
                    Text("Gender", style: TextStyle(color: Color(0xff1F2933), fontSize: Platform.isIOS ? 16 : 14, fontWeight: FontWeight.w700),),
                    SizedBox(height: height * 0.027,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              gender = "male";
                            });
                          },
                          child: Container(
                            height: Platform.isIOS ? 88 : 80,
                            width: Platform.isIOS ? 88 : 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffF5F7FA),
                              border: Border.all(color: Color(0xff2A5298))
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/images/icons/Man.svg"),
                                SizedBox(height: 8.0,),
                                Text("Male", style: TextStyle(fontSize: Platform.isIOS ? 14 : 13, color: Color(0xff323F4B)),)
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              gender = "female";
                            });
                          },
                          child: Container(
                            height: Platform.isIOS ? 88 : 80,
                            width: Platform.isIOS ? 88 : 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffF5F7FA),
                              border: Border.all(color: Color(0xff2A5298))
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/images/icons/Woman.svg"),
                                SizedBox(height: 8.0,),
                                Text("Female", style: TextStyle(fontSize: Platform.isIOS ? 14 : 13, color: Color(0xff323F4B)),)
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              gender = "other";
                            });
                          },
                          child: Container(
                            height: Platform.isIOS ? 88 : 80,
                            width: Platform.isIOS ? 88 : 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffF5F7FA),
                              border: Border.all(color: Color(0xff2A5298))
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/images/icons/Other.svg"),
                                SizedBox(height: 8.0,),
                                Text("Other", style: TextStyle(fontSize: Platform.isIOS ? 14 : 13, color: Color(0xff323F4B)),)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.03,),
                    Text("Date of Birth", style: TextStyle(color: Color(0xff1F2933), fontSize: Platform.isIOS ? 16 : 14, fontWeight: FontWeight.w700),),
                    SizedBox(height: height * 0.023,),
                    GestureDetector(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: Color(0xff616E7C))
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dateTime),
                            SvgPicture.asset("assets/images/icons/Calendar.svg"),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 28,),
                    SubmitButton(onTap: () {}, text: "Create account"),
                    SizedBox(height: 24.0,),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: Platform.isIOS ? 12.0 : 10.0),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text("Skip", style: TextStyle(color: Color(0xff1F2933), fontSize: Platform.isIOS ? 16 : 14, fontWeight: FontWeight.w500),),
                    ),
                    SizedBox(height: 96,),
                  ],
                ),
              ),
              Image(image: AssetImage("assets/images/decoLogin.png"),)
            ],
          )
        ),
      ),
    );
  }
}