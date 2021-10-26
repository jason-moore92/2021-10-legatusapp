import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'index.dart';

class CameraProvider extends ChangeNotifier {
  static CameraProvider of(BuildContext context, {bool listen = false}) => Provider.of<CameraProvider>(context, listen: listen);

  CameraState _cameraState = CameraState.init();
  CameraState get cameraState => _cameraState;

  void setCameraState(CameraState cameraState, {bool isNotifiable = true}) {
    if (_cameraState != cameraState) {
      _cameraState = cameraState;
      if (isNotifiable) notifyListeners();
    }
  }
}
