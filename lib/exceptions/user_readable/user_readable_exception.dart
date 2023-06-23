/// Defines interface for exceptions of different degrees of severity
/// that can be displayed to the user without any translation or filtering step
abstract class UserReadableException implements Exception {
  final String _message;
  final ExceptionSeverity _severity;
  final Object? _cause;

  const UserReadableException(this._message, this._severity, this._cause);

  String get message => _message;
  ExceptionSeverity get severity => _severity;
  Object? get cause => _cause;
}

enum ExceptionSeverity { INFO, WARNING, LOW, MEDIUM, HIGH }
