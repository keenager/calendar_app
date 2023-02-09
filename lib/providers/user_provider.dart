import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String _user = 'unselected';
  String get user => _user;

  Future<void> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    String savedUser = prefs.getString('user') ?? 'unselected';
    _user = savedUser;
    notifyListeners();
  }

  Future<void> setUser(BuildContext context, String user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('user', user);
    _user = user;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('사용자 $user가 선택되었습니다.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
