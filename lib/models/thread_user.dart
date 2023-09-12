
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cache_avatar.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/desktop/workview_desktop/render_markdown.dart';
import 'package:workcake/models/issue.dart';
import 'package:workcake/models/message.dart';
import 'package:workcake/models/models.dart';
import '../common/utils.dart';
import '../components/thread_view.dart';
import '../screens/work_screen/issue_info.dart';
abstract class ThreadUser{
  String id = "";
  String type = "";
  String insertedAt = "";
  int count = 0;
  bool unread = false;
  int mentionCount = 0;
  bool notify = true;
  static ThreadUser parseFromJson(obj){
    if (obj["type"] == "thread_conversation") 
      return ConversationThread.parseFromJson(obj);
    if (obj["type"] == "thread_message_workspace")
      return WorkspaceMessageThread.parseFromJson(obj);
    if (obj["type"] == "thread_issue_workspace") 
      return WorkspaceIssueThread.parseFromJson(obj);
    return DefaultThreadUser("", "", "", 0);
  }

  Widget render(BuildContext context);
}

class DefaultThreadUser extends ThreadUser{
  @override
  String id = "";
  @override
  String insertedAt = "";
  // @override
  // String type = "";
  @override
  int count = 0;
  DefaultThreadUser(String s, String t, String u, int c);
  @override
  Widget render(BuildContext context) {
    return Container();
  }
}
class ConversationThread implements ThreadUser{
  @override
  String id = "";

  @override
  String insertedAt = "";

  @override
  String type = "";

  @override
  int count = 0;

  @override
  int mentionCount = 0;

  @override
  bool unread = false;

  @override
  bool notify = false;

  String messageId = "";
  String conversationId = "";  
  late MessageConv parentMessage;
  List<MessageConv> childrens = [];

  ConversationThread(String id, String insertedAt, String type, String messageId, String conversationId, MessageConv parentMessage, List<MessageConv> childrens, int count, int mentionCount, bool unread){
    this.id  = id;
    this.insertedAt  = insertedAt;
    this.type = type;
    this.messageId  = messageId;
    this.conversationId  = conversationId;
    this.parentMessage  = parentMessage;
    this.childrens  = childrens;
    this.count = count;
    this.mentionCount = mentionCount;
    this.unread = unread;
  }

  static ConversationThread parseFromJson(obj)  {
    return ConversationThread(
      obj["id"] ?? "",
      obj["inserted_at"] ?? "",
      obj["type"] ?? "",
      obj["message_id"] ?? "",
      obj["conversation_id"] ?? "",
       MessageConv.parseFromJson({...obj["parent"], "conversation_id": obj["conversation_id"]}),
       (obj["childrens"] as List).reversed.map((e) {return  MessageConv.parseFromJson({...e, "conversation_id": obj["conversation_id"]});}).toList(),
      obj["count"] ?? 0,
      obj["mention_count"] ?? 0,
      obj["unread"] ?? false
    );
  }
  onReply(BuildContext context){
    String keyDB = "${this.parentMessage.insertedAt}__${this.parentMessage.id}";
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
        return ThreadView(
          isChannel: false,
          idMessage: this.parentMessage.id,
          keyDB: keyDB,
          idConversation: this.conversationId,
        );
      }
    ));
  }
  Widget render(BuildContext context){
    // int numberSeeMore = this.count - this.childrens.length;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    var nameDM = "";
    try {
      nameDM =  Provider.of<DirectMessage>(context, listen: false).getModelConversation(this.conversationId)!.displayName;
    } catch (e) {
    }
    return Container(
      key: Key(this.id),
      child: Column(
        children: [
          // render space
          // renderNameConversation
          Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(top: 8, bottom: 8, left: 16),
                  child: Row(
                    children: [
                      Icon(PhosphorIcons.chats, color:isDark ?  Colors.white : Color(0xff5E5E5E), size: 16,),
                      SizedBox(width: 10,),
                      Text(nameDM,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.57,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),

                ),
              ),
            ],
          ),
          // render parentMessage
          Container(
            color: isDark ? Color(0xFF3d3d3d) : Color(0xFFf3f3f3),
            padding: EdgeInsets.symmetric(vertical: 10),
             decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: this.unread ? (isDark ? Palette.calendulaGold : Palette.dayBlue) : Colors.transparent, width: 4)
              )
            ),
            child: this.parentMessage.render(context, isChildMessage: false),
          ),
          Container(
            color: isDark ? Color(0xFF3d3d3d) : Color(0xFFF3F3F3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border(top:BorderSide(width: 1, color:isDark?Color(0xFF5E5E5E): Color(0xFFDBDBDB)),
                      )
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Container(height: 10,width: 1,color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),),
                ),
              ],
            ),
          ),
          // render Show number missed
          // render child
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              color: isDark ? Color(0xFF3d3d3d) : Color(0xFFf3f3f3),
              margin: EdgeInsets.only(left: 0),
              child: Column(
                children: this.childrens.map<Widget>((e) => Container(
                  key: Key(e.id),
                  child: e.render(context, isChildMessage: true),
                )).toList(),
              ),
            ),
          ),
          Container(
            height: 40,
            padding: EdgeInsets.only(bottom: 10),
            color: isDark ? Color(0xFF3d3d3d) : Color(0xFFf3f3f3),
            child: Row(
              children: [
                SizedBox(width: 30.7,),
                Container(
                  height: 40,
                  margin: EdgeInsets.only(bottom: 10),
                  child: CustomPaint(
                    size: Size(20, (10*0.642857142857143).toDouble()),
                      foregroundPainter: new HookPainter(
                      completeColor:isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),
                    ), 
                    painter: HookPainter(
                      completeColor: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),
                    
                    ),
                  ),
                ),
                SizedBox(width: 8,),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap:() => onReply(context), child: Text("Go to all replies", style: TextStyle(
                       fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Color(0xFFFAAD14) : Color(0xFF1890FF)
                    ),)),
                ),
              ],
            )
          ),
        ],
      ),
    );

  }

}

