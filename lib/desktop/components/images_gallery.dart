import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/components/media_conversation/stream_media_downloaded.dart';
import 'package:workcake/models/models.dart';
import '../../components/media_conversation/model.dart';

class ImagesGallery extends StatefulWidget {
  ImagesGallery({
    var key,
    this.id,
    this.att, 
    this.isChildMessage, 
    this.isThread,
    required this.isConversation,
    this.conversationId
  }) : super(key: key);

  final id;
  final att;
  final isChildMessage;
  final isThread;
  final bool isConversation;
  final String? conversationId;

  @override
  _ImagesGalleryState createState() => _ImagesGalleryState();
}

class _ImagesGalleryState extends State<ImagesGallery> {
  var show = false;
  int page = 0;

  @override
  void initState() {
    super.initState();
  }

  onTapImage(img) {
    final index = widget.att["data"].indexWhere((e) => e["name"] == img["name"]);

    this.setState(() {
      page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final currentChannel = Provider.of<Channels>(context, listen: true).currentChannel;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10)
      ),
      width: deviceWidth,
      child: Wrap(
        children: widget.att["data"].map<Widget>((img) {
          var tag  = Utils.getRandomString(30);
          double size = (300 - (widget.att["data"].length)*6)/(widget.att["data"].length);

          return GestureDetector(
            onTap: () {
              onTapImage(img);
              FocusManager.instance.primaryFocus?.unfocus();
              // Navigator.push(context, MaterialPageRoute(builder: (context) => Gallery(page: page, tag: tag, att: widget.att, isConversation: widget.isConversation, messageId: widget.id,)));
              showModalBottomSheet(
                isScrollControlled: true,
                context: context, 
                builder: (BuildContext context) {
                  return Gallery(page: page, tag: tag, att: widget.att, isConversation: widget.isConversation, messageId: widget.id);
                });
            },
            child: img["content_url"] == null
              ? Text("Message unavailable", style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic, fontSize: 13, fontWeight: FontWeight.w200))
              : ImageItem(
                messageId: widget.id ?? "", 
                tag: tag, 
                size: size, 
                currentChannel: currentChannel, 
                widget: widget, 
                img: img, 
                att: widget.att, 
                isConversation: widget.isConversation, 
                conversationId: widget.conversationId,
                isThread: widget.isThread,
                inGallery: widget.att["data"].length > 1
              )
            );
          }
        ).toList(),
      )
    );
  }
}

class ImageItem extends StatefulWidget {
  const ImageItem({
    Key? key,
    this.tag,
    this.size,
    this.currentChannel,
    this.widget,
    this.img,
    this.att,
    required this.isConversation,
    this.messageId,
    this.conversationId,
    this.failed,
    this.previewComment,
    this.isThread = false,
    this.inGallery = false
  }) : super(key: key);

