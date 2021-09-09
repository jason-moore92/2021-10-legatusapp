import 'package:flutter/material.dart';
import 'package:legatus/Models/index.dart';
import 'package:provider/provider.dart';

import 'index.dart';

class NewReportPage extends StatelessWidget {
  final bool? isNew;
  final LocalReportModel? localReportModel;

  NewReportPage({this.isNew = true, this.localReportModel});

  @override
  Widget build(BuildContext context) {
    return NewReportView(isNew: isNew, localReportModel: localReportModel);
  }
}
