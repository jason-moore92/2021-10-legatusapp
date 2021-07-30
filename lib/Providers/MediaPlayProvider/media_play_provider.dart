import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'index.dart';

class MediaPlayProvider extends ChangeNotifier {
  static MediaPlayProvider of(BuildContext context, {bool listen = false}) => Provider.of<MediaPlayProvider>(context, listen: listen);

  MediaPlayState _mediaPlayState = MediaPlayState.init();
  MediaPlayState get mediaPlayState => _mediaPlayState;

  void setMediaPlayState(MediaPlayState mediaPlayState, {bool isNotifiable = true}) {
    if (_mediaPlayState != mediaPlayState) {
      _mediaPlayState = mediaPlayState;
      if (isNotifiable) notifyListeners();
    }
  }

  void refresh() {
    notifyListeners();
  }
}
