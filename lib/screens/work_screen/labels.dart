import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/desktop/workview_desktop/label.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/work_screen/issues.dart';

class Labels extends StatefulWidget {
  Labels({
    Key? key,
    this.issues
  }) : super(key: key);

  final issues;

  @override
  _LabelsState createState() => _LabelsState();
}

class _LabelsState extends State<Labels> {
  @override
  Widget build(BuildContext context) {
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    final labels = currentChannel["labels"] != null ? currentChannel["labels"] : [];
    
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Center(child: Text("Labels", style: TextStyle(fontSize: 18))),
        actions: <Widget>[
          Icon(Icons.more_horiz_outlined, size: 28),
          SizedBox(width: 16),
          Icon(Icons.add, size: 28),
          SizedBox(width: 16)
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(42),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 8),
                width: MediaQuery.of(context).size.width - 30,
                height: 42,
                child: SearchBar()
              )
            ]
          )
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: labels.length,
          itemBuilder: (BuildContext context, int index) {
            var colorHex = int.parse("0XFF${labels[index]["color_hex"]}");
            var labelName = labels[index]["name"];

            return Row(
              children: [
                SizedBox(width: 18),
                Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.4, color: Colors.grey[400]!))
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  width: MediaQuery.of(context).size.width - 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LabelDesktop(
                        color: colorHex, 
                        labelName: labelName
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 16),
                        child: Wrap(
                          children: [
                            Text("Edit", style: TextStyle(color: Colors.blue)),
                            SizedBox(width: 24),
                            Text("Delete", style: TextStyle(color: Colors.red))
                          ]
                        )
                      )
                    ]
                  )
                )
              ]
            );
          }
        )
      )
    );
  }
}