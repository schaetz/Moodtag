import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/dialog_option.dart';

class SimpleTextDialogOption implements DialogOption {
  @override
  Function(BuildContext context) getDialogResult;

  @override
  Widget get widget => Text(text);

  final String text;

  SimpleTextDialogOption(this.text, this.getDialogResult);
}
