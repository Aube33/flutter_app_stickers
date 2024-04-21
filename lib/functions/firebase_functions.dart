import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
String? getUserPicture(){
  return FirebaseAuth.instance.currentUser?.photoURL;
}

Future<List<Map<String, dynamic>>> getUserStickers() async{
  DocumentSnapshot<Object?> userCollection = await getUserCollection();
  List<Map<String, dynamic>> stickers = [];

  if (userCollection.exists && userCollection.data() is Map<String, dynamic>) {
    Map<String, dynamic> collectionData = userCollection.data() as Map<String, dynamic>;
    List<dynamic> items = List.from(collectionData["items"] ?? []);
    for(dynamic id in items){
      Map<String, dynamic> stickerData = await getStickerFromID(id);
      if (stickerData.isNotEmpty){
        stickers.add(stickerData);
      }
    }

  } else {
    print("Data returned is not in the expected format");
  }

  return stickers;
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
//==========

//===== Collection =====
CollectionReference userCollections = FirebaseFirestore.instance.collection('users');

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
      .set({
        'collection': collection
      })
      .then((value) => print("Item added to collection"))
      .catchError((error) => print("Failed to add to user collection: $error"));
  } else {
    print("Data returned is not in the expected format");
  }
}

//======================