import 'package:aiplant/bloc/auth/authentication_bloc.dart';
import 'package:aiplant/providers/product_provider.dart';
import 'package:aiplant/providers/cart_provider.dart';
import 'package:aiplant/screens/cart/cart_screen.dart';
import 'package:aiplant/screens/Home.dart';
import 'package:aiplant/screens/Onboard.dart';
import 'package:aiplant/screens/validation/login.dart';
import 'package:aiplant/screens/splash.dart';
import 'package:aiplant/screens/validation/signup.dart';
import 'package:aiplant/screens/welcome.dart';
import 'package:aiplant/screens/chat/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

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
        ChangeNotifierProvider(
          create: (context) => ProductProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) => CartProvider()..refreshCart(),
        ),
          BlocProvider(create: (context) => AuthenticationBloc()),
        ],
        child: MaterialApp(
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => SplashScreen(),
            '/onboard': (context) => OnBoardScreen(),
            '/welcome': (context) => WelcomeScreen(),
            '/login': (context) => LoginScreen(),
            '/signup': (context) => RegistrationScreen(),
            '/home': (context) => HomePage(),
            '/chat': (context) => ChatPage(),
            '/cart': (context) => const CartScreen(),
          },
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
        ));
  }
}
