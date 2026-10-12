enum Failure {
  network,
  unauthorized,
  forbidden,
  validation,
  server,
  contract,
  configuration,
  auth,
}

class AppException implements Exception {
  const AppException(this.kind);
  final Failure kind;
  @override
  String toString() => 'AppException(${kind.name})';
}
