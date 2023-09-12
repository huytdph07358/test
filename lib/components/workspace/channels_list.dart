import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/components/channel/channel_info.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';
class ChannelsList extends StatefulWidget {
  ChannelsList({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ChannelsListState();
}
class _ChannelsListState extends State<ChannelsList> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final channels = Provider.of<Channels>(context, listen: false).data;
    final currentWorkspace = Provider.of<Workspaces>(context).currentWorkspace;
    final workspaceChannels = channels.where((e) => e["workspace_id"] == currentWorkspace["id"]).toList();
    final isDark = auth.theme == ThemeType.DARK;
    return Scaffold(
      backgroundColor: isDark ? Color(0xFF3D3D3D) : Color(0xffEDEDED),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10),),
            color: isDark ? Color(0xff2E2E2E) : Color(0xffffffff),
          ),
          child: Column(
            children: [
              Container(
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: isDark ? Color(0xff2E2E2E) : Color(0xffffffff),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        child: InkWell(
                          onTap: () {Navigator.pop(context);},
                          child: Icon(
                            PhosphorIcons.arrowLeft,
                            size: 20,
                          ),
                        ),
                      ),
                      Container(
                        padding:EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        child: Text(S.current.channelsList,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            )),
                      ),
                      Container(
                        width: 30,
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                            margin: EdgeInsets.only(right: 20),
                            child: Icon(
                              PhosphorIcons.pencilLine,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: workspaceChannels.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: isDark? Color(0xFF4C4C4C): Color(0xFFDBDBDB),width: 1),
                      )),
                      child: InkWell(
                        onTap: () async {
                          await Provider.of<Channels>(context, listen: false).selectChannel(auth.token,currentWorkspace["id"],workspaceChannels[index]["id"]);
                          Provider.of<Channels>(context, listen: false).onChangeLastChannel(currentWorkspace["id"],workspaceChannels[index]['id']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) => 
                            ChannelInfo(
                              token: auth.token,
                              workspaceId: currentWorkspace["id"],
                              channelId: workspaceChannels[index]["id"],
                              userId: auth.userId,
                              )
                            )
                          );
                        },
                        child: Container(
                          height: 55,
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          color:isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    workspaceChannels[index]['is_private']? PhosphorIcons.lock: CupertinoIcons.number,
                                    size: 18,
                                    color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D),
                                  ),
                                  SizedBox( width: 8,),
                                  Text(workspaceChannels[index]['name'],
                                   style: TextStyle(fontSize: 15,color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D),height: 0.8)),
                                ],
                              ),
                              Icon(Icons.keyboard_arrow_right,color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D),size: 26),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
