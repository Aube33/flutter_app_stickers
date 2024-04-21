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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Login Page'),
        leading: null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: TextFormField(
                controller: _emailTxtController,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: 'Votre e-mail',
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
                  labelText: 'Votre mot de passe',
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
                      // Navigator.push(MaterialPageRoute(builder: (context)=>const RegisterPage()));
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                    },
                    child: const Text("Je n'ai pas de compte"),
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
                          _errorTextEmail = 'E-mail invalide !';
                        });
                      } else {
                        setState(() {
                          _errorTextEmail = 'E-mail de réinitialisation envoyé !';
                        });
                      }
                    },
                    child: const Text("Mot de passe oublié"),
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
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthCheckPage()));
                    } else {
                      setState(() {
                        _errorTextPassword = "La connexion a échoué !";
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
                          _errorTextPassword = 'Mauvais identifiants';
                        });
                      } else if (error.code == 'user-disabled') {
                        setState(() {
                          _errorTextEmail = 'Compte désactivé';
                        });
                      } else if (error.code == 'too-many-requests') {
                        setState(() {
                          _errorTextPassword = 'Veuillez ressayer plus tard';
                        });
                      } else if (error.code == 'wrong-password') {
                        setState(() {
                          _errorTextPassword = 'Mauvais mot de passe';
                        });
                      }
                    } else {
                      // Gérez d'autres erreurs ici
                      print('Erreur inattendue: $error');
                    }
                  }
                },
                child: const Text("Se connecter"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
