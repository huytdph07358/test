import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';


class AddFriendUsername extends StatefulWidget {
  @override
  _AddFriendUsernameState createState() => _AddFriendUsernameState();

}

class _AddFriendUsernameState extends State<AddFriendUsername> {
  TextEditingController controller = TextEditingController();
  var usernameTag;
  bool hoverSendButton = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User>(context, listen: false).currentUser;
    final token = Provider.of<Auth>(context).token;
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    

    sendFriendRequest() async {
      final usernameTag = controller.text;
      final data = await Provider.of<User>(context,listen: false).sendFriendRequestTag(usernameTag, token);

      showDialog(
        context: context,
        builder: (_) => CustomFriendDialog(
          title: data["success"] ? "Successful" : "Unsuccessful",
          string: data["message"],
          data: data,
        )
      );
    }

    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.only(left: 16),
            child: Text(
              S.current.youWillNeedBoth,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 13, height: 1.5, color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D)),
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
            color: isDark ? Color(0xff2E2E2E) : Color(0xffF3F3F3),
            borderRadius: BorderRadius.circular(5),
            ),
            margin: EdgeInsets.only(left: 16, right: 16),
            width: MediaQuery.of(context).size.width,
            child: CupertinoTextField(
              autofocus: false,
              placeholder: "Username#0000",
              placeholderStyle: TextStyle(color: isDark ? Color(0xffA6A6A6) : Color(0xff5E5E5E), fontSize: 15, fontFamily: "Roboto"),
              style: TextStyle(color: isDark ? Color(0xffEDEDED) : Color(0xff3D3D3D), fontSize: 15, fontFamily: "Roboto"),
              padding: EdgeInsets.symmetric(vertical: 11, horizontal: 12),
              clearButtonMode: OverlayVisibilityMode.editing,
              controller: controller,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: isDark ? Color(0xff2E2E2E) : Color(0xffF3F3F3),
              ),
              onChanged: (value) {
                // RegExp(r'^[0-9]+$').hasMatch(value);
                setState(() {
                  usernameTag = value;
                });
                // if (_debounce?.isActive ?? false) _debounce.cancel();
                // _debounce = Timer(const Duration(milliseconds: 500), () {
                  
                // });
              }
            ),
          ),
          SizedBox(height: 12),
          Container(
            margin: EdgeInsets.only(left: 16),
            child: Text.rich(TextSpan(
              text: S.current.yourUsernameAndTag,
              style: TextStyle(color: isDark ? Color(0xffC9C9C9) : Color(0xff5E5E5E), fontSize: 13),
              children: [
                TextSpan(text: "${currentUser["username"]}#${currentUser["custom_id"]}", style: TextStyle(fontWeight: FontWeight.w700))
              ]
            )),
          ),
          SizedBox(height: 20),
          MouseRegion(
            onEnter: (value) => setState(() => hoverSendButton = true),
            onExit: (value) => setState(() => hoverSendButton = false),
            child: InkWell(
              onTap: () => controller.text.length > 0 ? sendFriendRequest() : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Color(0xff1890FF),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16),
                height: 40,
                child: Center(child: Text(S.current.sendFriendRequest, style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500,)))
              ),
            ),
          )
        ],
      )
    );
  }
}
class CustomFriendDialog extends StatefulWidget {
  final title;
  final string;
  final onSaveString;
  final data;

  CustomFriendDialog({key, this.title, this.string, this.onSaveString, this.data}) : super(key: key);

  @override
  _CustomFriendDialogState createState() => _CustomFriendDialogState();
}

class _CustomFriendDialogState extends State<CustomFriendDialog> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    String _value = widget.string;
    final auth = Provider.of<Auth>(context, listen: true);
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      child: AlertDialog(
        insetPadding: EdgeInsets.all(20),
        contentPadding: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), ),
        backgroundColor: isDark ? Color(0xff3D3D3D) : Color(0xffDBDBDB),
        content: Container(
          height: 239,
          width: 438,
          // decoration: BoxDecoration(border: Border.all(width: 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    widget.data["success"] ? Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Icon(Icons.check_circle_rounded , color: Color(0xff27AE60) , size: 90,),
                    )
                    : Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Icon(Icons.cancel , color: Color(0xffEB5757) , size: 90,),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20,),
                      child: Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                        Text(
                         widget.title,
                         textAlign: TextAlign.center,
                         style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 24, color: isDark ? Colors.grey[300] : Colors.black))
                        ]
                      ),
                      // decoration:  BoxDecoration(border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey))),
                    ),
                    Container(
                      child: Text(_value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5 ,color: !isDark ? Color.fromRGBO(0, 0, 0, 0.65):Colors.white70),),
                    ),
                  ]
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context, rootNavigator: true).pop("Discard"),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(10),
                  width: 260,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0xff1890FF) ,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text("Done", style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600,))
                ),
              ),
              
            ]
          ),
        ),
      ),
    );
  }
}