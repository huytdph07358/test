import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

class TaskDownloadItem extends StatefulWidget{
  final att;
  final showDownload; 
  TaskDownloadItem({
    Key? key,
    @required this.att,
    @required this.showDownload
  }): super(key: key);
  @override
  _TaskDownloadItem createState() => _TaskDownloadItem();
}

class _TaskDownloadItem extends State<TaskDownloadItem>{
  bool show  = false;

  @override
  void initState(){
    super.initState();
    Timer(Duration(seconds: 1), () {
      setState(() {
        show = true;
      });
    });
  }

  @override
  void didUpdateWidget(oldWidget){
    super.didUpdateWidget(oldWidget);
    if (widget.att["status"] == "done" && show){
        Future.delayed(Duration(seconds: 5), (){
          setState(() {
            show =  false;
          });
        });
    }
  }

  @override
  Widget build(BuildContext context){
    Map task =  widget.att;
    return AnimatedContainer(
      margin: EdgeInsets.only(bottom: 8, left: 4, right: 4),
      height: widget.showDownload || show ? 50 : 0,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          // color: task["status"] == "error" ? Colors.red[200] : Colors.white70,
          width: 0.5,
        ),
        color: task["status"] == "error" ? Colors.red[200] : Color(0xFF434343),
        borderRadius: BorderRadius.circular(10)
      ),
      duration: Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {
          if ( task["status"] == "error"){
            Provider.of<Work>(context, listen: false).reDownload(task["id"]);
          }
          else {setState(() {
           show =  false;
          });}
        },
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${Utils.getString(task["name"], 20)}", style: TextStyle(color: Colors.white, fontSize: 10)),
                  Text(" ${(task["progress"] * 100).round()} %", style: TextStyle(color: Colors.white, fontSize: 10)),
                ]
              ),
            ),
            
            Container(
              height: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: LinearProgressIndicator(
                  value: task["progress"],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                  backgroundColor: Color(0xffD6D6D6),
                ),
              ),
            ),
          ],),
        ),
      )
    );
  }
}