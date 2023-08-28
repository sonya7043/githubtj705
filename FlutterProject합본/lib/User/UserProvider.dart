import 'package:flutter/material.dart';
import 'package:myflutterproject/User/User.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  bool get isLoggedIn => _user != null;

  String? get nickname => _user?.nickname;
  String? get phoneNumber => _user?.phoneNumber;

  void logIn(User user) {
    _user = user;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}