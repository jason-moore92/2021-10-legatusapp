import 'package:flutter/material.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Models/user_model.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class AppDataState extends Equatable {
  final int? progressState;
  final String? message;
  final String? contextName;
  final SettingsModel? settingsModel;
  final PersistentTabController? bottomTabController;

  AppDataState({
    @required this.progressState,
    @required this.message,
    @required this.contextName,
    @required this.settingsModel,
    @required this.bottomTabController,
  });

  factory AppDataState.init() {
    return AppDataState(
      progressState: 0,
      message: "",
      contextName: "",
      settingsModel: SettingsModel(),
      bottomTabController: PersistentTabController(),
    );
  }

  AppDataState copyWith({
    int? progressState,
    String? message,
    String? contextName,
    SettingsModel? settingsModel,
    PersistentTabController? bottomTabController,
  }) {
    return AppDataState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      contextName: contextName ?? this.contextName,
      settingsModel: settingsModel ?? this.settingsModel,
      bottomTabController: bottomTabController ?? this.bottomTabController,
    );
  }

  AppDataState update({
    int? progressState,
    String? message,
    String? contextName,
    SettingsModel? settingsModel,
    PersistentTabController? bottomTabController,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      contextName: contextName,
      settingsModel: settingsModel,
      bottomTabController: bottomTabController,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "contextName": contextName,
      "settingsModel": settingsModel!.toJson(),
      "bottomTabController": bottomTabController,
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
