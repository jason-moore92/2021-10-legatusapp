import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Helpers/http_plus.dart';
import 'package:legutus/Models/index.dart';
import 'package:http/http.dart' as httpOld;

class LocalMediaApiProvider {
  static Future<Map<String, dynamic>> uploadMedia({@required MediaModel? mediaModel}) async {
    String apiUrl = '/upload-media';

    try {
      String url = AppConfig.apiBaseUrl + apiUrl;
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

  static Future<Map<String, dynamic>> uploadPresignedUrl({@required String? presignedUrl}) async {
    try {
      var response = await httpOld.put(
        Uri.parse(presignedUrl!),
        headers: {
          'Content-Type': 'application/octet-stream',
        },
      );
      if (response.statusCode == 200) {
        return {
          "success": true,
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
