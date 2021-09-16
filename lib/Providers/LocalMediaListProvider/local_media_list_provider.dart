import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:legatus/ApiDataProviders/index.dart';
import 'package:legatus/Config/config.dart';
import 'package:legatus/Helpers/index.dart';
import 'package:legatus/Models/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'index.dart';

class LocalMediaListProvider extends ChangeNotifier {
  static LocalMediaListProvider of(BuildContext context,
          {bool listen = false}) =>
      Provider.of<LocalMediaListProvider>(context, listen: listen);

  LocalMediaListState _localMediaListState = LocalMediaListState.init();
  LocalMediaListState get localMediaListState => _localMediaListState;

  void setLocalMediaListState(LocalMediaListState localMediaListState,
      {bool isNotifiable = true}) {
    if (_localMediaListState != localMediaListState) {
      _localMediaListState = localMediaListState;
      if (isNotifiable) notifyListeners();
    }
  }

  Future<void> getLocalMediaList() async {
    if (_localMediaListState.localLocalReportModel!.medias!.length !=
        _localMediaListState.localLocalReportModel!.orderList!.length) {
      print("ssss");
      String createdAt = KeicyDateTime.convertDateStringToMilliseconds(
              dateString: _localMediaListState.localLocalReportModel!.createdAt)
          .toString();
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
        dateString:
            "${_localMediaListState.localLocalReportModel!.date} ${_localMediaListState.localLocalReportModel!.time}",
      )!;
      var result = await LocalReportApiProvider.update(
        localReportModel: _localMediaListState.localLocalReportModel,
        oldReportIdStr: "${reportDateTime}_$createdAt",
      );

      _localMediaListState =
          _localMediaListState.update(localLocalReportModel: result["data"]);
    }

    List<dynamic> localMediaListData = _localMediaListState.localMediaListData!;
    Map<String, dynamic> localMediaMetaData =
        _localMediaListState.localMediaMetaData!;

    try {
      int page = localMediaMetaData.isEmpty
          ? 0
          : (localMediaMetaData["nextPage"] ?? 0);
      int limit = AppConfig.refreshListLimit;
      // int limit = 5;

      for (var i = page * limit; i < (page + 1) * limit; i++) {
        if (i < _localMediaListState.localLocalReportModel!.orderList!.length) {
          int index = i;
          List<MediaModel> list = [];
          for (var k = 0;
              k <
                  _localMediaListState
                      .localLocalReportModel!.orderList![index]["ranks"].length;
              k++) {
            int rank = _localMediaListState
                .localLocalReportModel!.orderList![index]["ranks"][k];
            MediaModel mediaModel =
                _localMediaListState.localLocalReportModel!.medias![rank - 1];
            list.add(mediaModel);
          }
          localMediaListData.add(list);
        } else {
          break;
        }
      }

      _localMediaListState = _localMediaListState.update(
        progressState: 2,
        localMediaListData: localMediaListData,
        localMediaMetaData: {
          "total":
              _localMediaListState.localLocalReportModel!.orderList!.length,
          "page": page,
          "nextPage": page + 1,
          "isEnd": limit * (page + 1) >=
              _localMediaListState.localLocalReportModel!.orderList!.length,
        },
      );
    } catch (e) {
      _localMediaListState = _localMediaListState.update(
        progressState: 2,
      );
    }
    notifyListeners();
  }
}
