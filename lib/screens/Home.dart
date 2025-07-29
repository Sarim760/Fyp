import 'package:aiplant/screens/store/marketplace.dart';
import 'package:aiplant/widgets/Doctor.dart';
import 'package:aiplant/widgets/Home_widget.dart';
import 'package:aiplant/widgets/diagnosis.dart';
import 'package:bottom_bar_with_sheet/bottom_bar_with_sheet.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

import '../bloc/auth/authentication_bloc.dart';
import '../widgets/cart/cart_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _lastPressed;
  int _currentIndex = 0;
  final _advancedDrawerController = AdvancedDrawerController();

  final _pages = <Widget>[
    const HomeWidget(),
    const DoctorsScreen(),
    const Marketplace(),
    const Center(child: Text('Settings'),)
  ];
  final _bottomBarController = BottomBarWithSheetController(initialIndex: 0);

  @override
  void dispose() {
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          ),
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
            actions: [],
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
              : null,
          bottomNavigationBar: BottomBarWithSheet(
            controller: _bottomBarController,
            onSelectItem: (index) => setState(() => _currentIndex = index),
            bottomBarTheme: const BottomBarTheme(
              mainButtonPosition: MainButtonPosition.middle,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              itemIconColor: Colors.grey,
              itemTextStyle: TextStyle(color: Colors.grey, fontSize: 10),
              selectedItemTextStyle: TextStyle(color: Colors.blue, fontSize: 10),
            ),
            sheetChild: Center(child: Diagnosis()),
            items: const [
              BottomBarWithSheetItem(icon: Icons.home_filled),
              BottomBarWithSheetItem(icon: Icons.medical_services_outlined),
              BottomBarWithSheetItem(icon: Icons.shop),
              BottomBarWithSheetItem(icon: Icons.shopping_cart_sharp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

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
                    color: theme.colorScheme.primary,
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
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.8),
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
                        theme: theme,
                        onTap: () => Navigator.pop(context),
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
                          Navigator.pop(context);
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
