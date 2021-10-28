import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:legatus/Pages/Components/keicy_progress_dialog.dart';
import 'package:legatus/Providers/index.dart';
import 'package:provider/provider.dart';

class VideoRecoderPanel extends StatefulWidget {
  const VideoRecoderPanel({
    Key? key,
    @required this.scaffoldKey,
    // @required this.cameraController,
    @required this.keicyProgressDialog,
    @required this.width,
    @required this.videoSaveHandler,
    @required this.onAudioModeButtonPressed,
  }) : super(key: key);

  // final CameraController? cameraController;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final KeicyProgressDialog? keicyProgressDialog;
  final double? width;
  final Function(XFile, int)? videoSaveHandler;
  final Function()? onAudioModeButtonPressed;

  @override
  _VideoRecoderPanelState createState() => _VideoRecoderPanelState();
}

class _VideoRecoderPanelState extends State<VideoRecoderPanel> with SingleTickerProviderStateMixin {
  double? deviceHeight;

  /// Responsive design variables
  double? deviceWidth;
  double? fontSp;
  double? heightDp;
  double? widthDp;
  ///////////////////////////////

  CameraProvider? _cameraProvider;
  int _milliseconds = 0;

  Timer? _timer;

  Animation<double>? animation;
  AnimationController? controller;

