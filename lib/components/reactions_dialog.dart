import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/controller/direct_message_controller.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';

class ReactionsDialog extends StatefulWidget {
  final reactions;
  final String? conversationId;
  const ReactionsDialog({ Key? key, required this.reactions, required this.conversationId }) : super(key: key);


  @override
  _ReactionsDialogState createState() => _ReactionsDialogState();
}

class _ReactionsDialogState extends State<ReactionsDialog> {
  var indexReactionEmoji = 0;
  renderReactionPeople(user) {
    final isDark = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;
    if (widget.conversationId == null) {
      List channelMembers =  Provider.of<Channels>(context, listen: true).channelMember;
      var index = channelMembers.indexWhere((element) => element["id"] == user);
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            CachedAvatar(channelMembers[index]["avatar_url"], name: channelMembers[index]["full_name"], width: 26, height: 26),
            SizedBox(width: 8),
            Text(channelMembers[index]["full_name"], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
          ],
        )
      );      
    } else {
      DirectModel? dm = directMessageProvider.getModelConversation(widget.conversationId);
      if (dm == null) return Container();
      int indexUser = dm.user.indexWhere((e) => e["user_id"] == user);
      return Container(
        margin: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            CachedAvatar(indexUser == -1 ? null : dm.user[indexUser]["avatar_url"], name: indexUser == -1 ? "" : dm.user[indexUser]["full_name"], width: 26, height: 26),
            SizedBox(width: 8),
            Text(indexUser == -1 ? "" : dm.user[indexUser]["full_name"], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
          ],
        )
      );    
    }

  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final reactions = widget.reactions;
    return Container(
        height: MediaQuery.of(context).size.height * 2 / 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 12,horizontal: 16),
              child: Text("Reactions", style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              color: isDark ? Color(0xff5E5E5E) : Color(0xffF3F3F3),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: reactions.map<Widget>((ele) {
                    var index = reactions.indexOf(ele);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          indexReactionEmoji = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 20),
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 2, color: index == indexReactionEmoji ? isDark ? Color(0xffFAAD14) : Color(0xff1890FF) : Colors.transparent))
                        ),
                        child: Row(
                          children: [
                            FittedBox(
                              child: Text(ele["emoji"].value, style: TextStyle(fontSize: 20))
                            ),
                            SizedBox(width: 8),
                            Text("${ele["count"]}", style: TextStyle(fontSize: 14, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D))),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: reactions[indexReactionEmoji]["users"].length,
                  itemBuilder: (BuildContext context, int index) {
                    return renderReactionPeople(reactions[indexReactionEmoji]["users"][index]);
                  }
                ),
              ),
            )
          ],
        )
    );
  }
}