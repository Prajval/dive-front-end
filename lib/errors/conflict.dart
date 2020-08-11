class Conflict implements Exception {
  final String code;

  const Conflict(this.code);

  String toString() => '$code';
}
