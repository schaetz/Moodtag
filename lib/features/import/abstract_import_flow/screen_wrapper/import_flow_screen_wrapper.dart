import 'package:flutter/material.dart';
import 'package:moodtag/shared/widgets/import/scaffold_body_wrapper/scaffold_body_wrapper.dart';

class ImportFlowScreenWrapper extends ScaffoldBodyWrapper {
  static const captionStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  final Widget bodyWidget;
  final double importProgress;
  final String captionText;

  ImportFlowScreenWrapper({required this.bodyWidget, required this.importProgress, required this.captionText})
      : super(bodyWidget: bodyWidget);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
          height: 50,
          child: Stack(
            children: <Widget>[
              SizedBox.expand(
                child: LinearProgressIndicator(
                  value: importProgress,
                  minHeight: 50,
                  semanticsLabel: 'Linear progress indicator',
                ),
              ),
              Center(child: Text(captionText, style: captionStyle)),
            ],
          )),
      Expanded(child: bodyWidget),
    ]);
  }
}
