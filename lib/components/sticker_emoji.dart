// ignore_for_file: camel_case_types

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/components/render_list_emoji.dart';
import 'package:workcake/components/render_list_sticker.dart';

import '../models/models.dart';

class StickerEmojiWidget extends StatefulWidget {
  final selectSticker;
  final onClose;
  final onSelect;
  final workspaceId;


  const StickerEmojiWidget({
    Key? key,
    required this.selectSticker,
    this.onClose,
    this.onSelect,
    this.workspaceId
  }) : super(key: key);

  @override
  StickerEmojiWidgetState createState() => StickerEmojiWidgetState();
}

class StickerEmojiWidgetState extends State<StickerEmojiWidget> {
  bool isEmoji = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    bool isDark = auth.theme == ThemeType.DARK;

    return Container(
      height: 340, margin: EdgeInsets.only(bottom: Platform.isAndroid ? 0 : 20),
      decoration: BoxDecoration(
        color: isDark ? Palette.backgroundRightSiderDark : Colors.white,
        border: Border.all(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight.withOpacity(0.75)),
        borderRadius: BorderRadius.all(Radius.circular(8))
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight.withOpacity(0.75))
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => isEmoji = false),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1.75,
                              color: !isEmoji ? isDark ? Palette.calendulaGold : Palette.dayBlue : Colors.transparent
                            )
                          ),
                        ),
                        child: Text(
                          'Sticker',
                          style: TextStyle(
                            color: !isEmoji ? (isDark ? Palette.calendulaGold : Palette.dayBlue) : (isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                            fontWeight: FontWeight.w500, fontSize: 16
                          ),
                        )
                      ),
                    ),
                    SizedBox(width: 6),
                    InkWell(
                      onTap: () => setState(() => isEmoji = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1.75,
                              color: isEmoji ? (isDark ? Palette.calendulaGold : Palette.dayBlue) : Colors.transparent
                            )
                          ),
                        ),
                        child: Text(
                          'Emoji',
                          style: TextStyle(
                            color: isEmoji ? (isDark ? Palette.calendulaGold : Palette.dayBlue) : (isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                            fontWeight: FontWeight.w500, fontSize: 16
                          ),
                        )
                      ),
                    ),
                  ],
                ),
                InkWell(
                  child: Icon(
                    PhosphorIcons.x,
                  size: 20, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            )
          ),
          isEmoji
            ? Expanded(child: ListEmojiWidget(onClose: () => Navigator.pop(context), onSelect: widget.onSelect, workspaceId: widget.workspaceId))
            : ListStickersWidget(selectSticker: widget.selectSticker)
        ],
      ),
    );
  }
}
