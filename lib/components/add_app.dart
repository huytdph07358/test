import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

class AddApp extends StatefulWidget {
  const AddApp({ Key? key }) : super(key: key);

  @override
  _AddAppState createState() => _AddAppState();
}

class _AddAppState extends State<AddApp> {
  List listApp = [];

  @override
  void initState() {
    super.initState();
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    this.setState(() {
      listApp = currentWorkspace["app_ids"] ?? [];
    });
  }

  handleAddApp(token, app, currentWs) async {
    final currentMember = Provider.of<Workspaces>(context, listen: false).currentMember;
    if (currentMember["role_id"] <= 2) {
      if (!(currentWs['app_ids'] ?? []).contains(app['id'])) {
        List list = currentWs["app_ids"] ?? [];
        Map workspace = new Map.from(currentWs);
        if (!list.contains(app["id"])) {
          workspace["app_ids"] = list + [app["id"]];
        }
        setState(() => listApp = workspace["app_ids"]);
        await Provider.of<Workspaces>(context, listen: false).changeWorkspaceInfo(token, currentWs["id"], workspace);
      } else {
        showDialog(
          context: context,
          builder: (_) => SimpleDialog(
          children: <Widget>[
              new Center(child: new Container(child: new Text('App đã được thêm vào workspace này.')))
          ])
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (_) => SimpleDialog(
        children: <Widget>[
            new Center(child: new Container(child: new Text('Bạn không có đủ quyền để thực hiện thao tác')))
        ])
      );
    }
  }

  handleRemoveApp(token, app, currentWs) async {
    final currentMember = Provider.of<Workspaces>(context, listen: false).currentMember;
    if (currentMember["role_id"] <= 2) {
      if (currentWs['app_ids'].contains(app['id'])) {
        List list = currentWs["app_ids"] ?? [];
        Map workspace = new Map.from(currentWs);
        if (list.contains(app["id"])) {
          workspace["app_ids"].remove(app["id"]);
        }
        setState(() => listApp = workspace["app_ids"]);
        await Provider.of<Workspaces>(context, listen: false).changeWorkspaceInfo(token, currentWs["id"], workspace);
      } else {
        showDialog(
          context: context,
          builder: (_) => SimpleDialog(
          children: <Widget>[
              new Center(child: new Container(child: new Text('App đã bị xoá khỏi workspace này')))
          ])
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (_) => SimpleDialog(
        children: <Widget>[
            new Center(child: new Container(child: new Text('Bạn không có đủ quyền để thực hiện thao tác')))
        ])
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: true).currentWorkspace;
    final listActive = listAllApp.where((e) => listApp.contains(e["id"])).toList();
    final listDeactive = listAllApp.where((e) => !listApp.contains(e["id"])).toList();
    return Scaffold(
      backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Container(
          color: isDark ? Color(0xff02E2E2E) : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          "Add apps",
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
               if(listApp.length > 0) Container(
                margin: EdgeInsets.only(top: 16, left: 16),
                child: Text(
                  "Add Recent",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Color(0xffDBDBDB) : Colors.black87,
                    fontWeight: FontWeight.w700
                  )
                )
              ),
              if(listApp.length > 0) Expanded(
                child:  ListView.builder(
                  itemCount: listActive.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1, color: Color(0xffDBDBDB))
                        )
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    listActive[index]["avatar_app"].toString(),
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 12),
                                width: MediaQuery.of(context).size.width - 16*2 - 40 - 32 - 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(listActive[index]["name"].toString()),
                                    Text(listActive[index]["description"].toString(), overflow: TextOverflow.ellipsis,)
                                  ],
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: listActive[index]["id"] == 1 || listActive[index]["id"] == 3 || listActive[index]["id"] == 4 || listActive[index]["id"] == 13 ? () {
                              handleRemoveApp(auth.token, listActive[index], currentWorkspace);
                            } : null,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: Icon(PhosphorIcons.xCircle, size: 20, color: Color(0xffFF7875)),
                            ),
                          )
                        ],
                      )
                    );  
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 16, left: 16),
                child: Text(
                  "Recommend apps",
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Color(0xffDBDBDB) : Colors.black87,
                    fontWeight: FontWeight.w700
                  )
                )
              ),
              Expanded(
                child:  ListView.builder(
                  itemCount: listDeactive.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1, color: Color(0xffDBDBDB))
                        )
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4)
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.asset(
                                    listDeactive[index]["avatar_app"].toString(),
                                    width: 40,
                                    height: 40,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 12),
                                width: MediaQuery.of(context).size.width - 16*2 - 40 - 32 - 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(listDeactive[index]["name"].toString()),
                                    Text(listDeactive[index]["description"].toString(), overflow: TextOverflow.ellipsis)
                                  ],
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: listDeactive[index]["id"] == 1 || listDeactive[index]["id"] == 3 || listDeactive[index]["id"] == 4 || listDeactive[index]["id"] == 13 ? () {
                              handleAddApp(auth.token, listDeactive[index], currentWorkspace);
                            } : null,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
                                borderRadius: BorderRadius.circular(4)
                              ),
                              child: Icon(PhosphorIcons.plusCircle, size: 20,),
                            ),
                          )
                        ],
                      )
                    );
                  },
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}