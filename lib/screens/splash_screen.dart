import 'package:aiplant/screens/on_board_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) =>
          // );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using the professional deep botanical green
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/pic1.png',
              width: 120,  // Slightly larger for better visibility
              height: 120,
              color: Colors.white,  // Ensures logo is white on green background
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.local_florist,  // Plant-themed error icon
                  color: Colors.white,
                  size: 120,
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'AI Plant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,  // Increased font size
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(  // Adds subtle text shadow for better readability
                    blurRadius: 4.0,
                    color: Colors.black54,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(  // Loading indicator
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.0,
            ),
          ],
        ),
      ),
    );
  }
}