import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legutus/Config/config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginApiProvider {
  static Future<Map<String, dynamic>> getSMSCode({@required String? email, @required String? phoneNumber}) async {
    String apiUrl = '/get-sms-code';

    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      String? modeValue = _prefs.getString("develop_mode");
      String url;

      if (modeValue == "40251764") {
        url = AppConfig.testApiBaseUrl + apiUrl;
      } else {
        url = AppConfig.productionApiBaseUrl + apiUrl;
      }

      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.fields.addAll({"email": email ?? "", "mobile_phone_number": phoneNumber ?? ""});

      var response = await request.send();
      var result = await response.stream.bytesToString();

      Map<String, dynamic> jsonResult = json.decode(result);
      jsonResult["success"] = response.statusCode == 200;
      jsonResult["statusCode"] = response.statusCode;

      return jsonResult;
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

  static Future<Map<String, dynamic>> login({@required String? email, @required String? password}) async {
    String apiUrl = '/login-with-password';

    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      String? modeValue = _prefs.getString("develop_mode");
      String url;

      if (modeValue == "40251764") {
        url = AppConfig.testApiBaseUrl + apiUrl;
      } else {
        url = AppConfig.productionApiBaseUrl + apiUrl;
      }

      var request = http.MultipartRequest("POST", Uri.parse(url));
      request.fields.addAll({"email": email!, "password": password!});

      var response = await request.send();
      var result = await response.stream.bytesToString();

      Map<String, dynamic> jsonResult = json.decode(result);
      jsonResult["success"] = response.statusCode == 200;
      jsonResult["statusCode"] = response.statusCode;

      return jsonResult;
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
