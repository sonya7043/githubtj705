import 'package:flutter/material.dart';
import 'package:myflutterproject/Chat/chatingroom.dart';
import 'package:myflutterproject/Chat/chatserver.dart';
import 'package:myflutterproject/FriendList/MainProfile/MainProfileProvider.dart';
import 'package:provider/provider.dart';

class MainProfileBody extends StatelessWidget {
  final String username;
  final String id;
  final String name;
  final String phoneNumber;
  final String statusMSG;
  final ImageProvider? imageProvider;

  const MainProfileBody({
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
    final provider = Provider.of<MainProfileProvider>(context, listen: false);

    if (provider.idController.text.isEmpty) {
      provider.initializeValues(
        id: this.id,
        name: this.name,
        phoneNumber: this.phoneNumber,
        statusMSG: this.statusMSG,
        imageProvider: this.imageProvider,
      );
    }
    final idController = provider.idController;
    final nameController = provider.nameController;
    final phoneController = provider.phoneController;
    final msgController = provider.msgController;
    final permanentImageProvider = provider.permanentImageProvider;

    return Scaffold(
      backgroundColor: Colors.amber[100],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.amber[300],
                backgroundImage: imageProvider ??
                    permanentImageProvider ??
                    AssetImage('assets/human.jpeg'),
                radius: 50,
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Opacity(
            // 투명도를 조절하여 화면에서 안보이게 함
            opacity: 0.0,
            child: Text(
              idController.text,
              style: TextStyle(
                fontSize: 5,
              ),
            ),
          ),
          Text(
            nameController.text,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            msgController.text,
            style: TextStyle(
              fontSize: 15,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            phoneController.text,
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
                onPressed: () async {
                  final titleName =
                      await IntoChatRoom.InsertChatRoom(username, id);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return Chat(
                          sender: username,
                          receiver: id,
                          title: titleName[0],
                          chatMessages: titleName[1]);
                    }),
                  );

                  print("채팅하러가기");
                },
                icon: Icon(Icons.chat),
                iconSize: 30,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[100],
        elevation: 0,
        onPressed: () {
          Navigator.pop(context, {
            'id': idController.text,
            'name': nameController.text,
            'phoneNumber': phoneController.text,
            'statusMSG': msgController.text,
            'imageProvider': permanentImageProvider,
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
  }
}
