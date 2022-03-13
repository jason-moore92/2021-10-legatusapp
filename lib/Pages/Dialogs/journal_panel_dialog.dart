import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Helpers/validators.dart';
// import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/Components/index.dart';
import 'package:legatus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class JournalPanelDialog {
  static show(
    BuildContext context, {
    double? topMargin,
    String email = "",
    bool barrierDismissible = false,
    Function? callBack,
  }) async {
    double appbarHeight = AppBar().preferredSize.height;
    double widthDp = ScreenUtil().setWidth(1);
    double heightDp = ScreenUtil().setWidth(1);

    TextEditingController _controller = TextEditingController();
    FocusNode _focusNode = FocusNode();

    GlobalKey<FormState> _formkey = GlobalKey<FormState>();

    if (email != "") {
      _controller.text = email;
    }

    void _saveHandler(BuildContext context) async {
      if (!_formkey.currentState!.validate()) return;
      Navigator.of(context).pop();
      if (callBack != null) {
        callBack(_controller.text.trim());
      }
    }

    return await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: Wrap(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Form(
                  key: _formkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: topMargin ?? appbarHeight),
                      Container(
                        color: Colors.black45,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(heightDp * 15),
                              bottomRight: Radius.circular(heightDp * 15),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: heightDp * 20, vertical: heightDp * 20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    "lib/Assets/Images/word.png",
                                    width: heightDp * 25,
                                    height: heightDp * 25,
                                  ),
                                  SizedBox(width: widthDp * 10),
                                  Text(
                                    LocaleKeys.JournalDialogString_title.tr(),
                                    style: Theme.of(context).textTheme.caption,
                                  )
                                ],
                              ),
                              SizedBox(height: heightDp * 15),
                              Text(
                                  // LocaleKeys.JournalDialogString_content.tr(),
                                  "Recevez gratuitement et instantanément une base de PV de constat au format Word, par email. Elle reprendra les informations du constat et la chronologie des constatations. En cliquant sur Recevoir une base de PV, vous acceptez de transmettre à Legatus les données locales de ce constat stockées dans votre appareil.",
                                  style: Theme.of(context).textTheme.bodyText1!),

                              ///
                              SizedBox(height: heightDp * 20),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocaleKeys.JournalDialogString_emailLabel.tr(),
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ),
                                  SizedBox(height: heightDp * 5),
                                  CustomTextFormField(
                                    controller: _controller,
                                    focusNode: _focusNode,
                                    hintText: "vladimir@legatus.fr",
                                    hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                                    errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                                      borderRadius: BorderRadius.circular(heightDp * 6),
                                    ),
                                    readOnly: email != "",
                                    validator: (input) =>
                                        !KeicyValidators.isValidEmail(input.trim()) ? LocaleKeys.ValidateErrorString_emailErrorText.tr() : null,
                                    onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
                                    onEditingComplete: () => FocusScope.of(context).requestFocus(FocusNode()),
                                  ),
                                ],
                              ),

                              ///
                              SizedBox(height: heightDp * 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomTextButton(
                                    text: LocaleKeys.JournalDialogString_cancel.tr().toUpperCase(),
                                    textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
                                    // width: widthDp * 100,
                                    // bordercolor: Colors.grey.withOpacity(0.7),
                                    // borderRadius: heightDp * 6,
                                    elevation: 0,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  SizedBox(width: widthDp * 20),
                                  CustomTextButton(
                                    text: LocaleKeys.JournalDialogString_send.tr().toUpperCase(),
                                    textStyle: Theme.of(context).textTheme.button!.copyWith(color: AppColors.yello),
                                    // width: widthDp * 120,
                                    // bordercolor: AppColors.yello,
                                    // borderRadius: heightDp * 6,
                                    elevation: 0,
                                    onPressed: () {
                                      _saveHandler(context);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Container(color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
