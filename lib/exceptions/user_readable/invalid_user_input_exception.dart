import 'user_readable_exception.dart';

class InvalidUserInputException extends UserReadableException {
  static const ExceptionSeverity defaultSeverity = ExceptionSeverity.LOW;

  const InvalidUserInputException(String message, {ExceptionSeverity severity = defaultSeverity, Object? cause})
      : super(message, severity, cause);

  String toString() => "InvalidUserInputException: $message";
}
