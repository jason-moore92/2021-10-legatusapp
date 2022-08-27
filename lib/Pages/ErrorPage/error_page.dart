import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/Components/index.dart';

// ignore: must_be_immutable
class ErrorPage extends StatelessWidget {
  final String? message;
  final Function? callback;

  ErrorPage({
    Key? key,
    @required this.message,
    this.callback,
  }) : super(key: key);

  /// Responsive design variables
  double? deviceWidth;
  double? deviceHeight;
  double? statusbarHeight;
  double? bottomBarHeight;
  double? appbarHeight;
  double? widthDp;
  double? heightDp;
  double? heightDp1;
  double? fontSp;

  ///////////////////////////////

  @override
  Widget build(BuildContext context) {
    /// Responsive design variables
    deviceWidth = 1.sw;
    widthDp = ScreenUtil().setWidth(1);
    heightDp = ScreenUtil().setWidth(1);
    fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;
    ///////////////////////////////

    return Scaffold(
      body: Container(
        width: deviceWidth,
        padding: EdgeInsets.all(widthDp! * 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: heightDp! * 70, color: Colors.red),
            SizedBox(height: heightDp! * 20),
            Text(
              message ?? "",
              style: TextStyle(fontSize: fontSp! * 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: heightDp! * 20),
            CustomElevatedButton(
              width: widthDp! * 150,
              height: heightDp! * 45,
              backColor: AppColors.primayColor,
              borderRadius: heightDp! * 6,
              text: "Try again",
              onPressed: () {
                if (callback != null) {
                  callback!();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
