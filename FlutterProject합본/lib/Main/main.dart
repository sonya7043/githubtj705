import 'package:flutter/material.dart';
import 'package:myflutterproject/FriendList/MyProfile/MyProfileProvider.dart';
import 'package:myflutterproject/Main/MyAppMenu.dart';
import 'package:myflutterproject/Setting/Body/CalendarProvider.dart';
import 'package:myflutterproject/User/Login.dart';
import 'package:myflutterproject/User/UserProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MyProfileProvider()),
        ChangeNotifierProvider(create: (_) => CalendarMemo()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My flutter project",
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoggedIn) {
            final user = userProvider.user;
            return user != null ? MyAppMenu() : CircularProgressIndicator();
          } else {
            return Login();
          }
        },
      ),
      color: Colors.amber,
      debugShowCheckedModeBanner: false,
    );
  }
}
