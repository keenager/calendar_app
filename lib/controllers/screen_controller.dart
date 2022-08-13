import 'package:calendar_app/screens/calendar_screen.dart';
import 'package:calendar_app/screens/news_list_screen.dart';
import 'package:calendar_app/screens/select_user_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenController extends GetxController {
  late Map<String, Map<String, dynamic>> routes;
  late SharedPreferences prefs;
  final RxString user = 'unselected'.obs;

  final String initialPage = 'schedule';
  final RxMap selectedRoute = {}.obs;

  ScreenController() {
    routes = {
      'user': {
        'title': '사용자 선택',
        'body': const SelectUser(),
      },
      'schedule': {
        'title': '우리의 일정',
        'body': const CalendarScreen(),
      },
      'news': {
        'title': '뉴스',
        'body': const NewsListScreen(),
      },
    };
    selectedRoute.value = routes[initialPage]!;
  }

  @override
  void onInit() async {
    super.onInit();
    prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    var savedUser = prefs.getString('user') ?? 'unselected';
    user.value = savedUser;
    if (user.value == 'unselected') {
      selectedRoute.value = routes['user']!;
    }
  }

  void moveToPage(String pageName) {
    selectedRoute.value = routes[pageName]!;
  }

  void changeUser(String user) {
    this.user.value = user;
  }
}
