import 'dart:io';

import 'package:flutter/material.dart';
import 'package:legatus/ApiDataProviders/index.dart';
import 'package:legatus/Config/config.dart';
import 'package:legatus/Models/index.dart';
import 'package:provider/provider.dart';
import 'index.dart';

class LocalReportListProvider extends ChangeNotifier {
  static LocalReportListProvider of(BuildContext context,
          {bool listen = false}) =>
      Provider.of<LocalReportListProvider>(context, listen: listen);

  LocalReportListState _localReportListState = LocalReportListState.init();
  LocalReportListState get localReportListState => _localReportListState;

  void setLocalReportListState(LocalReportListState localReportListState,
      {bool isNotifiable = true}) {
    if (_localReportListState != localReportListState) {
      _localReportListState = localReportListState;
      if (isNotifiable) notifyListeners();
    }
  }

  Future<void> getLocalReportList() async {
    List<dynamic> localReportListData =
        _localReportListState.localReportListData!;
    Map<String, dynamic> localReportMetaData =
        _localReportListState.localReportMetaData!;
    try {
      var result;

      result = await LocalReportApiProvider.getLocalReportList(
        page: localReportMetaData.isEmpty
            ? 0
            : (localReportMetaData["nextPage"] ?? 0),
        limit: AppConfig.refreshListLimit,
      );

      if (result["success"]) {
        for (var i = 0; i < result["data"]["docs"].length; i++) {
          localReportListData.add(result["data"]["docs"][i]);
        }
        result["data"].remove("docs");
        localReportMetaData = result["data"];

        _localReportListState = _localReportListState.update(
          progressState: 2,
          localReportListData: localReportListData,
          localReportMetaData: localReportMetaData,
        );
      } else {
        _localReportListState = _localReportListState.update(
          progressState: 2,
        );
      }
    } catch (e) {
      _localReportListState = _localReportListState.update(
        progressState: 2,
      );
    }
    notifyListeners();
  }
}
