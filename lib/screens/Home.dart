import 'package:aiplant/widgets/Home_widget.dart';
import 'package:aiplant/widgets/diagnosis.dart';
import 'package:aiplant/screens/welcome.dart';
import 'package:bottom_bar_with_sheet/bottom_bar_with_sheet.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/authentication_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _lastPressed;
  int _currentIndex = 0;


  final _pages = <Widget>[
    HomeWidget(),
    const Center(child: Text('Cart Page',)),
    const Center(child: Text('Settings Page',)),
    const Center(child: Text('Favorites Page')),
  ];
  final _bottomBarController = BottomBarWithSheetController(initialIndex: 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Plant Diagnosis'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
        ),

        drawer: _buildDrawer(context),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
        ),
        bottomNavigationBar: BottomBarWithSheet(
          controller: _bottomBarController,

          onSelectItem: (index) => setState(() => _currentIndex = index),// <- keep the same instance in State
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

          sheetChild: Center(
            child: Diagnosis()
          ),
          items: const [
            BottomBarWithSheetItem(icon: Icons.home_filled),
            BottomBarWithSheetItem(icon: Icons.shopping_cart),
            BottomBarWithSheetItem(icon: Icons.settings),
            BottomBarWithSheetItem(icon: Icons.favorite),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, String?>>(
      future: AuthenticationBloc.readAuth(), // reads token, username, email
      builder: (_, snapshot) {
        final data = snapshot.data ?? {};
        final username = data['username'] ?? 'Guest';
        final email = data['email'] ?? 'no-email@aiplant.com';

        return Drawer(
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
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.settings, color: theme.colorScheme.primary),
                title: const Text('Settings'),
                onTap: () {},
              ),
              const Divider(),

              /* ---------- Sign-out with BlocListener ---------- */
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  if (state is AuthenticationInitial) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (_) => false,
                    );
                    DelightToastBar(
                        autoDismiss: true,
                        animationDuration: Animate.defaultDuration,
                        builder: (context) => ToastCard(
                                leading: Icon(
                                  Icons.flutter_dash_sharp,
                                  size: 28,
                                ),
                                title: Text('Signed out Successfully'))
                            .animate()
                            .scaleXY(
                              begin: 1,
                              end: 0.94,
                              curve: Curves.easeInOut,
                              duration: const Duration(milliseconds: 100),
                            )).show(context);
                  } else if (state is AuthenticationFailure) {
                    DelightToastBar(
                        autoDismiss: true,
                        animationDuration: Animate.defaultDuration,
                        builder: (context) => ToastCard(
                                leading: Icon(
                                  Icons.flutter_dash_sharp,
                                  size: 28,
                                ),
                                title: Text(state.message))
                            .animate()
                            .scaleXY(
                              begin: 1,
                              end: 0.94,
                              curve: Curves.easeInOut,
                              duration: const Duration(milliseconds: 100),
                            )).show(context);
                  }
                },
                child: ListTile(
                  leading: Icon(Icons.logout,
                      color: Theme.of(context).colorScheme.error),
                  title: const Text('Sign Out'),
                  onTap: () =>
                      context.read<AuthenticationBloc>().add(LoggedOut()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    if (_lastPressed == null ||
        now.difference(_lastPressed!) > const Duration(seconds: 2)) {
      // first back-press or too slow – show snack
      _lastPressed = now;
      DelightToastBar(
          autoDismiss: true,
          animationDuration: Animate.defaultDuration,
          builder: (context) => ToastCard(
                  leading: Icon(
                    Icons.exit_to_app,
                    size: 28,
                  ),
                  title: Text('Press back again to exit'))
              .animate()
              .scaleXY(
                begin: 1,
                end: 0.94,
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 100),
              )).show(context);

      return false; // prevent pop
    }
    return true; // pop / exit app
  }
}
