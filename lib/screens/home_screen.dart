import 'package:calendar_app/controllers/screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final sc = Get.put(ScreenController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(sc.selectedRoute['title'])),
        centerTitle: true,
        actions: [
          TextButton.icon(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            icon: const Icon(Icons.supervised_user_circle),
            label: Obx(() => Text(sc.user.value)),
            onPressed: () {
              sc.moveToPage('user');
            },
          ),
        ],
      ),
      body: Obx(() => sc.selectedRoute['body']),
      bottomNavigationBar: BottomAppBar(
        elevation: 15.0,
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  sc.moveToPage('schedule');
                },
                color: Colors.cyan,
              ),
              IconButton(
                icon: const Icon(Icons.newspaper),
                onPressed: () {
                  sc.moveToPage('news');
                },
                color: Colors.cyan,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
