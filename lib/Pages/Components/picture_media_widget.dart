import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';
import 'package:legatus/Providers/MediaPlayProvider/index.dart';
import 'package:provider/provider.dart';

class PictureMediaWidget extends StatefulWidget {
  final MediaModel? mediaModel;
  final int? totalMediaCount;
  final bool? isSelected;
  final bool? selectStatus;
  final bool? isUploading;
  final Function? tapHandler;
  final Function? longPressHandler;

  PictureMediaWidget({
    Key? key,
    @required this.mediaModel,
    @required this.totalMediaCount,
    this.isSelected = false,
    this.isUploading = false,
    @required this.selectStatus,
    @required this.tapHandler,
    @required this.longPressHandler,
  }) : super(key: key);

  @override
  _PictureMediaWidgetState createState() => _PictureMediaWidgetState();
}

class _PictureMediaWidgetState extends State<PictureMediaWidget> {
  double? deviceWidth;
  double? statusbarHeight;
  double? widthDp;
  double? heightDp;
  double? fontSp;
  double? picWidth;
  double? picHeight;
  String responsiveStyle = "";

  Timer? uploadTimer;
  double angle = 0;

  @override
  void dispose() {
    if (uploadTimer != null) uploadTimer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceWidth = 1.sw;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    statusbarHeight = ScreenUtil().statusBarHeight;

    picWidth = ((deviceWidth! - widthDp! * 40) / 3) - 1;
    picHeight = ((deviceWidth! - widthDp! * 40) / 3) - 1;

    if (MediaQuery.of(context).size.width >=
        ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "desktop";
    } else if (MediaQuery.of(context).size.width >=
            ResponsiveDesignSettings.mobileMaxWidth &&
        MediaQuery.of(context).size.width <
            ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "tablet";
    } else if (MediaQuery.of(context).size.width <
        ResponsiveDesignSettings.mobileMaxWidth) {
      responsiveStyle = "mobile";
    }

    double iconSize = heightDp! * 20;
    double iconPadding = widthDp! * 10;
    TextStyle? textStyle = Theme.of(context).textTheme.overline;

    if (responsiveStyle != "mobile") {
      iconSize = heightDp! * 35;
      iconPadding = widthDp! * 20;
      textStyle =
          Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black);
    }

    if (widget.isUploading!) {
      if (uploadTimer != null) uploadTimer!.cancel();
      uploadTimer = Timer.periodic(Duration(milliseconds: 10), (uploadTimer) {
        angle += 10;
        setState(() {});
      });
    } else {
      angle = 0;
    }

