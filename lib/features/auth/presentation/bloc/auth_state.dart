part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);
}
class AuthSignedOut extends AuthState {}
class AuthPasswordReset extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
