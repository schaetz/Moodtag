import 'package:flutter/widgets.dart';
import 'package:moodtag/shared/dialogs/components/form/dialog_form.dart';

/**
 *  Represents an option in a dialog that is visually represented by a widget;
 *  clicking the widget should result in calling the attached handler to determine
 *  the result of the dialog
 *
 *  R: result type of the dialog (pass as not nullable - null will be added)
 */
class DialogOption<R> {
  static DialogOption<R> getSimpleTextDialogOption<R>(String text,
          {required DialogResultFunction<R> getDialogResult, ValidatorFunction validate}) =>
      DialogOption(getDialogResult: getDialogResult, validate: validate, getWidget: () => Text(text));

  final DialogResultFunction<R> getDialogResult;
  final ValidatorFunction validate;
  final Widget Function() getWidget;

  const DialogOption({required this.getDialogResult, this.validate, required this.getWidget});
}

typedef DialogResultFunction<R> = R? Function(BuildContext, DialogFormState?);
typedef ValidatorFunction = bool Function(BuildContext, DialogFormState?)?;
