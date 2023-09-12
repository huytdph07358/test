import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

class ProfileInfo extends StatefulWidget {
  final type;
  ProfileInfo({this.type});

  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  onChangeProfileInfo(currentUser) async {
    final auth = Provider.of<Auth>(context, listen: false);

    await Provider.of<User>(context, listen: false).changeProfileInfo(auth.token, currentUser);
    await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context).currentUser;
    final type = widget.type;
    final TextEditingController _controller = new TextEditingController();
    _controller.text = type == 1 ? currentUser["full_name"] : currentUser["phone_number"];

    String pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
    RegExp regExp = new RegExp(pattern);

    return Scaffold(
      appBar: AppBar(
        title:Text(type == 1 ? 'Nickname' : 'Phone Number'),
        actions: <Widget>[
          TextButton(
            onPressed: () { 
              if (type == 1 && (currentUser["full_name"].length < 3 || currentUser["full_name"].length > 20)) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Icon(Icons.report, size: 25),
                    content: Text("Nickname must be from 3-20 characters")
                  )
                );
              } else if (type == 2) {
                if (!regExp.hasMatch(currentUser["phone_number"])) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => CupertinoAlertDialog(
                      title: Icon(Icons.report, size: 25),
                      content: Text("Please input valid phone number")
                    )
                  );
                }  else {
                  onChangeProfileInfo(currentUser);
                }
              } else {
                onChangeProfileInfo(currentUser);
              }
             },
            child: Center(
              child: Text(
                "Done",
                style: TextStyle(fontSize: 18, color: Color(0xff6b6b6b)),
              )
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            controller: _controller,
            onChanged: (value) {
              if (type == 1) {
                currentUser["full_name"] = value;
              } else if (type == 2) {
                currentUser["phone_number"] = value;
              }
            },
            decoration: InputDecoration(
              suffixIcon: Container(
                padding: EdgeInsets.only(top: 12),
                  child: IconButton(
                  icon: Icon(Icons.cancel, size: 20, color: Colors.black38),
                  onPressed: () {
                    if (type == 1) {
                      currentUser["full_name"] = "";
                    } else {
                      currentUser["phone_number"] = "";
                    }
                    _controller.clear();
                  },
                ),
              ),
              labelText: type == 1 ? 'Limit 20 characters' : 'Phone Number',
            ),
          ),
        ),
      ),
    );
  }
}