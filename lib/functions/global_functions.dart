import 'package:flutter/material.dart';

Map<String, dynamic> getStickerRarityData(double rarity) {
  Map<String, dynamic> rarityData = {
    "name": "Common",
    "color": Colors.grey
  };

  if(rarity<=0.7 && rarity>0.4){
    rarityData["name"] = "Uncommon";
    rarityData["color"] = Colors.green;
  } else if(rarity<=0.4 && rarity>0.2){
    rarityData["name"] = "Rare";
    rarityData["color"] = const Color.fromARGB(255, 255, 212, 71);
  } else if(rarity<=0.2 && rarity>0.1){
    rarityData["name"] = "Very Rare";
    rarityData["color"] = Colors.orange[400];
  } else if(rarity<=0.1){
    rarityData["name"] = "Legendary";
    rarityData["color"] = Colors.red;
  }

  return rarityData;
}