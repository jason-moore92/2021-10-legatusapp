import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CameraProvider extends ChangeNotifier {
  static CameraProvider of(BuildContext context, {bool listen = false}) => Provider.of<CameraProvider>(context, listen: listen);

  String? _videoRecordStatus = "";
  String? get videoRecordStatus => _videoRecordStatus;

  void setVideoRecordStatus(String videoRecordStatus, {bool isNotifiable = true}) {
    if (_videoRecordStatus != videoRecordStatus) {
      _videoRecordStatus = videoRecordStatus;
      if (isNotifiable) notifyListeners();
    }
  }

  String? _audioRecordStatus = "";
  String? get audioRecordStatus => _audioRecordStatus;

  void setAudioRecordStatus(String audioRecordStatus, {bool isNotifiable = true}) {
    if (_audioRecordStatus != audioRecordStatus) {
      _audioRecordStatus = audioRecordStatus;
      if (isNotifiable) notifyListeners();
    }
  }

  bool? _isVideoRecord = false;
  bool? get isVideoRecord => _isVideoRecord;

  void setIsVideoRecord(bool isVideoRecord, {bool isNotifiable = true}) {
    if (_isVideoRecord != isVideoRecord) {
      _isVideoRecord = isVideoRecord;
      if (isNotifiable) notifyListeners();
    }
  }

  bool? _isAudioRecord = false;
  bool? get isAudioRecord => _isAudioRecord;

  void setIsAudioRecord(bool isAudioRecord, {bool isNotifiable = true}) {
    if (_isAudioRecord != isAudioRecord) {
      _isAudioRecord = isAudioRecord;
      if (isNotifiable) notifyListeners();
    }
  }
}
