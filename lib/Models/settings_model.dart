// ignore_for_file: must_be_immutable

import "package:equatable/equatable.dart";
import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 1)
class SettingsModel extends Equatable {
  @HiveField(0)
  int? photoResolution;
  @HiveField(1)
  int? videoResolution;

  SettingsModel({
    this.photoResolution = 2,
    this.videoResolution = 0,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> map) {
    return SettingsModel(
      photoResolution: map["photoResolution"] ?? 2,
      videoResolution: map["videoResolution"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "photoResolution": photoResolution ?? 2,
      "videoResolution": videoResolution ?? 0,
    };
  }

  factory SettingsModel.copy(SettingsModel model) {
    return SettingsModel(
      photoResolution: model.photoResolution,
      videoResolution: model.videoResolution,
    );
  }

  @override
  List<Object> get props => [
        photoResolution!,
        videoResolution!,
      ];

  @override
  bool get stringify => true;
}
