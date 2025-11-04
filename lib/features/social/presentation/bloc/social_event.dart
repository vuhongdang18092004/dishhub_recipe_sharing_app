abstract class SocialEvent {}

class FollowUserEvent extends SocialEvent {
  final String currentUserId;
  final String targetUserId;
  FollowUserEvent(this.currentUserId, this.targetUserId);
}

class UnfollowUserEvent extends SocialEvent {
  final String currentUserId;
  final String targetUserId;
  UnfollowUserEvent(this.currentUserId, this.targetUserId);
}

class CheckFollowingStatusEvent extends SocialEvent {
  final String currentUserId;
  final String targetUserId;
  CheckFollowingStatusEvent(this.currentUserId, this.targetUserId);
}
