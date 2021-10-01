import 'package:flutter/material.dart';

import 'abstract_dialog.dart';

class ExceptionDialog extends AbstractDialog {

  static void openNew(BuildContext context, String exceptionHeadline, String exceptionMessage) {
    new ExceptionDialog(context, exceptionHeadline, exceptionMessage).show();
  }

  String exceptionHeadline;
  String exceptionMessage;

  ExceptionDialog(BuildContext context, this.exceptionHeadline, this.exceptionMessage) : super(context);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    return AlertDialog(
      title: Text(exceptionHeadline),
      content: Text(exceptionMessage),
      actions: <Widget>[
        TextButton(
          onPressed: () => closeDialog(context),
          child: const Text('OK'),
        ),
      ],
    );
  }

}