import 'package:flutter/material.dart';
import 'package:noteflix/constants/routes.dart';
import 'package:noteflix/services/auth/auth_exceptions.dart';
import 'package:noteflix/services/auth/auth_service.dart';
import 'package:noteflix/utils/show_error_dialog.dart';

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
                await AuthService.firebase().createUser(
                  email: _email.text,
                  password: _password.text,
                );

                await AuthService.firebase().sendEmailVerification();

                if (!mounted) return;

                Navigator.of(context).pushNamed(
                  verifyEmailRoute,
                );
              } on WeakPasswordAuthException {
                await showErrorDialog(
                  context,
                  'The password is too weak.',
                );
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(
                  context,
                  'The account already exists for that email.',
                );
              } on InvalidEmailAuthException {
                await showErrorDialog(
                  context,
                  'The email address is malformed.',
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'An unknown error occurred.',
                );
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
            child: const Text('Already registered? Login here.'),
          ),
        ],
      ),
    );
  }
}
