import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Config/config.dart';
import 'package:legatus/Helpers/custom_url_lancher.dart';
// import 'package:legatus/Helpers/index.dart';
// import 'package:legatus/Models/MediaModel.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/Components/index.dart';
import 'package:legatus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class UploadReportDialog {
  static show(
    BuildContext context, {
    double? borderRadius,
    Function? callback,
  }) {
    double widthDp = ScreenUtil().setWidth(1);
    double heightDp = ScreenUtil().setWidth(1);
    // double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? heightDp * 10)),
          insetPadding: EdgeInsets.symmetric(horizontal: heightDp * 30.0, vertical: heightDp * 20.0),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.only(
            left: heightDp * 15,
            right: heightDp * 15,
            top: heightDp * 20,
            bottom: heightDp * 20,
          ),
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: heightDp * 20, color: Colors.black),
                    SizedBox(width: heightDp * 10),
                    Text(
                      LocaleKeys.UploadDialogString_title.tr(),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),

                ///
                SizedBox(height: heightDp * 10),
                Text(
                  "${LocaleKeys.UploadDialogString_content1.tr()}",
                  style: Theme.of(context).textTheme.caption,
                ),

                ///
                SizedBox(height: heightDp * 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "  ∙  ",
                      style: Theme.of(context).textTheme.caption!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Expanded(
                      child: Text(
                        "${LocaleKeys.UploadDialogString_content2.tr()}",
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),

                ///
                SizedBox(height: heightDp * 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "  ∙  ",
                      style: Theme.of(context).textTheme.caption!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Expanded(
                      child: Text(
                        "${LocaleKeys.UploadDialogString_content3.tr()}",
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),

                ///
                SizedBox(height: heightDp * 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "  ∙  ",
                      style: Theme.of(context).textTheme.caption!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Expanded(
                      child: Text(
                        "${LocaleKeys.UploadDialogString_content4.tr()}",
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),

                ///
                SizedBox(height: heightDp * 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "  ∙  ",
                      style: Theme.of(context).textTheme.caption!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Expanded(
                      child: Text(
                        "${LocaleKeys.UploadDialogString_content5.tr()}",
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),

                ///
                SizedBox(height: heightDp * 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "  ∙  ",
                      style: Theme.of(context).textTheme.caption!.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Expanded(
                      child: Text(
                        "${LocaleKeys.UploadDialogString_content6.tr()}",
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: heightDp * 20),
                Center(
                  child: CustomTextButton(
                    leftWidget: Padding(
                      padding: EdgeInsets.only(right: widthDp * 5),
                      child: Icon(Icons.call_outlined, size: heightDp * 20, color: AppColors.yello),
                    ),
                    text: LocaleKeys.ConfigurationPageString_contactLegatus.tr(),
                    textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
                    bordercolor: AppColors.yello,
                    onPressed: () {
                      CustomUrlLauncher.makePhoneCall(AppConfig.contactPhoneNumber);
                    },
                  ),
                ),

                ///
                SizedBox(height: heightDp * 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomTextButton(
                      text: LocaleKeys.UploadDialogString_cancel.tr(),
                      textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: AppColors.yello,
                            fontWeight: FontWeight.w600,
                          ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CustomTextButton(
                      text: LocaleKeys.UploadDialogString_login.tr(),
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
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
