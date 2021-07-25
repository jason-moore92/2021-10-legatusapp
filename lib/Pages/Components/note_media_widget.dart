import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Pages/App/Styles/index.dart';
import 'package:legutus/Pages/Dialogs/index.dart';

class NoteMediaWidget extends StatelessWidget {
  final MediaModel? mediaModel;
  final int? totalMediaCount;
  final bool? isSelected;
  final Function? tapHandler;
  final Function? longPressHandler;

  NoteMediaWidget({
    Key? key,
    @required this.mediaModel,
    @required this.totalMediaCount,
    this.isSelected = false,
    @required this.tapHandler,
    @required this.longPressHandler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthDp = ScreenUtil().setWidth(1);
    double heightDp = ScreenUtil().setWidth(1);
    double fontSp = ScreenUtil().setSp(1) / ScreenUtil().textScaleFactor;

    return GestureDetector(
      onTap: () {
        if (tapHandler != null) {
          tapHandler!();
        }
      },
      onLongPress: () {
        if (longPressHandler != null) {
          longPressHandler!();
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: heightDp * 5),
        padding: EdgeInsets.symmetric(horizontal: widthDp * 5, vertical: heightDp * 10),
        decoration: BoxDecoration(
          color: Color(0xFFE7E7E7),
          borderRadius: BorderRadius.circular(heightDp * 6),
          border: Border.all(
            color: isSelected! ? AppColors.yello : Colors.transparent,
            width: isSelected! ? 3 : 0,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: widthDp * 5),
            Icon(
              mediaModel!.state == "uploaded" ? Icons.cloud_done : Icons.cloud_off,
              size: heightDp * 20,
              color: mediaModel!.state == "uploaded" ? AppColors.green : AppColors.red.withOpacity(0.6),
            ),
            SizedBox(width: widthDp * 10),
            Expanded(
              child: Text("${mediaModel!.content!}", style: Theme.of(context).textTheme.bodyText2),
            ),
            GestureDetector(
              onTap: () {
                MediaInfoDialog.show(
                  context,
                  mediaModel: mediaModel,
                  totalMediaCount: totalMediaCount,
                );
              },
              child: Container(
                padding: EdgeInsets.all(heightDp * 5),
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: heightDp * 20,
                      color: Colors.white,
                    ),
                    Icon(
                      Icons.info,
                      size: heightDp * 20,
                      color: AppColors.yello,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
