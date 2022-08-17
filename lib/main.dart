import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:noteflix/constants/routes.dart';
import 'package:noteflix/services/auth/auth_service.dart';
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
      home: const HomePage(),
      routes: {
        loginRoute: (BuildContext context) => const LoginView(),
        registerRoute: (BuildContext context) => const RegisterView(),
        notesRoute: (BuildContext context) => const NotesView(),
        createOrUpdateNoteRoute: (BuildContext context) =>
            const CreateUpdateNoteView(),
        verifyEmailRoute: (BuildContext context) => const VerifyEmailView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;

            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
