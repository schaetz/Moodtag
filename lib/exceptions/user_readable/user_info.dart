import 'user_readable_exception.dart';

class UserInfo extends UserReadableException {
  static const ExceptionSeverity defaultSeverity = ExceptionSeverity.INFO;

  const UserInfo(String message, {ExceptionSeverity severity = defaultSeverity, Object? cause})
      : super(message, severity, cause);

  String toString() => "UserInfo: $message";
}
