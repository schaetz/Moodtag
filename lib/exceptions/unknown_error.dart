import 'user_readable_exception.dart';

class UnknownError implements UserReadableException {

  final String _message;
  final ExceptionSeverity _severity = ExceptionSeverity.HIGH;

  const UnknownError([this._message = ""]);

  String get message => _message;
  ExceptionSeverity get severity => _severity;

  String toString() => "UnknownError: $message";

}