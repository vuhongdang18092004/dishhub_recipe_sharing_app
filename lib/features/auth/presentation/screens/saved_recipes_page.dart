import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/user_entity.dart';
import '../../../recipe/presentation/bloc/recipe_bloc.dart';
import '../../../recipe/presentation/widgets/recipe_card.dart';
import '../bloc/auth_bloc.dart';

class SavedRecipesPage extends StatefulWidget {
  final UserEntity user;

  const SavedRecipesPage({super.key, required this.user});

  @override
  State<SavedRecipesPage> createState() => _SavedRecipesPageState();
}

class _SavedRecipesPageState extends State<SavedRecipesPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(LoadAllRecipes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kho lưu trữ công thức'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final currentUser = authState is AuthAuthenticated
              ? authState.user
              : widget.user;
          final savedRecipeIds = currentUser.savedRecipes;

          if (savedRecipeIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có công thức nào được lưu',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn vào biểu tượng bookmark để lưu công thức yêu thích',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return BlocBuilder<RecipeBloc, RecipeState>(
            builder: (context, recipeState) {
              if (recipeState is RecipeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (recipeState is RecipeLoaded) {
                final savedRecipes = recipeState.recipes
                    .where((recipe) => savedRecipeIds.contains(recipe.id))
                    .toList();

                if (savedRecipes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có công thức nào được lưu',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<RecipeBloc>().add(LoadAllRecipes());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: savedRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = savedRecipes[index];
                      return RecipeCard(
                        recipe: recipe,
                        currentUser: currentUser,
                        onTap: () {
                          // Use `go` to navigate into the /home/recipe-detail route from
                          // outside the home branch to avoid pageKey reservation conflicts
                          // when pushing across shell branches.
                          GoRouter.of(context).push('/recipe-detail', extra: recipe);
                        },
                      );
                    },
                  ),
                );
              }

              if (recipeState is RecipeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(recipeState.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<RecipeBloc>().add(LoadAllRecipes());
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
