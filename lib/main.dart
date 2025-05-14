import 'package:aiplant/screens/On_board_Screen.dart';
import 'package:aiplant/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCcMGD2c4M6IuAK5SG0NXRSOLid2xmCuaA",
      appId: "1:894903813282:android:267bccd6ad51b099d303fb",
      messagingSenderId: "894903813282",
      projectId: "fyppart1-bbb83",
    ),
  );

  // Check if user has already seen the onboarding screen
  final prefs = await SharedPreferences.getInstance();
  bool hasBoarded = prefs.getBool('isBoarded') ?? false;

  runApp(MyApp(isBoarded: hasBoarded));
}

class MyApp extends StatelessWidget {
  final bool isBoarded;

  const MyApp({super.key, required this.isBoarded});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.light(
          primary: Color(0xFF2E7D32),
          secondary: Color(0xFF8BC34A),
          surface: Color(0xFFF5F5F5),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF212121)),
        ),
      ),
      home: isBoarded ? SplashScreen() : OnBoardScreen(),
    );
  }
}
