
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

import 'CardItem.dart';

class MemberSelection extends StatefulWidget {
  const MemberSelection({
    Key? key,
    required this.card
  }) : super(key: key);

  final CardItem card;

  @override
  State<MemberSelection> createState() => _MemberSelectionState();
}

class _MemberSelectionState extends State<MemberSelection> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final token = auth.token;
    final isDark = auth.theme == ThemeType.DARK;
    final channelMember = Provider.of<Channels>(context, listen: true).channelMember;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(top: 12, bottom: 6),
          child: Center(child: Text("Members", style: TextStyle(color: Colors.grey[700])))
        ),
        Divider(thickness: 1.5),
        Container(
          padding: EdgeInsets.only(left: 12, right: 12, top: 6),
          child: CupertinoTextField(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(4)
            ),
            padding: EdgeInsets.only(top: 8, left: 10, bottom: 6),
            placeholder: "Search members",
            placeholderStyle: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600])
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 14),
            itemCount: channelMember.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.only(top: 12),
                child: InkWell(
                  onTap: () async {
                    final attributeId = channelMember[index]["id"];
                    await Provider.of<Boards>(context, listen: false).addOrRemoveAttribute(token, widget.card.workspaceId, 
                      widget.card.channelId, widget.card.boardId, widget.card.listCardId, widget.card.id, attributeId, "member").then((obj) => {
                        setState(() {
                          widget.card.members = obj["assignees"];
                        })
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CachedAvatar(channelMember[index]["avatar_url"], name: channelMember[index]["full_name"], width: 30, height: 30),
                          SizedBox(width: 10),
                          Text(Utils.getUserNickName(channelMember[index]["id"]) ?? channelMember[index]["full_name"], style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700])),
                        ]
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Icon(Icons.check, color: widget.card.members.contains(channelMember[index]["id"]) ? isDark ? Colors.grey[400] : Colors.grey[700] : Colors.transparent, size: 18)
                      )
                    ]
                  )
                )
              );
            }
          )
        )
      ]
    );
  }
}
