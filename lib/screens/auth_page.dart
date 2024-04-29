import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stickershub/navbar.dart';
import 'package:stickershub/screens/login_page.dart';

class AuthCheckPage extends StatelessWidget {
  const AuthCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
            // L'utilisateur est connecté, affichez la page autorisée
            return const NavBar(position: 2,);
          } else {
            // L'utilisateur n'est pas connecté, affichez la page de connexion
            return const LoginPage();
          }
      },
    );
  }
}
