import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Helpers/index.dart';
import 'package:legatus/Models/media_model.dart';
import 'package:legatus/Pages/App/Styles/index.dart';
import 'package:legatus/Pages/Components/index.dart';
import 'package:legatus/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class MediaInfoDialog {
  static show(
    BuildContext context, {
    @required MediaModel? mediaModel,
    @required int? totalMediaCount,
    double? borderRadius,
  }) {
    double heightDp = ScreenUtil().setWidth(1);
    double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

    String mediaType = "";

    switch (mediaModel!.type) {
      case MediaType.picture:
        mediaType = LocaleKeys.MediaInfoDialogString_picture.tr();
        break;
      case MediaType.audio:
        mediaType = LocaleKeys.MediaInfoDialogString_audio.tr();
        break;
      case MediaType.note:
        mediaType = LocaleKeys.MediaInfoDialogString_note.tr();
        break;

      case MediaType.video:
        mediaType = LocaleKeys.MediaInfoDialogString_video.tr();
        break;
      default:
    }
    var date;
    var durationString;
    if (mediaModel.duration! != -1) {
      date = DateTime.fromMillisecondsSinceEpoch(mediaModel.duration!,
          isUtc: true);
      durationString = DateFormat('mm:ss').format(date);
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(borderRadius ?? heightDp * 10)),
          insetPadding: EdgeInsets.symmetric(
              horizontal: heightDp * 30.0, vertical: heightDp * 20.0),
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.only(
            left: heightDp * 15,
            right: heightDp * 15,
            top: heightDp * 20,
            bottom: heightDp * 20,
          ),
          children: [
            Row(
              children: [
                Icon(Icons.info_outline,
                    size: heightDp * 20, color: Colors.black),
                SizedBox(width: heightDp * 10),
                Text(
                  mediaModel.filename!,
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),

            ///
            SizedBox(height: heightDp * 10),
            Row(
              children: [
                Text(
                  "${LocaleKeys.MediaInfoDialogString_media.tr()} :",
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(width: heightDp * 8),
                Expanded(
                  child: Text(
                    "${mediaModel.rank!}/$totalMediaCount",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),

            ///
            SizedBox(height: heightDp * 5),
            Row(
              children: [
                Text(
                  "${LocaleKeys.MediaInfoDialogString_mediaType.tr()} :",
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(width: heightDp * 8),
                Expanded(
                  child: Text(
                    "$mediaType",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),

            ///
            SizedBox(height: heightDp * 5),
            Row(
              children: [
                Text(
                  "${LocaleKeys.MediaInfoDialogString_registeredOn.tr()} :",
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(width: heightDp * 8),
                Expanded(
                  child: Text(
                    "${KeicyDateTime.convertDateTimeToDateString(
                      dateTime: DateTime.tryParse(mediaModel.createdAt!),
                      formats: 'd/m/Y H:i:s',
                    )}",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),

            ///
            SizedBox(height: heightDp * 5),
            Row(
              children: [
                Text(
                  "${LocaleKeys.MediaInfoDialogString_size.tr()} :",
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(width: heightDp * 8),
                Expanded(
                  child: Text(
                    "${(mediaModel.size! / 1024 / 1024).toStringAsFixed(2)} Mo",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),

            ///
            if (mediaModel.duration! != -1) SizedBox(height: heightDp * 5),
            if (mediaModel.duration! != -1)
              Row(
                children: [
                  Text(
                    "${LocaleKeys.MediaInfoDialogString_duration.tr()} :",
                    style: Theme.of(context).textTheme.caption,
                  ),
                  SizedBox(width: heightDp * 8),
                  Expanded(
                    child: Text(
                      "$durationString seconds",
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                ],
              ),

            ///
            SizedBox(height: heightDp * 5),
            Row(
              children: [
                Text(
                  "${LocaleKeys.MediaInfoDialogString_latitude.tr()} :",
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(width: heightDp * 8),
                Expanded(
                  child: Text(
                    "${mediaModel.latitude}",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),

            ///
            SizedBox(height: heightDp * 5),
            Row(
              children: [
                Text(
                  "${LocaleKeys.MediaInfoDialogString_longitude.tr()} :",
                  style: Theme.of(context).textTheme.caption,
                ),
                SizedBox(width: heightDp * 8),
                Expanded(
                  child: Text(
                    "${mediaModel.longitude}",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),

            ///
            SizedBox(height: heightDp * 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomTextButton(
                  text:
                      LocaleKeys.MediaInfoDialogString_close.tr().toUpperCase(),
                  textStyle: Theme.of(context)
                      .textTheme
                      .button!
                      .copyWith(color: AppColors.yello),
                  // width: widthDp * 120,
                  // bordercolor: AppColors.yello,
                  // borderRadius: heightDp * 6,
                  elevation: 0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
