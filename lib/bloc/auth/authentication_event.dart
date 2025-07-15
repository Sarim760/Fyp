part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationEvent {}
class LoginEvent extends AuthenticationEvent{
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}
class LoggedOut extends AuthenticationEvent {}
class SignupEvent extends AuthenticationEvent{
  final String username ;
  final String email;
  final String password;

  SignupEvent({required this.username, required this.email, required this.password});
}