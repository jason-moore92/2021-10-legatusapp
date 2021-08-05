import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Helpers/http_plus.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Models/local_report_model.dart';

class DebugApiProvider {
  static Future<Map<String, dynamic>> debugReport({
    @required List<dynamic>? planningData,
    @required List<dynamic>? localReports,
    @required UserModel? userModel,
    @required SettingsModel? settingsModel,
  }) async {
    String apiUrl = '/debug';

    try {
      String url = AppConfig.apiBaseUrl + apiUrl;

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
