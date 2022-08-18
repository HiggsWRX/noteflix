import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteflix/services/auth/auth_provider.dart';
import 'package:noteflix/services/auth/bloc/auth_event.dart';
import 'package:noteflix/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateUninitialized(isLoading: true)) {
    on<AuthEventInitialize>((_, emit) async {
      await provider.initialize();
      final user = provider.currentUser;

      if (user == null) {
        emit(const AuthStateUnauthenticated(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateUnverifiedUser(isLoading: false));
      } else {
        emit(AuthStateAuthenticated(user: user, isLoading: false));
      }
    });

    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();

        emit(const AuthStateUnverifiedUser(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });

    on<AuthEventSendEmailVerification>((_, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventAuthenticate>((event, emit) async {
      emit(const AuthStateUnauthenticated(
          exception: null, isLoading: true, loadingText: 'Logging you in...'));

      final email = event.email;
      final password = event.password;

      try {
        final user = await provider.logIn(email: email, password: password);

        if (!user.isEmailVerified) {
          emit(const AuthStateUnauthenticated(
            exception: null,
            isLoading: false,
          ));
          emit(const AuthStateUnverifiedUser(isLoading: false));
        } else {
          emit(const AuthStateUnauthenticated(
            exception: null,
            isLoading: false,
          ));
          emit(AuthStateAuthenticated(user: user, isLoading: false));
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
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });

    on<AuthEventForgotPassword>((event, emit) async {
      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: false,
      ));

      final email = event.email;

      if (email == null) {
        return;
      }

      emit(const AuthStateForgotPassword(
        exception: null,
        hasSentEmail: false,
        isLoading: true,
      ));

      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(email: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }

      emit(AuthStateForgotPassword(
        exception: exception,
        hasSentEmail: didSendEmail,
        isLoading: false,
      ));
    });
  }
}
