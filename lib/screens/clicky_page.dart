import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stickershub/functions/firebase_functions.dart';

class ClickyPage extends StatefulWidget {
  const ClickyPage({super.key});

  @override
  State<ClickyPage> createState() => _ClickyPageState();
}

class _ClickyPageState extends State<ClickyPage> {
  int _clickCount_1 = 0;
  double _progress_1 = 0.0;  

  Future<void> _updateCounters() async {
    setState(() {
      _clickCount_1++;
      _progress_1 = _clickCount_1 / 10;
      if (_progress_1 >= 1.0) {
        _progress_1 = 0.0;
        _clickCount_1 = 0;

        double randomValue = Random().nextDouble();
        int lootboxId = 1;
        if (randomValue<=0.15) {
          addLootboxToCollection(2);
          lootboxId = 2;
        } else if (randomValue<=0.05) {
          addLootboxToCollection(3);
          lootboxId = 3;
        } else {
          addLootboxToCollection(1);
        }
        
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('New Lootbox !', textAlign: TextAlign.center,),
              actions: <Widget>[
                FutureBuilder(
                  future: getLootboxFromID(lootboxId), 
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            '${snapshot.error} occurred',
                            style: const TextStyle(fontSize: 18),
                          ),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                          return Center(
                            child: SizedBox(
                              width: 180,
                              height: 180,
                              child: Image.asset(
                                'assets/lootbox-0.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                      } else if (snapshot.hasData) {
                        Map<String, dynamic> lootbox = snapshot.data!;
                      
                        return Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 150,
                                child: Image(image: NetworkImage(lootbox["image"]))
                              ),
                              Text(lootbox["name"]+ " lootbox")
                            ],
                          ),
                        );
                      } else {
                        return Center(
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: Image.asset(
                              'assets/lootbox-0.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                    } else {
                      return const Center(child: CircularProgressIndicator(),);
                    }
                  }
                ),
                const SizedBox(height: 10,),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        getUserLootboxs();
                      });
                    },
                  ),
                ),
              ],
            );
          },
        );      
      }    
    });
  }

  Future<void> openNewStickerDialog(BuildContext context, Map<String, dynamic> newSticker) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Nouveau Sticker", textAlign: TextAlign.center,),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
                child: Image(image: NetworkImage(newSticker["image"]))
              ),
              Text(newSticker["name"]),
              const SizedBox(height: 10,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                
                    });
                  },
                  child: const Text(
                    "OK",
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clicker'),
        leading: null,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lootboxes:",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(width: 1, color: Colors.black),
                      borderRadius: const BorderRadius.all(Radius.circular(10))
                    ),
                    child: FutureBuilder(
                      future: getUserLootboxs(), 
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                '${snapshot.error} occurred',
                                style: const TextStyle(fontSize: 18),
                              ),
                            );
                          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text("No lootboxes"),
                            );
                          } else if (snapshot.hasData) {
                            final data = snapshot.data;
                            final Map<String, dynamic> lootboxCount = {};
                    
                            // Compter les occurrences
                            for (var lootbox in data!) {
                              final imageUrl = lootbox["image"];
                              if (lootboxCount.containsKey(imageUrl)) {
                                lootboxCount[imageUrl]["counter"] = lootboxCount[imageUrl]["counter"]! + 1;
                              } else {
                                lootbox["counter"]=1;
                                lootboxCount[imageUrl] = lootbox;
                              }
                            }
                    
                            List<Widget> collectionWidget = [];
                    
                            // Ajout des widgets avec le compteur correspondant
                            for (var lootbox in data) {
                    
                              collectionWidget.add(
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(lootbox["name"]+' Lootbox', textAlign: TextAlign.center,),
                                          content: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                height: 150,
                                                child: Image(image: NetworkImage(lootbox["image"]))
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    Map<String, dynamic> newSticker = await openLootbox(lootbox["id"]);
                                                    addItemToCollection(newSticker["id"]);
                                                    removeLootboxFromCollection(lootbox["id"]);
                                                    Navigator.pop(context);
                                                    openNewStickerDialog(context, newSticker);
                                                  },
                                                  style: ElevatedButton.styleFrom(),
                                                  child: const Text(
                                                    "Open",
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: double.infinity,
                                          child: Image(image: NetworkImage(lootbox["image"]))
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: collectionWidget.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 10.0),
                                  child: collectionWidget[index],
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'No lootboxes',
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
                ],
              ),
          
          
          
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.black),
                  borderRadius: const BorderRadius.all(Radius.circular(20))
                ),
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: Image.asset(
                            'assets/lootbox-0.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          height: 10,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                            child: LinearProgressIndicator(
                              value: _progress_1,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                        )
                      ],
                    ),
                    
                    ClickyButton(onTapUp: _updateCounters,)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class ClickyButton extends StatefulWidget {
  final VoidCallback onTapUp;

  const ClickyButton({super.key, required this.onTapUp});

  @override
  _ClickyButtonState createState() => _ClickyButtonState();
}

class _ClickyButtonState extends State<ClickyButton> {
  bool _buttonPressed = false;

  void _onTapDown() {
    HapticFeedback.heavyImpact();
    setState(() {
      _buttonPressed = true;
    });
  }

  void _onTapUp() {
    setState(() {
      _buttonPressed = false;
    });
    widget.onTapUp();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _onTapDown(),
      onTapUp: (details) => _onTapUp(),
      child: SizedBox(
        width: 180,
        height: 180,
        child: Image.asset(
          _buttonPressed? 'assets/button_pressed.png' : 'assets/button.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}