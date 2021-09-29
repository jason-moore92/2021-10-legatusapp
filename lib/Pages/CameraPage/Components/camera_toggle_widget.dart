// import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  /// Responsive design variables
  double? deviceWidth;
  double? deviceHeight;
  double? widthDp;
  double? heightDp;
  double? fontSp;
  ///////////////////////////////

  @override
  Widget build(BuildContext context) {
    /// Responsive design variables
    deviceWidth = 1.sw;
    deviceHeight = 1.sh;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    ///////////////////////////////

    Widget? backWidget;
    Widget? frontWidget;
    Widget? externalWidgdet;
    bool isAvailable = true;

    isAvailable =
        !(cameraController != null && cameraController!.value.isRecordingVideo);

    for (var i = 0; i < cameras!.length; i++) {
      switch (cameras![i].lensDirection) {
        case CameraLensDirection.back:
          backWidget = IconButton(
            icon: Icon(
              Icons.camera_front_outlined,
              color: isAvailable ? Colors.white : Colors.white.withOpacity(0.6),
              size: heightDp! * 20,
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
              size: heightDp! * 20,
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
              size: heightDp! * 20,
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
          size: heightDp! * 20,
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
