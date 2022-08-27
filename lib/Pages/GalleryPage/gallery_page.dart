import 'package:flutter/material.dart';
import 'package:legatus/Models/local_report_model.dart';
import 'package:legatus/Providers/index.dart';
import 'package:provider/provider.dart';

import 'index.dart';

class GalleryPage extends StatelessWidget {
  final LocalReportModel localReportModel;
  final LocalMediaListProvider localMediaListProvider;
  final int index;

  const GalleryPage({
    Key? key,
    required this.localReportModel,
    required this.index,
    required this.localMediaListProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalMediaListProvider()),
      ],
      child: GalleryView(
        localReportModel: localReportModel,
        index: index,
        localMediaListProvider: localMediaListProvider,
      ),
    );
  }
}
