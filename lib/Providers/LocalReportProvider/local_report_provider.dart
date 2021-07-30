import 'dart:io';

import 'package:flutter/material.dart';
import 'package:legutus/ApiDataProviders/index.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:provider/provider.dart';
import 'index.dart';

class LocalReportProvider extends ChangeNotifier {
  static LocalReportProvider of(BuildContext context, {bool listen = false}) => Provider.of<LocalReportProvider>(context, listen: listen);

  LocalReportState _localReportState = LocalReportState.init();
  LocalReportState get localReportState => _localReportState;

  void setLocalReportState(LocalReportState localReportState, {bool isNotifiable = true}) {
    if (_localReportState != localReportState) {
      _localReportState = localReportState;
      if (isNotifiable) notifyListeners();
    }
  }

  Future<int> createLocalReport({@required LocalReportModel? localReportModel}) async {
    try {
      var result = await LocalReportApiProvider.create(localReportModel: localReportModel);

      if (result["success"]) {
        _localReportState = _localReportState.update(
          progressState: 2,
          message: "",
        );
      } else {
        _localReportState = _localReportState.update(
          progressState: -1,
          message: "Somgthing was wrong",
        );
      }
    } catch (e) {
      _localReportState = _localReportState.update(
        progressState: -1,
        message: e.toString(),
      );
    }

    notifyListeners();
    return _localReportState.progressState!;
  }

  Future<int> updateLocalReport({
    @required LocalReportModel? localReportModel,
    @required String? oldReportId,
    bool isNotifiable = true,
  }) async {
    try {
      var result = await LocalReportApiProvider.update(localReportModel: localReportModel, oldReportId: oldReportId);

      if (result["success"]) {
        _localReportState = _localReportState.update(
          progressState: 2,
          message: "",
        );
      } else {
        _localReportState = _localReportState.update(
          progressState: -1,
          message: "Somgthing was wrong",
        );
      }
    } catch (e) {
      _localReportState = _localReportState.update(
        progressState: -1,
        message: e.toString(),
      );
    }

    if (isNotifiable) notifyListeners();
    return _localReportState.progressState!;
  }

  Future<int> deleteLocalReport({@required LocalReportModel? localReportModel}) async {
    try {
      var result = await LocalReportApiProvider.delete(localReportModel: localReportModel);

      for (var i = 0; i < localReportModel!.medias!.length; i++) {
        File file = File(localReportModel.medias![i].path!);
        try {
          file.deleteSync();
        } catch (e) {
          print(e);
        }
      }

      if (result["success"]) {
        _localReportState = _localReportState.update(
          progressState: 2,
          message: "",
        );
      } else {
        _localReportState = _localReportState.update(
          progressState: -1,
          message: "Somgthing was wrong",
        );
      }
    } catch (e) {
      _localReportState = _localReportState.update(
        progressState: -1,
        message: e.toString(),
      );
    }
    notifyListeners();

    return _localReportState.progressState!;
  }

  Future<void> uploadMedials({@required LocalReportModel? localReportModel, bool isNotifiable = true}) async {
    Future.delayed(Duration(seconds: 2), () async {
      try {
        /// if this report model is new
        if (_localReportState.isUploading! && localReportModel!.reportId == -1) {
          var result = await LocalReportApiProvider.storeReport(localReportModel: localReportModel);
          if (!result["success"]) {
            _localReportState = _localReportState.update(
              progressState: -1,
              isUploading: false,
              message: result["data"]["message"],
            );
            if (isNotifiable) notifyListeners();
            return;
          }

          /// if store Report is success, update local roport
          String createdAt = KeicyDateTime.convertDateStringToMilliseconds(dateString: localReportModel.createdAt).toString();
          int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
            dateString: "${localReportModel.date} ${localReportModel.time}",
          )!;

          localReportModel.reportId = result["data"]["report_id"];

          var result1 = await LocalReportApiProvider.update(localReportModel: localReportModel, oldReportId: "${reportDateTime}_$createdAt");

          if (!result1["success"]) {
            _localReportState = _localReportState.update(
              progressState: -1,
              isUploading: false,
              message: "Update LocalReport Error",
            );
            if (isNotifiable) notifyListeners();
            return;
          }

          /// if update is success,
          _localReportState = _localReportState.update(
            progressState: 3,
            message: result["data"]["message"],
            reportId: result["data"]["report_id"],
          );
        }
        //// uploading medias

        for (var i = 0; i < localReportModel!.medias!.length; i++) {
          MediaModel mediaModel = MediaModel.copy(localReportModel.medias![i]);

          /// upload media
          if (mediaModel.state != "uploaded" && mediaModel.state != "uploading") {
            if (!_localReportState.isUploading!) break;

            _localReportState = _localReportState.update(
              progressState: 3,
              uploadingMediaModel: mediaModel,
            );
            notifyListeners();
            mediaModel.reportId = localReportModel.reportId;
            var result = await LocalMediaApiProvider.uploadMedia(mediaModel: mediaModel);
            if (result["success"]) {
              mediaModel.state = "uploading";
              mediaModel.presignedUrl = result["data"]["presigned_url"];
              _localReportState = _localReportState.update(
                progressState: 3,
                uploadingMediaModel: mediaModel,
              );
              notifyListeners();
            }
          }
          if (mediaModel.state != "uploaded" && mediaModel.state == "uploading" && mediaModel.presignedUrl != "") {
            if (!_localReportState.isUploading!) break;

            _localReportState = _localReportState.update(
              progressState: 3,
              uploadingMediaModel: mediaModel,
            );
            notifyListeners();
            var result1 = await LocalMediaApiProvider.uploadPresignedUrl(presignedUrl: mediaModel.presignedUrl);
            if (result1["success"]) {
              mediaModel.state = "uploaded";
              _localReportState = _localReportState.update(
                progressState: 3,
                uploadingMediaModel: mediaModel,
              );
              notifyListeners();
            }
          }
        }
      } catch (e) {
        print(e.toString());
        _localReportState = _localReportState.update(
          progressState: -1,
          isUploading: false,
          message: e.toString(),
        );
      }

      _localReportState = _localReportState.update(
        progressState: 3,
        isUploading: false,
      );

      if (isNotifiable) notifyListeners();
    });
  }
}
