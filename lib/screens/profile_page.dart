import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stickershub/functions/global_functions.dart';
import '../functions/firebase_functions.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late ImageProvider<Object> userPicture;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    userPicture = (getUserPicture() != null && getUserPicture()!.isNotEmpty) ? NetworkImage(getUserPicture()!) as ImageProvider<Object> : const AssetImage('assets/default-person.png');
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 2).animate(CurvedAnimation(parent: _flipController, curve: const FlippedCurve(Curves.bounceIn)));
  }

  @override
  Widget build(BuildContext context) {
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
            } else if (value == 'Delete') {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  final passwordController = TextEditingController();

                  return AlertDialog(
                    title: const Text('Delete account'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Are you sure you want to delete your account?'),
                        const SizedBox(height: 13),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Enter your password',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.red)),
                        onPressed: () async {
                          setState(() {
                            _isLoading=true;
                          });
                          String password = passwordController.text;
                          await deleteAccount(password);
                          Navigator.pushReplacementNamed(context, "/login");
                        },
                        child: _isLoading ? 
                        const Center(child: CircularProgressIndicator())
                        : const Text('Confirm'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'Logout',
                child: Text('Logout'),
              ),
              const PopupMenuItem<String>(
                value: 'Delete',
                child: Text('Delete account'),
              ),
            ];
          },
        ),
      ],
    ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                                    final imageUrl = sticker["image"];
                                    final count = sticker["count"] ?? 0;
                                    final rarityData = getStickerRarityData(sticker["rarity"]);

                                    return GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(
                                              builder: (BuildContext context, StateSetter setState) {
                                                return Container(
                                                  height: 350,
                                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        sticker["name"],
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 25,
                                                          fontFamily: 'Goldplay'
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10,),
                                                      GestureDetector(
                                                        onTapDown: (details) {
                                                          _flipController.forward();
                                                        },
                                                        onTapUp: (details) {
                                                          _flipController.reverse();
                                                        },
                                                        onTapCancel: () {
                                                          _flipController.reverse();
                                                        },
                                                        child: SizedBox(
                                                          height: 150,
                                                          child: AnimatedBuilder(
                                                            animation: _flipAnimation,
                                                            child: Image(image: NetworkImage(imageUrl)),
                                                            builder: (context, child) {
                                                              return Transform(
                                                                transform: Matrix4.rotationY(_flipAnimation.value * pi),
                                                                origin: const Offset(150/2, 150/2),
                                                                child: child,
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 15,),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
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
                                                            "x$count",
                                                            style: const TextStyle(fontSize: 17),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                        _flipController.reset();
                                        _flipController.forward();
                                      },
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 100,
                                            width: 100,
                                            child: Image.network(sticker['image'])
                                          ),
                                          Text(sticker['name']),
                                        ],
                                      ),
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