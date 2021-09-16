import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/Components/index.dart';

class NormalAskDialog {
  static show(
    BuildContext context, {
    String title = "",
    String content = "",
    String okButton = "OK",
    String cancelButton = "Cancel",
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
              text: cancelButton,
              textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: AppColors.yello,
                    fontWeight: FontWeight.w600,
                  ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CustomTextButton(
              text: okButton,
              textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
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
