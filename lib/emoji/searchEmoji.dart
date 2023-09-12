import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
// import 'package:workcake/emoji/dataSourceEmoji.dart';
import 'package:workcake/emoji/itemEmoji.dart';
import 'package:workcake/models/models.dart';

class SearchEmoji extends StatefulWidget {
  final onTap;
  final onHover;
  final onSearch;
  const SearchEmoji({ Key? key, @required this.onTap, @required this.onHover, @required this.onSearch}) : super(key: key);

  @override
  _SearchEmojiState createState() => _SearchEmojiState();
}

class _SearchEmojiState extends State<SearchEmoji> {
  var text = "";
  List<ItemEmoji> listResults = [];
  search(value){
    if (value == ""){
      setState(() {
        text = "";
        listResults = [];
      });
    } else {
      setState(() {
        text = value;
        listResults = uniq(widget.onSearch(value));
      });
    }
  }

  List<ItemEmoji> uniq(List dataSource){
    Map index  = {};
    List<ItemEmoji> results = [];
    for (var i in dataSource){
      if (index[i.id] == null) {
        index[i.id] = true;
        results += [i];
      }
    }
    return results;
  }


  @override
  Widget build(BuildContext context) {
    final isDark  = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    return Container(
      margin: EdgeInsets.only(top: 3),
      // top: 50,
      color:isDark ? Color(0xFF3D3D3D) : Color(0xFFFFFFFF),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            color: isDark ? Color(0xff2E2E2E) : Color(0xffEDEDED),
            height: 36,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Search emojis',
                prefixIcon: Icon(
                  PhosphorIcons.magnifyingGlass,
                  color: isDark ? Color(0xffDBDBDB) : Color(0xff5E5E5E), size: 16
                ),
                contentPadding: EdgeInsets.only(top: 8),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)),
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Palette.calendulaGold : Palette.dayBlue),
                  borderRadius: BorderRadius.all(Radius.circular(4))
                )
              ),
              autofocus: false,
              style: TextStyle(fontSize: 14, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
              onChanged: (value) => search(value),
            ),
          ), 
          text == ""
            ? Container()
            : Container(
              height: 262,
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(top: 10,),
                  child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: listResults.map<Widget>((emo) {
                    return emo.render();
                  }).toList(),
              ),
                ),
              ),
            )
        ],
      ),
    );
  }
} 