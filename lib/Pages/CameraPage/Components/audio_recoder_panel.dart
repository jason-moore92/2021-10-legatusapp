import 'dart:async';
// import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:legatus/Pages/Components/keicy_progress_dialog.dart';
import 'package:legatus/Pages/Dialogs/failed_dialog.dart';
import 'package:legatus/Providers/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';

class AudioRecoderPanel extends StatefulWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final KeicyProgressDialog? keicyProgressDialog;
  final String? recoderName;
  final double? width;
  final Function(bool)? recordingStatusCallback;
  final Function(String, int)? audioSaveHandler;

  AudioRecoderPanel({
    Key? key,
    @required this.scaffoldKey,
    @required this.keicyProgressDialog,
    this.recoderName = "Flutter_sound",
    @required this.width,
    @required this.recordingStatusCallback,
    @required this.audioSaveHandler,
  }) : super(key: key);

  @override
  _AudioRecoderPanelState createState() => _AudioRecoderPanelState();
}

class _AudioRecoderPanelState extends State<AudioRecoderPanel>
    with SingleTickerProviderStateMixin {
  /// Responsive design variables
  double? deviceWidth;
  double? deviceHeight;
  double? widthDp;
  double? heightDp;
  double? fontSp;
  ///////////////////////////////

  bool _isInitialized = false;
  FlutterSoundRecorder _recorderModule = FlutterSoundRecorder();
  StreamSubscription? _recorderSubscription;

  CameraProvider? _cameraProvider;

  /// The usual file extensions used for each codecs
  List<String> _ext = [
    '.aac', // defaultCodec
    '.aac', // aacADTS
    '.opus', // opusOGG
    '_opus.caf', // opusCAF
    '.mp3', // mp3
    '.ogg', // vorbisOGG
    '.pcm', // pcm16
    '.wav', // pcm16WAV
    '.aiff', // pcm16AIFF
    '_pcm.caf', // pcm16CAF
    '.flac', // flac
    '.mp4', // aacMP4
    '.amr', // AMR-NB
    '.amr', // amr-WB
    '.pcm', // pcm8
    '.pcm', // pcmFloat32
    '.pcm', //codec.pcmWebM,
    '.opus', // codec.opusWebM,
  ];

  ///
  int tSAMPLERATE = 8000;
  // Sample rate used for Streams
  int tSTREAMSAMPLERATE = 44000; // 44100 does not work for recorder on iOS

  //
  Codec _codec = Codec.pcm16WAV;

  /// audio description variable
  String? _audioRecorderTxt = '00:00';
  int? _inMilliseconds = 0;
  int? _resumeMillseconds = 0;
  // double? _dbLevel;
  String? _path;

  /// audio status variable
  bool _encoderSupported = true;
  bool _isRecording = false;

  // /// player setting
  // FlutterSoundPlayer _playerModule = FlutterSoundPlayer();
  // StreamSubscription? _playerSubscription;
  // bool? _isAudioPlayer;
  // bool _decoderSupported = true;
  // double _sliderCurrentPosition = 0.0;
  // String _playerTxt = '00:00:00';
  // double _maxDuration = 1.0;

  Animation<double>? animation;
  AnimationController? controller;

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
    _cameraProvider!.addListener(_cameraProviderListener);

    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation = Tween<double>(begin: 0, end: 1).animate(controller!)
      ..addListener(() {
        if (controller!.status == AnimationStatus.completed) {
          controller!.reverse();
        } else if (controller!.status == AnimationStatus.dismissed) {
          controller!.forward();
        }
      });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      await _initSettings();
    });
  }

  /// --- init Settings
  Future<void> _initSettings() async {
    await _initRecoderSettings();
    await _initPlayerSettings();
    await initializeDateFormatting();
    _isInitialized = true;

    setState(() {});
  }

  Future<void> _initRecoderSettings() async {
    await _recorderModule.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );
    await _recorderModule.setSubscriptionDuration(Duration(milliseconds: 10));
    _encoderSupported = await _recorderModule.isEncoderSupported(_codec);
  }

  Future<void> _initPlayerSettings() async {
    // _isAudioPlayer = false;
    // await _playerModule.closeAudioSession();
    // await _playerModule.openAudioSession(
    //   withUI: false,
    //   focus: AudioFocus.requestFocusAndStopOthers,
    //   category: SessionCategory.playAndRecord,
    //   mode: SessionMode.modeDefault,
    //   device: AudioDevice.speaker,
    // );
    // await _playerModule.setSubscriptionDuration(Duration(milliseconds: 10));
    // _decoderSupported = await _playerModule.isDecoderSupported(codec);
  }
  /////////////////////////////////////////////////////////////////

  @override
  void dispose() {
    _cameraProvider!.removeListener(_cameraProviderListener);
    _cancelRecorderSubscriptions();
    _disposeRecorderSettings();

    _cancelPlayerSubscriptions();
    _disposePlaySettings();

    super.dispose();
  }

  void _cameraProviderListener() async {
    if (_cameraProvider!.isAudioRecord! &&
        _cameraProvider!.audioRecordStatus == "recording") {
      startRecorder();
    } else if (_cameraProvider!.isAudioRecord! &&
        _cameraProvider!.audioRecordStatus == "stopped") {
      stopRecorder();
    }
  }

  /// --- dispose Settings
  void _cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }
  }

  Future<void> _disposeRecorderSettings() async {
    try {
      await _recorderModule.closeAudioSession();
    } on Exception {
      print('Released unsuccessful');
    }
  }

  void _cancelPlayerSubscriptions() {
    // if (_playerSubscription != null) {
    //   _playerSubscription!.cancel();
    //   _playerSubscription = null;
    // }
  }

  Future<void> _disposePlaySettings() async {
    try {
      // await _playerModule.closeAudioSession();
    } on Exception {
      print('Released unsuccessful');
    }
  }
  /////////////////////////////////////////////////////////////////

