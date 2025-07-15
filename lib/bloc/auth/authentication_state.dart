part of 'authentication_bloc.dart';

@immutable
sealed class AuthenticationState {}
class AuthenticationInitial extends AuthenticationState {}
class AuthenticationLoading extends AuthenticationState {}
class AuthenticationAuthenticated extends AuthenticationState {}
class AuthenticationUnauthenticated extends AuthenticationState {}
class AuthenticationSuccess extends AuthenticationState {
  final String message;
  AuthenticationSuccess({required this.message});
}
class AuthenticationFailure extends AuthenticationState {
  final String message;
  AuthenticationFailure(this.message);
}