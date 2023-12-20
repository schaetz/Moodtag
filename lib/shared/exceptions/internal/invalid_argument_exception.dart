import 'package:moodtag/shared/exceptions/internal/internal_exception.dart';

class InvalidArgumentException implements InternalException {
  final String message;

  const InvalidArgumentException([this.message = ""]);

  String toString() => "InvalidArgumentException: $message";
}
