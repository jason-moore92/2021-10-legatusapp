import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:legutus/ApiDataProviders/index.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Models/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'index.dart';

class LocalMediaListProvider extends ChangeNotifier {
  static LocalMediaListProvider of(BuildContext context, {bool listen = false}) => Provider.of<LocalMediaListProvider>(context, listen: listen);

  LocalMediaListState _localMediaListState = LocalMediaListState.init();
  LocalMediaListState get localMediaListState => _localMediaListState;

  void setLocalMediaListState(LocalMediaListState localMediaListState, {bool isNotifiable = true}) {
    if (_localMediaListState != localMediaListState) {
      _localMediaListState = localMediaListState;
      if (isNotifiable) notifyListeners();
    }
  }

  Future<void> getLocalMediaList() async {
    Future.delayed(Duration(milliseconds: 500), () async {
      List<dynamic> localMediaListData = _localMediaListState.localMediaListData!;
      Map<String, dynamic> localMediaMetaData = _localMediaListState.localMediaMetaData!;
      try {
        int page = localMediaMetaData.isEmpty ? 0 : (localMediaMetaData["nextPage"] ?? 0);
        int limit = AppConfig.refreshListLimit;
        // int limit = 5;

        for (var i = page * limit; i < (page + 1) * limit; i++) {
          if (i < _localMediaListState.localLocalReportModel!.orderList!.length) {
            int index = i;
            List<MediaModel> list = [];
            for (var k = 0; k < _localMediaListState.localLocalReportModel!.orderList![index]["ranks"].length; k++) {
              int rank = _localMediaListState.localLocalReportModel!.orderList![index]["ranks"][k];
              list.add(_localMediaListState.localLocalReportModel!.medias![rank - 1]);
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
            "total": _localMediaListState.localLocalReportModel!.orderList!.length,
            "page": page,
            "nextPage": page + 1,
            "isEnd": limit * (page + 1) >= _localMediaListState.localLocalReportModel!.orderList!.length,
          },
        );
      } catch (e) {
        _localMediaListState = _localMediaListState.update(
          progressState: 2,
        );
      }
      notifyListeners();
    });
  }
}
