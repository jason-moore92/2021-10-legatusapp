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

class PlanningProvider extends ChangeNotifier {
  static PlanningProvider of(BuildContext context, {bool listen = false}) => Provider.of<PlanningProvider>(context, listen: listen);

  PlanningState _planningState = PlanningState.init();
  PlanningState get planningState => _planningState;

  SharedPreferences? _preferences;

  void setPlanningState(PlanningState planningState, {bool isNotifiable = true}) {
    if (_planningState != planningState) {
      _planningState = planningState;
      if (isNotifiable) notifyListeners();
    }
  }

  Future<void> getLocalReportList() async {
    try {
      var result;

      if (_preferences == null) _preferences = await SharedPreferences.getInstance();

      result = await PlanningApiProvider.getPlanning(startDate: _planningState.currentDate);

      if (result["success"]) {
        Map<String, dynamic> planningData = _planningState.planningData!;

        planningData[_planningState.currentDate!] = result["data"];

        _planningState = _planningState.update(
          progressState: 2,
          planningData: planningData,
        );

        await _preferences!.setString("planningData", json.encode(_planningState.planningData));
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
      var localData = _preferences!.getString("planningData");
      if (localData != null) {
        _planningState = _planningState.update(
          progressState: 2,
          planningData: json.decode(localData),
        );
      }
    }

    _planningState = _planningState.update(
      progressState: 2,
    );

    notifyListeners();
  }
}
