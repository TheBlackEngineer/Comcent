import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final String imageUrl;
  ImageView({@required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExtendedImageSlidePage(
        slideAxis: SlideAxis.vertical,
        slideType: SlideType.wholePage,
        child: ExtendedImage(
          //disable to stop image sliding off page && entering dead end without back button.
          //setting to false means it won't slide at all.
          enableSlideOutPage: true,
          mode: ExtendedImageMode.gesture,
          initGestureConfigHandler: (state) => GestureConfig(
            maxScale: 3.0,
          ),
          fit: BoxFit.scaleDown,
          image: CachedNetworkImageProvider(
            imageUrl,
          ),
        ),
      ),
    );
  }
}