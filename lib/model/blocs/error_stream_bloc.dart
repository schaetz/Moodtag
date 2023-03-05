import 'dart:async';

import 'package:moodtag/exceptions/user_readable_exception.dart';

abstract class ErrorStreamBloc {
  StreamController<UserReadableException> get errorStreamController;
}
