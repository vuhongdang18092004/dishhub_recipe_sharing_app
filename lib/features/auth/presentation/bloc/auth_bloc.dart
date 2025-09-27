import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../.././domain/entities/user_entity.dart';
import '../.././domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignUpWithEmail signUpWithEmail;
  final SignInWithEmail signInWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final ResetPassword resetPassword;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;

  AuthBloc({
    required this.signUpWithEmail,
    required this.signInWithEmail,
    required this.signInWithGoogle,
    required this.resetPassword,
    required this.signOut,
    required this.getCurrentUser,
  }) : super(AuthInitial()) {
    on<AuthSignUp>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signUpWithEmail(event.email, event.password, event.name);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthSignInEmail>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signInWithEmail(event.email, event.password);
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthSignInGoogle>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signInWithGoogle();
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthResetPassword>((event, emit) async {
      try {
        await resetPassword(event.email);
        emit(AuthPasswordReset());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthSignOut>((event, emit) async {
      await signOut();
      emit(AuthSignedOut());
    });

    on<AuthCheckStatus>((event, emit) async {
      final user = await getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthSignedOut());
      }
    });
  }
}
