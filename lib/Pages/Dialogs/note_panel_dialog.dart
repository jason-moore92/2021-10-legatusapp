import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotePanelDialog {
  static show(
    BuildContext context, {
    EdgeInsets? insetPadding,
    EdgeInsets? titlePadding,
    EdgeInsets? contentPadding,
    double? borderRadius,
    String text = "Success!",
    bool barrierDismissible = false,
    Function? callBack,
    int delaySecondes = 2,
  }) {
    double heightDp = ScreenUtil().setWidth(1);
    double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
          ),
        );
      },
    );
  }
}
