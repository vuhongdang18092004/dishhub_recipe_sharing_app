import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/recipe_entity.dart';
import '../bloc/recipe_bloc.dart';
import '../widgets/recipe_card.dart';

class MyRecipesPage extends StatefulWidget {
  final UserEntity user;

  const MyRecipesPage({super.key, required this.user});

  @override
  State<MyRecipesPage> createState() => _MyRecipesPageState();
}

class _MyRecipesPageState extends State<MyRecipesPage> {
  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(LoadAllRecipes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Công thức của tôi')),
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecipeLoaded) {
            final myRecipes = state.recipes
                .where((recipe) => recipe.creatorId == widget.user.id)
                .toList();

            if (myRecipes.isEmpty) {
              return _buildEmptyState();
            }

            return _buildRecipeList(myRecipes);
          } else if (state is RecipeError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }

          return const Center(child: Text('Đang tải...'));
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Chưa có công thức nào',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy tạo công thức đầu tiên của bạn!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRecipeList(List<RecipeEntity> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildRecipeItem(recipe);
      },
    );
  }

  Widget _buildRecipeItem(RecipeEntity recipe) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeCard(
              recipe: recipe,
              currentUser: widget.user,
              onTap: () {
                context.push(
                  '/recipe-detail',
                  extra: {'recipe': recipe, 'currentUser': widget.user},
                );
              },
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditDialog(recipe),
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text(
                      'Sửa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteDialog(recipe),
                    icon: const Icon(Icons.delete, size: 20),
                    label: const Text(
                      'Xóa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(RecipeEntity recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa công thức'),
        content: const Text('Bạn có muốn chỉnh sửa công thức này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/edit-recipe', extra: recipe);
            },
            child: const Text('Sửa'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(RecipeEntity recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa công thức'),
        content: Text('Bạn có chắc chắn muốn xóa "${recipe.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<RecipeBloc>().add(DeleteRecipeById(recipe.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa "${recipe.title}"')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showEditNotImplemented() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng chỉnh sửa đang được phát triển')),
    );
  }
}
