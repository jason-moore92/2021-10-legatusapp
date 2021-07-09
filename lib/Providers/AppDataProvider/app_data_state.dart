import 'package:flutter/material.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Models/user_model.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class AppDataState extends Equatable {
  final int? progressState;
  final String? message;
  final SettingsModel? settingsModel;
  final List<dynamic>? localReportList;

  AppDataState({
    @required this.progressState,
    @required this.message,
    @required this.settingsModel,
    @required this.localReportList,
  });

  factory AppDataState.init() {
    return AppDataState(
      progressState: 0,
      message: "",
      settingsModel: SettingsModel(),
      localReportList: [],
    );
  }

  AppDataState copyWith({
    int? progressState,
    String? message,
    SettingsModel? settingsModel,
    List<dynamic>? localReportList,
  }) {
    return AppDataState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      settingsModel: settingsModel ?? this.settingsModel,
      localReportList: localReportList ?? this.localReportList,
    );
  }

  AppDataState update({
    int? progressState,
    String? message,
    SettingsModel? settingsModel,
    List<dynamic>? localReportList,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      settingsModel: settingsModel,
      localReportList: localReportList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "settingsModel": settingsModel!.toJson(),
      "localReportList": localReportList,
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        settingsModel!,
        localReportList!,
      ];

  @override
  bool get stringify => true;
}
