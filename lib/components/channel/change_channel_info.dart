import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';

class ChangeChannelInfo extends StatefulWidget {
  final type;
  final channelId;
  
  ChangeChannelInfo({
    Key? key, 
    this.type, 
    this.channelId
  }) : super(key: key);

  @override
  _ChangeChannelInfoState createState() => _ChangeChannelInfoState();
}

class _ChangeChannelInfoState extends State<ChangeChannelInfo> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final TextEditingController _controller = new TextEditingController();
    final currentWorkspace = Provider.of<Workspaces>(context).currentWorkspace;
    final channels = Provider.of<Channels>(context, listen: false).data;
    final index = channels.indexWhere((e) => e['id'] == widget.channelId);
    final currentChannel = channels[index];
    final type = widget.type;
    final isDark = auth.theme == ThemeType.DARK;

    _controller.text = currentChannel["name"];

    onChangeChannelInfo() async {
      final auth = Provider.of<Auth>(context, listen: false);
      final listChannelGeneral = Provider.of<Channels>(context, listen: false).channelGeneral;
      final index = listChannelGeneral.indexWhere((e) => e['workspace_id'] == currentChannel["id"]);

      if (index == -1) {
        await Provider.of<Channels>(context, listen: false).changeChannelInfo(auth.token, currentWorkspace["id"], currentChannel["id"], currentChannel);
        Navigator.pop(context);
      }
    }

    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: isDesktop ? false : true,
      //   title: Text("Channel type"),
      //   actions: <Widget>[
      //     type == 1 ? TextButton(
      //       onPressed: () {
      //         if (currentChannel["name"].length < 3 || currentChannel["name"].length > 20) {
      //           showDialog(
      //             context: context,
      //             builder: (BuildContext context) => CustomDialogNew(
      //               title: "Err !!",
      //               content: "Channel name must be from 3-20 characters"
      //             )
      //           );
      //         } else {
      //           onChangeChannelInfo();
      //         }
      //       },
      //       child: Center( child: Text("Done", style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.grey) ) ),
      //     ) : Text("")
      //   ],
      // ),
      body: type == 1 ? Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: TextFormField(
          controller: _controller,
          onChanged: (value) {
            if (value != "newsroom") {
              currentChannel["name"] = value;
            }
          },
          decoration: InputDecoration(
            suffixIcon: Container(
              padding: EdgeInsets.only(top: 12),
                child: IconButton(
                icon: Icon(Icons.cancel, size: 20, color: Colors.black38),
                onPressed: () {
                  currentChannel["name"] = "";
                  _controller.clear();
                },
              ),
            ),
            labelText: 'Channel name',
          ),
        ),
      ) :  type == 2 ? Container(
        color: isDark ? Color(0xFF36393f) : Colors.white,
        child: Column(children: <Widget>[
          Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(
              color: Colors.black12,
              width: 0.5
            ))),
            child: ListTile(
              onTap: (){
                currentChannel["is_private"] = false;
                onChangeChannelInfo();
              },
              title: Text(S.current.regular), trailing: currentChannel["is_private"] == false ? Icon(Icons.check) : null)
            ),
          Container(child: ListTile(
            onTap: (){
              currentChannel["is_private"] = true;
              onChangeChannelInfo();
            },
            title: Text(S.current.private), trailing: currentChannel["is_private"] == true ? Icon(Icons.check) : null)
          )
        ],),
      ) : Column(children: <Widget>[
          Container(
              padding: EdgeInsets.all(10),
              child: Text(
              S.current.channelType,
              style: TextStyle(
                color: isDark ? Colors.white : Color(0xff6B6B6B),
                fontSize: 18,
                fontWeight: FontWeight.w500
              )
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(
              color: isDark ? Colors.black12 : Colors.white54,
              width: 0.5
            ))),
            child: ListTile(
              onTap: (){
                currentChannel["kanban_mode"] = true;
                onChangeChannelInfo();
              },
              title: Text("Kanban mode"), trailing: currentChannel["kanban_mode"] == true ? Icon(Icons.check) : null)
            ),
          Container(child: ListTile(
            onTap: (){
              currentChannel["kanban_mode"] = false;
              onChangeChannelInfo();
            },
            title: Text("Dev mode"), trailing: currentChannel["kanban_mode"] == false ? Icon(Icons.check) : null)
          )
        ]
      )
    );
  }
}
