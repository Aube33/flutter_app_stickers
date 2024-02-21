import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stickershub/screens/auth_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StickersHub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 179, 183, 58)),
        useMaterial3: true,
      ),
      home: AuthCheckPage(),
    );
  }
}