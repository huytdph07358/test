import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/components/channel/channel_info.dart';
import 'package:workcake/models/models.dart';

class WorkspaceChannels extends StatefulWidget {
  WorkspaceChannels({Key? key}) : super(key: key);

  @override
  _WorkspaceChannelsState createState() => _WorkspaceChannelsState();
}

class _WorkspaceChannelsState extends State<WorkspaceChannels> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final channels = Provider.of<Channels>(context, listen: false).data;
    final currentWorkspace = Provider.of<Workspaces>(context).currentWorkspace;
    final workspaceChannels = channels
        .where((e) => e["workspace_id"] == currentWorkspace["id"])
        .toList();
    final isDark = auth.theme == ThemeType.DARK;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF2e3135) : Colors.white,
        title: Text("Workspace Channels",
            style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.grey[200] : Colors.grey[800])),
      ),
      body: Container(
        color: isDark ? Color(0xFF35393e) : Colors.grey[100],
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 40, left: 15, right: 20, bottom: 7),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("CHANNELS",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[800])),
                    Text("Edit",
                        style: TextStyle(
                            fontSize: 12.5,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[800])),
                  ]),
            ),
            Divider(
                color: isDark ? Colors.black87 : Colors.grey[400], height: 0.3),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: workspaceChannels.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        border: Border(
                      bottom: BorderSide(
                          color: isDark ? Colors.black87 : Colors.grey[400]!,
                          width: 0.3),
                    )),
                    child: Card(
                      elevation: 0,
                      color: isDark ? Color(0xFF2e3135) : Colors.white,
                      margin: EdgeInsets.all(0),
                      child: ListTile(
                        onTap: () async {
                          await Provider.of<Channels>(context, listen: false)
                              .selectChannel(auth.token, currentWorkspace["id"],
                                  workspaceChannels[index]["id"]);
                          Provider.of<Channels>(context, listen: false)
                              .onChangeLastChannel(currentWorkspace["id"],
                                  workspaceChannels[index]['id']);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChannelInfo(
                                      token: auth.token,
                                      workspaceId: currentWorkspace["id"],
                                      channelId: workspaceChannels[index]["id"],
                                      userId: auth.userId)));
                        },
                        leading: Icon(
                            workspaceChannels[index]['is_private']
                                ? Icons.lock
                                : CupertinoIcons.number,
                            size: 20,
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600]),
                        title: Text(workspaceChannels[index]['name'],
                            style: TextStyle(
                                fontSize: 17,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[800],
                                height: 0.8)),
                        trailing: Icon(Icons.keyboard_arrow_right,
                            color: isDark ? Colors.grey[400] : Colors.grey[800],
                            size: 24),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
