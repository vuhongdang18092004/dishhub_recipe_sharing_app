part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthSignUp extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignUp({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

class AuthSignInEmail extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInEmail({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignInGoogle extends AuthEvent {
  const AuthSignInGoogle();
}

class AuthResetPassword extends AuthEvent {
  final String email;

  const AuthResetPassword({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthSignOut extends AuthEvent {
  const AuthSignOut();
}

class AuthCheckStatus extends AuthEvent {
  const AuthCheckStatus();
}

class AuthUpdateAvatar extends AuthEvent {
  final String newAvatarUrl;

  const AuthUpdateAvatar(this.newAvatarUrl);

  @override
  List<Object?> get props => [newAvatarUrl];
}

