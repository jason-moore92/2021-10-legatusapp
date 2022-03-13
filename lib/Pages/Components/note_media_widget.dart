import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';

class NoteMediaWidget extends StatefulWidget {
  final MediaModel? mediaModel;
  final int? totalMediaCount;
  final bool? isSelected;
  final bool? isUploading;
  final Function? tapHandler;
  final Function? longPressHandler;

  NoteMediaWidget({
    Key? key,
    @required this.mediaModel,
    @required this.totalMediaCount,
    this.isSelected = false,
    this.isUploading = false,
    @required this.tapHandler,
    @required this.longPressHandler,
  }) : super(key: key);

  @override
  _NoteMediaWidgetState createState() => _NoteMediaWidgetState();
}

class _NoteMediaWidgetState extends State<NoteMediaWidget> {
  double widthDp = ScreenUtil().setWidth(1);
  double heightDp = ScreenUtil().setWidth(1);
  double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
  String responsiveStyle = "";

  Timer? uploadTimer;
  double angle = 0;

  double? widgetWidth;
  double? widgetHeight;

  GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (_key.currentContext == null) return;
      RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
      widgetWidth = renderBox.size.width;
      widgetHeight = renderBox.size.height;
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (uploadTimer != null) uploadTimer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >= ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "desktop";
    } else if (MediaQuery.of(context).size.width >= ResponsiveDesignSettings.mobileMaxWidth &&
        MediaQuery.of(context).size.width < ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "tablet";
    } else if (MediaQuery.of(context).size.width < ResponsiveDesignSettings.mobileMaxWidth) {
      responsiveStyle = "mobile";
    }

    double iconSize = heightDp * 20;
    // double iconPadding = widthDp * 10;
    // TextStyle? textStyle = Theme.of(context).textTheme.overline;

    if (responsiveStyle != "mobile") {
      iconSize = heightDp * 35;
      // iconPadding = widthDp * 20;
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

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (widget.tapHandler != null) {
              widget.tapHandler!();
            }
          },
          onLongPress: () {
            if (widget.longPressHandler != null) {
              widget.longPressHandler!();
            }
          },
          child: Container(
            key: _key,
            margin: EdgeInsets.symmetric(vertical: heightDp * 5),
            padding: EdgeInsets.symmetric(horizontal: widthDp * 5, vertical: heightDp * 10),
            decoration: BoxDecoration(
              color: Color(0xFFE7E7E7),
              borderRadius: BorderRadius.circular(heightDp * 0),
              border: Border.all(
                color: widget.isSelected! ? AppColors.yello : Colors.transparent,
                width: widget.isSelected! ? 3 : 0,
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: widthDp * 5),
                Stack(
                  children: [
                    Stack(
                      children: [
                        Icon(
                          widget.mediaModel!.state == "error"
                              ? Icons.report_problem_outlined
                              : widget.mediaModel!.state == "uploaded"
                                  ? Icons.cloud_done_outlined
                                  : Icons.cloud_off_outlined,
                          size: iconSize,
                          color: widget.mediaModel!.state == "error" || widget.mediaModel!.state == "uploaded" ? Colors.white : Colors.transparent,
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
                    )
                  ],
                ),
                SizedBox(width: widthDp * 10),
                Expanded(
                  child: Text(
                    "${widget.mediaModel!.content!}",
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    MediaInfoDialog.show(
                      context,
                      mediaModel: widget.mediaModel,
                      totalMediaCount: widget.totalMediaCount,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(heightDp * 5),
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
              ],
            ),
          ),
        ),
        if (widget.isUploading!)
          Positioned(
            top: heightDp * 5,
            child: Container(
              width: widgetWidth,
              height: widgetHeight != null ? widgetHeight! - heightDp * 10 : widgetHeight,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: angle / 180 * pi,
                  child: Icon(Icons.autorenew, size: iconSize, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
