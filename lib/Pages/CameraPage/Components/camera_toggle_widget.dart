// import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Providers/index.dart';

class CameraToggleWidget extends StatelessWidget {
  final CameraController? cameraController;
  final List<CameraDescription>? cameras;
  final Function(CameraDescription)? onPressHandler;

  CameraToggleWidget({
    Key? key,
    @required this.cameraController,
    @required this.cameras,
    @required this.onPressHandler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Responsive design variables
    double heightDp = ScreenUtil().setWidth(1);
    ///////////////////////////////

    Widget? backWidget;
    Widget? frontWidget;
    Widget? externalWidgdet;
    bool isAvailable = true;

    isAvailable = cameraController != null &&
        !cameraController!.value.isRecordingVideo &&
        !CameraProvider.of(context).cameraState.isVideoRecord! &&
        !CameraProvider.of(context).cameraState.isAudioRecord!;

    for (var i = 0; i < cameras!.length; i++) {
      switch (cameras![i].lensDirection) {
        case CameraLensDirection.back:
          backWidget = IconButton(
            icon: Icon(
              Icons.camera_front_outlined,
              color: isAvailable ? Colors.white : Colors.white.withOpacity(0.6),
              size: heightDp * 20,
            ),
            onPressed: !isAvailable
                ? null
                : () {
                    onPressHandler!(cameras![(i + 1) % cameras!.length]);
                  },
          );
          break;
        case CameraLensDirection.front:
          frontWidget = IconButton(
            icon: Icon(
              Icons.camera_rear_outlined,
              color: isAvailable ? Colors.white : Colors.white.withOpacity(0.6),
              size: heightDp * 20,
            ),
            onPressed: !isAvailable
                ? null
                : () {
                    onPressHandler!(cameras![(i + 1) % cameras!.length]);
                  },
          );
          break;
        case CameraLensDirection.external:
          externalWidgdet = IconButton(
            icon: Icon(
              Icons.switch_camera,
              color: isAvailable ? Colors.white : Colors.white.withOpacity(0.5),
              size: heightDp * 20,
            ),
            onPressed: !isAvailable
                ? null
                : () {
                    onPressHandler!(cameras![(i + 1) % cameras!.length]);
                  },
          );
          break;
      }
    }

    if (cameraController == null)
      return IconButton(
        icon: Icon(
          Icons.camera_rear_outlined,
          color: Colors.transparent,
          size: heightDp * 20,
        ),
        onPressed: null,
      );

    switch (cameraController!.description.lensDirection) {
      case CameraLensDirection.back:
        return backWidget!;
      case CameraLensDirection.front:
        return frontWidget!;
      case CameraLensDirection.external:
        return externalWidgdet!;
      default:
        return SizedBox();
    }
  }
}
