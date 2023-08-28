import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

class MainProfileProvider with ChangeNotifier {
  late TextEditingController idController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController msgController;
  ImageProvider? _imageProvider;
  ImageProvider? permanentImageProvider;

  MainProfileProvider() {
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

  Future<void> loadProfileImage() async {
    _imageProvider = await _getImage();
    permanentImageProvider = _imageProvider;
    notifyListeners();
  }

  Future<ImageProvider> _getImage() async {
    try {
      var response = await http.get(Uri.parse(
          "http://10.0.2.2:9000/user/userpicinfo/${idController.text}"));
      if (response.statusCode == 200) {
        final isValid = await _isValidImage(response.bodyBytes);
        if (isValid) {
          return Image.memory(response.bodyBytes).image;
        } else {
          throw Exception("이미지 데이터가 유효하지 않습니다.");
        }
      } else {
        throw Exception("이미지 로딩 실패");
      }
    } catch (e) {
      print('저장된 이미지가 없습니다.');
      return AssetImage('assets/human.jpeg');
    }
  }

  // 이미지 유효성 검사
  Future<bool> _isValidImage(Uint8List data) async {
    try {
      final codec = await instantiateImageCodec(data);
      return codec != null;
    } catch (_) {
      return false;
    }
  }

  // 이미지 선택 및 불러오기
  Future getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final _selectedImage = File(pickedFile.path);
      _imageProvider = FileImage(_selectedImage!);
      permanentImageProvider = _imageProvider;
      notifyListeners();
      String imageUrl = await _uploadImage(_selectedImage);
      await loadProfileImage();
      notifyListeners();
    } else {
      print('이미지가 선택되지 않았습니다.');
    }
  }

  // 이미지 업로드
  Future<String> _uploadImage(File image) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse("http://10.0.2.2:9000/imagefile/upload"));
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      var responseString = await response.stream.bytesToString();
      var responseData = jsonDecode(responseString);
      return responseData['result'].toString();
    } else {
      throw Exception("이미지 업로드 실패");
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
