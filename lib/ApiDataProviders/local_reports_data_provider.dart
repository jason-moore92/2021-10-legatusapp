import 'package:flutter/material.dart';
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

      ///
      int createAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: localReportModel!.createdAt)!;
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(dateString: "${localReportModel.date} ${localReportModel.time}")!;
      String reportId = "${reportDateTime}_$createAt";

      ///
      await storage.deleteItem(oldReportId!);
      await storage.setItem(reportId, localReportModel.toJson());

      ///
      List<dynamic> reportIds = storage.getItem("local_report_ids") ?? [];
      reportIds.remove(oldReportId);
      reportIds.add(reportId);
      reportIds.sort(sortHandler);
      await storage.setItem("local_report_ids", reportIds);

      return {"success": true};
    } catch (e) {
      return {"success": false};
    }
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
