import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:workcake/common/utils.dart';

import 'media_conversation/isolate_media.dart';
import 'media_conversation/model.dart';

class VideoViewer extends StatefulWidget {
  VideoViewer({Key? key, required this.contentUrl, required this.isDirect, required this.data, required this.previewComment, required this.thumnailUrl}) : super(key: key);
  final contentUrl;
  final isDirect;
  final data;
  final previewComment;
  final thumnailUrl;
  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late String contentUrl;
  bool fetch = false;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  double? ratioVideo;
  Size? sizeThumnail;
  late CacheManager cacheManager;

  @override
  void initState() {
    super.initState();
    if (!Utils.checkedTypeEmpty(widget.thumnailUrl)) sizeThumnail = Size(200, 200);
    cacheManager = CacheManager(Config("pan-chat-mobile", maxNrOfCacheObjects: 20, stalePeriod: Duration(days: 1)));
    initPlayer();
  }
  @override
  void dispose(){
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
  
  initPlayer() async {
    try {
      setState(() {
        fetch = true;
      });
      contentUrl = widget.contentUrl;
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

  
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Container(
            // color: Colors.,
            height: ratioVideo != null ? ratioVideo! > 1 ? MediaQuery.of(context).size.width / ratioVideo! : MediaQuery.of(context).size.height * 9 / 10 : 200,
            width:  ratioVideo != null ? ratioVideo! > 1 ? null : MediaQuery.of(context).size.width : null,
            child:  _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized ? Chewie(controller: _chewieController!) : Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Lottie.network("https://assets4.lottiefiles.com/datafiles/riuf5c21sUZ05w6/data.json"),
                ),
                Text("Loading...", style: TextStyle(fontSize: 20),),
              ],
            )),
          )
        ),
      ),
    );
  }
}