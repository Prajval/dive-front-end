class BadRequest implements Exception {
  final String code;

  const BadRequest(this.code);

  String toString() => '$code';
}
