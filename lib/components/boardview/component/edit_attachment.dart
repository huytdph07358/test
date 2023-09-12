import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:workcake/common/cached_image.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/boardview/CardItem.dart';
import 'package:workcake/components/custom_dialog_new.dart';
import 'package:workcake/generated/l10n.dart';
import 'package:workcake/models/models.dart';

class EditAttachment extends StatefulWidget {
  const EditAttachment({
    Key? key,
    required this.attachments,
    this.card,  
    this.page,
    this.tag,
  }) : super(key: key);

  final List attachments;
  final card;
  final page;
  final tag;


  @override
  State<EditAttachment> createState() => _EditAttachmentState();
}

class _EditAttachmentState extends State<EditAttachment> {
  int page = 0;
  var pageController;

  @override
  void initState() {
    super.initState();
  }

  onTapImage(img) {
    final index = widget.attachments.indexWhere((e) => e["content_url"] == img["content_url"]);

    this.setState(() {
      page = index;
    });
  }

  openFileSelector() async {
    final token = Provider.of<Auth>(context, listen: false).token;
    final currentWorkspace = Provider.of<Workspaces>(context, listen: false).currentWorkspace;
    List<AssetEntity> resultList = await Provider.of<Work>(context, listen: false).openFileSelector(context, maxAssets: 10);
    List results = await Utils.handleFileData(resultList);
    results = results.where((e) => e.isNotEmpty).toList();

    for(var i = 0; i < results.length; i++){
      widget.attachments.add({...results[i], 'uploading': true});
      if (!mounted) return;
      this.setState(() {});
    }

    for (var i = 0; i < widget.attachments.length; i++) {
      if (widget.attachments[i]["uploading"] == true) {
        var file = widget.attachments[i];
        var dataUpload = await Provider.of<Work>(context, listen: false).getUploadData(file);
        var response = await Provider.of<Work>(context, listen: false).uploadImage(token, currentWorkspace["id"], dataUpload, dataUpload["type"], (t) {});

        setState(() {
          widget.attachments[i] = response;
          widget.attachments[i]["file_name"] = response["filename"];
        });

        if (widget.card != null) {
          Provider.of<Boards>(context, listen: false).addAttachment(token, widget.card.workspaceId, widget.card.channelId, widget.card.boardId, 
            widget.card.listCardId, widget.card.id, response["content_url"], response["type"], response["file_name"]).then((res) {
              this.setState(() {
                widget.attachments[i]["id"] = res["attachment"]["id"];
              });
            }
          );
        }
      }
    }
  }

  onDeleteAttachment(att) {
    final index = widget.attachments.indexOf(att);
    if (index == -1) return;
    this.setState(() {
      widget.attachments.removeAt(index);
    });
    if (widget.card != null) {
      final token = Provider.of<Auth>(context, listen: false).token;
      CardItem card = widget.card;
      Provider.of<Boards>(context, listen: false).deleteAttachment(token, card.workspaceId, card.channelId, card.boardId, card.listCardId, card.id, att["id"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    final auth = Provider.of<Auth>(context, listen: false );
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Color(0xffA6A6A6) : Color(0xff828282),
            width: 0.25,
          ),
          bottom: BorderSide(
            color: isDark ? Color(0xffA6A6A6) : Color(0xff828282),
            width: 0.25,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 44,
            padding: EdgeInsets.symmetric(vertical: 13, horizontal: 18),
            color: isDark ? Color(0xff4C4C4C) : Color(0xffffffff),
            child: InkWell(
              onTap: () {
                openFileSelector();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(S.current.attachments, style: TextStyle(fontSize: 14))
                  ),
                  Icon(PhosphorIcons.plus, size: 20, color: isDark ? Color(0xffFAAD14) : Color(0xff1890FF))
                ]
              ),
            )
          ),
          widget.attachments.length == 0 ? InkWell(
            onTap: () {
              openFileSelector();
            },
            child: Container(
              width: deviceWidth,
              height: 44,
              color: isDark ? Color(0xff3D3D3D) : Color(0xffF8F8F8),
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 18),
              child: Text(S.current.noAttachment, style: TextStyle(fontSize: 14, color: isDark ? Color(0xffC9C9C9):Color(0xff5E5E5E)))
            ),
          ) : Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8),
            child: Wrap(
              children: widget.attachments.map<Widget>((att) {
                final index = widget.attachments.indexOf(att);
                var tag  = Utils.getRandomString(30);
                return Stack(
                  children: [
                    Container(
                      child: index > 7 ? SizedBox() :
                        index == 7 ? Container(
                          decoration: BoxDecoration(
                            color: Color(0xff707070),
                            borderRadius: BorderRadius.circular(4)
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          width: deviceWidth/5,
                          height: deviceWidth/5 + 22,
                          child: widget.attachments.length - 8 > 0 ? Stack(
                            children: [
                              CachedImage(att["content_url"], width: deviceWidth/5, height: deviceWidth/5 + 22, radius: 4),
                              Container(
                                color: Colors.black.withOpacity(0.4),
                                width: deviceWidth/5,
                                height: deviceWidth/5 + 22,
                              ),
                              Center(child: Text("+${widget.attachments.length - 8}", style: TextStyle(fontSize: 22, color: Colors.white))),
                            ]
                          ) : Container()
                        ) : Container(
                          decoration: BoxDecoration(
                            color: Color(0xff707070),
                            borderRadius: BorderRadius.circular(4)
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          width: deviceWidth/5,
                          height: deviceWidth/5 + 22,
                          child: AttachmentItem(attachments: widget.attachments, att: att, tag: tag)
                        )
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: InkWell(
                        onTap: () {
                          onDeleteAttachment(att);
                        },
                        child: Icon(PhosphorIcons.x, size: 20)
                      )
                    )
                  ]
                );
              }).toList()
            )
          )
        ]
      ),
    );
  }
}

