import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


//===== UTILISATEURS =====
//===== Basic compte =====
registerUser(email, password, username) async {
  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  setUserDisplayName(username);
  createUserCollection();
  return credential;
}

loginUser(email, password) async {
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password
  );
  return credential;
}

bool isLoggedIn(){
  return FirebaseAuth.instance.currentUser != null;
}

logoutUser() async {
  await FirebaseAuth.instance.signOut();
}

Future<void> deleteAccount(String password) async {
  User? user = FirebaseAuth.instance.currentUser;
  await user!.reauthenticateWithCredential(
    EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    ),
  );

  String userId = FirebaseAuth.instance.currentUser!.uid;

  // Supprime les trades avec l'utilisateur en auteur
  QuerySnapshot<Object?> tradesSnapshot = await tradingCollections.where('author', isEqualTo: userId).get();
  for (QueryDocumentSnapshot<Object?> trade in tradesSnapshot.docs) {
    await tradingCollections.doc(trade.id).delete();
  }

  await userCollections.doc(userId).delete();
  // Supprime la pp de l'utilisateur
  Reference userPictureRef = FirebaseStorage.instance.ref('UsersPicture/$userId');
  try {
    await userPictureRef.getDownloadURL();
    await userPictureRef.delete();
  } catch(e) {
    print('Le fichier de l\'utilisateur n\'existe pas dans Firebase Storage');
  }

  // Supprime le compte Firebase Auth
  await FirebaseAuth.instance.currentUser!.delete();
}

Future<String?> resetPassword(email) async {
  final bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9-]+\.[a-zA-Z]+").hasMatch(email);
  if(emailValid){
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );
      return null;
    } catch (error) {
      return '$error';
    }
  } else {
    await Future.delayed(const Duration(milliseconds: 1));
    return Future.value("Invalid email");
  }
}
//==========

//===== Getters =====
User? getUserData() {
  return FirebaseAuth.instance.currentUser;
}
String? getUserDisplayname(){
  return FirebaseAuth.instance.currentUser?.displayName;
}
String getUserCreatedDate() {
  UserMetadata userData = FirebaseAuth.instance.currentUser!.metadata;
  DateTime creationTime = userData.creationTime!;
  DateFormat dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  String creationTimeString = dateFormat.format(creationTime);
  return creationTimeString;
}
String? getUserPicture(){
  return FirebaseAuth.instance.currentUser?.photoURL;
}

Future<List<Map<String, dynamic>>> getUserStickers() async {
  DocumentSnapshot<Object?> userCollection = await getUserCollection();
  List<Map<String, dynamic>> stickers = [];

  if (userCollection.exists && userCollection.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = userCollection.data() as Map<String, dynamic>;
    List<dynamic> items = List.from(collectionData["collection"] ?? []);
    for (dynamic id in items) {
      if (!stickers.any((sticker) => sticker["id"] == id)) {
        Map<String, dynamic> stickerData = await getStickerFromID(id);
        if (stickerData.isNotEmpty) {
          stickerData["count"]=1;
          stickers.add(stickerData);
        }
      } else {
        int index = stickers.indexWhere((sticker) => sticker["id"] == id);
        stickers[index]["count"] += 1;
      }
    }
  } else {
    print("Data returned is not in the expected format");
  }

  return stickers;
}

Future<List<Map<String, dynamic>>> getUserLootboxs() async{
  DocumentSnapshot<Object?> userCollection = await getUserCollection();
  List<Map<String, dynamic>> lootboxs = [];

  if (userCollection.exists && userCollection.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = userCollection.data() as Map<String, dynamic>;
    List<dynamic> items = List.from(collectionData["lootboxs"] ?? []);
    for(dynamic id in items){
      Map<String, dynamic> stickerData = await getLootboxFromID(id);
      if (stickerData.isNotEmpty){
        lootboxs.add(stickerData);
      }
    }

  } else {
    print("Data returned is not in the expected format");
  }

  return lootboxs;
}

