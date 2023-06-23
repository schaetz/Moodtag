import 'user_readable_exception.dart';

class NameAlreadyTakenException extends UserReadableException {
  static const ExceptionSeverity defaultSeverity = ExceptionSeverity.LOW;

  const NameAlreadyTakenException(String message, {ExceptionSeverity severity = defaultSeverity, Object? cause})
      : super(message, severity, cause);

  String toString() => "NameAlreadyTakenException: $message";
}