class WorkspaceMessageThread implements ThreadUser{
  @override
  int count = 0;

  @override
  String id = "";

  @override
  String insertedAt = "";

  @override
  String type = "workspace_message_thread";

  @override
  int mentionCount = 0;

  @override
  bool unread = false;

  int workspaceId = 0;
  int channelId = 0;  
  MessageChannel parentMessage = MessageChannel.parseFromJson({});
  List<MessageChannel> childrens = [];
  bool notify = false;

  WorkspaceMessageThread(String id, String insertedAt, String type, String messageId, int workspaceId, int channelId, MessageChannel parentMessage, List<MessageChannel> childrens, int count, bool notify, int mentionCount, bool unread) {
    this.id = id;
    this.insertedAt  = insertedAt;
    this.type = type;
    this.channelId = channelId;
    this.workspaceId = workspaceId;
    this.parentMessage = parentMessage;
    this.childrens = childrens;
    this.count = count;
    this.notify = notify;
    this.mentionCount = mentionCount;
    this.unread = unread;
  }

  static WorkspaceMessageThread parseFromJson(Map obj){
    return WorkspaceMessageThread(
      "${obj["id"]}" ,
      obj["inserted_at"] ?? "",
      obj["type"] ?? "", 
      "${obj["id"]}",
      obj["workspace_id"],
      obj["channel_id"],
      MessageChannel.parseFromJson(obj),
      obj["children"].map<MessageChannel>((e) => MessageChannel.parseFromJson(e)).toList(),
      obj["count_child"] ?? 0,
      obj["notify"] ?? false,
      obj["mention_count"] ?? 0,
      obj["unread"] ??  false
    );
  }

  onReply(BuildContext context)async{
    String keyDB = "${this.parentMessage.insertedAt}__${this.parentMessage.id}";
    var auth = Provider.of<Auth>(context, listen: false);
    var providerMessage = Provider.of<Messages>(context, listen: false);
    final lastChannelId = Provider.of<Channels>(context, listen: false).currentChannel['id'];
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;

    await Provider.of<Channels>(context, listen: false).onSelectedChannel(currentWorkspace['id'], this.channelId, auth, providerMessage);
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
      return ThreadView(
        isChannel: true,
        idMessage: this.parentMessage.id,
        keyDB: keyDB,
        channelId: this.channelId,
      );
    })).then((value) => Provider.of<Channels>(context, listen: false).onSelectedChannel(currentWorkspace['id'], lastChannelId, auth, providerMessage));
  }
  Widget render(BuildContext context){
    // int numberSeeMore = this.count - this.childrens.length;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    return Container(
      key: Key(this.id),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              decoration: BoxDecoration(
                 color: isDark ? Color(0xff3D3D3D) : Color(0xffF3F3F3),
                border: Border(
                  left: BorderSide(color: this.unread ? (isDark ? Palette.calendulaGold : Palette.dayBlue) : Colors.transparent, width: 4)
                )
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      Icon(PhosphorIcons.briefcase,size: 15,),
                      SizedBox(width: 8,),
                      Text(
                    "${currentWorkspace["name"]}",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.5, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E))
                  ),
                  SizedBox(width: 8,),
                  Text("|"),
                  SizedBox(width: 8,),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: SvgPicture.asset("assets/images/icons/#DisableDark.svg",color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)),
                      ),
                      SizedBox(width: 8,),
                      Text( Provider.of<Channels>(context, listen: false).getChannelName(this.channelId),
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E) 
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: this.parentMessage.render(context, isChildMessage: false),
          ),
          Container(
            color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border(top:BorderSide(width: 1, color:isDark?Color(0xFF5E5E5E): Color(0xFFDBDBDB)),
                      )
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Container(height: 10,width: 1,color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Container(              
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
                  ),
                  child: Column(
                    children: this.childrens.map<Widget>((e) => Container(
                      key: Key(e.id),
                      child: e.render(context, isChildMessage: true),
                    )).toList(),
                  ),
                ),
                Container(
                  height: 45,
                  color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
                  child: Row(
                    children: [
                      SizedBox(width: 30.9,),
                      Container(
                        height: 40,
                        margin: EdgeInsets.only(bottom: 30),
                        child: CustomPaint(
                          size: Size(16, (10*0.642857142857143).toDouble()),
                           foregroundPainter: new HookPainter(
                            completeColor:isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),
                          ), 
                          painter: HookPainter(
                            completeColor: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),
                          ),
                        ),
                      ),
                      SizedBox(width: 8,),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: InkWell(
                          onTap:() => onReply(context), child: Text("Go to all replies", style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Color(0xFFFAAD14) : Color(0xFF1890FF)
                          ),
                        )
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
         ),
       ],
      ),
    );
  }
}   
        
