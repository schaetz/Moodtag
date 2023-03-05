import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:moodtag/exceptions/user_readable_exception.dart';
import 'package:moodtag/model/blocs/error_stream_bloc.dart';

mixin UserErrorNotifier {
  void subscribeToErrorStream(ErrorStreamBloc bloc, BuildContext context) {
    bloc.errorStreamController.stream.listen((event) {
      _showErrorMessageInSnackbar(context, event);
    });
  }

  void _showErrorMessageInSnackbar(BuildContext context, UserReadableException event) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(event.message)));
    });
  }
}
