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
  final ToggleSaveRecipe toggleSaveRecipe;

  AuthBloc({
    required this.signUpWithEmail,
    required this.signInWithEmail,
    required this.signInWithGoogle,
    required this.resetPassword,
    required this.signOut,
    required this.getCurrentUser,
    required this.toggleSaveRecipe,
  }) : super(AuthInitial()) {
    // Track recipe IDs currently being toggled to prevent concurrent toggles
    final Set<String> _processingToggles = <String>{};
    on<AuthSignUp>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await signUpWithEmail(
          event.email,
          event.password,
          event.name,
        );
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

    on<AuthUpdateAvatar>((event, emit) {
      final currentState = state;
      if (currentState is AuthAuthenticated) {
        final updatedUser = currentState.user.copyWith(
          photo: event.newAvatarUrl,
        );
        emit(AuthAuthenticated(updatedUser));
      }
    });

    on<AuthToggleSaveRecipe>((event, emit) async {
      final currentState = state;
      if (currentState is! AuthAuthenticated) return;

      // prevent concurrent toggles for the same recipe
      if (_processingToggles.contains(event.recipeId)) return;
      _processingToggles.add(event.recipeId);

      // Optimistic update: toggle locally first so UI responds immediately
      final currentSaved = List<String>.from(currentState.user.savedRecipes);
      final optimisticList = List<String>.from(currentSaved);
      if (optimisticList.contains(event.recipeId)) {
        optimisticList.remove(event.recipeId);
      } else {
        optimisticList.add(event.recipeId);
      }

      final optimisticUser = currentState.user.copyWith(
        savedRecipes: optimisticList,
      );
      print(
        'AuthBloc: optimistic savedRecipes -> ${optimisticUser.savedRecipes}',
      );
      emit(AuthAuthenticated(optimisticUser));

      try {
        final updatedUser = await toggleSaveRecipe(
          currentState.user.id,
          event.recipeId,
        );
        // Replace optimistic user with authoritative user from backend
        print(
          'AuthBloc: backend updated savedRecipes -> ${updatedUser.savedRecipes}',
        );
        emit(AuthAuthenticated(updatedUser));
      } catch (e) {
        // Revert to previous state on error
        print('Error toggling save recipe: $e');
        emit(currentState);
      } finally {
        _processingToggles.remove(event.recipeId);
      }
    });
  }
}
