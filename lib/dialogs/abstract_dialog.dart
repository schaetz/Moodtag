import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class AbstractDialog {

  BuildContext context;

  AbstractDialog(this.context);

  void show() async {
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) => buildDialog(context)
    );
  }

  // Should be protected, but upgrading the meta package to ^1.7.0
  // to be able to use @protected collides with "flutter_test"
  StatelessWidget buildDialog(BuildContext context);

  void closeDialog(BuildContext context) {
    Navigator.pop(context);
  }

}