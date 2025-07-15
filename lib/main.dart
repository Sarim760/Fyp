import 'package:aiplant/bloc/auth/authentication_bloc.dart';
import 'package:aiplant/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthenticationBloc()),

      ],
      child: MaterialApp(
        // initialRoute: '/',
        // routes: {
        //   '/':(_)=>SplashScreen()
        // },
          theme: ThemeData(
            primarySwatch: Colors.green,
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2E7D32), // Deep botanical green
              secondary: Color(0xFF8BC34A), // Leaf green
             // background: Color(0xFFF5F5F5), // Light gray
            ),
            textTheme: TextTheme(
              headlineLarge:
                  TextStyle(color: Color(0xFF212121)), // Dark gray text
            ),
          ),
          home: SplashScreen()),
    );
  }

}
