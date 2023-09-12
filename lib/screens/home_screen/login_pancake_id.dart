import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final flutterWebviewPlugin = new FlutterWebviewPlugin();
  var _onDestroy;
  var _onUrlChanged;
  var _onStateChanged;
  var token;

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    // flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // flutterWebviewPlugin.close();
    // _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
    // });

    // _onStateChanged =
    //     flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
    //     print("onStateChanged: ${state.type} ${state.url}");
    // });

    // // Add a listener to on url changed
    // _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
    //   if (mounted) {
    //     setState(() {
    //       if (url.startsWith("workcake://pancake.vn")) {
    //         RegExp regExp = new RegExp("authorization_code=(.*)");
    //         this.token = regExp.firstMatch(url)?.group(1);

    //         saveToken(token);
    //         Navigator.of(context)
    //             .pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);
    //         flutterWebviewPlugin.close();
    //       }
    //     });
    //   }
    // });
  }

  void saveToken(token) {
    Provider.of<Auth>(context, listen: false).loginPancakeId(token);
  }

  navigationBar(BuildContext context) {
    return CupertinoNavigationBar(
      backgroundColor: Colors.white,
      padding: EdgeInsetsDirectional.zero,
      leading: IconButton(
        alignment: Alignment.centerLeft,
        // padding: EdgeInsets.only(right: 64.0),
        icon: Icon(Icons.clear),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      trailing: IconButton(
        alignment: Alignment.centerLeft,
        icon: Icon(
          Icons.more_horiz,
          size: 20,
        ),
        onPressed: () {},
      ),
      middle: Container(
        child: Row(
          children: <Widget>[
            Expanded(flex: 1, child: SizedBox()),
            Expanded(
              flex: 3,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.lock, color: Colors.green, size: 16.0),
                  SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      "https://id.pancake.vn",
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.green,
                          fontWeight: FontWeight.w400),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 1, child: SizedBox()),
          ],
        ),
      ),
      // backgroundColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    // final clientId = Utils.clientId;
    // String loginUrl =
    //     "https://id.pancake.vn/oauth2/authorize?grant_type=code&client_id=$clientId&redirect_uri=workcake%3A%2F%2Fpancake.vn&scope=avatar,email,subscriptions";

    return Material(
      color: Colors.transparent,
      // child: CupertinoPageScaffold(
        // navigationBar: _navigationBar(context),
        // child: SafeArea(bottom: false, child: WebviewScaffold(hidden: true, url: loginUrl)),
      // ),
    );
  }
}
