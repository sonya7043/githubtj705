import 'package:flutter/material.dart';
import 'package:myflutterproject/FriendList/FriendListProvider.dart';
import 'package:myflutterproject/User/UserProvider.dart';
import 'package:provider/provider.dart';

// 친구추가 클래스
class AddFriend extends StatefulWidget {
  const AddFriend({required this.username, super.key});

  final String username;

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  late BuildContext _context;

  @override
  void initState() {
    super.initState();
    _context = context;
  }

  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(_context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '친구 ID 입력',
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.amber[400])),
              child: Text(
                '친구 추가',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    nameController.text != null) {
                  FriendListProvider(
                          username: user!.loginId,
                          phoneNumber: user!.phoneNumber,
                          nickname: user!.nickname)
                      .addFriend(nameController.text);
                  final friendInfo = {
                    'friendname': nameController.text,
                  };
                  Navigator.pop(context, friendInfo);
                }
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.amber[100],
    );
  }
}
