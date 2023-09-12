
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

class SearchBarIssue extends StatefulWidget {
  SearchBarIssue({
    Key? key,
    this.onSearchIssue
  }) : super(key: key);

  final onSearchIssue;

  @override
  _SearchBarIssueState createState() => _SearchBarIssueState();
}

class _SearchBarIssueState extends State<SearchBarIssue> {
  bool collapse = true;
  TextEditingController controller = TextEditingController();
  var _animatedWidth = 100.0;
  FocusNode focusNode = new FocusNode();
  var _debounce;

  @override
  void initState() { 
    super.initState();
    focusNode.addListener(() {
      onChangeFocus();
    });
  }

  onChangeFocus() {
    if (!focusNode.hasFocus && mounted && controller.text.trim() == "") {
      controller.clear();
      this.setState(() {
        collapse = true;
        _animatedWidth = 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    
    return Container(
      margin: EdgeInsets.only(left: 5),
      child: collapse ? Container(
        height: 34,
        child: Center(
          child: IconButton(
            onPressed: () {
              this.setState(() {
                collapse = false;
              });

              Timer(Duration(milliseconds: 20), () {
                this.setState(() {
                  _animatedWidth = 199.0;
                });
                focusNode.requestFocus();
              });
            }, 
            icon: Icon(Icons.search, color: Colors.grey[600])
          ),
        ),
      ) : AnimatedContainer(
        margin: EdgeInsets.only(left: 5),
        height: 34,
        width: _animatedWidth,
        duration: Duration(milliseconds: 20),
        child: CupertinoTextField(
          decoration: BoxDecoration(
            color: isDark ? Color(0xff1f2933) : Colors.grey[200]!,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isDark ? Color(0xff334E68) : Color(0xffBCCCDC),
            )
          ),
          focusNode: focusNode,
          style: TextStyle(fontSize: 15.5, color: isDark ? Colors.grey[300] : Colors.grey[800]),
          controller: controller,
          autofocus: true,
          padding: EdgeInsets.symmetric(horizontal: 10),
          suffix: Container(
            width: 26,
            height: 26,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(isDark ? Color(0xFF282c2e) : Colors.grey[400]!),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0))),
              ),
              child: Icon(Icons.close, size: 12, color: isDark ? Colors.grey[300] : Color(0xff4f5660)),
              onPressed: () { 
                controller.clear();
                if (_debounce?.isActive ?? false) _debounce.cancel();
                _debounce = Timer(const Duration(milliseconds: 700), () {
                  widget.onSearchIssue(controller.text);
                });
              },
            ),
          ),
          onChanged: (value) {
            if (_debounce?.isActive ?? false) _debounce.cancel();
            _debounce = Timer(const Duration(milliseconds: 700), () {
              widget.onSearchIssue(controller.text);
            });
          }
        ),
      ),
    );
  }
}