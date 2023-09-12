import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

class ListIcons extends StatefulWidget {
  const ListIcons({
    Key? key,
    this.surroundTextSelection,
    this.isDark,
    this.getImage
  }) : super(key: key);

  final surroundTextSelection;
  final isDark;
  final getImage;

  @override
  _ListIconsState createState() => _ListIconsState();
}

class _ListIconsState extends State<ListIcons> {
  List text = [];

  openFileSelector() async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    try {
      List<AssetEntity> resultList = await Provider.of<Work>(context, listen: false).openFileSelector(context);
      List results = await Utils.handleFileData(resultList);
      results = results.where((e) => e.isNotEmpty).toList();

      for (var i = 0; i < results.length; i++) {
        text.add("\n![Uploading ${results[i]["name"]}...]()");
      }
      widget.surroundTextSelection(text.join("\n"), "", "img");
      uploadFile(results, token, currentWorkspace);

    } on Exception catch (e) {
      print("$e Cancel");
    }
  }

  uploadFile(resultList, token, currentWorkspace) async {
    for (var file in resultList) {
      final context = Utils.globalContext;
      var dataUpload = await Provider.of<Work>(context!, listen: false).getUploadData(file);
      var response = await Provider.of<Work>(context, listen: false).uploadImage(token, currentWorkspace["id"], dataUpload, dataUpload["mime_type"], (t) {});
      widget.getImage(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Container(
      color: isDark ? Color(0xff3f3f3f) : Color(0xffeff0f3),
      height: 56,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              icon: Icon(CupertinoIcons.bold, size: 24),
              onPressed: () {
                widget.surroundTextSelection("**", "**", "bold");
              },
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 2.5),
              width: 35,
              child: IconButton(
                color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
                icon: Icon(Icons.code, size: 19),
                onPressed: () {
                  widget.surroundTextSelection("`", "`", "code");
                },
              ),
            ),
          Container(
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              icon: Icon(CupertinoIcons.italic, size: 24),
              onPressed: () {
                widget.surroundTextSelection("_", "_", "italic");
              },
            ),
          ),
          Container(
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              icon: Icon(CupertinoIcons.link, size: 20),
              onPressed: () {
                widget.surroundTextSelection("[", "](url)", "link");
              }
            )
          ),
          Container(
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              icon: Icon(CupertinoIcons.list_bullet, size: 24),
              onPressed: () {
                widget.surroundTextSelection("- ", "", "listDash");
              }
            )
          ),
          Container(
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              icon: Icon(CupertinoIcons.checkmark_square, size: 24),
              onPressed: () {
                widget.surroundTextSelection("- [ ] ", "", "check");
              }
            )
          ),
          Container(
            padding: EdgeInsets.only(top: 2.5),
            child: IconButton(
              color: isDark ? Colors.white70 : Color.fromRGBO(0, 0, 0, 0.65),
              icon: Icon(Icons.image_outlined, size: 26),
              onPressed: () {
                openFileSelector();
              },
            ),
          )
        ]
      ),
    );
  }
}