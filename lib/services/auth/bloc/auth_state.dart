import 'package:flutter/foundation.dart' show immutable;
import 'package:noteflix/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final AuthUser user;

  const AuthStateAuthenticated(this.user);
}

class AuthStateUnverifiedUser extends AuthState {
  const AuthStateUnverifiedUser();
}

class AuthStateUnauthenticated extends AuthState {
  final Exception? exception;
  const AuthStateUnauthenticated(this.exception);
}
