import 'package:aiplant/screens/welcome_screen.dart';
import 'package:aiplant/screens/on_board_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // Get the onboarding status from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final hasBoarded = prefs.getBool('isBoarded') ?? false;

    // Wait for 3 seconds (splash duration)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Navigate to appropriate screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => hasBoarded ? const WelcomeScreen() : const OnBoardScreen(),
      ),
    );
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
            Hero(
              tag: 'Logo_splash',
              child: Image.asset(
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
                    color: Colors.black26,
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