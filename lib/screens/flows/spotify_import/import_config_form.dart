import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ImportConfigForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final headline = Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 0, 0),
          child: Text('Select what should be imported:'),
        ));

    final List<CheckboxListTile> checkboxListTiles = [];

    return Column(
      children: [headline, ...checkboxListTiles],
    );
  }
}
