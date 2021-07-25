import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Dialogs/index.dart';
import 'package:photo_view/photo_view.dart';

class PictureMediaWidget extends StatelessWidget {
  final MediaModel? mediaModel;
  final int? totalMediaCount;
  final bool? isSelected;
  final Function? tapHandler;
  final Function? longPressHandler;

  PictureMediaWidget({
    Key? key,
    @required this.mediaModel,
    @required this.totalMediaCount,
    this.isSelected = false,
    @required this.tapHandler,
    @required this.longPressHandler,
  }) : super(key: key);

  double? deviceWidth;
  double? statusbarHeight;
  double? widthDp;
  double? heightDp;
  double? fontSp;
  double? picWidth;
  double? picHeight;

  @override
  Widget build(BuildContext context) {
    deviceWidth = 1.sw;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    statusbarHeight = ScreenUtil().statusBarHeight;

    picWidth = (deviceWidth! - widthDp! * 40) / 3;
    picHeight = (deviceWidth! - widthDp! * 40) / 3;
    return Container(
      padding: EdgeInsets.symmetric(vertical: heightDp! * 5),
      child: Stack(
        children: [
          GestureDetector(
            onDoubleTap: () {
              _viewHandler(context);
            },
            onTap: () {
              if (tapHandler != null) {
                tapHandler!();
              }
            },
            onLongPress: () {
              if (longPressHandler != null) {
                longPressHandler!();
              }
            },
            child: Container(
              width: picWidth,
              height: picHeight,
              decoration: BoxDecoration(
                color: Color(0xFFE7E7E7),
                borderRadius: BorderRadius.circular(heightDp! * 6),
                border: Border.all(
                  color: isSelected! ? AppColors.yello : Colors.transparent,
                  width: isSelected! ? 3 : 0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(heightDp! * 4),
                child: Image.file(
                  File(mediaModel!.path!),
                  width: picWidth,
                  height: picHeight,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return Container(
                      width: picWidth,
                      height: picHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(heightDp! * 4),
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
            child: Icon(
              mediaModel!.state == "uploaded" ? Icons.cloud_done : Icons.cloud_off_sharp,
              size: heightDp! * 20,
              color: mediaModel!.state == "uploaded" ? AppColors.green : AppColors.red.withOpacity(0.6),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                MediaInfoDialog.show(
                  context,
                  mediaModel: mediaModel,
                  totalMediaCount: totalMediaCount,
                );
              },
              child: Container(
                padding: EdgeInsets.all(heightDp! * 5),
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: heightDp! * 20,
                      color: Colors.white,
                    ),
                    Icon(
                      Icons.info,
                      size: heightDp! * 20,
                      color: AppColors.yello,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewHandler(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
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
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(Icons.close_outlined, size: heightDp! * 30, color: Colors.white),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ExtendedImage.file(
                        File(mediaModel!.path!),
                        width: MediaQuery.of(context).size.width * 0.8,
                        fit: BoxFit.fitWidth,
                        mode: ExtendedImageMode.gesture,
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
                      ),
                    ),
                    SizedBox(height: statusbarHeight! + heightDp! * 20),
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
