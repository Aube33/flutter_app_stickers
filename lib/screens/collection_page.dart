import 'package:flutter/material.dart';
import 'package:stickershub/functions/firebase_functions.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getUserCollection();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Collection Page'),
        leading: null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Collection"),
            const SizedBox(
              width: 300,
            ),
            ElevatedButton(
              onPressed: () {
                addItemToCollection(1);
              }, 
              child: Text("Debug sticker"))
          ],
        ),
      ),
    );
  }
}