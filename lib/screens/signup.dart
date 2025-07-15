import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/authentication_bloc.dart';
import '../helper/ui_helper.dart';
import 'Home.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Future<void> _registerUser() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => _isLoading = true);
  //
  //   try {
  //     final userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //
  //     if (userCredential.user != null) {
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const WelcomeScreen()),
  //       );
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.message ?? 'Registration failed')),
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: theme.colorScheme.primary),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AuthenticationFailure) {
            DelightToastBar(
                autoDismiss: true,
                builder: (context) => ToastCard(title: Text(state.message)));
          }
          if (state is AuthenticationSuccess) {
            DelightToastBar(
                autoDismiss: true,
                builder: (context) => ToastCard(title: Text(state.message!)));
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          }
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
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your Username',
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
                        return 'Please enter your Username';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
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
                    text: 'Register',
                    onPressed: () {
                      context.read<AuthenticationBloc>().add(
                          SignupEvent(
                          email: _emailController.text,
                          username: _usernameController.text,
                          password: _passwordController.text));
                    },
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
