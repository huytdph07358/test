import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/models/models.dart';

class MessageCardDesktop extends StatefulWidget {
  final message;
  final id;
  final onlyPreview;

  const MessageCardDesktop({
    Key? key,
    @required this.message,
    @required this.id,
    this.onlyPreview = false,
  }) : super(key: key);

  @override
  _MessageCardDesktopState createState() => _MessageCardDesktopState();
}

class _MessageCardDesktopState extends State<MessageCardDesktop> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(!widget.onlyPreview) SelectableLinkify(
            options: LinkifyOptions(
              defaultToHttps: true,
              looseUrl: false,
              humanize: false,
            ),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Color(0xFFd8dcde) : Colors.grey[800],
              fontWeight: FontWeight.w400
            ),
            onOpen: (link) async {
              Utils.openUrl(link.url);
            },
            text: widget.message
          )
        ]
      )
    );
  }
}
