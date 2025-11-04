abstract class SocialState {}

class SocialInitial extends SocialState {}

class SocialLoading extends SocialState {}

class SocialFollowed extends SocialState {}

class SocialUnfollowed extends SocialState {}

class SocialFollowStatus extends SocialState {
  final bool isFollowing;
  SocialFollowStatus(this.isFollowing);
}

class SocialError extends SocialState {
  final String message;
  SocialError(this.message);
}
