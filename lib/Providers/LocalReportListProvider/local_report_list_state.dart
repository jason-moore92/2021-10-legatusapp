import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class LocalReportListState extends Equatable {
  final int? progressState; // 0: init, 1: progressing, 2: success, 3: failed
  final String? message;
  final List<dynamic>? localReportListData;
  final Map<String, dynamic>? localReportMetaData;
  final bool? isRefresh;

  LocalReportListState({
    @required this.progressState,
    @required this.message,
    @required this.localReportListData,
    @required this.localReportMetaData,
    @required this.isRefresh,
  });

  factory LocalReportListState.init() {
    return LocalReportListState(
      progressState: 0,
      message: "",
      localReportListData: [],
      localReportMetaData: Map<String, dynamic>(),
      isRefresh: false,
    );
  }

  LocalReportListState copyWith({
    int? progressState,
    String? message,
    List<dynamic>? localReportListData,
    Map<String, dynamic>? localReportMetaData,
    bool? isRefresh,
  }) {
    return LocalReportListState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      localReportListData: localReportListData ?? this.localReportListData,
      localReportMetaData: localReportMetaData ?? this.localReportMetaData,
      isRefresh: isRefresh ?? this.isRefresh,
    );
  }

  LocalReportListState update({
    int? progressState,
    String? message,
    List<dynamic>? localReportListData,
    Map<String, dynamic>? localReportMetaData,
    bool? isRefresh,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      localReportListData: localReportListData,
      localReportMetaData: localReportMetaData,
      isRefresh: isRefresh,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "localReportListData": localReportListData,
      "localReportMetaData": localReportMetaData,
      "isRefresh": isRefresh,
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        localReportListData!,
        localReportMetaData!,
        isRefresh!,
      ];

  @override
  bool get stringify => true;
}
