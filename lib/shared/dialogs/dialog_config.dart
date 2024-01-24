import 'package:flutter/widgets.dart';

typedef OptionObjectToHandler<T> = Map<Object, T Function(BuildContext)>;

/**
 *  Configuration for AbstractDialog and dialog classes inheriting from it
 *
 *  R: Result type of the dialog
 */
class DialogConfig<R> {
  final String? title;
  final DialogOptionType dialogOptionType;
  final OptionObjectToHandler<R> options; // The key can be a string (for simpleDialogOptionWithText) or a Widget
  final Function(R?)? onTerminate;

  const DialogConfig(
      {this.title,
      this.dialogOptionType = DialogOptionType.simpleDialogOptionWithText,
      required this.options,
      this.onTerminate});
}

enum DialogOptionType { simpleDialogOptionWithText }
