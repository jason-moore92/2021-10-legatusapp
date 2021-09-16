import 'dart:io';

import 'package:flutter/material.dart';
import 'package:legatus/ApiDataProviders/index.dart';
import 'package:legatus/Helpers/index.dart';
import 'package:legatus/Models/index.dart';
import 'package:provider/provider.dart';
import 'index.dart';

class LocalReportProvider extends ChangeNotifier {
  static LocalReportProvider of(BuildContext context, {bool listen = false}) =>
      Provider.of<LocalReportProvider>(context, listen: listen);

  LocalReportState _localReportState = LocalReportState.init();
  LocalReportState get localReportState => _localReportState;

  void setLocalReportState(LocalReportState localReportState,
      {bool isNotifiable = true}) {
    if (_localReportState != localReportState) {
      _localReportState = localReportState;
      if (isNotifiable) notifyListeners();
    }
  }

  Future<int> createLocalReport(
      {@required LocalReportModel? localReportModel}) async {
    try {
      var result = await LocalReportApiProvider.create(
          localReportModel: localReportModel);

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
    String? oldReportIdStr,
    bool isNotifiable = true,
  }) async {
    try {
      var result = await LocalReportApiProvider.update(
        localReportModel: localReportModel,
        oldReportIdStr: oldReportIdStr,
      );

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

  Future<int> deleteLocalReport(
      {@required LocalReportModel? localReportModel}) async {
    try {
      List<MediaModel>? medias = [];
      for (var i = 0; i < localReportModel!.medias!.length; i++) {
        File file = File(localReportModel.medias![i].path!);
        try {
          await file.delete();
        } catch (e) {
          medias.add(localReportModel.medias![i]);
        }
        if (localReportModel.medias![i].thumPath != "") {
          File file = File(localReportModel.medias![i].thumPath!);
          try {
            await file.delete();
          } catch (e) {
            medias.add(localReportModel.medias![i]);
          }
        }
      }

      if (medias.isNotEmpty) {
        var result = await updateLocalReport(
          localReportModel: localReportModel,
        );
        _localReportState = _localReportState.update(
          progressState: -1,
          message: "Can't delete all media files",
        );
        notifyListeners();
        return _localReportState.progressState!;
      }

      var result = await LocalReportApiProvider.delete(
          localReportModel: localReportModel);

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

  Future<void> uploadMedials(
      {@required LocalReportModel? localReportModel,
      bool isNotifiable = true}) async {
    try {
      /// if this report model is new
      if (_localReportState.isUploading! && localReportModel!.reportId == 0) {
        var result = await LocalReportApiProvider.storeReport(
            localReportModel: localReportModel);
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
        String createdAt = KeicyDateTime.convertDateStringToMilliseconds(
                dateString: localReportModel.createdAt)
            .toString();
        int reportDateTime = KeicyDateTime.convertDateStringToMilliseconds(
          dateString: "${localReportModel.date} ${localReportModel.time}",
        )!;

        localReportModel.reportId = result["data"]["report_id"];

        var result1 = await LocalReportApiProvider.update(
          localReportModel: localReportModel,
          oldReportIdStr: "${reportDateTime}_$createdAt",
        );

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
        if (!_localReportState.isUploading!) break;

        if (mediaModel.state == "uploaded") continue;

        /// upload media
        mediaModel.reportId = localReportModel.reportId;
        _localReportState = _localReportState.update(
          progressState: 3,
          uploadingMediaModel: mediaModel,
        );
        notifyListeners();

        var result =
            await LocalMediaApiProvider.uploadMedia(mediaModel: mediaModel);
        if (result["success"] &&
            result["statusCode"] == 200 &&
            result["data"]["presigned_url"] != null) {
          mediaModel.state = "uploading";
          _localReportState = _localReportState.update(
            progressState: 3,
            uploadingMediaModel: mediaModel,
          );
          notifyListeners();

          var result1 = await LocalMediaApiProvider.uploadPresignedUrl(
            file: File(mediaModel.path!),
            presignedUrl: result["data"]["presigned_url"],
          );
          if (result1["success"]) {
            mediaModel.state = "uploaded";
            _localReportState = _localReportState.update(
              progressState: 3,
              uploadingMediaModel: mediaModel,
            );
            notifyListeners();
          } else {
            mediaModel.state = "error";
            _localReportState = _localReportState.update(
              progressState: 3,
              uploadingMediaModel: mediaModel,
            );
            notifyListeners();
          }
        } else if (result["success"] && result["statusCode"] == 201) {
          mediaModel.state = "uploaded";
          _localReportState = _localReportState.update(
            progressState: 3,
            uploadingMediaModel: mediaModel,
          );
          notifyListeners();
        } else if (!result["success"]) {
          mediaModel.state = "error";
          _localReportState = _localReportState.update(
            progressState: 3,
            uploadingMediaModel: mediaModel,
          );
          notifyListeners();
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
  }
}
