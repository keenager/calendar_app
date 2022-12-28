import 'package:calendar_app/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectUser extends StatelessWidget {
  const SelectUser({Key? key}) : super(key: key);

  void setUser(String user) {
    Get.find<UserController>()
      ..prefs.setString('user', user)
      ..changeUser(user);
    Get.snackbar(
      '사용자 선택',
      '사용자 $user가 선택되었습니다.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 선택'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            icon: const Icon(Icons.supervised_user_circle),
            label: Obx(() => Text(Get.find<UserController>().user.value)),
            onPressed: null,
          ),
        ],
      ),
      body: Center(
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
      ),
    );
  }
}
