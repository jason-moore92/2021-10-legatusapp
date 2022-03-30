import 'dart:async';
import 'dart:io';
import 'dart:math';
// import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Helpers/date_time_convert.dart';
import 'package:legatus/Models/index.dart';
// import 'package:intl/date_symbol_data_local.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';
import 'package:legatus/Providers/index.dart';
import 'package:legatus/generated/locale_keys.g.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';

class VideoMediaWidget extends StatefulWidget {
  final MediaModel? mediaModel;
  final int? totalMediaCount;
  final bool? isSelected;
  final bool? isUploading;
  final Function? tapHandler;
  final Function? longPressHandler;

  VideoMediaWidget({
    Key? key,
    @required this.mediaModel,
    @required this.totalMediaCount,
    this.isSelected = false,
    this.isUploading = false,
    @required this.tapHandler,
    @required this.longPressHandler,
  }) : super(key: key);

  @override
  _VideoMediaWidgetState createState() => _VideoMediaWidgetState();
}

class _VideoMediaWidgetState extends State<VideoMediaWidget> {
  double widthDp = ScreenUtil().setWidth(1);
  double heightDp = ScreenUtil().setWidth(1);
  double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

  AudioPlayer audioPlayer = AudioPlayer();

  double _maxDuration = 1.0;
  // double _sliderCurrentPosition = 0.0;

  MediaPlayProvider? _mediaPlayProvider;

  Timer? uploadTimer;
  double angle = 0;

  double? widgetWidth;
  double? widgetHeight;

  GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      audioPlayer.notificationService.startHeadlessService();
    }

    _maxDuration = widget.mediaModel!.duration!.toDouble();
    _mediaPlayProvider = MediaPlayProvider.of(context);

    _mediaPlayProvider!
        .setMediaPlayState(MediaPlayState.init(), isNotifiable: false);

    audioPlayer.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(
        () => _maxDuration = d.inMilliseconds.toDouble(),
      );
    });

    audioPlayer.onAudioPositionChanged.listen((Duration p) {
      print('Current position: $p');
      // setState(() => _sliderCurrentPosition = p.inMilliseconds.toDouble());
    });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _mediaPlayProvider!.addListener(_mediaPlayProviderListener);

      RenderBox renderBox =
          _key.currentContext!.findRenderObject() as RenderBox;
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
        _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.rank !=
            widget.mediaModel!.rank &&
        _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.uuid !=
            widget.mediaModel!.uuid) {
      if (audioPlayer.state == PlayerState.PLAYING) {
        await _seekToPlayer(0);
        // _sliderCurrentPosition = 0;
        await _stopPlayer();
      } else {
        await _seekToPlayer(0);
        // _sliderCurrentPosition = 0;
        if (mounted) setState(() {});
      }
    }
  }

  // Future<void> _startPlayer() async {
  //   try {
  //     if (_mediaPlayProvider!.mediaPlayState.selectedMediaModel!.rank !=
  //             widget.mediaModel!.rank &&
  //         _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.uuid !=
  //             widget.mediaModel!.uuid) {
  //       ///
  //       _mediaPlayProvider!.setMediaPlayState(
  //         _mediaPlayProvider!.mediaPlayState
  //             .update(isNew: true, selectedMediaModel: widget.mediaModel),
  //       );
  //     } else if (_mediaPlayProvider!.mediaPlayState.selectedMediaModel!.rank ==
  //             widget.mediaModel!.rank &&
  //         _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.uuid ==
  //             widget.mediaModel!.uuid) {
  //       ///
  //       _mediaPlayProvider!.setMediaPlayState(
  //         _mediaPlayProvider!.mediaPlayState.update(
  //           isNew: false,
  //         ),
  //       );
  //     }

  //     int result =
  //         await audioPlayer.play(widget.mediaModel!.path!, isLocal: true);
  //     if (result == 1) {}
  //     setState(() {});
  //   } on Exception catch (err) {
  //     print('error: $err');
  //   }
  // }

  Future<void> _stopPlayer() async {
    try {
      int result = await audioPlayer.stop();
      if (result == 1) {
        // _sliderCurrentPosition = 0.0;
      }
    } on Exception catch (err) {
      print('error: $err');
    }
    if (mounted) setState(() {});
  }

