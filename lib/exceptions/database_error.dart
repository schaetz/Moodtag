import 'package:moodtag/exceptions/user_readable_exception.dart';

class DatabaseError implements UserReadableException {
  final String _message;
  final ExceptionSeverity _severity = ExceptionSeverity.MEDIUM;

  const DatabaseError([this._message = ""]);

  String get message => _message;
  ExceptionSeverity get severity => _severity;

  String toString() => "DatabaseError: $message";
}
