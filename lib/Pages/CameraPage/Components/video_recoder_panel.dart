import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:legutus/Pages/Components/keicy_progress_dialog.dart';
import 'package:legutus/Providers/index.dart';
import 'package:provider/provider.dart';

class VideoRecoderPanel extends StatefulWidget {
  const VideoRecoderPanel({
    Key? key,
    @required this.scaffoldKey,
    @required this.cameraController,
    @required this.keicyProgressDialog,
    @required this.width,
    @required this.videoSaveHandler,
    @required this.onAudioModeButtonPressed,
  }) : super(key: key);

  final CameraController? cameraController;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final KeicyProgressDialog? keicyProgressDialog;
  final double? width;
  final Function(XFile, int)? videoSaveHandler;
  final Function()? onAudioModeButtonPressed;

  @override
  _VideoRecoderPanelState createState() => _VideoRecoderPanelState();
}

class _VideoRecoderPanelState extends State<VideoRecoderPanel> {
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

  @override
  void dispose() {
    _cameraProvider!.removeListener(_cameraProviderListener);
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

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      _cameraProvider!.addListener(_cameraProviderListener);
    });
  }

  void _cameraProviderListener() async {
    if (_cameraProvider!.isVideoRecord! && _cameraProvider!.videoRecordStatus == "recording") {
      startVideoRecording();
    } else if (_cameraProvider!.isVideoRecord! && _cameraProvider!.videoRecordStatus == "stopped") {
      stopVideoRecording();
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
    if (widget.cameraController == null || !widget.cameraController!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (widget.cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      _milliseconds = 0;
      await widget.cameraController!.startVideoRecording();
      _timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
        setState(() {
          _milliseconds++;
        });
      });
      if (mounted) setState(() {});
      showInSnackBar('Video recording started');
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (widget.cameraController == null || !widget.cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      await widget.cameraController!.resumeVideoRecording();
      _timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
        setState(() {
          _milliseconds++;
        });
      });
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed');
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (widget.cameraController == null || !widget.cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      await widget.cameraController!.pauseVideoRecording();
      _timer!.cancel();
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused');
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> stopVideoRecording() async {
    if (widget.cameraController == null || !widget.cameraController!.value.isRecordingVideo) {
      return null;
    }

    try {
      await widget.keicyProgressDialog!.show();
      XFile file = await widget.cameraController!.stopVideoRecording();
      _timer!.cancel();
      if (mounted) setState(() {});
      if (file != null) {
        if (widget.videoSaveHandler != null) {
          widget.videoSaveHandler!(file, _milliseconds);
        }
        showInSnackBar('Video recorded to ${file.path}');
      }
    } on CameraException catch (e) {
      await widget.keicyProgressDialog!.hide();
      _showCameraException(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameraController == null) return SizedBox();

    String videoRecorderTxt = "";
    var date = DateTime(2021, 01, 01, 0, 0, 0, _milliseconds);
    String txt = DateFormat('mm:ss:SS').format(date);
    videoRecorderTxt = txt.substring(0, 8);

    String statusString = "";
    if (widget.cameraController != null && !widget.cameraController!.value.isInitialized) {
      statusString = "Video Record is initializing";
    } else if (widget.cameraController != null && widget.cameraController!.value.isInitialized && !widget.cameraController!.value.isRecordingVideo) {
      statusString = "Video Record is ready";
    } else if (widget.cameraController != null && widget.cameraController!.value.isInitialized && widget.cameraController!.value.isRecordingPaused) {
      statusString = "Video Record is stopped";
    } else if (widget.cameraController != null && widget.cameraController!.value.isInitialized && widget.cameraController!.value.isRecordingVideo) {
      statusString = "Video Record is recording";
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
                        widget.cameraController!.enableAudio ? Icons.volume_up : Icons.volume_mute,
                        color: widget.cameraController != null && !widget.cameraController!.value.isRecordingVideo
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        size: heightDp! * 20,
                      ),
                      onPressed: widget.cameraController != null ? widget.onAudioModeButtonPressed! : null,
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // if (!widget.cameraController!.value.isRecordingVideo)
                          //   Padding(
                          //     padding: EdgeInsets.symmetric(horizontal: widthDp! * 10),
                          //     child: Icon(
                          //       Icons.stop,
                          //       color: Colors.red,
                          //       size: heightDp! * 20,
                          //     ),
                          //   ),
                          if (widget.cameraController!.value.isRecordingVideo && !widget.cameraController!.value.isRecordingPaused)
                            GestureDetector(
                              onTap: pauseVideoRecording,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: widthDp! * 10),
                                child: Icon(
                                  Icons.pause,
                                  size: heightDp! * 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          if (widget.cameraController!.value.isRecordingVideo && widget.cameraController!.value.isRecordingPaused)
                            GestureDetector(
                              onTap: resumeVideoRecording,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: widthDp! * 10),
                                child: Icon(
                                  Icons.play_arrow,
                                  size: heightDp! * 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Text(videoRecorderTxt, style: TextStyle(fontSize: fontSp! * 14, color: Colors.white)),
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

    // return Consumer<CameraProvider>(builder: (context, cameraProvider, _) {
    //   return Container(
    //     width: deviceWidth,
    //     color: Colors.black.withOpacity(0.7),
    //     child: Column(
    //       children: [
    //         Row(
    //           children: <Widget>[
    //             // IconButton(
    //             //   icon: Icon(
    //             //     Icons.fiber_manual_record,
    //             //     size: heightDp! * 20,
    //             //     color: widget.cameraController!.value.isRecordingVideo ? Colors.grey.withOpacity(0.6) : Colors.red,
    //             //   ),
    //             //   onPressed: widget.cameraController!.value.isRecordingVideo ? null : startVideoRecording,
    //             // ),
    //             IconButton(
    //               icon: widget.cameraController != null && widget.cameraController!.value.isRecordingPaused
    //                   ? Icon(
    //                       Icons.play_arrow,
    //                       size: heightDp! * 20,
    //                       color: widget.cameraController!.value.isRecordingVideo ? Colors.white : Colors.grey,
    //                     )
    //                   : Icon(
    //                       Icons.pause,
    //                       size: heightDp! * 20,
    //                       color: widget.cameraController!.value.isRecordingVideo ? Colors.white : Colors.grey,
    //                     ),
    //               onPressed: widget.cameraController != null &&
    //                       widget.cameraController!.value.isInitialized &&
    //                       widget.cameraController!.value.isRecordingVideo
    //                   ? (widget.cameraController!.value.isRecordingPaused)
    //                       ? resumeVideoRecording
    //                       : pauseVideoRecording
    //                   : null,
    //             ),
    //             // IconButton(
    //             //   icon: Icon(
    //             //     Icons.stop,
    //             //     size: heightDp! * 20,
    //             //     color: widget.cameraController!.value.isRecordingVideo ? Colors.white : Colors.grey,
    //             //   ),
    //             //   onPressed: widget.cameraController != null &&
    //             //           widget.cameraController!.value.isInitialized &&
    //             //           widget.cameraController!.value.isRecordingVideo
    //             //       ? stopVideoRecording
    //             //       : null,
    //             // ),
    //             Expanded(
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Text(videoRecorderTxt, style: TextStyle(fontSize: fontSp! * 14, color: Colors.white)),
    //                 ],
    //               ),
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   );
    // });
  }
}
