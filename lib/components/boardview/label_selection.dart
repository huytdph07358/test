import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

import 'CardItem.dart';

class LabelSelection extends StatefulWidget {
  const LabelSelection({
    Key? key,
    required this.card,
  }) : super(key: key);

  final CardItem card;

  @override
  State<LabelSelection> createState() => _LabelSelectionState();
}

class _LabelSelectionState extends State<LabelSelection> {
  bool onCreateLabel = false;
  int selectedColor = 0;
  String labelTitle = "";
  TextEditingController controller = TextEditingController();

  addLabelToCard(label) {
    CardItem card = widget.card;
    final token = Provider.of<Auth>(context, listen: false).token;
    int index = card.labels.indexWhere((e) => e == label["id"]);

    this.setState(() {
      if (index == -1) {
      card.labels.add(label["id"]);
      } else {
        card.labels.removeAt(index);
      }  
    });
    Provider.of<Boards>(context, listen: false).addOrRemoveAttribute(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, label["id"], "label");
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: true);
    final token = auth.token;
    final isDark = auth.theme == ThemeType.DARK;
    final selectedBoard = Provider.of<Boards>(context, listen: true).selectedBoard;
    final labels = selectedBoard["labels"];
    List colors = ["61bd4f", "f2d600", "ff9f1a", "eb5a46", "c377e0", "0079bf", "00c2e0", "51e898", "ff78cb", "344563"];
    CardItem card = widget.card;

    return onCreateLabel ?
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            height: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      onCreateLabel = false;
                    });
                  },
                  child: Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey[600])
                ),
                Container(
                  padding: EdgeInsets.only(top: 4),
                  child: Center(child: Text("Labels", style: TextStyle(color: Colors.grey[700])))
                ),
                SizedBox(width: 16)
              ]
            ),
          ),
          Divider(thickness: 1.5, indent: 8, endIndent: 8),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            alignment: Alignment.centerLeft,
            child: Text("Title", style: TextStyle(color: Colors.grey[600]))
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            height: 36,
            child: CupertinoTextField(
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              onChanged: (value) {
                this.setState(() {
                  labelTitle = value;
                });
              },
              padding: EdgeInsets.only(top: 6, left: 10, bottom: 4),
              placeholderStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
            )
          ),
          SizedBox(height: 6),
          Container(
            margin: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text("Select a color", style: TextStyle(color: Colors.grey[600]))
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Wrap(
              children: colors.map((e) {
                int index = colors.indexWhere((ele) => ele == e);

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedColor = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Color(int.parse("0xFF$e")),
                      borderRadius: BorderRadius.circular(3)
                    ),
                    height: 32,
                    width: 48,
                    child: Icon(Icons.check, color: selectedColor == index ? Colors.grey[300] : Colors.transparent),
                  ),
                );
              }).toList()
            ),
          ),
          SizedBox(height: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Color(int.parse("0xFF${colors[selectedColor]}")),
              borderRadius: BorderRadius.circular(3)
            ),
            height: 32,
            child: Text("${labelTitle != "" ? labelTitle : "Please input title"}", style: TextStyle(color: Colors.grey[50]), overflow: TextOverflow.ellipsis),
          ),
          SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              width: 82,
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(3)
              ),
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  if (labelTitle.trim() != "") {
                    await Provider.of<Boards>(context, listen: false).createLabel(token, card.workspaceId, card.channelId, card.boardId, labelTitle, colors[selectedColor]);
                    setState(() {
                      onCreateLabel = false;
                      labelTitle = "";
                    });
                  }
                }, 
                child: Text("Create", style: TextStyle(color: Colors.white)))
            )
          )
        ]
      ) : Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.only(top: 12, bottom: 6),
          child: Center(child: Text("Labels", style: TextStyle(color: Colors.grey[700])))
        ),
        Divider(thickness: 1.5),
        Container(
          padding: EdgeInsets.only(left: 12, right: 12, top: 6),
          child: CupertinoTextField(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(4)
            ),
            padding: EdgeInsets.only(top: 8, left: 10, bottom: 6),
            placeholder: "Search labels",
            placeholderStyle: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600])
          ),
        ),
        SizedBox(height: 16),
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 12),
          child: Text("Labels", style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600]))
        ),
        Container(
          height: 36,
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: isDark ? Colors.grey[700] : Colors.grey[200],
          child: TextButton(
            onPressed: () {
              this.setState(() {
                selectedColor = int.parse(Utils.getRandomNumber(1));
                onCreateLabel = true;
              });
            }, 
            child: Text("Create a new label", style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w400))
          )
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 10),
            itemCount: labels.length,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        addLabelToCard(labels[index]);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.centerLeft,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(int.parse("0xFF${labels[index]["color_hex"]}")),
                          borderRadius: BorderRadius.circular(3)
                        ),
                        margin: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(labels[index]["name"], style: TextStyle(color: Colors.grey[50]), overflow: TextOverflow.ellipsis)),
                            Icon(Icons.check, color: card.labels.contains(labels[index]["id"]) ? Colors.grey[50] : Colors.transparent, size: 18)
                          ]
                        )
                      )
                    )
                  ),
                  SizedBox(width: 20),
                  InkWell(
                    onTap: () async {

                    },
                    child: Icon(Icons.edit_outlined, color: Colors.grey[500], size: 18)
                  )
                ]
              );
            }
          )
        )
      ]
    );
  }
}
