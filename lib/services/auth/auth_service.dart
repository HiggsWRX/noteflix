import 'package:noteflix/services/auth/auth_provider.dart';
import 'package:noteflix/services/auth/auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider _authProvider;
  const AuthService(this._authProvider);

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      _authProvider.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => _authProvider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      _authProvider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => _authProvider.logOut();

  @override
  Future<void> sendEmailVerification() => _authProvider.sendEmailVerification();
}
