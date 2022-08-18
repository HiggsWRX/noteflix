import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteflix/services/auth/auth_provider.dart';
import 'package:noteflix/services/auth/bloc/auth_event.dart';
import 'package:noteflix/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInitialize>((_, emit) async {
      await provider.initialize();
      final user = provider.currentUser;

      if (user == null) {
        emit(const AuthStateUnauthenticated(null));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateUnverifiedUser());
      } else {
        emit(AuthStateAuthenticated(user));
      }
    });

    on<AuthEventAuthenticate>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.logIn(email: email, password: password);
        emit(AuthStateAuthenticated(user));
      } on Exception catch (e) {
        emit(AuthStateUnauthenticated(e));
      }
    });

    on<AuthEventUnauthenticate>((_, emit) async {
      try {
        emit(const AuthStateLoading());
        await provider.logOut();
        emit(const AuthStateUnauthenticated(null));
      } on Exception catch (e) {
        emit(AuthStateUnauthenticated(e));
      }
    });
  }
}