class WorkspaceIssueThread implements ThreadUser{
  @override
  int count = 0;

  @override
  String id = "";

  @override
  String insertedAt = "";

  @override
  int mentionCount = 0;

  @override
  bool unread = false;

  @override
  String type = "workspace_issue_thread";

  int channelId = 0;
  int workspaceId = 0;
  Issue issue = Issue.parseFromJson({});
  List<CommentIssue> comments = [];
  bool notify = true;
  List childrens =[];

  WorkspaceIssueThread(String id, int workspaceId, int channelId, int count, String insertedAt, String type, Issue issue, List<CommentIssue> comments, bool notify, int mentionCount, bool unread){
    this.id = id;
    this.count = count;
    this.insertedAt = insertedAt;
    this.type = type;
    this.issue = issue;
    this.comments = comments;
    this.channelId = channelId;
    this.workspaceId = workspaceId;
    this.notify = notify;
    this.mentionCount = mentionCount;
    this.unread = unread;
  }

  static WorkspaceIssueThread parseFromJson(Map obj){
    return WorkspaceIssueThread(
      "${obj["id"]}",
      obj["workspace_id"],
      obj["channel_id"],
      obj["count_child"] ?? 0,
      obj["inserted_at"] ?? "",
      obj["type"] ?? "workspace_issue_thread",
      Issue.parseFromJson(obj),
      obj["children"].map<CommentIssue>((e) => CommentIssue.parseFromJson(e)).toList(),
      obj["notify"] ?? false,
      obj["mention_count"] ?? 0,
      obj["unread"] ?? false
    );

  }

  Map getUser(String userId, BuildContext context) {
    try {
      final members = Provider.of<Workspaces>(context, listen: false).members;
      final index = members.indexWhere((e) => e["id"] == userId);
      return members[index];  
    } catch (e) {
      return {};
    }
  }

  parseDatetime(String insertedAt){
    return Utils.parseDatetime(DateTime.parse(insertedAt).add(Duration(hours: 7)));
  }

