import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/http_exception.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/hive/direct/direct.model.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';

class DmName extends StatefulWidget {
  DmName({Key? key, required this.id}) : super(key: key);
  final String id;

  @override
  _DmName createState() => _DmName();
}

class _DmName extends State<DmName> {
  final TextEditingController _controller = new TextEditingController();
  String newName = "";
  var loading = false;

  onChangeChannelInfo(DirectModel directMessage, token) async {
    var currentDm = Provider.of<DirectMessage>(context, listen: false).getCurrentDataDMMessage(directMessage.id);
    if (currentDm == null) return;
    if (currentDm.statusConversation == "creating") return;
    if (currentDm.statusConversation == "init") {
      Provider.of<DirectMessage>(context, listen: false).changeNameConvDummy(newName, directMessage.id);
      return Navigator.pop(context);
    }


    LazyBox box  = Hive.lazyBox('pairKey');
    final url =
        "${Utils.apiUrl}direct_messages/${directMessage.id}/update?token=$token&device_id=${await box.get("deviceId")}";
    setState(() {
      loading = true;
    });
    try {
      var response = await Dio().post(url, data: {"data": await Utils.encryptServer({"name": newName})});

      var dataRes = response.data;
      if (dataRes["success"]) {
        // channge name
        // update Provide
        Provider.of<DirectMessage>(context, listen: false).getDataDirectMessage(token, Provider.of<Auth>(context, listen: false).userId);
        directMessage.name = newName;
        Provider.of<DirectMessage>(context, listen: false).setSelectedDM(directMessage, token);
        Navigator.pop(context);
      }
      else{
        throw HttpException(dataRes["message"]);
      }
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
      sl.get<Auth>().showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<Auth>(context, listen: false).token;
    DirectModel? directMessage = Provider.of<DirectMessage>(context, listen: true).getModelConversation(widget.id);
    if (directMessage == null) return Container();

    return Scaffold(
      appBar: AppBar(
        title: Text("Direct message name"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (newName.length < 3 || newName.length > 20) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Icon(Icons.report, size: 25),
                        content:
                            Text("Channel name must be from 3-20 characters")));
              } else {
                onChangeChannelInfo(directMessage, token);
              }
            },
            child: loading
                ? Container(
                    width: 50,
                    alignment: Alignment.center,
                    child: Lottie.network(
                        "https://assets4.lottiefiles.com/datafiles/riuf5c21sUZ05w6/data.json"),
                  )
                : Center(
                    child: Text("Done",
                        style: TextStyle(fontSize: 18, color: Colors.white))),
          )
        ],
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            controller: _controller,
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(
              suffixIcon: Container(
                padding: EdgeInsets.only(top: 12),
                child: IconButton(
                  icon: Icon(Icons.cancel, size: 20, color: Colors.black38),
                  onPressed: () {
                    newName = "";
                    _controller.clear();
                  },
                ),
              ),
              labelText: 'Direct message name',
            ),
          )),
    );
  }
}
