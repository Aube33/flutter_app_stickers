import 'package:flutter/material.dart';
import 'package:stickershub/screens/login_page.dart';
import '../functions/firebase_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stickershub/screens/auth_page.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailTxtController = TextEditingController();
  final _passwordTxtController = TextEditingController();
  final _passwordCheckTxtController = TextEditingController();
  final _usernameTxtController = TextEditingController();

  //=== Erreurs des TextFields ===
  bool passwordsMatch = false;

  String? _errorTextPassword;
  String? _errorTextEmail;
  String? _errorTextUsername;

  String? get _passwordErrorText {
    final password = _passwordTxtController.value.text;

    if (password.length < 6 && password.isNotEmpty) {
      return 'Password toot short (lass than 6 characters)';
    }
    return null;
  }

  String? get _errorTextPasswordCheck {
    final password = _passwordTxtController.value.text;
    final passwordCheck = _passwordCheckTxtController.value.text;

    if (password!=passwordCheck){
      return "Passwords don't match";
    }
    return null;
  }
  //======


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: TextFormField(
                controller: _usernameTxtController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Your name',
                  errorText: _errorTextUsername,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(right: 0), // add padding to adjust icon
                    child: Icon(Icons.person),
                  ),
                ),
              ),
            ),

            SizedBox(
              width: 300,
              child: TextFormField(
                controller: _emailTxtController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Your e-mail',
                  errorText: _errorTextEmail,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(right: 0), // add padding to adjust icon
                    child: Icon(Icons.email),
                  ),
                ),
              ),
            ),

            SizedBox(
              width: 300,
              child: TextFormField(
                obscureText: true,
                controller: _passwordTxtController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Your Password',
                  errorText: _errorTextPassword,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(right: 0), // add padding to adjust icon
                    child: Icon(Icons.password),
                  ),
                ),
                onChanged: (_) => setState(() {
                    _errorTextPassword = _passwordErrorText;
                    passwordsMatch = _passwordCheckTxtController.text == _passwordTxtController.text;
                  }),
              ),
            ),

            SizedBox(
              width: 300,
              child: TextFormField(
                obscureText: true,
                controller: _passwordCheckTxtController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Retype password',
                  errorText: _errorTextPasswordCheck,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(right: 0), // add padding to adjust icon
                    child: Icon(Icons.password),
                  ),
                ),
                onChanged: (_) => setState(() {
                  passwordsMatch = _passwordCheckTxtController.text == _passwordTxtController.text;
                }),
              ),
            ),

            Align(
              alignment: const Alignment(0.75, 0.75),
              child: TextButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  child: const Text("Already have an account"),
                ),
            ),

            SizedBox(
              width: 300,
              child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(passwordsMatch ? const Color.fromARGB(202, 156, 126, 33) : Colors.grey),
                ),
                onPressed: () async {
                  if(passwordsMatch){
                    try {
                      UserCredential? result = await registerUser(_emailTxtController.text, _passwordTxtController.text, _usernameTxtController.text);
                      if (result != null) {
                        Navigator.pushReplacementNamed(context, "/auth");
                      } else {
                        setState(() {
                          _errorTextPassword = "Registration failed !";
                        });
                      }
                    } catch (error) {
                      if (error is FirebaseAuthException) {
                        if(error.code=='weak-password'){
                          setState(() {
                            _errorTextPassword = 'Password too weak';
                          });
                        } else if(error.code=='email-already-in-use'){
                          setState(() {
                            _errorTextEmail='E-mail already used';
                          });
                        } else if(error.code=='invalid-email'){
                          setState(() {
                            _errorTextEmail='Invalid e-mail';
                          });
                        }
                      } else {
                        // Gérez d'autres erreurs ici
                        print('Error: $error');
                      }
                    }
                  }
                },
                child: const Text("Sign up"),
              ),
            )
          ],
        ),
      ),
    );
  }
}