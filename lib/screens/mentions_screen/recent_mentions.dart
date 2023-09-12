import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/common/progress.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/desktop/workview_desktop/render_markdown.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/issue.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/conversation.dart';
import 'package:workcake/screens/message.dart';
import '../../generated/l10n.dart';
import '../work_screen/issue_info.dart';
class RecentMentions extends StatefulWidget {
  @override
  _RecentMentionsState createState() => _RecentMentionsState();
}
class _RecentMentionsState extends State<RecentMentions> {
  ScrollController? controller;
  PanelController panelController = PanelController();

  @override
  void initState() {
    super.initState();
    Timer.run(() async {
      final auth = Provider.of<Auth>(context, listen: false);
     Provider.of<DirectMessage>(context, listen: false).getMentionUser(auth.token, isMark: true, lastId: "");
    });
    controller = new ScrollController()..addListener(_scrollListener);
  }

  _scrollListener() {
    final auth = Provider.of<Auth>(context, listen: false);
    if (controller ==  null) return;
    if (controller!.position.extentAfter < 10) 
      Provider.of<DirectMessage>(context, listen: false).getMentionUser(auth.token, isMark: true);
    if (controller!.position.extentBefore < 10 && controller!.position.userScrollDirection == ScrollDirection.forward){
      // Provider.of<DirectMessage>(context, listen: false).getMentionUser(auth.token, lastId: "");
      
    }
  }

  processDataMessageToJump(Map message , String conversationId) async {
    final auth  = Provider.of<Auth>(context, listen: false);
    await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(auth.token, conversationId);
    Provider.of<DirectMessage>(context, listen: false).processDataMessageToJump({
      ...message, 
      "conversation_id": conversationId,
    }, auth.token, auth.userId);
  }

  jumToSourceMention(MentionUser m) async {
    switch (m.type) {
      case "message_conversation":
        MentionUserConversation mention = m as MentionUserConversation;
        var hasConv = await Provider.of<DirectMessage>(context, listen: false).getInfoDirectMessage(Provider.of<Auth>(context, listen: false).token, m.conversationId);
        if (!hasConv) return;
        DirectModel? dm  = Provider.of<DirectMessage>(context, listen: false).getModelConversation(m.conversationId);
        if(dm == null) return;
        await processDataMessageToJump(mention.message.toJson(), mention.conversationId);
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) {
              return Message(
                dataDirectMessage: dm,
                id: dm.id,
                name: "",
                avatarUrl: "",
                isNavigator: true,
                idMessageToJump: mention.messageId,
                panelController: panelController
              );
            },
          )
        );
        break;

      case "message_channel":
        MentionUserWorkspaceMessage mention = m as MentionUserWorkspaceMessage;
        await Provider.of<Messages>(context, listen: false).handleProcessMessageToJump({
          ...mention.message.toJson(),
          "avatarUrl": mention.creatorUrl,
          "fullName": mention.creatorName,
          "workspace_id": mention.workspaceId,
          "channel_id": mention.channelId
        },context);

        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) {
              return Conversation(
                id: mention.channelId, 
                hideInput: true, 
                changePageView: (page) {}, 
                isNavigator: true,
                panelController: panelController
              );
            },
          )
        );
        break;

      case "message_issue":
        MentionUserWorkspaceIssue mention = m as MentionUserWorkspaceIssue;
        Provider.of<Channels>(context, listen: false).selectChannel(Provider.of<Auth>(context, listen: false).token, mention.workspaceId, mention.channelId);
        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
          return IssueInfo(
            issue: {
              ...mention.issue.toJson(),
              "id": mention.issueId,
              "is_closed": false,
              "comments": [],
              "timelines": [],
              "assignees": []
            },
            isJump: true
          );
        }));
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MentionUser> dataMentions = [];
    DataMentionUser dataMentionUser =  Provider.of<DirectMessage>(context, listen: true).dataMentionConversations;
    dataMentions = dataMentionUser.data;
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    return Scaffold(
      backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Container(
                height: 62,
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff2E2E2E) : Colors.white,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        child: RichText(
                          text: TextSpan(
                            text: S.current.mentions,
                            style: TextStyle(
                              color: isDark ? Color(0xffFFFFFF) : Color(0xff5E5E5E),
                              fontWeight: FontWeight.bold,
                              fontSize: 17.5,
                            )
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              dataMentionUser.isFetching && dataMentionUser.data.isEmpty 
              ? Expanded(child: SingleChildScrollView(child: shimmerEffect(context)))
              : Expanded(
                child: RefreshIndicator(
                  onRefresh: () async { 
                    await Provider.of<DirectMessage>(context, listen: false).getMentionUser(auth.token, lastId: "");
                  },
                  child: Container(
                    color: isDark ? Color(0xff2E2E2E) : Colors.white,
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      controller: controller,
                      shrinkWrap: true,
                      itemCount: dataMentions.length,
                      itemBuilder: (context, index) {
                        return RenderRecentMentionItem(
                          mention: dataMentions[index],
                          onTap: () async {
                            jumToSourceMention(dataMentions[index]);
                          },
                        );
                      }
                    )
                  ),
                )
              )
            ]
          )
        )
      )
    );
  }
}

