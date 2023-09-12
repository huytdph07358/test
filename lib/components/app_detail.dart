import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';

import '../generated/l10n.dart';
class AppDetail extends StatefulWidget {
  final appId;
  AppDetail({Key? key, @required this.appId});
  @override
  _AppDetailState createState() => _AppDetailState();
}
class _AppDetailState extends State<AppDetail> {
  Map dataApp = {"channels": [], "commands": [], "app": {}};
  double heightClientKey = 0;
  double heightCommands = 0;
  String _shortcut = "";
  String _requestUrl = "";
  String _description = "";
  bool _isChecked = false;
  List _commandParams = [
    {"key": ""}
  ];
  @override
  void initState() {
    super.initState();
    Timer.run(() async {
      final token = Provider.of<Auth>(context, listen: false).token;
      // get list Apps of user
      getDetailApp(token);
    });
  }
  getDetailApp(token) async {
    String url = "${Utils.apiUrl}app/${widget.appId}?token=$token";
    try {
      var response = await Dio().get(url);
      var resData = response.data;
      setState(() {
        dataApp = resData["data"];
      });
      if (resData["success"] == false) throw HttpException(resData["message"]);
    } catch (e) {
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      color: isDark ? Color(0xFF3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: isDark ? Color(0xFF3D3D3D) : Colors.grey[200],
          appBar: AppBar(
            backgroundColor: isDark ? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
                },
                icon: Icon(PhosphorIcons.arrowLeft)),
                title: Text("Superstore Demo",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          ),
          body: Stack(children: [
            Container(
              decoration: BoxDecoration(
                color: isDark ? Color(0xFF2E2E2E) : Colors.white,
                border: Border(top: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                ),
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Text(dataApp["app"] != null? dataApp["app"]["name"] ?? "": "",
                        style: TextStyle(fontSize: 30,fontWeight: FontWeight.w600,color: isDark? Colors.grey[400]: Colors.grey[700])),
                        Container(
                          padding:EdgeInsets.only(bottom: 20, left: 70, right: 70),
                          decoration: BoxDecoration(
                            color: isDark? Color(0xFF2E2E2E): Color(0xFFFFFFFF),
                              border: Border(
                                bottom:BorderSide(width: 1, color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)),
                              )
                            ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text("${dataApp["channels"].length}",
                                      style: TextStyle(fontSize: 30,color: !isDark? Color(0xFF242424): Color(0xffffffff)),
                                    ),
                                    Text("Channels installed",style: TextStyle(fontSize: 15,color: !isDark? Color(0xFF242424): Colors.white),
                                    )
                                  ],
                                )
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  // setState(() {
                                  //   heightCommands = heightCommands != 0 ? 0 : dataApp["commands"].length.toDouble() *50 + 20;
                                  //   }
                                  // );
                                },
                                child: Column(
                                  children: [
                                    Text("${dataApp["commands"].length}",style: TextStyle(fontSize: 30,color: !isDark ? Color(0xFF242424): Color(0xffffffff)),
                                    ),
                                    Text("Commands",style: TextStyle(fontSize: 15,color: !isDark ? Color(0xFF242424): Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.only(top: 10, bottom: 10, left: 8, right: 8),
                          height: heightCommands.toDouble(),
                          width: MediaQuery.of(context).size.width,
                          curve: Curves.fastOutSlowIn,
                          child: SingleChildScrollView(
                            child: Column(
                              children:dataApp["commands"].map<Widget>((command) {
                                var string = command["command_params"] != null? command["command_params"].map((e) {
                                  return "[${e["key"]}]";
                                  }
                                )
                                : [];
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 50,
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Column(
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Container(child: Text("/${command["short_cut"] ?? ""}  (${command["request_url"]})",
                                          overflow: TextOverflow.ellipsis,
                                          )
                                        ),
                                        Text("${string.join(" ")}",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Color(0xFF8C8C8C),
                                          fontWeight: FontWeight.w300,
                                          fontSize: 12))
                                        ]),
                                        Text(command["description"] ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Color(0xFF8C8C8C),fontWeight: FontWeight.w300,fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Container(
                          height: 55,
                          decoration: BoxDecoration(
                              color: isDark? Color(0xFF2E2E2E): Color(0xFFFFFFFF),
                              border: Border(bottom:BorderSide(width: 0.75,color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)),
                            )
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 10,),
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(PhosphorIcons.identificationCard,color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D),size: 20,
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Id",style: TextStyle(fontSize: 14,color: !isDark? Color(0xFF242424): Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Text(dataApp["app"] != null? dataApp["app"]["id"] ?? "": "",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              )
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        height: 55,
                        decoration: BoxDecoration(
                          color: isDark? Color(0xFF2E2E2E): Color(0xFFFFFFFF),
                          border: Border(bottom:BorderSide(width: 0.75,color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)),
                          )
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(PhosphorIcons.clock,color: isDark ? Color(0xFFDBDBDB): Color(0xFF3D3D3D),size: 20,
                                    ),
                                    SizedBox( width: 8,),
                                    Text(S.current.timeCreate,style: TextStyle(fontSize: 14,color: !isDark? Color(0xFF242424): Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(child: Text(
                                dataApp["app"] != null &&Utils.checkedTypeEmpty(dataApp["app"]["create_time"])
                                ? DateFormatter().renderTime(DateTime.parse(dataApp["app"]["create_time"]),type: "dd-MM-yyyy"): S.current.notSet,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: !isDark? Color(0xFF242424): Color(0xffffffff)),
                                )
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (heightClientKey == 0)heightClientKey = 300;
                              else heightClientKey = 0;
                              }
                            );
                          },
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: isDark? Color(0xFF2E2E2E) : Color(0xFFFFFFFF),
                                border: Border(bottom: BorderSide(width: 0.75, color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)),
                               )
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 10,),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(PhosphorIcons.userCircle,color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D),size: 20,
                                      ),
                                      SizedBox(width: 8,),
                                      Text("Client_key",style: TextStyle(fontSize: 14,color: !isDark? Color(0xFF242424) : Color(0xffffffff)),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Text((dataApp["app"] != null? dataApp["app"]["public_key"] ?? "": ""),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right))
                              ],
                            ),
                          ),
                        ),
                        AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            padding:EdgeInsets.only(top: 30, right: 10, left: 10),
                            height: heightClientKey,
                            curve: Curves.fastOutSlowIn,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.blueGrey.withOpacity(heightClientKey != 0 ? 1 : 0.5)),
                            child: Text((dataApp["app"] != null? dataApp["app"]["public_key"] ?? "": "")))
                      ],
                    ),
                  ],
                )
              ),
            Positioned(
              bottom: 30, left: 0, right: 0,
              child: Container(
                height: 45,
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xff1890FF),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(5),
                  color: Color(0xff1890FF), 
                ),
              child: Center(
                child: TextButton(
                  onPressed: (){
                    showCreateApps(context, onSuccessCreateCommands);
                  },
                  child: Text("Add commands",style: TextStyle(color: Color(0xffffffff)),),
                ),
              ),
            ),
          )
        ]),
      ),
    ),
  );
}

  onSuccessCreateCommands(app) {
    setState(() {
      dataApp["commands"] = [app] + dataApp["commands"];
    });
  }
  onAddParams() {
    _commandParams.add({"key": ""});
  }
  showCreateApps(context, onSuccessCreateApp) {
    onSave(shortcut, requestUrl, description) async {
      final token = Provider.of<Auth>(context, listen: false).token;
      _commandParams.removeWhere((e) => e["key"] == "");
      final paramsCommand = _isChecked? (_commandParams.length > 0 ? _commandParams : null): null;
      String url = "${Utils.apiUrl}app/${widget.appId}/commands?token=$token";
      try {
        var response = await Dio().post(url, data: {
          "request_url": requestUrl != null ? requestUrl.trim() : "",
          "short_cut": shortcut != null ? shortcut.trim() : "",
          "description": description != null ? description.trim() : "",
          "command_params": paramsCommand
        });
        var resData = response.data;
        if (resData["success"]) {
          onSuccessCreateApp(resData["data"]);
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          throw HttpException(resData["message"]);
        }
      } catch (e) {
        print(e);
        sl.get<Auth>().showErrorDialog(e.toString());
      }
    }
    showModalBottomSheet(
        isScrollControlled: true,
        enableDrag: true,
        context: context,
        shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        builder: (context) {
          final auth = Provider.of<Auth>(context, listen: true);
          final isDark = auth.theme == ThemeType.DARK;
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDark ? Color(0xFF3D3D3D) : Color(0xFFFFFFFF),
                  ),
                  // padding: EdgeInsets.symmetric(horizontal: 23),
                  height: MediaQuery.of(context).size.height * 0.85,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Column(children: [
                                    Container(
                                      padding: EdgeInsets.only(top: 20,bottom: 15,left: 15,right: 20),
                                      child: Row(
                                        mainAxisAlignment:MainAxisAlignment.start,
                                          children: [
                                            Text("Create commands",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 15,color: isDark? Colors.grey[300]: Colors.grey[700]))
                                         ]
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(width: 0.2,color: Colors.grey))),
                                    ),
                                  ]
                                ),
                              ),
                              SizedBox(height: 17,),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                    children: [
                                      Text('Shortcut',style: TextStyle(color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D),fontSize: 15,fontWeight: FontWeight.w500),
                                      ),
                                      Container(
                                        height: 65,
                                        padding:EdgeInsets.symmetric(vertical: 10),
                                        child: TextField(
                                          obscureText: true,
                                          onChanged: (value) {
                                            setState(() {
                                              _shortcut = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: isDark? Color(0xFF2E2E2E): Color(0xFFFAFAFA),
                                            contentPadding:EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(2)),
                                                borderSide: BorderSide(color: isDark? Colors.transparent: Color(0xffC9C9C9),style: BorderStyle.solid,width: 1)),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(2)),
                                                borderSide: BorderSide(color: isDark? Colors.transparent: Color(0xffC9C9C9),style: BorderStyle.solid, width: 1)),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all( Radius.circular(2)),
                                                borderSide: BorderSide(color: isDark? Colors.transparent: Color(0xffC9C9C9),style: BorderStyle.solid,width: 1)),
                                          ),
                                        ),
                                      ),
                                      Text('Request url',style: TextStyle(color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D),fontSize: 15,fontWeight: FontWeight.w500),
                                      ),
                                      Container(
                                        height: 65,
                                        padding:EdgeInsets.symmetric(vertical: 10),
                                        child: TextField(
                                          onChanged: (value) {
                                            setState(() {
                                              _requestUrl = value;
                                            }
                                          );
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: isDark ? Color(0xFF2E2E2E): Color(0xFFFAFAFA),
                                            contentPadding:EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)),
                                            borderSide: BorderSide(color: isDark ? Colors.transparent: Color(0xffC9C9C9),
                                            style: BorderStyle.solid, width: 1)),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(2)),
                                              borderSide: BorderSide(color: isDark ? Colors.transparent: Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)),
                                            borderSide: BorderSide(color: isDark ? Colors.transparent : Color(0xffC9C9C9),style: BorderStyle.solid,width: 1)),
                                          ),
                                        ),
                                      ),
                                      Text('Description',style: TextStyle(color: isDark ? Color(0xFFDBDBDB): Color(0xFF3D3D3D),fontSize: 15,fontWeight: FontWeight.w500),
                                      ),
                                      Container(
                                        height: 65,
                                        padding:EdgeInsets.symmetric(vertical: 10),
                                        child: TextField(
                                          onChanged: (value) {
                                            setState(() {
                                              _description = value;
                                            }
                                          );
                                        },
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: isDark ? Color(0xFF2E2E2E): Color(0xFFFAFAFA),
                                            contentPadding:EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            border: OutlineInputBorder( borderRadius: BorderRadius.all(Radius.circular(2)),
                                            borderSide: BorderSide(color: isDark? Colors.transparent: Color(0xffC9C9C9),style: BorderStyle.solid,width: 1)),
                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)),
                                            borderSide: BorderSide(color: isDark ? Colors.transparent : Color(0xffC9C9C9),style: BorderStyle.solid, width: 1)),
                                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(2)),
                                            borderSide: BorderSide(color: isDark? Colors.transparent: Color(0xffC9C9C9), style: BorderStyle.solid, width: 1)),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text("Params Commands",style: TextStyle(color: isDark? Color(0xFFDBDBDB): Color(0xFF3D3D3D),fontSize: 15,fontWeight: FontWeight.w500),
                                          )
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: CheckboxListTile(
                                              activeColor: isDark ? Color(0xFFFAAD14): Color(0xFF1890FF),
                                              checkColor: isDark ? Color(0xFF3D3D3D): Color(0xFFFFFFFF),
                                              value: _isChecked,
                                              onChanged: (value) {
                                                setState(() {
                                                  _isChecked =
                                                      value ?? _isChecked;
                                                }
                                              );
                                            },
                                          )
                                        ),
                                      ),
                                    ],
                                  ),
                                  _isChecked
                                  ? Container(
                                    child: Column(
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      children: [
                                        DataTable(
                                          columnSpacing: 10,
                                          dividerThickness: 0.001,
                                          checkboxHorizontalMargin:0.1,
                                          horizontalMargin: 0.001,
                                          headingRowHeight: 35,
                                          columns: [
                                            DataColumn(
                                              label: Text('Index',style: TextStyle(fontWeight:FontWeight.w400,fontSize: 15),)),
                                            DataColumn(
                                              label: Text('Params',style: TextStyle( fontWeight:FontWeight.w400,fontSize:15))),
                                              ],
                                              rows: _commandParams.map(((element) {
                                                print('item $element');
                                                var index =_commandParams.indexOf(element);
                                                return DataRow(
                                                  cells: <DataCell>[
                                                    DataCell(
                                                      Container(
                                                        alignment:Alignment.center,
                                                        height: 40,
                                                        width: 60,
                                                        decoration:BoxDecoration(
                                                          border: Border.all(width:1,color: isDark ? Color(0xFF2E2E2E): Color(0xffC9C9C9)),
                                                          color: isDark? Color(0xFF2E2E2E): Color( 0xFFFAFAFA),
                                                          borderRadius:BorderRadius.circular(2),),
                                                          child: Text("${index + 1}")),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            color: isDark ? Color(0xFF2E2E2E): Color(0xFFFAFAFA),
                                                            height: 40,
                                                            width: MediaQuery.of(context).size.width *0.76,
                                                            child:TextField(
                                                              onChanged:(value) {
                                                                print('element ${element["key"]}');
                                                                element["key"] =value.trim();
                                                                print('value $value');
                                                              },
                                                              decoration:InputDecoration(
                                                                suffixIcon:InkWell(
                                                                  onTap:() {
                                                                    print(_commandParams);
                                                                    _commandParams.removeAt(index);                                                                    
                                                                    setState(() {}
                                                                    );
                                                                  },
                                                                  child:Icon(PhosphorIcons.xCircle,size: 20,
                                                                  ),
                                                                ),
                                                                filled:true,
                                                                fillColor: isDark? Color(0xFF2E2E2E): Color(0xFFFAFAFA),
                                                                contentPadding: EdgeInsets.symmetric(vertical:4, horizontal:8),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius:BorderRadius.all(Radius.circular(2)),
                                                                    borderSide: BorderSide(
                                                                      color: isDark? Colors.transparent: Color(0xffC9C9C9),style: BorderStyle.solid,width: 1)),
                                                                    enabledBorder: OutlineInputBorder(
                                                                      borderRadius:BorderRadius.all(Radius.circular(2)),
                                                                      borderSide: BorderSide(
                                                                        color: isDark? Colors.transparent: Color(0xffC9C9C9),style: BorderStyle.solid,width: 1)),
                                                                    focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(2)),
                                                                    borderSide: BorderSide(
                                                                      color: isDark? Colors.transparent: Color(0xffC9C9C9),style: BorderStyle.solid,width: 1)),
                                                                  ),
                                                                ),
                                                              )
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  ),
                                                ).toList(),
                                              ),
                                              SizedBox(height: 15,),
                                              InkWell(
                                                onTap: () {onAddParams();
                                                setState(() {});
                                                },
                                                child: Container(
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    borderRadius:BorderRadius.circular(5),
                                                    border: Border.all(color: isDark? Color(0xFF1890FF): Color( 0xFFFAAD14))),
                                                      child: Row(
                                                        mainAxisAlignment:MainAxisAlignment.center,
                                                        children: [
                                                          Icon(Icons.add,color: isDark ? Color( 0xFF1890FF): Color(0xFFFAAD14),size: 20,),
                                                          Text("Add Params Commands", style: TextStyle(fontSize: 15,fontWeight:FontWeight.w500,color: isDark ? Color(0xFF1890FF): Color(0xFFFAAD14),
                                                         ))
                                                        ],
                                                     ),
                                                  ),
                                                ),
                                              ]
                                           )
                                         )
                                       : Container(),
                                    ],
                                  ),
                                ),
                              ]
                           ),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height / 9.5),
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 45,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(color: Color(0xFFFF7875), width: 1)),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context, rootNavigator: true).pop();
                                      setState(() {
                                        _commandParams = [
                                          {"key": ""}
                                        ];
                                        _isChecked = false;
                                      });
                                    },
                                    child: Text("Cancel",style: TextStyle( fontSize: 15,color: Color(0xFFFF7875)))),
                              ),
                            ),
                            SizedBox(width: 13,),
                            Expanded(
                              child: Container(
                                height: 45,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Color(0xFF1890FF),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: TextButton(
                                    onPressed: () {
                                      if (Utils.checkedTypeEmpty(_shortcut) &&Utils.checkedTypeEmpty(_requestUrl)) {
                                        onSave(_shortcut, _requestUrl,_description);
                                        setState(() {
                                          _commandParams = [{"key": ""}
                                          ];
                                          _isChecked = false;
                                        });
                                      }
                                    },
                                    child: Text("Create",style: TextStyle(fontSize: 15, color: Color(0xFFFFFFFF)))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
               );
            },
          );
        }
     );
  }
}
