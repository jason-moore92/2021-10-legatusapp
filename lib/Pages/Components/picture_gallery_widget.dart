import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:card_swiper/card_swiper.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';
import 'package:legatus/Providers/MediaPlayProvider/index.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class PictureGalleryWidget extends StatefulWidget {
  final MediaModel? mediaModel;

  const PictureGalleryWidget({Key? key, @required this.mediaModel})
      : super(key: key);

  @override
  _PictureGalleryWidgetState createState() => _PictureGalleryWidgetState();
}

class _PictureGalleryWidgetState extends State<PictureGalleryWidget> {
  @override
  Widget build(BuildContext context) {
    double heightDp = ScreenUtil().setWidth(1);
    double statusbarHeight = ScreenUtil().statusBarHeight;

    File file = File(widget.mediaModel!.path!);

    Image image = new Image.file(file);
    Completer<ui.Image> completer = new Completer<ui.Image>();
    image.image.resolve(new ImageConfiguration()).addListener(
          ImageStreamListener(
              (ImageInfo info, bool _) => completer.complete(info.image)),
        );

    return FutureBuilder<ui.Image>(
      future: completer.future,
      builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.width > snapshot.data!.height) {
            ExtendedImage imageWidget = ExtendedImage.file(
              file,
              // height: MediaQuery.of(context).size.height * 0.7,
              // fit: BoxFit.fitHeight,
              mode: ExtendedImageMode.gesture,
              enableMemoryCache: true,
              loadStateChanged: (ExtendedImageState state) {
                if (state.extendedImageLoadState == LoadState.loading) {
                  return Center(
                      child: Theme(
                    data:
                        Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: Center(child: CupertinoActivityIndicator()),
                  ));
                }

                return null;
              },
              initGestureConfigHandler: (state) {
                return GestureConfig(
                  minScale: 0.9,
                  animationMinScale: 0.7,
                  maxScale: 8.0,
                  animationMaxScale: 8.5,
                  speed: 1.0,
                  inertialSpeed: 100.0,
                  initialScale: 1.0,
                  inPageView: false,
                  initialAlignment: InitialAlignment.center,
                );
              },
            );

            return Center(
              child: imageWidget,
            );
          } else {
            ExtendedImage imageWidget = ExtendedImage.file(
              file,
              // width: MediaQuery.of(context).size.height *
              //     0.7 /
              //     (snapshot.data!.height / snapshot.data!.width),
              // fit: BoxFit.fitWidth,
              mode: ExtendedImageMode.gesture,
              enableMemoryCache: true,
              initGestureConfigHandler: (state) {
                return GestureConfig(
                  minScale: 0.9,
                  animationMinScale: 0.7,
                  maxScale: 8.0,
                  animationMaxScale: 8.5,
                  speed: 1.0,
                  inertialSpeed: 100.0,
                  initialScale: 1.0,
                  inPageView: false,
                  initialAlignment: InitialAlignment.center,
                );
              },
            );

            return Center(
              child: imageWidget,
            );
          }
        } else {
          return Material(
            color: Colors.transparent,
            child: Wrap(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Theme(
                    data:
                        Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: Center(child: CupertinoActivityIndicator()),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
