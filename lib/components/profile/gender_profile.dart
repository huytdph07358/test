import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

class GenderProfile extends StatefulWidget {
  @override
  _GenderProfileState createState() => _GenderProfileState();
}

class _GenderProfileState extends State<GenderProfile> {
  final genders = ['Male', 'Female'];
  
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context).currentUser;
    String gender = currentUser["gender"];

    onChangeGender(index) async {
      gender = index == 0 ? "Male" : "Female";
      final auth = Provider.of<Auth>(context, listen: false);
      Map body;

      body = new Map.from(currentUser);
      body["gender"] = gender;
    
      await Provider.of<User>(context, listen: false)
        .changeProfileInfo(auth.token, body);
      await Provider.of<User>(context, listen: false)
        .fetchAndGetMe(auth.token);
      Navigator.pop(context);
    }

    renderGender(index) {
      if (gender != "") {
        if (index == 0 && gender == "Male" || index == 1 && gender == "Female") {
          return Icon(
            Icons.done,
            color: Theme.of(context).colorScheme.secondary
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title:Text("Gender"),
      ),
      body: ListView.builder(
        itemCount: genders.length,
        itemBuilder: (context, index) {
          return Container(
            decoration:
              BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.2, color: Colors.grey)
                )
              ),
            child: ListTile(
              title: Text(genders[index]),
              hoverColor : Colors.transparent,
              onTap: () {
                onChangeGender(index);
              },
            trailing: renderGender(index)
            ),
          );
        },
      ),
    );
  }
}