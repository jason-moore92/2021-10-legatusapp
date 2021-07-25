import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:legutus/Pages/Dialogs/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioMediaWidget extends StatefulWidget {
  final MediaModel? mediaModel;
  final int? totalMediaCount;
  final bool? isSelected;
  final Function? tapHandler;
  final Function? longPressHandler;

  AudioMediaWidget({
    Key? key,
    @required this.mediaModel,
    @required this.totalMediaCount,
    this.isSelected = false,
    @required this.tapHandler,
    @required this.longPressHandler,
  }) : super(key: key);

  @override
  _AudioMediaWidgetState createState() => _AudioMediaWidgetState();
}

class _AudioMediaWidgetState extends State<AudioMediaWidget> {
  double widthDp = ScreenUtil().setWidth(1);
  double heightDp = ScreenUtil().setWidth(1);
  double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

  FlutterSoundPlayer _playerModule = FlutterSoundPlayer();
  StreamSubscription? _playerSubscription;

  Codec _codec = Codec.pcm16WAV;
  int _tSTREAMSAMPLERATE = 44000; // 44100 does not work for recorder on iOS

  double _maxDuration = 1.0;
  double _sliderCurrentPosition = 0.0;
  String _playerTxt = '00:00:00';
  bool _decoderSupported = true;
  double? _duration;

  @override
  void initState() {
    super.initState();
    _maxDuration = widget.mediaModel!.duration!.toDouble();
    _initialize();
  }

  Future<void> _initialize() async {
    await _playerModule.closeAudioSession();
    await _playerModule.openAudioSession(
      withUI: false,
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );
    await _playerModule.setSubscriptionDuration(Duration(milliseconds: 10));
    await initializeDateFormatting();
    await _setCodec(_codec);
    await _getDuration();
  }

  Future<void> _setCodec(Codec codec) async {
    _decoderSupported = await _playerModule.isDecoderSupported(codec);
  }

  Future<void> _getDuration() async {
    var path = widget.mediaModel!.path;
    var d = path != null ? await flutterSoundHelper.duration(path) : null;
    _duration = d != null ? d.inMilliseconds / 1000.0 : null;
  }

  @override
  void dispose() {
    super.dispose();
    _cancelPlayerSubscriptions();
    _disposePlayModel();
  }

  void _cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription!.cancel();
      _playerSubscription = null;
    }
  }

  Future<void> _disposePlayModel() async {
    try {
      await _playerModule.closeAudioSession();
    } on Exception {
      print('Released unsuccessful');
    }
  }

  void _addListeners() {
    _cancelPlayerSubscriptions();
    _playerSubscription = _playerModule.onProgress!.listen((e) {
      _maxDuration = e.duration.inMilliseconds.toDouble();
      if (_maxDuration <= 0) _maxDuration = 0.0;

      _sliderCurrentPosition = min(e.position.inMilliseconds.toDouble(), _maxDuration);
      if (_sliderCurrentPosition < 0.0) {
        _sliderCurrentPosition = 0.0;
      }

      var date = DateTime.fromMillisecondsSinceEpoch(e.position.inMilliseconds, isUtc: true);
      var txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
      setState(() {
        _playerTxt = txt.substring(0, 8);
      });
    });
  }

  Future<void> _startPlayer() async {
    try {
      await _playerModule.startPlayer(
        fromURI: widget.mediaModel!.path!,
        codec: _codec,
        sampleRate: _tSTREAMSAMPLERATE,
        whenFinished: () {
          print('Play finished');
          setState(() {});
        },
      );
      _addListeners();
      setState(() {});
    } on Exception catch (err) {
      print('error: $err');
    }
  }

  Future<void> _stopPlayer() async {
    try {
      await _playerModule.stopPlayer();
      if (_playerSubscription != null) {
        await _playerSubscription!.cancel();
        _playerSubscription = null;
      }
      _sliderCurrentPosition = 0.0;
    } on Exception catch (err) {
      print('error: $err');
    }
    setState(() {});
  }

  void _pauseResumePlayer() async {
    try {
      if (_playerModule.isPlaying) {
        await _playerModule.pausePlayer();
      } else {
        await _playerModule.resumePlayer();
      }
    } on Exception catch (err) {
      print('error: $err');
    }
    setState(() {});
  }

  Future<void> _seekToPlayer(int milliSecs) async {
    try {
      if (_playerModule.isPlaying) {
        await _playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
      }
    } on Exception catch (err) {
      print('error: $err');
    }
    setState(() {});
  }

  void Function()? _onPauseResumePlayerPressed() {
    if (_playerModule.isPaused || _playerModule.isPlaying) {
      return _pauseResumePlayer;
    }
    return null;
  }

  void Function()? _onStopPlayerPressed() {
    return (_playerModule.isPlaying || _playerModule.isPaused) ? _stopPlayer : null;
  }

  void Function()? _onStartPlayerPressed() {
    if (widget.mediaModel!.path == "" || widget.mediaModel!.path == null) return null;

    // Disable the button if the selected codec is not supported
    if (!(_decoderSupported || _codec == Codec.pcm16)) {
      return null;
    }

    return (_playerModule.isStopped) ? _startPlayer : null;
  }

  @override
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.symmetric(horizontal: widthDp * 5, vertical: heightDp * 10),
        decoration: BoxDecoration(
          color: Color(0xFFE7E7E7),
          borderRadius: BorderRadius.circular(heightDp * 6),
          border: Border.all(
            color: widget.isSelected! ? AppColors.yello : Colors.transparent,
            width: widget.isSelected! ? 3 : 0,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: widthDp * 5),
            Icon(
              widget.mediaModel!.state == "uploaded" ? Icons.cloud_done : Icons.cloud_off,
              size: heightDp * 20,
              color: widget.mediaModel!.state == "uploaded" ? AppColors.green : AppColors.red.withOpacity(0.6),
            ),
            Expanded(
              child: Row(
                children: [
                  if (_playerModule.isStopped)
                    GestureDetector(
                      onTap: _onStartPlayerPressed(),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: widthDp * 3, vertical: heightDp * 5),
                        child: Icon(Icons.play_arrow, size: heightDp * 25, color: AppColors.yello),
                      ),
                    ),
                  if (_playerModule.isPlaying)
                    GestureDetector(
                      onTap: _onStopPlayerPressed(),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: widthDp * 5, vertical: heightDp * 5),
                        child: Icon(Icons.stop, size: heightDp * 25, color: AppColors.yello),
                      ),
                    ),
                  Expanded(
                    child: Container(
                      // height: heightDp * 25,
                      child: Slider(
                        value: min(_sliderCurrentPosition, _maxDuration),
                        min: 0.0,
                        max: _maxDuration,
                        activeColor: AppColors.yello,
                        inactiveColor: AppColors.yello,
                        onChanged: (value) async {
                          await _seekToPlayer(value.toInt());
                        },
                        divisions: _maxDuration == 0.0 ? 1 : _maxDuration.toInt(),
                      ),
                    ),
                  ),
                  Text(
                    "$currentTimeString/$maxTimeString",
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
