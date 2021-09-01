import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:legutus/Pages/Components/keicy_progress_dialog.dart';
import 'package:legutus/Helpers/file_helpers.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Dialogs/index.dart';
import 'package:legutus/Providers/index.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image/image.dart' as IMG;

import 'index.dart';

class CameraView extends StatefulWidget {
  final LocalReportModel? localReportModel;
  final bool? isPicture;
  final bool? isAudio;

  CameraView({this.localReportModel, this.isAudio, this.isPicture});

  @override
  _CameraViewState createState() {
    return _CameraViewState();
  }
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver, TickerProviderStateMixin {
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CameraController? cameraController;
  XFile? videoFile;
  VoidCallback? videoPlayerListener;
  bool enableAudio = true;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  List<CameraDescription> cameras = [];

  bool _isShowAudioRecoderPanel = false;
  bool _isShowVideoRecoderPanel = false;

  bool _isAudioRecording = false;

  LocalReportModel? _localReportModel;

  KeicyProgressDialog? _keicyProgressDialog;
  LocalReportProvider? _localReportProvider;
  CameraProvider? _cameraProvider;
  AppDataProvider? _appDataProvider;

  Map<String, dynamic> _updatedStatus = Map<String, dynamic>();

  double _cameraViewHeiht = 0;

  NativeDeviceOrientation? _orientation;
  DeviceOrientation? _cameraOrientation;

  Position? _currentPosition;
  bool _isInit = false;

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
    heightDp1 = ScreenUtil().setHeight(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    ///////////////////////////////

    WidgetsBinding.instance?.addObserver(this);

    _localReportModel = LocalReportModel.copy(widget.localReportModel!);

    _keicyProgressDialog = KeicyProgressDialog.of(
      context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      layout: Layout.Column,
      padding: EdgeInsets.zero,
      width: heightDp! * 120,
      height: heightDp! * 120,
      progressWidget: Container(
        width: heightDp! * 120,
        height: heightDp! * 120,
        padding: EdgeInsets.all(heightDp! * 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(heightDp! * 10),
        ),
        child: SpinKitFadingCircle(
          color: AppColors.primayColor,
          size: heightDp! * 80,
        ),
      ),
      message: "",
    );
    _localReportProvider = LocalReportProvider.of(context);
    _cameraProvider = CameraProvider.of(context);
    _appDataProvider = AppDataProvider.of(context);

    _localReportProvider!.setLocalReportState(
      LocalReportState.init().copyWith(contextName: "CameraPage"),
      isNotifiable: false,
    );

    _cameraOrientation = DeviceOrientation.portraitUp;

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark, //status bar brigtness
      ));
      setState(() {});
      cameras = await availableCameras();
      onNewCameraSelected(cameras[0], _appDataProvider!.appDataState.settingsModel!.photoResolution!);
    });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColors.primayColor,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark, //status bar brigtness
    ));
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  void _noteHandler({String? note, bool? isNew = true, MediaModel? mediaModel}) async {
    await _keicyProgressDialog!.show();
    try {
      // if (AppDataProvider.of(context).appDataState.settingsModel!.withRestriction!) {
      //   Map<String, int> result = await FileHelpers.dirStatSync();
      //   if ((result["size"]! + (note!.length * 2) ~/ 1024) > 1250 * 1024) {
      //     await _keicyProgressDialog!.hide();
      //     NormalDialog.show(context, content: LocaleKeys.StorageLimitDialogString_content.tr());
      //     return;
      //   }
      // }

      if (isNew!) {
        String? path = await FileHelpers.getFilePath(
          mediaType: MediaType.note,
          rank: widget.localReportModel!.medias!.length + 1,
          fileType: "txt",
        );

        if (path == null) {
          await _keicyProgressDialog!.hide();
          FailedDialog.show(context, text: "Creating new note file path occur error");
          return;
        }

        File? textFile = await FileHelpers.writeTextFile(text: note, path: path);

        if (textFile == null) {
          await _keicyProgressDialog!.hide();
          FailedDialog.show(context, text: "Creating new note file occur error");
          return;
        }

        mediaModel = MediaModel();
        mediaModel.content = note;
        mediaModel.createdAt = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: "Y-m-d H:i:s");
        if (Platform.isAndroid) {
          mediaModel.deviceInfo = AppDataProvider.of(context).appDataState.androidInfo;
        } else if (Platform.isIOS) {
          mediaModel.deviceInfo = AppDataProvider.of(context).appDataState.iosInfo;
        }
        mediaModel.duration = -1;
        mediaModel.ext = textFile.path.split('.').last;
        mediaModel.filename = textFile.path.split('/').last;
        if (_currentPosition != null) {
          mediaModel.latitude = _currentPosition!.latitude.toString();
          mediaModel.longitude = _currentPosition!.longitude.toString();
        }
        mediaModel.path = textFile.path;
        mediaModel.rank = _localReportModel!.medias!.length + 1;
        mediaModel.reportId = _localReportModel!.reportId!;
        mediaModel.size = textFile.readAsBytesSync().lengthInBytes;
        mediaModel.state = "captured";
        mediaModel.type = MediaType.note;
        mediaModel.uuid = Uuid().v4();
        if (_localReportModel!.medias == null) _localReportModel!.medias = [];
        _localReportModel!.medias!.add(mediaModel);
      } else {
        for (var i = 0; i < _localReportModel!.medias!.length; i++) {
          if (_localReportModel!.medias![i].createdAt == mediaModel!.createdAt!) {
            File oldTextFile = File(mediaModel.path!);
            try {
              await oldTextFile.delete();
            } catch (e) {
              print(e);
            }

            File? textFile = await FileHelpers.writeTextFile(text: note, path: mediaModel.path!);

            if (textFile == null) {
              await _keicyProgressDialog!.hide();
              FailedDialog.show(context, text: "Creating updat note file occur error");
              return;
            }

            mediaModel.content = note;
            mediaModel.ext = textFile.path.split('.').last;
            mediaModel.filename = textFile.path.split('/').last;
            if (_currentPosition != null) {
              mediaModel.latitude = _currentPosition!.latitude.toString();
              mediaModel.longitude = _currentPosition!.longitude.toString();
            }
            mediaModel.path = textFile.path;
            mediaModel.size = textFile.readAsBytesSync().lengthInBytes;

            _localReportModel!.medias![i] = mediaModel;
            break;
          }
        }
      }

      String createdAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: _localReportModel!.createdAt).toString();
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
        dateString: "${_localReportModel!.date} ${_localReportModel!.time}",
      )!;

      var progressState = await _localReportProvider!.updateLocalReport(
        localReportModel: _localReportModel,
        oldReportId: "${reportDateTime}_$createdAt",
      );

      await _keicyProgressDialog!.hide();

      if (progressState == 2) {
        _updatedStatus = {
          "isUpdated": true,
          "localReportModel": _localReportModel,
        };
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

  void _pictureHandler({@required XFile? imageFile}) async {
    try {
      // if (AppDataProvider.of(context).appDataState.settingsModel!.withRestriction!) {
      //   Map<String, int> result = await FileHelpers.dirStatSync();
      //   int fileSize = ((await imageFile!.readAsBytes()).lengthInBytes ~/ 1024).toInt();
      //   if (result["size"]! + fileSize > 1250 * 1024) {
      //     await _keicyProgressDialog!.hide();
      //     NormalDialog.show(context, content: LocaleKeys.StorageLimitDialogString_content.tr());
      //     return;
      //   }
      // }

      String? path = await FileHelpers.getFilePath(
        mediaType: "photographie",
        rank: widget.localReportModel!.medias!.length + 1,
        fileType: imageFile!.path.split(".").last,
      );
      String? thumPath = await FileHelpers.getFilePath(
        mediaType: "photographie-thum",
        subDirectory: "vignettes",
        rank: widget.localReportModel!.medias!.length + 1,
        fileType: imageFile.path.split(".").last,
      );

      if (path == null) {
        await _keicyProgressDialog!.hide();
        FailedDialog.show(context, text: "Creating image file path occur error");
        return;
      }

      File? _imageFile = await FileHelpers.writeImageFile(imageFile: imageFile, path: path);

      if (_imageFile == null) {
        await _keicyProgressDialog!.hide();
        FailedDialog.show(context, text: "Creating image file occur error");
        return;
      }

      File tmpFile = File(imageFile.path);
      await tmpFile.delete();

      MediaModel mediaModel = MediaModel();
      mediaModel.createdAt = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: "Y-m-d H:i:s");
      if (Platform.isAndroid) {
        mediaModel.deviceInfo = AppDataProvider.of(context).appDataState.androidInfo;
      } else if (Platform.isIOS) {
        mediaModel.deviceInfo = AppDataProvider.of(context).appDataState.iosInfo;
      }
      mediaModel.duration = -1;
      mediaModel.ext = _imageFile.path.split('.').last;
      mediaModel.filename = _imageFile.path.split('/').last;
      if (_currentPosition != null) {
        mediaModel.latitude = _currentPosition!.latitude.toString();
        mediaModel.longitude = _currentPosition!.longitude.toString();
      }
      mediaModel.path = _imageFile.path;
      ////////////////////////////////////////
      // Read a jpeg image from file.
      if (thumPath != null) {
        IMG.Image? image = IMG.decodeImage(_imageFile.readAsBytesSync());
        // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
        IMG.Image thumbnail = IMG.copyResize(image!, width: 300);
        File turmFile = await File(thumPath).writeAsBytes(IMG.encodePng(thumbnail));
        mediaModel.thumPath = turmFile.path;
      }
      ////////////////////////////////////////
      mediaModel.rank = _localReportModel!.medias!.length + 1;
      mediaModel.reportId = _localReportModel!.reportId!;
      mediaModel.size = _imageFile.readAsBytesSync().lengthInBytes;
      mediaModel.state = "captured";
      mediaModel.type = MediaType.picture;
      mediaModel.uuid = Uuid().v4();

      if (_localReportModel!.medias == null) _localReportModel!.medias = [];
      _localReportModel!.medias!.add(mediaModel);

      String createdAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: _localReportModel!.createdAt).toString();
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
        dateString: "${_localReportModel!.date} ${_localReportModel!.time}",
      )!;

      var progressState = await _localReportProvider!.updateLocalReport(
        localReportModel: _localReportModel,
        oldReportId: "${reportDateTime}_$createdAt",
      );

      await _keicyProgressDialog!.hide();

      if (progressState == 2) {
        _updatedStatus = {
          "isUpdated": true,
          "localReportModel": _localReportModel,
        };
        setState(() {});
      } else {
        FailedDialog.show(context, text: "Created picture media and update local report error");
        return;
      }
    } catch (e) {
      print(e);
      await _keicyProgressDialog!.hide();
      FailedDialog.show(context, text: "Creating picture media error");
      return;
    }
  }

  void _audioHandler({@required String? tmpPath, @required int? inMilliseconds}) async {
    // await _keicyProgressDialog!.show();
    try {
      // if (AppDataProvider.of(context).appDataState.settingsModel!.withRestriction!) {
      //   Map<String, int> result = await FileHelpers.dirStatSync();
      //   File audioFile = File(tmpPath!);
      //   int fileSize = ((await audioFile.readAsBytes()).lengthInBytes ~/ 1024).toInt();
      //   if (result["size"]! + fileSize > 1250 * 1024) {
      //     await _keicyProgressDialog!.hide();
      //     NormalDialog.show(context, content: LocaleKeys.StorageLimitDialogString_content.tr());
      //     return;
      //   }
      // }

      String? path = await FileHelpers.getFilePath(
        mediaType: "dictee",
        rank: widget.localReportModel!.medias!.length + 1,
        fileType: tmpPath!.split(".").last,
      );

      if (path == null) {
        await _keicyProgressDialog!.hide();
        FailedDialog.show(context, text: "Creating audio file path occur error");
        return;
      }

      File? _audioFile = await FileHelpers.writeAudioFile(tmpPath: tmpPath, path: path);

      if (_audioFile == null) {
        await _keicyProgressDialog!.hide();
        FailedDialog.show(context, text: "Creating audio file occur error");
        return;
      }

      File tmpFile = File(tmpPath);
      await tmpFile.delete();

      MediaModel mediaModel = MediaModel();
      mediaModel.createdAt = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: "Y-m-d H:i:s");
      if (Platform.isAndroid) {
        mediaModel.deviceInfo = AppDataProvider.of(context).appDataState.androidInfo;
      } else if (Platform.isIOS) {
        mediaModel.deviceInfo = AppDataProvider.of(context).appDataState.iosInfo;
      }
      mediaModel.duration = inMilliseconds;
      mediaModel.ext = _audioFile.path.split('.').last;
      mediaModel.filename = _audioFile.path.split('/').last;
      if (_currentPosition != null) {
        mediaModel.latitude = _currentPosition!.latitude.toString();
        mediaModel.longitude = _currentPosition!.longitude.toString();
      }
      mediaModel.path = _audioFile.path;
      mediaModel.rank = _localReportModel!.medias!.length + 1;
      mediaModel.reportId = _localReportModel!.reportId!;
      mediaModel.size = _audioFile.readAsBytesSync().lengthInBytes;
      mediaModel.state = "captured";
      mediaModel.type = MediaType.audio;
      mediaModel.uuid = Uuid().v4();

      if (_localReportModel!.medias == null) _localReportModel!.medias = [];
      _localReportModel!.medias!.add(mediaModel);

      String createdAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: _localReportModel!.createdAt).toString();
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
        dateString: "${_localReportModel!.date} ${_localReportModel!.time}",
      )!;

      var progressState = await _localReportProvider!.updateLocalReport(
        localReportModel: _localReportModel,
        oldReportId: "${reportDateTime}_$createdAt",
      );

      await _keicyProgressDialog!.hide();

      if (progressState == 2) {
        _updatedStatus = {
          "isUpdated": true,
          "localReportModel": _localReportModel,
        };
      } else {
        FailedDialog.show(context, text: "Created audio media and update local report error");
      }
    } catch (e) {
      print(e);
      await _keicyProgressDialog!.hide();
      FailedDialog.show(context, text: "Creating audio media error");
    }

    _cameraProvider!.setAudioRecordStatus("stopped", isNotifiable: false);
    _isShowAudioRecoderPanel = false;
    setState(() {});
  }

  void _videoHandler({@required XFile? videoFile, @required int? inMilliseconds}) async {
    // await _keicyProgressDialog!.show();
    try {
      // if (AppDataProvider.of(context).appDataState.settingsModel!.withRestriction!) {
      //   Map<String, int> result = await FileHelpers.dirStatSync();
      //   int fileSize = ((await videoFile!.readAsBytes()).lengthInBytes ~/ 1024).toInt();
      //   if (result["size"]! + fileSize > 1250 * 1024) {
      //     await _keicyProgressDialog!.hide();
      //     NormalDialog.show(context, content: LocaleKeys.StorageLimitDialogString_content.tr());
      //     return;
      //   }
      // }

      String? path = await FileHelpers.getFilePath(
        mediaType: MediaType.video,
        rank: widget.localReportModel!.medias!.length + 1,
        fileType: videoFile!.path.split(".").last,
      );

      if (path == null) {
        await _keicyProgressDialog!.hide();
        FailedDialog.show(context, text: "Creating video file occur error");
        return;
      }

      File? _videoFile = await FileHelpers.writeVideoFile(videoFile: videoFile, path: path);

      if (_videoFile == null) {
        await _keicyProgressDialog!.hide();
        FailedDialog.show(context, text: "Creating video file occur error");
        return;
      }

      File tmpFile = File(videoFile.path);
      await tmpFile.delete();

      MediaModel mediaModel = MediaModel();
      mediaModel.createdAt = KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now(), formats: "Y-m-d H:i:s");
      if (Platform.isAndroid) {
        mediaModel.deviceInfo = AppDataProvider.of(context).appDataState.androidInfo;
      } else if (Platform.isIOS) {
        mediaModel.deviceInfo = AppDataProvider.of(context).appDataState.iosInfo;
      }
      mediaModel.duration = inMilliseconds;
      mediaModel.ext = _videoFile.path.split('.').last;
      mediaModel.filename = _videoFile.path.split('/').last;
      if (_currentPosition != null) {
        mediaModel.latitude = _currentPosition!.latitude.toString();
        mediaModel.longitude = _currentPosition!.longitude.toString();
      }
      mediaModel.path = _videoFile.path;
      mediaModel.rank = _localReportModel!.medias!.length + 1;
      mediaModel.reportId = _localReportModel!.reportId!;
      mediaModel.size = _videoFile.readAsBytesSync().lengthInBytes;
      mediaModel.state = "captured";
      mediaModel.type = MediaType.video;
      mediaModel.uuid = Uuid().v4();

      if (_localReportModel!.medias == null) _localReportModel!.medias = [];
      _localReportModel!.medias!.add(mediaModel);

      String createdAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: _localReportModel!.createdAt).toString();
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
        dateString: "${_localReportModel!.date} ${_localReportModel!.time}",
      )!;

      var progressState = await _localReportProvider!.updateLocalReport(
        localReportModel: _localReportModel,
        oldReportId: "${reportDateTime}_$createdAt",
      );

      await _keicyProgressDialog!.hide();

      if (progressState == 2) {
        _updatedStatus = {
          "isUpdated": true,
          "localReportModel": _localReportModel,
        };
      } else {
        FailedDialog.show(context, text: "Created video media and update local report error");
      }

      _isShowVideoRecoderPanel = false;
    } catch (e) {
      print(e);

      await _keicyProgressDialog!.hide();
      FailedDialog.show(context, text: "Creating video media error");
    }

    onNewCameraSelected(cameraController!.description, _appDataProvider!.appDataState.settingsModel!.photoResolution!);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController!.description, _appDataProvider!.appDataState.settingsModel!.photoResolution!);
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription, int resolution) async {
    if (cameraDescription == null) return;

    if (cameraController != null) {
      await cameraController!.dispose();
      cameraController = null;
    }
    _isInit = false;
    setState(() {});

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      ResolutionPreset resolutionPreset;

      switch (resolution) {
        case 0:
          resolutionPreset = ResolutionPreset.high;
          break;
        case 1:
          resolutionPreset = ResolutionPreset.veryHigh;
          break;
        case 2:
          resolutionPreset = ResolutionPreset.ultraHigh;
          break;
        case 3:
          resolutionPreset = ResolutionPreset.max;
          break;
        default:
          resolutionPreset = ResolutionPreset.ultraHigh;
      }
      CameraController newCameraController = CameraController(
        cameraDescription,
        resolutionPreset,
        enableAudio: enableAudio,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // If the cameraController is updated then update the UI.
      newCameraController.addListener(() {
        if (newCameraController.value.hasError) {
          showInSnackBar('Camera error ${cameraController!.value.errorDescription}');
        }
      });

      try {
        await newCameraController.initialize();
        await newCameraController.lockCaptureOrientation(_cameraOrientation);
        await Future.wait([
          newCameraController.getMaxZoomLevel().then((value) => _maxAvailableZoom = value),
          newCameraController.getMinZoomLevel().then((value) => _minAvailableZoom = value),
        ]);
        if (Platform.isIOS) {
          try {
            newCameraController.prepareForVideoRecording();
          } catch (e) {}
        }
      } on CameraException catch (e) {
        _showCameraException(e);
      }

      cameraController = newCameraController;

      if (mounted) {
        _isInit = true;
        setState(() {});
      }
    });
  }

  void _closeHandler() {
    if ((_cameraProvider!.audioRecordStatus != "stopped") || _cameraProvider!.videoRecordStatus != "stopped") {
      NormalAskDialog.show(
        context,
        content: "Un enregistrement est en cours, si vous quittez cette page, il sera perdu",
        okButton: "Quitter",
        cancelButton: "Annuler",
        callback: () {
          Navigator.of(context).pop(_updatedStatus);
        },
      );
      return;
    }

    Navigator.of(context).pop(_updatedStatus);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closeHandler();
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        body: NativeDeviceOrientationReader(
          useSensor: true,
          builder: (context) {
            _orientation = NativeDeviceOrientationReader.orientation(context);

            return Container(
              width: deviceWidth,
              height: deviceHeight,
              color: Colors.black,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: deviceWidth,
                    height: deviceHeight,
                    child: _cameraPreviewWidget(),
                  ),
                  Container(width: deviceWidth, height: statusbarHeight, color: Colors.black),
                  Positioned(
                    top: statusbarHeight,
                    child: _cameraToolTopPanel(orientation: _orientation),
                  ),

                  ///
                  Positioned(
                    bottom: heightDp! * 0,
                    child: Column(
                      children: [
                        _isShowAudioRecoderPanel
                            ? Container(
                                width: deviceWidth,
                                child: Row(
                                  children: [
                                    RotatedBox(
                                      quarterTurns:
                                          (_cameraOrientation == DeviceOrientation.portraitDown || _cameraOrientation == DeviceOrientation.portraitUp)
                                              ? 0
                                              : 1,
                                      child: AudioRecoderPanel(
                                        scaffoldKey: _scaffoldKey,
                                        keicyProgressDialog: _keicyProgressDialog,
                                        width: (_cameraOrientation == DeviceOrientation.portraitDown ||
                                                _cameraOrientation == DeviceOrientation.portraitUp)
                                            ? deviceWidth
                                            : _cameraViewHeiht - heightDp! * 120,
                                        recordingStatusCallback: (bool isAudioRecording) {
                                          _isAudioRecording = isAudioRecording;
                                          setState(() {});
                                        },
                                        audioSaveHandler: (String tmpPath, int inMilliseconds) {
                                          _audioHandler(tmpPath: tmpPath, inMilliseconds: inMilliseconds);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        _isShowVideoRecoderPanel
                            ? Container(
                                width: deviceWidth,
                                child: Row(
                                  children: [
                                    RotatedBox(
                                      quarterTurns:
                                          (_cameraOrientation == DeviceOrientation.portraitDown || _cameraOrientation == DeviceOrientation.portraitUp)
                                              ? 0
                                              : 1,
                                      child: VideoRecoderPanel(
                                        scaffoldKey: _scaffoldKey,
                                        cameraController: cameraController,
                                        keicyProgressDialog: _keicyProgressDialog,
                                        width: (_cameraOrientation == DeviceOrientation.portraitDown ||
                                                _cameraOrientation == DeviceOrientation.portraitUp)
                                            ? deviceWidth
                                            : _cameraViewHeiht - heightDp! * 120,
                                        videoSaveHandler: (XFile xfile, int inMilliseconds) {
                                          _videoHandler(videoFile: xfile, inMilliseconds: inMilliseconds);
                                        },
                                        onAudioModeButtonPressed: onAudioModeButtonPressed,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        _categoryToolPanel(orientation: _orientation),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _cameraToolTopPanel({@required NativeDeviceOrientation? orientation}) {
    double angle = 0;
    if (orientation == NativeDeviceOrientation.portraitUp || orientation == NativeDeviceOrientation.portraitUp) {
      angle = 0;
    } else if (orientation == NativeDeviceOrientation.landscapeLeft || orientation == NativeDeviceOrientation.landscapeRight) {
      angle = pi / 2;
    }
    return Container(
      width: deviceWidth,
      height: heightDp! * 40,
      decoration: BoxDecoration(color: Colors.black),
      padding: EdgeInsets.symmetric(horizontal: widthDp! * 5),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Transform.rotate(
            angle: angle,
            child: IconButton(
              icon: Icon(Icons.cancel_outlined, size: heightDp! * 20, color: Colors.white),
              onPressed: () {
                _closeHandler();
              },
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<Position>(
                  stream: Geolocator.getPositionStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      _currentPosition = snapshot.data;
                    }

                    return Icon(
                      Icons.gps_fixed_outlined,
                      size: heightDp! * 20,
                      color: _currentPosition != null ? AppColors.green : AppColors.red,
                    );
                  },
                ),
                SizedBox(width: widthDp! * 10),
                Text(
                  KeicyDateTime.convertDateTimeToDateString(
                    dateTime: DateTime.now(),
                    formats: "h:i",
                  ),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.rotate(
                angle: angle,
                child: FlashModeControllWidget(
                  cameraController: cameraController,
                  iconSize: heightDp! * 20,
                  onPressHandler: (nextMode) => onSetFlashModeButtonPressed(nextMode),
                ),
              ),
              Transform.rotate(
                angle: angle,
                child: CameraToggleWidget(
                  cameraController: cameraController,
                  cameras: cameras,
                  onPressHandler: (CameraDescription description) =>
                      onNewCameraSelected(description, _appDataProvider!.appDataState.settingsModel!.photoResolution!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    try {
      double aspectRatio = 1;
      print("--------ssssss------------");
      print(_isInit);
      print(!_isInit || cameraController == null || !cameraController!.value.isInitialized);
      print("----------sss----------");
      if (!_isInit || cameraController == null || !cameraController!.value.isInitialized) {
        return Center(
          child: Text(
            'Tap a camera',
            style: TextStyle(
              color: Colors.transparent,
              fontSize: 24.0,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      }

      _cameraViewHeiht = deviceHeight! - statusbarHeight!;
      // _cameraViewHeiht = deviceHeight! - heightDp! * 150 - statusbarHeight!;

      int turns;

      double deviceRatio = deviceWidth! / (deviceHeight! - statusbarHeight!);
      // double deviceRatio = deviceWidth! / (deviceHeight! - heightDp! * 120 - statusbarHeight!);
      double yScale = 1;
      double xScale = 1;

      switch (_orientation) {
        case NativeDeviceOrientation.landscapeLeft:
          turns = 1;
          aspectRatio = cameraController!.value.aspectRatio;
          xScale = (1 / cameraController!.value.aspectRatio) / deviceRatio;
          yScale = 1;
          if (_cameraOrientation == null || (_cameraOrientation != DeviceOrientation.landscapeRight)) {
            _cameraOrientation = DeviceOrientation.landscapeRight;
            WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
              await cameraController!.lockCaptureOrientation(_cameraOrientation);
              setState(() {});
            });
          }
          break;
        case NativeDeviceOrientation.landscapeRight:
          turns = -1;
          aspectRatio = cameraController!.value.aspectRatio;
          xScale = (1 / cameraController!.value.aspectRatio) / deviceRatio;
          yScale = 1;
          if (_cameraOrientation == null || (_cameraOrientation != DeviceOrientation.landscapeRight)) {
            _cameraOrientation = DeviceOrientation.landscapeRight;
            WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
              await cameraController!.lockCaptureOrientation(_cameraOrientation);
              setState(() {});
            });
          }
          break;
        case NativeDeviceOrientation.portraitDown:
          turns = 0;
          aspectRatio = 1 / cameraController!.value.aspectRatio;
          yScale = aspectRatio / deviceRatio;
          xScale = 1;

          if (_cameraOrientation == null || (_cameraOrientation != DeviceOrientation.portraitDown)) {
            _cameraOrientation = DeviceOrientation.portraitDown;
            WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
              await cameraController!.lockCaptureOrientation(_cameraOrientation);
              setState(() {});
            });
          }
          break;
        default:
          turns = 0;
          aspectRatio = 1 / cameraController!.value.aspectRatio;
          yScale = aspectRatio / deviceRatio;
          xScale = 1;

          if (_cameraOrientation == null || (_cameraOrientation != DeviceOrientation.portraitUp)) {
            _cameraOrientation = DeviceOrientation.portraitUp;
            WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
              await cameraController!.lockCaptureOrientation(_cameraOrientation);
              setState(() {});
            });
          }
          break;
      }

      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.black,
          // border: Border.all(
          //   color: cameraController != null && cameraController!.value.isRecordingVideo ? Colors.redAccent : Colors.transparent,
          //   width: cameraController != null && cameraController!.value.isRecordingVideo ? 3.0 : 0,
          // ),
        ),
        child: Listener(
          onPointerDown: (_) => _pointers++,
          onPointerUp: (_) => _pointers--,
          child: RotatedBox(
            quarterTurns: turns,
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: CameraPreview(
                cameraController!,
                child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate,
                    onTapDown: (details) => onViewFinderTap(details, constraints),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return Center(child: SizedBox());
    }
  }

  Widget _categoryToolPanel({@required NativeDeviceOrientation? orientation}) {
    double angle = 0;
    if (orientation == NativeDeviceOrientation.portraitUp || orientation == NativeDeviceOrientation.portraitUp) {
      angle = 0;
    } else if (orientation == NativeDeviceOrientation.landscapeLeft || orientation == NativeDeviceOrientation.landscapeRight) {
      angle = pi / 2;
    }

    int photosCount = 0;
    int audiosCount = 0;
    int notesCount = 0;
    int videosCount = 0;

    for (var i = 0; i < _localReportModel!.medias!.length; i++) {
      switch (_localReportModel!.medias![i].type) {
        case MediaType.audio:
          audiosCount++;
          break;
        case MediaType.note:
          notesCount++;
          break;
        case MediaType.picture:
          photosCount++;
          break;
        case MediaType.video:
          videosCount++;
          break;
        default:
      }
    }
    return Consumer<CameraProvider>(builder: (context, cameraProvider, _) {
      return Container(
        width: deviceWidth,
        padding: EdgeInsets.symmetric(horizontal: widthDp! * 15, vertical: heightDp! * 10),
        // height: heightDp! * 80,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ///
                Transform.rotate(
                  angle: angle,
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Image.asset(
                          "lib/Assets/Images/edit_note.png",
                          width: heightDp! * 30,
                          height: heightDp! * 30,
                          color: Colors.white,
                        ),
                        color: Colors.blue,
                        iconSize: heightDp! * 30,
                        onPressed: () async {
                          var note = await NotePanelDialog.show(context, isNew: true, topMargin: heightDp! * 40);
                          if (note != null) {
                            _noteHandler(note: note, isNew: true);
                          }
                        },
                      ),
                      Positioned(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                              decoration: BoxDecoration(
                                color: AppColors.yello,
                                borderRadius: BorderRadius.circular(heightDp! * 3),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "$notesCount",
                                style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                ///
                Transform.rotate(
                  angle: angle,
                  child: Stack(
                    children: [
                      IconButton(
                          icon: Icon(
                            Icons.camera_alt,
                            color: (!_isShowVideoRecoderPanel &&
                                    cameraController != null &&
                                    cameraController!.value.isInitialized &&
                                    !cameraController!.value.isRecordingVideo)
                                ? (!_isShowVideoRecoderPanel)
                                    ? AppColors.yello
                                    : Colors.white
                                : Colors.white.withOpacity(0.6),
                            size: heightDp! * 30,
                          ),
                          onPressed: () {}
                          // cameraController != null && cameraController!.value.isInitialized && !cameraController!.value.isRecordingVideo
                          //     ? _onTakePictureButtonPressed
                          //     : null,
                          ),
                      Positioned(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                              decoration: BoxDecoration(
                                color: AppColors.yello,
                                borderRadius: BorderRadius.circular(heightDp! * 3),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "$photosCount",
                                style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                ///
                GestureDetector(
                  onTap: () {
                    if (_isShowVideoRecoderPanel) {
                      if (!cameraController!.value.isRecordingVideo) {
                        _cameraProvider!.setVideoRecordStatus("recording");
                      } else if (cameraController!.value.isRecordingVideo) {
                        _cameraProvider!.setVideoRecordStatus("stopped");
                      }
                    } else if (!_isShowVideoRecoderPanel) {
                      if (cameraController != null && cameraController!.value.isInitialized && !cameraController!.value.isRecordingVideo) {
                        _onTakePictureButtonPressed();
                      }
                    }
                  },
                  child: Container(
                    width: heightDp! * 60,
                    height: heightDp! * 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: cameraController != null && _isShowVideoRecoderPanel && _cameraProvider!.videoRecordStatus == "recording"
                              ? heightDp! * 35
                              : heightDp! * 48,
                          height: cameraController != null && _isShowVideoRecoderPanel && _cameraProvider!.videoRecordStatus == "recording"
                              ? heightDp! * 35
                              : heightDp! * 48,
                          decoration: BoxDecoration(
                            color: _isShowVideoRecoderPanel ? Colors.red : AppColors.yello,
                            borderRadius: BorderRadius.circular(
                              cameraController != null && _isShowVideoRecoderPanel && _cameraProvider!.videoRecordStatus == "recording"
                                  ? heightDp! * 6
                                  : heightDp! * 48,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                ///
                Transform.rotate(
                  angle: angle,
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.videocam,
                          color: (_isAudioRecording || cameraController == null || !cameraController!.value.isInitialized)
                              ? Colors.white.withOpacity(0.6)
                              : _isShowVideoRecoderPanel
                                  ? AppColors.yello
                                  : Colors.white,
                          size: heightDp! * 30,
                        ),
                        onPressed: !_isAudioRecording &&
                                cameraController != null &&
                                cameraController!.value.isInitialized &&
                                !cameraController!.value.isRecordingVideo
                            ? () {
                                _isShowVideoRecoderPanel = !_isShowVideoRecoderPanel;
                                _isShowAudioRecoderPanel = false;
                                _cameraProvider!.setIsAudioRecord(_isShowAudioRecoderPanel, isNotifiable: false);
                                _cameraProvider!.setIsVideoRecord(_isShowVideoRecoderPanel, isNotifiable: false);
                                _cameraProvider!.setAudioRecordStatus("stopped", isNotifiable: false);
                                _cameraProvider!.setVideoRecordStatus("stopped", isNotifiable: false);

                                if (_isShowVideoRecoderPanel)
                                  onNewCameraSelected(cameraController!.description, _appDataProvider!.appDataState.settingsModel!.videoResolution!);
                                else
                                  onNewCameraSelected(cameraController!.description, _appDataProvider!.appDataState.settingsModel!.photoResolution!);
                              }
                            : null,
                      ),
                      Positioned(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                              decoration: BoxDecoration(
                                color: AppColors.yello,
                                borderRadius: BorderRadius.circular(heightDp! * 3),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "$videosCount",
                                style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /// audio recoder
                Transform.rotate(
                  angle: angle,
                  child: Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.mic),
                        color: (cameraController != null && cameraController!.value.isInitialized && !cameraController!.value.isRecordingVideo)
                            ? _isShowAudioRecoderPanel
                                ? AppColors.yello
                                : Colors.white
                            : Colors.white.withOpacity(0.6),
                        iconSize: heightDp! * 30,
                        onPressed: cameraController != null &&
                                cameraController!.value.isInitialized &&
                                !cameraController!.value.isRecordingVideo &&
                                _cameraProvider!.audioRecordStatus != "recording"
                            ? () {
                                setState(() {
                                  _isShowAudioRecoderPanel = !_isShowAudioRecoderPanel;
                                  _isShowVideoRecoderPanel = false;
                                  _cameraProvider!.setIsAudioRecord(_isShowAudioRecoderPanel, isNotifiable: false);
                                  _cameraProvider!.setIsVideoRecord(_isShowVideoRecoderPanel, isNotifiable: false);
                                  _cameraProvider!.setVideoRecordStatus("stopped", isNotifiable: false);
                                  _cameraProvider!.setAudioRecordStatus("stopped", isNotifiable: false);

                                  if (_isShowAudioRecoderPanel) {
                                    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                                      _cameraProvider!.setAudioRecordStatus("recording");
                                    });
                                  }
                                });
                              }
                            : () {},
                      ),
                      Positioned(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                              decoration: BoxDecoration(
                                color: AppColors.yello,
                                borderRadius: BorderRadius.circular(heightDp! * 3),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "$audiosCount",
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
            SizedBox(height: heightDp! * 15),
          ],
        ),
      );
    });
  }

  void onSetFlashModeButtonPressed(FlashMode mode) async {
    if (cameraController == null) return;
    try {
      await cameraController!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
    if (mounted) setState(() {});
    showInSnackBar('Flash mode set to ${mode.toString().split('.').last}');
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (cameraController != null && !cameraController!.value.isRecordingVideo) {
      onNewCameraSelected(cameraController!.description, _appDataProvider!.appDataState.settingsModel!.photoResolution!);
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (cameraController == null || _pointers != 2) {
      return;
    }

    _currentScale = (_baseScale * details.scale).clamp(_minAvailableZoom, _maxAvailableZoom);

    await cameraController!.setZoomLevel(_currentScale);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (cameraController == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController!.setExposurePoint(offset);
    cameraController!.setFocusPoint(offset);
  }

  void _onTakePictureButtonPressed() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController!.value.isTakingPicture) return;

    try {
      await _keicyProgressDialog!.show();
      XFile file = await cameraController!.takePicture();
      _pictureHandler(imageFile: file);
      if (file.path != "") showInSnackBar('Picture saved to ${file.path}');
    } on CameraException catch (e) {
      await _keicyProgressDialog!.hide();
      _showCameraException(e);
      return;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description!);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  void logError(String code, String message) {
    if (message != null) {
      print('Error: $code\nError Message: $message');
    } else {
      print('Error: $code');
    }
  }

  void showInSnackBar(String message) {
    // ignore: deprecated_member_use
    // _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
  }
}
