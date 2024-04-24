import 'package:flutter/material.dart';
import 'package:stickershub/functions/firebase_functions.dart';

class NotFoundPage extends StatefulWidget {
  const NotFoundPage({super.key});

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Found'),
        leading: null,
      ),
      body: const Center(
        child: Text(
          "Not found :/"
        )
      ),
    );
  }
}