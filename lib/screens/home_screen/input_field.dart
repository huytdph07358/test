import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/auth_model.dart';

class InputPassword extends StatefulWidget {
  const InputPassword({Key? key, required this.controller, this.hintText, required this.prefix, this.invalidCredential = false, this.setInvalidCredential, this.isLogin = false}) : super(key: key);
  final TextEditingController controller;
  final String? hintText;
  final Widget? prefix;
  final bool invalidCredential;
  final bool isLogin;
  final Function(bool)? setInvalidCredential;

  @override
  _InputPasswordState createState() => _InputPasswordState();
}

class _InputPasswordState extends State<InputPassword> {

  bool obscureText = true;
  FocusNode _focus = new FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose(){
    _focus.dispose();
    super.dispose();
  }

  void _onFocusChange(){
    if(widget.invalidCredential && _focus.hasFocus) {
      widget.setInvalidCredential!(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    return Container(
      height: Platform.isIOS ? 46 : 42,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        focusNode: _focus,
        keyboardType: TextInputType.visiblePassword,
        controller: widget.controller,
        obscureText: obscureText,
        style: TextStyle(color: Color(0xff323F48)),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 12, color: isDark ? Color(0xff828282) : Color(0xff323F48)),
          prefixIcon: widget.prefix,
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
            child: obscureText ? SvgPicture.asset("assets/images/icons/Eye.svg") : SvgPicture.asset("assets/images/icons/EyeInvisible.svg"),
          ),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: widget.invalidCredential && widget.isLogin ? Color(0xffEB5757) : Color(0xff616E7C), width: 0.5)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: widget.invalidCredential && widget.isLogin ? Color(0xffEB5757) :Color(0xff2A5298), width: 0.5)),
          contentPadding: EdgeInsets.only( top: 12.0, bottom: 12),
        ),
      ),
    );
  }
}


class InputField extends StatefulWidget {
  InputField({Key? key, required this.controller, required this.hintText, required this.prefix, this.invalidCredential = false, this.autoFocus = false, this.setInvalidCredential, this.keyboardType = TextInputType.text, this.isLogin = false}) : super(key: key);
  final TextEditingController controller;
  final String? hintText;
  final Widget? prefix;
  final bool invalidCredential;
  final bool isLogin;
  final bool autoFocus;
  final keyboardType;
  final Function(bool)? setInvalidCredential;

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  FocusNode _focus = new FocusNode();
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose(){
    _focus.dispose();
    super.dispose();
  }

  void _onFocusChange(){
    if(widget.invalidCredential && _focus.hasFocus) {
      widget.setInvalidCredential!(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    return Container(
      height: Platform.isIOS ? 46 : 42,
      margin: EdgeInsets.symmetric(vertical: Platform.isIOS ? 10.0 : 8.0),
      child: TextFormField(
        keyboardType: widget.keyboardType,
        focusNode: _focus,
        autofocus: widget.autoFocus,
        controller: widget.controller,
        style: TextStyle(color: Color(0xff323F48)),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 12, color: isDark ? Color(0xff828282) : Color(0xff323F48)),
          prefixIcon: widget.prefix,
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: widget.invalidCredential && widget.isLogin ? Color(0xffEB5757) : Color(0xff616E7C), width: 0.5)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: widget.invalidCredential && widget.isLogin ? Color(0xffEB5757) : Color(0xff616E7C), width: 0.5)),
          contentPadding: EdgeInsets.only( top: 12.0, bottom: 12, right: 6),
          // fillColor: Color(0xfff3f3f4),
          // filled: true
        ),
      ),
    );
  }
}
