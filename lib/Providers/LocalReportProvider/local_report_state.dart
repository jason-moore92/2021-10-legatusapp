import 'package:flutter/material.dart';
import 'package:legutus/Models/index.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class LocalReportState extends Equatable {
  final int? progressState; // 0: init, 1: progressing, 2: success, 3: failed
  final String? message;
  final String? contextName;
  final int? reportId;
  final bool? isUploading;
  final MediaModel? uploadingMediaModel;

  LocalReportState({
    @required this.progressState,
    @required this.message,
    @required this.contextName,
    @required this.reportId,
    @required this.isUploading,
    @required this.uploadingMediaModel,
  });

  factory LocalReportState.init() {
    return LocalReportState(
      progressState: 0,
      message: "",
      contextName: "",
      reportId: -1,
      isUploading: false,
      uploadingMediaModel: MediaModel(),
    );
  }

  LocalReportState copyWith({
    int? progressState,
    String? message,
    String? contextName,
    int? reportId,
    bool? isUploading,
    MediaModel? uploadingMediaModel,
  }) {
    return LocalReportState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      contextName: contextName ?? this.contextName,
      reportId: reportId ?? this.reportId,
      isUploading: isUploading ?? this.isUploading,
      uploadingMediaModel: uploadingMediaModel ?? this.uploadingMediaModel,
    );
  }

  LocalReportState update({
    int? progressState,
    String? message,
    String? contextName,
    int? reportId,
    bool? isUploading,
    MediaModel? uploadingMediaModel,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      contextName: contextName,
      reportId: reportId,
      isUploading: isUploading,
      uploadingMediaModel: uploadingMediaModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "contextName": contextName,
      "reportId": reportId,
      "isUploading": isUploading,
      "uploadingMediaModel": uploadingMediaModel!.toJson(),
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        contextName!,
        reportId!,
        isUploading!,
        uploadingMediaModel!,
      ];

  @override
  bool get stringify => true;
}
