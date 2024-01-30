import 'package:flutter/material.dart';
import 'package:moodtag/shared/dialogs/components/dialog_config.dart';

import '../components/abstract_dialog.dart';

class AddLastFmAccountDialog extends AbstractDialog<String?, DialogConfig<String?>> {
  final String serviceName;

  AddLastFmAccountDialog(BuildContext context, this.serviceName,
      {required Function(String?) handleResult, Function(String?)? onTerminate})
      : super(
            context,
            DialogConfig(
                options: [], // TODO Define options
                onTerminate: onTerminate));
}
