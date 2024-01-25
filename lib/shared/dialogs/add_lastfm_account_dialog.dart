import 'package:flutter/material.dart';

import 'abstract_dialog.dart';
import 'dialog_config.dart';

class AddLastFmAccountDialog extends AbstractDialog<String?, DialogConfig<String?>> {
  final String serviceName;

  AddLastFmAccountDialog(BuildContext context, this.serviceName,
      {required Function(String?) handleResult, Function(String?)? onTerminate})
      : super(
            context,
            DialogConfig(
                options: [], // TODO Define options
                handleResult: handleResult,
                onTerminate: onTerminate));
}
