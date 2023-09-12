import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:workcake/models/models.dart';

import '../screens/conversation.dart';

class ImageDetail extends StatefulWidget {
  final url;
  final id;
  final full;
  final tag;
  final att;

  ImageDetail({
    Key? key,
    @required this.id,
    @required this.url,
    @required this.tag,
    this.full = false, 
    this.att
  }) : super(key: key);
  @override
  _ImageDetailState createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {
  var show = false;
  var detailsState;
  TransformationController transformationController = new TransformationController();
  PanelController panelController = PanelController();

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 100), () {
      if (!mounted) return;
      setState(() {
        show = true;
      });
    });
  }

  downloadImage(url) async {
    if (Platform.isAndroid || Platform.isIOS) {
       try {
        await ImageDownloader.downloadImage(url);
      } on PlatformException catch (error) {
        print(error);
      }
    } else {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd kk-mm').format(now);
      var response = await get(url);
      var documentDirectory = await getApplicationDocumentsDirectory();
      var firstPath = documentDirectory.path + "/images";
      var filePathAndName = '/Users/admin/Downloads' + '/$formattedDate.jpg';
      
      await Directory(firstPath).create(recursive: true);
      File file2 = new File(filePathAndName);
      file2.writeAsBytesSync(response.bodyBytes);
    }
  }

  Widget build(BuildContext context) {
    return Stack(
      children: [
        PhotoView(
          imageProvider: NetworkImage(widget.url),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained * 4,
          initialScale: PhotoViewComputedScale.contained,
          heroAttributes: PhotoViewHeroAttributes(tag:widget.tag),
        ),
        
        AnimatedPositioned(
          duration: Duration(milliseconds: 300),
          top: show ? 0 : -100,
          child: Container(
            color: Color(0xFF000000).withOpacity(0.25),
            height: 100,
            padding: EdgeInsets.only(top: 24, left: 6, right: 6),
            alignment: Alignment.centerLeft,
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () { Navigator.of(context).pop(); },
                      child: Icon(Icons.keyboard_backspace, color: Color(0xFFFFFFFF)),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      child: TextButton(
                        onPressed: () async{
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          await Provider.of<Messages>(context, listen: false).handleProcessMessageToJump(widget.att, context);
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return Conversation(
                                  id: widget.att["channel_id"], 
                                  hideInput: true, 
                                  changePageView: (page) {}, 
                                  isNavigator: true,
                                  panelController: panelController
                                );
                              },
                            )
                          );
                        },
                        child: Icon(
                          PhosphorIcons.arrowElbowDownRight,
                          size: 20, color: Color(0xFFFFFFFF)
                        )
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      child: TextButton(
                        onPressed: () async {
                          try {
                            await GallerySaver.saveImage(widget.att["content_url"], toDcim: true);
                            Fluttertoast.showToast(
                              msg: "Downloaded successfully",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              fontSize: 13
                            );
                          } catch (e, trace) {
                            print("Download failure: $e $trace");
                          }
                        },
                        child: Icon(Icons.file_download, size: 20, color: Color(0xFFFFFFFF))
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 50,
                      child: TextButton(
                        onPressed: () => Share.share(widget.url),
                        child: Icon(Icons.share, size: 20,  color: Color(0xFFFFFFFF))
                      ),
                    )
                  ]
                ),
              ],
            )
          ),
        ),
      ],
    );
  }
}
