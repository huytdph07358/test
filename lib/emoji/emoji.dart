import 'dart:async';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as Img;
import 'package:provider/provider.dart';
import 'package:simple_tooltip/simple_tooltip.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/emoji/dataSourceEmoji.dart';
import 'package:workcake/emoji/itemEmoji.dart';
import 'package:workcake/emoji/searchEmoji.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/service_locator.dart';

class Emoji extends StatefulWidget {
  final onClose;
  final onSelect;
  final workspaceId;

  Emoji({
    Key? key,
    @required this.onClose,
    @required this.onSelect,
    this.workspaceId
  }) : super(key: key);

  _EmojiState createState() => _EmojiState();
}

class _EmojiState extends State<Emoji> {
  ScrollController scrollController = new ScrollController();
  List names = [];
  String selectedCategory = 'smileys';
  Map number = {};
  double heightTitle = 30;
  final _emojiController = StreamController<ItemEmoji?>.broadcast(sync: false);
  List customEmoji = [];
  List recentEmoji = [];
  String select= "recent";
  

  List listCategories = [
    {"name": "smileys", "id": "smileys", "avatar": "😀", "num": dataSourceEmojis.where((element) => element["category"] == "smileys").toList().length},
    {"name": "animals", "id": "animals", "avatar": "🙈", "num":  dataSourceEmojis.where((element) => element["category"] == "animals").toList().length},
    {"name": "foods", "id": "foods", "avatar": "🍉", "num":  dataSourceEmojis.where((element) => element["category"] == "foods").toList().length},
    {"name": "travel", "id": "travel", "avatar": "🚣", "num":  dataSourceEmojis.where((element) => element["category"] == "travel").toList().length},
    {"name": "activities", "id": "activities", "avatar": "🕴", "num":  dataSourceEmojis.where((element) => element["category"] == "activities").toList().length},
    {"name": "objects", "id": "objects", "avatar": "💌", "num":  dataSourceEmojis.where((element) => element["category"] == "objects").toList().length},
    {"name": "symbols", "id": "symbols", "avatar": "💘", "num":  dataSourceEmojis.where((element) => element["category"] == "symbols").toList().length},
    {"name": "flags", "id": "flags", "avatar": "🏁", "num": dataSourceEmojis.where((element) => element["category"] == "flags").toList().length},
  ];

  @override
  initState(){
    super.initState();
    getRecent();
    var data = Provider.of<Workspaces>(context, listen: false).data;
    if (widget.workspaceId != null){
      int index = data.indexWhere((element) => element["id"] == widget.workspaceId);
      if(index != -1) {
        customEmoji = (data[index]["emojis"] as List);
      }
    }
  }

  List searchEmoji(String value){
    return (dataSourceEmojis + customEmoji + recentEmoji).where((element) => element["id"].toString().contains(value))
      .map((emo) => ItemEmoji(emo["id"] ?? emo["emoji_id"], emo["name"], emo["value"], emo["skin"], emo["custom"], emo["type"], emo["url"], onSelectEmoji, onHoverEmojiItem)).toList();        
  }

  getRecent(){
    var box = Hive.box('recentEmoji');
    var recentList = box.get(widget.workspaceId);
    if (recentList == null){
      recentList = defaultEmoji;
      box.put(widget.workspaceId, recentList);
    }
    recentEmoji = recentList;
    listCategories = [] +  [{
      "name": 'recent', "id": "recent", "avatar": "🕙", "num": recentEmoji.length
    }] + listCategories;
  }

  caculatorHeightItem(category) {
    int index  = listCategories.indexWhere((element) => element["id"] == category);
    if (index == -1) return 0;
    double row = listCategories[index]["num"]  / ((MediaQuery.of(context).size.width)~/35);
    if (row % 1 == 0) return row.toDouble();
    return (row - row % 1 + 1).toDouble();
  }

