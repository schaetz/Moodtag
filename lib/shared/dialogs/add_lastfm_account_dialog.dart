import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/simple_text_input_dialog_base.dart';

import 'abstract_dialog.dart';
import 'dialog_config.dart';

class AddLastFmAccountDialog extends AbstractDialog<String, DialogConfig<String>> {
  final String serviceName;

  AddLastFmAccountDialog(BuildContext context, this.serviceName, {Function(String?)? onTerminate})
      : super(
            context,
            DialogConfig(
                options: [], // TODO Define options
                onTerminate: onTerminate));

  @override
  Widget buildDialog(BuildContext context) {
    return SimpleTextInputDialogBase(
        message: 'Enter your ${serviceName} account name:',
        confirmationButtonLabel: 'OK',
        onSendInput: (String newAccountName) => closeDialog(context, result: newAccountName));
  }
}
