import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Components/index.dart';

class NormalDialog {
  static show(
    BuildContext context, {
    String title = "",
    String content = "",
    String okButton = "OK",
    Function? callback,
  }) {
    double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontSize: fontSp * 18, color: Colors.black),
            textAlign: TextAlign.start,
          ),
          content: Text(
            content,
            style: TextStyle(fontSize: fontSp * 14, color: Colors.black),
            textAlign: TextAlign.start,
          ),
          actions: [
            CustomTextButton(
              text: okButton,
              textStyle: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: AppColors.yello,
                    fontWeight: FontWeight.w600,
                  ),
              onPressed: () {
                Navigator.of(context).pop();
                if (callback != null) callback();
              },
            ),
          ],
        );
      },
    );
  }
}
