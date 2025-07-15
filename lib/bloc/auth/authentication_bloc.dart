import 'package:aiplant/helper/Global_variables.dart';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final dio = Dio();
  static const _storage = FlutterSecureStorage(); // <─ secure storage

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
  static Future<Map<String, String?>> readAuth() async {
    final token = await _storage.read(key: 'token');
    final username = await _storage.read(key: 'username');
    final email = await _storage.read(key: 'email');
    return {'token': token, 'username': username, 'email': email};
  }

  Future<void> _saveAuth(String? token, Map<String, dynamic> user) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'username', value: user['username']);
    await _storage.write(key: 'email', value: user['email']);
  }

  void signupEvent() {
    return on<SignupEvent>((event, emit) async {
      emit(AuthenticationLoading());
      final username = event.username;
      final email = event.email;
      final password = event.password;

      try {
        final response =
            await dio.post('${globalvariables().apiString}/auth/signup', data: {
          'email': email,
          'username': username,
          'password': password,
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
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

  void loginEvent() {
    return on<LoginEvent>((event, emit) async {
      emit(AuthenticationLoading());
      final email = event.email;
      final password = event.password;

      try {
        final response =
            await dio.post('${globalvariables().apiString}/auth/login', data: {
          'email': email,
          'password': password,
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          final token = data['token'];
          final user = data['user'];
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
}
