import 'package:moodtag/exceptions/user_readable_exception.dart';

class SpotifyImportException implements UserReadableException {
  final String _message;
  final ExceptionSeverity _severity = ExceptionSeverity.LOW;

  const SpotifyImportException([this._message = '']);

  String get message => _message;
  ExceptionSeverity get severity => _severity;

  String toString() => "SpotifyImportException: $message";
}
