import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:moodtag/shared/dialogs/components/form/dialog_form.dart';

import 'dialog_config.dart';
import 'dialog_content.dart';

/**
 *  Wrapper for all dialogs in the application;
 *  takes care of acquiring the required data before building
 *  and using addPostFrameCallback() to display the dialog.
 *
 *  The dialog must either be supplied with a config object or
 *  a getRequiredData() function to asynchronously acquire a config.
 *
 *  R: Result type of the dialog
 *  C: Type of the dialog configuration
 */
class DialogWrapper<R, C extends DialogConfig<R>> {
  static bool isResultTruthy(Object? result) => (result != null &&
      !(result is bool && result == false) &&
      !(result is String && result.isEmpty) &&
      !(result is List && result.isEmpty));

  final BuildContext context;
  late final C config;

  late final Future<C>? _getRequiredDataFuture;
  late final Future<R?>? _showDialogFuture;

  bool _isClosed = false;

  DialogWrapper(this.context, this.config) : _getRequiredDataFuture = null;

  void show({Function(R)? onTruthyResult}) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _showDialogFuture = showDialog<R>(context: context, builder: (_) => buildDialog(context));
      _showDialogFuture!.whenComplete(() => _isClosed = true);
      if (config.onTerminate != null) {
        _showDialogFuture!.then(config.onTerminate!);
      }
      final result = await _showDialogFuture;
      if (onTruthyResult != null && isResultTruthy(result)) {
        onTruthyResult(result as R);
      }
    });
  }

  Widget buildDialog(BuildContext context) {
    return _getRequiredDataFuture == null
        ? DialogContent<R, C>(config, dialogFormFactory: const DialogFormFactory(), closeDialog: this.closeDialog)
        : FutureBuilder(
            future: _getRequiredDataFuture,
            builder: (context, _config) => DialogContent<R, C>(_config.data!,
                dialogFormFactory: const DialogFormFactory(), closeDialog: this.closeDialog));
  }

  void closeDialog(BuildContext context, {R? result}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isClosed) {
        Navigator.pop(context, result);
        _isClosed = true;
      }
    });
  }
}
