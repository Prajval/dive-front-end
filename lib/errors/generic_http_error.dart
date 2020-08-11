class GenericError implements Exception {
  final String code;

  const GenericError(this.code);

  String toString() => '$code';
}
