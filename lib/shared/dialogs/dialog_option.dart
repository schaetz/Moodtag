import 'package:flutter/widgets.dart';
import 'package:moodtag/shared/dialogs/dialog_form.dart';

/**
 *  Represents an option in a dialog that is visually represented by a widget;
 *  clicking the widget should result in calling the attached handler to determine
 *  the result of the dialog
 *
 *  R: result type of the dialog
 */
abstract class DialogOption<R> {
  abstract R Function(BuildContext, DialogFormState?) getDialogResult;
  abstract bool Function(BuildContext, DialogFormState?)? validate;
  Widget get widget;
}
