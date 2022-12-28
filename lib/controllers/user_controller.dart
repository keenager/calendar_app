import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController extends GetxController {
  late SharedPreferences prefs;
  final RxString user = 'unselected'.obs;

  @override
  void onInit() async {
    super.onInit();
    prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    var savedUser = prefs.getString('user') ?? 'unselected';
    user.value = savedUser;
    if (user.value == 'unselected') {
      Get.toNamed('/user');
    }
  }

  void changeUser(String user) {
    this.user.value = user;
  }
}
