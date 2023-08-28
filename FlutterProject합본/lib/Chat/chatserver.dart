import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:image_picker/image_picker.dart';

class ChatController {
  late String username1;
  late String username2;
  late String title;
  List<dynamic> chatMessages = [];

  // 메시지 입력
  TextEditingController textEditingController = TextEditingController();
  List<dynamic> _chatMessages = [];
  late StompClient _stompClient;

  void initData(String username1, String username2, String title,
      List<dynamic> chatMessages) {
    this.username1 = username1;
    this.username2 = username2;
    this.title = title;
    this.chatMessages = chatMessages;
  }

  void onInit(Function(dynamic) updateChatMessages) {
    _chatMessages = chatMessages;
    _connectToWebSocket(updateChatMessages);
  }

  void _connectToWebSocket(Function(dynamic) updateChatMessages) async {
    String webSocketUrl = 'ws://10.0.2.2:9000/wsstomp';
    StompConfig stompConfig = StompConfig(
      url: webSocketUrl,
      onConnect: (StompFrame frame) {
        print('WebSocket 연결이 성공하였습니다.');
        _stompClient.subscribe(
          destination: "/sub",
          callback: (frame) {
            var message = jsonDecode(frame.body!);
            chatMessages.add(message);
            updateChatMessages(message);
          },
        );
      },
      onWebSocketError: (dynamic error) {
        print('WebSocket 오류: $error');
      },
      onDisconnect: (frame) {
        print('WebSocket 연결이 종료되었습니다.');
      },
    );

    _stompClient = StompClient(config: stompConfig);
    _stompClient.activate();
  }

  void sendMessage(Function(dynamic) updateChatMessages) {
    String message = textEditingController.text.trim();
    if (message.isNotEmpty) {
      Map<String, dynamic> newMessage = {
        'roomTitle': title,
        'sendAt': DateTime.now().toIso8601String(),
        'sender': username1,
        'receiver': username2,
        'message': message,
      };
      //chatMessages.add(newMessage);
      textEditingController.clear();
      _sendToServer(newMessage, updateChatMessages);
    }
  }

  void _sendToServer(
      Map<String, dynamic> message, Function(dynamic) updateChatMessages) {
    var frame = StompFrame(
      command: 'SEND',
      body: jsonEncode(message),
    );

    _stompClient.send(
      destination: '/pub/sendmessage',
      body: frame.body,
      headers: {'Content-Type': 'application/json'},
    );
    updateChatMessages(message);
  }
}

class Chat extends StatefulWidget {
  final String sender;
  final String receiver;
  final String title;
  final List<dynamic> chatMessages;

  Chat({
    required this.sender,
    required this.receiver,
    required this.title,
    required this.chatMessages,
  });

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late ChatController c;

  @override
  void initState() {
    super.initState();
    if(mounted){
      c = ChatController();
      c.initData(
        widget.sender,
        widget.receiver,
        widget.title,
        widget.chatMessages,
      );
      c.onInit(updateChatMessages);
    }
  }

  void updateChatMessages(dynamic message) {
    setState(() {
      bool isDuplicate = widget.chatMessages.contains(message);
      if (!isDuplicate) {
        widget.chatMessages.add(message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    File _image;
    final picker = ImagePicker();
    Future getImage(ImageSource imageSource) async {
      final pickedFile = await picker.getImage(source: imageSource);

      setState(() {
        _image = File(pickedFile.toString());
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("${widget.title}의 대화방"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.chatMessages.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> message = widget.chatMessages[index];
                bool isMe = message['sender'] == widget.sender;
                print(message);
                return Bubble(
                  message: message['message'],
                  sender: message['sender'],
                  receiver: message['receiver'],
                  isMe: isMe,
                );
              },
            ),
          ),
          Divider(
            height: 2,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ListTile(
                                leading: Icon(Icons.camera),
                                title: Text("카메라"),
                                onTap: () {
                                  getImage(ImageSource.camera);
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.picture_as_pdf),
                                title: Text("갤러리"),
                                onTap: () {
                                  getImage(ImageSource.gallery);
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.map_outlined),
                                title: Text("지도"),
                                onTap: () {
                                  // 구글지도 예정
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.add),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextField(
                      controller: c.textEditingController,
                      decoration:
                          InputDecoration.collapsed(hintText: "메시지를 입력해주세요"),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    c.sendMessage(updateChatMessages);
                  },
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.brown,
    );
  }
}

class Bubble extends StatelessWidget {
  final String message;
  final String sender;
  final String receiver;
  final bool isMe;

  const Bubble({
    required this.message,
    required this.sender,
    required this.receiver,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isMe ? Colors.yellow : Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //if (!isMe) Text(receiver),
            Text(
              message,
              style: TextStyle(
                fontSize: 20,
                color: isMe ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
