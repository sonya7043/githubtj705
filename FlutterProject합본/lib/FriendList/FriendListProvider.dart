import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:myflutterproject/FriendList/MyProfile/MyProfile.dart';
import 'package:myflutterproject/User/UserDTO.dart';

// 상태변경 메서드 및 변수 호출
class FriendListProvider with ChangeNotifier {
  final String username;
  final String phoneNumber;
  final String nickname;
  final ImageProvider? imageProvider;

  late UserDto user = UserDto();
  List<Map<String, dynamic>> friendList = [];
  String searchKeyword = '';
  TextEditingController nameController = TextEditingController();
  bool showSearchBar = false;
  bool isSearching = false;
  bool showCheckBox = false;
  List<ValueNotifier<bool>> checkList = [];
  ImageProvider? _imageProvider;
  ImageProvider<Object> emptyImageProvider =
      AssetImage('assets/empty_image.png');

  FriendListProvider({
    required this.username,
    required this.phoneNumber,
    required this.nickname,
    this.imageProvider,
  }) {
    _fetchUserDetailAndInit();
  }

  // 친구목록에서 친구검색
  List<dynamic> filterFriendList() {
    return searchKeyword.isEmpty
        ? friendList // 검색 키워드가 없으면 전체 친구목록 반환
        : friendList
            .where((friend) => friend["friendname"]
                .toLowerCase()
                .contains(searchKeyword.toLowerCase())) //친구 이름이 검색키워드를 포함하는지 확인
            .toList(); // 검색결과 반환
  }

  // 검색창 토글
  void toggleSearchBar() {
    showSearchBar = !showSearchBar;
    if (!showSearchBar) {
      searchKeyword = '';
    }
    notifyListeners(); // setState 대신 쓰이는 상태 변경 알림
  }

  // 검색어를 설정하는 메서드
  void setSearchKeyword(String keyword) {
    searchKeyword = keyword;
    notifyListeners();
  }

  // 검색어를 지우는 메서드
  void clearSearch() {
    searchKeyword = '';
    notifyListeners();
  }

  // 체크박스 삭제 토글
  void toggleCheckboxes() {
    showCheckBox = !showCheckBox;
    notifyListeners();
  }

  // 체크 리스트 업데이트
  void updateCheckList(int index, bool? value) {
    checkList[index].value = value ?? false;
    notifyListeners(); // 상태 변경 알림
  }

