import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarMemo extends ChangeNotifier {
  Map<String, String> _memo = {};

  CalendarMemo() {
    loadMemo();
  }

  // 메모 입력
  void addOrUpdateMemo(DateTime date, String memo) {
    _memo[date.toIso8601String()] = memo;
    notifyListeners();
    saveMemo();
  }

  // 메모 불러오기
  String getMemo(DateTime date) {
    return _memo[date.toIso8601String()] ?? '';
  }

  // 메모 로딩
  void loadMemo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _memo =
        Map<String, String>.from(jsonDecode(prefs.getString('memo') ?? '{}'));
    notifyListeners();
  }

  // 메모 저장
  void saveMemo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('memo', jsonEncode(_memo));
  }
}

// Provider 클래스
class CalendarProvider extends ChangeNotifierProvider<CalendarMemo> {
  CalendarProvider() : super(create: (_) => CalendarMemo(), lazy: false);
}
