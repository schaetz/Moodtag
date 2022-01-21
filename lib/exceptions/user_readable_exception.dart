/// Defines interface for exceptions of different degrees of severity
/// that can be displayed to the user without any translation or filtering step
abstract class UserReadableException implements Exception {

  String get message;
  ExceptionSeverity get severity;

}

enum ExceptionSeverity {
  LOW, MEDIUM, HIGH
}