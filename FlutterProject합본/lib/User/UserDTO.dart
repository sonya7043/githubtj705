import 'dart:convert';
// quicktype.io로 만듦

UserDto userDtoFromJson(String str) => UserDto.fromJson(json.decode(str));

String userDtoToJson(UserDto data) => json.encode(data.toJson());

class UserDto {
  String? id;
  String? loginId;
  String? nickname;
  String? phoneNumber;
  String? password;
  String? statusMSG;
  bool checked;

  UserDto({
    this.id,
    this.loginId,
    this.nickname,
    this.phoneNumber,
    this.password,
    this.statusMSG,
    this.checked = false,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: json["id"],
        loginId: json["loginId"],
        nickname: json["nickname"],
        phoneNumber: json["phoneNumber"],
        password: json["password"],
        statusMSG: json["statusMSG"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "loginId": loginId,
        "nickname": nickname,
        "phoneNumber": phoneNumber,
        "password": password,
        "statusMSG": statusMSG,
      };
}
