import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/thread_user.dart';
import 'package:workcake/provider/thread_user.dart';

import '../../models/models.dart';

class ThreadWorkspace extends StatefulWidget {
  final int workspaceId;
  const ThreadWorkspace({ Key? key, required this.workspaceId }) : super(key: key);

  @override
  _ThreadWorkspaceState createState() => _ThreadWorkspaceState();
}

class _ThreadWorkspaceState extends State<ThreadWorkspace> {

  late ScrollController _controller;

  @override
  void initState(){
    super.initState();
    _controller = ScrollController()..addListener(addListenerCallBack);
  }

  void addListenerCallBack(){
    final auth = Provider.of<Auth>(context, listen: false);
    if (_controller.position.extentAfter < 10) 
      Provider.of<ThreadUserProvider>(context, listen: false).getThreadWorkspace(widget.workspaceId, auth.token,);
  }

  updateThreadUnread(e) {
    final token = Provider.of<Auth>(context, listen: true).token;
    var workspaceId = e.workspaceId;
    var channelId = e.channelId;
    var obj;

    if (e is WorkspaceMessageThread) {
      obj = {'id': e.id};
    } else if (e is WorkspaceIssueThread) {
      obj = {'id': e.id, 'issue_id': e.id};
    }

    Provider.of<ThreadUserProvider>(context, listen: false).updateThreadUnread(workspaceId, channelId, obj, token);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    final threadWorkspaces = Provider.of<ThreadUserProvider>(context, listen: true).getThreadUserWorkspaceData(widget.workspaceId);

    return Material(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        bottom: false,
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
                        InkWell(
                          onTap: () {
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
                            "Threads",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
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
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  controller: _controller,
                  child: Column(
                    children: threadWorkspaces.data.map((e) {
                      if (e.unread) {
                        updateThreadUnread(e);
                      }

                      return Container(
                        key: Key("thread_workspace${e.id}"),
                        child: e.render(context)
                      );
                    }).toList()
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}