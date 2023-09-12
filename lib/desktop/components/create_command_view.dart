import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';

class CreateCommandView extends StatefulWidget {
  final onSuccessCreateCommand;
  final appId;

  CreateCommandView({
    Key? key,
    @required this.onSuccessCreateCommand,
    @required this.appId
  });
  @override
  _CreateCommandViewState createState() => _CreateCommandViewState();
}

class _CreateCommandViewState extends State<CreateCommandView> {
  var _shortcut;
  var _requestUrl;
  var _description;

  bool _isChecked = false;
  List _commandParams = [
    {
      "key": ""
    }
  ];

  onAddParams() {
    _commandParams.add(
      {
        "key": ""
      }
    );
  }

  onRemoveParams() {
    int index = _commandParams.length;

    if (index > 1) {
      _commandParams.remove(
        _commandParams[index-1]
      );
    } 
  }

  onSave(shortcut, requestUrl, description) async {
      final token  =  Provider.of<Auth>(context, listen: false).token;

      _commandParams.removeWhere((e) => e["key"] == "");
      final paramsCommand = _isChecked ? (_commandParams.length > 0 ? _commandParams : null) : null;

      String url = "${Utils.apiUrl}app/${widget.appId}/commands?token=$token";
      try {
        var response  = await Dio().post(url, data: {
          "request_url": requestUrl != null ? requestUrl.trim() : "",
          "short_cut": shortcut != null ? shortcut.trim() : "",
          "description": description != null ? description.trim() : "",
          "command_params": paramsCommand
        });

        var resData = response.data;
        if (resData["success"]){
          widget.onSuccessCreateCommand(resData["data"]);
          Navigator.of(context, rootNavigator: true).pop();
        }
        else{
          throw HttpException(resData["message"]);
        }

      } catch (e) {
        print(e);
        sl.get<Auth>().showErrorDialog(e.toString());
      }
    }

  @override
  Widget build(BuildContext context) {
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    
    return Container(
      // height: MediaQuery.of(context).size.height * 0.6,
      width: MediaQuery.of(context).size.width * 0.6,
      child: Column(
        children: [
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width,
            color: Color(0xff52606D),
            child: Center(child: Text("CREATE COMMANDS", style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: "Roboto", fontWeight: FontWeight.w600))),
          ),
          Expanded(
            child: Container(
              color: isDark ? Color(0xff1F2933) : Colors.white,
              padding: EdgeInsets.all(24),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Shortcut:", style: TextStyle(fontSize: 14, fontFamily: "Roboto", fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Color(0xff323F4B) : Color(0xffCBD2D9)),
                      borderRadius: BorderRadius.circular(2),
                      color: isDark ? Colors.transparent : Color(0xffF5F7FA)
                    ),
                    child: TextFormField(
                      autofocus: true,
                      onChanged: (value) {
                        setState(() {
                          _shortcut = value;
                        });
                      },
                      style: TextStyle(color: isDark ? Color(0xffF5F7FA) : Color(0xff243B53), fontSize: 14, fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4), style: BorderStyle.solid, width: 0.5)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4), style: BorderStyle.solid, width: 0.5)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("Request URL:", style: TextStyle(fontSize: 14, fontFamily: "Roboto", fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Color(0xff323F4B) : Color(0xffCBD2D9)),
                      borderRadius: BorderRadius.circular(2),
                      color: isDark ? Colors.transparent : Color(0xffF5F7FA)
                    ),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _requestUrl = value;
                        });
                      },
                      style: TextStyle(color: isDark ? Color(0xffF5F7FA) : Color(0xff243B53), fontSize: 14, fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4), style: BorderStyle.solid, width: 0.5)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4), style: BorderStyle.solid, width: 0.5)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("Description:", style: TextStyle(fontSize: 14, fontFamily: "Roboto", fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? Color(0xff323F4B) : Color(0xffCBD2D9)),
                      borderRadius: BorderRadius.circular(2),
                      color: isDark ? Colors.transparent : Color(0xffF5F7FA)
                    ),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _description = value;
                        });
                      },
                      style: TextStyle(color: isDark ? Color(0xffF5F7FA) : Color(0xff243B53), fontSize: 14, fontWeight: FontWeight.w400),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4), style: BorderStyle.solid, width: 0.5)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xff1F2933) : Color.fromRGBO(228, 231, 235, 0.4), style: BorderStyle.solid, width: 0.5)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text("Params Commands:", style: TextStyle(fontSize: 14, fontFamily: "Roboto", fontWeight: FontWeight.w600)),
                      Transform.scale(
                        scale: 0.9,
                        child: Checkbox(
                          onChanged: (newValue) {
                            this.setState(() { _isChecked = newValue ?? false; });
                          },
                          value: _isChecked
                        ),
                      )
                    ],
                  ),
                  _isChecked ? Container(
                    height: 130,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () {
                                onAddParams();
                                setState(() {});
                              },
                              child: Icon(Icons.add, color: isDark ? Colors.grey[300] : Colors.black54)
                            ),
                            TextButton(
                              onPressed: () {
                                onRemoveParams();
                                setState(() {});
                              },
                              child: Icon(Icons.remove, color: isDark ? Colors.grey[300] : Colors.black54)
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text("Index:",  style: TextStyle(fontSize: 14, fontFamily: "Roboto", fontWeight: FontWeight.w600)),
                            Text("Params:",  style: TextStyle(fontSize: 14, fontFamily: "Roboto", fontWeight: FontWeight.w600))
                          ],
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _commandParams.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 200,
                                padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                                margin: EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xffCBD2D9)),
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    index < 9 ? Text("0${index + 1}",  style: TextStyle(fontSize: 14, fontFamily: "Roboto")) : Text("${index + 1}",  style: TextStyle(fontSize: 14, fontFamily: "Roboto", fontWeight: FontWeight.w600)),
                                    Container(
                                      child: CupertinoTextField(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: isDark ? Color(0xff52606D) : Color(0xff9AA5B1), width: 1)
                                        ),
                                        autofocus: true,
                                        onChanged: (value) {
                                          _commandParams[index]["key"] = value.trim();
                                        },
                                      ),
                                    ),
                                  ]
                                )
                              );
                            },
                          ),
                        )
                      ],
                    )
                  ) : Container(height: 130,),
                  Expanded(child: Container()),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              color: isDark ? Color(0xff1F2933) : Color(0xffFFF1F0),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    _commandParams = [{
                                      "key": ""
                                    }];
                                    _isChecked = false;
                                  });
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      side: BorderSide(color: Color(0xffFF7875), width: 1),
                                      borderRadius: BorderRadius.circular(2)
                                    ),
                                  ),
                                  padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(vertical: 16, horizontal: 24)
                                  )
                                ),
                                child: Text("Cancel", style: TextStyle(color: Color(0xffFF7875), fontSize: 14, fontWeight: FontWeight.w400)),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                          color: isDark ? Color(0xff19DFCB) : Color(0xff2A5298),
                          child: TextButton(
                            onPressed: () {
                              if (Utils.checkedTypeEmpty(_shortcut) && Utils.checkedTypeEmpty(_requestUrl)) {
                                onSave(_shortcut, _requestUrl, _description);
                                setState(() {
                                  _commandParams = [{
                                    "key": ""
                                  }];
                                  _isChecked = false;
                                });
                              }
                            },
                            child: Text("Create command", style: TextStyle(color: isDark ? Color(0xff1F2933) : Colors.white)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}