class RenderRecentMentionItem extends StatefulWidget {
  final MentionUser mention;
  final void Function()? onTap;
  const RenderRecentMentionItem({Key? key, required this.mention, required this.onTap}) : super(key: key);

  @override
  State<RenderRecentMentionItem> createState() => _RenderRecentMentionItemState();
}

class _RenderRecentMentionItemState extends State<RenderRecentMentionItem> {

  renderHeaderMention(MentionUser mention){
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    Widget getIcon(type){
      switch (type) {
        case "message_conversation":
          return Icon(PhosphorIcons.chatsBold, size: 16,  color: isDark ? Color(0xFFA6A6A6) : Color(0xFF3D3D3D));
        case "message_channel":
          return Icon(PhosphorIcons.briefcase, size: 16, color: isDark ? Color(0xFFA6A6A6) : Color(0xFF3D3D3D));
        case "message_issue":
          return SvgPicture.asset("assets/images/icons/issueDark.svg", height: 17, color: isDark ? Color(0xFFA6A6A6) : Color(0xFF3D3D3D) ,);
        default: return Container();
      }
    }
    String getNameOf(MentionUser mention){
      try {
        switch (mention.type) {
          case "message_conversation":
            return Provider.of<DirectMessage>(context, listen: false).getModelConversation((mention as MentionUserConversation).conversationId)!.displayName;
          case "message_channel":
            return Provider.of<Channels>(context, listen: false).getChannelName((mention as MentionUserWorkspaceMessage).channelId);
          case "message_issue": 
            return Provider.of<Channels>(context, listen: false).getChannelName((mention as MentionUserWorkspaceIssue).channelId);
          default: return mention.creatorName;
        }        
      } catch (e) {
        return "";
      }
    }
    String nameWorkspace = "";
    try {
      nameWorkspace = (Provider.of<Workspaces>(context, listen: false).getNameWorkspace((mention as MentionUserWorkspaceMessage).workspaceId)) ;
    } catch (e) {
    }
    if (mention.isSameTop) return Container(height: 8,);
    if (mention.type == "message_conversation") return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 2, color:!mention.seen ? isDark ? Color(0xFFFAAD14) : Color(0xff1890FF) : isDark ? Color(0xff2E2E2E) : Colors.white)
        )
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          getIcon(mention.type),
          SizedBox(width: 8,),
          Flexible(
            flex: getNameOf(mention).length,
            child: Text(getNameOf(mention), style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E),
              fontWeight: FontWeight.w700,
              fontSize: 15.5,
              height: 1.37
            ),),
          ),
        ],
      )
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(width: 2, color:!mention.seen ? isDark ? Color(0xFFFAAD14) : Color(0xff1890FF) : isDark ? Color(0xff2E2E2E) : Colors.white)
        )
      ),
      child: Row(
        children: [
          Row(
            children: [
              getIcon(mention.type),
              SizedBox(width: 8,),
              RichText(
                text: TextSpan(
                  text: nameWorkspace,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E), height: 1.37)
                ),
              ),
              SizedBox(width: 8,),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text("|"),
              ),
              SizedBox(width: 8,),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: SvgPicture.asset("assets/images/icons/#DisableDark.svg",color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)),
          ),
          SizedBox(width: 8,),
          Flexible(
            flex: getNameOf(mention).length,
            child: RichText(
              text: TextSpan(
                text: getNameOf(mention), style: TextStyle(
                overflow: TextOverflow.ellipsis,
                color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E),
                fontWeight: FontWeight.w600,
                fontSize: 15.5,
                height: 1.37
              ),),
            ),
          ),
        ],
      ),
    );
  }

  Map getDataChannel(Issue issue){
    try {
      List channels = Provider.of<Channels>(context, listen: false).data;
      int index  = channels.indexWhere((element) => "${element["id"]}" == "${issue.channelId}");
      return {
        "channel_id": channels[index]["id"],
        ...channels[index]
      };
    } catch (e) {
      print("getDataChannel: $e");
      return {};
    }
  }

  onChangeCheckBox(value, elText, commentId, indexCheckbox){
    Issue issue = (widget.mention as MentionUserWorkspaceIssue).issue;
    final auth = Provider.of<Auth>(context, listen: false);
    final currentChannel = getDataChannel(issue);
    final channelId = currentChannel["id"];
    String description = issue.description;
    String newText = Utils.onChangeCheckbox(description, value, elText, indexCheckbox);
    issue.description = newText;
    var result = Provider.of<Messages>(context, listen: false).checkMentions(newText);
    var listMentionsNew = result["success"] ? result["data"].where((e) => e["type"] == "user").toList().map((e) => e["value"]).toList() : [];

    var dataDescription = {
      "description": newText,
      "channel_id":  channelId,
      "workspace_id": currentChannel["workspace_id"],
      "user_id": auth.userId,
      "type": "issues",
      "from_issue_id": issue.id,
      "from_id_issue_comment": issue.id,
      "list_mentions_old": [],
      "list_mentions_new": listMentionsNew
    };
    Provider.of<Channels>(context, listen: false).updateIssueTitle(auth.token, currentChannel["workspace_id"], channelId, issue.id, issue.title, dataDescription);
  }

  renderContentMention(MentionUser mention){
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    switch (mention.type) {
      case "message_conversation":
        mention = mention as MentionUserConversation;
        return Container(
          color: isDark ? Color(0xFF363636) : Color(0xFFF3F3F3),
          child: mention.type == "message_conversation" || mention.type == "message_channel" ? 
          mention.message.render(context, onTapMessage: widget.onTap): SizedBox(),
        );
        case "message_channel":
         mention = mention as MentionUserWorkspaceMessage;
        return Container(
          color: isDark ? Color(0xFF363636) : Color(0xFFF3F3F3),
          child: mention.type == "message_conversation" || mention.type == "message_channel" ? Container(
            child: mention.message.render(context, onTapMessage: widget.onTap)
          ) : SizedBox(),
        ); 
    case "message_issue":
      mention = mention as MentionUserWorkspaceIssue;
      return  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 1,color: isDark ? Color(0xff5E5E5E) :Color(0xffDBDBDB),),
          Padding(
            padding: EdgeInsets.only(left: 16,top: 10),
            child: Text(mention.issue.title,style: TextStyle(fontSize: 16),),
          ),
          SizedBox(height: 10,),
          Container(
            color: isDark ? Color(0xFF363636) : Color(0xFFF3F3F3),
            child: RenderMarkdown(
              stringData: Utils.parseComment(mention.issue.description, false),
              onChangeCheckBox: onChangeCheckBox
            )
          )
        ]
      ); 
      default: return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("____${widget.mention.seen} ${widget.mention.id}");
    if (!widget.mention.seen) {
      Provider.of<DirectMessage>(Utils.globalContext!, listen: false).markSeenMentionUser(widget.mention);
    }
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: widget.onTap,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            renderHeaderMention(widget.mention),
            renderContentMention(widget.mention)                         
          ]
        )
      )
    );
  }
}