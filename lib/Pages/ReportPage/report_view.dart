import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Dialogs/index.dart';
import 'package:legutus/Pages/ReportNewPage/new_report_page.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class ReportView extends StatefulWidget {
  final LocalReportModel? localReportModel;

  ReportView({Key? key, this.localReportModel}) : super(key: key);

  @override
  _ReportViewState createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> with SingleTickerProviderStateMixin {
  /// Responsive design variables
  double? deviceWidth;
  double? deviceHeight;
  double? statusbarHeight;
  double? bottomBarHeight;
  double? appbarHeight;
  double? widthDp;
  double? heightDp;
  double? fontSp;
  ///////////////////////////////

  LocalReportModel? _localReportModel;

  Map<String, dynamic> _updatedStatus = Map<String, dynamic>();

  @override
  void initState() {
    super.initState();

    /// Responsive design variables
    deviceWidth = 1.sw;
    deviceHeight = 1.sh;
    statusbarHeight = ScreenUtil().statusBarHeight;
    bottomBarHeight = ScreenUtil().bottomBarHeight;
    appbarHeight = AppBar().preferredSize.height;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    ///////////////////////////////

    _localReportModel = LocalReportModel.copy(widget.localReportModel!);

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _editHandler() async {
    var result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => NewReportPage(isNew: false, localReportModel: _localReportModel!),
      ),
    );
    if (result != null && result.isNotEmpty) {
      _updatedStatus = result;
      if (result["isUpdated"]) {
        _localReportModel = result["localReportModel"];
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_updatedStatus);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.of(context).pop(_updatedStatus);
            },
          ),
          title: Text(
            _localReportModel!.name!,
            style: Theme.of(context).textTheme.headline6,
          ),
          actions: [
            IconButton(
              icon: Image.asset(
                "lib/Assets/Images/word.png",
                width: heightDp! * 20,
                height: heightDp! * 20,
                color: Colors.white,
                fit: BoxFit.cover,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.cloud_upload_outlined, size: heightDp! * 25, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.info_outline_rounded, size: heightDp! * 25, color: Colors.white),
              onPressed: _editHandler,
            ),
          ],
        ),
        body: Container(
          width: deviceWidth,
          height: deviceHeight,
          child: Column(
            children: [
              _mediaPanel(),
              Expanded(
                child: _localReportModel!.medias!.isEmpty ? _noMediaPanel() : Container(),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                NotePanelDialog.show(context);
              },
              child: Container(
                width: heightDp! * 50,
                height: heightDp! * 50,
                decoration: BoxDecoration(
                  color: AppColors.yello,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey, offset: Offset(0, 3), blurRadius: 8),
                  ],
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  "lib/Assets/Images/edit_note.png",
                  width: heightDp! * 25,
                  height: heightDp! * 25,
                  color: Colors.white,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            GestureDetector(
              child: Container(
                width: heightDp! * 65,
                height: heightDp! * 65,
                decoration: BoxDecoration(
                  color: AppColors.yello,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey, offset: Offset(0, 3), blurRadius: 8),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(Icons.photo_camera_outlined, size: heightDp! * 35, color: Colors.white),
              ),
            ),
            GestureDetector(
              child: Container(
                width: heightDp! * 50,
                height: heightDp! * 50,
                decoration: BoxDecoration(
                  color: AppColors.yello,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey, offset: Offset(0, 3), blurRadius: 8),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(Icons.mic_none_outlined, size: heightDp! * 25, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaPanel() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 10),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.collections_outlined, size: heightDp! * 20, color: Colors.black),
                    Text(
                      LocaleKeys.LocalReportWidgetString_photos.tr(),
                      style: Theme.of(context).textTheme.overline,
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                        decoration: BoxDecoration(
                          color: AppColors.yello,
                          borderRadius: BorderRadius.circular(heightDp! * 3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "12",
                          style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: widthDp! * 2),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.mic_none, size: heightDp! * 20, color: Colors.black),
                    Text(
                      LocaleKeys.LocalReportWidgetString_audios.tr(),
                      style: Theme.of(context).textTheme.overline,
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                        decoration: BoxDecoration(
                          color: AppColors.yello,
                          borderRadius: BorderRadius.circular(heightDp! * 3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "12",
                          style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: widthDp! * 2),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.sticky_note_2_outlined, size: heightDp! * 20, color: Colors.black),
                    Text(
                      LocaleKeys.LocalReportWidgetString_notes.tr(),
                      style: Theme.of(context).textTheme.overline,
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                        decoration: BoxDecoration(
                          color: AppColors.yello,
                          borderRadius: BorderRadius.circular(heightDp! * 3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "12",
                          style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: widthDp! * 2),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.video_library_outlined, size: heightDp! * 20, color: Colors.black),
                    Text(
                      LocaleKeys.LocalReportWidgetString_videos.tr(),
                      style: Theme.of(context).textTheme.overline,
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                        decoration: BoxDecoration(
                          color: AppColors.yello,
                          borderRadius: BorderRadius.circular(heightDp! * 3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "12",
                          style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _noMediaPanel() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widthDp! * 40),
        child: Text(
          LocaleKeys.ReportPageString_noMediaDescription.tr(),
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
