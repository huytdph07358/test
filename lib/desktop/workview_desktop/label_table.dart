import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/desktop/workview_desktop/label.dart';
import 'package:workcake/models/models.dart';

class LabelTabel extends StatefulWidget {
  LabelTabel({
    Key? key,
    this.createLabel,
    this.closeTable
  }) : super(key: key);

  final createLabel;
  final closeTable;

  @override
  _LabelTabelState createState() => _LabelTabelState();
}

class _LabelTabelState extends State<LabelTabel> {
  final _labelNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _labelNameEditController = TextEditingController();
  final _descriptionEditController = TextEditingController();

  List colors = [
    "1CE9AE", "0E8A16", "0052CC", "5319E7", "FF2C65", "FBA704", "D93F0B", "B60205", "CECECE",
    "57B99D", "65C87A", "5097D5", "925EB1", "D63964", "EAC545", "D8823B", "D65745", "98A5A6",
    "397E6B", "448852", "346690", "693B86", "9F2857", "B87E2E", "9C481B", "8D3529", "667C89"
  ];
  Random random = new Random();
  var pickedColor;
  var pickedColorEdit;
  var selectLabel;

  @override
  void initState() { 
    super.initState();
    this.setState(() {
      pickedColor = random.nextInt(8);
    });
  }

  onCreateLabel() {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
    List labels = currentChannel["labels"];

    if (Utils.checkedTypeEmpty(_labelNameController.text)) {
      final index = labels.indexWhere((e) => e["name"] == _labelNameController.text);

      if (index == -1) {
        Map label = {
          "name": _labelNameController.text,
          "description": _descriptionController.text,
          "color_hex": colors[pickedColor].toString(),
          "issues": 0
        };

        Provider.of<Channels>(context, listen: false).createChannelLabel(token, currentWorkspace["id"], currentChannel["id"], label);
        _labelNameController.clear();
        _descriptionController.clear();
        widget.closeTable();
      }
    }
  }

  onUpdateLabel(label) {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;

    Map newLabel = {
      "id": label["id"],
      "name": _labelNameEditController.text,
      "description": _descriptionEditController.text,
      "color_hex": colors[pickedColorEdit].toString(),
      "issues": 0
    };

    Provider.of<Channels>(context, listen: false).updateLabel(token, currentWorkspace["id"], currentChannel["id"], newLabel);
    this.setState(() {
      selectLabel = null;
    });
  }

  calculateLabel(label) {
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    List labelsStatistical = currentChannel["labelsStatistical"] != null ? currentChannel["labelsStatistical"] : [];
    var openIssue = 0;
     for(var ls in labelsStatistical) {
       if(label["id"] == ls["id"]) {
        openIssue = ls["issue_count"];
       }
     }
     return openIssue;
  }
 