    return Consumer<MediaPlayProvider>(
        builder: (context, mediaPlayProvider, _) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: heightDp! * 5),
        child: Stack(
          children: [
            GestureDetector(
              // onDoubleTap: () {
              //   _viewHandler(context);
              // },
              onTap: () => _tapHandler(context, mediaPlayProvider),
              onLongPress: () {
                if (widget.longPressHandler != null) {
                  widget.longPressHandler!();
                }
              },
              child: Container(
                width: picWidth,
                height: picHeight,
                decoration: BoxDecoration(
                  color: Color(0xFFE7E7E7),
                  borderRadius: BorderRadius.circular(heightDp! * 0),
                  border: Border.all(
                    color: widget.isSelected!
                        ? AppColors.yello
                        : Colors.transparent,
                    width: widget.isSelected! ? 3 : 0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(heightDp! * 0),
                  child: Image.file(
                    widget.mediaModel!.thumPath != ""
                        ? File(widget.mediaModel!.thumPath!)
                        : File(widget.mediaModel!.path!),
                    width: picWidth,
                    height: picHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Container(
                        width: picWidth,
                        height: picHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(heightDp! * 0),
                          color: Color(0xFFE7E7E7),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.not_interested_outlined,
                          size: heightDp! * 30,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: heightDp! * 5,
              left: heightDp! * 5,
              child: Stack(
                children: [
                  Icon(
                    widget.mediaModel!.state == "error"
                        ? Icons.report_problem_outlined
                        : widget.mediaModel!.state == "uploaded"
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_off_outlined,
                    size: iconSize,
                    color: widget.mediaModel!.state == "error" ||
                            widget.mediaModel!.state == "uploaded"
                        ? Colors.white
                        : Colors.transparent,
                  ),
                  Icon(
                    widget.mediaModel!.state == "error"
                        ? Icons.report_problem
                        : widget.mediaModel!.state == "uploaded"
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                    size: iconSize,
                    color: widget.mediaModel!.state == "error"
                        ? AppColors.red
                        : widget.mediaModel!.state == "uploaded"
                            ? AppColors.green
                            : AppColors.red.withOpacity(0.6),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  MediaInfoDialog.show(
                    context,
                    mediaModel: widget.mediaModel,
                    totalMediaCount: widget.totalMediaCount,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(heightDp! * 5),
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: iconSize,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.info,
                        size: iconSize,
                        color: AppColors.yello,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.isUploading!)
              Container(
                width: picWidth,
                height: picHeight,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(heightDp! * 0),
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: angle / 180 * pi,
                    child: Icon(Icons.autorenew,
                        size: picHeight! / 2, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  void _tapHandler(BuildContext context, MediaPlayProvider mediaPlayProvider) {
    if (widget.selectStatus!) {
      if (widget.tapHandler != null) {
        widget.tapHandler!();
      }
    } else {
      if (mediaPlayProvider.mediaPlayState.selectedMediaModel!.rank !=
              widget.mediaModel!.rank &&
          mediaPlayProvider.mediaPlayState.selectedMediaModel!.uuid !=
              widget.mediaModel!.uuid) {
        ///
        mediaPlayProvider.setMediaPlayState(
          mediaPlayProvider.mediaPlayState
              .update(isNew: true, selectedMediaModel: widget.mediaModel),
        );
      } else if (mediaPlayProvider.mediaPlayState.selectedMediaModel!.rank ==
              widget.mediaModel!.rank &&
          mediaPlayProvider.mediaPlayState.selectedMediaModel!.uuid ==
              widget.mediaModel!.uuid) {
        ///
        mediaPlayProvider.setMediaPlayState(
          mediaPlayProvider.mediaPlayState.update(
            isNew: false,
          ),
        );
      } else {}
      _viewHandler(context);
    }
  }

  void _viewHandler(BuildContext context) {
    File file = File(widget.mediaModel!.path!);

    Image image = new Image.file(file);
    Completer<ui.Image> completer = new Completer<ui.Image>();
    image.image.resolve(new ImageConfiguration()).addListener(
          ImageStreamListener(
              (ImageInfo info, bool _) => completer.complete(info.image)),
        );

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Wrap(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<ui.Image>(
                      future: completer.future,
                      builder: (BuildContext context,
                          AsyncSnapshot<ui.Image> snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.width > snapshot.data!.height) {
                            ExtendedImage imageWidget = ExtendedImage.file(
                              file,
                              height: MediaQuery.of(context).size.height * 0.7,
                              fit: BoxFit.fitHeight,
                              mode: ExtendedImageMode.gesture,
                              enableMemoryCache: true,
                              loadStateChanged: (ExtendedImageState state) {
                                if (state.extendedImageLoadState ==
                                    LoadState.loading) {
                                  return Center(
                                      child: Theme(
                                    data: Theme.of(context)
                                        .copyWith(brightness: Brightness.dark),
                                    child: Center(
                                        child: CupertinoActivityIndicator()),
                                  ));
                                }
                              },
                              initGestureConfigHandler: (state) {
                                return GestureConfig(
                                  minScale: 0.9,
                                  animationMinScale: 0.7,
                                  maxScale: 3.0,
                                  animationMaxScale: 3.5,
                                  speed: 1.0,
                                  inertialSpeed: 100.0,
                                  initialScale: 1.0,
                                  inPageView: false,
                                  initialAlignment: InitialAlignment.center,
                                );
                              },
                            );

                            return Material(
                              color: Colors.transparent,
                              child: Wrap(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: Column(
                                      children: [
                                        SizedBox(height: heightDp! * 10),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.7 /
                                              (snapshot.data!.width /
                                                  snapshot.data!.height),
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            icon: Icon(Icons.close_outlined,
                                                size: heightDp! * 30,
                                                color: Colors.white),
                                          ),
                                        ),
                                        SizedBox(height: heightDp! * 10),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.7 /
                                              (snapshot.data!.width /
                                                  snapshot.data!.height),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.7,
                                          child: RotatedBox(
                                            quarterTurns: 1,
                                            child: imageWidget,
                                          ),
                                        ),
                                        SizedBox(
                                            height: statusbarHeight! +
                                                heightDp! * 30),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            ExtendedImage imageWidget = ExtendedImage.file(
                              file,
                              width: MediaQuery.of(context).size.height *
                                  0.7 /
                                  (snapshot.data!.height /
                                      snapshot.data!.width),
                              fit: BoxFit.fitWidth,
                              mode: ExtendedImageMode.gesture,
                              enableMemoryCache: true,
                              initGestureConfigHandler: (state) {
                                return GestureConfig(
                                  minScale: 0.9,
                                  animationMinScale: 0.7,
                                  maxScale: 3.0,
                                  animationMaxScale: 3.5,
                                  speed: 1.0,
                                  inertialSpeed: 100.0,
                                  initialScale: 1.0,
                                  inPageView: false,
                                  initialAlignment: InitialAlignment.center,
                                );
                              },
                            );

                            return Material(
                              color: Colors.transparent,
                              child: Wrap(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: Column(
                                      children: [
                                        SizedBox(height: heightDp! * 10),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.7 /
                                              (snapshot.data!.height /
                                                  snapshot.data!.width),
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            icon: Icon(Icons.close_outlined,
                                                size: heightDp! * 30,
                                                color: Colors.white),
                                          ),
                                        ),
                                        SizedBox(height: heightDp! * 10),
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.7 /
                                              (snapshot.data!.height /
                                                  snapshot.data!.width),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.7,
                                          child: imageWidget,
                                        ),
                                        SizedBox(
                                            height: statusbarHeight! +
                                                heightDp! * 30),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
                                    data: Theme.of(context)
                                        .copyWith(brightness: Brightness.dark),
                                    child: Center(
                                        child: CupertinoActivityIndicator()),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
