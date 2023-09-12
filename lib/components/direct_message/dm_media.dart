import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/media_conversation/model.dart';
import 'package:workcake/components/video_card.dart';
import 'package:workcake/models/models.dart';


class MediaConversationRender extends StatefulWidget {
  final String id;

  const MediaConversationRender({ Key? key, required this.id }) : super(key: key);

  @override
  State<MediaConversationRender> createState() => _MediaConversationRenderState();
}

class _MediaConversationRenderState extends State<MediaConversationRender> {
  List<MediaConversation> data =[];
  int totalImages = 0;
  int totalFiles = 0;
  String selectedType = "image_video";
  Map<String, List<MediaConversation>> dataMedia = {
    "image_video": [],
    "file": []
  };


  @override
  void initState(){
    super.initState();
    Timer.run(() async{
      // await DriveService.backUp();
      Map d = await ServiceMedia.getNumberOfConversation(widget.id);
      getDataType(selectedType);
      setState(() {
        totalImages = d["images"];
        totalFiles = d["files"];
      });
    });
  }


  getDataType(String type) async {
    dataMedia[type] = (await ServiceMedia.loadConversationMedia(widget.id, 300, getLastCurrentTimeOfType(selectedType), selectedType))["data"];
    setState(() {
    });
  }

  int getLastCurrentTimeOfType(String type){
    try {
      return dataMedia[type]!.last.currentTime;
    } catch (e) {
      return DateTime.now().microsecondsSinceEpoch;
    }
  }

  String? getFileType(String fileName) {
    return fileName.contains('.') ? 
    "." + fileName.split('.').last.toString().toUpperCase() : 'Unknown';
  }
  
  Widget renderMediaType(){
    final auth = Provider.of<Auth>(context, listen: false);
    final isDark = auth.theme == ThemeType.DARK;
    final List<MediaConversation> data = dataMedia[selectedType] ?? [];
    if (selectedType == "image_video")
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 100,
          childAspectRatio: 1,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: data.length,
        itemBuilder: (context, int i) {
          MediaConversation e = data[i];
          return InkWell(
            onTap: () {
              if(e.media.target!.type == 'video') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Stack(
                    children: [
                      Center(
                        child: VideoCard(
                          contentUrl: e.media.target!.remoteUrl,
                          id: e.messageId,
                          isDirect: true,
                          thumnailUrl: null,
                        )
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
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      child: TextButton(
                                        onPressed: () async {
                                          String localPath = e.media.target!.pathInDevice ?? "";
                                          return Share.shareFiles([localPath], mimeTypes: ["video"]);
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
                )));

                return;
              }

              Navigator.push(context, MaterialPageRoute(builder: (context) => Material(child: ImageViewer(listImage: data, index: i,))));
            },
            child: e.media.target!.type == 'video' ? Stack(
              children: [
                Container(
                  width: 180, height: 180,
                  child: ExtendedImage.network(
                    json.decode(e.media.target!.metaData)['url_thumbnail'] ?? 'https://statics.pancake.vn/panchat-dev/2022/7/13/a09eefc0163c17427affb4b6bf939e337aeb54da.mp4',
                    fit: BoxFit.fill,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    shape: BoxShape.rectangle
                  ),
                ),
                Center(
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
            ) : Image.file(
              File(e.media.target!.pathInDevice ?? ""),
              fit: BoxFit.fill
            ),
          );
        }
      ),
    );

    return Expanded(
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext c, int i){
          MediaConversation e = data[i];
          final user = Provider.of<DirectMessage>(context, listen: false).getModelConversation(e.conversationId)!.user.where((user) => user["user_id"] == e.userId).toList();
          final itemInsertedAt = DateFormat("dd/MM/yyyy").format(DateTime.parse("${e.insertedAt}"));
          return Container(
            height: 60,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF3d3d3d) : Color(0xFFbfbfbf),
                    borderRadius: BorderRadius.all(Radius.circular(4))
                  ),
                  child: Icon(
                    PhosphorIcons.files,
                    size: 22.0,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.media.target!.name, 
                        style: TextStyle(
                          fontSize: 15, 
                          overflow: TextOverflow.ellipsis, 
                          fontWeight: FontWeight.w500, 
                          color: isDark ?  Color(0xFFDBDBDB) : Color(0xFF262626)
                        )
                      ),
                      Container(
                        width: 135,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${Utils.showFileSize(e.media.target?.size)}", 
                              style: TextStyle(
                                fontSize: 12, 
                              color: Color(0xFF828282)
                              )
                            ),
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
                            ),
                            Text(
                              '${user.first["full_name"]}', 
                              style: TextStyle(
                                fontSize: 12, 
                                color: Color(0xFF828282),
                                fontWeight: FontWeight.w500
                              )
                            ),
                          ]
                        ),
                      ),
                      Container(
                        // width: 60,
                        child: Text("$itemInsertedAt", style: TextStyle( fontSize: 12,color: Color(0xFF828282))),
                      ),
                    ]
                  ),
                ),
                Container(
                  width: 30,
                  child: Container(

                    child: InkWell(
                      onTap: () {},
                      child: Icon(Icons.more_horiz, color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight,),
                    )
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isDark = auth.theme == ThemeType.DARK;
    return Container(
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Container(
            color: isDark ? Color(0xFF2e2e2e) : Color(0xFFffffff),
            child: Column(
              children: [
                  Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xff2E2E2E) : Colors.white,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: isDark ? Color(0xff5E5E5E) : Color(0xffDBDBDB)))
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 50,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                child: Icon(PhosphorIcons.arrowLeft, size: 20,),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            child: Text(
                              "Files",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              )
                            ),
                          ),
                          SizedBox(width: 50,)
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF5e5e5e), width: 1)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Container(
                        //   color: Colors.red,
                        //   child: Flexible(
                        //     child: Text("dfds"),
                        //   ),
                        // ),
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                selectedType = "image_video";
                              });
                              getDataType(selectedType);
                            },
                            child: Center(
                              child: Container(
                                color: selectedType == "image_video" ? Color(0xFF5e5e5e) : null,
                                 padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(child: Text("$totalImages Image/Video", style: TextStyle(fontSize: 14,
                                color: isDark ? null : selectedType == "image_video" ? Colors.white : Colors.black,
                                ))),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                selectedType = "file";
                              });
                              getDataType("file");
                            },
                            child: Container(
                               color: selectedType != "image_video" ? Color(0xFF5e5e5e) : null,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: Text("$totalFiles Files", style: TextStyle(
                                color: isDark ? null : selectedType != "image_video" ? Colors.white : Colors.black,
                                fontSize: 14,))),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  renderMediaType()
              ],
            ),
          )
        )
      ),
    );
  }
}

//Show Image from FileBackup
class ImageViewer extends StatefulWidget {
  final List<MediaConversation> listImage;
  final int index;

  const ImageViewer({
    Key? key,
    required this.listImage,
    required this.index,
  }) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  int imageIndex = 0;

  @override
  void initState() {
    imageIndex = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MediaConversation data = widget.listImage[imageIndex];
    return Container(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Center(
                child: ExtendedImage.file(
                  File(data.media.target!.pathInDevice ?? ""),
                  clearMemoryCacheWhenDispose: true,
                  enableMemoryCache: true,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.gesture,
                  initGestureConfigHandler: (state) {
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
                )
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
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              child: TextButton(
                                onPressed: () async {
                                  String localPath = data.media.target!.pathInDevice ?? "";
                                  return Share.shareFiles([localPath], mimeTypes: ["image/png"]);
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
          );
        }
      ),
    );
  }
}