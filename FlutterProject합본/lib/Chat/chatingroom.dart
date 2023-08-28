import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myflutterproject/Chat/chatserver.dart';

class Chating extends StatefulWidget {
  const Chating({required this.username, Key? key}) : super(key: key);
  final String username; //로그인 한사람

  @override
  State<Chating> createState() => _ChatingState();
}

// 채팅 목록
class _ChatingState extends State<Chating> {
  List<dynamic> responseBody = [];
  List<Map<String, dynamic>> filteredList = []; // 빈리스트로 통신후 값을 list에 넣을 준비

  // 로그인된 사람의 채팅창 목록을 불러옴
  Future<void> FindChatMessage() async {
    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:9000/chat-service/findchatrooms/${widget.username}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      responseBody = jsonDecode(response.body);
      filteredList = responseBody.map<Map<String, dynamic>>((item) {
        //print(responseBody);
        final Map<String, dynamic> filteredItem = {
          'id': item.values.first['id'].toString(),
          'title': item.values.first['title'],
          'username1': item.values.first['username1'],
          'username2': item.values.first['username2'],
        };
        return filteredItem;
      }).toList(); // responseBody가 업데이트된 시점에서 filteredList 초기화
      setState(() {
        filteredList;
      });
    } else {
      print("에러");
      throw Exception("채팅목록이 없습니다.");
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      FindChatMessage();
      new Timer.periodic(Duration(hours: 60), (Timer t) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "채팅",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      backgroundColor: Colors.amber[100],
      body: ListView.separated(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          // 채팅방 입장을 위한 작업
          String sender;
          String receiver;

          if (filteredList[index]['username1'] == widget.username) {
            sender = filteredList[index]['username1'];
            receiver = filteredList[index]['username2'];
          } else {
            sender = filteredList[index]['username2'];
            receiver = filteredList[index]['username1'];
          }

          return InkWell(
            onTap: () async {
              final titleName =
                  await IntoChatRoom.InsertChatRoom(sender, receiver);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  ChatController()
                      .initData(sender, receiver, titleName[0], titleName[1]);

                  return Chat(
                      sender: sender,
                      receiver: receiver,
                      title: titleName[0],
                      chatMessages: titleName[1]);
                }),
              );
            },
            child: GestureDetector(
              onLongPress: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        // 꾹누르면 메뉴나오고 채팅방나가기 구현예정
                        title: Text(receiver),
                      )),
              child: ListTile(
                contentPadding: const EdgeInsets.only(left: 16.0, right: 10.0),
                horizontalTitleGap: 10,
                leading: const Icon(CupertinoIcons.person),
                title: Text(receiver),
                trailing: Container(
                  width: 230,
                  child: Text(
                    "${filteredList[index]['title']}의 대화방",
                    style: const TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const Divider(
            color: Colors.black,
            thickness: 1,
            height: 1,
          );
        },
      ),
    );
  }
}

// 채팅방들어가기위해
// username1 = 로그인한사람
// username2 = 상대방(친구)
// 의 값을 받으며 채팅방제목과, 메시지리스트를 List<dynamic>으로 반환함
class IntoChatRoom {
  static Future<List<dynamic>> InsertChatRoom(
      String username1, String username2) async {
    bool _isLoading = false;
    final url = Uri.parse('http://10.0.2.2:9000/chat-service/enter');
    final dto = {
      "username1": username1,
      "username2": username2,
    };

    try {
      _isLoading = true;
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(dto),
      );
      _isLoading = false;
      if (response.statusCode == 200) {
        print("채팅방 입장/생성이 완료되었습니다.");
        final responseBody = jsonDecode(response.body);
        //print(responseBody);
        final title = responseBody['roomInfo']['title'];
        final messageList = responseBody['messageList'] as List<dynamic>? ?? [];
        print("채팅방제목 : $title");
        return [title, messageList];
      } else {
        print("채팅방 입장/생성에 실패하였습니다.");
        return [];
      }
    } catch (e) {
      _isLoading = false;
      print("에러발생 : $e");
      return [];
    }
  }
}
