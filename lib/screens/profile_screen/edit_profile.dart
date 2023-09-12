import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/common/validators.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';

import '../../common/palette.dart';

class EditProfile extends StatefulWidget {
  final editName;
  final editBasic;
  const EditProfile({ Key? key, this.editName, this.editBasic }) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var fullNameError ="";
  var dateTime;
  var body;
  var gender;
  File? image;
  var imgName;
  var customIdError ="";
  var customUserName ="";
  // var fullNameError ="";
  var phoneError = "";
 
  // Pick image for avatar
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;

      final file = await ImageCropper().cropImage(
        sourcePath: image.path, 
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: "Edit"
        )
      );
      if(file == null) return;
      
      setState(() {
        this.image = file;
        imgName = image.name;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }



  void initState() {
    super.initState();
    final auth = Provider.of<Auth>(context, listen: false);
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    body = new Map.from(currentUser);
    
    dateTime = Utils.checkedTypeEmpty(currentUser["date_of_birth"]) ? DateFormatter().renderTime(DateTime.parse(currentUser["date_of_birth"]), type: "yMMMd") : "--/--/--";
    Timer.run(() async {
      await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
    });

    //Check gender
    if(currentUser["gender"] == null) {
      gender = "Other";
    }
    else{
      gender = currentUser["gender"];
    }

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

//Cap nhat thong tin ca nhan
  _updateUserInfo() async {
    try {
      var res = await uploadAvatar(context);
      final currentUser = Provider.of<User>(context, listen: false).currentUser;
      final auth = Provider.of<Auth>(context, listen: false);
      if(res != null) {
        if(res["success"] == true){

          if (body["custom_id"].runtimeType == String) {
            body["custom_id"] = int.parse(body["custom_id"]);
          }
          if (res["content_url"] != currentUser["avatar_url"]) {
            body["avatar_url"] = res["content_url"];
          }
          var response = await Provider.of<User>(context, listen: false).changeProfileInfo(auth.token, body);
          if (response["success"] && mounted) {
            await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
            Provider.of<Auth>(context, listen: false).locale = body['locale'];
            Navigator.pop(context);
          }
          else{
            print("Có lỗi trong quá trình cập nhật info user $response");
            showDialog(
              context: context, 
              builder: (BuildContext context) {
                return CustomDialogNew(
                  title: "Oops!!!",
                  content: "There was an error in updating your information, please try again later!",
                );
              }
            );
          }
        } else {
          print("Có lỗi trong lúc upload avatar");
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return CustomDialogNew(
                title: "Oops!!!",
                content: "There was an error while uploading the avatar, please try again later!",
              );
            }
          );
        } 
      }

      //Save khi khong co thay doi
      else {
        if (body["custom_id"].runtimeType == String) {
          body["custom_id"] = int.parse(body["custom_id"]);
        }
        var response = await Provider.of<User>(context, listen: false).changeProfileInfo(auth.token, body);
        if (response["success"] && mounted) {
          await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
          Provider.of<Auth>(context, listen: false).locale = body['locale'];
          Navigator.pop(context);
        }
        else{
          print("Có lỗi trong quá trình cập nhật info user $response");
          showDialog(
            context: context, 
            builder: (BuildContext context) {
              return CustomDialogNew(
                title: "Oops!!!",
                content: "There was an error in updating informationThere was an error in updating your information, please try again later!",
              );
            }
          );
        }
      }
    } catch (e) {
      print("Có lỗi trong quá trình cập nhật thông tin" + "\n" + "$e");
      showDialog(
          context: context, 
          builder: (BuildContext context) {
            return CustomDialogNew(
              title: "Oops!!!",
              content: "There was an error in updating informationThere was an error in updating your information, please try again later!",
            );
          }
        );
    }
  
  }
  uploadAvatar(context) async {
      final currentWorkspace = Provider.of<Workspaces>(context, listen: false ).currentWorkspace;
      final auth = Provider.of<Auth>(context, listen: false);
      if (image != null) {
        final workspaceId = currentWorkspace["id"];
        final uploadFile = {
          "filename": imgName,
          "path": base64Encode(await  image!.readAsBytes()),
          "height": 120,
          "width": 120,
        };
        var res = await Provider.of<User>(context, listen: false).uploadAvatar(auth.token, workspaceId, uploadFile, "image");
        return res;
      }
    }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    final currentUser = Provider.of<User>(context, listen: true).currentUser;
    
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Container(
        color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
        child: SafeArea(
          bottom: false,
          child: Scaffold(
            backgroundColor: isDark ? Color(0xff2E2E2E) : Colors.white,
            body: Container(
              child: Column(
                children: [
                  Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xff2E2E2E) : Colors.white,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              // Navigator.push(
                              //   context, MaterialPageRoute(builder: (context) => EditProfile())
                              // );
                            },
                            child: Container(
                              width: 40,
                              margin: EdgeInsets.only(left: 8),
                              padding: EdgeInsets.symmetric(vertical: 12,),
                              child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            child: Text(
                              widget.editBasic == true ? S.current.editBasicInfo : widget.editName == true ? S.current.editName : S.current.contactInfo,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              )
                            ),
                          ),
                          SizedBox(width: 30,)
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: isDark ? Color(0xff2E2E2E) : Colors.white,
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Container(
                          padding: EdgeInsets.only(top: 5, bottom: 30, left: 16, right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.editName == true ? Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 7,
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(S.current.userName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Color(0xffFFFFFF) : Color(0xff3D3D3D))),
                                                Container(
                                                  height: 40,
                                                  margin: EdgeInsets.only(top: 4),
                                                  child: TextFormField(
                                                    initialValue: currentUser["username"],
                                                    style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E), fontSize: 15, fontWeight: FontWeight.w400),
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: isDark ? customIdError.length > 0 ? Color(0xffFF7875).withOpacity(0.1) : Color(0xff3D3D3D) : customIdError.length > 0 ? Color(0xffFFF1F0) : Color(0xffFAFAFA),
                                                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)), borderSide: BorderSide(color: isDark ? customIdError.length > 0 ? Color(0xffFF7875) : Colors.transparent : customIdError.length > 0 ? Color(0xffEB5757) : Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)), borderSide: BorderSide(color: isDark ? customIdError.length > 0 ? Color(0xffFF7875) : Colors.transparent : customIdError.length > 0 ? Color(0xffEB5757) : Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                                    ),
                                                    onChanged: (value) {
                                                      body["username"] = value;
                                                      bool isError = value.length < 3 || value.length > 32 ? true : false;
                                                      if(isError) {
                                                        setState(() {
                                                          customIdError = "Username is not valid";
                                                        });
                                                      } else if(RegExp(r'[^a-zA-Z0-9\_\.\-]').hasMatch("$value") && value.length > 0 ){
                                                        setState(() {
                                                          customIdError = "Tên không được chứa kí tự đặc biệt";
                                                        });
                                                      } else {
                                                        setState(() {
                                                          customIdError = "";
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ),
        
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8,),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(S.current.tagName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Color(0xffFFFFFF) : Color(0xff3D3D3D))),
                                                Container(
                                                  margin: EdgeInsets.only(top: 4),
                                                  height: 40,
                                                  child: TextFormField(
                                                    keyboardType: TextInputType.number,
                                                    maxLength: 4,
                                                    initialValue: "${currentUser["custom_id"]}",
                                                    style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E), fontSize: 15, fontWeight: FontWeight.w400),
                                                    decoration: InputDecoration(
                                                      counterText: "",
                                                      prefix: Text("#", style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E), fontSize: 14, fontWeight: FontWeight.w400)),
                                                      filled: true,
                                                      fillColor: isDark ? customIdError.length > 0 ? Color(0xffFF7875).withOpacity(0.1) : Color(0xff3D3D3D) : customIdError.length > 0 ? Color(0xffFFF1F0) : Color(0xffFAFAFA),
                                                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)), borderSide: BorderSide(color: isDark ? customIdError.length > 0 ? Color(0xffFF7875) : Colors.transparent : customIdError.length > 0 ? Color(0xffEB5757) : Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)), borderSide: BorderSide(color: isDark ? customIdError.length > 0 ? Color(0xffFF7875) : Colors.transparent : customIdError.length > 0 ? Color(0xffEB5757) : Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                                    ),
                                                    onChanged: (value) {
                                                      body["custom_id"] = value;
                                                      if(value.length > 0 && value[0] =="0") {
                                                        setState(() {
                                                          customIdError = "Tag id can't begin with 0";
                                                        });
                                                      }
                                                      else if (value.length != 4) {
                                                        setState(() {
                                                          customIdError = "Tag id must be 4 characters.";
                                                        });
                                                      }
                                                      else {
                                                        setState(() {
                                                          customIdError = "";
                                                        });
                                                      }
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    !Utils.checkedTypeEmpty(body["username"]) ?
                                    Utils.checkedTypeEmpty(currentUser["username"])
                                        ? Container(
                                          padding: EdgeInsets.only(top: 4,left: 2),
                                          height: 15,)
                                        : Container(
                                          padding: EdgeInsets.only(top: 4,left: 2),
                                          height: 15,
                                          child: Text("Username là bắt buộc ", style: TextStyle(fontSize: 11, color: Palette.errorColor))
                                        )
                                    :Container(
                                      height: 15,
                                      padding: EdgeInsets.only(top: 4,left: 2),
                                      child: Text(customIdError, style: TextStyle(fontSize: 11, color: Colors.red))
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 14),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(S.current.displayName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Color(0xffFFFFFF) : Color(0xff3D3D3D))),
                                          Container(
                                            height: 40,
                                            margin: EdgeInsets.only(top: 4),
                                            child: TextFormField(
                                              initialValue: currentUser["full_name"],
                                              style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E), fontSize: 15, fontWeight: FontWeight.w400),
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: isDark ? fullNameError.length > 0 ? Color(0xffFF7875).withOpacity(0.1) : Color(0xff3D3D3D) : fullNameError.length > 0 ? Color(0xffFFF1F0) : Color(0xffFAFAFA),
                                                contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)), borderSide: BorderSide(color: isDark ? fullNameError.length > 0 ? Color(0xffFF7875) : Colors.transparent : fullNameError.length > 0 ? Color(0xffEB5757) : Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)), borderSide: BorderSide(color: isDark ? fullNameError.length > 0 ? Color(0xffFF7875) : Colors.transparent : fullNameError.length > 0 ? Color(0xffEB5757) : Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                              ),
                                              onChanged: (value) {
                                                body["full_name"] = value;
                                                  bool isError = value.length < 2 || value.length > 32 ? true : false;
                                                  if(isError) {
                                                    setState(() => fullNameError = "Your name must be more than 2 characters.");
                                                  } else {
                                                    setState(() => fullNameError = "");
                                                  }
                                              },
                                            ),
                                          ),
      
                                        ],
                                      ),
                                    ),
                                    if (fullNameError.length > 0 || customIdError.length > 0)SizedBox(height: 4),
                                    if (fullNameError.length > 0 ) Row(
                                      children: [
                                        if (fullNameError.length > 0 ) Icon(PhosphorIcons.warning, size: 13, color: isDark ? Color(0xffFF7875) : Color(0xffEB5757)),
                                        SizedBox(width: 4),
                                        Expanded(child: Text("$fullNameError", style: TextStyle(color: isDark ? Color(0xffFF7875) : Color(0xffEB5757), fontSize: 13))),
                                      ],
                                    ),
                                  ],
                                ),
                              ) 
                              : widget.editBasic == true  ? Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(S.current.dateOfBirth, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Color(0xffFFFFFF) : Color(0xff3D3D3D))),
                                    SizedBox(height: 4),
                                    Container(
                                      width: double.infinity,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isDark ? Color(0xff3D3D3D) : Color(0xffFAFAFA),
                                        borderRadius: BorderRadius.circular(2),
                                        border: Border.all(width: 1, color: isDark ? Colors.transparent : Color(0xffC9C9C9))
                                      ),
                                      child: TextButton(
                                        style: ButtonStyle(
                                          overlayColor: MaterialStateProperty.all(Colors.transparent),
                                          // padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16)),
                                          shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(2),
                                              // side: BorderSide(width: 1, color: isDark ? Color(0xff1F2933) : Color(0xffD9E2EC), style: BorderStyle.solid)
                                            ),
                                          )
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(dateTime, style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E), fontSize: 15, fontWeight: FontWeight.w400)),
                                            Icon(CupertinoIcons.calendar, size: 16, color: isDark ? Color(0xffF5F7FA) : Color(0xff243B53))
                                          ],
                                        ),
                                        onPressed:() {
                                          _selectDate(context);
                                        } ,
                                      )
                                    ),
                                    SizedBox(height: 20),
                                    Text(S.current.gender, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Color(0xffFFFFFF) : Color(0xff3D3D3D))),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: isDark ? Color(0xff3D3D3D) : Color(0xffFAFAFA),
                                              borderRadius: BorderRadius.circular(2),
                                              border: Border.all(width: 1, color: isDark ? Colors.transparent : Color(0xffC9C9C9))
                                            ),
                                            padding: EdgeInsets.only(left: 12),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  body["gender"] = "Female";
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(S.current.female, style: TextStyle(fontSize: 15, color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E))),
                                                  Container(
                                                    child: Radio(
                                                      activeColor: isDark ? Color(0xffFAAD14) : Color(0xff1890FF),
                                                      value: "Female",
                                                      groupValue: body["gender"], 
                                                      onChanged: (value) {
                                                        // print(valueeee);
                                                        setState(() {
                                                          body["gender"] = value;
                                                        });
                                                      }),
                                                  )
                                                ],
                                              ),
                                            )
                                          )
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: isDark ? Color(0xff3D3D3D) : Color(0xffFAFAFA),
                                              borderRadius: BorderRadius.circular(2),
                                              border: Border.all(width: 1, color: isDark ? Colors.transparent : Color(0xffC9C9C9))
                                            ),
                                            padding: EdgeInsets.only(left: 12),
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  body["gender"] = "Male";
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(S.current.male, style: TextStyle(fontSize: 15, color:  isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E))),
                                                  Container(
                                                    child: Radio(
                                                      activeColor: isDark ? Color(0xffFAAD14) : Color(0xff1890FF),
                                                      value: "Male", 
                                                      groupValue: body["gender"], 
                                                      onChanged: (value) {
                                                        setState(() {
                                                          body["gender"] = value;
                                                        });
                                                      }),
                                                  )
                                                ],
                                              ),
                                            )
                                          )
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ) : Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Text("Email", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Color(0xffFFFFFF) : Color(0xff3D3D3D))),
                                        SizedBox(width: 4),
                                        if(currentUser["is_verified_email"] == true) Icon(PhosphorIcons.circleWavyCheckFill, size: 16, color: Color(0xff27AE60))
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      height: 40,
                                      child: TextFormField(
                                        readOnly: true,
                                        initialValue: currentUser["email"],
                                        style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E), fontSize: 15, fontWeight: FontWeight.w400),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: isDark ?  Color(0xff3D3D3D) : Color(0xffFAFAFA),
                                          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)), borderSide: BorderSide(color: isDark ? Colors.transparent : Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)), borderSide: BorderSide(color: isDark ? Colors.transparent : Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)), borderSide: BorderSide(color: isDark ? Colors.transparent : Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                        ),
                                        onChanged: (value) {
                                          
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Text(S.current.phoneNumber, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDark ? Color(0xffFFFFFF) : Color(0xff3D3D3D))),
                                        SizedBox(width: 4),
                                        if(currentUser["is_verified_phone_number"] == true) Icon(PhosphorIcons.circleWavyCheckFill, size: 16, color: Color(0xff27AE60))
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      height: 40,
                                      child: TextFormField(
                                        readOnly: currentUser["is_verified_phone_number"] ? true : false,
                                        keyboardType: TextInputType.number,
                                        initialValue: '${currentUser["phone_number"] != "" ? currentUser["phone_number"] : ""}',
                                        style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E), fontSize: 15, fontWeight: FontWeight.w400),
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: isDark ? phoneError.length > 0 ? Color(0xffFF7875).withOpacity(0.1) : Color(0xff3D3D3D) : phoneError.length > 0 ? Color(0xffFFF1F0) : Color(0xffFAFAFA),
                                          contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)), borderSide: BorderSide(color: isDark ? phoneError.length > 0 ? Color(0xffFF7875) : Colors.transparent : phoneError.length > 0 ? Color(0xffEB5757) : Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)), borderSide: BorderSide(color: isDark ? phoneError.length > 0 ? Color(0xffFF7875) : Colors.transparent : phoneError.length > 0 ? Color(0xffEB5757) : Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                        ),
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
                                        },
                                      ),
                                    ),
                                    if(phoneError.length > 0) SizedBox(height: 4),
                                    if(phoneError.length > 0) Row(
                                      children: [
                                        if (phoneError.length > 0) Icon(PhosphorIcons.warning, size: 13, color: isDark ? Color(0xffFF7875) : Color(0xffEB5757)),
                                        SizedBox(width: 4),
                                        Text(phoneError, style: TextStyle(color: isDark ? Color(0xffFF7875) : Color(0xffEB5757), fontSize: 13)),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    )
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: fullNameError.length > 0 || customIdError.length > 0 || phoneError.length > 0 ? Colors.grey : Color(0xff1890FF),
                      borderRadius: BorderRadius.circular(4)
                    ),
                    margin: EdgeInsets.only(bottom: 30, left: 20, right: 20),
                    width: double.infinity,
                    child: TextButton(
                      child: Text(S.current.save, style: TextStyle(fontSize: 17, color: Color(0xffFFFFFF), fontWeight: FontWeight.w400)), 
                      onPressed: fullNameError.length > 0 || customIdError.length > 0 || phoneError.length > 0 ? null : _updateUserInfo,
                    ),
                  )
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}