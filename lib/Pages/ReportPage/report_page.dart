import 'package:flutter/material.dart';
import 'package:legatus/Models/local_report_model.dart';
import 'package:legatus/Providers/index.dart';
import 'package:provider/provider.dart';

import 'index.dart';

class ReportPage extends StatelessWidget {
  final LocalReportModel? localReportModel;

  const ReportPage({Key? key, @required this.localReportModel}) : super(key: key);

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
