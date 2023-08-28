import 'package:flutter/material.dart';
import 'package:myflutterproject/FriendList/FriendCard.dart';
import 'package:myflutterproject/FriendList/MyCard.dart';
import 'package:myflutterproject/FriendList/FriendListProvider.dart';
import 'package:myflutterproject/FriendList/MainProfile/MainProfile.dart';
import 'package:myflutterproject/User/UserDTO.dart';
import 'package:provider/provider.dart';

class FriendListBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FriendListProvider>(
      builder: (context, friendListProvider, _) {
        final friendList = friendListProvider.friendList;

        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              // 터치 이벤트 처리.onTap 감지
              InkWell(
                onTap: () => friendListProvider.navigateToMyProfile(context),
                // 비동기적으로 현재 사용자의 프로필 이미지에 대한 ImageProvider를 가져옴
                child: FutureBuilder<ImageProvider>(
                  future: friendListProvider
                      .fetchFriendImage(friendListProvider.user.loginId),
                  builder: (BuildContext context,
                      AsyncSnapshot<ImageProvider> imageSnapshot) {
                    // 만약 로딩중이라면
                    if (imageSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      // 돌아가는 동그라미 반환
                      return CircularProgressIndicator();
                      // 그렇지 않다면
                    } else {
                      // 내 카드 반환
                      return MyCard(
                        user: friendListProvider.user,
                        imageProvider: imageSnapshot.data ??
                            AssetImage('assets/human.jpeg'),
                      );
                    }
                  },
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // 구분선
              Divider(
                color: Colors.grey[800],
              ),
              Expanded(
                child: ListView.builder(
                  // friendList의 길이
                  itemCount: friendList.length,
                  // 각 항목 생성
                  itemBuilder: (context, index) {
                    // 만약 검색 키워드가 비어있지 않고 목록에 검색한 키워드가 없는 경우
                    if (friendListProvider.searchKeyword.isNotEmpty &&
                        !friendListProvider.friendList[index]["friendname"]
                            .contains(friendListProvider.searchKeyword)) {
                      // SizedBox를 반환하여 빈 공간 생성
                      return SizedBox();
                    }
                    // 각 항목의 사용자 세부 정보를 비동기적으로 가져옴
                    return FutureBuilder<UserDto>(
                      future: friendListProvider.fetchUserDetail(
                          friendListProvider.friendList[index]["friendname"]),
                      builder: (BuildContext context,
                          AsyncSnapshot<UserDto> snapshot) {
                        // 만약 세부정보를 로딩중이라면
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // 서큘러프로그래스인디케이터(돌아가는 동그라미) 반환
                          return CircularProgressIndicator();
                          // 만약 데이터가 있다면
                        } else if (snapshot.hasData) {
                          // 해당 사용자의 로그인 아이디인 friendName을 변수로 저장
                          String friendName = snapshot.data!.loginId ?? '';
                          // 해당 사용자의 프로필 이미지를 비동기적으로 가져옴
                          return FutureBuilder<ImageProvider>(
                            future:
                                friendListProvider.fetchFriendImage(friendName),
                            builder: (BuildContext context,
                                AsyncSnapshot<ImageProvider> imageSnapshot) {
                              // 만약 이미지를 로딩중이라면
                              if (imageSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // 돌아가는 동그라미 반환
                                return CircularProgressIndicator();
                                // 만약 데이터가 있다면
                              } else if (imageSnapshot.hasData) {
                                // (패딩으로 감싼) InkWell위젯과 친구 카드 반환
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: InkWell(
                                    // 탭 되었을때 MainProfile 화면으로 이동
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MainProfile(
                                            username:
                                                friendListProvider.username,
                                            id: friendListProvider
                                                    .friendList[index]
                                                ["friendname"],
                                            name: snapshot.data!.nickname ?? "",
                                            phoneNumber:
                                                snapshot.data!.phoneNumber ??
                                                    "",
                                            statusMSG:
                                                snapshot.data!.statusMSG ?? "",
                                            imageProvider: imageSnapshot.data,
                                          ),
                                        ),
                                      );
                                      // 만약 result가 비어있지 않다면
                                      if (result != null) {
                                        // 친구 목록 갱신
                                        friendListProvider.updateFriend(
                                            index, result);
                                      }
                                    },
                                    child: FriendCard(
                                      user: snapshot.data!,
                                      imageProvider: imageSnapshot.data ??
                                          AssetImage('assets/human.jpeg'),
                                      index: index,
                                      provider: friendListProvider,
                                      onCheckChanged:
                                          // 체크박스가 보이는 상태면?
                                          friendListProvider.showCheckBox
                                              // 친구목록의 체크리스트 갱신
                                              ? (value) {
                                                  friendListProvider
                                                      .updateCheckList(
                                                          index, value!);
                                                }
                                              // 아니라면 체크리스트 비우기
                                              : null,
                                    ),
                                  ),
                                );
                                // 이미지 데이터가 없는 경우
                              } else {
                                // 빈 공간 생성
                                return SizedBox();
                              }
                            },
                          );
                          // 세부정보 데이터가 없다면
                        } else {
                          // 메세지 반환
                          return Text('데이터가 없습니다.');
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
