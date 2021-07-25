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

class LocalReportListProvider extends ChangeNotifier {
  static LocalReportListProvider of(BuildContext context, {bool listen = false}) => Provider.of<LocalReportListProvider>(context, listen: listen);

  LocalReportListState _localReportListState = LocalReportListState.init();
  LocalReportListState get localReportListState => _localReportListState;

  void setLocalReportListState(LocalReportListState localReportListState, {bool isNotifiable = true}) {
    if (_localReportListState != localReportListState) {
      _localReportListState = localReportListState;
      if (isNotifiable) notifyListeners();
    }
  }

  Future<void> getLocalReportList() async {
    Future.delayed(Duration(milliseconds: 500), () async {
      List<dynamic> localReportListData = _localReportListState.localReportListData!;
      Map<String, dynamic> localReportMetaData = _localReportListState.localReportMetaData!;
      try {
        var result;

        result = await LocalReportsDataProvider.getLocalReportList(
          page: localReportMetaData.isEmpty ? 0 : (localReportMetaData["nextPage"] ?? 0),
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
    });
  }

  Future<int> createLocalReport({@required LocalReportModel? localReportModel}) async {
    try {
      var result = await LocalReportsDataProvider.create(localReportModel: localReportModel);

      if (result["success"]) {
        _localReportListState = _localReportListState.update(
          progressState: 2,
          message: "",
        );
      } else {
        _localReportListState = _localReportListState.update(
          progressState: -1,
          message: "Somgthing was wrong",
        );
      }
    } catch (e) {
      _localReportListState = _localReportListState.update(
        progressState: -1,
        message: e.toString(),
      );
    }

    notifyListeners();
    return _localReportListState.progressState!;
  }

  Future<int> updateLocalReport({@required LocalReportModel? localReportModel, @required String? oldReportId}) async {
    try {
      var result = await LocalReportsDataProvider.update(localReportModel: localReportModel, oldReportId: oldReportId);

      if (result["success"]) {
        _localReportListState = _localReportListState.update(
          progressState: 2,
          message: "",
        );
      } else {
        _localReportListState = _localReportListState.update(
          progressState: -1,
          message: "Somgthing was wrong",
        );
      }
    } catch (e) {
      _localReportListState = _localReportListState.update(
        progressState: -1,
        message: e.toString(),
      );
    }

    notifyListeners();
    return _localReportListState.progressState!;
  }

  Future<int> deleteLocalReport({@required LocalReportModel? localReportModel}) async {
    try {
      var result = await LocalReportsDataProvider.delete(localReportModel: localReportModel);

      for (var i = 0; i < localReportModel!.medias!.length; i++) {
        File file = File(localReportModel.medias![i].path!);
        try {
          file.deleteSync();
        } catch (e) {
          print(e);
        }
      }

      if (result["success"]) {
        _localReportListState = _localReportListState.update(
          progressState: 2,
          message: "",
        );
      } else {
        _localReportListState = _localReportListState.update(
          progressState: -1,
          message: "Somgthing was wrong",
        );
      }
    } catch (e) {
      _localReportListState = _localReportListState.update(
        progressState: -1,
        message: e.toString(),
      );
    }
    notifyListeners();

    return _localReportListState.progressState!;
  }
}