class AttachmentItem extends StatefulWidget {
  AttachmentItem({Key? key, required this.attachments, required this.att, required this.tag}) : super(key: key);
  final attachments;
  final att;
  final tag;

  @override
  State<AttachmentItem> createState() => _AttachmentItemState();
}

class _AttachmentItemState extends State<AttachmentItem> {
  int page = 0;
  var pageController;
  onTapImage(img) {
    final index = widget.attachments.indexWhere((e) => e["content_url"] == img["content_url"]);

    this.setState(() {
      page = index;
    });
  }
  Widget item(att) {
    double deviceWidth = MediaQuery.of(context).size.width;
    switch (att["type"]) {
      case "image":
        return CachedImage(widget.att["content_url"], width: deviceWidth/5, height: deviceWidth/5 + 22, radius: 4);
      case "video":
        return Container(
          color: Colors.black,
          child: Center(
            child: Icon(PhosphorIcons.playCircleBold, size: 28,)
          ),
        );
      default:
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(att["file_name"].toString().split(".").last, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
            ),
            SizedBox(height: 4),
            Text(att["file_name"].toString(), overflow: TextOverflow.ellipsis,)
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          if(widget.att["type"] == "image") {
            onTapImage(widget.att);
            Navigator.push(context, MaterialPageRoute(builder: (context) => Gallery(page: page, tag: widget.tag, attachments: widget.attachments)));
          }
          // else if(widget.att["type"] == "video") {
            
          // }
          else {
            showDialog(
              context: context,
              builder: (_)  {
                return CustomDialogNew(
                  title: S.current.downloadAttachment,
                  content: "${S.current.doYouWantToDownload} ${widget.att["file_name"]}",
                  confirmText: S.current.download,
                  onConfirmClick: () {
                    try {
                      Provider.of<Work>(context, listen: false).addTaskDownload({
                        'name': widget.att['file_name'],
                        'content_url': widget.att['content_url'],
                      });
                      Fluttertoast.showToast(
                        msg: S.current.startDownloading,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        fontSize: 13
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      print(e);
                    }
                  },
                  quickCancelButton: true,
                );
              }
            );
          }
        },
        child: item(widget.att),
      ),
    );
  }
}

class Gallery extends StatefulWidget {
  const Gallery({
    Key? key,
    this.page,
    this.tag,
    this.onChangePage,
    this.conversationId, 
    required this.attachments
  }) : super(key: key);

  final List attachments;
  final page;
  final tag;
  final onChangePage;
  final String? conversationId;

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  int page = 0;
  double sliderValue = 100;
  var pageController;
  var controller = PhotoViewController();
  
  @override
  void initState() {
    super.initState();

    this.setState(() {
      page = widget.page;
    });

    pageController = ExtendedPageController(initialPage: widget.page);
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
              ExtendedImageGesturePageView.builder(
                itemBuilder: (BuildContext context, int index) {
                  var item = widget.attachments[index]["content_url"];
                  GestureConfig initGestureConfigHandler(state) {
                    return GestureConfig(
                      minScale: 0.9,
                      animationMinScale: 0.7,
                      maxScale: 3.0,
                      animationMaxScale: 3.5,
                      speed: 1.0,
                      inertialSpeed: 100.0,
                      initialScale: 1.0,
                      inPageView: true,
                      initialAlignment: InitialAlignment.center,
                    );
                  }
                  Widget image = ExtendedImage.network(
                    item,
                    fit: BoxFit.contain,
                    cache: true,
                    mode: ExtendedImageMode.gesture,
                    initGestureConfigHandler: initGestureConfigHandler
                  );
                  image = Container(
                    child: image,
                    padding: EdgeInsets.all(5.0),
                  );
                  if (index == page) {
                    return Hero(
                      tag: item + index.toString(),
                      child: image,
                    );
                  } else {
                    return image;
                  }
                },
                itemCount: widget.attachments.length,
                onPageChanged: (int index) {
                  this.setState(() {
                    page = index;
                  });
                },
                controller: pageController,
                scrollDirection: Axis.horizontal,
              ),
              AnimatedPositioned(
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          (page + 1 < widget.attachments.length) ? Positioned(
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
          
          page > 0 ? Positioned(
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