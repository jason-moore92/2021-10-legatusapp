import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:legatus/Config/config.dart';
import 'package:legatus/Helpers/file_helpers.dart';
import 'package:legatus/Helpers/index.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Helpers/http_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class LocalReportApiProvider {
  static Box<LocalReportModel>? localReportsBox;
  static Box<List<dynamic>>? localReportIdsBox;
  static Box<dynamic>? appSettingsBox;

  static Future<void> initHiveObject() async {
    try {
      /// init local reports data
      if (localReportsBox == null) {
        localReportsBox = await Hive.openBox<LocalReportModel>("local_reports");
      }
      if (localReportIdsBox == null) {
        localReportIdsBox =
            await Hive.openBox<List<dynamic>>("local_report_ids");
      }
      if (appSettingsBox == null) {
        appSettingsBox = await Hive.openBox<dynamic>("app_settings");
      }
    } catch (e) {
      print(e);
    }
  }

  static void viewLocalReportData() {
    try {
      print("=======================================================");
      print("================ Local Report Data ====================");
      print("=======================================================");
      print(".");
      print(".");
      List<dynamic>? localReportIds =
          localReportIdsBox!.get("ids", defaultValue: []);

      print("==== Local Report Ids === ${localReportIds!.length} ====");
      print(localReportIds);
      print("=======================================================");
      print(".");
      print(".");

      List<LocalReportModel> localReportList = localReportsBox!.values.toList();
      print(
          "==== Local Report Ids === ${localReportsBox!.keys.toList().length} ====");
      print(localReportsBox!.keys.toList());
      print("=======================================================");
      print(".");
      print(".");

      for (var i = 0; i < localReportList.length; i++) {
        print(
            "================== local report data ===========================");
        print(localReportList[i].toJson());
        print("=======================================================");
        print(".");
        print(".");
      }
      print("=======================================================");
      print("=======================================================");
      print("=======================================================");
    } catch (e) {
      print(e);
    }
  }

  static Future<Map<String, dynamic>> create(
      {@required LocalReportModel? localReportModel}) async {
    try {
      await initHiveObject();

      int createAt = KeicyDateTime.convertDateStringToMilliseconds(
          dateString: localReportModel!.createdAt)!;
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
          dateString: "${localReportModel.date} ${localReportModel.time}")!;
      String reportIdStr = "${reportDateTime}_$createAt";

      /// store local report
      localReportsBox!.put(reportIdStr, localReportModel);

      /// update local reportsIds
      List<dynamic>? reportIds =
          localReportIdsBox!.get("ids", defaultValue: []);
      reportIds!.add(reportIdStr);
      reportIds.sort(sortReportIdHandler);
      localReportIdsBox!.put("ids", reportIds);

      viewLocalReportData();

      return {"success": true};
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> getLocalReportModel(
      {@required LocalReportModel? localReportModel}) async {
    try {
      await initHiveObject();

      int createAt = KeicyDateTime.convertDateStringToMilliseconds(
          dateString: localReportModel!.createdAt)!;
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
          dateString: "${localReportModel.date} ${localReportModel.time}")!;
      String reportIdStr = "${reportDateTime}_$createAt";

      LocalReportModel? newReport = localReportsBox!.get(reportIdStr);
      if (newReport != null) {
        return {
          "success": true,
          "data": newReport,
        };
      } else {
        return {"success": false};
      }
    } catch (e) {
      return {"success": false};
    }
  }

  static int sortReportIdHandler(dynamic a, dynamic b) {
    int aReportDateTime = int.parse(a.toString().split("_").first);
    int aCreateDateTime = int.parse(a.toString().split("_").last);

    int bReportDateTime = int.parse(b.toString().split("_").first);
    int bCreateDateTime = int.parse(b.toString().split("_").last);

    if (aReportDateTime > bReportDateTime) {
      return -1;
    } else if (aReportDateTime < bReportDateTime) {
      return 1;
    } else {
      if (aCreateDateTime >= bCreateDateTime) {
        return -1;
      } else {
        return 1;
      }
    }
  }

  static Future<Map<String, dynamic>> update({
    @required LocalReportModel? localReportModel,
    String? oldReportIdStr,
  }) async {
    try {
      await initHiveObject();

      List<dynamic>? orderList = [];

      if (localReportModel!.medias!.isNotEmpty) {
        for (var i = 0; i < localReportModel.medias!.length; i++) {
          MediaModel mediaModel = localReportModel.medias![i];
          if (mediaModel.rank != i + 1) {
            mediaModel.rank = i + 1;
            File oldFile = File(mediaModel.path!);
            String? newPath = await FileHelpers.getFilePath(
              mediaType: mediaModel.type,
              createAt: mediaModel.createdAt,
              rank: mediaModel.rank,
              fileType: mediaModel.path!.split('.').last,
            );
            if (newPath == null)
              return {
                "success": false,
                "message": "updated media file path is error",
              };

            await oldFile.copy(newPath);
            mediaModel.filename = newPath.split('/').last;
            mediaModel.path = newPath;
            try {
              await oldFile.delete();
            } catch (e) {
              print(e);
              return {
                "success": false,
                "message":
                    "when update local media, deleting old media file is failed.",
              };
            }
          } else {
            mediaModel.rank = i + 1;
          }

          if (orderList.isNotEmpty &&
              orderList.last["type"] == mediaModel.type &&
              mediaModel.type == MediaType.picture &&
              orderList.last["ranks"].length < 3) {
            orderList.last["ranks"].add(mediaModel.rank);
          } else {
            orderList.add({
              "type": mediaModel.type,
              "ranks": [mediaModel.rank],
            });
          }
          localReportModel.medias![i] = mediaModel;
        }

        localReportModel.orderList = orderList;
      }

      ///
      int createAt = KeicyDateTime.convertDateStringToMilliseconds(
          dateString: localReportModel.createdAt)!;
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
          dateString: "${localReportModel.date} ${localReportModel.time}")!;
      String reportIdStr = "${reportDateTime}_$createAt";

      /// if updated local report, delete old local report;
      if (oldReportIdStr != null && oldReportIdStr != reportIdStr) {
        localReportsBox!.delete(oldReportIdStr);
        viewLocalReportData();
      }

      /// update local report;
      localReportsBox!.put(reportIdStr, localReportModel);

      /// update local reportIds
      List<dynamic>? reportIds =
          localReportIdsBox!.get("ids", defaultValue: []);
      reportIds!.remove(oldReportIdStr);
      reportIds.add(reportIdStr);
      reportIds.sort(sortReportIdHandler);
      localReportIdsBox!.put("ids", reportIds);

      viewLocalReportData();

      return {"success": true, "data": localReportModel};
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<LocalReportModel?> getLocalReportModelByReportId(
      {int? reportId}) async {
    try {
      await initHiveObject();

      List<dynamic>? reportIds =
          localReportIdsBox!.get("ids", defaultValue: []);

      for (var i = 0; i < reportIds!.length; i++) {
        String reportIdStr = reportIds[i];
        LocalReportModel? localReportModel = localReportsBox!.get(reportIdStr);

        if (localReportModel == null) {
          continue;
        }
        if (localReportModel.reportId == reportId) {
          return localReportModel;
        }
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<Map<String, dynamic>> getLocalReportList(
      {@required int? limit, int page = 0}) async {
    try {
      await initHiveObject();

      List<dynamic>? reportIds =
          localReportIdsBox!.get("ids", defaultValue: []);
      List<LocalReportModel> reportModelList = [];

      for (var i = page * limit!; i < (page + 1) * limit; i++) {
        if (i < reportIds!.length) {
          String reportIdStr = reportIds[i];
          LocalReportModel? localReportModel =
              localReportsBox!.get(reportIdStr);

          if (localReportModel != null) {
            /// check if deleted medias are exist?
            List<MediaModel> medias = [];
            for (var i = 0; i < localReportModel.medias!.length; i++) {
              File file = File(localReportModel.medias![i].path!);
              if (await file.exists()) {
                medias.add(localReportModel.medias![i]);
              }
            }
            if (localReportModel.medias!.length != medias.length) {
              localReportModel.medias = medias;
              var result = await update(localReportModel: localReportModel);
              if (result["success"]) {
                localReportModel = result["data"];
              }
            }

            reportModelList.add(localReportModel!);
          } else {
            print(localReportModel);
          }
        } else {
          break;
        }
      }

      return {
        "success": true,
        "data": {
          "docs": reportModelList,
          "total": reportModelList.length,
          "page": page,
          "nextPage": page + 1,
          "isEnd": limit * (page + 1) >= reportIds!.length,
        },
      };
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> getALL() async {
    try {
      await initHiveObject();

      List<dynamic>? reportIds =
          localReportIdsBox!.get("ids", defaultValue: []);
      List<LocalReportModel> reportModelList = [];

      for (var i = 0; i < reportIds!.length; i++) {
        String reportIdStr = reportIds[i];
        LocalReportModel? localReportModel = localReportsBox!.get(reportIdStr);

        if (localReportModel != null) {
          /// check if deleted medias are exist?
          List<MediaModel> medias = [];
          for (var i = 0; i < localReportModel.medias!.length; i++) {
            File file = File(localReportModel.medias![i].path!);
            if (await file.exists()) {
              medias.add(localReportModel.medias![i]);
            }
          }
          if (localReportModel.medias!.length != medias.length) {
            localReportModel.medias = medias;
            var result = await update(localReportModel: localReportModel);
            if (result["success"]) {
              localReportModel = result["data"];
            }
          }

          reportModelList.add(localReportModel!);
        } else {
          print(reportIdStr);
        }
      }

      return {
        "success": true,
        "data": reportModelList,
      };
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> delete(
      {@required LocalReportModel? localReportModel}) async {
    try {
      await initHiveObject();

      ///
      int createAt = KeicyDateTime.convertDateStringToMilliseconds(
          dateString: localReportModel!.createdAt)!;
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
          dateString: "${localReportModel.date} ${localReportModel.time}")!;
      String reportIdStr = "${reportDateTime}_$createAt";

      ///
      localReportsBox!.delete(reportIdStr);

      ///
      List<dynamic>? reportIds =
          localReportIdsBox!.get("ids", defaultValue: []);
      reportIds!.remove(reportIdStr);
      reportIds.sort(sortReportIdHandler);
      localReportIdsBox!.put("ids", reportIds);

      viewLocalReportData();

      return {"success": true};
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> storeReport(
      {@required LocalReportModel? localReportModel}) async {
    String apiUrl = '/store-report';

    try {
      await initHiveObject();

      dynamic modeValue = appSettingsBox!.get("develop_mode");
      String url;

      if (modeValue == "40251764") {
        url = AppConfig.testApiBaseUrl + apiUrl;
      } else {
        url = AppConfig.productionApiBaseUrl + apiUrl;
      }

      var data = localReportModel!.toJson();
      if (data["report_id"] == -1 || data["report_id"] == 0)
        data["report_id"] = null;
      data.remove("orderList");

      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({"local_report": data}),
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
      print(e);
      return {
        "success": false,
        "message": "Something went wrong",
        "statusCode": 500,
      };
    }
  }
}
