import 'package:flutter/material.dart';
import 'package:stickershub/functions/firebase_functions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Home Page'),
        leading: null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Home"),
            const SizedBox(
              width: 300,
            ),
            ElevatedButton(onPressed: () {
              addItemToCollection(2);
            }, child: Text("tes"))
          ],
        ),
      ),
    );
  }
}