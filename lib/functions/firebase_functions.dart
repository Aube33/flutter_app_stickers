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

  print(userCollection.data());

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
    return uniqueStickers.take(3).toList(); // Prenez les 3 premiers stickers uniques, qui sont les plus rares
  } else {
    print("Aucun sticker trouvé pour l'utilisateur");
    return [];
  }
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

      for (Map<String, dynamic> sticker in availableStickers) {
        double weight = maxRarity.toDouble() - sticker["rarity"];
        if (randomPoint < weight) {
          return sticker;
        }
        randomPoint -= weight;
      }
    }
  }
  return {};
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