import 'package:flutter/material.dart';

void showExceptionDialog(BuildContext context, String exceptionHeadline, String exceptionMessage) {
  showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(exceptionHeadline),
        content: Text(exceptionMessage),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'OK'),
            child: const Text('OK'),
          ),
        ],
      )
  );
}