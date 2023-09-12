import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';
import '../../generated/l10n.dart';
import '../custom_dialog_new.dart';

class ChangeLanguage extends StatefulWidget {
  ChangeLanguage({
    Key? key,  
  }) : super(key: key);

  @override
  _ChangeLanguage createState() => _ChangeLanguage();
}

class _ChangeLanguage extends State<ChangeLanguage> {
  var body;
  _updateLanguage() async {
    try{
      final auth = Provider.of<Auth>(context, listen: false);
      var response = await Provider.of<User>(context, listen: false).changeProfileInfo(auth.token, body);
      if (response == null) return;
      if (response["success"] && mounted) {
        Provider.of<User>(context, listen: false).changeProfileInfo(auth.token, body);
        Provider.of<Auth>(context, listen: false).locale = body['locale'];
        Navigator.pop(context);
      } else {
     }
    } catch (e){
      showDialog(
        context: context, 
        builder: (BuildContext context) {
          return CustomDialogNew(
            title: "Oops!!!",
            content: S.current.thereWasAnErrorInUpdating,
          );
        }
      );
    }
    
  }
  void initState() {
    super.initState();
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    body = new Map.from(currentUser);
  }
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff3D3D3D) : Color(0xffFAFAFA),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.only(left: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      body["locale"] = "vi";
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Vietnamese", style: TextStyle(fontSize: 15, color:  isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E))),
                      Container(
                        child: Radio(
                          activeColor: isDark ? Color(0xffFAAD14) : Color(0xff1890FF),
                          value: "vi", 
                          groupValue: body["locale"], 
                          onChanged: (value) {
                            setState(() {
                              body["locale"] = "vi";
                            });
                          }),
                      )
                    ],
                  ),
                )
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 0.25,
              color: isDark ? Color.fromARGB(255, 244, 241, 241) : Color(0xffBDBDBD)
            ),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? Color(0xff3D3D3D) : Color(0xffFAFAFA),
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.only(left: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      body["locale"] = "en";
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("English", style: TextStyle(fontSize: 15, color:  isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E))),
                      Container(
                        child: Radio(
                          activeColor: isDark ? Color(0xffFAAD14) : Color(0xff1890FF),
                          value: "en", 
                          groupValue: body["locale"],
                          onChanged: (value) {
                            setState(() {
                              body["locale"] = "en";
                            });
                          }),
                      )
                    ],
                  ),
                )
              )
            ),
            Container(
              height: 0.25,
              color: isDark ? Color.fromARGB(255, 244, 241, 241) : Color(0xffBDBDBD)
            ),
            TextButton(
              child: Container(
                height: 40,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                color: Color(0xff1890FF),
                borderRadius: BorderRadius.circular(5),
              ),
                child: Text(S.current.save, style: TextStyle(fontSize: 17, color: Color(0xffFFFFFF), fontWeight: FontWeight.w400))), 
              onPressed: _updateLanguage,
            )
          ],
        ),
      ),
    );
  }
}
