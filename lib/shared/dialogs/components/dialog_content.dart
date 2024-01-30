import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/components/dialog_config.dart';

import 'form/dialog_form.dart';
import 'options/dialog_option.dart';

/**
 *  Stateful widget containing the actual dialog widget
 *  with its contents and options
 *
 *  R: Result type of the dialog
 *  C: Type of the dialog configuration
 */
class DialogContent<R, C extends DialogConfig<R>> extends StatefulWidget {
  final C config;
  final DialogFormFactory dialogFormFactory;
  final Function(BuildContext context, {R? result}) closeDialog;

  const DialogContent(this.config,
      {super.key, required this.closeDialog, this.dialogFormFactory = const DialogFormFactory()});

  @override
  State<StatefulWidget> createState() => _DialogContentState<R, C>(config, dialogFormFactory);
}

class _DialogContentState<R, C extends DialogConfig<R>> extends State<DialogContent> {
  final C config;
  final DialogFormFactory dialogFormFactory;

  DialogFormState? _currentFormState;

  _DialogContentState(this.config, this.dialogFormFactory);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: config.title != null ? Text(config.title!) : Text(''),
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [buildForm(config), buildDialogOptions(config)]))
      ],
    );
  }

  Widget buildForm(C config) {
    if (config.formFields == null) {
      return Container();
    }
    final formStateCallback = (DialogFormState newFormState) => setState(() {
          _currentFormState = newFormState;
        });
    return dialogFormFactory.createForm(config.formFields!, formStateCallback);
  }

  Widget buildDialogOptions(C config) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: config.options
            .map((option) => Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: SimpleDialogOption(
                  onPressed: option.validate == null || option.validate!(context, _currentFormState)
                      ? () => _onOptionPressed(option)
                      : () => {},
                  child: option.widget,
                )))
            .toList());
  }

  void _onOptionPressed(DialogOption<R> option) {
    final result = option.getDialogResult(context, _currentFormState);
    widget.closeDialog(context, result: result);
  }
}
