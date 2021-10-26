import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Models/LocalReportModel.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/App/responsive_settings.dart';
import 'package:legatus/generated/locale_keys.g.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

// ignore: must_be_immutable
class LocalReportWidget extends StatelessWidget {
  final LocalReportModel? localReportModel;
  final bool? isLoading;

  LocalReportWidget({Key? key, @required this.localReportModel, @required this.isLoading}) : super(key: key);

  /// Responsive design variables
  double? deviceWidth;
  double? deviceHeight;
  double? statusbarHeight;
  double? bottomBarHeight;
  double? appbarHeight;
  double? widthDp;
  double? heightDp;
  double? heightDp1;
  double? fontSp;
  ///////////////////////////////

  @override
  Widget build(BuildContext context) {
    /// Responsive design variables
    deviceWidth = 1.sw;
    deviceHeight = 1.sh;
    statusbarHeight = ScreenUtil().statusBarHeight;
    bottomBarHeight = ScreenUtil().bottomBarHeight;
    appbarHeight = AppBar().preferredSize.height;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    heightDp1 = ScreenUtil().setHeight(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    ///////////////////////////////

    if (deviceWidth! >= ResponsiveDesignSettings.tabletDesignWidth) {
      fontSp = fontSp! * 1.5;
      widthDp = widthDp! * 1.5;
      heightDp = heightDp! * 1.5;
      heightDp1 = heightDp1! * 1.5;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: widthDp! * 15, vertical: heightDp! * 10),
      color: Colors.transparent,
      child: isLoading! ? _shimmerWidget(context) : Container(child: _mainPanel(context)),
    );
  }

