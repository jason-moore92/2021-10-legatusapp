import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../responsive_settings.dart';
import 'index.dart';

ThemeData buildLightTheme(BuildContext context) {
  double fontSp = 1.sp / ScreenUtil().textScaleFactor;

  return ThemeData(
    fontFamily: "Roboto",
    brightness: Brightness.light,
    primaryColor: AppColors.primayColor,
    scaffoldBackgroundColor: AppColors.backColor,
    // accentColor: AppColors.primayColor,
    focusColor: AppColors.primayColor,
    hintColor: AppColors.primayColor,
    appBarTheme: AppBarTheme(
      // brightness: Brightness.dark,
      backgroundColor: AppColors.primayColor,
    ),
    textTheme: TextTheme(
      headline1: TextStyle(fontSize: fontSp * 40, color: Colors.black),
      headline2: TextStyle(fontSize: fontSp * 36, color: Colors.black),
      headline3: TextStyle(fontSize: fontSp * 32, color: Colors.black),
      headline4: TextStyle(fontSize: fontSp * 28, color: Colors.black),
      headline5: TextStyle(fontSize: fontSp * 24, color: Colors.black),
      // appbar title style
      headline6: TextStyle(
        fontSize: fontSp * 16,
        color: Colors.white,
        fontWeight: FontWeight.w400,
        height: 1.1,
      ),
      // textformfield style
      subtitle1: TextStyle(
        fontSize: fontSp * 14,
        color: Colors.black,
        height: 1.2,
      ),
      // main heder/title style
      subtitle2: TextStyle(
        fontSize: fontSp * 16,
        color: Colors.black,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      // main body string
      bodyText1: TextStyle(
        fontSize: fontSp * 14,
        color: const Color(0xFF222222),
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      bodyText2: TextStyle(
        fontSize: fontSp * 12,
        color: const Color(0xFF222222).withOpacity(0.6),
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      // label/caption style
      caption: TextStyle(
        fontSize: fontSp * 14,
        color: const Color(0xFF222222),
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
      overline: TextStyle(
        fontSize: fontSp * 10,
        color: const Color(0xFF222222),
        fontWeight: FontWeight.w400,
        height: 1,
        letterSpacing: 0.5,
      ),
      button: TextStyle(
        fontSize: fontSp * 14,
        color: Colors.black,
        fontWeight: FontWeight.w500,
        height: 1.3,
      ),
    ),
  );
}
