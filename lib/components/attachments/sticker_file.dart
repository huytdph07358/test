import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:workcake/common/palette.dart';
import 'package:workcake/models/models.dart';
// ignore: implementation_imports
import 'package:lottie/src/providers/lottie_provider.dart' show sharedLottieCache;

  class StickerFile extends StatefulWidget {
    StickerFile({
      required Key key,
      this.data,
      this.isPreview = false,
    }) : super(key: key);

    final data;
    final bool isPreview;

    @override
    _StickerFileState createState() => _StickerFileState();
  }

class _StickerFileState extends State<StickerFile> with SingleTickerProviderStateMixin{
  get data => widget.data;
  bool get isPreview => widget.isPreview;
  late Future<LottieComposition> _composition;
  bool animate = false;
  bool success = true;

  @override
  void initState() {
    super.initState();

    if(data['type'] != 'static') {
      _composition = NetworkLottie(data["content_url"]).load();
      _composition.catchError((err, t) {
        success = false;
      });
    }
  }

  onFetchingSticker() {
    if(!success) {
      sharedLottieCache.clear();
      _composition = NetworkLottie(data["content_url"]).load().then(
        (LottieComposition value) {
          this.setState(() {
            success = true;
          });

          return value;
        },
      );
    }
  }

  onPlaySticker(LottieComposition composition) {
    if(!animate) {
      setState(() {
        animate = true;
      });

      Future.delayed(composition.duration, () {
        if(this.mounted) setState(() {
          animate = false;
        });
      });
    }
  }

  Widget renderStickerAnimate() {
    final bool isDark = Provider.of<Auth>(context).theme == ThemeType.DARK;

    return FutureBuilder<LottieComposition>(
      future: _composition,
      builder: (context, snapshot) {
        LottieComposition? composition = snapshot.data;

        if (composition != null) {
          return isPreview
          ? CustomDrawer(composition, key: widget.key)
          : InkWell(
            onTap: () => onPlaySticker(composition),
            child: Lottie(
              key: widget.key,
              animate: animate,
              composition: composition,
              frameRate: FrameRate.max,
              addRepaintBoundary: true,
            ),
          );
        } else {
          onFetchingSticker();
          return Container(
            padding: EdgeInsets.all(isPreview ? 8 : 48),
            child: SvgPicture.asset(
              'assets/icons/sticker_loader.svg',
              width: 38, height: 38,
              color: isDark ? Palette.defaultTextDark : Palette.defaultTextLight.withOpacity(0.25),
              clipBehavior: Clip.none
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isPreview ? null : 148, height: isPreview ? null : 148,
      child: data['type'] != 'static'
      ? renderStickerAnimate()
      : ExtendedImage.network(
        data["content_url"],
        borderRadius: BorderRadius.all(Radius.circular(4)),
        shape: BoxShape.rectangle
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final LottieComposition composition;

  const CustomDrawer(this.composition, {Key? key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _Painter(composition),
        size: const Size(80, 80),
        isComplex: true
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final LottieDrawable drawable;

  _Painter(LottieComposition composition)
      : drawable = LottieDrawable(composition);

  @override
  void paint(Canvas canvas, Size size) {
    var destRect = Offset(0, 0 ~/ 10 * 80.0) & size;
    drawable
      ..setProgress(0)
      ..draw(canvas, destRect);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}