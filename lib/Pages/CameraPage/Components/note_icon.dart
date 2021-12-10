import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Pages/App/index.dart';
import 'package:legatus/Pages/Dialogs/index.dart';
import 'package:legatus/Providers/CameraProvider/camera_provider.dart';
import 'package:legatus/Providers/index.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:provider/provider.dart';

class NoteIcon extends StatelessWidget {
  final LocalReportModel? localReportModel;
  final NativeDeviceOrientation? orientation;
  final Function(String)? noteHandler;

  const NoteIcon({
    Key? key,
    @required this.localReportModel,
    @required this.orientation,
    @required this.noteHandler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double widthDp = ScreenUtil().setWidth(1);
    double heightDp = ScreenUtil().setWidth(1);

    return Consumer<CameraProvider>(builder: (context, cameraProvider, _) {
      double angle = 0;
      if (orientation == NativeDeviceOrientation.portraitUp || orientation == NativeDeviceOrientation.portraitUp) {
        angle = 0;
      } else if (orientation == NativeDeviceOrientation.landscapeLeft) {
        angle = pi / 2;
      } else if (orientation == NativeDeviceOrientation.landscapeRight) {
        angle = -pi / 2;
      }

      int notesCount = 0;

      for (var i = 0; i < localReportModel!.medias!.length; i++) {
        switch (localReportModel!.medias![i].type) {
          case MediaType.note:
            notesCount++;
            break;
          default:
        }
      }

      bool enable = (!cameraProvider.cameraState.isAudioRecord! && !cameraProvider.cameraState.isVideoRecord!);

      return Transform.rotate(
        angle: angle,
        child: Stack(
          children: [
            IconButton(
              icon: Image.asset(
                "lib/Assets/Images/edit_note.png",
                width: heightDp * 30,
                height: heightDp * 30,
                color: enable ? Colors.white : Colors.white.withOpacity(0.6),
              ),
              iconSize: heightDp * 30,
              onPressed: enable
                  ? () async {
                      var note = await NotePanelDialog.show(context, isNew: true, topMargin: heightDp * 40);
                      if (note != null) {
                        noteHandler!(note);
                      }
                    }
                  : null,
            ),
            Positioned(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: widthDp * 3, vertical: heightDp * 3),
                    decoration: BoxDecoration(
                      color: AppColors.yello,
                      borderRadius: BorderRadius.circular(heightDp * 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$notesCount",
                      style: Theme.of(context).textTheme.overline!.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
