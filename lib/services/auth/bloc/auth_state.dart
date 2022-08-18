import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:noteflix/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering(this.exception);
}

class AuthStateAuthenticated extends AuthState {
  final AuthUser user;

  const AuthStateAuthenticated(this.user);
}

class AuthStateUnverifiedUser extends AuthState {
  const AuthStateUnverifiedUser();
}

class AuthStateUnauthenticated extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;
  const AuthStateUnauthenticated({
    required this.exception,
    required this.isLoading,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}
