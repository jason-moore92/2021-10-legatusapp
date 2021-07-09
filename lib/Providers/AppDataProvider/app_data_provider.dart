import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:legutus/ApiDataProviders/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'index.dart';

class AppDataProvider extends ChangeNotifier {
  static AppDataProvider of(BuildContext context, {bool listen = false}) => Provider.of<AppDataProvider>(context, listen: listen);

  AppDataState _appDataState = AppDataState.init();
  AppDataState get appDataState => _appDataState;

  void setAppDataState(AppDataState appDataState, {bool isNotifiable = true}) {
    if (_appDataState != appDataState) {
      _appDataState = appDataState;
      if (isNotifiable) notifyListeners();
    }
  }

  SharedPreferences? _prefs;
  SharedPreferences? get prefs => _prefs;

  Future<void> init() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();

      _prefs = await SharedPreferences.getInstance();
      String? result = _prefs!.getString("settings");
      if (result != null && result != "null") {
        _appDataState = _appDataState.update(
          progressState: 2,
          message: "",
          settingsModel: SettingsModel.fromJson(json.decode(result)),
        );
      } else {
        _appDataState = _appDataState.update(
          progressState: 2,
          message: "",
          settingsModel: SettingsModel(),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> settingsHandler({
    bool? allowCamera,
    bool? allowLocation,
    bool? allowMicrophone,
    bool? withRestriction,
    bool isNotifiable = true,
  }) async {
    SettingsModel settingsModel = SettingsModel.copy(_appDataState.settingsModel!);

    if (allowCamera != null) settingsModel.allowCamera = allowCamera;
    if (allowLocation != null) settingsModel.allowLocation = allowLocation;
    if (allowMicrophone != null) settingsModel.allowMicrophone = allowMicrophone;
    if (withRestriction != null) settingsModel.withRestriction = withRestriction;

    if (_prefs == null) _prefs = await SharedPreferences.getInstance();

    await _prefs!.setString("settings", json.encode(settingsModel.toJson()));

    _appDataState = _appDataState.update(
      settingsModel: settingsModel,
    );

    if (isNotifiable) notifyListeners();
  }
}
