import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateProfile extends StatefulWidget {
  final String loginId;
  final String nickname;
  final String phoneNumber;

  UpdateProfile({
    Key? key,
    required this.loginId,
    required this.nickname,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  late String loginId;
  late String nickname;
  late String phoneNumber;
  late TextEditingController nameController;
  late TextEditingController idController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    loginId = widget.loginId;
    nickname = widget.nickname;
    phoneNumber = widget.phoneNumber;
    idController = TextEditingController(text: widget.loginId);
    nameController = TextEditingController(text: "");
    phoneController = TextEditingController(text: "");
  }

  @override
  void dispose() {
    nameController.dispose();
    idController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // 정보 업데이트
  Future<void> updateUserInfo() async {
    // 빈 문자열이 있는지 확인
    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('입력되지 않은 정보가 있습니다.'),
          backgroundColor: Colors.red[700],
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse("http://10.0.2.2:9000/user/update"),
      );

      request.fields['loginId'] = idController.text;
      request.fields['nickname'] = nameController.text;
      request.fields['phoneNumber'] = phoneController.text;

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('업데이트 성공'),
            backgroundColor: Colors.blue[600],
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('업데이트 실패');
      }
    } catch (e) {
      print('에러 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.brown[700],
        title: Text('내 정보 수정'),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: idController,
              decoration: InputDecoration(labelText: '아이디'),
              enabled: false,
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: '전화번호'),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: updateUserInfo,
              style: ElevatedButton.styleFrom(primary: Colors.deepPurple[300]),
              child: Text(
                '수정 완료',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