  @override
  void dispose() {
    _cameraProvider!.removeListener(_cameraProviderListener);
    controller!.stop();
    controller!.reset();
    controller!.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    /// Responsive design variables
    deviceWidth = 1.sw;
    deviceHeight = 1.sh;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    ///////////////////////////////

    _cameraProvider = CameraProvider.of(context);

    controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween<double>(begin: 0, end: 1).animate(controller!)
      ..addListener(() {
        if (controller!.status == AnimationStatus.completed) {
          controller!.reverse();
        } else if (controller!.status == AnimationStatus.dismissed) {
          controller!.forward();
        }
      });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      _cameraProvider!.addListener(_cameraProviderListener);
    });
  }

  void _cameraProviderListener() async {
    if (_cameraProvider!.cameraState.isShowVideoRecoderPanel! && _cameraProvider!.cameraState.changedCameraResolution!) {
      if (_cameraProvider!.cameraState.isVideoRecord! && _cameraProvider!.cameraState.videoRecordStatus == "recording") {
        startVideoRecording();
      } else if (!_cameraProvider!.cameraState.isVideoRecord! && _cameraProvider!.cameraState.videoRecordStatus == "stopped") {
        stopVideoRecording();
      }
    }
  }

  void _showCameraException(CameraException e) {
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void showInSnackBar(String message) {
    // widget.scaffoldKey!.currentState?.showSnackBar(
    //   SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    // );
  }

  Future<void> startVideoRecording() async {
    if (_cameraProvider!.cameraState.cameraController == null || !_cameraProvider!.cameraState.cameraController!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (_cameraProvider!.cameraState.cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      _milliseconds = 0;
      _timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
        setState(() {
          _milliseconds++;
        });
      });
      controller!.forward();
      await _cameraProvider!.cameraState.cameraController!.startVideoRecording();
      if (mounted) setState(() {});
      showInSnackBar('Video recording started');
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (_cameraProvider!.cameraState.cameraController == null || !_cameraProvider!.cameraState.cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      _timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
        setState(() {
          _milliseconds++;
        });
      });
      controller!.forward();
      await _cameraProvider!.cameraState.cameraController!.resumeVideoRecording();
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (_cameraProvider!.cameraState.cameraController == null || !_cameraProvider!.cameraState.cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      _timer!.cancel();
      controller!.stop();
      controller!.reset();
      await _cameraProvider!.cameraState.cameraController!.pauseVideoRecording();
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> stopVideoRecording() async {
    if (_cameraProvider!.cameraState.cameraController == null || !_cameraProvider!.cameraState.cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      _timer!.cancel();
      controller!.stop();
      controller!.reset();
      _cameraProvider!.cameraState.cameraController!.stopVideoRecording().then((XFile? file) async {
        if (mounted) setState(() {});
        if (file != null) {
          if (widget.videoSaveHandler != null) {
            await widget.keicyProgressDialog!.show();

            widget.videoSaveHandler!(file, _milliseconds);
            _milliseconds = 0;
            setState(() {});
          }
          showInSnackBar('Video recorded to ${file.path}');
        }
      });
    } on CameraException catch (e) {
      await widget.keicyProgressDialog!.hide();
      _showCameraException(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraProvider!.cameraState.cameraController == null) return SizedBox();

    String videoRecorderTxt = "";
    // var date = DateTime(2021, 01, 01, 0, 0, 0, _milliseconds);
    var date = DateTime.fromMillisecondsSinceEpoch(_milliseconds, isUtc: true);
    String txt = DateFormat('mm:ss:SS').format(date);
    videoRecorderTxt = txt.substring(0, 5);

    // String statusString = "";
    if (_cameraProvider!.cameraState.cameraController != null && !_cameraProvider!.cameraState.cameraController!.value.isInitialized) {
      // statusString = "Video Record is initializing";
    } else if (_cameraProvider!.cameraState.cameraController != null &&
        _cameraProvider!.cameraState.cameraController!.value.isInitialized &&
        !_cameraProvider!.cameraState.cameraController!.value.isRecordingVideo) {
      // statusString = "Video Record is ready";
    } else if (_cameraProvider!.cameraState.cameraController != null &&
        _cameraProvider!.cameraState.cameraController!.value.isInitialized &&
        _cameraProvider!.cameraState.cameraController!.value.isRecordingPaused) {
      // statusString = "Video Record is stopped";
    } else if (_cameraProvider!.cameraState.cameraController != null &&
        _cameraProvider!.cameraState.cameraController!.value.isInitialized &&
        _cameraProvider!.cameraState.cameraController!.value.isRecordingVideo) {
      // statusString = "Video Record is recording";
    }

    return Consumer<CameraProvider>(builder: (context, cameraProvider, _) {
      return Column(
        children: [
          Container(
            width: widget.width!,
            color: Colors.black.withOpacity(1),
            padding: EdgeInsets.symmetric(horizontal: widthDp! * 10),
            child: Column(
              children: [
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: heightDp! * 5),
                      child: Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: heightDp! * 30,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _cameraProvider!.cameraState.cameraController!.enableAudio ? Icons.volume_up : Icons.volume_mute,
                        color: _cameraProvider!.cameraState.cameraController != null &&
                                !_cameraProvider!.cameraState.cameraController!.value.isRecordingVideo
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        size: heightDp! * 20,
                      ),
                      onPressed: _cameraProvider!.cameraState.cameraController != null ? widget.onAudioModeButtonPressed! : null,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // if (!_cameraProvider!.cameraState.cameraController!.value.isRecordingVideo)
                          //   Padding(
                          //     padding: EdgeInsets.symmetric(horizontal: widthDp! * 10),
                          //     child: Icon(
                          //       Icons.stop,
                          //       color: Colors.red,
                          //       size: heightDp! * 20,
                          //     ),
                          //   ),
                          // if (_cameraProvider!.cameraState.cameraController!.value.isRecordingVideo &&
                          //     !_cameraProvider!.cameraState.cameraController!.value.isRecordingPaused)
                          //   GestureDetector(
                          //     onTap: pauseVideoRecording,
                          //     child: Container(
                          //       padding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 5),
                          //       child: Icon(
                          //         Icons.pause_circle_outline_outlined,
                          //         size: heightDp! * 20,
                          //         color: Colors.white,
                          //       ),
                          //     ),
                          //   ),
                          if (_cameraProvider!.cameraState.cameraController!.value.isRecordingVideo &&
                              _cameraProvider!.cameraState.cameraController!.value.isRecordingPaused)
                            GestureDetector(
                              onTap: resumeVideoRecording,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 5),
                                child: Icon(
                                  Icons.play_circle_outline_outlined,
                                  size: heightDp! * 20,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          AnimatedBuilder(
                            animation: animation!,
                            builder: (context, child) {
                              return Opacity(
                                opacity: (_cameraProvider!.cameraState.cameraController!.value.isRecordingVideo &&
                                        !_cameraProvider!.cameraState.cameraController!.value.isRecordingPaused)
                                    ? 1 - animation!.value
                                    : 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 5),
                                  child: Icon(
                                    Icons.fiber_manual_record,
                                    size: heightDp! * 20,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            },
                          ),
                          Text(videoRecorderTxt, style: TextStyle(fontSize: fontSp! * 14, color: Colors.white)),
                          SizedBox(width: widthDp! * 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
