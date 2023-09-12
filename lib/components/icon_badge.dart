import 'package:flutter/material.dart';

class IconBadge extends StatefulWidget {

  final icon;
  final size;
  final color;

  IconBadge({Key? key, this.icon, this.size, this.color})
      : super(key: key);

  @override
  _IconBadgeState createState() => _IconBadgeState();
}

class _IconBadgeState extends State<IconBadge> {

  int counter = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Icon(
          widget.icon,
          size: widget.size,
          color: widget.color ?? null,
        ),
        Positioned(
          right: 8,
          top: 3,
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Color(0xffEB5757),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white)
            ),
            constraints: BoxConstraints(
              minWidth: 11,
              minHeight: 11,
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 1),
              child: counter == 0 ? Container() : Text(
                '$counter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}