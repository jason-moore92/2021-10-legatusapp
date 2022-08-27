import 'package:flutter/material.dart';
import 'package:legatus/Models/index.dart';
import 'package:legatus/Providers/index.dart';
import 'package:provider/provider.dart';

import 'index.dart';

class CameraPage extends StatelessWidget {
  final LocalReportModel? localReportModel;
  final bool? isPicture;
  final bool? isAudio;

  const CameraPage({
    Key? key,
    @required this.localReportModel,
    this.isAudio = false,
    this.isPicture = false,
  }) : super(key: key);

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
