import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteflix/services/auth/auth_provider.dart';
import 'package:noteflix/services/auth/bloc/auth_event.dart';
import 'package:noteflix/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    on<AuthEventInitialize>((_, emit) async {
      await provider.initialize();
      final user = provider.currentUser;

      if (user == null) {
        emit(const AuthStateUnauthenticated(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateUnverifiedUser());
      } else {
        emit(AuthStateAuthenticated(user));
      }
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();

        emit(const AuthStateUnverifiedUser());
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });

    on<AuthEventSendEmailVerification>((_, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventAuthenticate>((event, emit) async {
      emit(const AuthStateUnauthenticated(
        exception: null,
        isLoading: true,
      ));

      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.logIn(email: email, password: password);

        if (!user.isEmailVerified) {
          emit(const AuthStateUnauthenticated(
            exception: null,
            isLoading: false,
          ));
          emit(const AuthStateUnverifiedUser());
        } else {
          emit(const AuthStateUnauthenticated(
            exception: null,
            isLoading: false,
          ));
          emit(AuthStateAuthenticated(user));
        }
      } on Exception catch (e) {
        emit(AuthStateUnauthenticated(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventUnauthenticate>((_, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateUnauthenticated(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateUnauthenticated(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventShouldRegister>((_, emit) async {
      emit(const AuthStateRegistering(null));
    });
  }
}
