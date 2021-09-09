import 'package:flutter/material.dart';
import 'package:legutus/Models/index.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class AppDataState extends Equatable {
  final int? progressState;
  final String? message;
  final String? contextName;
  final SettingsModel? settingsModel;
  final PersistentTabController? bottomTabController;
  final Map<String, dynamic>? androidInfo;
  final Map<String, dynamic>? iosInfo;

  AppDataState({
    @required this.progressState,
    @required this.message,
    @required this.contextName,
    @required this.settingsModel,
    @required this.bottomTabController,
    @required this.androidInfo,
    @required this.iosInfo,
  });

  factory AppDataState.init() {
    return AppDataState(
      progressState: 0,
      message: "",
      contextName: "",
      settingsModel: SettingsModel(),
      bottomTabController: PersistentTabController(),
      androidInfo: null,
      iosInfo: null,
    );
  }

  AppDataState copyWith({
    int? progressState,
    String? message,
    String? contextName,
    SettingsModel? settingsModel,
    PersistentTabController? bottomTabController,
    Map<String, dynamic>? androidInfo,
    Map<String, dynamic>? iosInfo,
  }) {
    return AppDataState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      contextName: contextName ?? this.contextName,
      settingsModel: settingsModel ?? this.settingsModel,
      bottomTabController: bottomTabController ?? this.bottomTabController,
      androidInfo: androidInfo ?? this.androidInfo,
      iosInfo: iosInfo ?? this.iosInfo,
    );
  }

  AppDataState update({
    int? progressState,
    String? message,
    String? contextName,
    SettingsModel? settingsModel,
    PersistentTabController? bottomTabController,
    Map<String, dynamic>? androidInfo,
    Map<String, dynamic>? iosInfo,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      contextName: contextName,
      settingsModel: settingsModel,
      bottomTabController: bottomTabController,
      androidInfo: androidInfo,
      iosInfo: iosInfo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "contextName": contextName,
      "settingsModel": settingsModel!.toJson(),
      "bottomTabController": bottomTabController,
      "androidInfo": androidInfo,
      "iosInfo": iosInfo,
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        settingsModel!,
        bottomTabController!,
      ];

  @override
  bool get stringify => true;
}
