import 'user_readable_exception.dart';

class UnknownError extends UserReadableException {
  static const ExceptionSeverity defaultSeverity = ExceptionSeverity.HIGH;

  const UnknownError(String message, {ExceptionSeverity severity = defaultSeverity, Object? cause})
      : super(message, severity, cause);

  String toString() => "UnknownError: $message";
}
