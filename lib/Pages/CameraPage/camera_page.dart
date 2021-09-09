import 'package:flutter/material.dart';
import 'package:legutus/Models/index.dart';
import 'package:legutus/Providers/index.dart';
import 'package:provider/provider.dart';

import 'index.dart';

class CameraPage extends StatelessWidget {
  final LocalReportModel? localReportModel;
  final bool? isPicture;
  final bool? isAudio;

  CameraPage({@required this.localReportModel, this.isAudio = false, this.isPicture = false});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CameraProvider()),
      ],
      child: CameraView(
        localReportModel: localReportModel,
        isPicture: isPicture,
        isAudio: isAudio,
      ),
    );
  }
}
