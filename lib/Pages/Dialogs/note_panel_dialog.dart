import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:keicy_progress_dialog/keicy_progress_dialog.dart';
import 'package:legutus/Helpers/index.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Components/index.dart';
import 'package:legutus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';

class NotePanelDialog {
  static show(
    BuildContext context, {
    double? topMargin,
    bool? isNew = true,
    MediaModel? medialModel,
    bool barrierDismissible = false,
    Function? callBack,
  }) async {
    double appbarHeight = AppBar().preferredSize.height;
    double widthDp = ScreenUtil().setWidth(1);
    double heightDp = ScreenUtil().setWidth(1);

    TextEditingController _controller = TextEditingController();
    FocusNode _focusNode = FocusNode();

    GlobalKey<FormState> _formkey = GlobalKey<FormState>();

    if (!isNew!) {
      _controller.text = medialModel!.content!;
    }

    void _saveHandler(BuildContext context) async {
      if (!_formkey.currentState!.validate()) return;

      Navigator.of(context).pop(_controller.text);
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
                                    "lib/Assets/Images/edit_note.png",
                                    width: heightDp * 25,
                                    height: heightDp * 25,
                                  ),
                                  SizedBox(width: widthDp * 10),
                                  Text(
                                    LocaleKeys.NoteDialogString_newNots.tr(),
                                    style: Theme.of(context).textTheme.caption,
                                  )
                                ],
                              ),

                              ///
                              SizedBox(height: heightDp * 20),
                              CustomTextFormField(
                                controller: _controller,
                                focusNode: _focusNode,
                                hintText: "Le contenu de votre note.",
                                hintStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey.withOpacity(0.8)),
                                errorStyle: Theme.of(context).textTheme.overline!.copyWith(color: Colors.red),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.8)),
                                  borderRadius: BorderRadius.circular(heightDp * 6),
                                ),
                                maxLines: 4,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                validator: (input) => input.isEmpty ? LocaleKeys.ValidateErrorString_shouldBeErrorText.tr(args: ["note"]) : null,
                                onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
                                onEditingComplete: () => FocusScope.of(context).requestFocus(FocusNode()),
                              ),

                              ///
                              SizedBox(height: heightDp * 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomTextButton(
                                    text: LocaleKeys.NoteDialogString_close.tr().toUpperCase(),
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
                                    text: LocaleKeys.NoteDialogString_save.tr().toUpperCase(),
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
