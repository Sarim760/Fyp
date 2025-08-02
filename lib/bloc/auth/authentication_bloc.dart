import 'package:aiplant/helper/global_variables.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final dio = Dio();
  static const _storage = FlutterSecureStorage();

  static bool _isTokenExpired(String? token) {
    if (token == null) return true;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'];
      if (exp == null) return true;
      final expInt = exp is int ? exp : int.tryParse(exp.toString());
      if (expInt == null) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch(expInt * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }

  AuthenticationBloc() : super(AuthenticationInitial()) {
    loginEvent();
    signupEvent();
    logoutEvent();
  }

  void logoutEvent() {
    return on<LoggedOut>((event, emit) async {
    emit(AuthenticationInitial());
    await _storage.deleteAll();
  });
  }
  
  static Future<Map<String, String?>?> readAuth() async {
    final token = await _storage.read(key: 'token');
    if (_isTokenExpired(token)) {
      await _storage.deleteAll();
      return null;
    }
    final username = await _storage.read(key: 'username');
    final email = await _storage.read(key: 'email');
    final userId = await _storage.read(key: 'userId');
    return {'token': token, 'username': username, 'email': email, 'userId': userId};
  }

  Future<void> _saveAuth(String? token, Map<String, dynamic> user) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'username', value: user['username']);
    await _storage.write(key: 'email', value: user['email']);
    await _storage.write(key: 'userId', value: user['_id'] ?? user['id']);
  }

  void signupEvent() {
    return on<SignupEvent>((event, emit) async {
      emit(AuthenticationLoading());
      final username = event.username;
      final email = event.email;
      final password = event.password;

      try {
        final response =
            await dio.post('${GlobalVariables().apiString}/auth/signup', data: {
          'email': email,
          'username': username,
          'password': password,
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          final user = Map<String, dynamic>.from(data['user'] ?? {});
          final token = data['token'] ?? '';
          await _saveAuth(token, user);
          emit(AuthenticationSuccess(message: data['message']));
        } else {
          emit(AuthenticationFailure(response.data['message']));
        }
      } on DioException catch (e) {
        if (e.response != null) {
          emit(AuthenticationFailure(
              e.response?.data['message'] ?? "Login failed"));
        } else {
          emit(AuthenticationFailure("Connection error. Please try again."));
        }
      }
    });
  }
// Update the signupEvent handler

  void loginEvent() {
    return on<LoginEvent>((event, emit) async {
      emit(AuthenticationLoading());
      final email = event.email;
      final password = event.password;

      try {
        final response =
            await dio.post('${GlobalVariables().apiString}/auth/login', data: {
          'email': email,
          'password': password,
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          final token = data['token'];
          final user = Map<String, dynamic>.from(data['user']);
          await _saveAuth(token, user);
          emit(AuthenticationSuccess(message: 'Login Successful'));
        } else {
          emit(AuthenticationFailure(response.data['message']));
        }
      } on DioException catch (e) {
        if (e.response != null) {
          emit(AuthenticationFailure(
              e.response?.data['message'] ?? "Login failed"));
        } else {
          emit(AuthenticationFailure("Connection error. Please try again."));
        }
      }
    });
  }

  static Future<bool> validateTokenWithBackend(String? token) async {
    if (token == null) return false;
    try {
      final dio = Dio();
      final response = await dio.get(
        '${GlobalVariables().apiString}/auth/validate',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200 && response.data['valid'] == true;
    } catch (e) {
      return false;
    }
  }
}
