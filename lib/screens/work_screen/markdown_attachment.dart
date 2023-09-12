import 'package:flutter/material.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/image_detail.dart';
import 'package:workcake/components/video_card.dart';
import 'package:workcake/desktop/components/images_gallery.dart';

class MarkdownAttachment extends StatefulWidget {
  MarkdownAttachment({
    Key? key,
    required this.alt,
    required this.uri
  }) : super(key: key);

  final alt;
  final uri;

  @override
  State<MarkdownAttachment> createState() => _MarkdownAttachmentState();
}

class _MarkdownAttachmentState extends State<MarkdownAttachment> {
  @override
  Widget build(BuildContext context) {
    final uri = widget.uri;
    var tag = Utils.getRandomString(30);
    final alt = widget.alt;

    return GestureDetector(
      onTap: uri.toString().split(".").last.toLowerCase() == "mov" ||  uri.toString().split(".").last.toLowerCase() == "mp4" ? null : () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return ImageDetail(url: "$uri", id: tag, full: true, tag: tag);
        }));
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 400,
          maxWidth: 750
        ),
        child: uri.toString().split(".").last.toLowerCase() == "mov" ||  uri.toString().split(".").last.toLowerCase() == "mp4" ? VideoCard(contentUrl: "$uri", id: tag, previewComment: true) : ImageItem(
          previewComment: true,
          tag: uri,
          img: {
            'content_url': uri.toString(),
            'name': widget.alt
          }, 
          isConversation: false,
          failed: !(alt.toLowerCase().contains('jpg')
            || alt.toLowerCase().contains('jpeg')
            || alt.toLowerCase().contains('png')
            || alt.toLowerCase().contains("image")
            || alt.toLowerCase().contains("img")) ? true : null,
        )
      )
    );
  }
}