import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/dialog_option.dart';

import 'dialog_form.dart';

/**
 *  Represents an option in a dialog that is visually represented by a simple
 *  text widget that can be clicked
 *
 *  R: result type of the dialog
 */
class SimpleTextDialogOption<R> implements DialogOption<R> {
  @override
  R Function(BuildContext context, DialogFormState?) getDialogResult;

  @override
  Widget get widget => Text(text);

  final String text;

  SimpleTextDialogOption(this.text, this.getDialogResult);
}
