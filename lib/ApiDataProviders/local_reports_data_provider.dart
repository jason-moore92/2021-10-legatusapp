import 'package:flutter/material.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

class LocalReportsDataProvider {
  static LocalStorage? _storage = LocalStorage("local_reports");

  static Future<Map<String, dynamic>> create({@required LocalReportModel? localReportModel}) async {
    try {
      await _storage!.setItem(localReportModel!.reportId.toString(), localReportModel.toJson());
      List<dynamic> reportIds = _storage!.getItem("local_report_ids") ?? [];
      int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(dateString: "${localReportModel.date} ${localReportModel.time}")!;
      reportIds.add("${reportDateTime}_${localReportModel.reportId}");

      reportIds.sort(sortHandler);

      await _storage!.setItem("local_report_ids", reportIds);
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

  static Future<Map<String, dynamic>> update({@required LocalReportModel? localReportModel}) async {
    try {
      await _storage!.setItem(localReportModel!.reportId.toString(), localReportModel.toJson());
      return {"success": true};
    } catch (e) {
      return {"success": false};
    }
  }

  static Future<Map<String, dynamic>> getLocalReportList({@required int? limit, int page = 0}) async {
    try {
      List<dynamic> reportIds = _storage!.getItem("local_report_ids") ?? [];
      List<LocalReportModel> reportModelList = [];
      for (var i = page * limit!; i < (page + 1) * limit; i++) {
        if (i < reportIds.length) {
          String reportId = reportIds[i].toString().split('_').last;

          LocalReportModel localReportModel = LocalReportModel.fromJson(_storage!.getItem(reportId));
          reportModelList.add(localReportModel);
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
}
