import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Dialogs/index.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

class VideoMediaWidget extends StatefulWidget {
  final MediaModel? mediaModel;
  final int? totalMediaCount;
  final bool? isSelected;
  final Function? tapHandler;
  final Function? longPressHandler;

  VideoMediaWidget({
    Key? key,
    @required this.mediaModel,
    @required this.totalMediaCount,
    this.isSelected = false,
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

  VideoPlayerController? _videoPlayerController;
  VoidCallback? _videoPlayerListener;

  Timer? _timer;

  double _maxDuration = 1.0;
  double _sliderCurrentPosition = 0.0;
  String _playerTxt = '00:00:00';

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _videoPlayerController = VideoPlayerController.file(File(widget.mediaModel!.path!))
      ..initialize().then(
        (_) {
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            _maxDuration = _videoPlayerController!.value.duration.inMilliseconds.toDouble();
            if (_maxDuration <= 0) _maxDuration = 0.0;
            if (mounted) setState(() {});
          });
        },
      ).onError((error, stackTrace) {
        print(error);
      });
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    super.dispose();
  }

  void _onStartPlay() async {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) return;
    try {
      await _videoPlayerController!.play();
      _timer = Timer.periodic(Duration(milliseconds: 1), (timer) async {
        _sliderCurrentPosition = (await _videoPlayerController!.position)!.inMilliseconds.toDouble();
        if (_sliderCurrentPosition >= _maxDuration) {
          _onStopPlay();
        } else {
          if (mounted) setState(() {});
        }
      });
    } catch (e) {}
  }

  Future<void> _seekToPlayer(int milliSecs) async {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) return;
    try {
      await _videoPlayerController!.seekTo(Duration(milliseconds: milliSecs));
      _timer!.cancel();
      _timer = Timer.periodic(Duration(milliseconds: 1), (timer) async {
        _sliderCurrentPosition = (await _videoPlayerController!.position)!.inMilliseconds.toDouble();
        if (_sliderCurrentPosition >= _maxDuration) {
          _onStopPlay();
        } else {
          if (mounted) setState(() {});
        }
      });
    } on Exception catch (err) {
      print('error: $err');
    }
    if (mounted) setState(() {});
  }

  void _onStopPlay() async {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) return;
    _timer!.cancel();
    await _videoPlayerController!.pause();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        direction: ShimmerDirection.ltr,
        enabled: true,
        period: Duration(milliseconds: 1000),
        child: Container(
          width: (MediaQuery.of(context).size.width - widthDp * 20),
          height: heightDp * 200,
          margin: EdgeInsets.symmetric(vertical: heightDp * 5),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(heightDp * 6),
          ),
        ),
      );
    }

    var maxTime = DateTime.fromMillisecondsSinceEpoch(_maxDuration.toInt(), isUtc: true);
    var maxTimeString = DateFormat('mm:ss').format(maxTime);
    var currentTime = DateTime.fromMillisecondsSinceEpoch(_sliderCurrentPosition.toInt(), isUtc: true);
    var currentTimeString = DateFormat('mm:ss').format(currentTime);

    return GestureDetector(
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
        margin: EdgeInsets.symmetric(vertical: heightDp * 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(heightDp * 6),
          border: Border.all(
            color: widget.isSelected! ? AppColors.yello : Colors.transparent,
            width: widget.isSelected! ? 3 : 0,
          ),
        ),
        child: Stack(
          children: [
            Container(
              width: (MediaQuery.of(context).size.width - widthDp * 20),
              height: _videoPlayerController!.value.aspectRatio < 1
                  ? (MediaQuery.of(context).size.width - widthDp * 20) * _videoPlayerController!.value.aspectRatio
                  : (MediaQuery.of(context).size.width - widthDp * 20) / _videoPlayerController!.value.aspectRatio,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(heightDp * 4),
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(heightDp * 4),
                  child: AspectRatio(
                    // aspectRatio: (MediaQuery.of(context).size.width - widthDp * 20) / heightDp * 200,
                    aspectRatio: _videoPlayerController!.value.size != null ? _videoPlayerController!.value.aspectRatio : 1.0,
                    child: VideoPlayer(_videoPlayerController!),
                  ),
                ),
              ),
            ),
            Positioned(
              top: heightDp * 5,
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
                  padding: EdgeInsets.all(heightDp * 5),
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: heightDp * 20,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.info,
                        size: heightDp * 20,
                        color: AppColors.yello,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: heightDp * 5,
              child: Container(
                width: (MediaQuery.of(context).size.width - widthDp * 20),
                padding: EdgeInsets.symmetric(horizontal: widthDp * 10, vertical: heightDp * 5),
                color: Colors.black.withOpacity(0.3),
                child: Row(
                  children: [
                    Icon(
                      widget.mediaModel!.state == "uploaded" ? Icons.cloud_done : Icons.cloud_off,
                      size: heightDp * 20,
                      color: widget.mediaModel!.state == "uploaded" ? AppColors.green : AppColors.red.withOpacity(0.6),
                    ),
                    if (!_videoPlayerController!.value.isPlaying)
                      GestureDetector(
                        onTap: _onStartPlay,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: widthDp * 3, vertical: heightDp * 5),
                          child: Icon(Icons.play_arrow, size: heightDp * 25, color: Colors.white),
                        ),
                      ),
                    if (_videoPlayerController!.value.isPlaying)
                      GestureDetector(
                        onTap: _onStopPlay,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: widthDp * 5, vertical: heightDp * 5),
                          child: Icon(Icons.stop, size: heightDp * 25, color: Colors.white),
                        ),
                      ),
                    Expanded(
                      child: Container(
                        height: heightDp * 20,
                        child: Slider(
                          value: min(_sliderCurrentPosition, _maxDuration),
                          min: 0.0,
                          max: _maxDuration,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white,
                          onChanged: (value) async {
                            await _seekToPlayer(value.toInt());
                          },
                          divisions: _maxDuration == 0.0 ? 1 : _maxDuration.toInt(),
                        ),
                      ),
                    ),
                    Text(
                      "$currentTimeString/$maxTimeString",
                      style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
