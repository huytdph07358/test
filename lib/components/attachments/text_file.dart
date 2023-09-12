import 'package:flutter/material.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_highlighter/themes/atom-one-light.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/components/custom_highlight_view.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';

class TextFile extends StatefulWidget {
  TextFile({
    Key? key,
    required this.att,
    this.isChannel = true,
  }) : super(key: key);

  final att;
  final bool isChannel;

  @override
  _TextFileState createState() => _TextFileState();
}

class _TextFileState extends State<TextFile> {
  String previewText = '';
  String renderText = '';
  bool isExpanded = false;
  String language = '';
  String fullText = '';

  @override
  void initState() {
    final att = widget.att;

    language = Utils.getLanguageFile(att['mime_type'].toLowerCase());
    try {
      final List<String> splitSnippet = att['preview'] != null ? att['preview'].split('\n') : [];
      previewText =  splitSnippet.length > 5 ? splitSnippet.sublist(0, 5).join('\n').trimRight() : att['preview'].trimRight();
      renderText = previewText;      
    } catch (e) {}



    Utils.onRenderSnippet(att['content_url'], keyEncrypt: att["key_encrypt"]).then((value) {
      fullText = value;
    });

    super.initState();
  }

  @override
  void didUpdateWidget(covariant TextFile oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<Auth>(context, listen: false).theme == ThemeType.DARK;
    final att = widget.att;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isDark ? Color(0xff1E1E1E) : Color(0xffDBDBDB)
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: language != 'txt' ? CustomHighlightView(
              renderText,
              language: language,
              backgroundColor: isDark ? Color(0xff1E1E1E) : Color(0xffDBDBDB),
              theme: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                  .platformBrightness == Brightness.dark
                  ? atomOneLightTheme
                  : atomOneDarkTheme,
              padding: const EdgeInsets.all(8),
              textStyle: GoogleFonts.robotoMono(color: isDark ? Colors.white70 : Colors.grey[800], height: 1.65, fontSize: 12.5),
            ) : SelectableText.rich(
            TextSpan(
              text: renderText,
                style: GoogleFonts.robotoMono(
                  fontWeight: FontWeight.w400, fontSize: 12.5, height: 1.57,
                  color: isDark ? Color(0xffEAE8E8) : Color(0xff3D3D3D)
                )
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor)
              )
            ),
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                      renderText = isExpanded ? att['preview'] ?? "" : previewText;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    width: 88,
                    child: Row(
                      children: [
                        Icon(
                          isExpanded ? PhosphorIcons.caretUp : PhosphorIcons.caretRight,
                          color: isDark ? Colors.white70 : Colors.grey[800],
                          size: 18,
                        ),
                        Text(
                          isExpanded ? ' ${S.current.collapse}' : ' ${S.current.expand}',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[800],
                            fontSize: 14
                          )
                        )
                      ],
                    ),
                  ),
                ),
                if(widget.isChannel) Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: IconButton(
                    onPressed: () => Utils.openUrl(att['content_url']),
                    padding: const EdgeInsets.all(4),
                    icon: Icon(
                      PhosphorIcons.arrowsOutSimple,
                      color: isDark ? Colors.white70 : Colors.grey[800],
                      size: 18,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_)  {
                          return CustomDialogNew(
                            title: "Download attachment", 
                            content: "Do you want  to download ${att["name"]}",
                            confirmText: "Download",
                            onConfirmClick: () {
                              Provider.of<Work>(context, listen: false).addTaskDownload(att);
                              Fluttertoast.showToast(
                                msg: "Start downloading",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                fontSize: 13
                              );
                              Navigator.pop(context);
                            },
                            quickCancelButton: true,
                          );
                        }
                      );
                    },
                    padding: const EdgeInsets.all(4),
                    icon: Icon(
                      PhosphorIcons.downloadSimple,
                      size: 18.0,
                      color: isDark ? Colors.white70 : Colors.grey[800],
                    )
                  ),
                ),
                // const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text.rich(
                      TextSpan(
                        text: att['name'],
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[800],
                          fontSize: 13
                        ),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
