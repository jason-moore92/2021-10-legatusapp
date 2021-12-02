import 'package:flutter/material.dart';

import 'index.dart';

class AddEditionPage extends StatelessWidget {
  final List<dynamic>? editions;

  AddEditionPage({@required this.editions});

  @override
  Widget build(BuildContext context) {
    return AddEditionView(editions: editions);
  }
}
