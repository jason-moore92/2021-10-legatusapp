import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Providers/CameraProvider/camera_provider.dart';
import 'package:legatus/Providers/index.dart';
import 'package:provider/provider.dart';

class CenterRecorderIcon extends StatelessWidget {
  final CameraController? cameraController;
  final Function()? onTakePictureButtonPressed;
  final Function(CameraDescription, int)? onNewCameraSelected;

  const CenterRecorderIcon({
    Key? key,
    @required this.cameraController,
    @required this.onTakePictureButtonPressed,
    @required this.onNewCameraSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double heightDp = ScreenUtil().setWidth(1);

    return Consumer<CameraProvider>(builder: (context, cameraProvider, _) {
      bool isRecording = false;

      isRecording = (cameraController != null &&
              cameraProvider.cameraState.isShowVideoRecoderPanel! &&
              cameraProvider.cameraState.videoRecordStatus == "recording") ||
          (cameraController != null &&
              cameraProvider.cameraState.isShowAudioRecoderPanel! &&
              cameraProvider.cameraState.audioRecordStatus == "recording");

      return GestureDetector(
        onTap: () async {
          if (cameraProvider.cameraState.isShowVideoRecoderPanel!) {
            if (!cameraController!.value.isRecordingVideo) {
              await onNewCameraSelected!(
                cameraController!.description,
                AppDataProvider.of(context).appDataState.settingsModel!.videoResolution!,
              );
              WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                cameraProvider.setCameraState(
                  cameraProvider.cameraState.update(
                    videoRecordStatus: "recording",
                    isVideoRecord: true,
                  ),
                );
              });
            } else if (cameraController!.value.isRecordingVideo) {
              WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                cameraProvider.setCameraState(
                  cameraProvider.cameraState.update(
                    videoRecordStatus: "stopped",
                    isVideoRecord: false,
                  ),
                );
              });
            }
          } else if (cameraProvider.cameraState.isShowAudioRecoderPanel!) {
            if (!cameraProvider.cameraState.isAudioRecord!) {
              cameraProvider.setCameraState(
                cameraProvider.cameraState.update(
                  audioRecordStatus: "recording",
                  isAudioRecord: true,
                ),
              );
            } else if (cameraProvider.cameraState.isAudioRecord!) {
              cameraProvider.setCameraState(
                cameraProvider.cameraState.update(
                  audioRecordStatus: "stopped",
                  isAudioRecord: false,
                ),
              );
            }
          } else {
            if (cameraController != null &&
                cameraController!.value.isInitialized &&
                !cameraController!.value.isRecordingVideo &&
                !cameraProvider.cameraState.isAudioRecord! &&
                !cameraProvider.cameraState.isVideoRecord!) {
              onTakePictureButtonPressed!();
            }
          }
        },
        child: Container(
          width: heightDp * 60,
          height: heightDp * 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isRecording ? heightDp * 35 : heightDp * 48,
                height: isRecording ? heightDp * 35 : heightDp * 48,
                decoration: BoxDecoration(
                  color: cameraProvider.cameraState.isShowVideoRecoderPanel! || cameraProvider.cameraState.isShowAudioRecoderPanel!
                      ? Colors.red
                      : AppColors.yello,
                  borderRadius: BorderRadius.circular(
                    isRecording ? heightDp * 6 : heightDp * 48,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
