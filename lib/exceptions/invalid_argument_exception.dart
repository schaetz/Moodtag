import 'package:moodtag/exceptions/internal_exception.dart';

class InvalidArgumentException implements InternalException {
  final String message;

  const InvalidArgumentException([this.message = ""]);

  String toString() => "InvalidArgumentException: $message";
}
