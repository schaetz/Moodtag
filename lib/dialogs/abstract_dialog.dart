import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

abstract class AbstractDialog<T> {
  BuildContext context;

  AbstractDialog(this.context, {Function(T?)? onTerminate}) {
    this._onTerminate = onTerminate;
    show();
  }

  Future<T?>? _futureResult;
  Function(T?)? _onTerminate;
  bool _isClosed = false;

  void show() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _futureResult = showDialog<T>(context: context, builder: (_) => buildDialog(this.context));
      if (_onTerminate != null) {
        _futureResult!.then(_onTerminate!).whenComplete(() => _isClosed = true);
      }
    });
  }

  // Should be protected, but upgrading the meta package to ^1.7.0
  // to be able to use @protected collides with "flutter_test"
  StatelessWidget buildDialog(BuildContext context);

  void closeDialog(BuildContext context, {T? result}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isClosed) {
        Navigator.pop(context, result);
        _isClosed = true;
      }
    });
  }
}
