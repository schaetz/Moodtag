import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:moodtag/shared/exceptions/internal/internal_exception.dart';

import 'dialog_config.dart';

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
  late final C config;

  Future<C>? _getRequiredDataFuture;
  Future<R?>? _showDialogFuture;
  bool _isClosed = false;

  AbstractDialog(this.context, this.config) : _getRequiredDataFuture = null;
  AbstractDialog.withFuture(this.context, {required Future<C> Function(BuildContext) getRequiredData}) {
    _getRequiredDataFuture = getRequiredData(context)
        .then((_config) => this.config = _config)
        .onError((error, stackTrace) => throw InternalException('A dialog could not be displayed.'));
  }

  void show() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _showDialogFuture = showDialog<R>(context: context, builder: (_) => buildDialog(context));
      _showDialogFuture!.whenComplete(() => _isClosed = true);
      if (config.onTerminate != null) {
        _showDialogFuture!.then(config.onTerminate!);
      }
    });
  }

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
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: buildDialogOptions(config)
                  .map((optionWidget) => Padding(padding: const EdgeInsets.only(left: 16.0), child: optionWidget))
                  .toList()),
        )
      ],
    );
  }

  List<Widget> buildDialogOptions(C config) {
    return config.options
        .map((optionObject) => SimpleDialogOption(
              onPressed: () => optionObject.getDialogResult(context),
              child: optionObject.widget,
            ))
        .toList();
  }
}
