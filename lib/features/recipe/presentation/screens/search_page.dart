import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/recipe_entity.dart';
import '../bloc/recipe_bloc.dart';
import '../widgets/recipe_card.dart';

class SearchPage extends StatefulWidget {
  final UserEntity user;

  const SearchPage({super.key, required this.user});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load tất cả recipes khi vào trang search
    context.read<RecipeBloc>().add(LoadAllRecipes());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm công thức'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  context.read<RecipeBloc>().add(SearchRecipesEvent(value));
                },
                decoration: InputDecoration(
                  hintText: 'Tìm công thức (gõ 1 từ khóa)...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
            ),

            // Kết quả tìm kiếm
            Expanded(
              child: BlocBuilder<RecipeBloc, RecipeState>(
                builder: (context, state) {
                  if (state is RecipeSearchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is RecipeSearchLoaded) {
                    if (state.searchResults.isEmpty) {
                      return const Center(
                        child: Text(
                          'Không tìm thấy kết quả.',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    return _buildRecipeList(context, state.searchResults);
                  }
                  if (state is RecipeSearchError) {
                    return Center(
                      child: Text('Lỗi tìm kiếm: ${state.message}'),
                    );
                  }

                  if (state is RecipeLoaded) {
                    // Hiển thị tất cả recipes khi chưa tìm kiếm
                    final recipes = state.recipes;
                    if (recipes.isEmpty) {
                      return const Center(
                        child: Text(
                          'Chưa có công thức nào.',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    return _buildRecipeList(context, recipes);
                  }

                  // Trạng thái mặc định
                  return const Center(
                    child: Text(
                      'Gõ từ khóa để tìm kiếm công thức...',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeList(BuildContext context, List<RecipeEntity> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          recipe: recipe,
          currentUser: widget.user,
          onTap: () {
            // Navigate đến trang chi tiết
            context.push('/recipe-detail', extra: recipe);
          },
        );
      },
    );
  }
}