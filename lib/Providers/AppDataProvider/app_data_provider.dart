import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:legatus/Models/index.dart';
import 'package:provider/provider.dart';
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

  Box<dynamic>? _appSettingsBox;
  Box<dynamic>? get appSettingsBox => _appSettingsBox;

  Future<void> initHiveObject() async {
    try {
      if (_appSettingsBox == null) {
        _appSettingsBox = await Hive.openBox<dynamic>("app_settings");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> init() async {
    try {
      await initHiveObject();

      dynamic result = _appSettingsBox!.get("settings");

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
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic>? androidInfoJoson;
      Map<String, dynamic>? iosInfoJoson;
      if (Platform.isAndroid) {
        AndroidDeviceInfo? androidInfo;
        androidInfo = await deviceInfo.androidInfo;
        androidInfoJoson = {
          "androidId": androidInfo.androidId,
          "board": androidInfo.board,
          "bootloader": androidInfo.bootloader,
          "brand": androidInfo.brand,
          "device": androidInfo.device,
          "display": androidInfo.display,
          "fingerprint": androidInfo.fingerprint,
          "hardware": androidInfo.hardware,
          "host": androidInfo.host,
          "id": androidInfo.id,
          "isPhysicalDevice": androidInfo.isPhysicalDevice,
          "manufacturer": androidInfo.manufacturer,
          "model": androidInfo.model,
          "product": androidInfo.product,
          "systemFeatures": androidInfo.systemFeatures,
          "tags": androidInfo.tags,
          "type": androidInfo.type,
          "version": androidInfo.version.codename,
        };
      } else if (Platform.isIOS) {
        IosDeviceInfo? iosInfo;
        iosInfo = await deviceInfo.iosInfo;
        iosInfoJoson = {
          "identifierForVendor": iosInfo.identifierForVendor,
          "isPhysicalDevice": iosInfo.isPhysicalDevice,
          "localizedModel": iosInfo.localizedModel,
          "model": iosInfo.model,
          "name": iosInfo.name,
          "systemName": iosInfo.systemName,
          "systemVersion": iosInfo.systemVersion,
          "utsname": {
            "machine": iosInfo.utsname.machine,
            "nodename": iosInfo.utsname.nodename,
            "release": iosInfo.utsname.release,
            "sysname": iosInfo.utsname.sysname,
            "version": iosInfo.utsname.version
          },
        };
      }
      _appDataState = _appDataState.update(
        progressState: 2,
        message: "",
        androidInfo: androidInfoJoson,
        iosInfo: iosInfoJoson,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> settingsHandler({
    // bool? allowCamera,
    // bool? allowLocation,
    // bool? allowMicrophone,
    bool? withRestriction,
    int? photoResolution,
    int? videoResolution,
    bool isNotifiable = true,
  }) async {
    await initHiveObject();

    SettingsModel settingsModel = SettingsModel.copy(_appDataState.settingsModel!);

    // if (allowCamera != null) settingsModel.allowCamera = allowCamera;
    // if (allowLocation != null) settingsModel.allowLocation = allowLocation;
    // if (allowMicrophone != null) settingsModel.allowMicrophone = allowMicrophone;
    // if (withRestriction != null) settingsModel.withRestriction = withRestriction;
    if (photoResolution != null) settingsModel.photoResolution = photoResolution;
    if (videoResolution != null) settingsModel.videoResolution = videoResolution;

    _appSettingsBox!.put("settings", settingsModel);

    var result = _appSettingsBox!.get("settings");

    print(result);

    _appDataState = _appDataState.update(
      settingsModel: settingsModel,
    );

    if (isNotifiable) notifyListeners();
  }
}
