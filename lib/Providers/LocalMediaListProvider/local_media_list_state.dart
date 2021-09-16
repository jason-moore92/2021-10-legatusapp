import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:legatus/Models/index.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class LocalMediaListState extends Equatable {
  final int? progressState; // 0: init, 1: progressing, 2: success, 3: failed
  final String? message;
  final String? contextName;
  final LocalReportModel? localLocalReportModel;
  final List<dynamic>? localMediaListData;
  final Map<String, dynamic>? localMediaMetaData;
  final bool? isRefresh;

  LocalMediaListState({
    @required this.progressState,
    @required this.message,
    @required this.contextName,
    @required this.localLocalReportModel,
    @required this.localMediaListData,
    @required this.localMediaMetaData,
    @required this.isRefresh,
  });

  factory LocalMediaListState.init() {
    return LocalMediaListState(
      progressState: 0,
      message: "",
      contextName: "",
      localLocalReportModel: LocalReportModel(),
      localMediaListData: [],
      localMediaMetaData: Map<String, dynamic>(),
      isRefresh: false,
    );
  }

  LocalMediaListState copyWith({
    int? progressState,
    String? message,
    String? contextName,
    LocalReportModel? localLocalReportModel,
    List<dynamic>? localMediaListData,
    Map<String, dynamic>? localMediaMetaData,
    bool? isRefresh,
  }) {
    return LocalMediaListState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      contextName: contextName ?? this.contextName,
      localLocalReportModel:
          localLocalReportModel ?? this.localLocalReportModel,
      localMediaListData: localMediaListData ?? this.localMediaListData,
      localMediaMetaData: localMediaMetaData ?? this.localMediaMetaData,
      isRefresh: isRefresh ?? this.isRefresh,
    );
  }

  LocalMediaListState update({
    int? progressState,
    String? message,
    String? contextName,
    LocalReportModel? localLocalReportModel,
    List<dynamic>? localMediaListData,
    Map<String, dynamic>? localMediaMetaData,
    bool? isRefresh,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      contextName: contextName,
      localLocalReportModel: localLocalReportModel,
      localMediaListData: localMediaListData,
      localMediaMetaData: localMediaMetaData,
      isRefresh: isRefresh,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "contextName": contextName,
      "localLocalReportModel": localLocalReportModel!.toJson(),
      "localMediaListData": localMediaListData,
      "localMediaMetaData": localMediaMetaData,
      "isRefresh": isRefresh,
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        contextName!,
        localLocalReportModel!,
        localMediaListData!,
        localMediaMetaData!,
        isRefresh!,
      ];

  @override
  bool get stringify => true;
}
