import 'package:flutter/cupertino.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

class CustomSearchBar extends StatefulWidget {
  final placeholder;
  final onChanged;
  final double radius;
  final prefix;
  final controller;
  final autoFocus;
  final focusNode;
  final decoration;

  CustomSearchBar({
    Key? key,
    this.placeholder = "",
    this.onChanged,
    this.controller,
    this.radius = 5,
    this.prefix = true,
    this.autoFocus = false,
    this.focusNode,
    this.decoration
  }) : super(key: key);

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;

    return CupertinoTextField(
      focusNode: widget.focusNode ?? FocusNode(),
      autofocus: false,
      prefix: widget.prefix ? Container(
        child: Icon(PhosphorIcons.magnifyingGlass, size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),
        padding: EdgeInsets.only(left: 15)
      ) : Container(),
      placeholder: widget.placeholder,
      placeholderStyle: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E), fontSize: 15, fontFamily: "Roboto"),
      style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 15, fontFamily: "Roboto"),
      padding: EdgeInsets.symmetric(vertical: 11, horizontal: 12),
      clearButtonMode: OverlayVisibilityMode.editing,
      controller: widget.controller,
      decoration: widget.decoration ?? BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3)
      ),
      onChanged: (value) {
        widget.onChanged(value);
      },
    );
  }
}
