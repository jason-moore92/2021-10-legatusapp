import 'package:flutter/material.dart';
import 'package:legatus/Models/MediaModel.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class MediaPlayState extends Equatable {
  final int? progressState; // 0: init, 1: progressing, 2: success, 3: failed
  final String? message;
  final bool? isNew;
  final MediaModel? selectedMediaModel;

  MediaPlayState({
    @required this.progressState,
    @required this.message,
    @required this.isNew,
    @required this.selectedMediaModel,
  });

  factory MediaPlayState.init() {
    return MediaPlayState(
      progressState: 0,
      message: "",
      isNew: false,
      selectedMediaModel: MediaModel(),
    );
  }

  MediaPlayState copyWith({
    int? progressState,
    String? message,
    bool? isNew,
    MediaModel? selectedMediaModel,
  }) {
    return MediaPlayState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      isNew: isNew ?? this.isNew,
      selectedMediaModel: selectedMediaModel ?? this.selectedMediaModel,
    );
  }

  MediaPlayState update({
    int? progressState,
    String? message,
    bool? isNew,
    MediaModel? selectedMediaModel,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      isNew: isNew,
      selectedMediaModel: selectedMediaModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "isNew": isNew,
      "selectedMediaModel": selectedMediaModel!.toJson(),
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        isNew!,
        selectedMediaModel!,
      ];

  @override
  bool get stringify => true;
}
