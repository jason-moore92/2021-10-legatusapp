import 'package:flutter/cupertino.dart';
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

class AvailableEditionDialog {
  static show(
    BuildContext context, {
    @required List<dynamic>? editions,
    double? borderRadius,
    Function? callback,
  }) {
    double widthDp = ScreenUtil().setWidth(1);
    double heightDp = ScreenUtil().setWidth(1);
    double deviceHeight = 1.sh;
    // double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

    TextEditingController _noteController = TextEditingController();
    FocusNode _noteFocusNode = FocusNode();

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
            Container(
              height: deviceHeight * 0.7,
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.history_edu, size: heightDp * 20, color: Colors.black),
                      SizedBox(width: heightDp * 10),
                      Text(
                        "Externaliser la frappe",
                        style: Theme.of(context).textTheme.subtitle2!.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),

                  ///
                  SizedBox(height: heightDp * 10),
                  Text(
                    "Choisissez une option dans la liste ci-dessous.",
                    style: Theme.of(context).textTheme.caption,
                  ),

                  ///
                  SizedBox(height: heightDp * 10),

                  ///
                  SizedBox(height: heightDp * 10),

                  ///
                  CustomTextFormField(
                    controller: _noteController,
                    focusNode: _noteFocusNode,
                    hintText: LocaleKeys.NewReportPageString_description.tr(),
                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                      borderRadius: BorderRadius.circular(heightDp * 6),
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
                    onEditingComplete: () => FocusScope.of(context).requestFocus(FocusNode()),
                  ),

                  ///
                  SizedBox(height: heightDp * 10),
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
            ),
          ],
        );
      },
    );
  }
}
