import 'package:flutter/widgets.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/emoji/emoji.dart';

class ItemEmoji {
  var name;
  var id;
  var value;
  var skin;
  var custom;
  var type;
  var url;
  var onTap;
  var onHover;

  ItemEmoji(this.id, this.name, this.value, this.skin, this.custom, this.type, this.url, this.onTap, this.onHover);

  getItemEmoji(){
    return;
  }

  static ItemEmoji castObjectToClass(Map obj){
    return ItemEmoji(
      obj["id"] ?? obj["emoji_id"] ?? "",
      obj["name"] ??  "",  
      obj["value"] ??  "",
      obj["skin"] ??  "",
      obj["custom"] ??  "",
      obj["type"],
      obj["url"] ??  "",
      obj["opTap"],
      obj["onHover"],
    );
  }

  toJson(){
    return {
      "id": this.id,
      "name": this.name,
      "value": this.value,
      "skin": this.skin,
      "custom": this.custom,
      "type": this.type,
      "url": this.url,
    };
  }

  render({double size = 22, var padding = 5.0, bool isEnableHover = true, double heightLine = 0.0}){
    if (isEnableHover)
      return HoverItem(
        onHover: (){
          if (this.onHover != null)
            this.onHover(this);
        },
        onExit: (){
          if (this.onHover != null)
            this.onHover(null);
        },
        colorHover: Color(0xFFd9d9d9),
        child: GestureDetector(
          onTap: () {
            if (onTap != null) onTap(this);
          },
          child: Container(
            padding: EdgeInsets.all(padding),
            height: size == 22 ? 35 : size *2,
            width: size == 22 ? 35 : size *2,
            child: Center(
              child: this.type == "default"
                ? Text("${this.value}", style: TextStyle(fontSize: size))
                : CachedImage(url, height: size* 2, width:  size* 2,)
            )
          ),
        ),
      );
    return this.type == "default"
      ? Text("${this.value}", style: TextStyle(fontSize: size,  height: heightLine))
      : CachedImage(url, height: size* 2, width:  size* 2,);
  }
}