/*   Future<void> _setCodec(Codec codec) async {
    /// recoder setting
    await _recorderModule.setSubscriptionDuration(Duration(milliseconds: 10));

    // /// player setting
    // _decoderSupported = await _playerModule.isDecoderSupported(codec);

    setState(() {
      _codec = codec;
      _isInitialized = true;
    });
  } */

  void startRecorder() async {
    if (!_encoderSupported) return null;

    try {
      // Request Microphone permission if needed
      if (!kIsWeb) {
        var status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          throw RecordingPermissionException(
              'Microphone permission not granted');
          return;
        }
      }
      var path = '';
      if (!kIsWeb) {
        var tempDir = await getTemporaryDirectory();
        path = '${tempDir.path}/${widget.recoderName}${_ext[_codec.index]}';
      } else {
        path = '${widget.recoderName}${_ext[_codec.index]}';
      }

      await _recorderModule.startRecorder(
        toFile: path,
        codec: _codec,
        // bitRate: 8000,
        // numChannels: 1,
        // sampleRate: tSTREAMSAMPLERATE,
      );

      _inMilliseconds = 0;

      print('--------- startRecorder -----------------');
      controller!.forward();

      _recorderSubscription = _recorderModule.onProgress!.listen((e) {
        _inMilliseconds = e.duration.inMilliseconds;
        print("---------------------");
        print(_inMilliseconds);
        var date =
            DateTime.fromMillisecondsSinceEpoch(_inMilliseconds!, isUtc: true);
        var txt = DateFormat('mm:ss').format(date);

        setState(() {
          // _audioRecorderTxt = txt.substring(0, 8);
          _audioRecorderTxt = txt;
          // _dbLevel = e.decibels;
        });
      });

      setState(() {
        _isRecording = true;
        _path = path;
        if (widget.recordingStatusCallback != null) {
          widget.recordingStatusCallback!(_isRecording);
        }
      });
    } on RecordingPermissionException catch (err) {
      setState(() {
        FailedDialog.show(context, text: err.message);
        _isRecording = false;
        if (widget.recordingStatusCallback != null) {
          widget.recordingStatusCallback!(_isRecording);
        }
        _cancelRecorderSubscriptions();
      });
    } on Exception catch (err) {
      print('startRecorder error: $err');

      setState(() {
        FailedDialog.show(context, text: err.toString());
        _isRecording = false;
        if (widget.recordingStatusCallback != null) {
          widget.recordingStatusCallback!(_isRecording);
        }
        _cancelRecorderSubscriptions();
      });
    }
  }

  void pauseResumeRecorder() async {
    try {
      if (_recorderModule.isPaused) {
        await _recorderModule.resumeRecorder();
        controller!.forward();
        _recorderSubscription = _recorderModule.onProgress!.listen((e) {
          print("--------inMilliseconds-------------");
          if (_resumeMillseconds == 0) {
            _resumeMillseconds = e.duration.inMilliseconds;
          }
          _inMilliseconds = _inMilliseconds! +
              (e.duration.inMilliseconds - _resumeMillseconds!);
          _resumeMillseconds = e.duration.inMilliseconds;
          print("--------resume-------------");
          print(_inMilliseconds);
          var date = DateTime.fromMillisecondsSinceEpoch(_inMilliseconds!,
              isUtc: true);
          var txt = DateFormat('mm:ss').format(date);

          setState(() {
            // _audioRecorderTxt = txt.substring(0, 8);
            _audioRecorderTxt = txt;
            // _dbLevel = e.decibels;
          });
        });
      } else {
        await _recorderModule.pauseRecorder();
        controller!.stop();
        controller!.reset();
        _resumeMillseconds = 0;
        _cancelRecorderSubscriptions();
        assert(_recorderModule.isPaused);
      }
    } on Exception catch (err) {
      print('error: $err');
    }
    setState(() {});
  }

  void stopRecorder() async {
    try {
      await widget.keicyProgressDialog!.show();
      await _recorderModule.stopRecorder();
      controller!.stop();
      controller!.reset();

      _cancelRecorderSubscriptions();

      setState(() {
        _isRecording = false;
        if (widget.recordingStatusCallback != null) {
          widget.recordingStatusCallback!(_isRecording);
        }

        if (widget.audioSaveHandler != null) {
          widget.audioSaveHandler!(_path!, _inMilliseconds!);
        }
      });

      _showInSnackBar("Audio saved in '$_path'");
    } on Exception catch (err) {
      await widget.keicyProgressDialog!.hide();
      print('stopRecorder error: $err');
    }
  }

  void _showInSnackBar(String message) {
    // ignore: deprecated_member_use
    // widget.scaffoldKey!.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
/*     String recorderStation = "";

    if (!_isInitialized) {
      recorderStation = "Audio Record is initializing";
    } else if (_isInitialized && _recorderModule.isStopped) {
      recorderStation = "Audio Record is ready";
    } else if (_isInitialized && _recorderModule.isRecording) {
      recorderStation = "Audio Record is recording";
    } else if (_isInitialized && _recorderModule.isPaused) {
      recorderStation = "Audio Record is paused";
    } */

    return Consumer<CameraProvider>(builder: (context, cameraProvider, _) {
      return Container(
        width: widget.width!,
        color: Colors.black.withOpacity(1),
        padding: EdgeInsets.symmetric(horizontal: widthDp! * 10),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: heightDp! * 5),
                  child: Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: heightDp! * 25,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: stopRecorder,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: widthDp! * 10),
                          color: Colors.transparent,
                          child: Icon(
                            Icons.stop,
                            color: Colors.white,
                            size: heightDp! * 20,
                          ),
                        ),
                      ),
                      // if (_isInitialized && _recorderModule.isStopped)
                      //   GestureDetector(
                      //     child: Container(
                      //       padding: EdgeInsets.symmetric(horizontal: widthDp! * 10),
                      //       color: Colors.transparent,
                      //       child: Icon(
                      //         Icons.stop,
                      //         color: Colors.red,
                      //         size: heightDp! * 20,
                      //       ),
                      //     ),
                      //   ),
                      if (_isInitialized)
                        GestureDetector(
                          onTap: pauseResumeRecorder,
                          child: Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: widthDp! * 10),
                            color: Colors.transparent,
                            child: Icon(
                              _recorderModule.isRecording
                                  ? Icons.pause_circle_outline_outlined
                                  : Icons.play_circle_outline_outlined,
                              size: heightDp! * 20,
                              color: _recorderModule.isRecording
                                  ? Colors.white
                                  : Colors.red,
                            ),
                          ),
                        ),
                      AnimatedBuilder(
                        animation: animation!,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _recorderModule.isRecording
                                ? 1 - animation!.value
                                : 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: widthDp! * 10,
                                  vertical: heightDp! * 5),
                              child: Icon(
                                Icons.fiber_manual_record,
                                size: heightDp! * 20,
                                color: Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                      Text(_audioRecorderTxt!,
                          style: TextStyle(
                              fontSize: fontSp! * 14, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });

    // return Container(
    //   width: deviceWidth,
    //   color: Colors.black.withOpacity(0.7),
    //   child: Column(
    //     children: [
    //       Row(
    //         children: [
    //           IconButton(
    //             icon: Icon(
    //               Icons.fiber_manual_record,
    //               size: heightDp! * 20,
    //               color: _isInitialized && _recorderModule.isStopped ? Colors.red : Colors.grey.withOpacity(0.6),
    //             ),
    //             onPressed: startRecorder,
    //           ),
    //           IconButton(
    //             icon: Icon(
    //               _recorderModule.isRecording ? Icons.pause : Icons.play_arrow,
    //               size: heightDp! * 20,
    //               color: _isInitialized && (_recorderModule.isRecording || _recorderModule.isPaused) ? Colors.blue : Colors.grey.withOpacity(0.6),
    //             ),
    //             onPressed: pauseResumeRecorder,
    //           ),
    //           IconButton(
    //             icon: Icon(
    //               Icons.stop,
    //               size: heightDp! * 20,
    //               color: _isInitialized && (_recorderModule.isRecording || _recorderModule.isPaused) ? Colors.red : Colors.grey.withOpacity(0.6),
    //             ),
    //             onPressed: stopRecorder,
    //           ),
    //           Expanded(
    //             child: Center(
    //               child: Text(_audioRecorderTxt!, style: TextStyle(fontSize: fontSp! * 14, color: Colors.white)),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ],
    //   ),
    // );
  }
}
