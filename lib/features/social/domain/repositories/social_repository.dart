abstract class SocialRepository {
  Future<void> followUser(String currentUserId, String targetUserId);
  Future<void> unfollowUser(String currentUserId, String targetUserId);
  Future<bool> isFollowing(String currentUserId, String targetUserId);
}