Future<void> removeLootboxFromCollection(int lootboxID) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  DocumentSnapshot<Object?> userCollection = await getUserCollection();

  if (userCollection.exists && userCollection.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = userCollection.data() as Map<String, dynamic>;
    List<dynamic> lootboxs = List.from(collectionData["lootboxs"] ?? []);
    lootboxs.remove(lootboxID);

    return userCollections
      .doc(userId)
      .update({
        'lootboxs': lootboxs
      })
      .then((value) => print("Lootbox removed from collection"))
      .catchError((error) => print("Failed to remove lootbox from user collection: $error"));
  } else {
    print("Data returned is not in the expected format");
  }
}
//==========

//===== Setters =====
void setUserDisplayName(String username){
  FirebaseAuth.instance.currentUser?.updateDisplayName(username);
}
Future<String?> setUserPicture(File file) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String fileName = 'profile_picture.jpg';
  Reference reference = FirebaseStorage.instance.ref('UsersPicture/$userId/$fileName');

  UploadTask uploadTask = reference.putFile(file);
  TaskSnapshot snapshot = await uploadTask.whenComplete(() => print('File uploaded'));
  String downloadURL = await snapshot.ref.getDownloadURL();
  FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadURL);
  return downloadURL;
}
//==========

//===== Stickers =====
CollectionReference stickersCollections = FirebaseFirestore.instance.collection('stickers');

Future<Map<String, dynamic>> getStickerFromID(int id) async {
  DocumentSnapshot<Object?> stickerData = await stickersCollections
    .doc(id.toString())
    .get();

  if (stickerData.exists && stickerData.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = stickerData.data() as Map<String, dynamic>;
    return collectionData;
  } else {
    print("Data returned is not in the expected format");
  }
  return {};
}

Future<List<Map<String, dynamic>>> getAllStickers() async {
  QuerySnapshot<Object?> stickersSnapshot = await stickersCollections.get();

  if (stickersSnapshot.size > 0) {
    List<Map<String, dynamic>> stickers = [];
    for (QueryDocumentSnapshot<Object?> sticker in stickersSnapshot.docs) {
      Map<String, dynamic> stickerData = sticker.data() as Map<String, dynamic>;
      stickers.add(stickerData);
    }
    return stickers;
  } else {
    print("No stickers found");
    return [];
  }
}

Future<int> getUserStickerCount() async {
  DocumentSnapshot<Object?> userCollection = await getUserCollection();
  if (userCollection.exists && userCollection.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = userCollection.data() as Map<String, dynamic>;
    List<dynamic> stickers = List.from(collectionData["collection"]?? []);
    return stickers.length;
  } else {
    return 0;
  }
}

Future<bool> userHasSticker(int stickerID) async {
  DocumentSnapshot<Object?> userCollection = await getUserCollection();

  if (userCollection.exists && userCollection.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = userCollection.data() as Map<String, dynamic>;
    List<dynamic> stickers = List.from(collectionData["collection"]?? []);

    return stickers.contains(stickerID);
  } else {
    return false;
  }
}

Future<List<Map<String, dynamic>>> getRarestStickers() async {
  List<Map<String, dynamic>> userStickers = await getUserStickers();
  if (userStickers.isNotEmpty) {
    userStickers.sort((a, b) => a['rarity'].compareTo(b['rarity']));
    List<Map<String, dynamic>> uniqueStickers = [];
    for (Map<String, dynamic> sticker in userStickers) {
      if (!uniqueStickers.any((element) => element['id'] == sticker['id'])) {
        uniqueStickers.add(sticker);
      }
    }
    for(int i=0; i<uniqueStickers.length; i++) {
      uniqueStickers[i]['count'] = userStickers.where((element) => element['id'] == uniqueStickers[i]['id']).first["count"];
    }
    return uniqueStickers.take(3).toList();
  } else {
    print("Aucun sticker trouvé pour l'utilisateur");
    return [];
  }
}

Future<int> getStickerUserCount(int stickerID) async {
  DocumentSnapshot<Object?> userCollection = await getUserCollection();
  if (userCollection.exists && userCollection.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = userCollection.data() as Map<String, dynamic>;
    List<dynamic> stickers = List.from(collectionData["collection"]?? []);
    int count = 0;
    for (dynamic id in stickers) {
      if (id == stickerID) {
        count++;
      }
    }
    return count;
  } else {
    return 0;
  }
}

