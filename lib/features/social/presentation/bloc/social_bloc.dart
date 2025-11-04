import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/follow_user.dart';
import '../../domain/usecases/unfollow_user.dart';
import '../../domain/repositories/social_repository.dart';
import 'social_event.dart';
import 'social_state.dart';

class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final SocialRepository repository;
  final FollowUser followUser;
  final UnfollowUser unfollowUser;

  final Map<String, bool> _followingCache = {};

  SocialBloc({
    required this.repository,
    required this.followUser,
    required this.unfollowUser,
  }) : super(SocialInitial()) {
    on<FollowUserEvent>((event, emit) async {
      try {
        await followUser(event.currentUserId, event.targetUserId);
        _followingCache[event.targetUserId] = true;
        emit(SocialFollowStatus(true));
      } catch (e) {
        emit(SocialError(e.toString()));
      }
    });

    on<UnfollowUserEvent>((event, emit) async {
      try {
        await unfollowUser(event.currentUserId, event.targetUserId);
        _followingCache[event.targetUserId] = false;
        emit(SocialFollowStatus(false));
      } catch (e) {
        emit(SocialError(e.toString()));
      }
    });

    on<CheckFollowingStatusEvent>((event, emit) async {
      if (_followingCache.containsKey(event.targetUserId)) {
        emit(SocialFollowStatus(_followingCache[event.targetUserId]!));
        return;
      }

      final isFollowing = await repository.isFollowing(
        event.currentUserId,
        event.targetUserId,
      );
      _followingCache[event.targetUserId] = isFollowing;
      emit(SocialFollowStatus(isFollowing));
    });
  }
}
