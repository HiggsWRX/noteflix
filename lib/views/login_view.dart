import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dart:developer' as devtools show log;

import 'package:noteflix/constants/routes.dart';
import 'package:noteflix/utils/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration:
                  const InputDecoration(hintText: 'Enter your email here'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration:
                  const InputDecoration(hintText: 'Enter your password here'),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final FirebaseAuth auth = FirebaseAuth.instance;

                await auth.signInWithEmailAndPassword(
                  email: _email.text,
                  password: _password.text,
                );

                final user = auth.currentUser;
                final userEmailIsVerified = user?.emailVerified ?? false;

                if (!mounted) return;

                if (userEmailIsVerified) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                }
              } on FirebaseAuthException catch (e) {
                switch (e.code) {
                  case 'user-not-found':
                    await showErrorDialog(
                      context,
                      'User not found',
                    );
                    break;
                  case 'wrong-password':
                    await showErrorDialog(
                      context,
                      'Wrong credentials',
                    );
                    break;
                  case 'invalid-email':
                    await showErrorDialog(
                      context,
                      'Invalid email',
                    );
                    break;
                  default:
                    await showErrorDialog(
                      context,
                      'An unknown error occurred',
                    );
                }
              } catch (e) {
                showErrorDialog(
                  context,
                  'An unknown error occurred',
                );
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Not registered? Click here'),
          )
        ],
      ),
    );
  }
}
