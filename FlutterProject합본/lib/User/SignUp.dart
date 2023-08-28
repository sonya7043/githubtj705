import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myflutterproject/User/Login.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String _id = ""; // 입력받은 아이디 저장할 변수
  String _name = "";
  String _pass = "";
  String _phone = "";

  bool _isLoading = false;

  TextEditingController _idController =
      TextEditingController(); // 아이디 입력할 텍스트 필드 컨트롤러
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  late FocusNode idFocusNode;

  @override
  void initState() {
    super.initState();

    idFocusNode = FocusNode();
    idFocusNode.addListener(() {
      if (!idFocusNode.hasFocus) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('아이디는 추후 변경이 불가하니 신중하게 입력해주세요!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red[600],
          ),
        );
      }
    });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(idFocusNode);
    });
  }

  @override
  void dispose() {
    idFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[300],
      appBar: AppBar(
        backgroundColor: Colors.amber[300],
        elevation: 0,
        title: Text(
          "회원가입",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _idController,
                focusNode: idFocusNode,
                decoration: InputDecoration(
                  labelText: "아이디",
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(fontSize: 20),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "이름",
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(fontSize: 20),
              ),
              TextField(
                controller: _passController,
                decoration: InputDecoration(
                  labelText: "비밀번호",
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(fontSize: 20),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "전화번호",
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: _insert,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  primary: Colors.brown,
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    "입력완료",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(
                height: 320,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text(
                  "이미 회원이신가요? 로그인 페이지로",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _insert() async {
    setState(() {
      _isLoading = true; // 로딩 상태임을 표시
      _id = _idController.text; // 입력받은 아이디 변수에 저장
      _name = _nameController.text;
      _pass = _passController.text;
      _phone = _phoneController.text;
    });

    String url = "http://10.0.2.2:9000/user/create"; // 회원가입 엔드포인트 url

    Map<String, String> body = {
      "loginId": _id,
      "nickname": _name,
      "password": _pass,
      "phoneNumber": _phone,
    };

    final response = await http.post(Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body));

    try {
      if (response.statusCode ~/ 100 != 2) {
        // 응답 코드가 200번대 아니면 오류처리
        throw Exception('${response.statusCode}');
      }

      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

      if (data['result'] is String) {
        // 회원가입 결과가 문자열인 경우 오류처리
        throw Exception('회원가입 실패: ${data['result']}');
      }

      print("회원가입 성공");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("회원가입 성공"),
          duration: Duration(seconds: 3), // 스낵바 3초 뒤 사라짐
          backgroundColor: Colors.black87,
        ),
      );

      String name = _nameController.text;
      String phone = _phoneController.text;

      _idController.clear();
      _nameController.clear();
      _passController.clear();
      _phoneController.clear();

      Navigator.pushReplacement(
        // 회원가입 성공 후 로그인 페이지로 이동
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (e) {
      print("회원가입 실패");
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("회원가입 실패: " + e.toString()),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; //로딩 상태 표시 해제
      });
    }
  }
}