  // 친구 삭제
  Future<bool> _deleteFriend(String friendname) async {
    bool success = false; // 초기 success값 false로 설정

    if (friendname.isNotEmpty) {
      final body = {
        'username': user.loginId,
        'friendname': friendname,
      };

      //friendname이 있으면 로직 실행
      final deleteResponse = await http.delete(
          Uri.parse("http://10.0.2.2:9000/friend/deletefriend"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(body));

      if (deleteResponse.statusCode == 200) {
        print('친구 삭제 성공: $friendname');
        success = true;
        notifyListeners();
      } else {
        print('친구 삭제에 실패했습니다.');
      }
    } else {
      print('친구 확인에 실패했습니다.');
    }
    return success;
  }

  // 선택한 친구 삭제
  void deleteSelectedFriends() async {
    List<Map<String, dynamic>> selectedFriends = []; // 삭제할 친구 저장할 리스트
    List<Map<String, dynamic>> updatedList = []; // 삭제 후 친구 목록 저장 리스트
    List<ValueNotifier<bool>> updatedCheckList = []; // 삭제 후 체크리스트 저장 리스트

    for (int i = 0; i < friendList.length; i++) {
      // 친구목록의 길이만큼 반복문 돌림
      if (checkList[i].value) {
        // 만약 체크리스트의 i번째 항목이 참이면
        selectedFriends.add(friendList[i]); // 선택된 친구를 selectedFriends에 추가
      } else {
        // 그렇지 않다면
        updatedList.add(friendList[i]); // 해당 친구를 updatedList에 추가
        updatedCheckList.add(checkList[i]); // 체크리스의 i번째 항목 거짓으로 설정
      }
    }

    for (var friend in selectedFriends) {
      // 선택된 친구들을 포문 돌림
      await _deleteFriend(friend["friendname"]); // friendname을 인자로 받아 해당 친구를 삭제
    }

    // 삭제 후 친구목록 업데이트, 화면 리로드
    friendList = updatedList;
    checkList = updatedCheckList;
    notifyListeners();
  }

  // 친구 추가
  void addFriend(String friendname) async {
    if (friendname.isNotEmpty) {
      // friendname이 있으면 로직 실행
      final Map<String, String> body = {
        'username': username,
        'friendname': friendname,
      };

      final addResponse = await http.post(
        Uri.parse("http://10.0.2.2:9000/friend/add"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      if (addResponse.statusCode == 200) {
        print('친구 추가 성공: $friendname');
        await _fetchFriendList(); // 친추 성공시 친구 목록 업데이트
        await refresh();
        Future.delayed(Duration(milliseconds: 200)).then((_) {
          notifyListeners();
        });
        notifyListeners();
      } else {
        print('친구 추가에 실패했습니다.');
      }
    } else {
      print('친구 확인에 실패했습니다.');
    }
  }

  // 친구 목록 호출
  Future<void> refresh() async {
    await _fetchFriendList();
  }

  // 친구 목록
  Future<void> _fetchFriendList() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:9000/friend/list/$username"),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
      responseBody.sort((a, b) => a['friendname'].compareTo(b['friendname']));

      friendList = responseBody.map((item) {
        String friendName = item['friendname'] ?? "Unknown";
        return {
          "friendname": friendName,
          "isChecked": false,
        };
      }).toList();

      checkList =
          List.generate(friendList.length, (_) => ValueNotifier<bool>(false));

      notifyListeners();
    } else {
      print('친구 목록 불러오기에 실패했습니다.');
    }
  }

  // 내 프로필 상세보기 페이지로 가기
  void navigateToMyProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyProfile(
          // MyProfile에 전달해줄 정보 넣기
          nickname: user!.nickname ?? 'nickname',
          phoneNumber: user!.phoneNumber ?? 'phoneNumber',
          loginId: user!.loginId ?? 'loginId',
          statusMSG: user!.statusMSG ?? 'statusMSG',
          imageProvider: _imageProvider,
        ),
      ),
    );

    if (result != null) {
      // 상태 업데이트
      user!.loginId = result['loginId'];
      user!.nickname = result['nickname'];
      user!.phoneNumber = result['phoneNumber'];
      user!.statusMSG = result['statusMSG'];
      notifyListeners();
    }
  }

  // 내 정보 불러오기
  Future<UserDto> fetchUserDetail(String loginId) async {
    final response = await http.get(
      // 이걸로 이름, 전화번호등을 가져옴
      Uri.parse("http://10.0.2.2:9000/user/userdetail/$loginId"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      UserDto user = UserDto.fromJson(responseBody['result']);
      return user;
    } else {
      throw Exception('정보를 가져오지 못했습니다.');
    }
  }

  // 친구정보 불러오기
  void fetchUserDetails(String loginId) async {
    try {
      // 이걸로 친구의 이름, 전화번호 등을 가져옴
      final response = await http
          .get(Uri.parse('http://10.0.2.2:9000/user/userdetail/$loginId'));

      if (response.statusCode == 200) {
      } else {
        throw Exception('정보 로딩 실패');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // 친구 정보 업데이트
  void updateFriend(int index, Map<String, dynamic> updatedFriend) async {
    friendList[index] = updatedFriend;
    notifyListeners(); // 상태 변경 알림
  }

  // 내 이미지 불러오기
  Future<void> _loadProfileImage() async {
    var response = await http.get(
      Uri.parse("http://10.0.2.2:9000/user/userpicinfo/${username}"),
    );

    if (response.statusCode == 200) {
      _imageProvider = MemoryImage(response.bodyBytes);
      notifyListeners();
    } else {
      _imageProvider = null;
      notifyListeners();
    }
  }

// 친구 이미지 불러오기
  Future<ImageProvider> fetchFriendImage(String? friendname) async {
    final response = await http
        .get(Uri.parse('http://10.0.2.2:9000/user/userpicinfo/$friendname'));

    if (response.statusCode == 200) {
      final imageData = response.bodyBytes;
      if (imageData.isEmpty) {
        return AssetImage('assets/human.jpeg');
      }
      return MemoryImage(imageData);
    } else if (response.statusCode == 204) {
      return AssetImage('assets/human.jpeg');
    } else {
      throw Exception("실패");
    }
  }

  // 비동기 작업을 처리하기 위한 메서드
  Future<void> _fetchUserDetailAndInit() async {
    // 현재 사용자의 상세정보를 가져와 user변수에 저장
    user = await fetchUserDetail(username);
    notifyListeners();

    // 친구 목록을 가져오는 비동기 함수를 호출하여 친구 목록을 초기화
    await _fetchFriendList();
    checkList =
        List.generate(friendList.length, (_) => ValueNotifier<bool>(false));
    notifyListeners();

    // 프로필 이미지를 로드
    await _loadProfileImage();
  }

  @override
  void dispose() {
    for (var notifier in checkList) {
      notifier.dispose();
    }
    super.dispose();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
