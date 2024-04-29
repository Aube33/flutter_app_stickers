import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stickershub/functions/firebase_functions.dart';
import 'package:stickershub/functions/global_functions.dart';
import 'package:stickershub/screens/newTrade_page.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 2).animate(CurvedAnimation(parent: _flipController, curve: const FlippedCurve(Curves.bounceIn)));
  }


  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collection'),
        leading: null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: getUserStickers(), 
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    '${snapshot.error} occurred',
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isEmpty){
                return const Center(
                  child: Text(
                    'Aucun sticker en stock',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              } else if (snapshot.hasData) {
                final data = snapshot.data;
                List<Widget> collectionWidget = [];

                for (var sticker in data!) {
                  final imageUrl = sticker["image"];
                  final count = sticker["count"] ?? 0;
                  final rarityData = getStickerRarityData(sticker["rarity"]);

                  collectionWidget.add(
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return Container(
                                  height: 400,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        sticker["name"],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          fontFamily: 'Goldplay'
                                        ),
                                      ),
                                      const SizedBox(height: 10,),
                                      GestureDetector(
                                        onTapDown: (details) {
                                          _flipController.forward();
                                        },
                                        onTapUp: (details) {
                                          _flipController.reverse();
                                        },
                                        onTapCancel: () {
                                          _flipController.reverse();
                                        },
                                        child: SizedBox(
                                          height: 150,
                                          child: AnimatedBuilder(
                                            animation: _flipAnimation,
                                            child: Image(image: NetworkImage(imageUrl)),
                                            builder: (context, child) {
                                              return Transform(
                                                transform: Matrix4.rotationY(_flipAnimation.value * pi),
                                                origin: const Offset(150/2, 150/2),
                                                child: child,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Rarity: ",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                          ),
                                          Text(
                                            rarityData["name"],
                                            style: TextStyle(
                                              color: rarityData["color"],
                                              fontSize: 17
                                            ),
                                          ),
                                        ],
                                      ),       
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Quantity: ",
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                          ),
                                          Text(
                                            "x$count",
                                            style: const TextStyle(fontSize: 17),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => NewTradePage(stickerId: sticker["id"])),
                                            );
                                          }, 
                                          child: const Text("Trade")
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                        _flipController.reset();
                        _flipController.forward();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: rarityData["color"], width: 2),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: double.infinity,
                                child: Image(image: NetworkImage(imageUrl))
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(color: rarityData["color"],
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                              ),
                              child: Text(
                                "x$count",
                                style: const TextStyle(color: Colors.white),
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                  ),
                  itemCount: collectionWidget.length,
                  itemBuilder: (BuildContext context, int index) {
                    return collectionWidget[index];
                  },
                );
              } else {
                return const Center(
                  child: Text(
                    'Aucun sticker en stock',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }
        ),
      ),
    );
  }
}