  Widget _shimmerWidget(context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      direction: ShimmerDirection.ltr,
      enabled: isLoading!,
      period: Duration(milliseconds: 1000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                color: Colors.white,
                child: Text("report name", style: Theme.of(context).textTheme.subtitle2),
              ),
              Container(
                color: Colors.white,
                child: Text(
                  "2021-02-34 34:45",
                  style: Theme.of(context).textTheme.caption!.copyWith(color: AppColors.yello),
                ),
              ),
            ],
          ),

          ///
          SizedBox(height: heightDp! * 5),
          Row(
            children: [
              Container(
                color: Colors.white,
                child: Icon(Icons.location_on_outlined, size: heightDp! * 20, color: Colors.white),
              ),
              SizedBox(width: widthDp! * 10),
              Container(
                color: Colors.white,
                child: Text(
                  "report city",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ],
          ),

          ///
          SizedBox(height: heightDp! * 5),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Icon(Icons.collections_outlined, size: heightDp! * 15, color: Colors.white),
                    ),
                    Container(
                      color: Colors.white,
                      child: Text(
                        LocaleKeys.LocalReportWidgetString_photos.tr(),
                        style: Theme.of(context).textTheme.overline,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: widthDp! * 3),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Icon(Icons.mic_none, size: heightDp! * 15, color: Colors.white),
                    ),
                    Container(
                      color: Colors.white,
                      child: Text(
                        LocaleKeys.LocalReportWidgetString_audios.tr(),
                        style: Theme.of(context).textTheme.overline,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: widthDp! * 3),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Icon(Icons.sticky_note_2_outlined, size: heightDp! * 15, color: Colors.white),
                    ),
                    Container(
                      color: Colors.white,
                      child: Text(
                        LocaleKeys.LocalReportWidgetString_notes.tr(),
                        style: Theme.of(context).textTheme.overline,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: widthDp! * 3),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Icon(Icons.video_library_outlined, size: heightDp! * 15, color: Colors.white),
                    ),
                    Container(
                      color: Colors.white,
                      child: Text(
                        LocaleKeys.LocalReportWidgetString_videos.tr(),
                        style: Theme.of(context).textTheme.overline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          ///
          SizedBox(height: heightDp! * 5),
          Row(
            children: [
              Container(
                color: Colors.white,
                child: Icon(Icons.cloud_done_outlined, size: heightDp! * 20, color: AppColors.green),
              ),
              SizedBox(width: widthDp! * 3),
              Container(
                color: Colors.white,
                child: Text(
                  LocaleKeys.LocalReportWidgetString_allMediaUpload.tr(),
                  style: Theme.of(context).textTheme.overline,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _mainPanel(BuildContext context) {
    int photosCount = 0;
    int audiosCount = 0;
    int notesCount = 0;
    int videosCount = 0;
    int totalCount = 0;
    int nonUploadedCount = 0;

    for (var i = 0; i < localReportModel!.medias!.length; i++) {
      totalCount++;
      if (localReportModel!.medias![i].state != "uploaded") {
        nonUploadedCount++;
      }

      switch (localReportModel!.medias![i].type) {
        case MediaType.audio:
          audiosCount++;
          break;
        case MediaType.note:
          notesCount++;
          break;
        case MediaType.picture:
          photosCount++;
          break;
        case MediaType.video:
          videosCount++;
          break;
        default:
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text(localReportModel!.name!, style: Theme.of(context).textTheme.subtitle2)),
            SizedBox(width: widthDp! * 10),
            Text(
              "${localReportModel!.date!.split('-').last}/${localReportModel!.date!.split('-')[1]}/${localReportModel!.date!.split('-').first} "
              "${localReportModel!.time!.split(":")[0]}:${localReportModel!.time!.split(":")[1]}",
              style: Theme.of(context).textTheme.caption!.copyWith(color: AppColors.yello),
            ),
          ],
        ),

        ///
        if (localReportModel!.city != "" || localReportModel!.zip != "")
          Column(
            children: [
              SizedBox(height: heightDp! * 5),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: heightDp! * 20, color: Colors.black),
                  SizedBox(width: widthDp! * 10),
                  Text(
                    "${localReportModel!.zip!} ${localReportModel!.city!}",
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ],
              ),
            ],
          ),

        ///
        SizedBox(height: heightDp! * 5),
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Icon(Icons.collections_outlined, size: heightDp! * 15, color: Colors.black),
                      SizedBox(width: widthDp! * 5),
                      Text(
                        LocaleKeys.LocalReportWidgetString_photos.tr(),
                        style: TextStyle(
                          fontSize: fontSp! * 10,
                          color: Color(0xFF222222),
                          fontWeight: FontWeight.w400,
                          height: 1,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: widthDp! * 10),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                        decoration: BoxDecoration(
                          color: AppColors.yello,
                          borderRadius: BorderRadius.circular(heightDp! * 3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "$photosCount",
                          style: TextStyle(
                            fontSize: fontSp! * 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            height: 1,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                    decoration: BoxDecoration(
                      color: AppColors.yello,
                      borderRadius: BorderRadius.circular(heightDp! * 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$photosCount",
                      style: TextStyle(
                        fontSize: fontSp! * 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: widthDp! * 3),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mic_none, size: heightDp! * 15, color: Colors.black),
                      Text(
                        LocaleKeys.LocalReportWidgetString_audios.tr(),
                        style: TextStyle(
                          fontSize: fontSp! * 10,
                          color: Color(0xFF222222),
                          fontWeight: FontWeight.w400,
                          height: 1,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                    decoration: BoxDecoration(
                      color: AppColors.yello,
                      borderRadius: BorderRadius.circular(heightDp! * 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$audiosCount",
                      style: TextStyle(
                        fontSize: fontSp! * 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: widthDp! * 3),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sticky_note_2_outlined, size: heightDp! * 15, color: Colors.black),
                      Text(
                        LocaleKeys.LocalReportWidgetString_notes.tr(),
                        style: TextStyle(
                          fontSize: fontSp! * 10,
                          color: Color(0xFF222222),
                          fontWeight: FontWeight.w400,
                          height: 1,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                    decoration: BoxDecoration(
                      color: AppColors.yello,
                      borderRadius: BorderRadius.circular(heightDp! * 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$notesCount",
                      style: TextStyle(
                        fontSize: fontSp! * 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: widthDp! * 3),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Icon(Icons.video_library_outlined, size: heightDp! * 15, color: Colors.black),
                      Text(
                        LocaleKeys.LocalReportWidgetString_videos.tr(),
                        style: TextStyle(
                          fontSize: fontSp! * 10,
                          color: Color(0xFF222222),
                          fontWeight: FontWeight.w400,
                          height: 1,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                    decoration: BoxDecoration(
                      color: AppColors.yello,
                      borderRadius: BorderRadius.circular(heightDp! * 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$videosCount",
                      style: TextStyle(
                        fontSize: fontSp! * 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        height: 1,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        ///
        SizedBox(height: heightDp! * 5),
        Row(
          children: [
            Icon(
              totalCount == 0 || nonUploadedCount != 0 ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
              size: heightDp! * 20,
              color: totalCount == 0 || nonUploadedCount != 0 ? AppColors.red : AppColors.green,
            ),
            SizedBox(width: widthDp! * 5),
            Text(
              totalCount == 0
                  ? LocaleKeys.LocalReportWidgetString_noMedial.tr()
                  : totalCount != 0 && nonUploadedCount != 0
                      ? LocaleKeys.LocalReportWidgetString_nonUploadMedial.tr(args: [nonUploadedCount.toString()])
                      : LocaleKeys.LocalReportWidgetString_allMediaUpload.tr(),
              style: TextStyle(
                fontSize: fontSp! * 10,
                color: Color(0xFF222222),
                fontWeight: FontWeight.w400,
                height: 1,
                letterSpacing: 0.5,
              ),
            ),
          ],
        )
      ],
    );
  }
}