  Widget render(BuildContext context){
    final ownerIssue = getUser(this.issue.ownerId, context);
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final workspace = Provider.of<Workspaces>(context, listen: false).getDataWorkspace(workspaceId);
    return Container(
      color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 40,
              color:  isDark ? Color(0xFF3d3d3d) : Color(0xFFf3f3f3),
              padding: EdgeInsets.only(top: 8, bottom: 8,left: 16),
              child: Row(
                children: [
                  Icon(PhosphorIcons.briefcase,size: 16,),
                  SizedBox(width: 8,),
                  Text("${workspace['name'] ?? 'Workspace'}",style: TextStyle(
                      fontSize: 13,
                      height: 1.57,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D) 
                    ),
                  ),
                  SizedBox(width: 8),
                  Text("|"),
                  SizedBox(width: 8),
                  Text(Provider.of<Channels>(context, listen: false).getChannelName(this.channelId),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.67,
                      fontWeight: FontWeight.bold
                    )
                  )
                ]
              )
            )
          ),
          // render Title
          Container(
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
              border: Border(
                 bottom: BorderSide(width: 1.0, color:isDark ? Color(0xFF5E5E5E) : Color(0xffDBDBDB)),
              )
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
                margin: EdgeInsets.only(top: 8, bottom: 8, left: 16),
                child: Text( "#${this.issue.uniqueId} ${this.issue.title}",
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.67,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
          // render Issue
          Container(
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
            ),
            padding: EdgeInsets.only(left: 16, right: 16, top: 12,bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedAvatar(
                  ownerIssue["avatar_url"],
                  width: 32,
                  height: 32,
                  radius: 16,
                  name: ownerIssue["full_name"],
                ),
                Container(width: 8,),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ownerIssue["nickname"] ?? ownerIssue["full_name"] ?? "", 
                            style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Color(0xff2E2E2E), fontWeight: FontWeight.w700)
                          ),
                          Container(width: 4,),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: Text(
                              parseDatetime(this.issue.insertedAt),
                              style: TextStyle(
                                color: Color(0xFFA6A6A6),
                                fontSize: 12, 
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10,),
                      Container(
                        child: RenderMarkdown(
                          stringData: (this.issue.description != "") ? Utils.parseComment(this.issue.description, false) : "_No description provided._",
                          onChangeCheckBox: (value, stringComment, commentId, indexComment){}
                        )
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border(top:BorderSide(width: 1, color:isDark?Color(0xFF5E5E5E): Color(0xFFDBDBDB)),
                      )
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Container(height: 10,width: 1,color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),),
                ),
              ],
            ),
          ),
          Column(
            children: this.comments.map((e) {
              Map userInfo = getUser(e.authorId, context);
              return Container(
                key: Key("comments${e.id}"),
                color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
                padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            CachedAvatar(
                              userInfo["avatar_url"],
                              width: 32,
                              height: 32,
                              radius: 16,
                              name: userInfo["full_name"],
                            ),
                            SizedBox(height:5 ,),
                          ],
                        ),
                        Container(width: 8,),
                        Expanded(
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    userInfo["nickname"] ?? userInfo["full_name"] ?? "", 
                                    style: TextStyle(fontSize: 15, color: isDark ? Colors.white : Color(0xff2E2E2E), fontWeight: FontWeight.w700)
                                  ),
                                  Container(width: 4,),
                                  Text(
                                    parseDatetime(e.insertedAt),
                                    style: TextStyle(
                                      color: Color(0xFFA6A6A6),
                                      fontSize: 12, 
                                      height: 1.3
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 18),
                      margin: EdgeInsets.only(right: 17),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 80),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),
                            width: 1.0,
                          ),
                        )
                      ),
                      child: RenderMarkdown(
                        stringData: (e.comment != "") ? Utils.parseComment(e.comment, false) : "_No description provided._",
                        onChangeCheckBox: (value, stringComment, commentId, indexComment){}
                      )
                    )
                  ]
                )
              );
            }).toList(),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: (){
                Provider.of<Channels>(context, listen: false).selectChannel(Provider.of<Auth>(context, listen: false).token, this.workspaceId, this.channelId);
                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (BuildContext context) {
                  return IssueInfo(
                    issue: {
                      ...this.issue.toJson(),
                      "comments": [],
                      "timelines": [],
                      "assignees": []
                    },
                    isJump: true
                  );
                }));
              }, 
              child: Container(
                padding: const EdgeInsets.only(bottom:10.0),
                color: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
                child: Row(
                  children: [
                    SizedBox(width: 30.9,),
                    Container(
                        height: 40,
                        padding: EdgeInsets.only(bottom: 20),
                        child: CustomPaint(
                          size: Size(16, (10*0.642857142857143).toDouble()),
                           foregroundPainter: new HookPainter(
                            completeColor:isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),
                          ), 
                          painter: HookPainter(
                            completeColor: isDark ? Color(0xff5E5E5E) : Color(0xffC9C9C9),
                          
                          ),
                        ),
                      ),
                      SizedBox(width: 8,),
                      Text("Go to issue", style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Color(0xFFFAAD14) : Color(0xFF1890FF)
                       ),
                     ),
                   ],
                 )
              )
            ),
          )
        ],
      ),
    );
  }
  
}
class HookPainter extends CustomPainter {
  final completeColor;
  final width;
  HookPainter({
    this.completeColor, this.width
  });
  @override
  void paint(Canvas canvas, Size size) {
    
   Path path_0 = Path();
   
    path_0.moveTo(size.width*0.9285714,size.height*0.9729730);
    path_0.lineTo(size.width*0.3571429,size.height*0.9729730);
    path_0.cubicTo(size.width*0.1993471,size.height*0.9729730,size.width*0.07142857,size.height*0.9245703,size.width*0.07142857,size.height*0.8648649);
    path_0.lineTo(size.width*0.07142857,size.height*0);

    Paint paint0stroke = Paint()
    ..color = completeColor
    ..style=PaintingStyle.stroke
    ..strokeWidth=1;

    paint0stroke.strokeCap = StrokeCap.round;
    canvas.drawPath(path_0, paint0stroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}