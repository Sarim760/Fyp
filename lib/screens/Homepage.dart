import '../screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:printing/printing.dart';

import '../servise/pdf_report_servise.dart';

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({required this.userName, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedPlant;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final List<String> _plants = [
    'Apple',
    'BlueBerry',
    'Cherry',
    'Corn',
    'Grape',
    'Orange',
    'Peach',
    'Pepper',
    'Potato',
    'Raspberry',
    'Soybean',
    'Squash',
    'Strawberry',
    'Tomato',
  ];

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Diagnosis'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      drawer: _buildDrawer(theme),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPlantDropdown(theme),
            const SizedBox(height: 30),
            _buildImageUploadCard(theme),
            const SizedBox(height: 30),
            _buildDiagnoseButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(ThemeData theme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.userName),
            accountEmail: Text(
                '${widget.userName.toLowerCase().replaceAll(' ', '')}@aiplant.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.secondary,
              child: Text(
                widget.userName[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  color: theme.colorScheme.onSecondary,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
          ),
          Animate(
            effects: [
              SlideEffect(
                begin: const Offset(0, 1),
                end: Offset.zero,
                duration: 400.ms,
                curve: Curves.easeInOut,
                delay: 100.ms,
              ),
            ],
            child: ListTile(
              leading: Icon(Icons.home, color: theme.colorScheme.primary),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
          ),
          Animate(
            effects: [
              SlideEffect(
                begin: const Offset(0, 1),
                end: Offset.zero,
                duration: 400.ms,
                curve: Curves.easeInOut,
                delay: 200.ms,
              ),
            ],
            child: ListTile(
              leading: Icon(Icons.history, color: theme.colorScheme.primary),
              title: const Text('Diagnosis History'),
              onTap: () {},
            ),
          ),
          Animate(
            effects: [
              SlideEffect(
                begin: const Offset(0, 1),
                end: Offset.zero,
                duration: 400.ms,
                curve: Curves.easeInOut,
                delay: 300.ms,
              ),
            ],
            child: ListTile(
              leading: Icon(Icons.settings, color: theme.colorScheme.primary),
              title: const Text('Settings'),
              onTap: () {},
            ),
          ),
          Divider(color: theme.colorScheme.outline),
          Animate(
            effects: [
              SlideEffect(
                begin: const Offset(0, 1),
                end: Offset.zero,
                duration: 400.ms,
                curve: Curves.easeInOut,
                delay: 400.ms,
              ),
            ],
            child: ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: const Text('Sign Out'),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WelcomeScreen(),
                    ),
                        (route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed out successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: ${e.toString()}')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
