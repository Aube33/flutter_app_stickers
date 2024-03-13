import 'dart:io';
import 'dart:js_interop';

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

//===== Collection =====
CollectionReference collections = FirebaseFirestore.instance.collection('collections');

Future<void> createUserCollection() {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  return collections
    .doc(userId)
    .set({
      'items': []
    })
    .then((value) => print("User Collection Created"))
    .catchError((error) => print("Failed to create user collection: $error"));
}

Future<DocumentSnapshot<Object?>> getUserCollection() {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  return collections
    .doc(userId)
    .get();
}

Future<void> addItemToCollection(int stickerID) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  DocumentSnapshot<Object?> userCollection = await getUserCollection();
  //print(userCollection.data().runtimeType);
  return collections
    .doc(userId)
    .set({
      'items': []//userCollection.data()?["items"].add(stickerID)
    })
    .then((value) => print("User Collection Created"))
    .catchError((error) => print("Failed to create user collection: $error"));
}
//======================