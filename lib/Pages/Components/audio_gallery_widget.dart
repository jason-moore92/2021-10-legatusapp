import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Providers/index.dart';

class AudioGalleryWidget extends StatefulWidget {
  final MediaModel? mediaModel;

  const AudioGalleryWidget({
    Key? key,
    @required this.mediaModel,
  }) : super(key: key);

  @override
  AudioGalleryWidgetState createState() => AudioGalleryWidgetState();
}

class AudioGalleryWidgetState extends State<AudioGalleryWidget> {
  double widthDp = ScreenUtil().setWidth(1);
  double heightDp = ScreenUtil().setWidth(1);
  double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

  AudioPlayer audioPlayer = AudioPlayer();

  double _maxDuration = 1.0;
  double _sliderCurrentPosition = 0.0;

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
      setState(() => _sliderCurrentPosition = p.inMilliseconds.toDouble());
    });

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _mediaPlayProvider!.addListener(_mediaPlayProviderListener);

    //   RenderBox renderBox =
    //       _key.currentContext!.findRenderObject() as RenderBox;
    //   widgetWidth = renderBox.size.width;
    //   widgetHeight = renderBox.size.height;
    //   setState(() {});
    // });
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
        _sliderCurrentPosition = 0;
        await _stopPlayer();
      } else {
        await _seekToPlayer(0);
        _sliderCurrentPosition = 0;
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _startPlayer() async {
    try {
      if (_mediaPlayProvider!.mediaPlayState.selectedMediaModel!.rank != widget.mediaModel!.rank &&
          _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.uuid != widget.mediaModel!.uuid) {
        ///
        _mediaPlayProvider!.setMediaPlayState(
          _mediaPlayProvider!.mediaPlayState.update(isNew: true, selectedMediaModel: widget.mediaModel),
        );
      } else if (_mediaPlayProvider!.mediaPlayState.selectedMediaModel!.rank == widget.mediaModel!.rank &&
          _mediaPlayProvider!.mediaPlayState.selectedMediaModel!.uuid == widget.mediaModel!.uuid) {
        ///
        _mediaPlayProvider!.setMediaPlayState(
          _mediaPlayProvider!.mediaPlayState.update(
            isNew: false,
          ),
        );
      }

      // audioplayers: ^0.20.1
      // int result = await audioPlayer.play(widget.mediaModel!.path!, isLocal: true);
      // if (result == 1) {}

      await audioPlayer.play(UrlSource(widget.mediaModel!.path!));

      setState(() {});
    } on Exception catch (err) {
      if (kDebugMode) {
        print('error: $err');
      }
    }
  }

  Future<void> _stopPlayer() async {
    try {
      // audioplayers: ^0.20.1
      // int result = await audioPlayer.stop();
      // if (result == 1) {
      //   _sliderCurrentPosition = 0.0;
      // }
      await audioPlayer.stop();
      _sliderCurrentPosition = 0.0;
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
        // int result = await audioPlayer.seek(Duration(milliseconds: milliSecs));
        await audioPlayer.seek(Duration(milliseconds: milliSecs));
      }
    } on Exception catch (err) {
      if (kDebugMode) {
        print('error: $err');
      }
    }
    if (mounted) setState(() {});
  }

  void Function()? _onStopPlayerPressed() {
    return (audioPlayer.state == PlayerState.playing || audioPlayer.state == PlayerState.paused) ? _stopPlayer : null;
  }

  void Function()? _onStartPlayerPressed() {
    if (widget.mediaModel!.path == "" || widget.mediaModel!.path == null) return null;

    return audioPlayer.state == PlayerState.stopped || audioPlayer.state == PlayerState.completed ? _startPlayer : null;
  }

  @override
  Widget build(BuildContext context) {
    var maxTime = DateTime.fromMillisecondsSinceEpoch(_maxDuration.toInt(), isUtc: true);
    var maxTimeString = DateFormat('mm:ss').format(maxTime);
    var currentTime = DateTime.fromMillisecondsSinceEpoch(_sliderCurrentPosition.toInt(), isUtc: true);
    var currentTimeString = DateFormat('mm:ss').format(currentTime);

    angle = 0;

    return Container(
      key: _key,
      margin: EdgeInsets.symmetric(vertical: heightDp * 5),
      padding: EdgeInsets.symmetric(horizontal: widthDp * 5, vertical: heightDp * 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E7E7),
        borderRadius: BorderRadius.circular(heightDp * 6),
      ),
      child: Row(
        children: [
          if (audioPlayer.state == PlayerState.completed || audioPlayer.state == PlayerState.stopped)
            GestureDetector(
              onTap: _onStartPlayerPressed(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: widthDp * 3, vertical: heightDp * 5),
                child: Icon(Icons.play_arrow, size: heightDp * 25, color: AppColors.yello),
              ),
            ),
          if (audioPlayer.state == PlayerState.playing)
            GestureDetector(
              onTap: _onStopPlayerPressed(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: widthDp * 5, vertical: heightDp * 5),
                child: Icon(Icons.stop, size: heightDp * 25, color: AppColors.yello),
              ),
            ),
          Expanded(
            child: Slider(
              value: min(_sliderCurrentPosition, _maxDuration < 0 ? 0 : _maxDuration),
              min: 0.0,
              max: _maxDuration < 0 ? 0 : _maxDuration,
              activeColor: AppColors.yello,
              inactiveColor: AppColors.yello,
              onChanged: (value) async {
                await _seekToPlayer(value.toInt());
              },
              divisions: _maxDuration < 0.0 ? 1 : _maxDuration.toInt(),
            ),
          ),
          Text(
            "$currentTimeString/$maxTimeString",
            style: Theme.of(context).textTheme.overline,
          ),
          SizedBox(width: widthDp * 5),
        ],
      ),
    );
  }
}
