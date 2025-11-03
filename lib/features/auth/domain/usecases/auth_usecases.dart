import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository repository;
  SignUpWithEmail(this.repository);

  Future<UserEntity> call(String email, String password, String name) {
    return repository.signUpWithEmail(email, password, name);
  }
}

class SignInWithEmail {
  final AuthRepository repository;
  SignInWithEmail(this.repository);

  Future<UserEntity> call(String email, String password) {
    return repository.signInWithEmail(email, password);
  }
}

class SignInWithGoogle {
  final AuthRepository repository;
  SignInWithGoogle(this.repository);

  Future<UserEntity> call() {
    return repository.signInWithGoogle();
  }
}

class ResetPassword {
  final AuthRepository repository;
  ResetPassword(this.repository);

  Future<void> call(String email) async {
    if (email.isEmpty) {
      throw Exception("Vui lòng nhập địa chỉ email trước khi đặt lại mật khẩu.");
    }

    try {
      await repository.resetPassword(email);
    } catch (e) {
      throw Exception("Không thể gửi email đặt lại mật khẩu. ${e.toString()}");
    }
  }
}


class SignOut {
  final AuthRepository repository;
  SignOut(this.repository);

  Future<void> call() {
    return repository.signOut();
  }
}

class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  Future<UserEntity?> call() {
    return repository.getCurrentUser();
  }
}

class ToggleSaveRecipe {
  final AuthRepository repository;
  ToggleSaveRecipe(this.repository);

  Future<UserEntity> call(String userId, String recipeId) {
    return repository.toggleSaveRecipe(userId, recipeId);
  }
}

class SendEmailVerification {
  final AuthRepository repository;
  SendEmailVerification(this.repository);

  Future<void> call() {
    return repository.sendEmailVerification();
  }
}

