import '../repositories/social_repository.dart';

class FollowUser {
  final SocialRepository repository;

  FollowUser(this.repository);

  Future<void> call(String currentUserId, String targetUserId) {
    return repository.followUser(currentUserId, targetUserId);
  }
}
