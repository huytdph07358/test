import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/provider/thread_user.dart';

import '../../models/models.dart';

class ThreadConversation extends StatefulWidget {
  const ThreadConversation({ Key? key }) : super(key: key);

  @override
  _ThreadConversationState createState() => _ThreadConversationState();
}

class _ThreadConversationState extends State<ThreadConversation> {

  late ScrollController _controller;
  @override
  void initState(){
    super.initState();
    _controller = ScrollController()..addListener(addListenerCallBack);
    Provider.of<ThreadUserProvider>(context, listen: false).getThread(Provider.of<Auth>(context, listen: false).token, context, isUpdate: true, lastId: "null");
  }

  void addListenerCallBack(){
    if (_controller.position.extentAfter < 10)
      Provider.of<ThreadUserProvider>(context, listen: false).getThread(Provider.of<Auth>(context, listen: false).token, context, isUpdate: true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;
    return Material(
      child: SafeArea(
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
              Expanded(
                child: SingleChildScrollView(
                  controller: _controller,
                  child: Column(
                    children: Provider.of<ThreadUserProvider>(context, listen: true).data.map((e) => Container(
                      key: Key("thread_conversation${e.id}"),
                      child: e.render(context),
                    )).toList(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}