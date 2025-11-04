import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/recipe_entity.dart';
import '../bloc/recipe_bloc.dart';
import '../widgets/recipe_card.dart';

class HomePage extends StatefulWidget {
  final UserEntity user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(LoadAllRecipes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final currentUser = authState is AuthAuthenticated
                ? authState.user
                : widget.user;

            return Column(
              children: [
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: InkWell(
                    onTap: () {
                      context.push('/search', extra: currentUser);
                    },
                    child: IgnorePointer(
                      child: TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: 'Tìm công thức...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: BlocBuilder<RecipeBloc, RecipeState>(
                    builder: (context, state) {
                      if (state is RecipeSearchLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is RecipeSearchLoaded) {
                        final results = state.searchResults;
                        if (results.isEmpty) {
                          return const Center(
                            child: Text('Không tìm thấy kết quả.'),
                          );
                        }
                        return _buildRecipeList(context, results, currentUser);
                      }
                      if (state is RecipeSearchError) {
                        return Center(
                          child: Text('Lỗi tìm kiếm: ${state.message}'),
                        );
                      }

                      if (state is RecipeLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is RecipeLoaded) {
                        final recipes = state.recipes;
                        if (recipes.isEmpty) {
                          return const Center(
                            child: Text('Chưa có công thức nào.'),
                          );
                        }
                        return _buildRecipeList(context, recipes, currentUser);
                      } else if (state is RecipeError) {
                        return Center(child: Text('Lỗi: ${state.message}'));
                      }

                      return const Center(child: Text('Gõ vào ô tìm kiếm...'));
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecipeList(
    BuildContext context,
    List<RecipeEntity> recipes,
    UserEntity currentUser,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          recipe: recipe,
          currentUser: currentUser,
          onTap: () {
            context.push(
              '/recipe-detail',
              extra: {'recipe': recipe, 'currentUser': currentUser},
            );
          },
        );
      },
    );
  }
}
