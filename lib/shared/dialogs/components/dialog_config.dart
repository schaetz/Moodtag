import 'form/dialog_form_field.dart';
import 'options/dialog_option.dart';

/**
 *  Configuration for AbstractDialog and dialog classes inheriting from it
 *
 *  R: Result type of the dialog (pass as not nullable - null will be added)
 */
class DialogConfig<R> {
  final String? title;
  final String? subtitle;
  final List<DialogFormField>? formFields;
  final List<DialogOption<R>> options; // The key can be a string (for simpleDialogOptionWithText) or a Widget
  final Function(R?)? onTerminate;

  const DialogConfig({this.title, this.subtitle, this.formFields, required this.options, this.onTerminate});
}
