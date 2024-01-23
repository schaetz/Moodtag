import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

abstract class AbstractDialog<T> {
  BuildContext context;
  Function(T?)? onTerminate;

  Future<T?>? _futureResult;
  bool _isClosed = false;

  AbstractDialog(this.context, {Function(T?)? this.onTerminate});

  void show() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _futureResult = showDialog<T>(context: context, builder: (_) => buildDialog(context));
      _futureResult!.whenComplete(() => _isClosed = true);
      if (onTerminate != null) {
        _futureResult!.then(onTerminate!);
      }
    });
  }

  // Should be protected, but upgrading the meta package to ^1.7.0
  // to be able to use @protected collides with "flutter_test"
  Widget buildDialog(BuildContext context);

  void closeDialog(BuildContext context, {T? result}) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isClosed) {
        Navigator.pop(context, result);
        _isClosed = true;
      }
    });
  }
}
