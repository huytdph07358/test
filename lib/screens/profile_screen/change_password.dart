import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/generated/l10n.dart';

import '../../models/auth_model.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool isLoading = false;
  String password = "";
  String newPassword = "";
  String renewPassword = "";
  bool obscureText = true;

  final focusNewPass = FocusNode();
  final focusRenewPass = FocusNode();

  Future<dynamic> _changePassword(token) async {
    setState(() => isLoading = true);

    final url = Utils.apiUrl + "users/change_password?token=$token";
    try {
      final data = {
        "password": password,
        "new_password": newPassword,
        "renew_password": renewPassword
      };
      final response = await Dio().post(url, data: json.encode(data));
      final auth = Provider.of<Auth>(context, listen: false);
      final isDark = auth.theme == ThemeType.DARK;
      if (response.data["success"]) {
        Navigator.of(context, rootNavigator: true).pop("Discard");
        Fluttertoast.showToast(
          msg: S.current.success,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D),
          textColor: isDark ? Color(0xff2E2E2E) : Colors.white,
          fontSize: 16.0
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => SimpleDialog(
          children: <Widget>[
              new Center(child: new Container(child: new Text(response.data["message"])))
          ])
        );
      }
      setState(() => isLoading = false);
    } catch (e, trace) {
      setState(() => isLoading = false);
      print("$e\n$trace");
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<Auth>();
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 62,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff2E2E2E) : Colors.white,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1, color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED))
                      )
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(Icons.arrow_back)
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          child: Text(
                            S.current.changePassword,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Text(
                    S.current.changePassword,
                    style: TextStyle(fontSize: 15.5, color: isDark ? Color.fromARGB(255, 150, 147, 147) : Colors.black)
                  )
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Text(
                    S.current.noteNewPassword,
                    style: TextStyle(fontSize: 13, color: isDark ? Color.fromARGB(255, 150, 147, 147) : Color(0xff5E5E5E))
                  )
                ),
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    child: Text(
                      !obscureText ? S.current.hide : S.current.appear,
                      style: TextStyle(fontSize: 15.5, color: isDark ? Color.fromARGB(255, 210, 207, 207) : Colors.black, decoration: TextDecoration.underline)
                    ),
                  )
                ),
                Container(
                  height: 40,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: TextFormField(
                    obscureText: obscureText,
                    onChanged: (value) => setState(() => password = value),
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: S.current.currentPassword,
                      hoverColor: isDark ? Color(0xff5E5E5E) : Color(0xffEDEDED),
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      filled: true,
                      fillColor: isDark ? Color(0xFF353535) : Color(0xffFAFAFA),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                        borderRadius: BorderRadius.all(Radius.circular(4)))
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: TextFormField(
                    focusNode: focusNewPass,
                    obscureText: obscureText,
                    onChanged: (value) => setState(() => newPassword = value),
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: S.current.NewPassword,
                      hoverColor: isDark ? Color(0xff5E5E5E) : Color(0xffEDEDED),
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      filled: true,
                      fillColor: isDark ? Color(0xFF353535) : Color(0xffFAFAFA),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                        borderRadius: BorderRadius.all(Radius.circular(4)))
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: TextFormField(
                    focusNode: focusRenewPass,
                    obscureText: obscureText,
                    onChanged: (value) => setState(() => renewPassword = value),
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: S.current.enterANewPassword,
                      hoverColor: isDark ? Color(0xff5E5E5E) : Color(0xffEDEDED),
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      filled: true,
                      fillColor: isDark ? Color(0xFF353535) : Color(0xffFAFAFA),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9)),
                        borderRadius: BorderRadius.all(Radius.circular(4)))
                    ),
                  ),
                ),
                if (newPassword != renewPassword) Container(
                  margin: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    S.current.newPasswordDoesMatch,
                    style: TextStyle(fontSize: 11, color: Palette.errorColor)
                  )
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 32,
                        margin: EdgeInsets.only(right: 12),
                        child: OutlinedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all((newPassword == "" || renewPassword == "" || newPassword != renewPassword || newPassword.length < 6 ||  renewPassword.length < 6 || password == "") ? isDark ? Color(0xff707070) : Color(0xffF3F3F3) :Color(0xff1890FF)),
                          ),
                          onPressed: (newPassword == "" || renewPassword == "" || newPassword != renewPassword || newPassword.length < 6 ||  renewPassword.length < 6 || password == "")
                            ? null
                            : () => _changePassword(auth.token),
                          child: isLoading
                            ? Center(
                                child: SpinKitFadingCircle(
                                  color: isDark ? Colors.white60 : Color(0xff096DD9),
                                  size: 15,
                                ))
                            : Text(
                                S.current.update,
                                style: TextStyle(color : Colors.white),)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}