// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:legatus/ApiDataProviders/local_report_api_provider.dart';
import 'package:legatus/Helpers/date_time_convert.dart';
import 'package:legatus/Helpers/file_helpers.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Pages/Components/index.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/Dialogs/failed_dialog.dart';
import 'package:legatus/Pages/Dialogs/note_panel_dialog.dart';
import 'package:legatus/Providers/index.dart';
import 'package:legatus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:uuid/uuid.dart';

class GalleryView extends StatefulWidget {
  final LocalReportModel localReportModel;
  final LocalMediaListProvider localMediaListProvider;
  final int index;

  const GalleryView({
    Key? key,
    required this.localReportModel,
    required this.index,
    required this.localMediaListProvider,
  }) : super(key: key);

  @override
  GalleryViewState createState() => GalleryViewState();
}

class GalleryViewState extends State<GalleryView> with SingleTickerProviderStateMixin {
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

  // KeicyProgressDialog? _keicyProgressDialog;

  LocalReportModel? _localReportModel;
  MediaModel? _selectedMediaModel;
  int selectedIndex = 0;

  int photosCount = 0;
  int audiosCount = 0;
  int notesCount = 0;
  int videosCount = 0;
  int totalCount = 0;
  String mediaType = "";
  String responsiveStyle = "";

  Position? _currentPosition;
  StreamSubscription? _locationSubscription;
  Map<String, dynamic> _updatedStatus = <String, dynamic>{};
  // late PageController _pageController;

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

    // _keicyProgressDialog = KeicyProgressDialog.of(
    //   context,
    //   backgroundColor: Colors.transparent,
    //   elevation: 0,
    //   layout: Layout.column,
    //   padding: EdgeInsets.zero,
    //   width: heightDp! * 120,
    //   height: heightDp! * 120,
    //   progressWidget: Container(
    //     width: heightDp! * 120,
    //     height: heightDp! * 120,
    //     padding: EdgeInsets.all(heightDp! * 20),
    //     decoration: BoxDecoration(
    //       color: Colors.white,
    //       borderRadius: BorderRadius.circular(heightDp! * 10),
    //     ),
    //     child: SpinKitFadingCircle(
    //       color: AppColors.primayColor,
    //       size: heightDp! * 80,
    //     ),
    //   ),
    //   message: "",
    // );

    _localReportModel = LocalReportModel.copy(widget.localReportModel);
    selectedIndex = widget.index;

