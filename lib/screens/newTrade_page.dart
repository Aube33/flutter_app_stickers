import 'package:flutter/material.dart';
import 'package:stickershub/functions/firebase_functions.dart';
import 'package:stickershub/functions/global_functions.dart';

class NewTradePage extends StatefulWidget {
  final int stickerId;

  const NewTradePage({super.key, required this.stickerId});

  @override
  State<NewTradePage> createState() => _NewTradePagePageState();
}

class _NewTradePagePageState extends State<NewTradePage> {
  late Future<Map<String, dynamic>> _stickerFuture;
  late Future<List<Map<String, dynamic>>> _allStickersFuture;
  Map<String, dynamic> selectedSticker = {};

  @override
  void initState() {
    super.initState();
    _stickerFuture = getStickerDataWithCount(widget.stickerId);
    _allStickersFuture = getAllStickers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('New Trade'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _stickerFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> stickerData = snapshot.data!;
            final rarityData = getStickerRarityData(stickerData["rarity"]);
            final selectedRarityData = selectedSticker.isEmpty? {} : getStickerRarityData(selectedSticker["rarity"]);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _allStickersFuture,
                    builder: (context, allStickersSnapshot) {
                      if (allStickersSnapshot.hasData) {
                        List<Map<String, dynamic>> allStickers = allStickersSnapshot.data!;

                        return Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            return allStickers
                            .where((sticker) => sticker['name']
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()))
                            .map((sticker) => sticker['name'] as String)
                            .toList();
                          },
                          onSelected: (String selection) {
                            setState(() {
                              selectedSticker = allStickers.firstWhere((sticker) => sticker['name'] == selection);
                            });
                          },
                          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                            return TextField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Search for a sticker',
                              ),
                            );
                          },
                          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                            return ListView.builder(
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) {
                                String option = options.elementAt(index);
                                Map<String, dynamic> sticker = allStickers.firstWhere((sticker) => sticker['name'] == option);
                                return SizedBox(
                                  width: double.infinity,
                                    child: GestureDetector(
                                      onTap: () {
                                        onSelected(option);
                                      },
                                      child: Row(
                                      children: [
                                        SizedBox(
                                          height: 35, 
                                          child: Image.network(sticker['image']),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            margin: const EdgeInsets.only(right: 50),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.2),
                                              border: Border.all(width: 2, color: Colors.black)
                                            ),
                                            child: Text(
                                              option, 
                                              style: const TextStyle(
                                                fontSize: 20, 
                                                color: Colors.black, 
                                                decoration: TextDecoration.none,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'GoldPlay'
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            );
                          },
                        );
                      } else if (allStickersSnapshot.hasError) {
                        return Text('Error: ${allStickersSnapshot.error}');
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),    
                  const SizedBox(height: 25,),
                  const Divider(),              
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 120,
                            child: Image(image: NetworkImage(stickerData["image"]))
                          ),
                          const SizedBox(width: 10,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Name: ',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  Text(
                                    stickerData['name'],
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                    "x${stickerData['count']?? 0}",
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ],
                              ),
                            ],
                          ), 
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.swap_vert,
                              size: 45,
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          selectedSticker.isEmpty? 
                          Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 3),
                              borderRadius: const BorderRadius.all(Radius.circular(20))
                            ),
                          ) :
                          SizedBox(
                            height: 120,
                            child: Image(
                              image: NetworkImage(selectedSticker["image"]),
                            ),
                          ),
                          const SizedBox(width: 10,),
                          selectedSticker.isEmpty?
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                height: 10,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(Radius.circular(20))
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                height: 10,
                                width: 160,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: const BorderRadius.all(Radius.circular(20))
                                ),
                              ),
                            ],
                          )
                          :Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Name: ',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  Text(
                                    selectedSticker['name'],
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Rarity: ",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                  ),
                                  Text(
                                    selectedRarityData["name"],
                                    style: TextStyle(
                                      color: selectedRarityData["color"],
                                      fontSize: 17
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ), 
                        ],
                      ),
                      const SizedBox(height: 25,),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: selectedSticker.isEmpty? null : () async {
                            await createTrade(stickerData["id"], selectedSticker["id"]);
                            Navigator.pushReplacementNamed(context, "/trading");
                          }, 
                          child: const Text("Create trade")
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}