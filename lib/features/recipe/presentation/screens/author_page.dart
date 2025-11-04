import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../recipe/presentation/bloc/recipe_bloc.dart';
import '../../../recipe/presentation/widgets/recipe_card.dart';
import '../../../social/presentation/bloc/social_bloc.dart';
import '../../../social/presentation/bloc/social_event.dart';
import '../../../social/presentation/bloc/social_state.dart';
import '../../domain/entities/recipe_entity.dart';

class AuthorPage extends StatefulWidget {
  final UserEntity currentUser;
  final String authorId;

  const AuthorPage({
    super.key,
    required this.currentUser,
    required this.authorId,
  });

  @override
  State<AuthorPage> createState() => _AuthorPageState();
}

class _AuthorPageState extends State<AuthorPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(LoadAllRecipes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Người dùng')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.authorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text('Không tìm thấy tác giả'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final followers = List<String>.from(data['followers'] ?? []);
          final isFollowing = followers.contains(widget.currentUser.id);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    data['photo'] ??
                        'https://cdn-icons-png.flaticon.com/512/847/847969.png',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data['name'] ?? 'Người dùng',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Người theo dõi: ${followers.length}'),
                const SizedBox(height: 8),

                if (widget.currentUser.id != widget.authorId)
                  ElevatedButton(
                    onPressed: () {
                      if (isFollowing) {
                        context.read<SocialBloc>().add(
                              UnfollowUserEvent(
                                widget.currentUser.id,
                                widget.authorId,
                              ),
                            );
                      } else {
                        context.read<SocialBloc>().add(
                              FollowUserEvent(
                                widget.currentUser.id,
                                widget.authorId,
                              ),
                            );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFollowing ? Colors.grey : Colors.blue,
                    ),
                    child: Text(isFollowing ? 'Đang theo dõi' : 'Theo dõi'),
                  ),

                const SizedBox(height: 16),

                BlocBuilder<RecipeBloc, RecipeState>(
                  builder: (context, state) {
                    if (state is RecipeLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is RecipeLoaded) {
                      final authorRecipes = state.recipes
                          .where((r) => r.creatorId == widget.authorId)
                          .toList();

                      if (authorRecipes.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Tác giả chưa có công thức nào.'),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: authorRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = authorRecipes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: RecipeCard(
                              recipe: recipe,
                              currentUser: widget.currentUser,
                              onTap: () async {
                                await context.push(
                                  '/recipe-detail',
                                  extra: {
                                    'recipe': recipe,
                                    'currentUser': widget.currentUser,
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    }

                    return const Center(child: Text('Đang tải công thức...'));
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
