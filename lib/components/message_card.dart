import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/common/validators.dart';
import 'package:workcake/models/models.dart';
import 'package:dart_emoji/dart_emoji.dart';

import '../generated/l10n.dart';

List charCodeIcon = [":)", "=)", ":D", "<3", ":*", ":))", ";)", ":(", ":(("];
List replaceIcon = [":slightly_smiling_face:", ":smiley:", ":smile:", ":heart:", ":kissing_heart:", ":sunglasses:", ":wink:", ":disappointed:", ":cry:"];
class MessageCard extends StatefulWidget {
  const MessageCard({
    Key? key,
    @required this.message,
    @required this.id, 
    this.onlyPreview = false,
    this.onTap,
    this.lastEditedAt,
    this.isConversation = false
  }) : super(key: key);

  final message;
  final id;
  final onlyPreview;
  final onTap;
  final lastEditedAt;
  final isConversation;

  @override
  _MessageCardState createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {

  void openLink(e, bool isEmail) async{
    if (isEmail) {
      Clipboard.setData(ClipboardData(text: e));
    } else {
      Utils.openUrl(e.toString().trim());
    }
  }

  TextSpan renderMessage(list, exp, isDark) {
    var parser = EmojiParser();
    return TextSpan(
      children: [
        TextSpan(
          style: TextStyle(fontSize: 15, height: 1.57),
          children: list.map<TextSpan>((e){
            Iterable<RegExpMatch> matches = exp.allMatches(e);
            bool isLink = false;
            bool isEmail = Validators.validateEmail(e);
            if (e.startsWith('\n')) isLink = e.startsWith('\nhttp');
            else isLink = e.startsWith('http');
            if ((matches.length > 0 && isLink) || isEmail)
              return TextSpan(
                children: [
                  TextSpan(
                    text: e,
                    style: matches.isNotEmpty || isEmail
                      ? TextStyle(color: isDark ? Palette.calendulaGold : Palette.dayBlue, decoration: TextDecoration.underline)
                      : TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)),
                    recognizer: TapGestureRecognizer()..onTapUp = (matches.length > 0 || isEmail) ? (_) {
                      openLink(e, isEmail);
                    } : null,
                  ),
                  TextSpan(text: " ")
                ]
              );
            else {
              int indexIcon = charCodeIcon.indexWhere((element) => element == e);
              if(indexIcon != -1) {
                e = replaceIcon[indexIcon];
              }
              return TextSpan(text: "${parser.emojify(e)} ", style: TextStyle(color: isDark ? Color(0xffDBDBDB) : Color(0xff3D3D3D)));
            }
          }).toList()
        ),
        WidgetSpan(
          child : Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(widget.lastEditedAt != null ? '(${S.current.edited})' : '',
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11, color: Color(0xff6c6f71))),
          ) 
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    RegExp exp = new RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    List list = widget.message.replaceAll("\n", " \n").split(" ");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        !widget.onlyPreview ? widget.isConversation ? Text.rich(
          renderMessage(list, exp, isDark)
        ) : SelectableText.rich(
          renderMessage(list, exp, isDark)
        ) : Container()
      ]
    );
  }
}