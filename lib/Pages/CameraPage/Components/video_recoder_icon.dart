import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Providers/index.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';

class VideoRecorderIcon extends StatelessWidget {
  final CameraController? cameraController;
  final LocalReportModel? localReportModel;
  final NativeDeviceOrientation? orientation;
  final Function(CameraDescription, int)? onNewCameraSelected;

  const VideoRecorderIcon({
    Key? key,
    @required this.cameraController,
    @required this.localReportModel,
    @required this.orientation,
    @required this.onNewCameraSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthDp = ScreenUtil().setWidth(1);
    double heightDp = ScreenUtil().setWidth(1);

    return Consumer<CameraProvider>(builder: (context, cameraProvider, _) {
      double angle = 0;
      if (orientation == NativeDeviceOrientation.portraitUp || orientation == NativeDeviceOrientation.portraitUp) {
        angle = 0;
      } else if (orientation == NativeDeviceOrientation.landscapeLeft) {
        angle = pi / 2;
      } else if (orientation == NativeDeviceOrientation.landscapeRight) {
        angle = -pi / 2;
      }

      int videosCount = 0;

      for (var i = 0; i < localReportModel!.medias!.length; i++) {
        switch (localReportModel!.medias![i].type) {
          case MediaType.video:
            videosCount++;
            break;
          default:
        }
      }

      bool enable = (cameraController != null &&
          cameraController!.value.isInitialized &&
          !cameraProvider.cameraState.isAudioRecord! &&
          !cameraProvider.cameraState.isVideoRecord!);

      return Transform.rotate(
        angle: angle,
        child: Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.videocam,
                color: enable ? Colors.white : Colors.white.withOpacity(0.6),
                size: heightDp * 30,
              ),
              onPressed: enable
                  ? () async {
                      if (!cameraProvider.cameraState.isShowVideoRecoderPanel!) {
                        cameraProvider.setCameraState(
                          cameraProvider.cameraState.update(
                            isShowVideoRecoderPanel: !cameraProvider.cameraState.isShowVideoRecoderPanel!,
                            isShowAudioRecoderPanel: false,
                            videoRecordStatus: "stopped",
                            audioRecordStatus: "stopped",
                            isAudioRecord: false,
                            isVideoRecord: false,
                          ),
                          isNotifiable: false,
                        );

                        if (cameraProvider.cameraState.isPhotoResolution!) {
                          cameraProvider.setCameraState(
                            cameraProvider.cameraState.update(
                              isPhotoResolution: false,
                            ),
                            isNotifiable: false,
                          );
                          await onNewCameraSelected!(
                            cameraController!.description,
                            AppDataProvider.of(context).appDataState.settingsModel!.videoResolution!,
                          );
                        }
                      }
                    }
                  : null,
            ),
            Positioned(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: widthDp * 3, vertical: heightDp * 3),
                    decoration: BoxDecoration(
                      color: AppColors.yello,
                      borderRadius: BorderRadius.circular(heightDp * 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$videosCount",
                      style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
