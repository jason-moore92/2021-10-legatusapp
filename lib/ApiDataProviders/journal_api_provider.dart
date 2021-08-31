import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Helpers/http_plus.dart';
import 'package:legutus/Models/local_report_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalApiProvider {
  static Future<Map<String, dynamic>> sendJournal({@required String? email, @required LocalReportModel? localMediaModel}) async {
    String apiUrl = '/send-journal';

    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      String? modeValue = _prefs.getString("develop_mode");
      String url;

      if (modeValue == "40251764") {
        url = AppConfig.testApiBaseUrl + apiUrl;
      } else {
        url = AppConfig.productionApiBaseUrl + apiUrl;
      }

      var data = localMediaModel!.toJson();
      print(data);

      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({"email": email, "local_report": localMediaModel.toJson()}),
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
