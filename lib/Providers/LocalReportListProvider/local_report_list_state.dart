import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class LocalReportListState extends Equatable {
  final int? progressState; // 0: init, 1: progressing, 2: success, 3: failed
  final String? message;
  final String? contextName;
  final List<dynamic>? localReportListData;
  final Map<String, dynamic>? localReportMetaData;
  final bool? isRefresh;
  final bool? refreshList;

  LocalReportListState({
    @required this.progressState,
    @required this.message,
    @required this.contextName,
    @required this.localReportListData,
    @required this.localReportMetaData,
    @required this.isRefresh,
    @required this.refreshList,
  });

  factory LocalReportListState.init() {
    return LocalReportListState(
      progressState: 0,
      message: "",
      contextName: "",
      localReportListData: [],
      localReportMetaData: Map<String, dynamic>(),
      isRefresh: false,
      refreshList: false,
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
  }) {
    return LocalReportListState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      contextName: contextName ?? this.contextName,
      localReportListData: localReportListData ?? this.localReportListData,
      localReportMetaData: localReportMetaData ?? this.localReportMetaData,
      isRefresh: isRefresh ?? this.isRefresh,
      refreshList: refreshList ?? this.refreshList,
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
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      contextName: contextName,
      localReportListData: localReportListData,
      localReportMetaData: localReportMetaData,
      isRefresh: isRefresh,
      refreshList: refreshList,
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
      ];

  @override
  bool get stringify => true;
}
