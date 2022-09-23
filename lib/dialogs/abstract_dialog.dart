import 'package:flutter/material.dart';

abstract class AbstractDialog<T> {
  BuildContext context;

  AbstractDialog(this.context);

  Future<T> show() async {
    return await showDialog<T>(context: context, builder: (_) => buildDialog(this.context));
  }

  // Should be protected, but upgrading the meta package to ^1.7.0
  // to be able to use @protected collides with "flutter_test"
  StatelessWidget buildDialog(BuildContext context);

  void closeDialog(BuildContext context, {T result}) {
    Navigator.pop(context, result);
  }
}
