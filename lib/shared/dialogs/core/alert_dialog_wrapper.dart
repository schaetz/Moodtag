import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logging/logging.dart';

import '../configurations/alert_dialog_config.dart';
import '../form/dialog_form.dart';
import 'alert_dialog_content.dart';

/**
 *  Wrapper for alert dialogs;
 *  takes care of acquiring the required data before building
 *  and using addPostFrameCallback() to display the dialog.
 *
 *  The dialog must either be supplied with a config object or
 *  a getRequiredData() function to asynchronously acquire a config.
 *
 *  R: Result type of the dialog
 *  C: Type of the dialog configuration
 */
class AlertDialogWrapper<R, C extends AlertDialogConfig<R>> {
  static final log = Logger('AlertDialogWrapper');

  static bool isResultTruthy(Object? result) => (result != null &&
      !(result is bool && result == false) &&
      !(result is String && result.isEmpty) &&
      !(result is List && result.isEmpty));

  final BuildContext context;
  late final C config;

  late final Future<C>? _getRequiredDataFuture;
  late final Future<R?>? _showDialogFuture;

  bool _isClosed = false;

  AlertDialogWrapper(this.context, this.config) : _getRequiredDataFuture = null;

  void show({Function(R?)? handleResult, Function(R)? onTruthyResult}) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _showDialogFuture = showDialog<R>(context: context, builder: (_) => buildDialog(context));
      _showDialogFuture!.then((value) => config.formFields.isEmpty
          ? log.fine('Dialog with no form fields successfully opened.')
          : log.fine(
              'Dialog successfully opened with form fields [${config.formFields.map((field) => field.toString()).join('], [')}].'));

      _showDialogFuture!.whenComplete(() => _isClosed = true);
      if (config.onTerminate != null) {
        _showDialogFuture!.then(config.onTerminate!);
      }
      final result = await _showDialogFuture;

      if (handleResult != null) {
        handleResult(result);
      }
      if (onTruthyResult != null && isResultTruthy(result)) {
        onTruthyResult(result as R);
      }
    });
  }

  Widget buildDialog(BuildContext context) {
    return _getRequiredDataFuture == null
        ? AlertDialogContent<R, C>(config, dialogFormFactory: const DialogFormFactory(), closeDialog: this.closeDialog)
        : FutureBuilder(
            future: _getRequiredDataFuture,
            builder: (context, _config) => AlertDialogContent<R, C>(_config.data!,
                dialogFormFactory: const DialogFormFactory(), closeDialog: this.closeDialog));
  }

  void closeDialog(BuildContext context, {R? result}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      log.fine('Dialog closed with result "$result".');
      if (!_isClosed) {
        Navigator.pop(context, result);
        _isClosed = true;
      }
    });
  }
}
