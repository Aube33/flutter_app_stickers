import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stickershub/screens/auth_page.dart';
import 'package:image_picker/image_picker.dart';
import '../functions/firebase_functions.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late ImageProvider<Object> userPicture;

  @override
  Widget build(BuildContext context) {
    userPicture = (getUserPicture() != null && getUserPicture()!.isNotEmpty) ? NetworkImage(getUserPicture()!) as ImageProvider<Object> : const AssetImage('assets/default-person.png');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Profile Page'),
        leading: null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              XFile? picture = await picker.pickImage(source: ImageSource.gallery);
              if(picture!=null){
                setUserPicture(File(picture.path));
                String? userPictureURL=getUserPicture();
                if(userPictureURL!=null && userPictureURL.isNotEmpty){
                  setState(() {
                    userPicture=NetworkImage(userPictureURL);
                  });
                }
              }
            },
            child: 
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: FadeInImage(
                    placeholder: const AssetImage('assets/default-person.png'),
                    image: userPicture,
                    fadeInDuration: const Duration(milliseconds: 500),
                  ).image,
                ),
              ),
            ),
            
            Text(getUserDisplayname() ?? '<Aucun pseudo>'),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(202, 156, 126, 33)),
                ),
                onPressed: () async {
                  await logoutUser();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthCheckPage()));
                },
                child: const Text("Se déconnecter"),
              ),
            )

          ],
        ),
      ),
    );
  }
}