import 'package:flutter/material.dart';
import 'package:stickershub/screens/register_page.dart';
import 'package:stickershub/screens/auth_page.dart';
import '../functions/firebase_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailTxtController = TextEditingController();
  final _passwordTxtController = TextEditingController();

  //=== Erreurs des TextFields ===
  String? _errorTextEmail;
  String? _errorTextPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        leading: null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: TextFormField(
                autofillHints: const [AutofillHints.email],
                controller: _emailTxtController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Your e-mail',
                  errorText: _errorTextEmail,
                ),
                onChanged: (_) => setState(() {
                }),
              ),
            ),
            SizedBox(
              width: 300,
              child: TextFormField(
                obscureText: true,
                controller: _passwordTxtController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Your password',
                  errorText: _errorTextPassword,
                ),
                onChanged: (_) => setState(() {
                }),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: const Alignment(0.75, 0.75),
                  child: TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.grey),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/register");
                    },
                    child: const Text("Don't have account ?"),
                  ),
                ),

                Align(
                  alignment: const Alignment(0.75, 0.75),
                  child: TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>((_emailTxtController.text.isNotEmpty ) ? const Color.fromARGB(202, 156, 126, 33) : Colors.grey),
                    ),
                    onPressed: () async {
                      String? result = await resetPassword(
                        _emailTxtController.text);
                      if (result != null) {
                        setState(() {
                          _errorTextEmail = 'Invalid e-mail !';
                        });
                      } else {
                        setState(() {
                          _errorTextEmail = 'Reset e-mail sent !';
                        });
                      }
                    },
                    child: const Text("Forgot password ?"),
                  ),
                ),

              ],
            ),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>((_emailTxtController.text.isNotEmpty && _passwordTxtController.text.isNotEmpty ) ? const Color.fromARGB(202, 156, 126, 33) : Colors.grey)),
                onPressed: () async {
                  try {
                    UserCredential? result = await loginUser(
                        _emailTxtController.text, _passwordTxtController.text);
                    if (result != null) {
                      /*
                      print('User signed in: ${result.user?.email}');
                      print(FirebaseAuth.instance.currentUser);
                      */
                      Navigator.pushReplacementNamed(context, "/auth");
                    } else {
                      setState(() {
                        _errorTextPassword = "Login failed !";
                      });
                    }
                  } catch (error) {
                    setState(() {
                      _errorTextPassword = "";
                      _errorTextEmail = "";
                    });
                    if (error is FirebaseAuthException) {
                      print(error);
                      print(error.code);
                      if (error.code == 'INVALID_LOGIN_CREDENTIALS') {
                        setState(() {
                          _errorTextPassword = 'Bad authentification !';
                        });
                      } else if (error.code == 'user-disabled') {
                        setState(() {
                          _errorTextEmail = 'Account disabled';
                        });
                      } else if (error.code == 'too-many-requests') {
                        setState(() {
                          _errorTextPassword = 'Please try later';
                        });
                      } else if (error.code == 'wrong-password') {
                        setState(() {
                          _errorTextPassword = 'Bad password !';
                        });
                      }
                    } else {
                      // Gérez d'autres erreurs ici
                      print('Error: $error');
                    }
                  }
                },
                child: const Text("Login"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
