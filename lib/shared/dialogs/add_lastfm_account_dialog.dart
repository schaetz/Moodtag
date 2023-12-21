import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:moodtag/shared/widgets/text_input/simple_text_input_dialog_base.dart';

import 'abstract_dialog.dart';

class AddExternalAccountDialog<T> extends AbstractDialog<String> {
  final String serviceName;

  AddExternalAccountDialog(BuildContext context, this.serviceName, {Function(String?)? onTerminate})
      : super(context, onTerminate: onTerminate);

  @override
  Widget buildDialog(BuildContext context) {
    return SimpleTextInputDialogBase(
      message: 'Enter your ${serviceName} account name:',
      confirmationButtonLabel: 'OK',
      onSendInput: (String newAccountName) {
        closeDialog(context, result: newAccountName);
      },
    );
  }
}
