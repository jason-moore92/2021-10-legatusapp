import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legutus/Config/config.dart';
import 'package:legutus/Helpers/file_helpers.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:localstorage/localstorage.dart';
import 'package:legutus/Helpers/http_plus.dart';

class LocalReportApiProvider {
  static final LocalStorage storage = LocalStorage("local_reports");

  static Future<Map<String, dynamic>> create({@required LocalReportModel? localReportModel}) async {
    try {
      await storage.ready;
      int createAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: localReportModel!.createdAt)!;
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(dateString: "${localReportModel.date} ${localReportModel.time}")!;
      String reportId = "${reportDateTime}_$createAt";

      ///
      await storage.setItem(reportId, localReportModel.toJson());

      ///
      List<dynamic> reportIds = storage.getItem("local_report_ids") ?? [];
      reportIds.add(reportId);
      reportIds.sort(sortReportIdHandler);
      await storage.setItem("local_report_ids", reportIds);

      return {"success": true};
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> getLocalReportModel({@required LocalReportModel? localReportModel}) async {
    try {
      await storage.ready;
      int createAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: localReportModel!.createdAt)!;
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(dateString: "${localReportModel.date} ${localReportModel.time}")!;
      String reportId = "${reportDateTime}_$createAt";

      var result = storage.getItem(reportId);
      if (result != null) {
        return {
          "success": true,
          "data": LocalReportModel.fromJson(result),
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
    String? oldReportId,
  }) async {
    try {
      await storage.ready;

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
            if (newPath == null) return {"success": false};

            File newFile = await oldFile.copy(newPath);
            mediaModel.filename = newPath.split('/').last;
            mediaModel.path = newPath;
            try {
              await oldFile.delete();
            } catch (e) {
              print(e);
              return {"success": false};
            }
          } else {
            mediaModel.rank = i + 1;
          }

          if (orderList.isNotEmpty && orderList.last["type"] == mediaModel.type && mediaModel.type == MediaType.picture) {
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
      int createAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: localReportModel.createdAt)!;
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(dateString: "${localReportModel.date} ${localReportModel.time}")!;
      String reportId = "${reportDateTime}_$createAt";

      ///
      if (oldReportId != null && oldReportId != reportId) await storage.deleteItem(oldReportId);
      await storage.setItem(reportId, localReportModel.toJson());

      ///
      List<dynamic> reportIds = storage.getItem("local_report_ids") ?? [];
      reportIds.remove(oldReportId);
      reportIds.add(reportId);
      reportIds.sort(sortReportIdHandler);
      await storage.setItem("local_report_ids", reportIds);

      return {"success": true, "data": localReportModel};
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<LocalReportModel> getLocalReportModelByReportId({int? reportId}) async {
    List<dynamic> reportIds = storage.getItem("local_report_ids") ?? [];

    for (var i = 0; i < reportIds.length; i++) {
      String reportIdString = reportIds[i];
      LocalReportModel localReportModel = LocalReportModel.fromJson(storage.getItem(reportIdString));
      if (localReportModel.reportId == reportId) {
        return localReportModel;
      }
    }

    return LocalReportModel();
  }

  static Future<Map<String, dynamic>> getLocalReportList({@required int? limit, int page = 0}) async {
    try {
      await storage.ready;
      List<dynamic> reportIds = storage.getItem("local_report_ids") ?? [];
      List<LocalReportModel> reportModelList = [];
      for (var i = page * limit!; i < (page + 1) * limit; i++) {
        if (i < reportIds.length) {
          String reportId = reportIds[i];

          if (storage.getItem(reportId) != null) {
            LocalReportModel localReportModel = LocalReportModel.fromJson(storage.getItem(reportId));
            reportModelList.add(localReportModel);
          } else {
            print(reportId);
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
          "isEnd": limit * (page + 1) >= reportIds.length,
        },
      };
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> getALL() async {
    try {
      await storage.ready;
      List<dynamic> reportIds = storage.getItem("local_report_ids") ?? [];
      List<LocalReportModel> reportModelList = [];
      for (var i = 0; i < reportIds.length; i++) {
        String reportId = reportIds[i];
        if (storage.getItem(reportId) != null) {
          LocalReportModel localReportModel = LocalReportModel.fromJson(storage.getItem(reportId));
          reportModelList.add(localReportModel);
        } else {
          print(reportId);
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

  static Future<Map<String, dynamic>> delete({@required LocalReportModel? localReportModel}) async {
    try {
      await storage.ready;

      ///
      int createAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: localReportModel!.createdAt)!;
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(dateString: "${localReportModel.date} ${localReportModel.time}")!;
      String reportId = "${reportDateTime}_$createAt";

      ///
      await storage.deleteItem(reportId);

      ///
      List<dynamic> reportIds = storage.getItem("local_report_ids") ?? [];
      reportIds.remove(reportId);
      reportIds.sort(sortReportIdHandler);
      await storage.setItem("local_report_ids", reportIds);

      return {"success": true};
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> storeReport({@required LocalReportModel? localReportModel}) async {
    String apiUrl = '/store-report';

    try {
      String url = AppConfig.apiBaseUrl + apiUrl;

      var data = localReportModel!.toJson();
      if (data["report_id"] == -1 || data["report_id"] == 0) data["report_id"] = null;
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
