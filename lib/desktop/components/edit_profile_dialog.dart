import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/common/validators.dart';
import 'package:workcake/models/models.dart';
import 'check_verify_phone_number.dart';

class EditProfileDialog extends StatefulWidget {
  EditProfileDialog({Key? key}) : super(key: key);

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

enum Themes { Auto, Light, Dark }

class _EditProfileDialogState extends State<EditProfileDialog> {
  List images = [];
  var dateTime;
  var body;
  var _themesType;
  bool showFormUpload = false;
  var customIdError ="";
  var fullNameError ="";
  var phoneError = "";

  void initState() {
    super.initState();
    final auth = Provider.of<Auth>(context, listen: false);
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    body = new Map.from(currentUser);
    
    dateTime = Utils.checkedTypeEmpty(currentUser["date_of_birth"]) ? DateFormatter().renderTime(DateTime.parse(currentUser["date_of_birth"]), type: "yMMMd") : "--/--/--";
    var theme = Provider.of<Auth>(context, listen: false).theme;
    bool isAutoTheme = Provider.of<Auth>(context, listen: false).isAutoTheme;
  
    if(isAutoTheme == true) {
      _themesType = Themes.Auto;
    } else {
      if(theme == ThemeType.DARK) {
        _themesType = Themes.Dark;
      } else {
        _themesType = Themes.Light;
      }
    }

    Timer.run(() async {
      await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
    });
  }

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
          body["date_of_birth"] = DateFormatter().renderTime(DateTime.parse("$picked"), type: "yyyy-MM-dd");
        });
      }
    }

  uploadAvatar(token, workspaceId) async {
    List list = images;

    this.setState(() { images = []; });

    for (var item in list) {
      String imageData = base64.encode(item["file"]);

      if (item["file"].lengthInBytes > 10000000) {
        final uploadFile = {
          "filename": item["name"],
          "path": imageData,
          "length": imageData.length,
        };
        await Provider.of<User>(context, listen: false).uploadAvatar(token, workspaceId, uploadFile, "image");
      } else {
        final uploadFile = {
          "filename": item["name"],
          "path": imageData,
          "length": imageData.length,
        };
        await Provider.of<User>(context, listen: false).uploadAvatar(token, workspaceId, uploadFile, "image");
      }
    }
  }

  openFileSelector(workspaceId) async {
    List resultList = [];
    final auth = Provider.of<Auth>(context, listen: false);
    
    try {

      var myMultipleFiles =  await Utils.openFilePicker([
        XTypeGroup(
          extensions: ['jpg', 'jpeg', 'png'],
        )
      ]);
      for (var e in myMultipleFiles) {
        Map newFile = {
          "name": e["name"],
          "file": e["file"],
          "path": e["path"]
        };
        resultList.add(newFile);
      }

      if(resultList.length > 0) {
        final image = resultList[0];
        String imageData = base64.encode(image["file"]);

        if (image["file"].lengthInBytes > 10000000) {
          final uploadFile = {
            "filename": image["name"],
            "path": imageData,
            "length": imageData.length,
          };
          await Provider.of<User>(context, listen: false).uploadAvatar(auth.token, workspaceId, uploadFile, "image");
        } else {
          final uploadFile = {
            "filename": image["name"],
            "path": imageData,
            "length": imageData.length,
          };
          await Provider.of<User>(context, listen: false).uploadAvatar(auth.token, workspaceId, uploadFile, "image");
        }
      }
    } on Exception catch (e) {
      print("$e Cancel");
    }
  }

  _updateUserInfo() async {
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    
    if(body["custom_id"].runtimeType == String) {
      body["custom_id"] = int.parse(body["custom_id"]);
    }

    if(body["avatar_url"] != currentUser["avatar_url"]) {
      body["avatar_url"] = currentUser["avatar_url"];
    }
    

    final auth = Provider.of<Auth>(context, listen: false);
    var response = await Provider.of<User>(context, listen: false).changeProfileInfo(auth.token, body);

    if(response["success"] == false) {
      // Toast.show(response["message"], context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP, textColor: Colors.white, backgroundColor: Color(0xffEF5350), backgroundRadius: 3);
    } else {
      // Toast.show("Update successfully", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.TOP, textColor: Colors.white, backgroundColor: Color(0xff0fbf3e), backgroundRadius: 3);
      await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentWorkspace = Provider.of<Workspaces>(context).currentWorkspace;
    final data = Provider.of<Workspaces>(context).data;
    final workspaceId = currentWorkspace["id"] ?? (data.length > 0 ? data[0]["id"] : "");
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    TextStyle labelStyle = TextStyle(color: isDark ? Colors.white : Color(0xff1F2933), fontSize: 14, fontWeight: FontWeight.w700);
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    final isVerifiedEmail = currentUser["is_verified_email"] is bool ? currentUser["is_verified_email"] : currentUser["is_verified_email"] == 'true';
    final isVerifiedPhoneNumber = currentUser["is_verified_phone_number"] is bool ? currentUser["is_verified_phone_number"] : currentUser["is_verified_phone_number"] == 'true';
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Color(0xff1F2933),
      ),
      width: 880,
      height: 542,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            alignment: Alignment.centerRight,
            child: InkWell(
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 22,
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
            )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text("EDIT PROFILE", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: isDark ? Color(0xff323F4B) : Color(0xffF5F7FA),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            spreadRadius: 4,
                            blurRadius: 7,
                            offset: Offset(0, 0)
                          )
                        ]
                      ),
                      width: 568,
                      height: 454,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 8,),
                                  MouseRegion(
                                    onEnter: (event) {
                                      setState(() {
                                        showFormUpload = true;
                                      });
                                    },
                                    onExit: (event) {
                                      setState(() {
                                        showFormUpload = false;
                                      });
                                    },
                                    child: showFormUpload ? Stack(
                                      children: [
                                        Container(
                                          child: CachedAvatar(
                                            currentUser["avatar_url"],
                                            height: 136,
                                            width: 136,
                                            radius: 3,
                                            fontSize: 48,
                                            name: currentUser["full_name"]
                                          ),
                                        ),
                                        Positioned(
                                          child: InkWell(
                                            child: Container(
                                              width: 136,
                                              height: 136,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(70),
                                                color: Color.fromRGBO(0, 0, 0, 0.85),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(CupertinoIcons.cloud_upload, color: Color(0xffCBD2D9) ,size: 18),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    child: Text("Upload", style: TextStyle(color: Color(0xffCBD2D9), fontSize: 14, fontWeight: FontWeight.w400))
                                                  )
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              openFileSelector(workspaceId);
                                            },
                                          ),
                                        )
                                      ],
                                    ) : Container(
                                      child: CachedAvatar(
                                        currentUser["avatar_url"],
                                        height: 136,
                                        width: 136,
                                        radius: 3,
                                        fontSize: 48,
                                        name: currentUser["full_name"]
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 28,),
                                  FormDropdown(
                                    labelContent: "Gender",
                                    labelStyle: labelStyle,
                                    formWidth: 240.0,
                                    elements: (body["gender"] == "Male" || body["gender"] == "Female") ? ["Male", "Female"] : ["Not set", "Male", "Female"],
                                    onChanged: (value) { 
                                      if(value =="Not set") {
                                        body["gender"] = null;
                                      } else {
                                        body["gender"] = value;
                                      }
                                    },
                                    initialValue: (body["gender"] == "Male" || body["gender"] == "Female") ? body["gender"] : "Not set"
                                  ),
                                  SizedBox(height: 24,),
                                  Container(
                                    width: 240,
                                    margin: EdgeInsets.only(bottom: 4),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Text("Date of Birth", style: labelStyle),
                                    )
                                  ),
                                  Container(
                                    width: 240,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isDark ? Color(0xff1F2933) : Color(0xffE4E7EB),
                                      borderRadius: BorderRadius.circular(2)
                                    ),
                                    child: TextButton(
                                      style: ButtonStyle(
                                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16)),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(2),
                                            side: BorderSide(width: 1, color: isDark ? Color(0xff1F2933) : Color(0xffD9E2EC), style: BorderStyle.solid)
                                          ),
                                        )
                                      ),
                                      onPressed: () {
                                        _selectDate(context);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(dateTime, style: TextStyle(color: isDark ? Color(0xffF5F7FA) : Color(0xff243B53), fontSize: 14, fontWeight: FontWeight.w400)),
                                          Icon(CupertinoIcons.calendar, size: 16, color: isDark ? Color(0xffF5F7FA) : Color(0xff243B53))
                                        ],
                                      )
                                    )
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 4),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Text("Full name", style: labelStyle),
                                        ),
                                      ),
                                      Container(
                                        width: 240,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4),
                                          borderRadius: BorderRadius.circular(2),
                                          border: Border.all(color: Colors.redAccent, style: fullNameError != "" || customIdError != "" ? BorderStyle.solid : BorderStyle.none)
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Container(
                                              width: 179,
                                              height: 32,
                                              child: TextFormField(
                                                onChanged: (value) {
                                                  body["full_name"] = value;
                                                  bool isError = value.length < 2 || value.length > 32 ? true : false;
                                                  if(isError) {
                                                    setState(() {
                                                      fullNameError = "Full name is not valid";
                                                    });
                                                  } else {
                                                    setState(() {
                                                      fullNameError = "";
                                                    });
                                                  }
                                                },
                                                initialValue: currentUser["full_name"],
                                                style: TextStyle(color: isDark ? Color(0xffF5F7FA) : Color(0xff243B53), fontSize: 14, fontWeight: FontWeight.w400),
                                                decoration: InputDecoration(
                                                  contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4), style: BorderStyle.solid, width: 0.5)),
                                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4), style: BorderStyle.solid, width: 0.5)),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 59,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                border: Border(left: BorderSide(color: isDark ? Color(0xff323F4B) : Colors.white))
                                              ),
                                              child: TextFormField(
                                                onChanged: (value) {
                                                  body["custom_id"] = value;
                                                  
                                                  if(value.length > 0 && value[0] == "0") {
                                                    setState(() {
                                                      customIdError = "Tag id can't begin with 0";
                                                    });
                                                  } else if(!RegExp(r'^[0-9]+$').hasMatch("$value") && value.length > 0) {
                                                    setState(() {
                                                      customIdError = "Tag id must be interger";
                                                    });
                                                  } else if(value.length != 4) {
                                                    setState(() {
                                                      customIdError = "Tag id must be 4 characters";
                                                    });
                                                  } else {
                                                    setState(() {
                                                      customIdError = "";
                                                    });
                                                  }
                                                },
                                                initialValue: "${currentUser["custom_id"]}",
                                                style: TextStyle(color: Color(0xff616E7C), fontSize: 14, fontWeight: FontWeight.w400),
                                                decoration: InputDecoration(
                                                  prefix: Text("#", style: TextStyle(color: Color(0xff616E7C), fontSize: 14, fontWeight: FontWeight.w400)),
                                                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(2), bottomRight: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4), style: BorderStyle.solid, width: 0.5)),
                                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(2), bottomRight: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4), style: BorderStyle.solid, width: 0.5)),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      )
                                    ],
                                  ),
                                  Container(
                                    height: 32,
                                    width: 240,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4),
                                        fullNameError == "" ? Container() : Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Icon(Icons.warning_amber_outlined, size: 10, color: Colors.redAccent),
                                            SizedBox(width: 4),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text("$fullNameError", style: TextStyle(color: Colors.redAccent , fontSize: 9, fontWeight: FontWeight.w400 )),
                                            ),
                                          ],
                                        ),
                                        customIdError == "" ? Container() : Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Icon(Icons.warning_amber_outlined, size: 10, color: Colors.redAccent),
                                            SizedBox(width: 4),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text("$customIdError", style: TextStyle(color: Colors.redAccent , fontSize: 9, fontWeight: FontWeight.w400 )),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  FormInput(
                                    verifyType: "email",
                                    isVerified: isVerifiedEmail,
                                    labelContent: "Email",
                                    labelStyle: labelStyle,
                                    initialValue: currentUser["email"],
                                    readOnly: true,
                                  ),
                                  SizedBox(height: 28,),
                                  FormInput(
                                    readOnly: isVerifiedPhoneNumber,
                                    verifyType: "phoneNumber",
                                    isVerified: isVerifiedPhoneNumber,
                                    labelContent: "Phone Number",
                                    labelStyle: labelStyle,
                                    isError: phoneError != "" ? true : false,
                                    initialValue: currentUser["phone_number"],
                                    onChanged: (value) {
                                      body["phone_number"] = value;
                                      if((body["phone_number"]).length > 0 && !Validators.validatePhoneNumber(body["phone_number"])) {
                                        setState(() {
                                          phoneError = "Phone number is not valid";
                                        });
                                      } else {
                                        setState(() {
                                          phoneError = "";
                                        });
                                      }
                                    }
                                  ),
                                  phoneError == "" ? Container() : Container(
                                    height: 16,
                                    width: 240,
                                    padding: EdgeInsets.only(top: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Icon(Icons.warning_amber_outlined, size: 10, color: Colors.redAccent),
                                            SizedBox(width: 4),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text("$phoneError", style: TextStyle(color: Colors.redAccent , fontSize: 9, fontWeight: FontWeight.w400 )),
                                            ),
                                          ],
                                    )
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 30,
                                child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: isDark ? MaterialStateProperty.all(Color(0xff1F2933)) : MaterialStateProperty.all(Color(0xffFFF1F0)),
                                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 22.0)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        side: BorderSide(color: Color(0xffFF4D4F), width: 1),
                                        borderRadius: BorderRadius.circular(2)
                                      )
                                    ),
                                  ),
                                  onPressed: () async {
                                    try {
                                      Navigator.pop(context);
                                      await Provider.of<Auth>(context, listen: false).logout();
                                      await Provider.of<Workspaces>(context, listen: false).resetData();
                                      await Provider.of<DirectMessage>(context, listen: false).resetData();
                                      await Provider.of<Channels>(context, listen: false).openChannelSetting(false);
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Container()));
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                  child: Text("Log out", style: TextStyle(color: Color(0xffFF4D4F), fontSize: 14, fontWeight: FontWeight.w400)),
                                ),
                              ),
                              SizedBox(width: 8,),
                              Container(
                                height: 30,
                                child: TextButton(
                                   style: ButtonStyle(
                                    foregroundColor: isDark ? MaterialStateProperty.all(Color(0xff616E7C)) : MaterialStateProperty.all(Color(0xffE4E7EB)),
                                    backgroundColor: fullNameError.length > 0 || customIdError.length > 0 || phoneError.length > 0 ? isDark ? MaterialStateProperty.all(Color(0xff616E7C)) : MaterialStateProperty.all(Color(0xffE4E7EB)) : MaterialStateProperty.all(Color(0xff2A5298)),
                                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 22.0)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2)
                                      )
                                    ),
                                  ),
                                  onPressed: fullNameError.length > 0 || customIdError.length > 0 || phoneError.length > 0 ? null : _updateUserInfo,
                                  child: Text("Save", style: TextStyle(color: fullNameError.length > 0 || customIdError.length > 0 || phoneError.length > 0 ? Color(0xff9AA5B1) : Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                  ],
                ),
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text("PREFERENCES", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: isDark ? Color(0xff323F4B) : Color(0xffF5F7FA),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            spreadRadius: 4,
                            blurRadius: 7,
                            offset: Offset(0, 0)
                          )
                        ]
                      ),
                      width: 244,
                      height: 454,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text("Themes", style: labelStyle),
                          ),
                          SizedBox(height: 11,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    child: Radio(
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      value: Themes.Auto,
                                      activeColor: Color(0xff096DD9),
                                      groupValue: _themesType,
                                      onChanged: (value) {
                                        setState(() {
                                          _themesType = value;
                                          Provider.of<Auth>(context, listen: false).setIsAutoTheme(true);
                                        });
                                        var currentTheme = MediaQuery.of(context).platformBrightness == Brightness.dark ? "NSAppearanceNameDarkAqua" : "NSAppearanceNameAqua" ;
                                        Provider.of<Auth>(context, listen: false).onChangeCurrentTheme(currentTheme, true);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8,),
                                  Text("Auto", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    child: Radio(
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      value: Themes.Light,
                                      activeColor: Color(0xff096DD9),
                                      groupValue: _themesType,
                                      onChanged: (value) {
                                        setState(() {
                                          _themesType = value;
                                          Provider.of<Auth>(context, listen: false).isAutoTheme = false;
                                          Provider.of<Auth>(context, listen: false).theme = ThemeType.LIGHT;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8,),
                                  Text("Light", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    child: Radio(
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      value: Themes.Dark,
                                      activeColor: Color(0xff096DD9),
                                      groupValue: _themesType,
                                      onChanged: (value) {
                                        setState(() {
                                          Provider.of<Auth>(context, listen: false).isAutoTheme = false;
                                          Provider.of<Auth>(context, listen: false).theme = ThemeType.DARK;
                                          _themesType = value;
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text("Dark", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 33,),
                          FormDropdown(
                            labelContent: "Language",
                            labelStyle: labelStyle,
                            formWidth: 208.0,
                            elements: ["English", "Vietnamese"],
                            onChanged: (value) {
                              body["locale"] = value == "English" ? "en" : "vi";
                            },
                            initialValue: (body["locale"] == "vi") ? "Vietnamese" : "English"
                          ),
                          Expanded(child: Container()),
                          Platform.isWindows ? 
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text("System", style: labelStyle,),
                              ),
                              Divider(
                                height: 1,
                                color: Colors.black,
                              ),
                              SystemToTray()
                            ],
                          ) : Container()
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class SystemToTray extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _SystemToTrayState();
  }
}
class _SystemToTrayState extends State<SystemToTray>{
  late bool _check = true;
  MethodChannel systemChannel = MethodChannel("system");
  late Box box;
  @override
  void initState() {
    super.initState();
    Hive.openBox("system").then((value){
      box = value;
      _check = box.get("is_tray") ?? true;
      systemChannel.invokeMethod("system_to_tray", [_check]);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),
      width: 208.0,
      child: Row(
        children: [
          Expanded(child: Text("Close button to system tray", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400))),
          Checkbox(
            onChanged: (value) {
              setState(() {
                _check = value!;
                systemChannel.invokeMethod("system_to_tray", [_check]);
                box.put("is_tray", _check);
                Provider.of<Work>(context, listen: false).isSystemTray = _check;
              });
            },
            value: _check,
            activeColor: Colors.grey[300],
            checkColor: Colors.black,
          ),
        ],
      )
    );
  }
}

class FormDropdown extends StatelessWidget{
  final labelContent;
  final labelStyle;
  final formWidth;
  final elements;
  final onChanged;
  final initialValue;

  FormDropdown({this.labelContent, this.labelStyle, this.formWidth, this.elements, this.onChanged, this.initialValue});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    final OutlineInputBorder borderStyle = OutlineInputBorder(borderRadius: BorderRadius.circular(2.0), borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4), style: BorderStyle.solid, width: 1.0));
    
    final DropdownButtonFormField formControl = DropdownButtonFormField(
      style: TextStyle(color: isDark ? Color(0xffF5F7FA) : Color(0xff243B53), fontSize: 14, fontWeight: FontWeight.w400),
      dropdownColor: isDark ? Color(0xff1F2933) : Color(0xffF5F7FA),
      icon: Icon(Icons.expand_more, size: 20, color: isDark ? Color(0xffF5F7FA) : Color(0xff243B53)),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        enabledBorder: borderStyle,
        focusedBorder: borderStyle,
      ),
      items: [
        ...this.elements.map( (element) {
          return DropdownMenuItem(
            child: Container(
              child: Text(element.toString()),
            ),
            value: element.toString(),
          );
        }), 
      ],
      onChanged: onChanged,
      value: initialValue,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(this.labelContent, style: this.labelStyle),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4),
            borderRadius: BorderRadius.circular(2)
          ),
          height: 32,
          width: formWidth,
          child: Container(
            child: formControl,
          )
        )
      ],
    );
  }
}

