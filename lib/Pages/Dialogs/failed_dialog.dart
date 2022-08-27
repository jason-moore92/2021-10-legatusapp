import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Pages/Components/index.dart';

class FailedDialog {
  static show(
    BuildContext context, {
    String text = "Failed!",
    String okButton = "OK",
    EdgeInsets? insetPadding,
    EdgeInsets? titlePadding,
    EdgeInsets? contentPadding,
    double? borderRadius,
    bool barrierDismissible = false,
    Function? callBack,
  }) {
    double heightDp = ScreenUtil().setWidth(1);
    double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0.0,
          backgroundColor: Colors.white,
          insetPadding: insetPadding ?? const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? heightDp * 10)),
          title: Icon(Icons.error_outline, size: heightDp * 60, color: Colors.redAccent),
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
          content: Text(
            text,
            style: TextStyle(fontSize: fontSp * 15, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                    text: okButton,
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (callBack != null) {
                        callBack();
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
