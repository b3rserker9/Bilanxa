import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/config.dart';
import '../../../core/error/app_exception.dart';
import '../domain/auth_repository.dart';
import 'mock_auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this.auth);
  final FirebaseAuth auth;
  @override
  Stream<SessionUser?> watch() => auth.authStateChanges().map(
    (u) => u == null ? null : SessionUser(u.uid, u.email),
  );
  Future<void> _call(Future<Object?> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException {
      throw const AppException(Failure.auth);
    }
  }

  @override
  Future<void> login(String email, String password) => _call(
    () => auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );
  @override
  Future<void> register(String email, String password) => _call(
    () => auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ),
  );
  @override
  Future<void> resetPassword(String email) =>
      _call(() => auth.sendPasswordResetEmail(email: email.trim()));
  @override
  Future<void> logout() => _call(auth.signOut);
  @override
  Future<String?> token({bool refresh = false}) =>
      auth.currentUser?.getIdToken(refresh) ?? Future.value();
}

class UnconfiguredAuthRepository implements AuthRepository {
  @override
  Stream<SessionUser?> watch() => Stream.value(null);
  @override
  Future<void> login(String email, String password) async =>
      throw const AppException(Failure.configuration);
  @override
  Future<void> register(String email, String password) =>
      login(email, password);
  @override
  Future<void> resetPassword(String email) => login(email, '');
  @override
  Future<void> logout() async {}
  @override
  Future<String?> token({bool refresh = false}) async => null;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(setupErrorProvider) != null) {
    return UnconfiguredAuthRepository();
  }
  if (Config.mockAuth && Config.mocksAllowed) {
    final repository = MockAuthRepository();
    ref.onDispose(repository.dispose);
    return repository;
  }
  return FirebaseAuthRepository(FirebaseAuth.instance);
});
final sessionProvider = StreamProvider<SessionUser?>(
  (ref) => ref.watch(authRepositoryProvider).watch(),
);
