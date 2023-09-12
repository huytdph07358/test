import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/custom_search_bar.dart';
import 'package:workcake/components/friends/friend_list.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';

import '../../generated/l10n.dart';

class AddApp extends StatefulWidget {
  AddApp({Key? key}) : super(key: key);

  @override
  _AddAppState createState() => _AddAppState();
}

class _AddAppState extends State<AddApp> {
  List apps = [];

  @override
  void initState() {
    // _controller.addListener(_scrollListener);
    super.initState();
    String token = Provider.of<Auth>(context, listen: false).token;
    getListApps(token);
  }
  
  getListApps(token)async {
    String url = "${Utils.apiUrl}app?token=$token";
    try {
      var response  =  await Dio().get(url);

      var resData  =  response.data;
      setState(() {
        apps =  resData["data"];
      });

      // print(resData);
    } catch (e) {
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }
    

  handelApp(installed, appId, token, channelId, workspaceId)async{
    try {
      String url  = "";
      if (!installed) url = "${Utils.apiUrl}app/$appId/install_channel?token=$token";
      else url = "${Utils.apiUrl}app/$appId/remove_channel?token=$token";
      await Dio().post(url, data: {
        "channel_id": channelId
      });
      Provider.of<Channels>(context, listen: false).loadCommandChannel(token, workspaceId, channelId);
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
   

  }

  @override
  Widget build(BuildContext context) {
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final appInChannels = Provider.of<Channels>(context, listen: true).appInChannels;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF3D3D3D) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0)
        )   
      ),
      padding: EdgeInsets.only(top: 20, left: 5, right: 5, bottom: 0),
      height: MediaQuery.of(context).size.height *.80,
      child: GestureDetector(
        onTap: () { FocusScope.of(context).unfocus(); },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.current.addAppToChannel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: isDark ? Color(0xFFDBDBDB) : Colors.grey[700])),
            Container(margin: EdgeInsets.only(top: 10, left: 0, right: 0), child: Divider(thickness: 1,)),
            apps.length > 0 ? Expanded(
              child: ListView.builder(
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  var installed  = appInChannels.where((element) {return element["app_id"] == apps[index]["id"];}).toList().length > 0;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: 60,
                       decoration: BoxDecoration(
                         color: isDark? Color(0xFF3D3D3D): Color(0xFFFFFFFF),
                         border: Border(
                           bottom:BorderSide(width: 0.5, color: Colors.grey),
                           )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                                height: 35,
                                  width: 35,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1890FF),
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                child: Text("${apps[index]["name"].substring(0,1)}",style: TextStyle(color: Color(0xFFFFFFFF)),),
                              ),
                              SizedBox(width: 10,),
                              Text("${apps[index]["name"]}",style: TextStyle(fontSize: 15,color:isDark? Color(0xFFDBDBDB):Color(0xFF2E2E2E),),),
                          ],
                        ),
                        Container(
                        child: TextButton(
                          onPressed: (){handelApp(installed, apps[index]["id"], auth.token, currentChannel["id"], currentWorkspace["id"]);},
                          child: Text(installed ? S.current.remove : S.current.install,style: TextStyle(fontSize: 15),),
                        ),
                      )
                      ],
                    ),
                  );
                },
              ),
            ) : FriendList(type: "toChannel")
          ]
        ),
      ),
    );
  }
}

class SearchBarChannel extends StatelessWidget {
  const SearchBarChannel({
    Key? key,
    this.onInviteToChannel
  }) : super(key: key);

  final onInviteToChannel;

  @override
  Widget build(BuildContext context) {
    // final TextEditingController _invitePeopleController = TextEditingController();
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final auth = Provider.of<Auth>(context);

    var _debounce;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: CustomSearchBar(
        placeholder: "Invite to ${currentChannel["name"]}",
        // controller: _invitePeopleController,
        onChanged: (value) {
          if (_debounce != null ? _debounce.isActive : false ) _debounce.cancel();
            _debounce = Timer(const Duration(milliseconds: 500), () {
            onInviteToChannel(auth.token, currentWorkspace["id"], currentChannel["id"], value);
          });
        },
      )
    );
  }
}