Future<Map<String, dynamic>> getStickerDataWithCount(int stickerID) async {
  Map<String, dynamic> stickerData = await getStickerFromID(stickerID);
  int stickerCount = await getStickerUserCount(stickerID);
  stickerData['count'] = stickerCount;
  return stickerData;
}
//==========

//===== Lootbox =====
CollectionReference lootboxsCollections = FirebaseFirestore.instance.collection('lootboxs');

Future<Map<String, dynamic>> getLootboxFromID(int id) async {
  DocumentSnapshot<Object?> lootboxData = await lootboxsCollections
    .doc(id.toString())
    .get();

  if (lootboxData.exists && lootboxData.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = lootboxData.data() as Map<String, dynamic>;
    return collectionData;
  } else {
    print("Data returned is not in the expected format");
  }
  return {};
}

Future<Map<String, dynamic>> openLootbox(int id) async {
  Map<String, dynamic> lootbox = await getLootboxFromID(id);
  if (lootbox.isNotEmpty) {
    double maxRarity = lootbox["maxRarity"].toDouble();
    List<Map<String, dynamic>> allStickers = await getAllStickers();
    List<Map<String, dynamic>> availableStickers = [];

    for (Map<String, dynamic> sticker in allStickers) {
      if (sticker["rarity"] <= maxRarity) {
        availableStickers.add(sticker);
      }
    }

    if (availableStickers.isNotEmpty) {
      double totalWeight = availableStickers.fold(0, (sum, sticker) => sum + (maxRarity - sticker["rarity"]));

      final random = Random();
      double randomPoint = random.nextDouble() * totalWeight;

      double cumulativeWeight = 0;
      for (Map<String, dynamic> sticker in availableStickers) {
        cumulativeWeight += maxRarity.toDouble() - sticker["rarity"];
        if (randomPoint < cumulativeWeight) {
          return sticker;
        }
      }
    }
  }
  return {};
}
//==========


//===== Trading =====
CollectionReference tradingCollections = FirebaseFirestore.instance.collection('trading');

Future<void> createTrade(int id1, int id2) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot<Object?> userCollection = await getUserCollection();

  if (userCollection.exists && userCollection.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = userCollection.data() as Map<String, dynamic>;
    List<dynamic> stickers = List.from(collectionData["collection"]?? []);
    stickers.remove(id1);
    await userCollections.doc(userId).update({
      'collection': stickers
    });
  }

  // Créer le trade
  DocumentReference docRef = await tradingCollections.add({
    'author': userId,
    'offerSticker': id1,
    'wantedSticker': id2,
    'createdAt': FieldValue.serverTimestamp(),
  });

  DocumentSnapshot doc = await docRef.get();
  print("Trade created successfully: ${doc.data()}");
}

Future<void> deleteTrade(String tradeId) async {
  DocumentSnapshot<Object?> tradeData = await tradingCollections.doc(tradeId).get();
  if (tradeData.exists && tradeData.data() is Map<String, dynamic>) {
    Map<String, dynamic> tradeInfo = tradeData.data() as Map<String, dynamic>;
    int offerStickerId = tradeInfo['offerSticker'];
    addItemToCollection(offerStickerId);
  }

  // Supprime le trade
  await tradingCollections.doc(tradeId).delete();
  print("Trade deleted successfully");
}

Future<List<Map<String, dynamic>>> getAllTrades() async {
  QuerySnapshot<Object?> tradesSnapshot = await tradingCollections.get();

  if (tradesSnapshot.size > 0) {
    List<Map<String, dynamic>> trades = [];
    for (QueryDocumentSnapshot<Object?> trade in tradesSnapshot.docs) {
      Map<String, dynamic> tradeData = trade.data() as Map<String, dynamic>;
      String authorUid = tradeData['author'];
      int offerStickerId = tradeData['offerSticker'];
      int wantedStickerId = tradeData['wantedSticker'];
      Timestamp createdAt = tradeData['createdAt'];
      DateTime createDate = createdAt.toDate();

      Map<String, dynamic> offerStickerData = await getStickerFromID(offerStickerId);
      Map<String, dynamic> wantedStickerData = await getStickerFromID(wantedStickerId);

      trades.add({
        'id': trade.id,
        'author': authorUid,
        'offerSticker': offerStickerData,
        'wantedSticker': wantedStickerData,
        'createdAt': createDate
      });
    }

    trades.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

    return trades;
  } else {
    print("No trades found");
    return [];
  }
}

