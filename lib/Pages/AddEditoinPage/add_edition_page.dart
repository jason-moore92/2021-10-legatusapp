import 'package:flutter/material.dart';

import 'index.dart';

class AddEditionPage extends StatelessWidget {
  final List<dynamic>? editions;

  const AddEditionPage({Key? key, @required this.editions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AddEditionView(editions: editions);
  }
}
