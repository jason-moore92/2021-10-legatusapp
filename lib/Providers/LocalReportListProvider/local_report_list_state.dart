import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:legatus/Models/index.dart';
import 'package:equatable/equatable.dart';

class LocalReportListState extends Equatable {
  final int? progressState; // 0: init, 1: progressing, 2: success, 3: failed
  final String? message;
  final String? contextName;
  final List<dynamic>? localReportListData;
  final Map<String, dynamic>? localReportMetaData;
  final bool? isRefresh;
  final bool? refreshList;
  final LocalReportModel? localReportModel;
  final bool? isNew;

  const LocalReportListState({
    @required this.progressState,
    @required this.message,
    @required this.contextName,
    @required this.localReportListData,
    @required this.localReportMetaData,
    @required this.isRefresh,
    @required this.refreshList,
    @required this.localReportModel,
    @required this.isNew,
  });

  factory LocalReportListState.init() {
    return LocalReportListState(
      progressState: 0,
      message: "",
      contextName: "",
      localReportListData: const [],
      localReportMetaData: const <String, dynamic>{},
      isRefresh: false,
      refreshList: false,
      localReportModel: LocalReportModel(),
      isNew: false,
    );
  }

  LocalReportListState copyWith({
    int? progressState,
    String? message,
    String? contextName,
    List<dynamic>? localReportListData,
    Map<String, dynamic>? localReportMetaData,
    bool? isRefresh,
    bool? refreshList,
    LocalReportModel? localReportModel,
    bool? isNew,
  }) {
    return LocalReportListState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      contextName: contextName ?? this.contextName,
      localReportListData: localReportListData ?? this.localReportListData,
      localReportMetaData: localReportMetaData ?? this.localReportMetaData,
      isRefresh: isRefresh ?? this.isRefresh,
      refreshList: refreshList ?? this.refreshList,
      localReportModel: localReportModel ?? this.localReportModel,
      isNew: isNew ?? this.isNew,
    );
  }

  LocalReportListState update({
    int? progressState,
    String? message,
    String? contextName,
    List<dynamic>? localReportListData,
    Map<String, dynamic>? localReportMetaData,
    bool? isRefresh,
    bool? refreshList,
    LocalReportModel? localReportModel,
    bool? isNew,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      contextName: contextName,
      localReportListData: localReportListData,
      localReportMetaData: localReportMetaData,
      isRefresh: isRefresh,
      refreshList: refreshList,
      localReportModel: localReportModel,
      isNew: isNew,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "contextName": contextName,
      "localReportListData": localReportListData,
      "localReportMetaData": localReportMetaData,
      "isRefresh": isRefresh,
      "refreshList": refreshList,
      "localReportModel": localReportModel,
      "isNew": isNew,
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        contextName!,
        localReportListData!,
        localReportMetaData!,
        isRefresh!,
        refreshList!,
        localReportModel ?? Object(),
        refreshList!,
        isNew!,
      ];

  @override
  bool get stringify => true;
}
