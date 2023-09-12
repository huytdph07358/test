import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/attachment_card.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/models/models.dart';

import '../../generated/l10n.dart';
import '../video_viewer.dart';

class RenderMediaChannel extends StatefulWidget {
  final channelId;
  RenderMediaChannel({
    Key? key, this.channelId,
  }) : super(key: key);

  @override
  _RenderMediaChannelState createState() => _RenderMediaChannelState();
}

class _RenderMediaChannelState extends State<RenderMediaChannel> {
  List data = [];
  bool isImage = true;
  List typeAttachments = ['mp4', 'mov', 'flv', 'avi', 'image', 'video'];

  @override
  void initState() {
    super.initState();
    final channels = Provider.of<Channels>(context, listen: false).data;
    final indexs = channels.indexWhere((e) => e['id'] == widget.channelId);
    final currentChannel = channels[indexs];
    final attachmentsChannel = Provider.of<Channels>(context, listen: false).getFilesChannel(currentChannel['id']);
    data = attachmentsChannel.where((e) => typeAttachments.contains(e['type'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    final channels = Provider.of<Channels>(context, listen: false).data;
    final indexs = channels.indexWhere((e) => e['id'] == widget.channelId);
    final currentChannel = channels[indexs];
    final attachmentsChannel = Provider.of<Channels>(context, listen: true).getFilesChannel(currentChannel['id']);
    List dataImages = attachmentsChannel.where((e) => typeAttachments.contains(e['type'])).toList();
    List dataFiles = attachmentsChannel.where((e) => !typeAttachments.contains(e['type'])).toList();


    return Container(
      color: isDark ? Color(0xff3D3D3D) : Color(0xffEDEDED),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: isDark ? Colors.transparent : Color(0xffEDEDED),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xff2E2E2E) : Colors.white,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 16),
                              width: 30,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Text(
                                "${S.current.files}/${S.current.photo}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            Container(width: 30)
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: dataFiles.length > 0 ? () {
                          if(isImage) setState(() {
                            isImage = false;
                            data = dataFiles;
                          });
                        } : null,
                        child: Container(
                          width: 160, height: 40,
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight),
                            color: isImage ? null : (isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight)
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIcons.files,
                                color: isDark ? Colors.white : Colors.black, size: 20
                              ),
                              SizedBox(width: 8),
                              Text(
                                '${S.current.files} (${dataFiles.length.toString()})',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: isDark ? Colors.white : Colors.black
                                ),
                              ),
                            ],
                          )
                        )
                      ),
                      SizedBox(width: 2),
                      InkWell(
                        onTap: dataImages.length > 0 ? () {
                          if(!isImage) setState(() {
                            isImage = true;
                            data = dataImages;
                          });
                        } : null,
                        child: Container(
                          width: 160, height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight),
                            color: !isImage ? null : (isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight)
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                PhosphorIcons.imageSquare,
                                color: isDark ? Colors.white : Colors.black, size: 20
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${S.current.photo}/Video (${dataImages.length.toString()})',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: isDark ? Colors.white : Colors.black
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        )
                      ),
                    ],
                  ),
                ),
                !isImage ? Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      PhosphorIconData icon = PhosphorIcons.files;
                      final item = data[index];
                      final itemInsertedAt = item["inserted_at"] != null ? DateFormat("dd/MM/yyyy").format(DateTime.parse("${item["inserted_at"]}")) : '';
                      final itemSize = Utils.showFileSize(item["size"]);
                      switch (item['type']) {
                        case 'js': 
                        case 'ts':
                        case 'dart':
                        case 'ex':
                        case 'c':
                        case 'sql':
                        case 'json':
                        case 'txt':
                        case 'text':
                          icon = PhosphorIcons.fileText;
                          break;
                        default:
                      }
                    
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_)  {
                              return CustomDialogNew(
                                title: "Download attachment", 
                                content: "Do you want  to download ${item["file_name"]}",
                                confirmText: "Download",
                                onConfirmClick: () {
                                  Provider.of<Work>(context, listen: false).addTaskDownload({
                                    'name': item['file_name'],
                                    'content_url': item['content_url'],
                                    'version': item['version'],
                                  });
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
                        child: Container(
                          height: 70,
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight),
                              top: BorderSide(color: index != 0 ? Colors.transparent : isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight),
                            )
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: isDark ? Color(0xff2E2E2E) : Color(0xFFbfbfbf),
                                  borderRadius: BorderRadius.all(Radius.circular(4))
                                ),
                                child: Icon(icon, size: 22.0),
                              ),
                              Container(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      item["file_name"],
                                      style: TextStyle(
                                        fontSize: 15, 
                                        overflow: TextOverflow.ellipsis, 
                                        fontWeight: FontWeight.w500, 
                                        color: isDark ?  Color(0xFFDBDBDB) : Color(0xFF262626)
                                      )
                                    ),
                                    Container(
                                      width: 120,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "$itemSize",
                                            style: TextStyle(
                                              fontSize: 12, 
                                            color: Color(0xFF828282),
                                            overflow: TextOverflow.ellipsis
                                            )
                                          ),
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                                          ),
                                          Text(
                                            '', //full name is here
                                            style: TextStyle(
                                              fontSize: 12, 
                                              color: Color(0xFF828282),
                                              fontWeight: FontWeight.w500
                                            )
                                          ),
                                        ]
                                      ),
                                    ),
                                    itemInsertedAt == "" ? Container() : Container(
                                      child: Text("$itemInsertedAt", style: TextStyle( fontSize: 12,color: Color(0xFF828282))),
                                    ),
                                  ]
                                ),
                              ),
                              Container(
                                width: 30,
                                child: InkWell(
                                  onTap: () {
                                    // show popup jump to message or forward file
                                  },
                                  child: Icon(Icons.more_horiz, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight),
                                )
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                ) : Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: isDark ? Palette.borderSideColorDark : Palette.borderSideColorLight)
                      )
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 100,
                        childAspectRatio: 1,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        String tag  = Utils.getRandomString(30);
                        return GestureDetector(
                          onTap: () {
                            if(data[index]['type'] == 'image') {
                              showBottomSheetImage(context, data[index]["content_url"], data[index]['message_id'], tag, {
                                ...data[index],
                                'name': data[index]['file_name'],
                                'id': data[index]['message_id']
                              });
                            } else {
                              showModalBottomSheet(
                                isScrollControlled: true,
                                context: context, 
                                builder: (BuildContext context) {
                                  return VideoViewer(
                                    contentUrl: data[index]['content_url'], 
                                    isDirect: false, previewComment: false, 
                                    thumnailUrl: data[index]["url_thumbnail"] 
                                      ?? data[index]["path_thumbnail"] 
                                      ?? 'https://statics.pancake.vn/panchat-dev/2022/7/13/a09eefc0163c17427affb4b6bf939e337aeb54da.mp4', 
                                    data: null
                                  );
                                }
                              );
                            }
                          },
                          child: Hero(
                            tag: tag,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100, height: 100,
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: CachedImage(
                                    data[index]['type'] == 'image' ? data[index]['content_url'] : data[index]['path_thumbnail'] ?? 'https://statics.pancake.vn/panchat-dev/2022/7/13/a09eefc0163c17427affb4b6bf939e337aeb54da.mp4', 
                                    radius: 4,
                                    fit: BoxFit.cover,
                                  )
                                ),
                                if(data[index]['type'] != 'image') Center(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: Center(child: Icon(CupertinoIcons.play_fill, color: Colors.white, size: 22))
                                ),
                              ),
                              ],
                            ),
                          )
                        );
                      }
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}