import 'package:calendar_app/screens/calendar_screen.dart';
import 'package:calendar_app/screens/home_screen.dart';
import 'package:calendar_app/screens/news_list_screen.dart';
import 'package:calendar_app/screens/select_user_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Calendar app',
      debugShowCheckedModeBanner: false,
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/calendar', page: () => const CalendarScreen()),
        GetPage(name: '/news', page: () => const NewsListScreen()),
        GetPage(name: '/user', page: () => const SelectUser()),
      ],
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 10,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            textStyle: const TextStyle(fontSize: 25),
          ),
        ),
      ),
    );
  }
}
