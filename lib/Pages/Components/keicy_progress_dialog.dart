import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ProgressDialogType { Normal, Download }
enum Layout { Row, Column }

BuildContext? _context, _dismissingContext;
bool _barrierDismissible = true, _showLogs = false;
ProgressDialogType _progressDialogType = ProgressDialogType.Normal;
Layout _layout = Layout.Row;
Color _backgroundColor = Colors.white;
double _dialogElevation = 8.0, _borderRadius = 8.0;
Curve _insetAnimCurve = Curves.easeInOut;
double _width = 100;
double _height = 80;
double _progress = 0.0;
double _maxProgress = 100.0;
EdgeInsetsGeometry _padding = EdgeInsets.all(15);
double _spacing = 20.0;
double _indicatorSize = 20;
Widget _progressWidget = Container(
  width: _indicatorSize,
  height: _indicatorSize,
  child: CupertinoActivityIndicator(
    radius: _indicatorSize / 2,
  ),
);
TextStyle _progressTextStyle = TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w400);
TextStyle _messageStyle = TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w600);

bool _isShowing = false;

class KeicyProgressDialog {
  _Body? _dialog;

  String _dialogMessage = "Please wait .....";

  KeicyProgressDialog(
    BuildContext? context, {
    bool? isDismissible,
    bool? showLogs,
    ProgressDialogType? type,
    Layout? layout,
    Color? backgroundColor,
    double? borderRadius,
    double? elevation,
    Curve? insetAnimCurve,
    double? width,
    double? height,
    String? message,
    double? progress,
    double? maxProgress,
    EdgeInsetsGeometry? padding,
    double? spacing,
    double? indicatorSize,
    Widget? progressWidget,
    TextStyle? progressTextStyle,
    TextStyle? messageTextStyle,
  }) {
    _context = context;
    _barrierDismissible = isDismissible ?? true;
    _showLogs = showLogs ?? false;
    _progressDialogType = type ?? _progressDialogType;
    _layout = layout ?? _layout;

    if (_isShowing) return;

    _backgroundColor = backgroundColor ?? _backgroundColor;
    _borderRadius = borderRadius ?? _borderRadius;
    _dialogElevation = elevation ?? _dialogElevation;
    _insetAnimCurve = insetAnimCurve ?? _insetAnimCurve;
    _dialogMessage = message ?? _dialogMessage;
    _width = width ?? _width;
    _height = height ?? _height;
    if (_progressDialogType == ProgressDialogType.Download) {
      _progress = progress ?? _progress;
    }
    _maxProgress = maxProgress ?? _maxProgress;
    _padding = padding ?? _padding;
    _spacing = spacing ?? _spacing;
    _indicatorSize = indicatorSize ?? _indicatorSize;
    _progressWidget = progressWidget ?? _progressWidget;
    _messageStyle = messageTextStyle ?? _messageStyle;
    _progressTextStyle = progressTextStyle ?? _progressTextStyle;
  }

  static KeicyProgressDialog of(
    BuildContext? context, {
    bool? isDismissible,
    bool? showLogs,
    ProgressDialogType? type,
    Layout? layout,
    Color? backgroundColor,
    double? borderRadius,
    double? elevation,
    Curve? insetAnimCurve,
    double? width,
    double? height,
    String? message,
    double? progress,
    double? maxProgress,
    EdgeInsetsGeometry? padding,
    double? spacing,
    double? indicatorSize,
    Widget? progressWidget,
    TextStyle? progressTextStyle,
    TextStyle? messageTextStyle,
  }) {
    return KeicyProgressDialog(
      context,
      isDismissible: isDismissible,
      showLogs: showLogs,
      type: type,
      layout: layout,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      elevation: elevation,
      insetAnimCurve: insetAnimCurve,
      message: message,
      width: width,
      height: height,
      progress: progress,
      maxProgress: maxProgress,
      padding: padding,
      spacing: spacing,
      indicatorSize: indicatorSize,
      progressWidget: progressWidget,
      progressTextStyle: progressTextStyle,
      messageTextStyle: messageTextStyle,
    );
  }

