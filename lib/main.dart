import 'package:calendar_app/screens/calendar_screen.dart';
import 'package:calendar_app/screens/news_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int pageIndex = 0;
  Map<String, dynamic> getPage(int index) {
    Map<String, dynamic> page = {};
    switch (index) {
      case 0:
        page['title'] = '우리의 일정';
        page['body'] = const CalendarScreen();
        break;
      case 1:
        page['title'] = '뉴스';
        page['body'] = const NewsListScreen();
        break;
    }
    return page;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar app',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(getPage(pageIndex)['title']),
          centerTitle: true,
        ),
        body: getPage(pageIndex)['body'],
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
                    setState(() {
                      pageIndex = 0;
                    });
                  },
                  color: Colors.cyan,
                ),
                IconButton(
                  icon: const Icon(Icons.newspaper),
                  onPressed: () {
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                  color: Colors.cyan,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
