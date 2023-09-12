import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/icon_badge.dart';
import 'package:workcake/models/models.dart';

class Threads extends StatefulWidget {
  Threads({Key? key}) : super(key: key);

  @override
  _ThreadsState createState() => _ThreadsState();
}

class _ThreadsState extends State<Threads> {
  bool isHover = false;
  @override
  Widget build(BuildContext context) {
    final selectedTab = Provider.of<User>(context, listen: true).selectedTab;
    final currentMember = Provider.of<Workspaces>(context, listen: true).currentMember;
    final numberUnreadThreads = currentMember["number_unread_threads"] ?? 0;
    final token = Provider.of<Auth>(context, listen: true).token;

    return Container(
      height: 32.0,
      decoration: selectedTab == "thread" ? BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(3)),
        color: Color(0xff1F2933)
      ) 
      : isHover ? BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(3)),
          color: Color(0xff3a4e5f)
      ) : BoxDecoration(),
      
      margin: EdgeInsets.only(top: 4, right: 8, left: 8, bottom: 4),
      child: InkWell(
        onHover: (hover){
          setState(() {
            isHover = hover;
          });
        },
        onTap: () {
          Provider.of<User>(context, listen: false).selectTab("thread");
          Provider.of<Workspaces>(context, listen: false).onChangeThread(false, token);
          Provider.of<Workspaces>(context, listen: false).onChangeTabs(true);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(width: 6),
                  Icon(Icons.message, color: isHover || selectedTab == "thread" ? Utils.getHighlightTextColor() : Utils.getUnHighlightTextColor(), size: 15),
                  SizedBox(width: 10),
                  Text("Threads", style: TextStyle(color: isHover || selectedTab == "thread" ? Utils.getHighlightTextColor() : Utils.getUnHighlightTextColor())),
                ]
              ),
              numberUnreadThreads > 0 ? Container(
                padding: EdgeInsets.only(top: 10),
                child: IconBadge()
              ) : Container()
            ],
          )
        ),
      ),
    );
  }
}