import 'package:flutter/material.dart';
import 'package:myflutterproject/FriendList/MyProfile/MyProfileBody.dart';
import 'package:myflutterproject/FriendList/MyProfile/MyProfileProvider.dart';
import 'package:provider/provider.dart';

class MyProfile extends StatelessWidget {
  final String loginId;
  final String nickname;
  final String phoneNumber;
  final String statusMSG;
  final ImageProvider? imageProvider;

  const MyProfile({
    Key? key,
    required this.loginId,
    required this.nickname,
    required this.phoneNumber,
    required this.statusMSG,
    this.imageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyProfileProvider(),
      builder: (context, _) {
        return MyProfileBody(
          username: loginId,
          id: loginId,
          name: nickname,
          phoneNumber: phoneNumber,
          statusMSG: statusMSG,
          imageProvider: imageProvider,
        );
      },
    );
  }
}