  final tag;
  final size;
  final currentChannel;
  final widget;
  final img;
  final att;
  final bool isConversation;
  final messageId;
  final conversationId;
  final failed;
  final previewComment;
  final isThread;
  final bool inGallery;

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  bool failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.failed != null) {
      this.setState(() {
        failed = widget.failed;
      });
    }
  }

  getImageSize(imageData) {
    double? height = (imageData != null && imageData["height"] != null) ? int.parse(imageData["height"].toString()).toDouble() : null;
    double? width = (imageData != null && imageData["width"] != null) ? int.parse(imageData["width"].toString()).toDouble() : null;

    if (height != null && width != null) {
      var ratio = height/width;
      double deviceWidth = MediaQuery.of(context).size.width;

      if (ratio > 1) {
        height = widget.inGallery ? (deviceWidth-94)/2 : (widget.isThread == true && height > 240) ? 240 : (height > 320) ? 320 : height;
        width = widget.inGallery ? (deviceWidth-94)/2 : height/ratio;
      } else {
        width = widget.inGallery ? (deviceWidth-94)/2 : (widget.isThread == true && width > 240) ? 240 : (width > 320) ? 320 : width;
        height = widget.inGallery ? (deviceWidth-94)/2 : width*ratio;
      }
    } else {
      height = (widget.isThread == true) ? 240 : 320;
      width = (widget.isThread == true) ? 240 : 320;
    }

    return {
      'height': height,
      'width': width
    };
  }

  Widget dummyImage() {
    final isDark = Provider.of<Auth>(context).theme == ThemeType.DARK;

    return Container(
      color: isDark ? Color(0xff1C1D21) : Color(0xffEAEEF1),
      child: Image.asset(
        'assets/images/preview_image_${isDark ? 'dark' : 'light'}.png',
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    var img = widget.img;
    final imageData = img["image_data"];
    double? height = getImageSize(imageData)['height'];
    double? width = getImageSize(imageData)['width'];
    int? cacheWidth = (imageData != null && imageData["width"] != null) ? int.parse(imageData["width"].toString()) : null;
    // var screenWidth = 640;
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;

    return failed ? InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContex)  {
            return CustomDialogNew(
              title: "Download attachment", 
              content: "Do you want to download ${img["name"]}",
              confirmText: "Download",
              quickCancelButton: true,
              onConfirmClick: () async {
                Provider.of<Work>(context, listen: false).addTaskDownload({"content_url": img["content_url"], 'name': img["name"],  "key_encrypt": img["key_encrypt"]});
              }
            );
          }
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(CupertinoIcons.cloud_download, color: Colors.grey[600]),
            SizedBox(width: 6),
            Container(
              constraints: BoxConstraints(maxWidth: 160),
              child: Text(img["name"], style: TextStyle(color: Colors.grey[700]), overflow: TextOverflow.ellipsis)
            )
          ],
        )
      )
    ) :
    (Platform.isAndroid && img["mime_type"] == "heic" && (Utils.versionAndroid ?? 0) < 10)
    ? InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (dialogContex)  {
              return CustomDialogNew(
                title: "Download attachment", 
                content: "Do you want to download ${img["name"]}",
                confirmText: "Download",
                quickCancelButton: true,
                onConfirmClick: () async {
                  Provider.of<Work>(context, listen: false).addTaskDownload({"content_url": img["content_url"], 'name': img["name"],  "key_encrypt": img["key_encrypt"]});
                }
              );
            }
          );
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color(0xFFd9d9d9)
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            minWidth: 0.0
          ),
          child:Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(Icons.download_rounded, size: 15, color: Color(0xFF595959)),
                  ),
                ),
                WidgetSpan(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 150,
                      minWidth: 0.0
                    ),
                    child: Text(img["name"], style: TextStyle(color: Colors.grey[700]), overflow: TextOverflow.ellipsis))
                ),
              ]
            )
          )
        ),
      ) : Hero(
        tag: widget.tag,
        child: Container(
          constraints: (widget.isThread == true)
            ? BoxConstraints(maxHeight: 240, maxWidth: 240)
            : BoxConstraints(maxHeight: 320, maxWidth: 320),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Color.fromARGB(255, 103, 102, 102) : Color.fromARGB(255, 232, 230, 230),
              width: 0.55
            ),
            borderRadius: BorderRadius.circular(4)
          ),
          height: height,
          width: width,
          margin: EdgeInsets.only(top: 6, right: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: widget.isConversation 
            ? ImageDirect.build(context, img["content_url"], widget.messageId, widget.conversationId, img)
            : CachedNetworkImage(
            imageUrl: img["content_url"],
            cacheKey: img["content_url"],
            fadeInDuration: Duration(milliseconds: 200),
            fit: BoxFit.cover,
            fadeOutDuration: Duration(milliseconds: 200),
            placeholderFadeInDuration: Duration(milliseconds: 200),
            memCacheWidth: widget.inGallery ? (cacheWidth != null ? cacheWidth > 960 ? 960 : cacheWidth : 960) : 640,
            maxWidthDiskCache: widget.inGallery ? 960 : 640,
            
            placeholder: (context, url) {
              return dummyImage();
            },
            errorWidget: (context, url, error) {
              return InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContex)  {
                      return CustomDialogNew(
                        title: "Download attachment", 
                        content: "Do you want to download ${img["name"]}",
                        confirmText: "Download",
                        quickCancelButton: true,
                        onConfirmClick: () async {
                          Provider.of<Work>(context, listen: false).addTaskDownload({"content_url": img["content_url"], 'name': img["name"],  "key_encrypt": img["key_encrypt"]});
                        }
                      );
                    }
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[600]!),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Icon(CupertinoIcons.cloud_download, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Container(
                        constraints: BoxConstraints(maxWidth: 160),
                        child: Text(img["name"], style: TextStyle(color: Colors.grey[700]), overflow: TextOverflow.ellipsis)
                      )
                    ]
                  )
                )
              );
            }
          )
        )
      )
    );
  }
}

class Gallery extends StatefulWidget {
  const Gallery({
    Key? key,
    this.att,
    this.page,
    this.tag,
    this.onChangePage,
    required this.isConversation,
    required this.messageId,
    this.conversationId
  }) : super(key: key);

  final att;
  final page;
  final tag;
  final onChangePage;
  final bool isConversation;
  final String messageId;
  final String? conversationId;

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  int page = 0;
  double sliderValue = 100;
  var pageController;
  var controller = PhotoViewController();
  bool showActionButton = true;
  
