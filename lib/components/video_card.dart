import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:workcake/common/utils.dart';
import 'package:workcake/components/thread_view.dart';
import 'package:workcake/components/video_viewer.dart';

import '../models/models.dart';
import 'media_conversation/isolate_media.dart';
import 'media_conversation/model.dart';

class VideoCard extends StatefulWidget{
  VideoCard({
    Key? key,
    required this.contentUrl,
    required this.id,
    this.thumnailUrl,
    this.isDirect = false,
    this.data = const {},
    this.previewComment = false
  }) : super(key: key);

  final String contentUrl;
  final String? thumnailUrl;
  final id;
  final bool isDirect;
  final Map data; // doi voi direct, cac video cu se ko co localpath => dung content_url

  final previewComment;

  @override
  State<StatefulWidget> createState() {
    return _WidgetCardState();
  }
}
class _WidgetCardState extends State<VideoCard>{
  double? ratioVideo;
  late CacheManager cacheManager;
  bool fetch = false;
  Size? sizeThumnail;
  String get contentUrl => widget.contentUrl;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
     if (widget.previewComment) {
      initPlayer();
    }
  }

  initPlayer() async {
    try {
      setState(() {
        fetch = true;
      });
      if(!widget.isDirect) {
        // hien tai tren ios, file lay tu cacheManager dang ko co duoi mo rong
        // => dung serrvice cua ServiceMediade tai file xuong
        String? pathInDevice  = await ServiceMedia.getDownloadedPath(contentUrl);
        if (pathInDevice != null){
          _videoPlayerController = VideoPlayerController.file(File(pathInDevice));
        }
        else {
          _videoPlayerController = VideoPlayerController.network(contentUrl);
          IsolateMedia.mainSendPort.send!({
            "type": "download_video_channel",
            "data": {
              "url": contentUrl,
              "cache_path": (await getTemporaryDirectory()).path
            }
          });
        }
      } else {
        if (widget.data["type"] == "remote"){
          _videoPlayerController = VideoPlayerController.network(contentUrl);
        } else {
          String? pathInDevice  = await ServiceMedia.getDownloadedPath(contentUrl);
          final File file = File.fromUri(Uri.parse(pathInDevice ?? ''));
          _videoPlayerController = VideoPlayerController.file(file);
        }
      }
      await _videoPlayerController?.initialize();
      _chewieController = ChewieController(
        aspectRatio: _videoPlayerController?.value.aspectRatio,
        videoPlayerController: _videoPlayerController!,
        looping: false,
        autoPlay: widget.previewComment ? false : widget.isDirect ? false : true,
        additionalOptions: (context) {
          return <OptionItem> [
            OptionItem(
              onTap: () async {
                try {
                  Navigator.pop(context);
                  Fluttertoast.showToast(
                    msg: "Downloading",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    fontSize: 13
                  );
                  if (widget.isDirect) {
                    String? pathInDevice  = await ServiceMedia.getDownloadedPath(contentUrl);
                    await GallerySaver.saveVideo(pathInDevice!);
                  }
                  else {
                    await GallerySaver.saveVideo(contentUrl);
                  }
                  Fluttertoast.showToast(
                    msg: "Downloaded successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    fontSize: 13
                  );
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: "Downloaded failure",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    fontSize: 13
                  );
                  print(e);
                }
              }, 
              iconData: PhosphorIcons.downloadSimple, 
              title: "Download this video"
            )
          ];
        }
      );
      ratioVideo = _videoPlayerController?.value.aspectRatio;
      setState(() {
        fetch = false;
      });
    } catch (e, t) {
      setState(() {
        fetch = false;
      });
      print("initPlayer: $e, $t");
    }
  }

  Widget preloadVideo() {
    final isDark = Provider.of<Auth>(context).theme == ThemeType.DARK;

    return Container(
      width: 200, height: 200,
      color: isDark ? Color(0xff1C1D21) : Color(0xffEAEEF1),
      child: Image.asset(
        'assets/images/preload_video_${isDark ? 'dark' : 'light'}.png',
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2.5),
      padding: EdgeInsets.only(top: 8),
      height: ratioVideo != null ? MediaQuery.of(context).size.width * 0.8 / ratioVideo! : 200,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context, 
            builder: (BuildContext context) {
              return VideoViewer(contentUrl: contentUrl, data: widget.data, isDirect: widget.isDirect, previewComment: widget.previewComment, thumnailUrl: widget.thumnailUrl,);
            }
          );
        },
        child: Container(
          child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : CachedNetworkImage(
              imageUrl: widget.thumnailUrl ?? 'https://statics.pancake.vn/panchat-dev/2022/7/13/a09eefc0163c17427affb4b6bf939e337aeb54da.mp4',
              placeholder: (context, url) => preloadVideo(),
              errorWidget: (context, url, error) => preloadVideo(),
              imageBuilder: (context, imageProvider) {
                return Container(
                  width: 200, height: 200,
                  child: Stack(
                    children: [
                      Utils.checkedTypeEmpty(widget.thumnailUrl) ? MeasureSize(
                        onChange: (Size size){
                          if (this.mounted) setState((){
                            sizeThumnail = size;
                          });
                        },
                        child: Container(
                          width: 200, height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Color(0xff1C1D21)
                          ),
                          child: Image(image: imageProvider),
                        )
                      ) : Positioned(
                        child: Container(
                          height: ratioVideo != null ? MediaQuery.of(context).size.width * 0.8 / ratioVideo! : 200,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 75, 73, 73),
                            borderRadius: BorderRadius.all(Radius.circular(5))
                          ),
                        )
                      ),
                      sizeThumnail == null
                      ? Container(
                        child: Center(
                          child: Icon(Icons.play_arrow_sharp,
                            size: 30,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ) 
                      : Positioned(
                        top: Utils.checkedTypeEmpty(widget.thumnailUrl) ? sizeThumnail!.height / 2 - 20 : sizeThumnail!.height / 2 - 30,
                        left: Utils.checkedTypeEmpty(widget.thumnailUrl) ? sizeThumnail!.width / 2 - 20 : sizeThumnail!.width / 1.5,
                        child: Center(
                          child: Container(
                            child: fetch ? CircularProgressIndicator() : Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(24)
                              ),
                              child: Icon(Icons.play_arrow_sharp,
                              size: 30,
                              color: Color(0xFFFFFFFF),
                              )
                            )
                          ),
                        )
                      ),
                    ]
                  ),
                );
              },
              fadeInDuration: const Duration(milliseconds: 200),
              fadeOutDuration: const Duration(milliseconds: 200),
            )
        ),
      )
    );
  }
}