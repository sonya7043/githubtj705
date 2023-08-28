import 'package:flutter/material.dart';
import 'package:myflutterproject/Setting/Body/Calendar.dart';
import 'package:myflutterproject/Setting/Body/StopWatch.dart';
import 'package:myflutterproject/Setting/Body/ThemeSelection.dart';
import 'package:myflutterproject/Setting/UpdateProfile.dart';
import 'package:myflutterproject/User/Login.dart';
import 'package:myflutterproject/User/User.dart';
import 'package:myflutterproject/User/UserProvider.dart';
import 'package:provider/provider.dart';

class Settingmenu extends StatefulWidget {
  const Settingmenu({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  State<Settingmenu> createState() => _SettingmenuState();
}

class _SettingmenuState extends State<Settingmenu> {
  late User user;

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.brown[700],
        title: Text(
          "환경설정",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined),
            onPressed: () {
              userProvider.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Login()),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProfile(
                    loginId: widget.user.loginId,
                    nickname: widget.user.nickname,
                    phoneNumber: widget.user.phoneNumber,
                  ),
                ),
              );
            },
          )
        ],
      ),
      backgroundColor: Colors.amber[100],
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8), // 그림자 색상 및 투명도 조정
                  //spreadRadius: 5, // 그림자 퍼짐 정도 조정
                  //blurRadius: 7, // 그림자의 흐림 정도 조정
                  offset: Offset(13, 13), // 그림자 위치 조정
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.brush,
                size: 50,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ThemeSelection(), // 빈 클래스임! 여기에 연준님 테마 클래스 넣기
                  ),
                );
              },
              padding: EdgeInsets.all(20),
              constraints: BoxConstraints(), // 크기 제약 해제
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: Offset(13, 13),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.calendar_month,
                size: 50,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Calendar(),
                  ),
                );
              },
              padding: EdgeInsets.all(20),
              constraints: BoxConstraints(), // 크기 제약 해제
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: Offset(13, 13),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.timer,
                size: 50,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StopWatch(),
                  ),
                );
              },
              padding: EdgeInsets.all(20),
              constraints: BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}
