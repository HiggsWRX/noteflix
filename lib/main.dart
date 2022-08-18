import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:noteflix/constants/routes.dart';
import 'package:noteflix/services/auth/bloc/auth_bloc.dart';
import 'package:noteflix/services/auth/bloc/auth_event.dart';
import 'package:noteflix/services/auth/bloc/auth_state.dart';
import 'package:noteflix/services/auth/firebase_auth_provider.dart';
import 'package:noteflix/views/login_view.dart';
import 'package:noteflix/views/notes/create_update_note_view.dart';
import 'package:noteflix/views/notes/notes_view.dart';
import 'package:noteflix/views/register_view.dart';
import 'package:noteflix/views/verify_email_view.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

Future<void> main() async {
  if (kDebugMode) {
    await dotenv.load(fileName: '.env');
  } else {
    await dotenv.load(fileName: ".env.prod");
  }

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppWrapper());
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdateNoteRoute: (BuildContext context) =>
            const CreateUpdateNoteView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthStateAuthenticated) {
        return const NotesView();
      } else if (state is AuthStateUnverifiedUser) {
        return const VerifyEmailView();
      } else if (state is AuthStateUnauthenticated) {
        return const LoginView();
      } else if (state is AuthStateRegistering) {
        return const RegisterView();
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    });
  }
}
