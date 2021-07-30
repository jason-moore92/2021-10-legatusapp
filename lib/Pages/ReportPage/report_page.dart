import 'package:flutter/material.dart';
import 'package:legutus/Models/local_report_model.dart';
import 'package:legutus/Providers/index.dart';
import 'package:provider/provider.dart';

import 'index.dart';

class ReportPage extends StatelessWidget {
  final LocalReportModel? localReportModel;

  ReportPage({@required this.localReportModel});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalMediaListProvider()),
        ChangeNotifierProvider(create: (_) => LocalReportProvider()),
      ],
      child: ReportView(localReportModel: localReportModel),
    );
  }
}
