class SessionUser {
  const SessionUser(this.id, this.email);
  final String id;
  final String? email;
}

abstract interface class AuthRepository {
  Stream<SessionUser?> watch();
  Future<void> login(String email, String password);
  Future<void> register(String email, String password);
  Future<void> resetPassword(String email);
  Future<void> logout();
  Future<String?> token({bool refresh = false});
}