    // _pageController = PageController(initialPage: selectedIndex);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _permissionHander();
    });
  }

  void _permissionHander() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      _currentPosition = await Geolocator.getCurrentPosition();
    }

    _locationSubscription = Geolocator.getPositionStream().listen((position) {
      _currentPosition = position;
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >= ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "desktop";
    } else if (MediaQuery.of(context).size.width >= ResponsiveDesignSettings.mobileMaxWidth &&
        MediaQuery.of(context).size.width < ResponsiveDesignSettings.tableteMaxWidth) {
      responsiveStyle = "tablet";
    } else if (MediaQuery.of(context).size.width < ResponsiveDesignSettings.mobileMaxWidth) {
      responsiveStyle = "mobile";
    }

    photosCount = 0;
    audiosCount = 0;
    notesCount = 0;
    videosCount = 0;
    totalCount = 0;
    for (var i = 0; i < _localReportModel!.medias!.length; i++) {
      totalCount++;

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

    _selectedMediaModel = _localReportModel!.medias![selectedIndex];

    switch (_localReportModel!.medias![selectedIndex].type) {
      case MediaType.audio:
        mediaType = LocaleKeys.GalleryPageString_audio.tr();
        break;
      case MediaType.note:
        mediaType = LocaleKeys.GalleryPageString_note.tr();
        break;
      case MediaType.picture:
        mediaType = LocaleKeys.GalleryPageString_photo.tr();
        break;
      case MediaType.video:
        mediaType = LocaleKeys.GalleryPageString_video.tr();
        break;
      default:
    }

    Widget panel = const SizedBox();
    switch (_localReportModel!.medias![selectedIndex].type) {
      case MediaType.audio:
        mediaType = LocaleKeys.GalleryPageString_audio.tr();
        panel = _audioPanel();
        break;
      case MediaType.note:
        mediaType = LocaleKeys.GalleryPageString_note.tr();
        panel = _notePanel();
        break;
      case MediaType.picture:
        mediaType = LocaleKeys.GalleryPageString_photo.tr();
        panel = _picturePanel();
        break;
      case MediaType.video:
        mediaType = LocaleKeys.GalleryPageString_video.tr();
        panel = _videoPanel();
        break;
      default:
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_updatedStatus);
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              width: deviceWidth,
              height: deviceHeight,
              child: Column(
                children: [
                  Container(width: deviceWidth, height: statusbarHeight!, color: AppColors.primayColor),
                  _appBarWidget(),
                  _mediaCountPanel(),
                  Expanded(child: panel),
                  // Expanded(
                  //   child: PageView.builder(
                  //     controller: _pageController,
                  //     itemCount: _localReportModel!.medias!.length,
                  //     onPageChanged: (int index) {
                  //       selectedIndex = index;
                  //       setState(() {});
                  //     },
                  //     itemBuilder: (context, index) {
                  //       Widget panel = SizedBox();
                  //       switch (_localReportModel!.medias![selectedIndex].type) {
                  //         case MediaType.audio:
                  //           mediaType = LocaleKeys.GalleryPageString_audio.tr();
                  //           panel = _audioPanel();
                  //           break;
                  //         case MediaType.note:
                  //           mediaType = LocaleKeys.GalleryPageString_note.tr();
                  //           panel = _notePanel();
                  //           break;
                  //         case MediaType.picture:
                  //           mediaType = LocaleKeys.GalleryPageString_photo.tr();
                  //           panel = _picturePanel();
                  //           break;
                  //         case MediaType.video:
                  //           mediaType = LocaleKeys.GalleryPageString_video.tr();
                  //           panel = _videoPanel();
                  //           break;
                  //         default:
                  //       }
                  //       return panel;
                  //     },
                  //   ),
                  // ),
                  _navigationToolPanel(),
                ],
              ),
            ),
            Column(
              children: [
                Container(width: deviceWidth, height: statusbarHeight!, color: AppColors.primayColor),
                _appBarWidget(),
                _mediaCountPanel(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _appBarWidget() {
    double iconSize = heightDp! * 25;
    double iconPadding = widthDp! * 7;

    if (responsiveStyle != "mobile") {
      iconSize = heightDp! * 38;
      iconPadding = widthDp! * 25;
    }

    return Container(
      width: deviceWidth,
      height: appbarHeight,
      color: AppColors.primayColor,
      child: Row(
        children: [
          GestureDetector(
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  SizedBox(width: iconPadding),
                  Icon(Icons.arrow_back_ios_outlined, size: iconSize * 0.8, color: Colors.white),
                  SizedBox(width: iconPadding),
                ],
              ),
            ),
            onTap: () => Navigator.of(context).pop(_updatedStatus),
          ),
          Expanded(
            child: Center(
              child: Text(
                LocaleKeys.GalleryPageString_gallery.tr(),
                style: Theme.of(context).textTheme.headline6,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: iconPadding),
                child: Icon(Icons.perm_media_outlined, size: iconSize, color: Colors.white),
              ),
              SizedBox(width: widthDp! * 5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mediaCountPanel() {
    double iconSize = heightDp! * 20;
    double iconPadding = widthDp! * 5;
    TextStyle? textStyle = Theme.of(context).textTheme.overline;

    if (responsiveStyle != "mobile") {
      iconSize = heightDp! * 35;
      iconPadding = widthDp! * 20;
      textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 10),
      color: const Color(0xFFE7E7E7),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.collections_outlined, size: iconSize, color: Colors.black),
                SizedBox(width: iconPadding / 2),
                Text(
                  LocaleKeys.LocalReportWidgetString_photos.tr(),
                  style: textStyle,
                ),
                SizedBox(width: iconPadding),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                  decoration: BoxDecoration(
                    color: AppColors.yello,
                    borderRadius: BorderRadius.circular(heightDp! * 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$photosCount",
                    style: textStyle!.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: widthDp! * 2),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_none, size: iconSize, color: Colors.black),
                SizedBox(width: iconPadding / 2),
                Text(
                  LocaleKeys.LocalReportWidgetString_audios.tr(),
                  style: textStyle,
                ),
                SizedBox(width: iconPadding),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                  decoration: BoxDecoration(
                    color: AppColors.yello,
                    borderRadius: BorderRadius.circular(heightDp! * 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$audiosCount",
                    style: textStyle.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: widthDp! * 2),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sticky_note_2_outlined, size: iconSize, color: Colors.black),
                SizedBox(width: iconPadding / 2),
                Text(
                  LocaleKeys.LocalReportWidgetString_notes.tr(),
                  style: textStyle,
                ),
                SizedBox(width: iconPadding),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                  decoration: BoxDecoration(
                    color: AppColors.yello,
                    borderRadius: BorderRadius.circular(heightDp! * 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$notesCount",
                    style: textStyle.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: widthDp! * 2),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library_outlined, size: iconSize, color: Colors.black),
                SizedBox(width: iconPadding / 2),
                Text(
                  LocaleKeys.LocalReportWidgetString_videos.tr(),
                  style: textStyle,
                ),
                SizedBox(width: iconPadding),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 3),
                  decoration: BoxDecoration(
                    color: AppColors.yello,
                    borderRadius: BorderRadius.circular(heightDp! * 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$videosCount",
                    style: textStyle.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notePanel() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widthDp! * 20,
        vertical: heightDp! * 20,
      ),
      color: Colors.white,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          var note = await NotePanelDialog.show(context, isNew: false, mediaModel: _selectedMediaModel);
          if (note != null) {
            _noteHandler(note: note, isNew: false, mediaModel: _selectedMediaModel);
          }
        },
        child: Container(
          width: deviceWidth,
          padding: EdgeInsets.symmetric(
            horizontal: widthDp! * 20,
            vertical: heightDp! * 15,
          ),
          color: Colors.grey.withOpacity(0.3),
          child: Text(
            "${_selectedMediaModel!.content}",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _audioPanel() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widthDp! * 10,
            vertical: heightDp! * 10,
          ),
          child: AudioGalleryWidget(
            key: GlobalKey(),
            mediaModel: _selectedMediaModel,
          ),
        ),
      ],
    );
  }

  Widget _videoPanel() {
    return VideoWidgetForGallery(
      key: GlobalKey(),
      mediaModel: _selectedMediaModel,
      totalMediaCount: _localReportModel!.medias!.length,
    );
  }

  Widget _picturePanel() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widthDp! * 10,
        vertical: heightDp! * 10,
      ),
      child: PictureGalleryWidget(
        key: GlobalKey(),
        mediaModel: _selectedMediaModel,
      ),
    );
  }

  Widget _navigationToolPanel() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (selectedIndex == 0) return;
              selectedIndex--;
              // _pageController.jumpToPage(selectedIndex);
              setState(() {});
            },
            child: Container(
              width: widthDp! * 70,
              height: widthDp! * 70,
              color: Colors.grey.withOpacity(0.4),
              child: Icon(
                Icons.arrow_back_ios,
                size: heightDp! * 25,
                color: selectedIndex == 0 ? Colors.grey : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: widthDp! * 70,
              color: Colors.grey.withOpacity(0.2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${selectedIndex + 1}",
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        " ${LocaleKeys.GalleryPageString_on.tr()} ",
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        "$totalCount",
                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: heightDp! * 2),
                  Text(
                    mediaType,
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: heightDp! * 2),
                  Text(
                    KeicyDateTime.convertDateTimeToDateString(
                      dateTime: DateTime.tryParse(_selectedMediaModel!.createdAt!),
                      formats: 'd/m/Y H:i:s',
                    ),
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (selectedIndex == _localReportModel!.medias!.length - 1) return;
              selectedIndex++;
              // _pageController.jumpToPage(selectedIndex);
              setState(() {});
            },
            child: Container(
              width: widthDp! * 70,
              height: widthDp! * 70,
              color: Colors.grey.withOpacity(0.4),
              child: Icon(
                Icons.arrow_forward_ios_outlined,
                size: heightDp! * 25,
                color: selectedIndex == _localReportModel!.medias!.length - 1 ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _noteHandler({String? note, bool? isNew = true, MediaModel? mediaModel}) async {
    LocalReportModel localReportModel = LocalReportModel.copy(_localReportModel!);
    try {
      if (isNew!) {
        String? path = await FileHelpers.getFilePath(
          mediaType: MediaType.note,
          rank: localReportModel.medias!.length + 1,
          fileType: "txt",
        );

        if (path == null) {
          // await _keicyProgressDialog!.hide();
          FailedDialog.show(context, text: "Creating new note file path occur error");
          return;
        }

        File? textFile = await FileHelpers.writeTextFile(text: note, path: path);

        if (textFile == null) {
          // await _keicyProgressDialog!.hide();
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
        mediaModel.rank = localReportModel.medias!.length + 1;
        mediaModel.reportId = localReportModel.reportId!;
        mediaModel.size = textFile.readAsBytesSync().lengthInBytes;
        mediaModel.state = "captured";
        mediaModel.type = MediaType.note;
        mediaModel.uuid = const Uuid().v4();

        localReportModel.medias ??= [];
        localReportModel.medias = List.from(localReportModel.medias!);
        localReportModel.medias!.add(mediaModel);
      } else {
        for (var i = 0; i < localReportModel.medias!.length; i++) {
          if (localReportModel.medias![i].createdAt == mediaModel!.createdAt!) {
            File oldTextFile = File(mediaModel.path!);
            try {
              await oldTextFile.delete();
            } catch (e) {
              if (kDebugMode) {
                print(e);
              }
              // await _keicyProgressDialog!.hide();
              FailedDialog.show(context, text: "Deleting old note file occur error");
              return;
            }

            File? textFile = await FileHelpers.writeTextFile(text: note, path: mediaModel.path!);

            if (textFile == null) {
              // await _keicyProgressDialog!.hide();
              FailedDialog.show(context, text: "Creating update note file occur error");
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
            mediaModel.state = "captured";

            localReportModel.medias![i] = mediaModel;
            break;
          }
        }
      }

      bool success = await _updateLocalReport(localReportModel);

      // await _keicyProgressDialog!.hide();

      if (success) {
        var result = await LocalReportApiProvider.getLocalReportModel(localReportModel: localReportModel);
        if (result["success"]) {
          _localReportModel = result["data"];
        } else {
          _localReportModel = localReportModel;
        }
        _updatedStatus = {
          "isUpdated": true,
          "localReportModel": _localReportModel,
        };

        widget.localMediaListProvider.setLocalMediaListState(
          widget.localMediaListProvider.localMediaListState.update(
            localLocalReportModel: _localReportModel,
          ),
          isNotifiable: true,
        );

        String message = isNew ? "Note enregistrée avec succès" : "Note mise à jour avec succès";
        // SuccessDialog.show(context, text: message);
        // Fluttertoast.showToast(
        //   msg: message,
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.TOP,
        //   timeInSecForIosWeb: 1,
        //   backgroundColor: Colors.black,
        //   textColor: Colors.greenAccent,
        //   fontSize: 16.0,
        // );
        showTopSnackBar(
          context,
          CustomSnackBar.success(
            message: message,
            icon: const SizedBox(),
            messagePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        );

        setState(() {});
      } else {
        FailedDialog.show(context, text: isNew ? "New note error" : "Update note error");
        return;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      FailedDialog.show(context, text: isNew! ? "New note error" : "Update note error");
      return;
    }
  }

  Future<bool> _updateLocalReport(LocalReportModel localReportModel) async {
    var result = await LocalReportApiProvider.update(
      localReportModel: localReportModel,
      oldReportIdStr: "${localReportModel.date} ${localReportModel.time}_${localReportModel.createdAt}",
    );
    LocalReportListProvider.of(context).setLocalReportListState(
      LocalReportListProvider.of(context).localReportListState.update(
            refreshList: true,
          ),
    );
    return result["success"];
  }
}