  void update({
    double? progress,
    double? maxProgress,
    String? message,
    Widget? progressWidget,
    TextStyle? progressTextStyle,
    TextStyle? messageTextStyle,
  }) {
    if (_progressDialogType == ProgressDialogType.Download) {
      _progress = progress ?? _progress;
    }

    _dialogMessage = message ?? _dialogMessage;
    _maxProgress = maxProgress ?? _maxProgress;
    _progressWidget = progressWidget ?? _progressWidget;
    _messageStyle = messageTextStyle ?? _messageStyle;
    _progressTextStyle = progressTextStyle ?? _progressTextStyle;

    if (_isShowing) _dialog!.update();
  }

  bool isShowing() {
    return _isShowing;
  }

  void dismiss() {
    if (_isShowing) {
      try {
        _isShowing = false;
        if (Navigator.of(_dismissingContext!).canPop()) {
          Navigator.of(_dismissingContext!).pop();
          if (_showLogs) debugPrint('ProgressDialog dismissed');
        } else {
          if (_showLogs) debugPrint('Cant pop ProgressDialog');
        }
      } catch (_) {}
    } else {
      if (_showLogs) debugPrint('ProgressDialog already dismissed');
    }
  }

  Future<bool> hide() {
    if (_isShowing) {
      try {
        _isShowing = false;
        Navigator.of(_dismissingContext!).pop(true);
        if (_showLogs) debugPrint('ProgressDialog dismissed');
        return Future.value(true);
      } catch (_) {
        return Future.value(false);
      }
    } else {
      if (_showLogs) debugPrint('ProgressDialog already dismissed');
      return Future.value(false);
    }
  }

  Future<bool> show() async {
    if (!_isShowing) {
      try {
        _dialog = new _Body(message: _dialogMessage);
        showDialog<dynamic>(
          context: _context!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            _dismissingContext = context;
            return WillPopScope(
              onWillPop: () async => _barrierDismissible,
              child: Transform.rotate(
                angle: pi / 2,
                child: Dialog(
                  backgroundColor: _backgroundColor,
                  insetAnimationCurve: _insetAnimCurve,
                  insetAnimationDuration: Duration(milliseconds: 100),
                  elevation: _dialogElevation,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_borderRadius))),
                  child: _dialog,
                ),
              ),
            );
          },
        );
        // Delaying the function for 200 milliseconds
        // [Default transitionDuration of DialogRoute]
        await Future.delayed(Duration(milliseconds: 200));
        if (_showLogs) debugPrint('ProgressDialog shown');
        _isShowing = true;
        return true;
      } catch (_) {
        return false;
      }
    } else {
      if (_showLogs) debugPrint("ProgressDialog already shown/showing");
      return false;
    }
  }
}

// ignore: must_be_immutable
class _Body extends StatefulWidget {
  String? message;

  _Body({this.message});

  _BodyState _dialog = _BodyState();

  update() {
    _dialog.update();
  }

  @override
  State<StatefulWidget> createState() {
    return _dialog;
  }
}

class _BodyState extends State<_Body> {
  update() {
    setState(() {});
  }

  @override
  void dispose() {
    _isShowing = false;
    if (_showLogs) debugPrint('ProgressDialog dismissed by back button');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_layout == Layout.Row) {
      return Container(
        width: _width,
        height: _height,
        padding: _padding,
        child: Transform.rotate(
          angle: pi / 2,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _progressWidget,
                (widget.message! == "") ? SizedBox() : SizedBox(width: _spacing),
                (widget.message! == "")
                    ? SizedBox()
                    : (_progressDialogType == ProgressDialogType.Normal)
                        ? Text(widget.message!, textAlign: TextAlign.justify, style: _messageStyle)
                        : Column(
                            children: <Widget>[
                              Text(widget.message!, style: _messageStyle),
                              SizedBox(height: 15),
                              Text("$_progress/$_maxProgress", style: _progressTextStyle),
                            ],
                          ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: _width,
        height: _height,
        padding: _padding,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _progressWidget,
              (widget.message! == "") ? SizedBox() : SizedBox(width: _spacing),
              (widget.message! == "")
                  ? SizedBox()
                  : _progressDialogType == ProgressDialogType.Normal
                      ? Text(widget.message!, textAlign: TextAlign.justify, style: _messageStyle)
                      : Column(
                          children: <Widget>[
                            Text(widget.message!, style: _messageStyle),
                            SizedBox(height: 15),
                            Text("$_progress/$_maxProgress", style: _progressTextStyle),
                          ],
                        ),
            ],
          ),
        ),
      );
    }
  }
}
