import 'package:calendar_app/controllers/screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectUser extends StatelessWidget {
  const SelectUser({Key? key}) : super(key: key);
  void setUser(String user) {
    Get.find<ScreenController>()
      ..prefs.setString('user', user)
      ..changeUser(user)
      ..moveToPage('schedule');
    Get.snackbar(
      '사용자 선택',
      '사용자 $user가 선택되었습니다.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              setUser('YS');
            },
            child: const Text('용수'),
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: () {
              setUser('MY');
            },
            child: const Text('미영'),
          ),
        ],
      ),
    );
  }
}
