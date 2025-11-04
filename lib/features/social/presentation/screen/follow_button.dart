import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/social_bloc.dart';
import '../bloc/social_event.dart';
import '../bloc/social_state.dart';

class FollowButton extends StatelessWidget {
  final String authorId;

  const FollowButton({super.key, required this.authorId});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUser =
        authState is AuthAuthenticated ? authState.user : null;

    if (currentUser == null || currentUser.id == authorId) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<SocialBloc, SocialState>(
      builder: (context, state) {
        bool isFollowing = false;

        if (state is SocialFollowStatus) {
          isFollowing = state.isFollowing;
        } else if (state is SocialFollowed) {
          isFollowing = true;
        } else if (state is SocialUnfollowed) {
          isFollowing = false;
        }

        return ElevatedButton(
          onPressed: () {
            if (isFollowing) {
              context
                  .read<SocialBloc>()
                  .add(UnfollowUserEvent(currentUser.id, authorId));
            } else {
              context
                  .read<SocialBloc>()
                  .add(FollowUserEvent(currentUser.id, authorId));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey[700] : Colors.blueAccent,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            isFollowing ? 'Following' : 'Follow',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