class FormInput extends StatefulWidget {
  final String? verifyType;
  final bool? isVerified;
  final labelContent;
  final labelStyle;
  final initialValue;
  final onChanged;
  final bool readOnly;
  final isError;
  
  FormInput({this.labelContent, this.labelStyle, this.initialValue, this.readOnly = false, this.onChanged, this.isError = false, this.isVerified, this.verifyType});

  @override
  _FormInputState createState() => _FormInputState();
}

class _FormInputState extends State<FormInput> {

  @override
  Widget build(BuildContext context) {
  final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;

  TextStyle textInputStyle =  TextStyle(
                                color: isDark ? Color(0xffF5F7FA) : Color(0xff243B53),
                                fontSize: 14,
                                fontWeight: FontWeight.w400
                              );
  final OutlineInputBorder borderStyle = OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(2.0),
                                            borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4),
                                            style: BorderStyle.solid,
                                            width: 1.0)
                                          );
  
  final formControl = TextFormField(
    onChanged: this.widget.onChanged,
    initialValue: widget.initialValue,
    readOnly: widget.readOnly,
    style: textInputStyle,
    decoration: InputDecoration(
      suffixIcon: Utils.checkedTypeEmpty(widget.isVerified)
          ? Icon(Icons.verified, color: Colors.green, size: 20)
          : InkWell(onTap: () {_showAlert(context);}, child: Icon(Icons.verified_rounded, color: Colors.grey, size: 20,)),
      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      enabledBorder: borderStyle,
      focusedBorder: borderStyle,
    ),
  );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 4),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(this.widget.labelContent, style: this.widget.labelStyle),
          ),
          ),
        Container(
            width: 240,
            height: 32,
            decoration: BoxDecoration(
              color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.redAccent, style: widget.isError ? BorderStyle.solid : BorderStyle.none)
            ),
            child: formControl
        ),
        (widget.verifyType == "email" && !Utils.checkedTypeEmpty(widget.isVerified))
            ? Container(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "Email chưa được xác thực",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red
                ),
              ))
            : (widget.verifyType == "phoneNumber" && !Utils.checkedTypeEmpty(widget.isVerified))
                ? Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    "Số điện thoại chưa được xác thực",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red
                    ),
                  ))
                : Text(""),
      ],
    );
  }

  void _showAlert(BuildContext context) {
    final currentUser = Provider.of<User>(context, listen: false).currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Enter verification code."),
        content: CheckVerifyPhoneNumber(
          verificationType: widget.verifyType,
          type: widget.verifyType == "email"
              ? currentUser["email"]
              : currentUser["phone_number"]
        )
      )
    );
  }
}
