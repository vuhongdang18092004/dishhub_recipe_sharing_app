import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class RecipeCard extends StatelessWidget {
  final RecipeEntity recipe;
  final UserEntity? currentUser;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.currentUser,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthAuthenticated ? authState.user : currentUser;
        final isSaved = user?.savedRecipes.contains(recipe.id) ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.photoUrls.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      recipe.photoUrls.first,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recipe.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.thumb_up_alt_outlined, size: 20, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${recipe.likes.length}'),
                          const SizedBox(width: 16),
                          InkWell(
                            onTap: user != null
                                ? () {
                                    // Quick debug to ensure tap reaches this widget
                                    // and the event is dispatched.
                                    // TODO: remove debug print after verifying behavior.
                                    print('RecipeCard: bookmark tapped for recipe ${recipe.id}');
                                    context.read<AuthBloc>().add(
                                          AuthToggleSaveRecipe(recipeId: recipe.id),
                                        );
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              // Increase tappable area slightly to make the icon easier to hit.
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_border,
                                size: 20,
                                color: isSaved ? Colors.orange : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