  renderListCategory() {
    // render listCategories  va baao 
    var isDark  = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;
    return Row(
      children: (listCategories).map((e) => 
        HoverItem(
          key: Key("catergory_${e["name"]}"),
          child: InkWell(
            onTap: () {
            setState(() {
            select = e["name"];
          });
          scrollController.animateTo(
            caculatorScrollTo(e["name"]),
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,);
          },
            child: Container(
              width: 45,
              height: 50,
              child: Column(
                children: [
                  Expanded(child: Text(e["avatar"], style: TextStyle(fontSize: 18),)),
                  SizedBox(height: 10,),
                  isDark ? Container(
                    decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide( 
                        color: select == e["name"] ? Color(0xffFAAD14): Colors.transparent,
                        width: 3.0,
                    ), ) 
                  ),):
                  Container(
                    decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide( 
                        color: select == e["name"] ? Color(0xff1890FF): Colors.transparent,
                        width: 3.0,
                    ), ) 
                  ),)
                ],
              ) 
            ),
          ),
          colorHover: Color(0xFFbae7ff)
        )
      ).toList(),
    );
  }
  caculatorScrollTo(categoryName){
    if (categoryName == "Often used") return 0.0;
    int index  =  listCategories.indexWhere((element) => element["name"] == categoryName);
    double result  = 0;
    for(int i = 0; i < index; i++){
      result += caculatorHeightItem(listCategories[i]["name"]) * 35 + 30; 
    }
    return result;
  }
  createEmoji() {
    widget.onClose();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(0),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 500),
            child: SingleChildScrollView(
              child: Wrap(
                children: [CreateEmoji()],
              ),
            ),
          )
        );
      }
    );
  }
  onSelectEmoji(ItemEmoji emo) {
    widget.onSelect(emo);
    widget.onClose();
    // update recentList
    var index = recentEmoji.indexWhere((element) => element["id"] == emo.id);
    if (index == -1){
      var box  = Hive.box('recentEmoji');
      recentEmoji = [] + [emo.toJson()] + recentEmoji;
      // toi da 30 
      try {
        recentEmoji = recentEmoji.sublist(0, 30);
      } catch (e) {
      }
      box.put(widget.workspaceId, recentEmoji);
    }
  }
  onHoverEmojiItem(ItemEmoji? emo){
    _emojiController.add(emo);
  }
  Widget renderListCategoryItem(category, context) {
    var isDark  = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;
    // List emojiWorksapce = Utils.checkedTypeEmpty(Provider.of<Workspaces>(context, listen: true).currentWorkspace["emojis"]) ? Provider.of<Workspaces>(context, listen: true).currentWorkspace["emojis"] : [];
    // List dataEmoji = Utils.checkedTypeEmpty(Provider.of<Workspaces>(context, listen: true).emojis) ? Provider.of<Workspaces>(context, listen: true).emojis :  [];

    return ListView.builder(
      itemCount: listCategories.length,
      controller: scrollController,
      itemBuilder: (context, index) {
        final e = listCategories[index];

        if (e["name"] == "Create" ) return Container();
        List<ItemEmoji> dataCate = dataSourceEmojis.where((element) => element["category"] == e["id"])
          .map((emo) => ItemEmoji(emo["id"], emo["name"], emo["value"], emo["skin"], emo["custom"], emo["type"], emo["url"], onSelectEmoji, onHoverEmojiItem)).toList();
          if(e["id"] == "custom"){
            dataCate = customEmoji.map((emo) => 
              ItemEmoji(emo["emoji_id"], emo["name"], emo["value"], emo["skin"], emo["custom"], emo["type"], emo["url"], onSelectEmoji, onHoverEmojiItem)
            ).toList();
          }
        if(e["id"] == "recent"){
            dataCate = recentEmoji.map((emo) => 
              ItemEmoji(emo["emoji_id"] ?? emo["id"], emo["name"], emo["value"], emo["skin"], emo["custom"], emo["type"], emo["url"], onSelectEmoji, onHoverEmojiItem)
            ).toList();
          }
      return StickyHeader(
        header: Container(
          color:isDark ? Color(0xFF3D3D3D) : Color(0xFFFFFFFF),
          height: heightTitle,
          width: double.infinity,
          padding: EdgeInsets.only(left: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(e["name"], style: TextStyle(fontWeight: FontWeight.bold))),
        ),
        content: Wrap(
          alignment: WrapAlignment.start,
          children: dataCate.map<Widget>((emo) {
            return Container(
              key: Key("__${emo.id}"),
              child: emo.render(),
            );
          }).toList(),
        )
      );
      }
    );
  }
   Widget build(BuildContext context) {
    var isDark  = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;
    var widthApp  = MediaQuery.of(context).size.width;
    return Container(
      // height: 260,
      width: widthApp,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color:isDark ? Color(0xFF3D3D3D) : Color(0xFFFFFFFF),
        border: Border(
          bottom: BorderSide(width: 0.3, color:isDark ? Colors.grey[700]! :  Colors.grey),
          top: BorderSide(width: 0.3, color:isDark ? Colors.grey[700]! :  Colors.grey),
          left: BorderSide(width: 0.3, color:isDark ? Colors.grey[700]! :  Colors.grey),
          right: BorderSide(width: 0.3, color:isDark ? Colors.grey[700]! :  Colors.grey)
        )
      ),
      child: Stack(
        children: [
          Column(
            // categroru
            children: [
              Container(
                margin: EdgeInsets.only(left: 10,right: 12,top: 10),
                height: 41,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide( 
                      color:isDark ? Color(0xff5E5E5E) : Color(0xffEAE8E8),
                      width: 1.0,
                  ), ) 
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    renderListCategory()
                  ],
                ) 
              ),
              Container(
                margin: EdgeInsets.only(top:48),
                height: 240,
                child: renderListCategoryItem(selectedCategory, context)
              ),
            ],
          ),
          Wrap(
            children: [
              SearchEmoji(onTap: onSelectEmoji, onHover: onHoverEmojiItem, onSearch: searchEmoji,),
            ],
          ),
        ],
      ),
    
    );
  }
}
class CreateEmoji extends StatefulWidget {
  CreateEmoji({
    Key? key,
  }) : super(key: key);
  _CreateEmojiState createState() => _CreateEmojiState();
}
class _CreateEmojiState extends State<CreateEmoji> {
  var image;
  var errorMessage;
  var name;
  pickImage() async {
    try {
      var myMultipleFiles =  await Utils.openFilePicker([
        XTypeGroup(
          extensions: ['jpg', 'jpeg', 'gif', 'png'],
        )
      ]);
      var isGif  =  myMultipleFiles[0]["path"].split(".").last  == "gif";
      var thumbnail;
      if (isGif){
      }
      else {
        var img = Img.decodeImage(myMultipleFiles[0]["file"]);
        thumbnail = Img.copyResize(img!, width: 30, height: 30);
      }
      image = {
        "name": "custom_emoji",
        "mime_type": "png",
        "path": myMultipleFiles[0]["path"],
        "bytes": isGif ? myMultipleFiles[0] :  Img.encodePng(thumbnail)
      };
      setState(() {});
    } catch (e) {
      print(" pickImage $e");
    }
  }
  handleCreate() async {
    setState(() {
      errorMessage = null;
    });
    if (name == null || name == "" || image == null) {
      setState(() {
        errorMessage = "Vui long dien day du";
      });
    } else {
      image["name"] = name;
      String token = Provider.of<Auth>(context, listen: false).token;
      var workspaceId = Provider.of<Workspaces>(context, listen: false).currentWorkspace["id"];
      var dataUpload = await Provider.of<Work>(context, listen: false).getUploadData(image);
      var data = await Provider.of<Work>(context, listen: false).uploadImage(token, workspaceId, dataUpload, dataUpload["mime_type"], (t) {});
      String url = "${Utils.apiUrl}workspaces/$workspaceId/create_emoji?token=$token";
      var response = await Dio().post(url, data: {"name": name, "url": data["content_url"]});
      if (response.data["success"]) {
        Navigator.pop(context);
      } else {
        setState(() {
          errorMessage = response.data["message"];
        });
        sl.get<Auth>().showErrorDialog(errorMessage ?? "Error create emojji");
      }
    }
  }
  Widget build(BuildContext context) {
    bool isDark  = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;
    return Container(
      width: 500,
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(4),
        color: isDark ? Color(0xFF262626) :  Colors.white,
      ),
      padding: EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("Add Emoji", style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, )
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Your custom emoji will be available to everyone in your workspace. You’ll find it in the custom tab of the emoji picker.',
              style: TextStyle(fontSize: 14,)
            ),
          ),
          Text('1. Upload an image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Container(
            margin: EdgeInsets.only(left: 12),
            child: Column(
              children: [
                Text(
                  'Square images under 128KB and with transparent backgrounds work best. If your image is too large, we’ll try to resize it for you.',
                  style: TextStyle( fontSize: 12,)
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      image != null
                        ? Container(
                            child: Image.memory( image["file"], height: 30, width: 30,)
                          )
                        : Container(),
                      Container(width: 16),
                      TextButton(
                        // color: Color(0xFF8c8c8c),
                        onPressed: () {
                          pickImage();
                        },
                        child: Text('upload image', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Text('2. Give it a name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Container(
            margin: EdgeInsets.only(left: 12),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text( 'This is also what you’ll type to add this emoji to your messages.', style: TextStyle( fontSize: 12, )),
                Container( height: 12, ),
                CupertinoTextField(
                  placeholder: "name emoji",
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  autofocus: true,
                  style: TextStyle(fontSize: 12),
                  // controller: _invitePeopleController,
                  decoration: BoxDecoration(
                    border: Border.all(width: 0.5, color: Colors.grey),
                    borderRadius: BorderRadius.circular(5)),
                  onChanged: (value) {
                    name = value;
                  },
                ),
              ],
            ),
          ),
          AnimatedContainer(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8),
            duration: Duration(milliseconds: 200),
            height: errorMessage != null ? 50 : 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.red[50],
              ),
              //  margin: EdgeInsets.symmetric(vertical: 34),
              child: Row(
                children: [
                  Text(errorMessage ?? "", style: TextStyle(color: Colors.red, fontSize: 11))
                ],
              ),
            )
          ),
          Container(
            margin: EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  // color: Color(0xFFbfbfbf),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel', style: TextStyle(color: Colors.white,)),
                ),
                Container( width: 16, ),
                TextButton(
                  // color: Color(0xFF1890ff),
                  onPressed: () {
                    //  create Emoji
                    handleCreate();
                  },
                  child: Text('OK', style: TextStyle(color: Colors.white,)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
class HoverItem extends StatefulWidget {
  final child;
  final colorHover;
  final tooltip;
  final showTooltip;
  final onHover;
  final onExit;
  HoverItem({
    Key? key,
    @required this.child,
    this.colorHover,
    this.tooltip,
    this.showTooltip,
    this.onHover,
    this.onExit
  }) : super(key: key);
  _HoverItemState createState() => _HoverItemState();
}
class _HoverItemState extends State<HoverItem>{
  bool isHover =  false;
   
  Widget build(BuildContext context){
    var isDark  = Provider.of<Auth>(context, listen: true).theme == ThemeType.DARK;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        setState(() {
          isHover = true;
        });
        if (widget.onHover !=  null){
          widget.onHover();
        }
      },
      onExit: (event){
        setState(() {
          isHover = false;
        });
        if (widget.onExit !=  null){
          widget.onExit();
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isHover ? widget.colorHover : null,
          // border: BoxBorder()
        ),
        // child: widget.child,
        child: SimpleTooltip(
          animationDuration: Duration(milliseconds: 50),
          tooltipDirection: TooltipDirection.up,
          child: widget.child,
          show: isHover && Utils.checkedTypeEmpty(widget.showTooltip),
          borderColor: isDark ? Color(0xFF262626) :Color(0xFFb5b5b5),
          borderWidth: 0.5,
          backgroundColor: isDark ? Color(0xFF1c1c1c): Colors.white,
          arrowLength:  8, 
          content: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 200),
            child: Container(
              // height: 100,
              child: Wrap(
                children: [
                  widget.tooltip != null ? widget.tooltip : Container()
                ],
              ),
            ),
          )
        )
      ),
    );
  }
}