  @override
  void initState() {
    super.initState();

    this.setState(() {
      page = widget.page;
    });

    pageController = PageController(initialPage: widget.page);
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Stack(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    showActionButton = !showActionButton;
                  });
                },
                child: PageView.builder(
                  controller: widget.isConversation ? pageController : null,
                  itemCount: widget.att["data"].length,
                  itemBuilder: (BuildContext context, int index) {
                    return widget.isConversation 
                    ? ImageDirect.build(context, widget.att["data"][page]["content_url"], widget.messageId, widget.conversationId, widget.att["data"][page], customBuild: (String localPath) {
                        return PhotoViewGallery.builder(
                        scrollPhysics: const BouncingScrollPhysics(),
                        builder: (BuildContext context, int index) {
                          return PhotoViewGalleryPageOptions(
                            imageProvider: FileImage(File(localPath)),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.contained * 4,
                            initialScale: PhotoViewComputedScale.contained,
                            heroAttributes: PhotoViewHeroAttributes(tag:widget.att["data"][page]["content_url"] + index.toString()),
                          );
                        },
                        itemCount: widget.att["data"].length,
                        onPageChanged: (int index) {
                          this.setState(() {
                            print("page $page");
                            print("index $index");
                            page = index;
                          });
                        },
                        scrollDirection: Axis.horizontal,
                      );
                    })
                    : PhotoViewGallery.builder(
                      scrollPhysics: const BouncingScrollPhysics(),
                      builder: (BuildContext context, int index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: NetworkImage(widget.att["data"][index]["content_url"]),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.contained * 4,
                          initialScale: PhotoViewComputedScale.contained,
                          heroAttributes: PhotoViewHeroAttributes(tag:widget.att["data"][index]["content_url"] + index.toString()),
                        );
                      },
                      itemCount: widget.att["data"].length,
                      onPageChanged: (int index) {
                        this.setState(() {
                          page = index;
                        });
                      },
                      pageController: pageController,
                      scrollDirection: Axis.horizontal,
                    );
                  }
                ),
              ),
              if(showActionButton) AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                top: 0,
                height: 100,
                
                width: MediaQuery.of(context).size.width,
                child: Container(
                  color: Color(0xFF000000).withOpacity(0.25),
                  padding: EdgeInsets.only(top: 24, left: 6, right: 6),
                  alignment: Alignment.centerLeft,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Container(
                          height: 50,
                          width: 50,
                          child: TextButton(
                            onPressed: () { Navigator.of(context).pop(); },
                            child: Icon(Icons.keyboard_backspace, color: Color(0xFFFFFFFF)),
                          ),     
                        )
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            if(Platform.isIOS) Container(
                              height: 50,
                              width: 50,
                              child: TextButton(
                                onPressed: () async { 
                                  if(Platform.isIOS) {
                                    String? pathInDevice = await ServiceMedia.getDownloadedPath( widget.att["data"][page]["content_url"]);
                                    if (pathInDevice == null){
                                      Work.platform.invokeMethod("copy_image",  widget.att["data"][page]["content_url"]);  
                                    } else {
                                      Work.platform.invokeMethod("copy_image", pathInDevice); 
                                    }
                                    Fluttertoast.showToast(
                                      msg: "copied",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 2,
                                      backgroundColor: Color(0xffDBDBDB),
                                      textColor:Color(0xff2E2E2E),
                                      fontSize: 16.0 
                                    );
                                  }
                                },
                                child: Icon(Icons.copy, size: 20,  color: Color(0xFFFFFFFF))
                              ),
                            ),
                            Container(
                              height: 50,
                              width: 50,
                              child: TextButton(
                                onPressed: () async {
                                  String? localPath = await ServiceMedia.getDownloadedPath(widget.att["data"][page]["content_url"]);
                                  try {
                                    if (Platform.isIOS) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("Downloading ${widget.att["data"][page]["name"]}"),
                                    ));
                                    await GallerySaver.saveImage(widget.isConversation ? localPath : widget.att["data"][page]["content_url"], toDcim: true);
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
                                onPressed: () async {
                                  String? localPath = await ServiceMedia.getDownloadedPath(widget.att["data"][page]["content_url"]);
                                  if (localPath != null) {
                                    Share.shareFiles([localPath], mimeTypes: ["image/png"]);
                                  }
                                  else {
                                    try {
                                      // Saved with this method.
                                      var imageId = await ImageDownloader.downloadImage(widget.att["data"][page]["content_url"]);
                                      if (imageId == null) {
                                        return;
                                      }
                                      var path = await ImageDownloader.findPath(imageId);
                                      var mimeType = await ImageDownloader.findMimeType(imageId);
                                      if(path == null || mimeType == null) return;
                                      await Share.shareFiles([path], mimeTypes: [mimeType]);
                                      final file = File(path);
                                      file.delete();
                                    } on PlatformException catch (error) {
                                      print(error);
                                    }

                                  }
                                  
                                 },
                                child: Icon(Icons.share, size: 20,  color: Color(0xFFFFFFFF))
                              ),
                            )
                          ]
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          (page + 1 < widget.att["data"].length) && showActionButton ? Positioned(
            top: (deviceHeight/2) - 25, right: 10,
            child: GestureDetector(
              onTap: () {
                this.setState(() {
                  page +=1;
                });

                pageController.jumpToPage(page);
              },
              child: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
                size: 50,
              )
            )
          ) : Positioned(child: Container()),
          
          page > 0 && showActionButton ? Positioned(
            top: (deviceHeight/2) - 25, left: 10,
            child: GestureDetector(
              onTap: () {
                this.setState(() { page -=1; });
                pageController.jumpToPage(page);
              },
              child: Icon(
                Icons.keyboard_arrow_left,
                color: Colors.white,
                size: 50,
              ),
            ),
          ) : Positioned(child: Container())
        ]
      ),
    );
  }
}