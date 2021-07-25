import 'dart:io';

import 'package:flutter/material.dart';
import 'package:legutus/Helpers/file_helpers.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class LocalReportsDataProvider {
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
      reportIds.sort(sortHandler);
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

  static int sortHandler(dynamic a, dynamic b) {
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
    @required String? oldReportId,
  }) async {
    try {
      await storage.ready;

      List<dynamic>? orderList = [];

      if (localReportModel!.medias!.isNotEmpty) {
        for (var i = 0; i < localReportModel.medias!.length; i++) {
          MediaModel mediaModel = localReportModel.medias![localReportModel.medias!.length - 1 - i];
          if (mediaModel.rank != localReportModel.medias!.length - i) {
            mediaModel.rank = localReportModel.medias!.length - i;
            File oldFile = File(mediaModel.path!);
            String newPath = await FileHelpers.getFilePath(
              mediaType: mediaModel.type,
              createAt: mediaModel.createdAt,
              rank: mediaModel.rank,
              fileType: mediaModel.path!.split('.').last,
            );
            File newFile = await oldFile.copy(newPath);
            mediaModel.path = newPath;
            try {
              oldFile.deleteSync();
            } catch (e) {
              print(e);
            }
          } else {
            mediaModel.rank = localReportModel.medias!.length - i;
          }

          if (orderList.isNotEmpty && orderList.last["type"] == mediaModel.type && mediaModel.type == MediaType.picture) {
            orderList.last["ranks"].add(mediaModel.rank);
          } else {
            orderList.add({
              "type": mediaModel.type,
              "ranks": [mediaModel.rank],
            });
          }
        }

        localReportModel.orderList = orderList;
      }

      ///
      int createAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: localReportModel.createdAt)!;
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(dateString: "${localReportModel.date} ${localReportModel.time}")!;
      String reportId = "${reportDateTime}_$createAt";

      ///
      if (oldReportId != reportId) await storage.deleteItem(oldReportId!);
      await storage.setItem(reportId, localReportModel.toJson());

      ///
      List<dynamic> reportIds = storage.getItem("local_report_ids") ?? [];
      reportIds.remove(oldReportId);
      reportIds.add(reportId);
      reportIds.sort(sortHandler);
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

  static Future<Map<String, dynamic>> getLocalMediaList({@required int? limit, int page = 0}) async {
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
          "total": reportIds.length,
          "page": page,
          "nextPage": page + 1,
          "isEnd": limit * (page + 1) >= reportIds.length,
        },
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
      reportIds.sort(sortHandler);
      await storage.setItem("local_report_ids", reportIds);

      return {"success": true};
    } catch (e) {
      return {"success": false};
    }
  }
}
