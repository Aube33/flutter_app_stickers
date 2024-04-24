import 'dart:io';

import 'package:flutter/material.dart';
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
  void initState() {
    super.initState();
    userPicture = (getUserPicture() != null && getUserPicture()!.isNotEmpty) ? NetworkImage(getUserPicture()!) as ImageProvider<Object> : const AssetImage('assets/default-person.png');
  }

  @override
  Widget build(BuildContext context) {
    print(getUserData());
    return Scaffold(
    appBar: AppBar(
      title: const Text('Profile'),
      leading: null,
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.settings),
          onSelected: (String value) {
            if (value == 'Logout') {
              logoutUser();
              Navigator.pushReplacementNamed(context, "/login");
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ];
          },
        ),
      ],
    ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle
                        ),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 5),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: -3,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundImage: FadeInImage(
                              placeholder: const AssetImage('assets/default-person.png'),
                              image: userPicture,
                              fadeInDuration: const Duration(milliseconds: 500),
                            ).image,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getUserDisplayname() ?? '<No name>',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Created: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              getUserCreatedDate(),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Collection: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            FutureBuilder(
                              future: getUserStickerCount(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    "${snapshot.data} stickers",
                                  );
                                } else {
                                  return const Text('Loading...');
                                }
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              //Afficher les stickers
              Expanded(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Rarest Stickers:", style: TextStyle(fontWeight: FontWeight.bold),),
                        const SizedBox(height: 10,),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: getRarestStickers(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: snapshot.data!.map<Widget>((sticker) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: Image.network(sticker['image'])
                                        ),
                                        Text(sticker['name']),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            return const Center(child: CircularProgressIndicator());
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}