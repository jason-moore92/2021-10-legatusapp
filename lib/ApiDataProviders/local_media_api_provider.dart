import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Helpers/http_plus.dart';
import 'package:legutus/Models/index.dart';
import 'package:http/http.dart' as httpOld;
import 'package:shared_preferences/shared_preferences.dart';

class LocalMediaApiProvider {
  static Future<Map<String, dynamic>> uploadMedia({@required MediaModel? mediaModel}) async {
    String apiUrl = '/upload-media';

    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      String? modeValue = _prefs.getString("develop_mode");
      String url;

      if (modeValue == "40251764") {
        url = AppConfig.testApiBaseUrl + apiUrl;
      } else {
        url = AppConfig.productionApiBaseUrl + apiUrl;
      }

      var data = mediaModel!.toJson();
      if (data["report_id"] == -1) data["report_id"] = null;

      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({"media": data}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
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

  static Future<Map<String, dynamic>> uploadPresignedUrl({@required File? file, @required String? presignedUrl}) async {
    try {
      Uint8List imageByteData = await file!.readAsBytes();
      var response = await httpOld.put(
        Uri.parse(presignedUrl!),
        body: imageByteData,
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
        };
      } else {
        return {
          "success": false,
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
