import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> signUpWithEmail(
    String email,
    String password,
    String name,
  ) {
    return remoteDataSource.signUpWithEmail(email, password, name);
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) {
    return remoteDataSource.signInWithEmail(email, password);
  }

  @override
  Future<UserEntity> signInWithGoogle() {
    return remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> resetPassword(String email) {
    return remoteDataSource.resetPassword(email);
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<UserEntity> toggleSaveRecipe(String userId, String recipeId) {
    return remoteDataSource.toggleSaveRecipe(userId, recipeId);
  }

  @override
  Future<void> sendEmailVerification() {
    return remoteDataSource.sendEmailVerification();
  }
}
