import 'package:aiplant/bloc/auth/authentication_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aiplant/screens/app_settings_screen.dart';
import 'package:aiplant/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
//import '../blocs/authentication_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, String?>?>(
      future: AuthenticationBloc.readAuth(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final username = data?['username'] ?? 'Guest';
        final email = data?['email'] ?? 'no-email@aiplant.com';

        return SingleChildScrollView(
          child: Column(
            children: [
              // User Profile Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Hero(
                      tag: 'user_avatar',
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            username.isNotEmpty ? username[0].toUpperCase() : 'G',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // App Settings Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildSettingsItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'App Settings',
                  subtitle: 'Customize your app experience',
                  theme: theme,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppSettingsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Font Selection Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _buildSettingsItem(
                      context,
                      icon: Icons.font_download_rounded,
                      title: 'Font Selection',
                      subtitle: 'Current: ${themeProvider.fontFamily}',
                      theme: theme,
                      onTap: () {
                        _showFontSelectionDialog(context, themeProvider);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Sign Out Section
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  if (state is AuthenticationInitial) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/welcome',
                      (_) => false,
                    );
                    DelightToastBar(
                      autoDismiss: true,
                      animationDuration: Animate.defaultDuration,
                      builder: (context) => ToastCard(
                        leading: Icon(Icons.flutter_dash_sharp, size: 28),
                        title: Text('Signed out Successfully'),
                      ).animate().scaleXY(
                        begin: 1,
                        end: 0.94,
                        curve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 100),
                      ),
                    ).show(context);
                  } else if (state is AuthenticationFailure) {
                    DelightToastBar(
                      autoDismiss: true,
                      animationDuration: Animate.defaultDuration,
                      builder: (context) => ToastCard(
                        leading: Icon(Icons.flutter_dash_sharp, size: 28),
                        title: Text(state.message),
                      ).animate().scaleXY(
                        begin: 1,
                        end: 0.94,
                        curve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 100),
                      ),
                    ).show(context);
                  }
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text('Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    context.read<AuthenticationBloc>().add(LoggedOut());
                                  },
                                  child: Text(
                                    'Sign Out',
                                    style: TextStyle(color: theme.colorScheme.error),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.logout_rounded,
                                color: theme.colorScheme.error,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sign Out',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Sign out from your account',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontSelectionDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Font'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ThemeProvider.availableFonts.length,
              itemBuilder: (context, index) {
                final fontName = ThemeProvider.availableFonts[index];
                final isSelected = themeProvider.fontFamily == fontName;
                
                return ListTile(
                  title: Text(
                    fontName,
                    style: _getFontStyle(fontName),
                  ),
                  subtitle: Text(
                    'Sample text in $fontName',
                    style: _getFontStyle(fontName).copyWith(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  leading: Radio<String>(
                    value: fontName,
                    groupValue: themeProvider.fontFamily,
                    onChanged: (String? value) {
                      if (value != null) {
                        themeProvider.setFontFamily(value);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  selected: isSelected,
                  onTap: () {
                    themeProvider.setFontFamily(fontName);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  TextStyle _getFontStyle(String fontName) {
    switch (fontName) {
      case 'Roboto':
        return GoogleFonts.roboto();
      case 'Open Sans':
        return GoogleFonts.openSans();
      case 'Lato':
        return GoogleFonts.lato();
      case 'Montserrat':
        return GoogleFonts.montserrat();
      case 'Poppins':
        return GoogleFonts.poppins();
      case 'Inter':
        return GoogleFonts.inter();
      case 'Nunito':
        return GoogleFonts.nunito();
      case 'Source Sans Pro':
        return GoogleFonts.sourceSans3();
      default:
        return GoogleFonts.roboto();
    }
  }
}