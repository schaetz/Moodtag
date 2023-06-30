import 'package:flutter/material.dart';

class ImportFlowScreenWrapper extends StatelessWidget {
  Widget childScreen;
  double importProgress;

  ImportFlowScreenWrapper({required this.childScreen, required this.importProgress}) {
    print(this.importProgress);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      LinearProgressIndicator(
        value: importProgress,
        minHeight: 50,
        semanticsLabel: 'Linear progress indicator',
      ),
      Expanded(child: childScreen),
    ]);
  }
}
