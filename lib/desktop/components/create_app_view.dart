import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';

enum RadioOptionApp { Workspace, Channel }

class CreateAppView extends StatefulWidget {
  final onSuccessCreateApp;

  CreateAppView({Key? key, @required this.onSuccessCreateApp});
  @override
  _CreateAppViewState createState() => _CreateAppViewState();
}

class _CreateAppViewState extends State<CreateAppView> {
  var _nameChannel;
  RadioOptionApp _radioOptionApp = RadioOptionApp.Channel;

  onSave(appName, option) async {
    final token  =  Provider.of<Auth>(context, listen: false).token;
    final url = "${Utils.apiUrl}app?token=$token";
    try {
      var response  = await Dio().post(url, data: {
        "name": appName,
        "is_workspace": option == RadioOptionApp.Channel ? false : true
      });

      var resData = response.data;
      if (resData["success"]){
        widget.onSuccessCreateApp(resData["data"]);
        Navigator.of(context, rootNavigator: true).pop("Discard");
      }
    } catch (e) {
      print(e);
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  Widget _myRadioButton({var title, var value, var onChanged}) {
    return RadioListTile(
      value: value,
      groupValue: _radioOptionApp,
      onChanged: onChanged,
      title: Text(title, style: TextStyle(fontFamily: "Roboto", fontSize: 14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    
    return Container(
      height: 330,
      width: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: Offset(0, 3),
            blurRadius: 8
          )
        ]
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? Color(0xff52606D) : Color(0xff52606D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              )
            ),
            height: 40,
            width: MediaQuery.of(context).size.width,
            
            child: Center(child: Text("CREATE APP", style: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white))),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Color(0xff1F2933) : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                )
              ),
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("App Name", style: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w600, fontSize: 14)),
                        SizedBox(height: 8),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: isDark ? Color(0xff323F4B) : Color(0xffCBD2D9)),
                            borderRadius: BorderRadius.circular(2),
                            color: isDark ? Colors.transparent : Color(0xffF5F7FA)
                          ),
                          child: TextFormField(
                            autofocus: true,
                            onChanged: (value) {
                              setState(() {
                                _nameChannel = value;
                              });
                            },
                            style: TextStyle(color: isDark ? Color(0xffF5F7FA) : Color(0xff243B53), fontSize: 14, fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xffCBD2D9) : Color(0xffF5F7FA), style: BorderStyle.solid, width: 0.5)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(2), bottomLeft: Radius.circular(2)), borderSide: BorderSide(color: isDark ? Color(0xffCBD2D9) : Color(0xffF5F7FA), style: BorderStyle.solid, width: 0.5)),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(child: Text("Option:", style: TextStyle(fontFamily: "Roboto", fontWeight: FontWeight.w600, fontSize: 14))),
                        SizedBox(height: 8),
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _myRadioButton(
                                  title: "Workspace",
                                  value: RadioOptionApp.Workspace,
                                  onChanged: (newValue) {
                                    setState(() => _radioOptionApp = newValue);
                                  },
                                ),
                              ),
                              Expanded(
                                child: _myRadioButton(
                                  title: "Channel",
                                  value: RadioOptionApp.Channel,
                                  onChanged: (newValue) {
                                    print(newValue);
                                    setState(() => _radioOptionApp = newValue);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 32),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    color: isDark ? Color(0xff1F2933) :Color(0xffFFF1F0),
                                    child: TextButton(
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
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel", style: TextStyle(color: Color(0xffFF7875), fontSize: 14, fontWeight: FontWeight.w400)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: isDark ? Color(0xff19DFCB) : Color(0xff2A5298),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    onSave(_nameChannel, _radioOptionApp);
                                  },
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(vertical: 16, horizontal: 22)
                                    ),
                                  ),
                                  child: Text("Create app", style: TextStyle(color: isDark ? Color(0xff1F2933) : Colors.white)),
                                ),
                              )
                            ],
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