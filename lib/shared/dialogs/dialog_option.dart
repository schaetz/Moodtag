import 'package:flutter/widgets.dart';

/**
 *  Represents an option in a dialog that is visually represented by a widget;
 *  clicking the widget should result in calling the attached handler to determine
 *  the result of the dialog
 *
 *  R: result type of the dialog
 */
abstract class DialogOption<R> {
  abstract R Function(BuildContext) getDialogResult;
  Widget get widget;
}
