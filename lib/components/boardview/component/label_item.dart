import 'package:flutter/material.dart';

class LabelItem extends StatefulWidget {
  LabelItem({
    Key? key,
    this.label
  }) : super(key: key);

  final label;

  @override
  _LabelItemState createState() => _LabelItemState();
}

class _LabelItemState extends State<LabelItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(int.parse("0XFF${widget.label["color_hex"]}"))
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      height: 20,
      child: Text(widget.label["name"], style: TextStyle(fontSize: 12))
    );
  }
}