import 'package:flutter/material.dart';
import 'package:myflutterproject/FriendList/MainProfile/MainProfileBody.dart';
import 'package:myflutterproject/FriendList/MainProfile/MainProfileProvider.dart';
import 'package:provider/provider.dart';

class MainProfile extends StatelessWidget {
  final String username;
  final String id;
  final String name;
  final String phoneNumber;
  final String statusMSG;
  final ImageProvider? imageProvider;

  const MainProfile({
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
    return ChangeNotifierProvider(
      create: (context) => MainProfileProvider(),
      builder: (context, _) {
        return MainProfileBody(
          username: username,
          id: id,
          name: name,
          phoneNumber: phoneNumber,
          statusMSG: statusMSG,
          imageProvider: imageProvider,
        );
      },
    );
  }
}
