// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/Components/index.dart';
import 'package:legatus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:uuid/uuid.dart';

class NotePanelDialog {
  static show(
    BuildContext context, {
    double? topMargin,
    bool? isNew = true,
    MediaModel? mediaModel,
    bool barrierDismissible = false,
    Function? callBack,
  }) async {
    double appbarHeight = AppBar().preferredSize.height;
    double widthDp = ScreenUtil().setWidth(1);
    double heightDp = ScreenUtil().setWidth(1);

    TextEditingController controller = TextEditingController();
    FocusNode focusNode = FocusNode();

    GlobalKey<FormState> formkey = GlobalKey<FormState>();

    if (!isNew!) {
      controller.text = mediaModel!.content!;
    }

    void _saveHandler(BuildContext context) async {
      if (!formkey.currentState!.validate()) return;

      Navigator.of(context).pop(controller.text);
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
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Form(
                  key: formkey,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  if (mediaModel != null)
                                    Icon(
                                      mediaModel.state == "uploaded" ? Icons.cloud_done : Icons.cloud_off,
                                      size: heightDp * 20,
                                      color: mediaModel.state == "uploaded" ? AppColors.green : AppColors.red.withOpacity(0.6),
                                    ),
                                ],
                              ),

                              ///
                              SizedBox(height: heightDp * 20),
                              CustomTextFormField(
                                controller: controller,
                                focusNode: focusNode,
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
                                readOnly: mediaModel != null && mediaModel.state == "uploaded",
                                validator: (input) =>
                                    input.isEmpty ? LocaleKeys.ValidateErrorString_shouldBeErrorText.tr(args: ["note"]) : null,
                                onFieldSubmitted: (input) => FocusScope.of(context).requestFocus(FocusNode()),
                                onEditingComplete: () => FocusScope.of(context).requestFocus(FocusNode()),
                              ),

                              ///
                              SizedBox(height: heightDp * 20),
                              if (mediaModel != null && mediaModel.state == "uploaded")
                                Column(
                                  children: [
                                    Text(
                                      "Une note synchronisée ne peut pas être modifiée.",
                                      style: Theme.of(context).textTheme.subtitle1,
                                    ),
                                    SizedBox(height: heightDp * 10),
                                  ],
                                ),
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
                                    textStyle: Theme.of(context).textTheme.button!.copyWith(
                                        color: mediaModel != null && mediaModel.state == "uploaded"
                                            ? Colors.grey.withOpacity(0.7)
                                            : AppColors.yello),
                                    // width: widthDp * 120,
                                    // bordercolor: AppColors.yello,
                                    // borderRadius: heightDp * 6,
                                    elevation: 0,
                                    onPressed: mediaModel != null && mediaModel.state == "uploaded"
                                        ? null
                                        : () {
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
