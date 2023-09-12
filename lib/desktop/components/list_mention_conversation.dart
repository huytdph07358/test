import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/desktop/components/mention_item.dart';
import 'package:workcake/models/models.dart';

class ListMentionsConversation extends StatefulWidget {
  @override
  _ListMentionsConversationState createState() => _ListMentionsConversationState();
}

class _ListMentionsConversationState extends State<ListMentionsConversation> {

  @override
  Widget build(BuildContext context) {
    final mentions = Provider.of<DirectMessage>(context, listen: true).dataMentionConversations.data;
    
    return Container(
      margin: EdgeInsets.only(top: 12, bottom: 12),
      child: SingleChildScrollView(
          child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: mentions.length,
            itemBuilder: (context, index) {
              // get source name
              String sourceName = "a direct message";
              return MentionItem(mentions: mentions, index: index, sourceName: sourceName, showDateThread: "");
            },
          ),
        )
    );
  }
}