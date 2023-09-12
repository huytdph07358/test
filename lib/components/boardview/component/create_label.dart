import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/models/models.dart';

import 'label_item.dart';

class CreateLabel extends StatefulWidget {
  const CreateLabel({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateLabel> createState() => _CreateLabelState();
}

class _CreateLabelState extends State<CreateLabel> {
  List colors = [
    "5CDBD3", "389E0D", "1890FF", "531DAB", "F759AB", "FAAD14", "D46B08", "FF7875", "D9DBEA", 
    "13C2C2", "B7EB8F", "096DD9", "722ED1", "C41D7F", "FFD666", "FA8C16", "F5222D", "8F90A6",
    "08979C", "237804", "0050B3", "B37FEB", "9E1068", "D48806", "FFA940", "A8071A", "6B7588"
  ];
  int selectedColor = 0;
  TextEditingController labelTitleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<Auth>(context, listen: true).token;
    final selectedBoard = Provider.of<Boards>(context, listen: true).selectedBoard;

    return Container(
      color: Color(0xff3D3D3D),
      height: MediaQuery.of(context).size.height - 48,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color(0xff2E2E2E),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(PhosphorIcons.arrowLeft, size: 18, color: Color(0xffDBDBDB))
                ),
                Container(
                  padding: EdgeInsets.only(top: 4),
                  child: Center(child: Text("New Labels", style: TextStyle(color: Color(0xffDBDBDB), fontSize: 15, fontWeight: FontWeight.w500)))
                ),
                InkWell(
                  onTap: () {
                    if (labelTitleController.text.trim() != "") {
                      Provider.of<Boards>(context, listen: false).createLabel(token, selectedBoard["workspace_id"], selectedBoard["channel_id"], selectedBoard["id"], labelTitleController.text, colors[selectedColor]);
                    }
                    Navigator.pop(context);
                  }, 
                  child: Text("Create", style: TextStyle(color: Color(0xffFAAD14)))
                )
              ]
            )
          ),
          Divider(thickness: 1, color: Color(0xff5E5E5E), height: 1),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: LabelItem(label: {'name': labelTitleController.text != "" ? labelTitleController.text : "Please input title", 'color_hex': colors[selectedColor]}),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text("Title", style: TextStyle(fontWeight: FontWeight.w500))
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            child: CupertinoTextField(
              onChanged: (value) {
                this.setState(() {});
              },
              controller: labelTitleController,
              style: TextStyle(color: Palette.defaultTextDark),
              placeholder: "Name label",
              decoration: BoxDecoration(
                color: Color(0xff2E2E2E),
                border: Border.all(
                  color: Color(0xff5E5E5E)
                ),
                borderRadius: BorderRadius.circular(4)
              ),
              padding: EdgeInsets.only(left: 12),
              placeholderStyle: TextStyle(fontSize: 14, color: Color(0xffA6A6A6)),
            )
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Text("Select a color:", style: TextStyle(fontWeight: FontWeight.w500))
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: colors.map((e) {
                int index = colors.indexWhere((ele) => ele == e);

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedColor = index;
                    });
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width/11.1,
                    height: MediaQuery.of(context).size.width/11.1,
                    decoration: BoxDecoration(
                      color: Color(int.parse("0xFF$e")),
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: Icon(PhosphorIcons.checkCircle, color: selectedColor == index ? Colors.grey[300] : Colors.transparent)
                  )
                );
              }).toList()
            )
          )
        ]
      )
    );
  }
}