import 'package:flutter/material.dart';

class LabelDesktop extends StatefulWidget {
  final labelName;
  final color;
  final fromPanchat;

  LabelDesktop({
    Key? key,
    @required this.labelName, 
    @required this.color,
    this.fromPanchat
  }) : super(key: key);

  @override
  _LabelDesktopState createState() => _LabelDesktopState();
}

class _LabelDesktopState extends State<LabelDesktop> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.fromPanchat == true ? EdgeInsets.only(right: 4, top: 4) : EdgeInsets.only(right: 4, top: 1, bottom: 1),
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(widget.color),
        borderRadius: BorderRadius.circular(16)
      ),
      child: Text("${widget.labelName}", style: TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
    );
  }
}