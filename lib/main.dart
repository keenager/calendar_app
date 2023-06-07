import 'package:calendar_app/providers/user_provider.dart';
import 'package:calendar_app/screens/cafe_upload_screen.dart';
import 'package:calendar_app/screens/calendar_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/media_provider.dart';
import 'screens/home_screen.dart';
import 'screens/news_list_screen.dart';
import 'screens/select_user_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//TODO: photo gallery -> other?

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting();
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // print('fcmToken: $fcmToken');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MediaProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Calendar app',
        debugShowCheckedModeBanner: false,
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/calendar': (context) => const CalendarScreen(),
          '/cafe': (context) => const CafeUploadScreen(),
          '/news': (context) => const NewsListScreen(),
          '/user': (context) => const SelectUser(),
        },
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 10,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              textStyle: const TextStyle(fontSize: 15),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          ),
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ko')],
      ),
    );
  }
}
