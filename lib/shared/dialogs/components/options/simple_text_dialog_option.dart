import 'package:flutter/material.dart';

import '../form/dialog_form.dart';
import 'dialog_option.dart';

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
  bool Function(BuildContext context, DialogFormState?)? validate;

  @override
  Widget get widget => Text(text);

  final String text;

  SimpleTextDialogOption(this.text, this.getDialogResult, {this.validate});
}
