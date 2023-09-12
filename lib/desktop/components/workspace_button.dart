import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/components/icon_badge.dart';
import 'package:workcake/models/models.dart';

class WorkSpaceButton extends StatefulWidget{
  WorkSpaceButton({
    required this.onTap,
    this.currentTab,
    this.item
  });
  final VoidCallback onTap;
  final currentTab;
  final item;
  @override
  State<StatefulWidget> createState() {
    return _WorkspaceButtonState();
  }
}
class _WorkspaceButtonState extends State<WorkSpaceButton>{
  bool isHover = false;
  bool isClick = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedContainer(
          curve: Curves.easeOutSine,
          margin: EdgeInsets.only(right: widget.currentTab != widget.item["id"] && !isHover ? 4 : 0),
          duration: Duration(milliseconds: 250),
          width: widget.currentTab == widget.item["id"] || isHover ? 4 : 0,
          height: widget.currentTab == widget.item["id"] ? 40 : isHover ? 20 : 0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
            color: isHover || widget.currentTab == widget.item["id"] ? Color(0xffFAFAFA) : Color(0xff1F2933),
          ),
        ),

        Container(
          margin: EdgeInsets.symmetric(vertical: 3),
          height: 50,
          width: 50,
          child: Stack(
            children: [
              Container(
                padding: isClick ? EdgeInsets.only(top: 4, bottom: 0, right: 2, left: 2) : EdgeInsets.all(2),
                child: InkWell(
                  onHover: (hover){
                    setState(() {
                      isHover = hover;
                    });
                  },
                  onTap: (){},
                  child: GestureDetector(
                    onTapDown: (_){
                      setState(() {
                        isClick = true;
                      });
                    },
                    onTapUp: (_){
                      Future.delayed(Duration(milliseconds: 25),(){
                        setState((){
                          isClick = false;
                        });
                      });
                      widget.onTap();
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: isHover ? 250 : 100),
                      decoration: BoxDecoration(
                        color: isHover || widget.currentTab == widget.item["id"] ? Color(0xff5865f2) : Color(0xff334E68),
                        borderRadius: BorderRadius.circular(isHover || widget.currentTab == widget.item["id"] ? 16 : 40),
                      ),
                      curve: isHover ? Curves.easeOutCubic : Curves.easeInCirc,
                      child: Center(
                        child: Text(
                          widget.item["name"] != null ? widget.item["name"].substring(0, 1).toUpperCase() : "",
                          style: TextStyle(
                            color: Color(0xffF0F4F8),
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              checkWorkspaceStatus(widget.item["id"]) ? Container () : Positioned(
                right: 0, bottom: 18,
                child: IconBadge()
              )
            ]
          ),
        ),
        Container(
          width: 4,
          height: 48,
          color: Color(0xff1F2933)
        ),
      ],
    );
  }
  checkWorkspaceStatus(workspaceId) {
    bool check = true;
    final channels = Provider.of<Channels>(context, listen: true).data;
    List workspaceChannels = channels.where((e) => e["workspace_id"] == workspaceId).toList();

    for (var c in workspaceChannels) {
      if (c["new_message_count"] != null && c["new_message_count"] > 0) {
        check = false;
      }
    }

    return check;
  }
}

class DirectMessageButton extends StatefulWidget{
  DirectMessageButton({this.currentTab, this.onTap});
  final currentTab;
  final onTap;
  @override
  _DirectMessageButtonState createState() => _DirectMessageButtonState();
}

class _DirectMessageButtonState extends State<DirectMessageButton> {
  bool isHover = false;
  bool isClick = false;
  checkDirectStatus() {
    if (Provider.of<DirectMessage>(context, listen: true).dataDMMessages.where((element) => element.conversationKey!= null).toList().length > 0){
      final data = Provider.of<DirectMessage>(context, listen: true).data;
      var check = true;

      for (var dr in data) {
        if (dr.seen != null && dr.seen == false) {
          check = false;
        }
      }

      return check;        
    }
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOutSine,
          margin: EdgeInsets.only(right: widget.currentTab != 0 && !isHover ? 4 : 0),
          width: widget.currentTab == 0 || isHover ? 4 : 0,
          height: widget.currentTab == 0 ? 40 : isHover ? 20 : 0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
            color: isHover || widget.currentTab == 0 ? Color(0xfffafafa) : Color(0xff1f2933)
          ),
        ),
        Container(
          // margin: EdgeInsets.only(top: 8),
          height: 50,
          width: 50,
          child: Stack(
            children: [
              Container(
                padding: isClick ? EdgeInsets.only(top: 4, bottom: 0, right: 2, left: 2) : EdgeInsets.all(2),
                  child: InkWell(
                    onHover: (hover){
                      setState(() {
                        isHover = hover;
                      });
                    },
                    onTap: (){},
                    child: GestureDetector(
                      onTapDown: (_){
                        setState(() {
                          isClick =true;
                        });
                      },
                      onTapUp: (_){
                        Future.delayed(Duration(milliseconds: 25), (){
                          setState((){
                            isClick = false;
                          });
                        });
                        widget.onTap();
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: isHover ? 250 : 100),
                        curve: isHover ? Curves.easeOutCubic : Curves.easeInCirc,
                        decoration: BoxDecoration(
                          color: isHover || widget.currentTab == 0 ? Color(0xff5865f2) : Color(0xff334E68),
                          borderRadius: BorderRadius.circular(isHover || widget.currentTab == 0 ? 16 : 40)
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/images/logoPanchat.png",
                            width: 30,
                            height: 30,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                  ),
              ),
              checkDirectStatus() ? Container() : Positioned(
                right: 0, bottom: 16,
                child: IconBadge()
              )
            ],
          ),
        ),
        Container(
          width: 4,
          height: 48,
          color: Color(0xff1F2933)
        ),
      ],
    );
  }
}
