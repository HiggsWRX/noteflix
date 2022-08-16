import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:noteflix/firebase_options.dart';
import 'package:noteflix/views/login_view.dart';
import 'package:noteflix/views/register_view.dart';

void main() {
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
        '/login': (BuildContext context) => const LoginView(),
        '/register': (BuildContext context) => const RegisterView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            // final user = FirebaseAuth.instance.currentUser;
            // final userIsVerified = user?.emailVerified ?? false;

            // if (userIsVerified) {
            //   print('Verified');
            //   return const Text('Done');
            // } else {
            //   return const VerifyEmailView();
            // }
            return const LoginView();
          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
