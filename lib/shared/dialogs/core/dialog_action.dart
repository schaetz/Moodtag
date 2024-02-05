import 'package:flutter/widgets.dart';

import '../form/dialog_form.dart';

/**
 *  Represents an action in a dialog that is visually represented by a widget;
 *  clicking the widget should result in calling the attached handler to determine
 *  the result of the dialog
 *
 *  R: result type of the dialog (pass as not nullable - null will be added)
 */
class DialogAction<R> {
  final String text;
  final DialogResultFunction<R> getDialogResult;
  final ValidatorFunction validate;

  const DialogAction(this.text, {required this.getDialogResult, this.validate});
}

typedef DialogResultFunction<R> = R? Function(BuildContext, DialogFormState?);
typedef ValidatorFunction = bool Function(BuildContext, DialogFormState?)?;
