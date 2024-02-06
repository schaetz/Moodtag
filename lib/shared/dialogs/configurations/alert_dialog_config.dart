import '../core/dialog_action.dart';
import '../form/fields/dialog_form_field.dart';

/**
 *  Configuration for AlertDialogWrapper
 *
 *  R: Result type of the dialog (pass as not nullable - null will be added)
 */
class AlertDialogConfig<R> {
  final String? title;
  final String? subtitle;
  final List<DialogFormField> formFields;
  final List<DialogAction<R>> actions; // The key can be a string (for simpleDialogActionWithText) or a Widget
  final Function(R?)? onTerminate;

  AlertDialogConfig(this.title, this.subtitle, this.formFields, this.actions, this.onTerminate);
}
