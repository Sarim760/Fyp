import 'package:aiplant/screens/Home.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/authentication_bloc.dart';
import '../helper/ui_helper.dart';
import 'Home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: theme.colorScheme.primary),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) async {
          if (state is AuthenticationFailure) {
            DelightToastBar(
                autoDismiss: true,
                animationDuration: Animate.defaultDuration,
                builder: (context) => ToastCard(
                    leading:Icon(Icons.flutter_dash_sharp,size: 28,),
                    title: Text(
                        state.message
                    )
                ).animate().scaleXY(
                  begin: 1,
                  end: 0.94,
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 100),
                )
            ).show(context);
          }
          if (state is AuthenticationSuccess) {
            DelightToastBar(
                autoDismiss: true,
                animationDuration: Animate.defaultDuration,
                builder: (context) => ToastCard(
                    leading:Icon(Icons.flutter_dash_sharp,size: 28,),
                    title: Text(
                        state.message
                    )
                ).animate().scaleXY(
              begin: 1,
              end: 0.94,
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 100),
            )
            ).show(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
            );}
        },
        builder: (context, state) {
          if (state is AuthenticationLoading) {
            return Container(
              color: Colors.transparent,          // transparent background
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: 'Logo_splash',
                    child: SizedBox(
                      height: 200,
                      child: Image.asset('assets/images/pic1.png'),
                    ),
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      border: border,
                      enabledBorder: border,
                      focusedBorder: border.copyWith(
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                      border: border,
                      enabledBorder: border,
                      focusedBorder: border.copyWith(
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  UIHelper.buildThemedButton(
                    context: context,
                    text: 'Log In',
                    onPressed: () {
                      context.read<AuthenticationBloc>().add(LoginEvent(
                          email: _emailController.text,
                          password: _passwordController.text));
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      // Add forgot password functionality
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
