import 'dart:async';

import '../domain/auth_repository.dart';

/// Explicitly enabled local test session. Never a Firebase session.
class MockAuthRepository implements AuthRepository {
  final _changes = StreamController<SessionUser?>.broadcast();
  SessionUser? _user;
  @override
  Stream<SessionUser?> watch() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  Future<void> login(String email, String password) async {
    _user = SessionUser('mock:${email.trim()}', email.trim());
    _changes.add(_user);
  }

  @override
  Future<void> register(String email, String password) =>
      login(email, password);
  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> logout() async {
    _user = null;
    _changes.add(null);
  }

  @override
  Future<String?> token({bool refresh = false}) async =>
      _user == null ? null : 'local-mock-token';
  void dispose() => _changes.close();
}
