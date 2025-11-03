import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/recipe_bloc.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../data/models/recipe_step.dart';
import '../widgets/zoomable_image_screen.dart';

class RecipeDetailPage extends StatelessWidget {
  final RecipeEntity recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  void _openZoomableImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ZoomableImageScreen(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BlocBuilder<RecipeBloc, RecipeState>(builder: (context, recipeState) {
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

            BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
              final user = authState is AuthAuthenticated ? authState.user : null;
              final isLiked = user != null ? currentRecipe.likes.contains(user.id) : false;

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
                                  ToggleLike(recipeId: currentRecipe.id, userId: user.id),
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
            }),

            BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
              final user = authState is AuthAuthenticated ? authState.user : null;
              final isSaved = user?.savedRecipes.contains(currentRecipe.id) ?? false;

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
            }),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (currentRecipe.photoUrls.isNotEmpty)
                GestureDetector(
                  onTap: () => _openZoomableImage(context, currentRecipe.photoUrls.first),
                  child: Hero(
                    tag: currentRecipe.photoUrls.first,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: theme.primaryColor,
                    ),
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
                                    color: isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.black87,
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
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
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
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
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
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: theme.primaryColor.withOpacity(0.15),
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Bước ${i + 1}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.black87,
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
                                  onTap: () => _openZoomableImage(context, step.photoUrl!),
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
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    });
  }
}