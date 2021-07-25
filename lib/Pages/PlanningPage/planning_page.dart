import 'package:flutter/material.dart';
import 'package:legutus/Models/index.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import 'index.dart';

class PlanningPage extends StatelessWidget {
  final PlanningReportModel? planningReportModel;
  final PersistentTabController? bottomTabController;

  PlanningPage({@required this.planningReportModel, @required this.bottomTabController});

  @override
  Widget build(BuildContext context) {
    return PlanningView(planningReportModel: planningReportModel, bottomTabController: bottomTabController);
  }
}
