import 'dialog_form_field.dart';
import 'dialog_option.dart';

/**
 *  Configuration for AbstractDialog and dialog classes inheriting from it
 *
 *  R: Result type of the dialog
 */
class DialogConfig<R> {
  final String? title;
  final List<DialogFormField>? formFields;
  final List<DialogOption<R>> options; // The key can be a string (for simpleDialogOptionWithText) or a Widget
  final Function(R) handleResult;
  final Function(R?)? onTerminate;

  const DialogConfig(
      {this.title, this.formFields, required this.options, required this.handleResult, this.onTerminate});
}
