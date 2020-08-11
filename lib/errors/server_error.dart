class ServerError implements Exception {
  final String code;

  const ServerError(this.code);

  String toString() => '$code';
}
