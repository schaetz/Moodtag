class InvalidArgumentException implements Exception {

  final String message;

  const InvalidArgumentException([this.message = ""]);

  String toString() => "InvalidArgumentException: $message";

}