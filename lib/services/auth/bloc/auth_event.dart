import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventAuthenticate extends AuthEvent {
  final String email;
  final String password;

  const AuthEventAuthenticate(this.email, this.password);
}

class AuthEventUnauthenticate extends AuthEvent {
  const AuthEventUnauthenticate();
}