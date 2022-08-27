import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:legatus/Config/config.dart';
import 'package:legatus/Helpers/http_plus.dart';
import 'package:legatus/Models/index.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as httpold;

class LocalMediaApiProvider {
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

  static Future<Map<String, dynamic>> uploadMedia({@required MediaModel? mediaModel}) async {
    String apiUrl = '/upload-media';

    try {
      await initHiveObject();

      dynamic modeValue = appSettingsBox!.get("develop_mode");
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

  static Future<Map<String, dynamic>> uploadPresignedUrl({@required File? file, @required String? presignedUrl}) async {
    try {
      Uint8List imageByteData = await file!.readAsBytes();
      var response = await httpold.put(
        Uri.parse(presignedUrl!),
        headers: {
          "Connection": "Keep-Alive",
          "Keep-Alive": "timeout=1, max=1000",
        },
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
