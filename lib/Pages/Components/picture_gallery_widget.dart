import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:legatus/Models/index.dart';

class PictureGalleryWidget extends StatefulWidget {
  final MediaModel? mediaModel;

  const PictureGalleryWidget({Key? key, @required this.mediaModel}) : super(key: key);

  @override
  PictureGalleryWidgetState createState() => PictureGalleryWidgetState();
}

class PictureGalleryWidgetState extends State<PictureGalleryWidget> {
  @override
  Widget build(BuildContext context) {
    File file = File(widget.mediaModel!.path!);

    Image image = Image.file(file);
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((ImageInfo info, bool _) => completer.complete(info.image)),
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
                    data: Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: const Center(child: CupertinoActivityIndicator()),
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
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Theme(
                    data: Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: const Center(child: CupertinoActivityIndicator()),
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
