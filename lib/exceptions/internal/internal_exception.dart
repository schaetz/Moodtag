class InternalException implements Exception {
  final String message;

  const InternalException([this.message = ""]);

  String toString() => "InternalException: $message";
}
