import 'package:flutter/material.dart';
import 'package:legatus/Models/index.dart';

import 'index.dart';

class PlanningPage extends StatelessWidget {
  final PlanningReportModel? planningReportModel;

  const PlanningPage({Key? key, @required this.planningReportModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlanningView(planningReportModel: planningReportModel);
  }
}
