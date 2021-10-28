import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class CameraState extends Equatable {
  final int? progressState; // 0: init, 1: progressing, 2: success, 3: failed
  final String? message;
  final String? videoRecordStatus;
  final String? audioRecordStatus;
  final bool? isVideoRecord;
  final bool? isAudioRecord;
  final bool? isShowVideoRecoderPanel;
  final bool? isShowAudioRecoderPanel;
  final bool? changedCameraResolution;
  final CameraController? cameraController;
  final bool? isPhotoResolution;

  CameraState({
    @required this.progressState,
    @required this.message,
    @required this.videoRecordStatus,
    @required this.audioRecordStatus,
    @required this.isVideoRecord,
    @required this.isAudioRecord,
    @required this.isShowVideoRecoderPanel,
    @required this.isShowAudioRecoderPanel,
    @required this.changedCameraResolution,
    @required this.cameraController,
    @required this.isPhotoResolution,
  });

  factory CameraState.init() {
    return CameraState(
      progressState: 0,
      message: "",
      videoRecordStatus: "stopped",
      audioRecordStatus: "stopped",
      isVideoRecord: false,
      isAudioRecord: false,
      isShowVideoRecoderPanel: false,
      isShowAudioRecoderPanel: false,
      changedCameraResolution: true,
      cameraController: null,
      isPhotoResolution: true,
    );
  }

  CameraState copyWith({
    int? progressState,
    String? message,
    String? videoRecordStatus,
    String? audioRecordStatus,
    bool? isVideoRecord,
    bool? isAudioRecord,
    bool? isShowVideoRecoderPanel,
    bool? isShowAudioRecoderPanel,
    bool? changedCameraResolution,
    CameraController? cameraController,
    bool? isPhotoResolution,
  }) {
    return CameraState(
      progressState: progressState ?? this.progressState,
      message: message ?? this.message,
      videoRecordStatus: videoRecordStatus ?? this.videoRecordStatus,
      audioRecordStatus: audioRecordStatus ?? this.audioRecordStatus,
      isVideoRecord: isVideoRecord ?? this.isVideoRecord,
      isAudioRecord: isAudioRecord ?? this.isAudioRecord,
      isShowVideoRecoderPanel: isShowVideoRecoderPanel ?? this.isShowVideoRecoderPanel,
      isShowAudioRecoderPanel: isShowAudioRecoderPanel ?? this.isShowAudioRecoderPanel,
      changedCameraResolution: changedCameraResolution ?? this.changedCameraResolution,
      cameraController: cameraController ?? this.cameraController,
      isPhotoResolution: isPhotoResolution ?? this.isPhotoResolution,
    );
  }

  CameraState update({
    int? progressState,
    String? message,
    String? videoRecordStatus,
    String? audioRecordStatus,
    bool? isVideoRecord,
    bool? isAudioRecord,
    bool? isShowVideoRecoderPanel,
    bool? isShowAudioRecoderPanel,
    bool? changedCameraResolution,
    CameraController? cameraController,
    bool? isPhotoResolution,
  }) {
    return copyWith(
      progressState: progressState,
      message: message,
      videoRecordStatus: videoRecordStatus,
      audioRecordStatus: audioRecordStatus,
      isVideoRecord: isVideoRecord,
      isAudioRecord: isAudioRecord,
      isShowVideoRecoderPanel: isShowVideoRecoderPanel,
      isShowAudioRecoderPanel: isShowAudioRecoderPanel,
      changedCameraResolution: changedCameraResolution,
      cameraController: cameraController,
      isPhotoResolution: isPhotoResolution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "progressState": progressState,
      "message": message,
      "videoRecordStatus": videoRecordStatus,
      "audioRecordStatus": audioRecordStatus,
      "isVideoRecord": isVideoRecord,
      "isAudioRecord": isAudioRecord,
      "isShowVideoRecoderPanel": isShowVideoRecoderPanel,
      "isShowAudioRecoderPanel": isShowAudioRecoderPanel,
      "changedCameraResolution": changedCameraResolution,
      "isPhotoResolution": isPhotoResolution,
    };
  }

  @override
  List<Object> get props => [
        progressState!,
        message!,
        videoRecordStatus!,
        audioRecordStatus!,
        isVideoRecord!,
        isAudioRecord!,
        isShowVideoRecoderPanel!,
        isShowAudioRecoderPanel!,
        changedCameraResolution!,
        isPhotoResolution!,
      ];

  @override
  bool get stringify => true;
}
