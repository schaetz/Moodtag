import 'user_readable_exception.dart';

class ExternalServiceQueryException extends UserReadableException {
  static const ExceptionSeverity defaultSeverity = ExceptionSeverity.LOW;

  const ExternalServiceQueryException(String message, {ExceptionSeverity severity = defaultSeverity, Object? cause})
      : super(message, severity, cause);

  String toString() => "ExternalServiceQueryException: $message";
}
