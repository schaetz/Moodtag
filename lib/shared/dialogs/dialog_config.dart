import 'dialog_option.dart';

/**
 *  Configuration for AbstractDialog and dialog classes inheriting from it
 *
 *  R: Result type of the dialog
 */
class DialogConfig<R> {
  final String? title;
  final List<DialogOption<R>> options; // The key can be a string (for simpleDialogOptionWithText) or a Widget
  final Function(R?)? onTerminate;

  const DialogConfig({this.title, required this.options, this.onTerminate});
}