  @override
  Widget build(BuildContext context) {
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    List labels = currentChannel["labels"] != null ? currentChannel["labels"] : [];
    List labelsStatistical = currentChannel["labelsStatistical"] != null ? currentChannel["labelsStatistical"] : [];
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      width: (MediaQuery.of(context).size.width - 300),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        children: [
          if (widget.createLabel) Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            constraints: BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: isDark ? Color(0xff323F4B) : Color(0xffF6F8FA),
              border: Border.all(
                color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9)
              ),
              borderRadius: BorderRadius.circular(4.0)
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelDesktop(
                    labelName: Utils.checkedTypeEmpty(_labelNameController.text) ? _labelNameController.text : "Label preview",
                    color: int.parse("0xFF${colors[pickedColor]}")
                  ),
                  SizedBox(height: 18.0),
                  createOrEditLabel(context, null)
                ]
              ),
            )
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9)
              ),
              borderRadius: BorderRadius.circular(4.0)
            ),
            child: Column(
              children: [
                Container( 
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff323F4B) : Color(0xffF6F8FA),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(3.0), topRight: Radius.circular(3.0))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 4),
                        child: Text(
                          "${labels.length} labels",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 13.5
                          )
                        )
                      ),
                      Row(
                        children: [
                          Container(child: Text("Sort", style: TextStyle(color: isDark ? Colors.white.withOpacity(0.85) : Color(0xff1F2933), fontSize: 13.5))),
                          Icon(Icons.keyboard_arrow_down, color: isDark ? Colors.white.withOpacity(0.85) : Color(0xff1F2933), size: 18.0)
                        ],
                      )
                    ]
                  )
                ),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: (MediaQuery.of(context).size.height - (widget.createLabel ? 404 : 240))
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ...labels.map((label) => Container(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9)))
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        // width: (MediaQuery.of(context).size.width - 300 - 184)*3/4,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Expanded(
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: LabelDesktop(
                                                  labelName: selectLabel == label["id"] ? _labelNameEditController.text : label["name"], 
                                                  color: selectLabel == label["id"] ? int.parse("0xFF${colors[pickedColorEdit]}") : 
                                                  label["color_hex"] != null ? int.parse("0XFF${label["color_hex"]}") : 0xffffff,
                                                )
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                selectLabel == label["id"] ? _descriptionEditController.text : "${label["description"]}",
                                                style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700])
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(
                                            labelsStatistical.length > 0 ? "${calculateLabel(label)} open issues" : "",
                                            style: TextStyle(color: isDark ? Colors.white.withOpacity(0.85) : Color(0xff1F2933))
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 96,
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _labelNameEditController.text = label["name"];
                                          _descriptionEditController.text = label["description"];

                                          int indexColor = colors.indexWhere((e) => e == label["color_hex"]);
                                          this.setState(() {
                                            pickedColorEdit = indexColor != -1 ? indexColor : 0;
                                            selectLabel = label["id"];
                                          });
                                        },
                                        hoverColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        child: Text("Edit", style: TextStyle(color: Colors.lightBlue))
                                      ),
                                      SizedBox(width: 16),
                                      InkWell(
                                        onTap: () {
                                          showConfirmDialog(context, label["id"]);
                                        },
                                        hoverColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        child: Text("Delete", style: TextStyle(color: Colors.redAccent))
                                      ),
                                    ]
                                  )
                                )
                              ]
                            ),
                            if (selectLabel == label["id"]) Column(
                              children: [
                                SizedBox(height: 24),
                                createOrEditLabel(context, label)
                              ]
                            )
                          ]
                        )
                      ))
                    ]
                  ),
                )
              ]
            )
          )
        ]
      )
    );
  }

  Row createOrEditLabel(BuildContext context, label) {
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 4),
                      child: Text("Label name", style: TextStyle(fontWeight: FontWeight.w500))
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: isDark ? Color(0xff1F2933) : Colors.white,
                      ),
                      margin: EdgeInsets.only(left: 2),
                      child: TextFormField(
                        controller: label == null ? _labelNameController : _labelNameEditController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                          hintText: label == null ?  "Add name" : "${label["name"]}",
                          hintStyle: TextStyle(color: Color(0xff9AA5B1), fontWeight: FontWeight.w300, fontSize: 13.0),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9))),
                        ),
                        onChanged: (value) {
                          this.setState(() {});
                        }
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 4),
                      child: Text("Description", style: TextStyle(fontWeight: FontWeight.w500))
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? Color(0xff1F2933) : Colors.white,
                        borderRadius: BorderRadius.circular(4.0)
                      ),
                      margin: EdgeInsets.only(left: 2),
                      child: TextFormField(
                        onChanged: (value) {
                          this.setState(() {});
                        },
                        controller: label == null ? _descriptionController : _descriptionEditController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w300),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                          hintText: label == null ? "Description(Opt)" : "${label["description"]}",
                          hintStyle: TextStyle(color: Color(0xff9AA5B1), fontWeight: FontWeight.w300, fontSize: 13.0),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: isDark ? Color(0xff52606D) : Color(0xffCBD2D9))),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(width: 12.0),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 6),
                      child: Text("Color", style: TextStyle(fontWeight: FontWeight.w500))
                    ),
                    SizedBox(height: 7),
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          color: label == null ? Color(int.parse("0xFF${colors[pickedColor]}")) : Color(int.parse("0xFF${colors[pickedColorEdit]}")),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        height: 32.0,
                        width: 40.0,
                        padding: EdgeInsets.only(bottom: 1.0),
                        child: Icon(CupertinoIcons.eyedropper, size: 18.0, color: Colors.white,)
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => Dialog(
                            backgroundColor: Color(0xff323F4B),
                            elevation: 0,
                            child: Container(
                              height: 112,
                              width: 304,
                              padding: EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GridView.count(
                                    shrinkWrap: true,
                                    primary: false,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    crossAxisCount: 9,
                                    children: colors.map((e) => 
                                      InkWell(
                                        onTap: () {
                                          if (label == null) {
                                            this.setState(() {
                                              pickedColor = colors.indexWhere((color) => color == e);
                                            });
                                            Navigator.pop(context);
                                          } else {
                                            this.setState(() {
                                              pickedColorEdit = colors.indexWhere((color) => color == e);
                                            });
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(int.parse("0xFF$e")),
                                            borderRadius: BorderRadius.circular(4.0)
                                          ),
                                          height: 24.0,
                                          width: 24.0
                                        ),
                                      )
                                    ).toList(),
                                  )
                                ],
                              ),
                            ),
                          )
                        );
                      }
                    )
                  ]
                )
              )
            ]
          ),
        ),
        Container(
          width: 220,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                      side: BorderSide(color: Color(0xffFF7875))
                    ),
                  ),
                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16, horizontal: 24)),
                  backgroundColor: MaterialStateProperty.all(
                    isDark ? Colors.transparent : Colors.white
                  )
                ),
                // disabledColor: Color(0xff6989BF),
                onPressed: () {
                  if (label == null) {
                    _labelNameController.clear();
                    _descriptionController.clear();
                    widget.closeTable();
                  } else {
                    this.setState(() {
                      selectLabel = null;
                    });
                  }
                },
                child: Text("Cancel", style: TextStyle(color: Color(0xffFF7875)),),
              ),
              SizedBox(width: 10),
              TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.0),
                    )
                  ),
                  padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0)),
                  backgroundColor: MaterialStateProperty.all(isDark ? Color(0xff19DFCB) : Color(0xff2A5298))
                ),
                // disabledColor: Color(0xff6989BF),
                onPressed: () { 
                  if (label == null) {
                    onCreateLabel();
                  } else {
                    onUpdateLabel(label);
                  }
                },
                child: Text(label == null ? "Create label" : "Save changes", style: TextStyle(color: isDark ? Colors.black.withOpacity(0.85) : Colors.white.withOpacity(0.85)))
              ),
            ],
          ),
        )
      ]
    );
  }
}

showConfirmDialog(context, labelId) {
  final token = Provider.of<Auth>(context, listen: false).token;
  final currentChannel = Provider.of<Channels>(context, listen: false).currentChannel;
  final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
  
  onDeleteLabel() {
    Provider.of<Channels>(context, listen: false).deleteAttribute(token, currentWorkspace["id"], currentChannel["id"], labelId, "label");
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomDialogNew(
        title: "Delete Label", 
        content: "Are you sure want to delete label?\nThis action cannot be undone.",
        confirmText: "Delete Label",
        onConfirmClick: onDeleteLabel,
        quickCancelButton: true,
      );
    }
  );
}