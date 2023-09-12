import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListIcons extends StatefulWidget {
  const ListIcons({
    Key? key,
    this.surroundTextSelection,
    this.isDark
  }) : super(key: key);

  final surroundTextSelection;
  final isDark;

  @override
  _ListIconsState createState() => _ListIconsState();
}

class _ListIconsState extends State<ListIcons> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Container(
      height: 40,
      width: 320,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.only(top: 4),
            width: 35,
            child: TextButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent)
              ),
              onPressed: () {
                widget.surroundTextSelection("### ", "", "header");
              },
              child: Text(
                "H",
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65)
                )
              )
            ),
          ),
          Container(
            width: 35,
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(CupertinoIcons.bold, size: 21),
              onPressed: () {
                widget.surroundTextSelection("**", "**", "bold");
              },
            ),
          ),
          Container(
            width: 35,
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(CupertinoIcons.italic, size: 21),
              onPressed: () {
                widget.surroundTextSelection("_", "_", "italic");
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 2.5),
            width: 35,
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.code, size: 19),
              onPressed: () {
                widget.surroundTextSelection("`", "`", "code");
              },
            ),
          ),
          Container(
            width: 35,
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(CupertinoIcons.link, size: 16),
              onPressed: () {
                widget.surroundTextSelection("[", "](url)", "link");
              },
            ),
          ),
          Container(
            width: 35,
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(CupertinoIcons.list_bullet, size: 21),
              onPressed: () {
                widget.surroundTextSelection("- ", "", "listDash");
              },
            ),
          ),
          Container(
            width: 35,
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(CupertinoIcons.list_number, size: 21),
              onPressed: () {
                widget.surroundTextSelection("1. ", "", "listNumber");
              },
            ),
          ),
          Container(
            width: 35,
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(CupertinoIcons.checkmark_square, size: 21),
              onPressed: () {
                widget.surroundTextSelection("- [ ] ", "", "check");
              },
            ),
          ),
          Container(
            width: 35,
            padding: EdgeInsets.only(top: 2.5),
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.panorama_outlined, size: 22),
              onPressed: () {
                widget.surroundTextSelection("![ ](url)", "", "img");
              },
            ),
          )
        ]
      ),
    );
  }
}