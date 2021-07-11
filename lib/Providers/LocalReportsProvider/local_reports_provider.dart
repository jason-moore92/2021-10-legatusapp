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

class LocalReportsProvider extends ChangeNotifier {
  static LocalReportsProvider of(BuildContext context, {bool listen = false}) => Provider.of<LocalReportsProvider>(context, listen: listen);

  LocalReportsState _localReportsState = LocalReportsState.init();
  LocalReportsState get localReportsState => _localReportsState;

  void setLocalReportsState(LocalReportsState localReportsState, {bool isNotifiable = true}) {
    if (_localReportsState != localReportsState) {
      _localReportsState = localReportsState;
      if (isNotifiable) notifyListeners();
    }
  }

  Future<void> getLocalReportList() async {
    Future.delayed(Duration(milliseconds: 500), () async {
      List<dynamic> localReportListData = _localReportsState.localReportListData!;
      Map<String, dynamic> localReportMetaData = _localReportsState.localReportMetaData!;
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

          _localReportsState = _localReportsState.update(
            progressState: 2,
            localReportListData: localReportListData,
            localReportMetaData: localReportMetaData,
          );
        } else {
          _localReportsState = _localReportsState.update(
            progressState: 2,
          );
        }
      } catch (e) {
        _localReportsState = _localReportsState.update(
          progressState: 2,
        );
      }
      notifyListeners();
    });
  }

  Future<void> createLocalReport({@required LocalReportModel? localReportModel}) async {
    try {
      var result = await LocalReportsDataProvider.create(localReportModel: localReportModel);

      if (result["success"]) {
        _localReportsState = _localReportsState.update(
          progressState: 2,
          message: "",
        );
      } else {
        _localReportsState = _localReportsState.update(
          progressState: -1,
          message: "Somgthing was wrong",
        );
      }
    } catch (e) {
      _localReportsState = _localReportsState.update(
        progressState: -1,
        message: e.toString(),
      );
    }

    notifyListeners();
  }

  Future<void> updateLocalReport({@required LocalReportModel? localReportModel, @required String? oldReportId}) async {
    try {
      var result = await LocalReportsDataProvider.update(localReportModel: localReportModel, oldReportId: oldReportId);

      if (result["success"]) {
        _localReportsState = _localReportsState.update(
          progressState: 2,
          message: "",
        );
      } else {
        _localReportsState = _localReportsState.update(
          progressState: -1,
          message: "Somgthing was wrong",
        );
      }
    } catch (e) {
      _localReportsState = _localReportsState.update(
        progressState: -1,
        message: e.toString(),
      );
    }

    notifyListeners();
  }

  Future<Map<String, dynamic>> deleteLocalReport({@required LocalReportModel? localReportModel}) async {
    var result = await LocalReportsDataProvider.delete(localReportModel: localReportModel);
    return result;
    try {
      var result = await LocalReportsDataProvider.delete(localReportModel: localReportModel);

      if (result["success"]) {
        _localReportsState = _localReportsState.update(
          progressState: 2,
          message: "",
        );
      } else {
        _localReportsState = _localReportsState.update(
          progressState: -1,
          message: "Somgthing was wrong",
        );
      }
    } catch (e) {
      _localReportsState = _localReportsState.update(
        progressState: -1,
        message: e.toString(),
      );
    }
    // notifyListeners();
  }
}
