import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuccessDialog {
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
        Future.delayed(Duration(seconds: delaySecondes), () {
          Navigator.pop(context);
          if (callBack != null) {
            callBack();
          }
        });
        return SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? heightDp * 10)),
          title: Icon(Icons.check_circle_outline, size: heightDp * 60, color: Colors.green),
          insetPadding: insetPadding ?? EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          titlePadding: titlePadding ??
              EdgeInsets.only(
                left: heightDp * 10,
                right: heightDp * 10,
                top: heightDp * 20,
                bottom: heightDp * 5,
              ),
          contentPadding: contentPadding ??
              EdgeInsets.only(
                left: heightDp * 10,
                right: heightDp * 10,
                top: heightDp * 5,
                bottom: heightDp * 20,
              ),
          children: [
            Text(
              text,
              style: TextStyle(fontSize: fontSp * 17, color: Colors.black, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
