import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/core/alert_dialog_config.dart';

import '../form/dialog_form.dart';
import 'dialog_action.dart';

/**
 *  Stateful widget containing the actual dialog widget
 *  with its contents and actions
 *
 *  R: Result type of the dialog
 *  C: Type of the dialog configuration
 */
class AlertDialogContent<R, C extends AlertDialogConfig<R>> extends StatefulWidget {
  final C config;
  final DialogFormFactory dialogFormFactory;
  final Function(BuildContext context, {R? result}) closeDialog;

  const AlertDialogContent(this.config,
      {super.key, required this.closeDialog, this.dialogFormFactory = const DialogFormFactory()});

  @override
  State<StatefulWidget> createState() => _AlertDialogContentState<R, C>(config, dialogFormFactory);
}

class _AlertDialogContentState<R, C extends AlertDialogConfig<R>> extends State<AlertDialogContent> {
  final C config;
  final DialogFormFactory dialogFormFactory;

  DialogFormState? _currentFormState;

  _AlertDialogContentState(this.config, this.dialogFormFactory);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: config.title != null ? Text(config.title!) : Text(''),
      content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [buildSubtitle(), buildForm()]),
      actions: buildDialogActions(),
    );
  }

  Widget buildSubtitle() {
    if (config.subtitle == null) {
      return SizedBox();
    }
    return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(config.subtitle!),
        ));
  }

  Widget buildForm() {
    if (config.formFields == null) {
      return Container();
    }
    final formStateCallback = (DialogFormState newFormState) => setState(() {
          _currentFormState = newFormState;
        });
    return dialogFormFactory.createForm<R>(config.formFields!, formStateCallback, widget.closeDialog);
  }

  List<Widget> buildDialogActions() {
    return config.actions
        .map((action) => Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: TextButton(
              onPressed: action.validate == null || action.validate!(context, _currentFormState)
                  ? () => _onActionPressed(action)
                  : null,
              child: action.getWidget(),
            )))
        .toList();
  }

  void _onActionPressed(DialogAction<R> action) {
    final result = action.getDialogResult(context, _currentFormState);
    widget.closeDialog(context, result: result);
  }
}
