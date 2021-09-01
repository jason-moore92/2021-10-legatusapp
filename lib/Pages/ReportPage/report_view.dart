import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:legutus/Pages/App/index.dart';
import 'package:legutus/Pages/Components/keicy_progress_dialog.dart';
import 'package:legutus/ApiDataProviders/index.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Helpers/file_helpers.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/CameraPage/index.dart';
import 'package:legutus/Pages/Components/index.dart';
import 'package:legutus/Pages/Dialogs/index.dart';
import 'package:legutus/Pages/ReportNewPage/new_report_page.dart';
import 'package:legutus/Providers/LocalMediaListProvider/index.dart';
import 'package:legutus/Providers/index.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock/wakelock.dart';

class ReportView extends StatefulWidget {
  final LocalReportModel? localReportModel;

  ReportView({Key? key, this.localReportModel}) : super(key: key);

  @override
  _ReportViewState createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> with SingleTickerProviderStateMixin {
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

  LocalReportModel? _localReportModel;

  Map<String, dynamic> _updatedStatus = Map<String, dynamic>();

  KeicyProgressDialog? _keicyProgressDialog;

  LocalMediaListProvider? _localMediaListProvider;
  LocalReportProvider? _localReportProvider;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  ScrollController? _controller = ScrollController();

  List<int>? _selectedMediaRanks;
  bool _selectStatus = false;

  Position? _currentPosition;
  StreamSubscription? _locationSubscription;

  int photosCount = 0;
  int audiosCount = 0;
  int notesCount = 0;
  int videosCount = 0;
  int totalCount = 0;
  int nonUploadedCount = 0;
  String responsiveStyle = "";

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

    _selectedMediaRanks = [];

    _localReportModel = LocalReportModel.copy(widget.localReportModel!);
    _localReportProvider = LocalReportProvider.of(context);
    _localMediaListProvider = LocalMediaListProvider.of(context);

    _localMediaListProvider!.setLocalMediaListState(
      _localMediaListProvider!.localMediaListState.update(
        localLocalReportModel: _localReportModel,
      ),
      isNotifiable: false,
    );

    _localReportProvider!.setLocalReportState(
      LocalReportState.init().copyWith(contextName: "ReportPage"),
      isNotifiable: false,
    );

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      _locationSubscription = Geolocator.getPositionStream().listen((position) {
        _currentPosition = position;
      });

      _localMediaListProvider!.addListener(_localMediaListProviderListener);
      _localReportProvider!.addListener(_localReportProviderListener);

      _localMediaListProvider!.setLocalMediaListState(
        _localMediaListProvider!.localMediaListState.update(
          progressState: 1,
        ),
      );

      _localMediaListProvider!.getLocalMediaList();
    });
  }

  @override
  void dispose() {
    _localMediaListProvider!.removeListener(_localMediaListProviderListener);
    _localReportProvider!.removeListener(_localReportProviderListener);
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
      _locationSubscription = null;
    }
    super.dispose();
  }

  void _localMediaListProviderListener() async {
    if (_localMediaListProvider!.localMediaListState.progressState == -1) {
      if (_localMediaListProvider!.localMediaListState.isRefresh!) {
        _localMediaListProvider!.setLocalMediaListState(
          _localMediaListProvider!.localMediaListState.update(isRefresh: false),
          isNotifiable: false,
        );
        _refreshController.refreshFailed();
      } else {
        _refreshController.loadFailed();
      }
    } else if (_localMediaListProvider!.localMediaListState.progressState == 2) {
      if (_localMediaListProvider!.localMediaListState.isRefresh!) {
        _localMediaListProvider!.setLocalMediaListState(
          _localMediaListProvider!.localMediaListState.update(isRefresh: false),
          isNotifiable: false,
        );
        _refreshController.refreshCompleted();
      } else {
        _refreshController.loadComplete();
      }

      if (_localMediaListProvider!.localMediaListState.localMediaMetaData!["nextPage"] == 1) {
        // _controller!.jumpTo(0);
      }
    }
  }

  void _localReportProviderListener() async {
    if (_localReportProvider!.localReportState.contextName != "ReportPage") return;

    if (_localReportProvider!.localReportState.progressState != 1 && _keicyProgressDialog!.isShowing()) {
      await _keicyProgressDialog!.hide();
    }

    if (_localReportProvider!.localReportState.progressState == 2) {
      _localReportModel!.reportId = _localReportProvider!.localReportState.reportId;
      _updatedStatus = _updatedStatus = {
        "isUpdated": true,
        "localReportModel": _localReportModel,
      };
      setState(() {});
      Wakelock.disable();
      SuccessDialog.show(
        context,
        text: _localReportProvider!.localReportState.message!,
      );
    } else if (_localReportProvider!.localReportState.progressState == 3) {
      _localReportModel!.reportId = _localReportProvider!.localReportState.reportId;
      for (var i = 0; i < _localReportModel!.medias!.length; i++) {
        if (_localReportModel!.medias![i].rank! == _localReportProvider!.localReportState.uploadingMediaModel!.rank!) {
          _localReportModel!.medias![i] = _localReportProvider!.localReportState.uploadingMediaModel!;
          _updateLocalReport(_localReportModel!);
          break;
        }
      }
      List<dynamic> localMediaListData = _localMediaListProvider!.localMediaListState.localMediaListData!;
      for (var i = 0; i < localMediaListData.length; i++) {
        List<MediaModel> mediaModelList = localMediaListData[i];
        bool isFind = false;
        for (var k = 0; k < mediaModelList.length; k++) {
          if (mediaModelList[k].rank! == _localReportProvider!.localReportState.uploadingMediaModel!.rank!) {
            mediaModelList[k] = _localReportProvider!.localReportState.uploadingMediaModel!;
            isFind = true;
            break;
          }
        }
        if (isFind) break;
      }
      _localMediaListProvider!.setLocalMediaListState(
        _localMediaListProvider!.localMediaListState.update(
          localMediaListData: localMediaListData,
        ),
        isNotifiable: false,
      );
      _updatedStatus = _updatedStatus = {
        "isUpdated": true,
        "localReportModel": _localReportModel,
      };
      setState(() {});
    } else if (_localReportProvider!.localReportState.progressState == -1) {
      FailedDialog.show(
        context,
        text: _localReportProvider!.localReportState.message!,
      );
    }
  }

  void _onRefresh() async {
    _selectStatus = false;
    _selectedMediaRanks = [];
    List<dynamic> localMediaListData = _localMediaListProvider!.localMediaListState.localMediaListData!;
    Map<String, dynamic> localMediaMetaData = _localMediaListProvider!.localMediaListState.localMediaMetaData!;

    localMediaListData = [];
    localMediaMetaData = Map<String, dynamic>();
    _localMediaListProvider!.setLocalMediaListState(
      _localMediaListProvider!.localMediaListState.update(
        progressState: 1,
        localMediaListData: localMediaListData,
        localMediaMetaData: localMediaMetaData,
        isRefresh: true,
      ),
    );

    _localMediaListProvider!.getLocalMediaList();
  }

  void _onLoading() async {
    _localMediaListProvider!.setLocalMediaListState(
      _localMediaListProvider!.localMediaListState.update(progressState: 1),
    );
    _localMediaListProvider!.getLocalMediaList();
  }

  void _editHandler() async {
    var result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => NewReportPage(isNew: false, localReportModel: _localReportModel!),
      ),
    );
    if (result != null && result.isNotEmpty) {
      _updatedStatus = result;
      if (result["isUpdated"]) {
        _localReportModel = result["localReportModel"];
        setState(() {});
      }
    }
  }

  Future<void> _noteHandler({String? note, bool? isNew = true, MediaModel? mediaModel}) async {
    LocalReportModel localReportModel = LocalReportModel.copy(_localReportModel!);
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
          rank: localReportModel.medias!.length + 1,
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
        mediaModel.rank = localReportModel.medias!.length + 1;
        mediaModel.reportId = localReportModel.reportId!;
        mediaModel.size = textFile.readAsBytesSync().lengthInBytes;
        mediaModel.state = "captured";
        mediaModel.type = MediaType.note;
        mediaModel.uuid = Uuid().v4();

        if (_localReportModel!.medias == null) _localReportModel!.medias = [];
        localReportModel.medias!.add(mediaModel);
      } else {
        for (var i = 0; i < localReportModel.medias!.length; i++) {
          if (localReportModel.medias![i].createdAt == mediaModel!.createdAt!) {
            File oldTextFile = File(mediaModel.path!);
            try {
              await oldTextFile.delete();
            } catch (e) {
              print(e);
              await _keicyProgressDialog!.hide();
              FailedDialog.show(context, text: "Deleting old note file occur error");
              return;
            }

            File? textFile = await FileHelpers.writeTextFile(text: note, path: mediaModel.path!);

            if (textFile == null) {
              await _keicyProgressDialog!.hide();
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

      await _keicyProgressDialog!.hide();

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

        _localMediaListProvider!.setLocalMediaListState(
          _localMediaListProvider!.localMediaListState.update(
            localLocalReportModel: _localReportModel,
          ),
          isNotifiable: true,
        );

        String message = isNew ? "Note enregistrée avec succès" : "Note mise à jour avec succès";
        SuccessDialog.show(context, text: message);

        if (isNew) {
          _onRefresh();
        } else {
          setState(() {});
        }
      } else {
        FailedDialog.show(context, text: isNew ? "New note error" : "Update note error");
        return;
      }
    } catch (e) {
      print(e);
      FailedDialog.show(context, text: isNew! ? "New note error" : "Update note error");
      return;
    }
  }

  Future<bool> _updateLocalReport(LocalReportModel localReportModel) async {
    String createdAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: localReportModel.createdAt).toString();
    int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
      dateString: "${localReportModel.date} ${localReportModel.time}",
    )!;
    var result = await LocalReportApiProvider.update(
      localReportModel: localReportModel,
      oldReportId: "${reportDateTime}_$createdAt",
    );
    LocalReportListProvider.of(context).setLocalReportListState(
      LocalReportListProvider.of(context).localReportListState.update(
            refreshList: true,
          ),
    );
    return result["success"];
  }

  void _deleteLocalMedias() async {
    LocalReportModel localReportModel = LocalReportModel.copy(_localReportModel!);
    List<MediaModel> newMedias = [];
    for (var i = 0; i < localReportModel.medias!.length; i++) {
      MediaModel mediaModel = localReportModel.medias![i];
      if (_selectedMediaRanks!.contains(mediaModel.rank) && mediaModel.path! != "") {
        File oldFile = File(mediaModel.path!);
        try {
          await oldFile.delete();
        } catch (e) {
          print(e);
          newMedias.add(mediaModel);
        }
        if (mediaModel.thumPath != "") {
          File oldFile = File(mediaModel.thumPath!);
          try {
            await oldFile.delete();
          } catch (e) {
            print(e);
            newMedias.add(mediaModel);
          }
        }
      } else {
        newMedias.add(mediaModel);
      }
    }

    localReportModel.medias = newMedias;

    bool success = await _updateLocalReport(localReportModel);

    if (success) {
      SuccessDialog.show(context, text: "Médias supprimés de cet appareil avec succès.");
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

      _localMediaListProvider!.setLocalMediaListState(
        _localMediaListProvider!.localMediaListState.update(
          localLocalReportModel: _localReportModel,
        ),
        isNotifiable: false,
      );
      _onRefresh();
      LocalReportListProvider.of(context).setLocalReportListState(
        LocalReportListProvider.of(context).localReportListState.update(
              refreshList: true,
            ),
      );
    }
  }

  void _journalHandler(String email) async {
    await _keicyProgressDialog!.show();
    var result = await JournalApiProvider.sendJournal(
      email: email,
      localMediaModel: _localReportModel,
    );
    await _keicyProgressDialog!.hide();

    print(result);
    if (result["success"]) {
      SuccessDialog.show(
        context,
        text: result["data"]["message"],
      );
    } else {
      FailedDialog.show(
        context,
        text: result["data"]["message"],
      );
    }
  }

  void _uploadHandler() async {
    if (_localReportProvider!.localReportState.isUploading!) return;

    if (AuthProvider.of(context).authState.loginState == LoginState.IsNotLogin) {
      UploadReportDialog.show(
        context,
        callback: () {
          AppDataProvider.of(context).appDataState.bottomTabController!.jumpToTab(2);
        },
      );
    } else {
      _localReportProvider!.setLocalReportState(
        _localReportProvider!.localReportState.update(
          isUploading: true,
          uploadingMediaModel: MediaModel(),
          reportId: _localReportModel!.reportId,
        ),
      );
      Wakelock.enable();
      _localReportProvider!.uploadMedials(localReportModel: LocalReportModel.copy(_localReportModel!));
    }
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
    nonUploadedCount = 0;
    for (var i = 0; i < _localReportModel!.medias!.length; i++) {
      totalCount++;
      if (_localReportModel!.medias![i].state != "uploaded") {
        nonUploadedCount++;
      }

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

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_updatedStatus);
        return false;
      },
      child: Consumer2<LocalMediaListProvider, LocalReportProvider>(builder: (context, localMediaListProvider, localReportProvider, _) {
        return Scaffold(
          // appBar: AppBar(
          //   automaticallyImplyLeading: false,
          //   // leading: BackButton(onPressed: () => Navigator.of(context).pop(_updatedStatus)),
          //   leadingWidth: 0,

          //   title: ,
          // ),
          body: Container(
            width: deviceWidth,
            height: deviceHeight,
            child: Column(
              children: [
                Container(width: deviceWidth, height: statusbarHeight!, color: AppColors.primayColor),
                _appBarWidget(),
                localReportProvider.localReportState.isUploading!
                    ? _uploadingPanel()
                    : _selectStatus
                        ? _selectToolPanel()
                        : _mediaCountPanel(),
                SizedBox(height: heightDp! * 5),
                Expanded(
                  child: _localReportModel!.medias!.isEmpty ? _noMediaPanel() : _mediaPanel1(),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _floatingButtonPanel(),
        );
      }),
    );
  }

  Widget _appBarWidget() {
    double iconSize = heightDp! * 25;
    double iconPadding = widthDp! * 10;

    if (responsiveStyle != "mobile") {
      iconSize = heightDp! * 45;
      iconPadding = widthDp! * 20;
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
            child: Text(
              _localReportModel!.name!,
              style: Theme.of(context).textTheme.headline6,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _selectedMediaRanks = [];
                  _selectStatus = true;
                  for (var i = 0; i < _localReportModel!.medias!.length; i++) {
                    _selectedMediaRanks!.add(_localReportModel!.medias![i].rank!);
                  }
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: iconPadding),
                  child: Icon(Icons.select_all_outlined, size: iconSize, color: Colors.white),
                ),
              ),
              GestureDetector(
                onTap: () {
                  JournalPanelDialog.show(
                    context,
                    email: AuthProvider.of(context).authState.loginState == LoginState.IsLogin
                        ? AuthProvider.of(context).authState.userModel!.email!
                        : "",
                    callBack: (String email) => _journalHandler(email),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: iconPadding),
                  child: Image.asset(
                    "lib/Assets/Images/word.png",
                    width: iconSize - heightDp! * 5,
                    height: iconSize - heightDp! * 5,
                    color: Colors.white,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _localReportProvider!.localReportState.isUploading! ? null : _uploadHandler,
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: iconPadding),
                      child: Icon(Icons.cloud_upload_outlined, size: iconSize, color: Colors.white),
                    ),
                    if (nonUploadedCount != 0)
                      Positioned(
                        right: iconPadding / 2,
                        // bottom: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: widthDp! * 3, vertical: heightDp! * 2),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(heightDp! * 3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "$nonUploadedCount",
                            style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _editHandler,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: iconPadding),
                  child: Icon(Icons.info_outline_rounded, size: iconSize, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _floatingButtonPanel() {
    return Container(
      width: deviceWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () async {
              var note = await NotePanelDialog.show(context, isNew: true);
              if (note != null) {
                await _noteHandler(note: note, isNew: true);
              }
            },
            child: Container(
              width: heightDp! * 50,
              height: heightDp! * 50,
              decoration: BoxDecoration(
                color: AppColors.yello,
                shape: BoxShape.circle,
                // boxShadow: [
                //   BoxShadow(color: Colors.grey, offset: Offset(0, 3), blurRadius: 8),
                // ],
              ),
              alignment: Alignment.center,
              child: Image.asset(
                "lib/Assets/Images/edit_note.png",
                width: heightDp! * 25,
                height: heightDp! * 25,
                color: Colors.white,
                fit: BoxFit.cover,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              var result = await pushNewScreen(
                context,
                screen: CameraPage(localReportModel: _localReportModel, isPicture: true),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.fade,
              );
              // var result = await Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (BuildContext context) => CameraPage(isPicture: true),
              //   ),
              // );
              if (result != null && result.isNotEmpty) {
                _updatedStatus = result;
                if (result["isUpdated"]) {
                  _localReportModel = result["localReportModel"];

                  _localMediaListProvider!.setLocalMediaListState(
                    _localMediaListProvider!.localMediaListState.update(
                      localLocalReportModel: _localReportModel,
                    ),
                    isNotifiable: false,
                  );

                  _onRefresh();
                  // setState(() {});
                }
              }
            },
            child: Container(
              width: heightDp! * 65,
              height: heightDp! * 65,
              decoration: BoxDecoration(
                color: AppColors.yello,
                shape: BoxShape.circle,
                // boxShadow: [
                //   BoxShadow(color: Colors.grey, offset: Offset(0, 3), blurRadius: 8),
                // ],
              ),
              alignment: Alignment.center,
              child: Icon(Icons.photo_camera_outlined, size: heightDp! * 35, color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: () async {
              var result = await pushNewScreen(
                context,
                screen: CameraPage(localReportModel: _localReportModel, isAudio: true),
                withNavBar: false, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
              // var result = await Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (BuildContext context) => CameraPage(isAudio: true),
              //   ),
              // );

              if (result != null && result.isNotEmpty) {
                _updatedStatus = result;
                if (result["isUpdated"]) {
                  _localReportModel = result["localReportModel"];

                  _localMediaListProvider!.setLocalMediaListState(
                    _localMediaListProvider!.localMediaListState.update(
                      localLocalReportModel: _localReportModel,
                    ),
                    isNotifiable: false,
                  );

                  _onRefresh();
                  // setState(() {});
                }
              }
            },
            child: Container(
              width: heightDp! * 50,
              height: heightDp! * 50,
              decoration: BoxDecoration(
                color: AppColors.yello,
                shape: BoxShape.circle,
                // boxShadow: [
                //   BoxShadow(color: Colors.grey, offset: Offset(0, 3), blurRadius: 8),
                // ],
              ),
              alignment: Alignment.center,
              child: Icon(Icons.mic_none_outlined, size: heightDp! * 25, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaCountPanel() {
    double iconSize = heightDp! * 20;
    double iconPadding = widthDp! * 10;
    TextStyle? textStyle = Theme.of(context).textTheme.overline;

    if (responsiveStyle != "mobile") {
      iconSize = heightDp! * 35;
      iconPadding = widthDp! * 20;
      textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 10),
      color: Color(0xFFE7E7E7),
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

  Widget _selectToolPanel() {
    double iconSize = heightDp! * 20;
    double iconPadding = widthDp! * 10;
    TextStyle? textStyle = Theme.of(context).textTheme.overline;

    if (responsiveStyle != "mobile") {
      iconSize = heightDp! * 35;
      iconPadding = widthDp! * 20;
      textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black);
    }

    return Container(
      color: Color(0xFFE7E7E7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              _selectStatus = false;
              _selectedMediaRanks = [];
              setState(() {});
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 10),
              child: Transform.rotate(
                angle: pi / 4,
                child: Icon(Icons.add_circle_outline_outlined, size: iconSize, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                CustomCheckBox(
                  iconSize: iconSize,
                  iconColor: Colors.black,
                  trueIcon: Icons.check_box_outlined,
                  falseIcon: Icons.check_box_outline_blank,
                  label: LocaleKeys.ReportPageString_selecteAll.tr(),
                  labelSpacing: widthDp! * 5,
                  labelStyle: Theme.of(context).textTheme.bodyText1,
                  onChangeHandler: (value) {
                    if (value) {
                      _selectedMediaRanks = [];
                      for (var i = 0; i < _localReportModel!.medias!.length; i++) {
                        _selectedMediaRanks!.add(_localReportModel!.medias![i].rank!);
                      }
                    } else {
                      _selectedMediaRanks = [];
                    }

                    setState(() {});
                  },
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: widthDp! * 5),
                  padding: EdgeInsets.symmetric(horizontal: widthDp! * 5, vertical: heightDp! * 3),
                  decoration: BoxDecoration(
                    color: AppColors.yello,
                    borderRadius: BorderRadiusDirectional.circular(heightDp! * 4),
                  ),
                  child: Text(
                    "${_selectedMediaRanks!.length}",
                    style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              List<String> shareFiles = [];
              if (_selectedMediaRanks!.isNotEmpty && _localMediaListProvider!.localMediaListState.progressState == 2) {
                for (var i = 0; i < _localMediaListProvider!.localMediaListState.localLocalReportModel!.medias!.length; i++) {
                  MediaModel mediaModel = _localMediaListProvider!.localMediaListState.localLocalReportModel!.medias![i];
                  if (_selectedMediaRanks!.contains(mediaModel.rank)) {
                    shareFiles.add(mediaModel.path!);
                  }
                }
                Share.shareFiles(shareFiles);
              }
            },
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: iconPadding / 2, vertical: heightDp! * 10),
                  child: Transform.rotate(
                    angle: -pi / 2,
                    child: Icon(Icons.logout, size: iconSize, color: Colors.black),
                  ),
                ),
                Text(
                  LocaleKeys.ReportPageString_share.tr(),
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_selectedMediaRanks!.isEmpty) return;

              NormalAskDialog.show(
                context,
                title: LocaleKeys.DeleteMediaDialogString_title.tr(),
                content: LocaleKeys.DeleteMediaDialogString_content.tr(),
                okButton: LocaleKeys.DeleteMediaDialogString_delete.tr(),
                cancelButton: LocaleKeys.DeleteMediaDialogString_cancel.tr(),
                callback: () async {
                  _deleteLocalMedias();
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: iconPadding, vertical: heightDp! * 10),
              child: Icon(Icons.delete_outline_outlined, size: iconSize, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _uploadingPanel() {
    double iconSize = heightDp! * 20;
    double iconPadding = widthDp! * 10;
    TextStyle? textStyle = Theme.of(context).textTheme.overline;

    if (responsiveStyle != "mobile") {
      iconSize = heightDp! * 35;
      iconPadding = widthDp! * 20;
      textStyle = Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.black);
    }

    return Container(
      color: AppColors.yello,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: widthDp! * 10),
          Expanded(
            child: Row(
              children: [
                Icon(Icons.cloud_upload_outlined, size: iconSize, color: Colors.white),
                SizedBox(width: widthDp! * 5),
                Text(
                  LocaleKeys.NewReportPageString_uploading.tr(),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _localReportProvider!.setLocalReportState(
                _localReportProvider!.localReportState.update(
                  isUploading: false,
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: widthDp! * 10, vertical: heightDp! * 10),
              child: Transform.rotate(
                angle: pi / 4,
                child: Icon(Icons.add_circle_outline_outlined, size: iconSize, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noMediaPanel() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widthDp! * 40),
        child: Text(
          LocaleKeys.ReportPageString_noMediaDescription.tr(),
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _mediaPanel1() {
    List<dynamic> localMediaListData = [];
    Map<String, dynamic> localMediaMetaData = Map<String, dynamic>();

    if (_localMediaListProvider!.localMediaListState.localMediaListData != null) {
      localMediaListData = _localMediaListProvider!.localMediaListState.localMediaListData!;
    }
    if (_localMediaListProvider!.localMediaListState.localMediaMetaData != null) {
      localMediaMetaData = _localMediaListProvider!.localMediaListState.localMediaMetaData!;
    }

    int itemCount = 0;

    if (_localMediaListProvider!.localMediaListState.localMediaListData != null) {
      itemCount += _localMediaListProvider!.localMediaListState.localMediaListData!.length;
    }

    if (_localMediaListProvider!.localMediaListState.progressState == 1) {
      itemCount += AppConfig.refreshListLimit;
      // itemCount += 1;
    } else {
      itemCount++;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: widthDp! * 10),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (localReports) {
          localReports.disallowGlow();
          return true;
        },
        child: SmartRefresher(
          enablePullDown: true,
          enablePullUp: (localMediaMetaData["isEnd"] != null &&
              !localMediaMetaData["isEnd"] &&
              _localMediaListProvider!.localMediaListState.progressState != 1),
          header: WaterDropHeader(),
          footer: ClassicFooter(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView.builder(
            controller: _controller,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              List<MediaModel>? mediaModelList = (index >= localMediaListData.length) ? null : localMediaListData[index];
              if (_localMediaListProvider!.localMediaListState.progressState == 2 && mediaModelList == null && index == localMediaListData.length) {
                return SizedBox(height: heightDp! * 85);
              }
              if (mediaModelList == null) {
                return Container(
                  width: deviceWidth,
                  height: heightDp! * 50,
                  margin: EdgeInsets.symmetric(vertical: heightDp! * 5),
                  decoration: BoxDecoration(
                    color: Color(0xFFE7E7E7),
                    borderRadius: BorderRadius.circular(heightDp! * 6),
                  ),
                  alignment: Alignment.center,
                  child: CupertinoActivityIndicator(),
                );
              } else {
                return Wrap(
                  spacing: widthDp! * 10,
                  children: List.generate(mediaModelList.length, (index) {
                    MediaModel mediaModel = mediaModelList[index];

                    bool isUploading = _localReportProvider!.localReportState.isUploading! &&
                        _localReportProvider!.localReportState.uploadingMediaModel!.rank != -1 &&
                        mediaModel.rank == _localReportProvider!.localReportState.uploadingMediaModel!.rank;

                    switch (mediaModel.type) {
                      case MediaType.note:
                        return NoteMediaWidget(
                          mediaModel: mediaModel,
                          totalMediaCount: _localReportModel!.medias!.length,
                          isSelected: _selectedMediaRanks!.contains(mediaModel.rank),
                          isUploading: isUploading,
                          tapHandler: () async {
                            if (!_selectStatus && _selectedMediaRanks!.isEmpty) {
                              var note = await NotePanelDialog.show(context, isNew: false, mediaModel: mediaModel);
                              if (note != null) {
                                _noteHandler(note: note, isNew: false, mediaModel: mediaModel);
                              }
                            } else {
                              _tapHandler(mediaModel);
                            }
                          },
                          longPressHandler: () {
                            _longPressHandler(mediaModel);
                          },
                        );
                      case MediaType.picture:
                        return PictureMediaWidget(
                          mediaModel: mediaModel,
                          totalMediaCount: _localReportModel!.medias!.length,
                          isSelected: _selectedMediaRanks!.contains(mediaModel.rank),
                          selectStatus: _selectStatus,
                          isUploading: isUploading,
                          tapHandler: () {
                            _tapHandler(mediaModel);
                          },
                          longPressHandler: () {
                            _longPressHandler(mediaModel);
                          },
                        );
                      case MediaType.audio:
                        return AudioMediaWidget(
                          mediaModel: mediaModel,
                          totalMediaCount: _localReportModel!.medias!.length,
                          isSelected: _selectedMediaRanks!.contains(mediaModel.rank),
                          isUploading: isUploading,
                          tapHandler: () {
                            _tapHandler(mediaModel);
                          },
                          longPressHandler: () {
                            _longPressHandler(mediaModel);
                          },
                        );
                      case MediaType.video:
                        return VideoMediaWidget(
                          mediaModel: mediaModel,
                          totalMediaCount: _localReportModel!.medias!.length,
                          isSelected: _selectedMediaRanks!.contains(mediaModel.rank),
                          isUploading: isUploading,
                          tapHandler: () {
                            _tapHandler(mediaModel);
                          },
                          longPressHandler: () {
                            _longPressHandler(mediaModel);
                          },
                        );
                      default:
                        return Container();
                    }
                  }),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _tapHandler(MediaModel? mediaModel) {
    if (!_selectStatus) return;
    if (_selectedMediaRanks!.contains(mediaModel!.rank)) {
      _selectedMediaRanks!.remove(mediaModel.rank);
    } else {
      _selectedMediaRanks!.add(mediaModel.rank!);
    }

    setState(() {});
  }

  void _longPressHandler(MediaModel? mediaModel) {
    _selectedMediaRanks!.add(mediaModel!.rank!);
    _selectStatus = true;
    setState(() {});
  }
}
