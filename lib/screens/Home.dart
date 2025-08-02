import 'package:aiplant/screens/store/marketplace.dart';
import 'package:aiplant/widgets/Doctor.dart';
import 'package:aiplant/widgets/Home_widget.dart';
import 'package:aiplant/widgets/diagnosis.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'favorites/favorites_screen.dart';

import '../bloc/auth/authentication_bloc.dart';
import '../widgets/cart/cart_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  DateTime? _lastPressed;
  int _currentIndex = 0;
  final _advancedDrawerController = AdvancedDrawerController();
  late AnimationController _favoriteAnimationController;
  late Animation<double> _favoriteAnimation;

  final _pages = <Widget>[
    const HomeWidget(),
    const DoctorsScreen(),
    const Marketplace(),
    const SettingsScreen()
  ];


  @override
  void initState() {
    super.initState();
    _favoriteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _favoriteAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _favoriteAnimationController.dispose();
    _advancedDrawerController.dispose();
    super.dispose();
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
      ),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      drawer: _buildDrawer(context),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(
              _currentIndex == 0 ? 'Home' :
              _currentIndex == 1 ? 'Doctors' :
              _currentIndex == 2 ? 'Store' :
              'Settings',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            leading: IconButton(
              onPressed: _handleMenuButtonPressed,
              icon: ValueListenableBuilder<AdvancedDrawerValue>(
                valueListenable: _advancedDrawerController,
                builder: (_, value, __) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      value.visible ? Icons.clear : Icons.menu,
                      key: ValueKey<bool>(value.visible),
                    ),
                  );
                },
              ),
            ),
            actions: _currentIndex == 2 
                ? [
                    AnimatedBuilder(
                      animation: _favoriteAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _favoriteAnimation.value,
                          child: IconButton(
                            onPressed: () {
                              _favoriteAnimationController.forward().then((_) {
                                _favoriteAnimationController.reverse();
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FavoritesScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.favorite_outline,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                  ]
                : [],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: IndexedStack(
                index: _currentIndex,
                sizing: StackFit.expand,
                children: _pages,
              ),
            ),
          ),
          floatingActionButton: _currentIndex == 2
              ? Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    final count = cart.totalCount;
                    return Stack(
                      alignment: Alignment.topRight,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const CartBottomSheet(),
                            );
                          },
                          child: const Icon(Icons.shopping_cart),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                          child: count > 0
                              ? Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    key: ValueKey(count),
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      count.toString(),
                                      style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                )
              : _currentIndex == 0
                  ? FloatingActionButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: const Center(child: Diagnosis()),
                          ),
                        );
                      },
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    )
                  : null,
          bottomNavigationBar: WaterDropNavBar(
            backgroundColor: Colors.white,
            waterDropColor: Theme.of(context).primaryColor,
            inactiveIconColor: Colors.grey,
            onItemSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedIndex: _currentIndex,
            barItems: [
              BarItem(
                filledIcon: Icons.home,
                outlinedIcon: Icons.home_outlined,
              ),
              BarItem(
                filledIcon: Icons.medical_services,
                outlinedIcon: Icons.medical_services_outlined,
              ),
              BarItem(
                filledIcon: Icons.shop,
                outlinedIcon: Icons.shop_outlined,
              ),
              BarItem(
                filledIcon: Icons.settings,
                outlinedIcon: Icons.settings_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, String?>?>(
      future: AuthenticationBloc.readAuth(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final username = data?['username'] ?? 'Guest';
        final email = data?['email'] ?? 'no-email@aiplant.com';

        return Drawer(
          backgroundColor: theme.scaffoldBackgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.colorScheme.secondary,
                        child: Text(
                          username.isNotEmpty ? username[0].toUpperCase() : 'G',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        username,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: [
                      _buildDrawerItem(
                        context,
                        icon: Icons.home_rounded,
                        title: 'Home',
                        theme: theme, onTap: () {  },
                       
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.history_rounded,
                        title: 'Diagnosis History',
                        theme: theme,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.chat_rounded,
                        title: 'Community Chat',
                        theme: theme,
                        onTap: () {

                          Navigator.pushNamed(context, '/chat');
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        theme: theme,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1),
                      ),
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
                        child: _buildDrawerItem(
                          context,
                          icon: Icons.logout_rounded,
                          title: 'Sign Out',
                          theme: theme,
                          isDestructive: true,
                          onTap: () {
                            Navigator.pop(context);
                            context.read<AuthenticationBloc>().add(LoggedOut());
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(BuildContext context, {
    required IconData icon,
    required String title,
    required ThemeData theme,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isDestructive
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDestructive
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastPressed == null ||
        now.difference(_lastPressed!) > const Duration(seconds: 2)) {
      _lastPressed = now;
      DelightToastBar(
        autoDismiss: true,
        animationDuration: Animate.defaultDuration,
        builder: (context) => ToastCard(
          leading: Icon(Icons.exit_to_app, size: 28),
          title: Text('Press back again to exit'),
        ).animate().scaleXY(
          begin: 1,
          end: 0.94,
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 100),
        ),
      ).show(context);
      return false;
    }
    return true;
  }
}

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
              // Menu Items Section
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
                child: Column(
                  children: [
                    _buildSettingsItem(
                      context,
                      icon: Icons.home_rounded,
                      title: 'Home',
                      subtitle: 'Go to main dashboard',
                      theme: theme,
                      onTap: () {
                        // Navigate to home tab
                        final homeState = context.findAncestorStateOfType<_HomePageState>();
                        homeState?.setState(() {
                          homeState._currentIndex = 0;
                        });
                      },
                    ),
                    const Divider(height: 1, indent: 72),
                    _buildSettingsItem(
                      context,
                      icon: Icons.history_rounded,
                      title: 'Diagnosis History',
                      subtitle: 'View your plant diagnosis records',
                      theme: theme,
                      onTap: () {
                        // TODO: Navigate to diagnosis history
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Diagnosis History - Coming Soon!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 72),
                    _buildSettingsItem(
                      context,
                      icon: Icons.chat_rounded,
                      title: 'Community Chat',
                      subtitle: 'Connect with other plant enthusiasts',
                      theme: theme,
                      onTap: () {
                        Navigator.pushNamed(context, '/chat');
                      },
                    ),
                    const Divider(height: 1, indent: 72),
                    _buildSettingsItem(
                      context,
                      icon: Icons.settings_rounded,
                      title: 'App Settings',
                      subtitle: 'Customize your app experience',
                      theme: theme,
                      onTap: () {
                        // TODO: Navigate to app settings
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('App Settings - Coming Soon!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
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
}
