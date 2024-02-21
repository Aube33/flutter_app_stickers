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
void setUserPicture(File file) async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String fileName = 'profile_picture.jpg';
  Reference reference = FirebaseStorage.instance.ref('UsersPicture/$userId/$fileName');

  UploadTask uploadTask = reference.putFile(file);
  TaskSnapshot snapshot = await uploadTask.whenComplete(() => print('File uploaded'));
  String downloadURL = await snapshot.ref.getDownloadURL();
  FirebaseAuth.instance.currentUser?.updatePhotoURL(downloadURL);
  print(downloadURL);
}
//==========

//===== Collection =====
CollectionReference collections = FirebaseFirestore.instance.collection('collections');
/* 
Future<void> addUser() {
  // Call the user's CollectionReference to add a new user
  return collections
      .add({
        'uid': fullName,
        'company': company,
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));
} */
//======================