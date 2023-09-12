import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/file_share/file_share.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/services/queue.dart';

class ViewShareTo extends StatefulWidget {
  const ViewShareTo({Key? key}) : super(key: key);

  @override
  State<ViewShareTo> createState() => _ViewShareToState();
}

class _ViewShareToState extends State<ViewShareTo> {

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    // render danh sach channel(Workspace), direct
    return Scaffold(
      backgroundColor: isDark ? Color(0xff262626) : Color(0xffffffff),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 62,
              decoration: BoxDecoration(
                color: isDark ? Color(0xff2E2E2E) : Colors.white,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: isDark ? null : Border(bottom: BorderSide(color: Color(0xffDBDBDB)))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        await Future.wait(FileShare.instance.fileFromShare.map((e) async {await (File(e.localPath)).delete();}));
                        FileShare.instance.fileFromShare = [];
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 60,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      child: Text(
                        "SEND TO",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      ),
                    ),
                    Container(
                      width: 60,
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    )
                  ],
                ),
              ),
            ),
            RenderFileShared(
              files: FileShare.instance.fileFromShare,
            ),
            Expanded(child: ShareToConversationOrChannel())



          ],
          // render danh sach files
          // render Search()
          // render danh sach direct + channel
        ),
      )
    );
  }
}


class RenderFileShared extends StatefulWidget {
  const RenderFileShared({Key? key, required this.files}) : super(key: key);
  final List<DataFileShare> files;

  @override
  State<RenderFileShared> createState() => _RenderFileSharedState();
}

class _RenderFileSharedState extends State<RenderFileShared> {

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    List<DataFileShare> elementsShow = widget.files;
    return Container(
      padding: EdgeInsets.all(8),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: elementsShow.map((e) {
              return Container(
                margin: EdgeInsets.only(right: 8),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFFbfbfbf) : Color(0xFF262626),
                  borderRadius: BorderRadius.circular(8)
                ),
                width: 100,
                height: 100,
                child: e.type.contains("image/")
                  ?   ExtendedImage.file(File(e.localPath), fit: BoxFit.fill,)
                  : Container(
                    child: Center(
                      child: Text(e.localPath.split("/").last, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
                    ),
                  )
              );
              }).toList(),
          ),
        ),
      ),
    );
    
  }
}

class ShareToConversationOrChannel extends StatefulWidget {
  const ShareToConversationOrChannel({Key? key}) : super(key: key);

  @override
  State<ShareToConversationOrChannel> createState() => _ShareToConversationOrChannelState();
}

class _ShareToConversationOrChannelState extends State<ShareToConversationOrChannel> {
  List totals = [];
  List sended = [];
  Scheduler queueSendRequest =  Scheduler();
  Timer? _debounce;

  @override
  void initState(){
    super.initState();
    Timer.run(() async {
      await Future.delayed(Duration(milliseconds: 300));
      List directs = Provider.of<DirectMessage>(context, listen: false).data;
      List channels = Provider.of<Channels>(context, listen: false).data;
      totals = [] + channels.map((e) {
        return {
          "name": e["name"],
          "id": e["id"],
          "workspace_id": e["workspace_id"],
          "type": e["is_private"] ? "channel_private" : "channel_public"
        };
      }).toList() + directs.map((e) {
        return {
          "id": e.id,
          "name":  e.displayName,
          "type": "direct"
        };
      }).toList();
      setState((){});
    });
  }

