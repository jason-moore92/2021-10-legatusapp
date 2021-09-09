import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Helpers/date_time_convert.dart';
import 'package:legutus/Helpers/http_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanningApiProvider {
  static Box<dynamic>? appSettingsBox;

  static Future<void> initHiveObject() async {
    try {
      if (appSettingsBox == null) {
        appSettingsBox = await Hive.openBox<dynamic>("app_settings");
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<Map<String, dynamic>> getPlanning({@required String? startDate}) async {
    String apiUrl = '/planning';

    try {
      await initHiveObject();

      dynamic modeValue = appSettingsBox!.get("develop_mode");
      String url;

      if (modeValue == "40251764") {
        url = AppConfig.testApiBaseUrl + apiUrl;
      } else {
        url = AppConfig.productionApiBaseUrl + apiUrl;
      }

      startDate = startDate ?? KeicyDateTime.convertDateTimeToDateString(dateTime: DateTime.now());
      url += "?start_date=$startDate";

      var response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
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
    } on PlatformException catch (e) {
      return {
        "success": false,
        "message": "Something went wrong",
        "statusCode": 500,
      };
    } catch (e) {
      print(e);
      return {
        "success": false,
        "message": "Something went wrong",
        "statusCode": 500,
      };
    }
  }
}
