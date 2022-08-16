import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'dart:developer' as devtools show log;

import 'package:noteflix/constants/routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text('Register')),
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
                final UserCredential user =
                    await auth.createUserWithEmailAndPassword(
                  email: _email.text,
                  password: _password.text,
                );
                print(user);
              } on FirebaseAuthException catch (e) {
                switch (e.code) {
                  case 'weak-password':
                    devtools.log('The password is too weak.');
                    break;
                  case 'email-already-in-use':
                    devtools.log('The account already exists for that email.');
                    break;
                  case 'invalid-email':
                    devtools.log('The email address is malformed.');
                    break;
                  default:
                }
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false,
              );
            },
            child: const Text('Already registered? Login'),
          ),
        ],
      ),
    );
  }
}
