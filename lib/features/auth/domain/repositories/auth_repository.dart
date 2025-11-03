import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signUpWithEmail(
    String email,
    String password,
    String name,
  );
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signInWithGoogle();
  Future<void> resetPassword(String email);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> toggleSaveRecipe(String userId, String recipeId);
  Future<void> sendEmailVerification();

}
