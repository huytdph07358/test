import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/models/models.dart';

class Logs extends StatefulWidget {
  const Logs({
    Key? key,
    this.isNoti
  }) : super(key: key);

  final isNoti;

  @override
  State<Logs> createState() => _LogState();
}

class _LogState extends State<Logs> {

  List data  = [];
  List dataNoti = [];

  @override
  void initState(){
    super.initState();
    getLogs();
  }


  getLogs() async {
    LazyBox box = Hive.lazyBox('log');
    data  = (await Future.wait(box.keys.map((e) => box.get(e)))).reversed.toList();
    
    setState((){});
  }

  clearLog() async {
    LazyBox box = Hive.lazyBox('log');
    await box.clear();
    getLogs();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 62,
              decoration: BoxDecoration(
                color: isDark ? Color(0xff2E2E2E) : Colors.white,
                
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: isDark ? null : Border(bottom: BorderSide(color: Color(0xffDBDBDB))) ,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Icon(PhosphorIcons.arrowLeft, size: 20, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E)),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          // await Navigator.push(context, MaterialPageRoute(builder: (context) => DMInfo(id: widget.id)));
                        },
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Logs",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle( fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                        ),
                      ),
                    )),
                    InkWell(
                      onTap: clearLog,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Icon(PhosphorIcons.dotsThreeVerticalBold, color: isDark ? Color(0xffEDEDED) : Color(0xff5E5E5E))
                      ),
                    )
                  ],
                ),
              ),
            ),
            (widget.isNoti == true) ?  Expanded(
              child: ListView.builder(
                itemCount: dataNoti.length,
                itemBuilder: (context, index){
                  return Container(
                    margin: EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: (){
                        Clipboard.setData(ClipboardData(text: dataNoti[index].toString()));
                        Fluttertoast.showToast(msg: "Copied");
                      },
                      child: Container(
                        child: Text(dataNoti[index].toString())
                      )
                    )
                  );
                }
              )
            ) : Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index){
                  return Container(
                    margin: EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: (){
                        Clipboard.setData(ClipboardData(text: data[index].toString()));
                        Fluttertoast.showToast(msg: "Copied");
                      },
                      child: Container(
                        child: Text(data[index].toString()),
                      ),
                    ),
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}