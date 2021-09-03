class NameAlreadyTakenException implements Exception {

  final String message;

  const NameAlreadyTakenException([this.message = ""]);

  String toString() => "NameAlreadyTakenException: $message";

}