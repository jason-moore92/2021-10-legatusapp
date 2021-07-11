import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legutus/Models/local_report_model.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(localReportModel!.name!, style: Theme.of(context).textTheme.subtitle2),
            Text(
              "${localReportModel!.date!} ${localReportModel!.time!}",
              style: Theme.of(context).textTheme.caption!.copyWith(color: AppColors.yello),
            ),
          ],
        ),

        ///
        SizedBox(height: heightDp! * 5),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: heightDp! * 20, color: Colors.black),
            SizedBox(width: widthDp! * 10),
            Text(
              localReportModel!.city == "" ? "No city" : localReportModel!.city!,
              style: Theme.of(context).textTheme.subtitle1,
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
                  Icon(Icons.collections_outlined, size: heightDp! * 15, color: Colors.black),
                  Text(
                    LocaleKeys.LocalReportWidgetString_photos.tr(),
                    style: Theme.of(context).textTheme.overline,
                  ),
                ],
              ),
            ),
            SizedBox(width: widthDp! * 3),
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.mic_none, size: heightDp! * 15, color: Colors.black),
                  Text(
                    LocaleKeys.LocalReportWidgetString_audios.tr(),
                    style: Theme.of(context).textTheme.overline,
                  ),
                ],
              ),
            ),
            SizedBox(width: widthDp! * 3),
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.sticky_note_2_outlined, size: heightDp! * 15, color: Colors.black),
                  Text(
                    LocaleKeys.LocalReportWidgetString_notes.tr(),
                    style: Theme.of(context).textTheme.overline,
                  ),
                ],
              ),
            ),
            SizedBox(width: widthDp! * 3),
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.video_library_outlined, size: heightDp! * 15, color: Colors.black),
                  Text(
                    LocaleKeys.LocalReportWidgetString_videos.tr(),
                    style: Theme.of(context).textTheme.overline,
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
            Icon(Icons.cloud_done_outlined, size: heightDp! * 20, color: AppColors.green),
            SizedBox(width: widthDp! * 3),
            Text(
              LocaleKeys.LocalReportWidgetString_allMediaUpload.tr(),
              style: Theme.of(context).textTheme.overline,
            ),
          ],
        )
      ],
    );
  }
}
