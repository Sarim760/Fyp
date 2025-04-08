import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:aiplant/screens/login_screen.dart';
import 'package:aiplant/screens/register_user_screen.dart';
import 'package:aiplant/ui_Helper/ui_helper.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> 
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                 Image.asset('assets/images/pic1.png',
                 height: 100.0,
                 width: 100.0,
                 ),
                const SizedBox(width: 20.0),
                Expanded(
                  child: DefaultTextStyle(
                    style: theme.textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onBackground,
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'AI Plant Diagnostic',
                          speed: const Duration(milliseconds: 100),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48.0),
            // Login Button - using direct navigation
            UIHelper.buildThemedButton(
              context: context,
              text: 'Log In',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              ),
            ),
            const SizedBox(height: 16.0),
            // Register Button - using direct navigation
            UIHelper.buildThemedButton(
              context: context,
              text: 'Register',
              buttonColor: theme.colorScheme.secondary,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegidterUser (),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}