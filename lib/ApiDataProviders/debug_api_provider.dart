import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:legatus/Config/config.dart';
import 'package:legatus/Helpers/http_plus.dart';
import 'package:legatus/Models/index.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class DebugApiProvider {
  static Box<dynamic>? appSettingsBox;

  static Future<void> initHiveObject() async {
    try {
      appSettingsBox ??= await Hive.openBox<dynamic>("app_settings");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static Future<Map<String, dynamic>> debugReport({
    @required List<dynamic>? planningData,
    @required List<dynamic>? localReports,
    @required UserModel? userModel,
    @required SettingsModel? settingsModel,
  }) async {
    String apiUrl = '/debug';

    try {
      await initHiveObject();

      dynamic modeValue = appSettingsBox!.get("develop_mode");
      String url;

      if (modeValue == "40251764") {
        url = AppConfig.testApiBaseUrl + apiUrl;
      } else {
        url = AppConfig.productionApiBaseUrl + apiUrl;
      }

      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "planning": planningData,
          "user": userModel!.toJson(),
          "settings": settingsModel!.toJson(),
          "local_reports": localReports,
        }),
      );
      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": json.decode(response.body),
          "statusCode": response.statusCode,
        };
      } else {
        return {
          "success": false,
          "data": json.decode(response.body),
          "statusCode": response.statusCode,
        };
      }
    } on SocketException catch (e) {
      return {
        "success": false,
        "message": "Something went wrong",
        "statusCode": e.osError!.errorCode,
      };
    } on PlatformException catch (_) {
      return {
        "success": false,
        "message": "Something went wrong",
        "statusCode": 500,
      };
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return {
        "success": false,
        "message": "Something went wrong",
        "statusCode": 500,
      };
    }
  }
}
