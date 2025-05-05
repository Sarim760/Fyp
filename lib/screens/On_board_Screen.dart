import 'package:aiplant/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  final PageController pageController = PageController();
  int currentPage = 0;

  final pages = [
    pagesclass(
      image: 'assets/images/page_1.gif',
      title: 'Analyze the Plants',
      subtitle: 'Embrace the harmony of nature, where plants touch within structured elegance',
    ),
    pagesclass(
      image: 'assets/images/page_2.gif',
      title: 'Plant Care Guide',
      subtitle: 'Learn how to nurture your plants for optimal growth and health',
    ),
    pagesclass(
      image: 'assets/images/page_3.gif',
      title: 'Smart Monitoring',
      subtitle: 'Get real-time updates and alerts for your plant\'s needs',
    ),
  ];

  void _onSkipPressed() {
    saveData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SplashScreen()),
    );
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBoarded', true);
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;


    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: pages.map((page) => onboardingpage(page: page)).toList(),
          ),

        ],
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class pagesclass {
  final String image;
  final String title;
  final String subtitle;

  pagesclass({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class onboardingpage extends StatelessWidget {
  final pagesclass page;

  const onboardingpage({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            page.image,
            width: double.infinity,
            height: size.height * 0.5,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          Column(
            children: [
              Text(
                page.title,
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                page.subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 40), // Space for indicator
        ],
      ),
    );
  }
}