/*   void _pauseResumePlayer() async {
    try {
      if (audioPlayer.state == PlayerState.PLAYING) {
        // int result = await audioPlayer.pause();
        await audioPlayer.pause();
      } else {
        // int result = await audioPlayer.resume();
        await audioPlayer.resume();
      }
    } on Exception catch (err) {
      print('error: $err');
    }
    if (mounted) setState(() {});
  } */

  Future<void> _seekToPlayer(int milliSecs) async {
    try {
      if (audioPlayer.state == PlayerState.PLAYING) {
        // int result = await audioPlayer.seek(Duration(milliseconds: milliSecs));
        await audioPlayer.seek(Duration(milliseconds: milliSecs));
      }
    } on Exception catch (err) {
      print('error: $err');
    }
    if (mounted) setState(() {});
  }

/*   void Function()? _onPauseResumePlayerPressed() {
    if (audioPlayer.state == PlayerState.PAUSED ||
        audioPlayer.state == PlayerState.PLAYING) {
      return _pauseResumePlayer;
    }
    return null;
  } */

  // void Function()? _onStopPlayerPressed() {
  //   return (audioPlayer.state == PlayerState.PLAYING ||
  //           audioPlayer.state == PlayerState.PAUSED)
  //       ? _stopPlayer
  //       : null;
  // }

  // void Function()? _onStartPlayerPressed() {
  //   if (widget.mediaModel!.path == "" || widget.mediaModel!.path == null)
  //     return null;

  //   return audioPlayer.state == PlayerState.STOPPED ||
  //           audioPlayer.state == PlayerState.COMPLETED
  //       ? _startPlayer
  //       : null;
  // }

  @override
  Widget build(BuildContext context) {
    String responsiveStyle = "";
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

    double iconSize = heightDp * 20;
    // double iconPadding = widthDp * 10;
    // TextStyle? textStyle = Theme.of(context).textTheme.overline;

    if (responsiveStyle != "mobile") {
      iconSize = heightDp * 35;
      // iconPadding = widthDp * 20;
      // textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black);
    }

    var maxTime =
        DateTime.fromMillisecondsSinceEpoch(_maxDuration.toInt(), isUtc: true);
    var maxTimeString = DateFormat('mm:ss').format(maxTime);
    // var currentTime = DateTime.fromMillisecondsSinceEpoch(
    //     _sliderCurrentPosition.toInt(),
    //     isUtc: true);
    // var currentTimeString = DateFormat('mm:ss').format(currentTime);

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
            padding: EdgeInsets.symmetric(
                horizontal: widthDp * 5, vertical: heightDp * 10),
            decoration: BoxDecoration(
              color: Color(0xFFE7E7E7),
              borderRadius: BorderRadius.circular(heightDp * 0),
              border: Border.all(
                color:
                    widget.isSelected! ? AppColors.yello : Colors.transparent,
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
                              "${LocaleKeys.LocalReportWidgetString_videos.tr().substring(0, LocaleKeys.LocalReportWidgetString_videos.tr().length - 1)}",
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            SizedBox(width: widthDp * 5),
                            Text(
                              "${KeicyDateTime.convertDateTimeToDateString(
                                dateTime: DateTime.tryParse(
                                  widget.mediaModel!.createdAt!,
                                ),
                                formats: 'd/m/Y H:i:s',
                              )}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    color: Colors.black,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: widthDp * 10),
                      Text(
                        "$maxTimeString",
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
              height: widgetHeight != null
                  ? widgetHeight! - heightDp * 10
                  : widgetHeight,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(heightDp * 0),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: angle / 180 * pi,
                  child: Icon(Icons.autorenew,
                      size: iconSize, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
