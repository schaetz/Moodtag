import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:moodtag/components/simple_text_input_dialog_base.dart';

import 'abstract_dialog.dart';

class AddLastFmAccountDialog<T> extends AbstractDialog<String> {
  AddLastFmAccountDialog(BuildContext context) : super(context);

  @override
  StatelessWidget buildDialog(BuildContext context) {
    return SimpleTextInputDialogBase(
      message: 'Enter your Last.fm account name:',
      confirmationButtonLabel: 'OK',
      onSendInput: (String newAccountName) {
        closeDialog(context, result: newAccountName);
      },
    );
  }
}
