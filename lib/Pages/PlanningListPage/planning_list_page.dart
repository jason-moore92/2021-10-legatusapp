import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import 'index.dart';

class PlanningListPage extends StatelessWidget {
  final PersistentTabController? bottomTabController;

  PlanningListPage({this.bottomTabController});

  @override
  Widget build(BuildContext context) {
    return PlanningListView(bottomTabController: bottomTabController);
  }
}
