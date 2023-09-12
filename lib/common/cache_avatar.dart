import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:workcake/common/utils.dart';

import 'cached_image.dart';

class CachedAvatar extends StatelessWidget {
  final imageUrl;
  final bool isRound;
  final double radius;
  final double height;
  final double width;
  final BoxFit fit;
  final String? name;
  final bool isAvatar;
  final bool full;
  final double fontSize;

  final String noImageAvailable = "https://statics.pancake.vn/web-media/3e/24/0b/bb/09a144a577cf6867d00ac47a751a0064598cd8f13e38d0d569a85e0a.png";

  CachedAvatar(
    this.imageUrl, {
    required this.name,
    required this.width,
    required this.height,
    this.isRound = false,
    this.fit = BoxFit.cover,
    this.isAvatar = false,
    this.fontSize = 12,
    this.full = false,
    this.radius = 50,
  });
  
  @override
  Widget build(BuildContext context) {
    try {
      return SizedBox(
        height: height,
        width: width,
        child: (!Utils.checkedTypeEmpty(imageUrl) || imageUrl == noImageAvailable) 
        ? DefaultAvatar(name: name, fontSize: fontSize, radius: height / 2)
        : ClipOval(
          child: Container(
            color: Colors.white,
            child: CachedNetworkImage(
              cacheKey: imageUrl ?? noImageAvailable,
              imageUrl: imageUrl ?? noImageAvailable,
              fit: BoxFit.cover,
              memCacheHeight: (height*1.5).toInt(),
              memCacheWidth: (width*1.5).toInt(),
              maxHeightDiskCache: 60,
              maxWidthDiskCache: 60,
              repeat: ImageRepeat.repeat,
              placeholder: (context, url) => Container(color: Colors.grey[350]),
              errorWidget: (context, url, error) => CachedNetworkImage(imageUrl: noImageAvailable),
            )
          )
        ),
      );
    } catch (e) {
      return Container( 
        child: DefaultAvatar(name: name, radius: radius)
      );
    }
  }
}