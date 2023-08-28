import 'package:flutter/material.dart';
import 'package:myflutterproject/User/UserDTO.dart';

class MyCard extends StatelessWidget {
  final UserDto user;
  final ImageProvider<Object>? imageProvider;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckChanged;

  MyCard({
    required this.user,
    this.imageProvider,
    this.onTap,
    this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25.0),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.amber[300],
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage:
                      imageProvider ?? AssetImage('assets/human.jpeg'),
                  backgroundColor: Colors.amber[300],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.nickname} (${user.loginId})',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      user.statusMSG ?? '',
                      style: TextStyle(fontSize: 13),
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
