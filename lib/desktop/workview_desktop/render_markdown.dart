import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/desktop/markdown/style_sheet.dart';
import 'package:workcake/desktop/workview_desktop/markdown_checkbox.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';
import 'package:workcake/screens/work_screen/markdown_attachment.dart';

import '../markdown/widget.dart';

class RenderMarkdown extends StatefulWidget {
  RenderMarkdown({
    Key? key,
    required this.stringData,
    required this.onChangeCheckBox,
    this.padding,
    this.commentId
  }) : super(key: key);

  final stringData;
  final Function(bool, String, int?, int) onChangeCheckBox;
  final padding;
  final commentId;

  @override
  State<RenderMarkdown> createState() => _RenderMarkdownState();
}


class _RenderMarkdownState extends State<RenderMarkdown> {
  onChangeCheckbox(newValue, variable, commentId, index) {
    widget.onChangeCheckBox(newValue, variable, commentId, index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    List<String> stringData = Utils.parseStringToMarkdown(widget.stringData);

    return Container(
      padding: widget.padding != null ? widget.padding : EdgeInsets.all(16),
      child: ListView.builder(
        physics: ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: stringData.length,
        itemBuilder: (BuildContext context, int index) {
          String data = stringData[index];

          return Container(
            child: data.trim() == "" ? SizedBox(height: 14) : 
            
            Markdown(
              padding: EdgeInsets.symmetric(vertical: 3),
              physics: const NeverScrollableScrollPhysics(),
              imageBuilder: (uri, title, alt) {
                return MarkdownAttachment(alt: alt, uri: uri);
              },
              shrinkWrap: true,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  fontSize: 16,
                  color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight
                ),
                a: TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, decoration: TextDecoration.underline),
                code: const TextStyle(fontSize: 13, color: Color(0xff40A9FF), fontFamily: "Menlo"),
                codeblockDecoration: BoxDecoration()
              ),
              onTapLink: (link, url, uri) async {
                Utils.openUrl(url);
              },
              selectable: true,
              checkboxBuilder: (value, variable) {
                return Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: MarkdownCheckbox(
                    value: value, 
                    variable: variable, 
                    onChangeCheckBox: onChangeCheckbox, 
                    commentId: widget.commentId,
                    index: index
                  )
                );
              },
              data: data != "" ? data : S.current.noDescriptionProvided
            )
          );
        }
      )
    );
  }
}