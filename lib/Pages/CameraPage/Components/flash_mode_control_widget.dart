import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FlashModeControllWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final CameraController? cameraController;
  final double? iconSize;
  final Function(FlashMode)? onPressHandler;

  const FlashModeControllWidget({
    Key? key,
    this.scaffoldKey,
    @required this.cameraController,
    @required this.iconSize,
    @required this.onPressHandler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Icon icon;
    FlashMode nextMode;

    bool enable = true;

    if (cameraController == null || cameraController!.description.lensDirection == CameraLensDirection.front) {
      enable = false;
    }

    if (cameraController == null) {
      return IconButton(
        icon: const Icon(Icons.flash_off),
        color: Colors.transparent,
        iconSize: iconSize!,
        onPressed: null,
      );
    }

    switch (cameraController!.value.flashMode) {
      case FlashMode.off:
        icon = const Icon(Icons.flash_off);
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        icon = const Icon(Icons.flash_on);
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        icon = const Icon(Icons.flash_auto);
        nextMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        icon = const Icon(Icons.highlight);
        nextMode = FlashMode.off;
        break;
      default:
        icon = const Icon(Icons.flash_off);
        nextMode = FlashMode.off;
    }

    return IconButton(
      icon: icon,
      color: enable ? Colors.white : Colors.white.withOpacity(0.5),
      iconSize: iconSize!,
      onPressed: enable ? () => onPressHandler!(nextMode) : () {},
    );
  }
}
