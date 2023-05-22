import 'package:flutter/widgets.dart';

class ChipsRowInfoLabel extends StatelessWidget {
  static const infoLabelStyle = TextStyle(fontSize: 18.0);

  final String infoMessage;

  ChipsRowInfoLabel(this.infoMessage);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(infoMessage, style: infoLabelStyle),
    );
  }
}
