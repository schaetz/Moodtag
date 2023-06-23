import 'user_readable_exception.dart';

class DatabaseError extends UserReadableException {
  static const ExceptionSeverity defaultSeverity = ExceptionSeverity.MEDIUM;

  const DatabaseError(String message, {ExceptionSeverity severity = defaultSeverity, Object? cause})
      : super(message, severity, cause);

  String toString() => "DatabaseError: $message";
}
