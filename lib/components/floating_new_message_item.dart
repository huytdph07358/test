import 'dart:async';
import 'package:flutter/material.dart';

class FloatingNewMessageItem extends StatefulWidget {
  // require content, sender Infor, reviver infor, action
  final data;

  FloatingNewMessageItem({
    Key? key,
    @required this.data,
  }) : super(key: key);

  @override
  _FloatingNewMessageItem createState() => _FloatingNewMessageItem();
}

class _FloatingNewMessageItem extends State<FloatingNewMessageItem> {
  var show = false;
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      setState(() {
        show = true;
      });
      Timer(Duration(seconds: 5), () {
        setState(() {
          show = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // a animation width 3s from top to bottom when start end left to right when end and can over all View

    Map dataMessage = widget.data;
    return AnimatedPositioned(
        duration: Duration(milliseconds: show ? 200 : 200),
        top: show ? 20 : -100,
        child: Container(
            width: MediaQuery.of(context).size.width - 20,
            margin: EdgeInsets.all(10),
            height: 70,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: Row(
              children: [
                Ink(
                  decoration: ShapeDecoration(
                    color: Colors.deepPurpleAccent,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.message),
                    color: Colors.white,
                    onPressed: () {  },
                    // onPressed: () {
                    //   Provider.of<Workspaces>(context, listen: false).tab = 0;
                    // },
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: Text(
                        dataMessage["title"].length > 20
                            ? dataMessage["title"].substring(0, 20) + "..."
                            : dataMessage["title"],
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: Text(
                          dataMessage["message"],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }
}
