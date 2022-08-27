// import 'dart:convert';
// import 'dart:io';

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:legatus/ApiDataProviders/index.dart';
// import 'package:legatus/Config/config.dart';
// import 'package:legatus/Models/index.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'index.dart';

class PlanningProvider extends ChangeNotifier {
  static PlanningProvider of(BuildContext context, {bool listen = false}) => Provider.of<PlanningProvider>(context, listen: listen);

  PlanningState _planningState = PlanningState.init();
  PlanningState get planningState => _planningState;

  Box<dynamic>? _planningDataBox;
  Box<dynamic>? get planningDataBox => _planningDataBox;

  void setPlanningState(PlanningState planningState, {bool isNotifiable = true}) {
    if (_planningState != planningState) {
      _planningState = planningState;
      if (isNotifiable) notifyListeners();
    }
  }

  Future<void> initHiveObject() async {
    try {
      _planningDataBox ??= await Hive.openBox<dynamic>("planningData");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> getPlanningList() async {
    try {
      Map<String, dynamic> result;
      await initHiveObject();

      result = await PlanningApiProvider.getPlanning(startDate: _planningState.currentDate);

      if (result["success"]) {
        Map<String, dynamic> planningData = _planningState.planningData!;

        planningData[_planningState.currentDate!] = result["data"];

        _planningState = _planningState.update(
          progressState: 2,
          planningData: planningData,
        );

        _planningDataBox!.put("planningData", _planningState.planningData);
        var test = _planningDataBox!.get("planningData");

        if (kDebugMode) {
          print(test);
        }
      } else {
        _planningState = _planningState.update(
          progressState: -1,
        );
      }
    } catch (e) {
      _planningState = _planningState.update(
        progressState: -1,
      );
    }

    if (_planningState.progressState == -1) {
      var localData = _planningDataBox!.get("planningData");
      if (localData != null) {
        _planningState = _planningState.update(
          progressState: 2,
          planningData: json.decode(json.encode(localData)),
        );
      }
    }

    _planningState = _planningState.update(
      progressState: 2,
    );

    notifyListeners();
  }
}
