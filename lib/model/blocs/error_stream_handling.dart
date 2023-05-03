import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:moodtag/exceptions/user_readable_exception.dart';

mixin ErrorStreamHandling {
  StreamController<UserReadableException> _errorStreamController = StreamController<UserReadableException>();

  StreamController<UserReadableException> get errorStreamController => _errorStreamController;

  void setupErrorHandler(BuildContext context) {
    final snackbarErrorHandler = _snackbarErrorHandlerFactory(context);
    errorStreamController.stream.listen((exception) => snackbarErrorHandler(exception));
  }

  Function _snackbarErrorHandlerFactory = (context) => (UserReadableException exception) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(exception.message)));
        });
      };
}