Future<bool> tradeAccept(String tradeId) async {
  DocumentSnapshot<Object?> tradeData = await tradingCollections.doc(tradeId).get();
  if (tradeData.exists && tradeData.data() is Map<String, dynamic>) {
    Map<String, dynamic> tradeInfo = tradeData.data() as Map<String, dynamic>;
    String authorUid = tradeInfo['author'];
    int offerStickerId = tradeInfo['offerSticker'];
    int wantedStickerId = tradeInfo['wantedSticker'];

    DocumentSnapshot<Object?> authorCollection = await userCollections.doc(authorUid).get();
    DocumentSnapshot<Object?> userCollection = await getUserCollection();

    if (authorCollection.exists && authorCollection.data() is Map<String, dynamic> &&
        userCollection.exists && userCollection.data() is Map<String, dynamic>) {
      Map<String, dynamic> authorCollectionData = authorCollection.data() as Map<String, dynamic>;
      Map<String, dynamic> userCollectionData = userCollection.data() as Map<String, dynamic>;

      // Supprime le stickerOffer de la collection de l'auteur
      List<dynamic> authorStickers = List.from(authorCollectionData["collection"]?? []);
      authorStickers.remove(offerStickerId);
      // Ajoute le stickerWanted à la collection de l'auteur
      authorStickers.add(wantedStickerId);

      // Supprime le stickerWanted de la collection de l'utilisateur actuel
      List<dynamic> userStickers = List.from(userCollectionData["collection"]?? []);
      userStickers.remove(wantedStickerId);
      // Ajoute le stickerOffer à la collection de l'utilisateur actuel
      userStickers.add(offerStickerId);

      // Met à jour les collections
      await userCollections.doc(authorUid).update({
        'collection': authorStickers
      });

      await userCollections.doc(FirebaseAuth.instance.currentUser!.uid).update({
        'collection': userStickers
      });
      print("Trade effectué avec succès");
      Future.delayed(const Duration(seconds: 1));
      return true;
    } else {
      print("Erreur lors de la récupération des collections");
    }
  } else {
    print("Erreur lors de la récupération du trade");
  }
  return false;
}
//==========


//===== Collection =====
CollectionReference userCollections = FirebaseFirestore.instance.collection('collections');

Future<void> createUserCollection() {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  return userCollections
    .doc(userId)
    .set({
      'lootboxs': [],
      'coins' : 100,
      'collection': []
    })
    .then((value) => print("User Db Created"))
    .catchError((error) => print("Failed to create user db: $error"));
}

Future<DocumentSnapshot<Object?>> getUserCollection() {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  print(userId);

  return userCollections
    .doc(userId)
    .get();
}

Future<void> addItemToCollection(int stickerID) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  DocumentSnapshot<Object?> userCollection = await getUserCollection();

  if (userCollection.exists && userCollection.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = userCollection.data() as Map<String, dynamic>;
    List<dynamic> collection = List.from(collectionData["collection"] ?? []);
    collection.add(stickerID);

    return userCollections
      .doc(userId)
      .update({
        'collection': collection
      })
      .then((value) => print("Item added to collection"))
      .catchError((error) => print("Failed to add to user collection: $error"));
  } else {
    print("Data returned is not in the expected format");
  }
}

Future<void> addLootboxToCollection(int lootboxID) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  DocumentSnapshot<Object?> userCollection = await getUserCollection();

  if (userCollection.exists && userCollection.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = userCollection.data() as Map<String, dynamic>;
    List<dynamic> lootboxs = List.from(collectionData["lootboxs"] ?? []);
    lootboxs.add(lootboxID);

    return userCollections
      .doc(userId)
      .update({
        'lootboxs': lootboxs
      })
      .then((value) => print("Lootbox added to collection"))
      .catchError((error) => print("Failed to add lootbox to user collection: $error"));
  } else {
    print("Data returned is not in the expected format");
  }
}

//======================