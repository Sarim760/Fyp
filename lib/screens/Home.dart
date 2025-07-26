import 'package:aiplant/screens/store/marketplace.dart';
import 'package:aiplant/widgets/Doctor.dart';
import 'package:aiplant/widgets/Home_widget.dart';
import 'package:aiplant/widgets/diagnosis.dart';
import 'package:bottom_bar_with_sheet/bottom_bar_with_sheet.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

import '../bloc/auth/authentication_bloc.dart';
import '../widgets/cart_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _lastPressed;
  int _currentIndex = 0;

  final _pages = <Widget>[
    const HomeWidget(),
    const DoctorsScreen(),
    const Marketplace(),
    const Center(child: Text('Se'),)

  ];
  final _bottomBarController = BottomBarWithSheetController(initialIndex: 0);

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return  WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            actions: [
              // Cart button removed from app bar
            ],
          ),
          drawer: _buildDrawer(context),
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
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(username),
                  accountEmail: Text(email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondary,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'G',
                      style: TextStyle(
                        fontSize: 24,
                        color: theme.colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(color: theme.colorScheme.primary),
                ),
                ListTile(
                  leading: Icon(Icons.home, color: theme.colorScheme.primary),
                  title: const Text('Home'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: Icon(Icons.history, color: theme.colorScheme.primary),
                  title: const Text('Diagnosis History'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.chat, color: theme.colorScheme.primary),
                  title: const Text('Community Chat'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/chat');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: theme.colorScheme.primary),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
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
                  child: ListTile(
                    leading: Icon(Icons.logout, color: theme.colorScheme.error),
                    title: const Text('Sign Out'),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AuthenticationBloc>().add(LoggedOut());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
