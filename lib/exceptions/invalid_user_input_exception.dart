import 'user_readable_exception.dart';

class InvalidUserInputException implements UserReadableException {
  final String _message;
  final ExceptionSeverity _severity = ExceptionSeverity.LOW;

  const InvalidUserInputException([this._message = ""]);

  String get message => _message;
  ExceptionSeverity get severity => _severity;

  String toString() => "InvalidUserInputException: $message";
}
