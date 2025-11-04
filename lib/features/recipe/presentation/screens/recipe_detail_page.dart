import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/recipe_bloc.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../data/models/recipe_step.dart';
import '../../data/models/recipe_comment.dart';
import '../widgets/zoomable_image_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../social/presentation/bloc/social_bloc.dart';
import '../../../social/presentation/bloc/social_event.dart';
import '../../../social/domain/usecases/follow_user.dart';
import '../../../social/domain/usecases/unfollow_user.dart';
import '../../../social/domain/repositories/social_repository.dart';
import '../../../social/presentation/bloc/social_state.dart';
import 'author_page.dart';

class RecipeDetailPage extends StatelessWidget {
  final RecipeEntity recipe;
  final UserEntity currentUser;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.currentUser,
  });

  void _openZoomableImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZoomableImageScreen(imageUrl: imageUrl),
      ),
    );
  }

  void _navigateToAuthorPage(
    BuildContext context,
    String authorId,
    String authorName,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AuthorPage(currentUser: currentUser, authorId: authorId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<RecipeBloc, RecipeState>(
      builder: (context, recipeState) {
        final RecipeEntity currentRecipe;
        if (recipeState is RecipeLoaded) {
          final matches = recipeState.recipes.where((r) => r.id == recipe.id);
          currentRecipe = matches.isNotEmpty ? matches.first : recipe;
        } else {
          currentRecipe = recipe;
        }

        return Scaffold(
          backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
          appBar: AppBar(
            elevation: 0,
            title: const Text("Chi tiết công thức"),
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            actions: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final user = authState is AuthAuthenticated ? authState.user : null;
                  final isLiked = user != null
                      ? currentRecipe.likes.contains(user.id)
                      : false;

                  return Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                          color: isLiked ? Colors.blue : theme.iconTheme.color,
                        ),
                        onPressed: user != null
                            ? () {
                                context.read<RecipeBloc>().add(
                                      ToggleLike(
                                        recipeId: currentRecipe.id,
                                        userId: user.id,
                                      ),
                                    );
                              }
                            : null,
                        tooltip: 'Like',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          '${currentRecipe.likes.length}',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final user = authState is AuthAuthenticated ? authState.user : null;
                  final isSaved =
                      user?.savedRecipes.contains(currentRecipe.id) ?? false;

                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Colors.orange : theme.iconTheme.color,
                    ),
                    onPressed: user != null
                        ? () {
                            context.read<AuthBloc>().add(
                                  AuthToggleSaveRecipe(recipeId: currentRecipe.id),
                                );
                          }
                        : null,
                    tooltip: isSaved ? 'Bỏ lưu' : 'Lưu công thức',
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (currentRecipe.photoUrls.isNotEmpty)
                  GestureDetector(
                    onTap: () => _openZoomableImage(
                      context,
                      currentRecipe.photoUrls.first,
                    ),
                    child: Hero(
                      tag: currentRecipe.photoUrls.first,
                      child: ClipRRect(
                        child: Image.network(
                          currentRecipe.photoUrls.first,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentRecipe.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentRecipe.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                _buildAuthorSection(context, currentRecipe, theme, isDarkMode),

                const SizedBox(height: 28),

                _buildIngredientsSection(currentRecipe, theme, isDarkMode),

                const SizedBox(height: 28),

                _buildStepsSection(context, currentRecipe, theme, isDarkMode),

                const SizedBox(height: 28),
                
                _buildCommentStream(context, currentRecipe, theme, isDarkMode),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientsSection(
    RecipeEntity currentRecipe,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Nguyên liệu',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: currentRecipe.ingredients.map((ing) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 6,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ing,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDarkMode ? Colors.grey[300] : Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection(
    BuildContext context,
    RecipeEntity currentRecipe,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_list_numbered_rounded,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Các bước thực hiện',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: currentRecipe.steps.asMap().entries.map((entry) {
              final i = entry.key;
              final RecipeStep step = entry.value;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 2,
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withAlpha(38),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              'Bước ${i + 1}',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        step.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.grey[300] : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      if (step.photoUrl != null && step.photoUrl!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: GestureDetector(
                            onTap: () => _openZoomableImage(
                              context,
                              step.photoUrl!,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: step.photoUrl!.startsWith('http')
                                  ? Image.network(step.photoUrl!)
                                  : Image.file(File(step.photoUrl!)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentStream(
    BuildContext context,
    RecipeEntity currentRecipe,
    ThemeData theme,
    bool isDarkMode,
  ) {
    final commentController = TextEditingController();
    final user = currentUser;
    final defaultPhoto = 'https://cdn-icons-png.flaticon.com/512/847/847969.png';

    final commentsStream = FirebaseFirestore.instance
        .collection('recipes')
        .doc(currentRecipe.id)
        .snapshots();

    void submitComment() {
      final content = commentController.text.trim();
      if (content.isEmpty) return;

      final newComment = RecipeComment(
        userId: user.id,
        userName: user.name,
        userPhotoUrl: user.photo,
        comment: content,
        createdAt: DateTime.now(),
      );

      context.read<RecipeBloc>().add(
            AddNewComment(recipeId: currentRecipe.id, comment: newComment),
          );

      commentController.clear();
      FocusScope.of(context).unfocus();
    }

    Widget buildCommentItem(RecipeComment comment) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(comment.userPhotoUrl ?? defaultPhoto),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.userName,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    comment.comment,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.grey[300] : Colors.black87,
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm - dd/MM/yyyy').format(comment.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: commentsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Lỗi tải bình luận: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
          );
        }

        final List<dynamic> rawComments = (snapshot.data?.data() as Map<String, dynamic>?)?['comments'] ?? [];
        
        final List<RecipeComment> comments = rawComments
            .map((c) => RecipeComment.fromMap(c as Map<String, dynamic>))
            .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bình luận (${comments.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(user.photo ?? defaultPhoto),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'Viết bình luận của bạn...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      ),
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => submitComment(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: submitComment,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (comments.isEmpty) 
                const Text('Chưa có bình luận nào.', style: TextStyle(color: Colors.grey)),
              
              ...comments.map(buildCommentItem), 
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuthorSection(
    BuildContext context,
    RecipeEntity currentRecipe,
    ThemeData theme,
    bool isDarkMode,
  ) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentRecipe.creatorId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildAuthorSectionLoading();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _buildAuthorNotFound();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final authorName = userData['name'] ?? 'Người dùng';
        final authorPhoto =
            userData['photo'] ??
            'https://cdn-icons-png.flaticon.com/512/847/847969.png';

        final authState = context.read<AuthBloc>().state;
        final currentUser = authState is AuthAuthenticated
            ? authState.user
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.person, color: theme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Tác giả',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: isDarkMode ? Colors.grey[800] : Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToAuthorPage(
                          context,
                          currentRecipe.creatorId,
                          authorName,
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(authorPhoto),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: GestureDetector(
                          onTap: () => _navigateToAuthorPage(
                            context,
                            currentRecipe.creatorId,
                            authorName,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (currentUser != null &&
                          currentUser.id != currentRecipe.creatorId)
                        _buildFollowButton(
                          context,
                          currentUser,
                          currentRecipe.creatorId,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFollowButton(
    BuildContext context,
    UserEntity currentUser,
    String authorId,
  ) {
    return BlocProvider(
      create: (context) => SocialBloc(
        repository: context.read<SocialRepository>(),
        followUser: context.read<FollowUser>(),
        unfollowUser: context.read<UnfollowUser>(),
      )..add(CheckFollowingStatusEvent(currentUser.id, authorId)),
      child: _FollowButtonWidget(authorId: authorId),
    );
  }

  Widget _buildAuthorSectionLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(radius: 28, backgroundColor: Colors.grey[300]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 16, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Container(width: 80, height: 12, color: Colors.grey[300]),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthorNotFound() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                'Không tìm thấy thông tin tác giả',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowButtonWidget extends StatelessWidget {
  final String authorId;

  const _FollowButtonWidget({required this.authorId});

  @override
  Widget build(BuildContext context) {
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
            final authState = context.read<AuthBloc>().state;
            final currentUser = authState is AuthAuthenticated
                ? authState.user
                : null;

            if (currentUser != null) {
              if (isFollowing) {
                context.read<SocialBloc>().add(
                      UnfollowUserEvent(currentUser.id, authorId),
                    );
              } else {
                context.read<SocialBloc>().add(
                      FollowUserEvent(currentUser.id, authorId),
                    );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey[700] : Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            isFollowing ? 'Đang theo dõi' : 'Theo dõi',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}