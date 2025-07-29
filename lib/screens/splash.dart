import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/auth/authentication_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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

    // Check for valid auth session (no fixed delay)
    final auth = await AuthenticationBloc.readAuth();
    bool isTokenValid = false;
    if (auth != null) {
      isTokenValid = await AuthenticationBloc.validateTokenWithBackend(auth['token']);
    }
    if (!mounted) return;
    if (auth == null || !isTokenValid) {
      // Token missing, expired, or invalid, go to login
      Navigator.pushReplacementNamed(
        context,
        hasBoarded ? '/welcome' : '/onboard',
      );
    } else {
      // Token valid, go to welcome/home
      Navigator.pushReplacementNamed(
        context,
        hasBoarded ? '/home' : '/onboard',
      );
    }
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