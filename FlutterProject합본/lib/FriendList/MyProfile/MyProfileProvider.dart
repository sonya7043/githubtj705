import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class MyProfileProvider with ChangeNotifier {
  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController msgController;
  ImageProvider? _imageProvider;
  ImageProvider? permanentImageProvider;

  bool _isEditing = false;

  bool get isEditing => _isEditing;

  set isEditing(bool newValue) {
    _isEditing = newValue;
    notifyListeners();
  }

  File? _selectedImage;
  String imageUrl = "";

  MyProfileProvider() {
    idController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    msgController = TextEditingController();
  }

  void initializeValues({
    required String id,
    required String name,
    required String phoneNumber,
    required String statusMSG,
    required ImageProvider? imageProvider,
  }) {
    idController.text = id;
    nameController.text = name;
    phoneController.text = phoneNumber;
    msgController.text = statusMSG;
    _imageProvider = imageProvider;
    permanentImageProvider = imageProvider;
    notifyListeners();
  }

  // 프로필 이미지 로딩
  Future<void> loadProfileImage() async {
    _imageProvider = await _getImage();
    permanentImageProvider = _imageProvider;
    notifyListeners();
  }

  // 이미지 불러오기
  Future<ImageProvider> _getImage() async {
    var response = await http.get(Uri.parse(
        "http://10.0.2.2:9000/user/userpicinfo/${idController.text}"));
    return Image.memory(response.bodyBytes).image;
  }

  // 이미지 선택 및 불러오기
  Future getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final _selectedImage = File(pickedFile.path);
      _imageProvider = FileImage(_selectedImage);
      permanentImageProvider = _imageProvider;
      notifyListeners();

      String imageUrl = await _uploadImage(_selectedImage);

      if (imageUrl.isNotEmpty) {
        this.imageUrl = imageUrl;
        print("이미지성공");
        notifyListeners();
      }
    } else {
      print('이미지가 선택되지 않았습니다.');
    }
  }

  Future<String> _uploadImage(File image) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse("http://10.0.2.2:9000/user/update"),
    );

    var fileStream = http.ByteStream(Stream.castFrom(image.openRead()));
    var length = await image.length();
    var multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: image.path.split('/').last,
    );

    request.files.add(multipartFile);
    request.fields['loginId'] = idController.text;

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      var responseData = jsonDecode(responseString);
      return responseData['result'].toString();
    } else {
      throw Exception("이미지 업로드 실패");
    }
  }

  // 정보 업데이트
  Future<void> updateUserInfo() async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse("http://10.0.2.2:9000/user/update"),
    );

    request.fields['loginId'] = idController.text;
    request.fields['nickname'] = nameController.text;
    request.fields['phoneNumber'] = phoneController.text;
    request.fields['statusMSG'] = msgController.text;

    if (_selectedImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          _selectedImage!.path,
        ),
      );
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('업데이트 성공');
      // 이미지를 다시 불러옴
      _imageProvider = await _getImage();
      permanentImageProvider = _imageProvider;
      notifyListeners();
      _selectedImage = null;
    } else {
      print('업데이트 실패');
    }
  }

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    phoneController.dispose();
    msgController.dispose();
    super.dispose();
  }
}