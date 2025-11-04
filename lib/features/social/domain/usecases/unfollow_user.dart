import '../repositories/social_repository.dart';

class UnfollowUser {
  final SocialRepository repository;

  UnfollowUser(this.repository);

  Future<void> call(String currentUserId, String targetUserId) {
    return repository.unfollowUser(currentUserId, targetUserId);
  }
}
