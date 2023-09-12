import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';

class Language extends StatelessWidget {
  final languages = [
    'English',
    'Vietnamese'
  ];

  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context).currentUser;
    int idx = currentUser["locale"] == 'en' ? 0 : 1;

    onChangeTimezone(index) async {
      idx = index;
      final auth = Provider.of<Auth>(context, listen: false);
      Map body;

      body = new Map.from(currentUser);
      body["locale"] = index == 1 ? 'vi' : 'en';
    
      await Provider.of<User>(context, listen: false).changeProfileInfo(auth.token, body);
      await Provider.of<User>(context, listen: false).fetchAndGetMe(auth.token);
      switch (index) {
        case 0:
          S.load(Locale('en'));
          break;
        case 1:
          S.load(Locale('vi'));
          break;
        default:
          S.load(Locale('en'));
          break;
      }
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).language),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          return Container(
            decoration:
              BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.2, color: Colors.grey)
                )
              ),
            child: ListTile(
              title: Text(languages[index]),
              onTap: () {
                onChangeTimezone(index);
              },
              trailing: index == idx
                ? Icon(
                    Icons.done,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                : null,
            ),
          );
        },
      ),
    );
  }
}
