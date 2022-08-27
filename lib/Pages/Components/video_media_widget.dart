import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Helpers/date_time_convert.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';
import 'package:legatus/Providers/index.dart';
import 'package:legatus/generated/locale_keys.g.dart';

class VideoMediaWidget extends StatefulWidget {
  final MediaModel? mediaModel;
  final int? totalMediaCount;
  final bool? isSelected;
  final bool? isUploading;
  final Function? tapHandler;
  final Function? longPressHandler;

  const VideoMediaWidget({
    Key? key,
    @required this.mediaModel,
    @required this.totalMediaCount,
    this.isSelected = false,
    this.isUploading = false,
    @required this.tapHandler,
    @required this.longPressHandler,
  }) : super(key: key);

  @override
  VideoMediaWidgetState createState() => VideoMediaWidgetState();
}

class VideoMediaWidgetState extends State<VideoMediaWidget> {
  double widthDp = ScreenUtil().setWidth(1);
  double heightDp = ScreenUtil().setWidth(1);
  double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

  AudioPlayer audioPlayer = AudioPlayer();

  double _maxDuration = 1.0;

  MediaPlayProvider? _mediaPlayProvider;

  Timer? uploadTimer;
  double angle = 0;

  double? widgetWidth;
  double? widgetHeight;

  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    // audioplayers: ^0.20.1
    // if (Platform.isIOS) {
    //   audioPlayer.notificationService.startHeadlessService();
    // }

    _maxDuration = widget.mediaModel!.duration!.toDouble();
    _mediaPlayProvider = MediaPlayProvider.of(context);

    _mediaPlayProvider!.setMediaPlayState(MediaPlayState.init(), isNotifiable: false);

    audioPlayer.onDurationChanged.listen((Duration d) {
      if (kDebugMode) {
        print('Max duration: $d');
      }
      setState(
        () => _maxDuration = d.inMilliseconds.toDouble(),
      );
    });

    audioPlayer.onPositionChanged.listen((Duration p) {
      if (kDebugMode) {
        print('Current position: $p');
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _mediaPlayProvider!.addListener(_mediaPlayProviderListener);

      RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
      widgetWidth = renderBox.size.width;
      widgetHeight = renderBox.size.height;
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (uploadTimer != null) uploadTimer!.cancel();
    _mediaPlayProvider!.removeListener(_mediaPlayProviderListener);
    super.dispose();
  }

  void _mediaPlayProviderListener() async {
    if (_mediaPlayProvider!.mediaPlayState.isNew! &&
        _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.rank != widget.mediaModel!.rank &&
        _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.uuid != widget.mediaModel!.uuid) {
      if (audioPlayer.state == PlayerState.playing) {
        await _seekToPlayer(0);
        await _stopPlayer();
      } else {
        await _seekToPlayer(0);
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _stopPlayer() async {
    try {
      // audioplayers: ^0.20.1
      // int result = await audioPlayer.stop();
      // if (result == 1) {}

      await audioPlayer.stop();
    } on Exception catch (err) {
      if (kDebugMode) {
        print('error: $err');
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _seekToPlayer(int milliSecs) async {
    try {
      if (audioPlayer.state == PlayerState.playing) {
        await audioPlayer.seek(Duration(milliseconds: milliSecs));
      }
    } on Exception catch (err) {
      if (kDebugMode) {
        print('error: $err');
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String responsiveStyle = "";
    if (MediaQuery.of(context).size.width >= ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "desktop";
    } else if (MediaQuery.of(context).size.width >= ResponsiveDesignSettings.mobileMaxWidth &&
        MediaQuery.of(context).size.width < ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "tablet";
    } else if (MediaQuery.of(context).size.width < ResponsiveDesignSettings.mobileMaxWidth) {
      responsiveStyle = "mobile";
    }

    double iconSize = heightDp * 20;

    if (responsiveStyle != "mobile") {
      iconSize = heightDp * 35;
    }

    var maxTime = DateTime.fromMillisecondsSinceEpoch(_maxDuration.toInt(), isUtc: true);
    var maxTimeString = DateFormat('mm:ss').format(maxTime);

    if (widget.isUploading!) {
      if (uploadTimer != null) uploadTimer!.cancel();
      uploadTimer = Timer.periodic(const Duration(milliseconds: 10), (uploadTimer) {
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
              color: const Color(0xFFE7E7E7),
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
                    Icon(
                      widget.mediaModel!.state == "error"
                          ? Icons.report_problem_outlined
                          : widget.mediaModel!.state == "uploaded"
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_off_outlined,
                      size: iconSize,
                      color:
                          widget.mediaModel!.state == "error" || widget.mediaModel!.state == "uploaded" ? Colors.white : Colors.transparent,
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
                SizedBox(width: widthDp * 10),
                Icon(Icons.videocam_outlined, size: iconSize * 1.2),
                SizedBox(width: widthDp * 5),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              LocaleKeys.LocalReportWidgetString_videos.tr()
                                  .substring(0, LocaleKeys.LocalReportWidgetString_videos.tr().length - 1),
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            SizedBox(width: widthDp * 5),
                            Text(
                              KeicyDateTime.convertDateTimeToDateString(
                                dateTime: DateTime.tryParse(
                                  widget.mediaModel!.createdAt!,
                                ),
                                formats: 'd/m/Y H:i:s',
                              ),
                              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                                    color: Colors.black,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: widthDp * 10),
                      Text(
                        maxTimeString,
                        style: Theme.of(context).textTheme.overline,
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
                borderRadius: BorderRadius.circular(heightDp * 0),
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
