import 'package:aiplant/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyCcMGD2c4M6IuAK5SG0NXRSOLid2xmCuaA",
    appId: "1:894903813282:android:267bccd6ad51b099d303fb",
    messagingSenderId: "894903813282",
    projectId: "fyppart1-bbb83",
  ));
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.light(
          primary: Color(0xFF2E7D32), // Deep botanical green
          secondary: Color(0xFF8BC34A), // Leaf green
          background: Color(0xFFF5F5F5), // Light gray
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: Color(0xFF212121)), // Dark gray text
        ),
      ),
      home:  SplashScreen()
    );
  }
}