  _onChangeText(String value) async {
    final auth = Provider.of<Auth>(context, listen: false);
    List channels = Provider.of<Channels>(context, listen: false).data.where((element) => Utils.unSignVietnamese(element["name"].toString()).contains(Utils.unSignVietnamese(value))).toList();
    var url = "${Utils.apiUrl}direct_messages/search_conversation?token=${auth.token}&text=$value";
    var res  = await Dio().get(url);
    List<Map> result = (res.data["data"] as List).map((e) => (e as Map)).toList();
    totals = [] + channels.map((e) {
      return {
        "name": e["name"],
        "id": e["id"],
        "workspace_id": e["workspace_id"],
        "type": e["is_private"] ? "channel_private" : "channel_public"
      };
    }).toList() + result.map((e) {
      return {
        "id": e["conversation_id"],
        "name":  e["name"],
        "type": "direct"
      };
    }).toList();
    setState((){});
  
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(16, 5, 16, 5),
          height: 38,
          child: CupertinoTextField(
            // controller: _controller,
            // focusNode: node,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
            ),
            onChanged: (text){
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                _onChangeText(text);
              });
            },
            padding: EdgeInsets.only(left: 8, right: 8),
            clearButtonMode: OverlayVisibilityMode.editing,
            prefix: Container(
              padding: EdgeInsets.only(left: 12),
              child: Icon(PhosphorIcons.magnifyingGlass, size: 18, color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E))
            ),
            placeholder: "Search",
            placeholderStyle: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E)),
            style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 14),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: totals.map((e) {
                bool isSended = sended.indexWhere((ele) => ele == e["id"]) > -1;
                return Container(
                  height: 50,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      e["type"] == "direct" 
                        ? Icon(PhosphorIcons.chats, size: 16) 
                        : e["type"] == "channel_private" 
                          ? isDark ? SvgPicture.asset("assets/images/icons/lockDark.svg") : SvgPicture.asset("assets/images/icons/lockLight.svg")
                          : isDark ? SvgPicture.asset("assets/images/icons/#Dark.svg") : SvgPicture.asset("assets/images/icons/#Light.svg"),
                      Expanded(
                        child: Text(e["name"], style: TextStyle(overflow: TextOverflow.ellipsis)),
                      ),
                      isSended ? Container() : GestureDetector(
                        onTap: () async {
                          var currentUser =  Provider.of<User>(context, listen: false).currentUser;
                          List filesProcess = await Future.wait(FileShare.instance.fileFromShare.map((e) async{
                            return {
                              "name": (e.localPath.split("/").last).split(".").first + "." + e.type.split("/").last,
                              "mime_type": e.type.split("/").last,
                              "type": e.type.split("/").first,
                              "file": await File(e.localPath).readAsBytes(),
                              "bytes": await File(e.localPath).readAsBytes()
                            };
                          }).toList());
                          // print("filesProcess: $filesProcess");

                          if (e["type"] == "direct"){
                            Provider.of<DirectMessage>(context, listen: false).sendMessageWithImage(
                              filesProcess
                              , {
                              "message": "",
                              "attachments": [],
                              "title": "",
                              "avatar_url": currentUser["avatar_url"],
                              "full_name": currentUser["full_name"],
                              "conversation_id": e["id"],
                              "show": true,
                              "id":"",
                              "user_id": auth.userId,
                              "time_create": DateTime.now().add(new Duration(hours: -7)).toIso8601String(),
                              "count": 0,
                              "sending": true,
                              "success": true,
                              "fake_id": Utils.getRandomString(10),
                              "current_time": DateTime.now().millisecondsSinceEpoch * 1000,
                              "isSend": true,
                              "from": "share"
                            }, auth.token);
                          } else {
                             var dataMessage = {
                              "channel_thread_id": null,
                              "key": Utils.getRandomString(20),
                              "message": "",
                              "attachments": [],
                              "channel_id": e["id"],
                              "workspace_id": e["workspace_id"],
                              "user_id": auth.userId,
                              "is_system_message": false,
                              "full_name": currentUser["full_name"] ?? "",
                              "avatar_url": currentUser["avatar_url"] ?? "",
                              "from": "share"
                            };
                            Provider.of<Messages>(context, listen: false).sendMessageWithImage(filesProcess, dataMessage, auth.token);
                          }
                          setState((){
                            sended += [e["id"]];
                          });
                          
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFbfbfbf),
                            borderRadius: BorderRadius.circular(16)
                          ),
                          child: Text("SEND"),
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

