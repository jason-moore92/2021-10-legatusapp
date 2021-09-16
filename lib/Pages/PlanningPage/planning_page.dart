import 'package:flutter/material.dart';
import 'package:legatus/Models/index.dart';

import 'index.dart';

class PlanningPage extends StatelessWidget {
  final PlanningReportModel? planningReportModel;

  PlanningPage({@required this.planningReportModel});

  @override
  Widget build(BuildContext context) {
    return PlanningView(planningReportModel: planningReportModel);
  }
}
