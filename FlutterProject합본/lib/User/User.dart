class User {
  String loginId;
  String username;
  String phoneNumber;
  String nickname;

  User({
    required this.loginId,
    required this.username,
    required this.phoneNumber,
    required this.nickname,
  });

  @override
  String toString() {
    return 'User('
        'loginId: $loginId,'
        'username: $username,'
        'phoneNumber: $phoneNumber,'
        'nickname: $nickname,'
        ')';
  }
}