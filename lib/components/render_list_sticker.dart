// ignore_for_file: camel_case_types

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/components/attachments/list_sticker.dart';

import '../models/models.dart';
import 'attachments/sticker_file.dart';

enum TYPE_STICKER {
  DUCKS, PEPE, PANDA, EMOJI
}

class ListStickersWidget extends StatefulWidget {
  final selectSticker;

  const ListStickersWidget({
    Key? key,
    required this.selectSticker
  }) : super(key: key);

  @override
  _ListStickersWidgetState createState() => _ListStickersWidgetState();
}

class _ListStickersWidgetState extends State<ListStickersWidget> {
  TYPE_STICKER type = TYPE_STICKER.DUCKS;

  List dataStickers = [{
    'stickers': ducks,
    'type': TYPE_STICKER.DUCKS,
  }, {
    'stickers': pepeStickers,
    'type': TYPE_STICKER.PEPE,
  }, {
    'stickers': emojis,
    'type': TYPE_STICKER.EMOJI,
  }, {
    'stickers': pandaStickers,
    'type': TYPE_STICKER.PANDA,
  }];

  Widget renderItem(data, TYPE_STICKER typeData, bool isDark) {
    return InkWell(
      onTap: () {
        setState(() {
          type = typeData;
        });
      },
      child: Container(
        width: 52, height: 52,
        padding: EdgeInsets.all(6),
        color: typeData == type ? (isDark ? Colors.grey[700] : Color(0xffF3F3F3)) : Colors.transparent,
        child: typeData != TYPE_STICKER.PANDA ? StickerFile(
          key: Key(typeData.toString()),
          data: data[0],
          isPreview: true,
        ) : ExtendedImage.network(data[0]["content_url"]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    bool isDark = auth.theme == ThemeType.DARK;

    int index = dataStickers.indexWhere((e) => e['type'] == type);
    final List stickers = dataStickers[index]['stickers'];

    return Column(
      children: [
        Container(
          width: 400, height: 240,
          child: GridView.count(
            crossAxisCount: 4,
            controller: ScrollController(),
            children: stickers.map<Widget>((sticker) {
              return TextButton(
                onPressed: () {
                  widget.selectSticker(sticker);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: StickerFile(
                    key: Key(sticker.toString()),
                    data: sticker,
                    isPreview: true,
                  ),
                )
              );
            }).toList(),
          )
        ),
        Column(
          children: [
            Divider(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight, height: 0.25),
            Row(
              children: [
                InkWell(
                  child: Container(
                    width: 52, height: 52,
                    child: SvgPicture.asset("assets/icons/recent.svg", color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                  )
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        vertical: BorderSide(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight)
                      )
                    ),
                    child: Row(
                      children: dataStickers.map<Widget>((data) => renderItem(data['stickers'], data['type'], isDark)).toList(),
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      PhosphorIcons.plus, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight, size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ]
        )
      ],
    );
  }
}
