import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:moodtag/shared/dialogs/dialog_form.dart';
import 'package:moodtag/shared/exceptions/internal/internal_exception.dart';

import 'dialog_config.dart';
import 'dialog_option.dart';

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
abstract class AbstractDialog<R, C extends DialogConfig<R>> {
  final BuildContext context;
  final DialogFormFactory dialogFormFactory;
  late final C config;

  late final Future<C>? _getRequiredDataFuture;
  late final Future<R?>? _showDialogFuture;

  DialogFormState? _currentFormState;
  bool _isClosed = false;

  AbstractDialog(this.context, this.config, {this.dialogFormFactory = const DialogFormFactory()})
      : _getRequiredDataFuture = null;
  AbstractDialog.withFuture(this.context,
      {this.dialogFormFactory = const DialogFormFactory(), required Future<C> Function(BuildContext) getRequiredData}) {
    _getRequiredDataFuture = getRequiredData(context).then((_config) {
      this.config = _config;
      return _config;
    }).onError((error, stackTrace) => throw InternalException('A dialog could not be displayed.'));
  }

  void show({Function(R)? onTruthyResult}) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _showDialogFuture = showDialog<R>(context: context, builder: (_) => buildDialog(context));
      _showDialogFuture!.whenComplete(() => _isClosed = true);
      if (config.onTerminate != null) {
        _showDialogFuture!.then(config.onTerminate!);
      }
      final result = await _showDialogFuture;
      if (onTruthyResult != null && _isResultTruthy(result)) {
        onTruthyResult(result as R);
      }
    });
  }

  bool _isResultTruthy(R? result) =>
      (result != null && !(result is bool && result == false) && !(result is String && result.isEmpty));

  Widget buildDialog(BuildContext context) {
    return _getRequiredDataFuture == null
        ? buildDialogContent(context)
        : FutureBuilder(future: _getRequiredDataFuture, builder: (context, _config) => buildDialogContent(context));
  }

  void closeDialog(BuildContext context, {R? result}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isClosed) {
        Navigator.pop(context, result);
        _isClosed = true;
      }
    });
  }

  StatelessWidget buildDialogContent(BuildContext context) {
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

  Widget buildForm(
    C config,
  ) {
    if (config.formFields == null) {
      return Container();
    }
    final formStateCallback = (DialogFormState newFormState) => _currentFormState = newFormState;
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
                  onPressed: () => _onOptionPressed(option),
                  child: option.widget,
                )))
            .toList());
  }

  void _onOptionPressed(DialogOption<R> option) {
    final result = option.getDialogResult(context, _currentFormState);
    closeDialog(context, result: result);
  }
}
