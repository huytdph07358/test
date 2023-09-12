import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/work_screen/issues.dart';

import 'labels.dart';

class Workview extends StatefulWidget {
  Workview({Key? key}) : super(key: key);

  @override
  _WorkviewState createState() => _WorkviewState();
}

class _WorkviewState extends State<Workview> {
  @override
  Widget build(BuildContext context) {
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final channelMember = Provider.of<Channels>(context, listen: true).channelMember;
    final indexOwner = channelMember.indexWhere((element) => element['id'] == currentChannel['owner_id']);
    final owner = indexOwner == -1 ? null  : channelMember[indexOwner];
    var openIssuesCount = currentChannel["openIssuesCount"] ?? 0;
    var closedIssuesCount = currentChannel["closedIssuesCount"] ?? 0;
    List labels = currentChannel["labels"] != null ? currentChannel["labels"]: [];
    List milestones = currentChannel["milestones"] != null ? currentChannel["milestones"] : [];

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: <Widget>[
          Icon(Icons.more_horiz_outlined, size: 28),
          SizedBox(width: 16),
          Icon(Icons.add, size: 28),
          SizedBox(width: 16)
        ]
      ),
      body: Column(
        children: [
          Container(        
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CachedAvatar(
                      owner["avatar_url"],
                      width: 30,
                      height: 30,
                      radius: 50, 
                      name: owner["full_name"],
                    ),
                    SizedBox(width: 8),
                    Text(owner["full_name"], style: TextStyle(fontSize: 18, color: Colors.grey[700]))
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: Text(currentChannel["name"], style: TextStyle(fontSize: 25, color: Colors.black87, fontWeight: FontWeight.w700))
                ),
                Row(
                  children: [
                    Icon(currentChannel["is_private"] ? Icons.lock_outline : CupertinoIcons.number, color: Colors.grey[600], size: 21),
                    SizedBox(width: 10),
                    Text(currentChannel["is_private"] ? "Private" : "Public", style: TextStyle(fontSize: 17, color: Colors.grey[700]))
                  ]
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people_alt_outlined, color: Colors.grey[600], size: 21),
                          SizedBox(width: 10),
                          Text("${channelMember.length}", style: TextStyle(fontSize: 17, color: Colors.grey[700])),
                          SizedBox(width: 4),
                          Text("Members", style: TextStyle(fontSize: 17, color: Colors.grey[700]))
                        ]
                      ),
                      SizedBox(width: 20),
                      Row(
                        children: [
                          Container(
                            child: Icon(Icons.star_outline, color: Colors.grey[600], size: 21)
                          ),
                          SizedBox(width: 10),
                          Text("10", style: TextStyle(fontSize: 17, color: Colors.grey[700])),
                          SizedBox(width: 4),
                          Text("Stars", style: TextStyle(fontSize: 17, color: Colors.grey[700]))
                        ]
                      )
                    ]
                  ),
                )
              ],
            ),
          ),
          Divider(color: Colors.grey[500], height: 0),
          WorkviewItem(title: "Issues", icon: Icons.info_outline, number: closedIssuesCount + openIssuesCount, iconColor: Color(0xff31d058)),
          WorkviewItem(title: "Labels", icon: Icons.tag ,number: labels.length, iconColor: Color(0xff2088ff)),
          WorkviewItem(title: "Milestones", icon: Icons.flag, number: milestones.length, iconColor: Color(0xffffd33d)),
          WorkviewItem(title: "License", icon: Icons.card_membership_outlined, number: 0, iconColor: Color(0xffd73948))
        ],
      ),
    );
  }
}

class WorkviewItem extends StatefulWidget {
  const WorkviewItem({
    Key? key,
    this.title,
    this.icon,
    this.iconColor,
    this.number,
  }) : super(key: key);

  final title;
  final icon;
  final iconColor;
  final number;

  @override
  _WorkviewItemState createState() => _WorkviewItemState();
}

class _WorkviewItemState extends State<WorkviewItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.title == "Issues") {
          Navigator.push(
            context, MaterialPageRoute(builder: (context) => Issues())
          );
        } else {
          Navigator.push(
            context, MaterialPageRoute(builder: (context) => Labels())
          );
        }
      },
      child: Row(
        children: [
          SizedBox(width: 20),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: widget.iconColor,
              borderRadius: BorderRadius.circular(6)
            ),
            child: Icon(widget.icon, color: Colors.white, size: 27)
          ),
          SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(width: 0.3, color: Colors.grey[500]!))
            ),
            padding: EdgeInsets.symmetric(vertical: 20),
            width: MediaQuery.of(context).size.width - 76,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: TextStyle(fontSize: 20, color: Colors.grey[800])),
                Row(
                  children: [
                    Text("${widget.number}", style: TextStyle(fontSize: 20,  color: Colors.grey[800])),
                    Icon(Icons.chevron_right, size: 28, color: Colors.grey[500])
                  ]
                )
              ]
            )
          )
        ]
      )
    );
  }
}