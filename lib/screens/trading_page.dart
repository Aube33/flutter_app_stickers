import 'package:flutter/material.dart';
import 'package:stickershub/functions/firebase_functions.dart';
import 'package:stickershub/functions/global_functions.dart';

class TradingPage extends StatefulWidget {
  const TradingPage({super.key});

  @override
  State<TradingPage> createState() => _TradingPageState();
}

enum TradeButtonState { loading, success, error, normal }

class _TradingPageState extends State<TradingPage> {
  late Future<List<Map<String, dynamic>>> _tradesFuture;

  @override
  void initState() {
    super.initState();
    _tradesFuture = getAllTrades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            pinned: false,
            expandedHeight: 100.0,
            flexibleSpace: Center(
              child: Text(
                'Trading',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black, 
                  fontSize: 40.0, 
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Goldplay',
                ),
              ),
            ),
          ),
          FutureBuilder(
            future: _tradesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<Map<String, dynamic>> trades = snapshot.data!;
                if(trades.isEmpty){
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text("No trade for the moment..."),
                    ),
                  );
                }
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      Map<String, dynamic> trade = trades[index];
                      
                      return GestureDetector(
                        onTap: () {
                          if(trade['author']!=getUserData()?.uid){
                            _showTradeModalBottomSheet(context, trade, false);
                          } else {
                            _showTradeModalBottomSheet(context, trade, true);
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: (trade['author']!=getUserData()?.uid)? Colors.black : Colors.grey,
                              width: (trade['author']!=getUserData()?.uid) ? 1 : 3,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Image.network(trade['offerSticker']['image'])
                              ),
                              Text(
                                trade['offerSticker']['name'].length>=15? 
                                  trade['offerSticker']['name'].substring(0, 12) + "..."
                                  :trade['offerSticker']['name'],
                                style: const TextStyle(
                                  fontFamily: 'GoldPlay'
                                ),
                              ),
                              const Icon(Icons.swap_vert),
                              SizedBox(
                                height: 40,
                                child: Image.network(trade['wantedSticker']['image']),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: trades.length,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showTradeModalBottomSheet(BuildContext context, Map<String, dynamic> trade, bool manage) {
    final offerRarityData = getStickerRarityData(trade['offerSticker']["rarity"]);
    final wantedRarityData = getStickerRarityData(trade['wantedSticker']["rarity"]);
  
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          height: 400,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    manage ? "Manage" : "Trade",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'GoldPlay',
                      fontSize: 30
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    height: 100,
                    child: Image(image: NetworkImage(trade['offerSticker']['image']))
                  ),
                  const SizedBox(width: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      manage ? const Row(
                        children: [
                          Text(
                            'From: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            "You",
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ):Container(),
                      Row(
                        children: [
                          const Text(
                            'Name: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            trade['offerSticker']['name'],
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
                            offerRarityData["name"],
                            style: TextStyle(
                              color: offerRarityData["color"],
                              fontSize: 17
                            ),
                          ),
                        ],
                      ),
                    ]
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.swap_vert, size: 35)
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    height: 100,
                    child: Image(image: NetworkImage(trade['wantedSticker']['image']))
                  ),
                  const SizedBox(width: 15,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      !manage ? const Row(
                        children: [
                          Text(
                            'From: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            "You",
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ):Container(),
                      Row(
                        children: [
                          const Text(
                            'Name: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            trade['wantedSticker']['name'],
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
                            wantedRarityData["name"],
                            style: TextStyle(
                              color: wantedRarityData["color"],
                              fontSize: 17
                            ),
                          ),
                        ],
                      ),
                    ]
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: manage ?
                ElevatedButton(
                  onPressed: () async {
                    await deleteTrade(trade["id"]);
                    Navigator.pop(context);
                    setState(() {
                      _tradesFuture=getAllTrades();
                    });
                  },
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.red),
                  ),
                  child: const Text('Delete Trade'),
                )
                : FutureBuilder(
                  future: userHasSticker(trade["wantedSticker"]["id"]),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      bool hasSticker = snapshot.data!;
                      return ElevatedButton(
                        onPressed: hasSticker ? 
                        () async {
                          bool tradeResult = await tradeAccept(trade["id"]);
                          if(tradeResult){
                            await deleteTrade(trade["id"]);
                            Navigator.pop(context);
                            setState(() {
                              _tradesFuture=getAllTrades();
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Trade done !'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Trade error'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }:
                        null,
                        child: const Text('Accept Trade'),
                      );
                    } else {
                      return const ElevatedButton(
                        onPressed: null, 
                        child: Center(child:CircularProgressIndicator())
                      );
                    }
                  }
                )
              ),
            ],
          ),
        );
      },
    );
  }
}