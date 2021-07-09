import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Components/index.dart';

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
            textAlign: TextAlign.center,
          ),
          content: Text(
            content,
            style: TextStyle(fontSize: fontSp * 14, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          actions: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomTextButton(
                    text: okButton,
                    textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
                    bordercolor: AppColors.yello,
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (callback != null) callback();
                    },
                  ),
                  CustomTextButton(
                    text: cancelButton,
                    textStyle: Theme.of(context).textTheme.button!.copyWith(color: Colors.grey),
                    bordercolor: Colors.grey,
                    onPressed: () {
                      Navigator.of(context).pop();
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
