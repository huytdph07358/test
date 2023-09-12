import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/date_formatter.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/profile/gender_profile.dart';
import 'package:workcake/models/models.dart';
import '../language.dart';

class MoreProfile extends StatefulWidget {

  @override
  _MoreProfileState createState() => _MoreProfileState();
}

class _MoreProfileState extends State<MoreProfile> {
  DateTime dateTime = DateTime.now().add(new Duration(days: -7300));
  List listTimezone = [-12, -11, -10, -09.5, -09, -08, -07, -06, -05, -04, -03.5, -02, -01, 00.0, 01, 02, 03, 03.5, 04, 04.5, 05, 05.5, 06, 06.5, 07, 08, 09, 09.5, 10, 10.5, 11, 12, 12.5, 13, 14];

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context).currentUser;
    String dateString = Utils.checkedTypeEmpty(currentUser["date_of_birth"])
        ? DateFormatter().renderTime(DateTime.parse(currentUser["date_of_birth"]), type: "dd-MM-yyyy")
        : "Not set"; 
    // String timezone = currentUser["timezone"] != null ? currentUser["timezone"] : "7";

    onChangeBirthday() async {
      final auth = Provider.of<Auth>(context, listen: false);
      Map body;
      int date = dateTime.toUtc().millisecondsSinceEpoch~/1000 + 86400;

      body = new Map.from(currentUser);
      body["date_of_birth"] = date;
    
      await Provider.of<User>(context, listen: false).changeTimezone(auth.token, body);
      await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
      Navigator.pop(context);
    }

    // onChangeTimezone() async {
    //   final auth = Provider.of<Auth>(context, listen: false);
    //   Map body;

    //   body = new Map.from(currentUser);
    //   body["timezone"] = timezone;
    
    //   await Provider.of<User>(context, listen: false)
    //     .changeProfileInfo(auth.token, body);
    //   await Provider.of<User>(context, listen: false)
    //     .fetchAndGetMe(auth.token);
    //   Navigator.pop(context);
    // }

    renderGender() {
      final gender = currentUser["gender"];
      var string;

      if (gender == null) {
        string = "Not set";
      } else if (gender == "0") {
        string = "Male";
      } else if (gender == "1") {
        string = "Female";
      } else {
        string = gender;
      }

      return string;
    }

    return Scaffold(
      appBar: AppBar(
        title:Text("More"),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.2, color: Colors.grey)
                )
              ),
              child: ListTile(
                contentPadding: EdgeInsets.only(right: 20),
                onTap:() {
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => GenderProfile())
                  );
                },
                title: Text("Gender"), 
                trailing: Container(
                  child: Container(
                    child: Text(
                      renderGender(),
                      style: TextStyle(color: Colors.grey)
                    )
                  )
                ), 
              ),
            ),
            Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.2, color: Colors.grey)
                )
              ),
              child: ListTile(
                contentPadding: EdgeInsets.only(right: 20),
                onTap:() {
                  showCupertinoModalPopup<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return _buildBottomPicker(
                        Stack(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: (){ }, 
                                  child: Text("", style: TextStyle(color: Colors.blue))
                                ),
                                TextButton(
                                  onPressed: (){ 
                                    onChangeBirthday();
                                  }, 
                                  child: Text("Ok", style: TextStyle(color: Colors.blue))
                                )
                              ]
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 35),
                              child: CupertinoDatePicker(
                                minimumYear: 1900,
                                maximumYear: 2020,
                                mode: CupertinoDatePickerMode.date,
                                initialDateTime: dateTime,
                                onDateTimeChanged: (DateTime newDateTime) {
                                  if (mounted) {
                                    setState(() => dateTime = newDateTime);
                                  }
                                },
                              ),
                            )
                          ]
                        ),
                      );
                    },
                  );
                },
                title: Text("Date of birth"),
                trailing: Container(
                child: Container(
                  child: currentUser["date_of_birth"] != null ? Text(
                    '$dateString', 
                    style: TextStyle(color: Colors.grey)
                  ) : Icon(Icons.arrow_forward_ios, size: 14)
                )
              ), 
              ),
            ),

            Container(
              padding: EdgeInsets.all(1),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.2, color: Colors.grey)
                )
              ),
              child: ListTile(
                contentPadding: EdgeInsets.only(right: 20),
                onTap: () {
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Language())
                  );
                },
                title: Text('Language & Region'),
                trailing: Container(
                  child: Container(
                    child: Text(
                      currentUser["locale"] == 'vi' ? "Vietnamese" : "English", 
                      style: TextStyle(color: Colors.grey)
                    )
                  )
                ), 
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildBottomPicker(Widget picker) {
  return Container(
    height: 280,
    color: CupertinoColors.white,
    child: DefaultTextStyle(
      style: const TextStyle(
        color: CupertinoColors.black,
        fontSize: 10,
      ),
      child: GestureDetector(
        onTap: () {},
        child: SafeArea(
          top: false,
          child: picker
        ),
      ),
    ),
  );
}
