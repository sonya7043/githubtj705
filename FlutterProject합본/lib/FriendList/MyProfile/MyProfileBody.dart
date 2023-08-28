import 'package:flutter/material.dart';
import 'package:myflutterproject/FriendList/MyProfile/MyProfileProvider.dart';
import 'package:provider/provider.dart';

class MyProfileBody extends StatelessWidget {
  final String username;
  final String id;
  final String name;
  final String phoneNumber;
  final String statusMSG;
  final ImageProvider? imageProvider;

  const MyProfileBody({
    Key? key,
    required this.username,
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.statusMSG,
    this.imageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MyProfileProvider>(
      builder: (context, provider, child) {
        if (provider.idController.text.isEmpty && !provider.isEditing) {
          provider.initializeValues(
            id: this.id,
            name: this.name,
            phoneNumber: this.phoneNumber,
            statusMSG: this.statusMSG,
            imageProvider: this.imageProvider,
          );
        }

        return Scaffold(
          backgroundColor: Colors.amber[100],
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.amber[300],
                      backgroundImage: provider.permanentImageProvider ??
                          AssetImage('assets/human.jpeg'),
                      radius: 50,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: provider.isEditing
                          ? IconButton(
                              onPressed: provider.getImage,
                              icon: Icon(Icons.photo_camera),
                              color: Colors.black,
                            )
                          : Container(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Opacity(
                  opacity: 0.0,
                  child: Text(
                    provider.idController.text,
                    style: TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
                provider.isEditing
                    ? TextField(
                        controller: provider.nameController,
                        decoration: InputDecoration(
                          labelText: "이름",
                        ),
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )
                    : Text(
                        provider.nameController.text,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                SizedBox(
                  height: 5,
                ),
                provider.isEditing
                    ? TextField(
                        controller: provider.msgController,
                        decoration: InputDecoration(
                          labelText: "상태메세지",
                        ),
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      )
                    : Text(
                        provider.msgController.text,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                SizedBox(
                  height: 15,
                ),
                provider.isEditing
                    ? TextField(
                        controller: provider.phoneController,
                        decoration: InputDecoration(
                          labelText: "전화번호",
                        ),
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      )
                    : Text(
                        provider.phoneController.text,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.chat),
                      iconSize: 30,
                    ),
                    IconButton(
                      onPressed: () {
                        if (provider.isEditing) {
                          provider.updateUserInfo().then((_) {
                            provider.isEditing = false;
                          });
                        } else {
                          provider.isEditing = true;
                        }
                      },
                      icon: Icon(provider.isEditing ? Icons.check : Icons.edit),
                      iconSize: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.amber[100],
            elevation: 0,
            onPressed: () async {
              await provider.updateUserInfo();
              Navigator.pop(context, {
                'loginId': provider.idController.text,
                'nickname': provider.nameController.text,
                'phoneNumber': provider.phoneController.text,
                'statusMSG': provider.msgController.text,
                'imageUrl': provider.imageUrl,
              });
            },
            child: Icon(
              Icons.close,
              color: Colors.black,
              size: 30,
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        );
      },
    );
  }
}
