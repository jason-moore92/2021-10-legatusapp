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

class PictureMediaWidget extends StatefulWidget {
  final LocalReportModel? localReportModel;
  final MediaModel? mediaModel;
  final int? totalMediaCount;
  final bool? isSelected;
  final bool? selectStatus;
  final bool? isUploading;
  final Function? tapHandler;
  final Function? longPressHandler;

  PictureMediaWidget({
    Key? key,
    @required this.localReportModel,
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

    // Vlad => adding .floorToDouble() to round to lower double value, for iPhones
    picWidth = ((deviceWidth! - widthDp! * 40) / 3).floorToDouble();
    picHeight = ((deviceWidth! - widthDp! * 40) / 3).floorToDouble();

    print(picWidth);

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
    // double iconPadding = widthDp! * 10;
    // TextStyle? textStyle = Theme.of(context).textTheme.overline;

    if (responsiveStyle != "mobile") {
      iconSize = heightDp! * 35;
      // iconPadding = widthDp! * 20;
      // textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black);
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
    widget.tapHandler!();
    // if (widget.selectStatus!) {
    //   if (widget.tapHandler != null) {
    //     widget.tapHandler!();
    //   }
    // } else {
    //   if (mediaPlayProvider.mediaPlayState.selectedMediaModel!.rank !=
    //           widget.mediaModel!.rank &&
    //       mediaPlayProvider.mediaPlayState.selectedMediaModel!.uuid !=
    //           widget.mediaModel!.uuid) {
    //     ///
    //     mediaPlayProvider.setMediaPlayState(
    //       mediaPlayProvider.mediaPlayState
    //           .update(isNew: true, selectedMediaModel: widget.mediaModel),
    //     );
    //   } else if (mediaPlayProvider.mediaPlayState.selectedMediaModel!.rank ==
    //           widget.mediaModel!.rank &&
    //       mediaPlayProvider.mediaPlayState.selectedMediaModel!.uuid ==
    //           widget.mediaModel!.uuid) {
    //     ///
    //     mediaPlayProvider.setMediaPlayState(
    //       mediaPlayProvider.mediaPlayState.update(
    //         isNew: false,
    //       ),
    //     );
    //   } else {}
    //   _viewHandler(context);
    // }
  }

  Future<void> _viewHandler(BuildContext context) async {
    pushNewScreen(
      context,
      screen: GallaryPage(
        localReportModel: widget.localReportModel,
        mediaModel: widget.mediaModel,
      ),
      pageTransitionAnimation: PageTransitionAnimation.fade,
      withNavBar: false,
    );
  }
}

class GallaryPage extends StatefulWidget {
  final LocalReportModel? localReportModel;
  final MediaModel? mediaModel;

  const GallaryPage(
      {Key? key, @required this.localReportModel, @required this.mediaModel})
      : super(key: key);

  @override
  _GallaryPageState createState() => _GallaryPageState();
}

class _GallaryPageState extends State<GallaryPage> {
  @override
  Widget build(BuildContext context) {
    double heightDp = ScreenUtil().setWidth(1);
    List<MediaModel> medias = [];
    int index = 0;

    for (var i = 0; i < widget.localReportModel!.medias!.length; i++) {
      if (widget.localReportModel!.medias![i].type == MediaType.picture) {
        medias.add(widget.localReportModel!.medias![i]);
        if (widget.mediaModel!.rank ==
                widget.localReportModel!.medias![i].rank &&
            widget.mediaModel!.uuid ==
                widget.localReportModel!.medias![i].uuid) {
          index = medias.length - 1;
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.close, size: heightDp * 25, color: Colors.white),
          ),
        ],
      ),
      body: Swiper(
        itemCount: medias.length,
        pagination: SwiperPagination(builder: SwiperPagination.rect),
        loop: false,
        index: index,
        control: SwiperControl(color: Colors.white),
        itemBuilder: (BuildContext context, int index) {
          File file = File(medias[index].path!);

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
                  Image imageWidget = Image.file(
                    file,
                    fit: BoxFit.cover,
                  );

                  return RotatedBox(
                    quarterTurns: 1,
                    child: imageWidget,
                  );
                } else {
                  Image imageWidget = Image.file(
                    file,
                    fit: BoxFit.cover,
                  );

                  return imageWidget;
                }
              } else {
                return Container(
                  child: Theme(
                    data:
                        Theme.of(context).copyWith(brightness: Brightness.dark),
                    child: Center(child: CupertinoActivityIndicator()),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
