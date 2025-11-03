import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
// Import này cần thiết cho hàm helper
import '../../domain/entities/recipe_entity.dart'; 
import '../bloc/recipe_bloc.dart';
import '../widgets/recipe_card.dart';

// 1. Chuyển thành StatefulWidget để sửa lỗi lặp
class HomePage extends StatefulWidget {
  final UserEntity user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 2. Gọi LoadAllRecipes MỘT LẦN DUY NHẤT
  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(LoadAllRecipes());
  }

  @override
  Widget build(BuildContext context) {
    // Không gọi LoadAllRecipes ở đây

    return Scaffold(
      // 3. Sử dụng SafeArea (tốt hơn)
      body: SafeArea(
        // 4. GIỮ LẠI AuthBloc builder của đồng đội
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final currentUser = authState is AuthAuthenticated
                ? authState.user
                // Sửa thành widget.user
                : widget.user; 

            // 5. THÊM Column (từ logic tìm kiếm)
            return Column(
              children: [
                // 6. THÊM Thanh tìm kiếm (từ logic tìm kiếm)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
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

                // 7. THÊM Expanded và Cập nhật RecipeBloc builder
                Expanded(
                  child: BlocBuilder<RecipeBloc, RecipeState>(
                    builder: (context, state) {
                      // --- XỬ LÝ TRẠNG THÁI TÌM KIẾM (của bạn) ---
                      if (state is RecipeSearchLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is RecipeSearchLoaded) {
                        if (state.searchResults.isEmpty) {
                          return const Center(child: Text('Không tìm thấy kết quả.'));
                        }
                        // Hiển thị kết quả tìm kiếm VÀ truyền currentUser
                        return _buildRecipeList(
                            context, state.searchResults, currentUser);
                      }
                      if (state is RecipeSearchError) {
                        return Center(
                            child: Text('Lỗi tìm kiếm: ${state.message}'));
                      }

                      // --- XỬ LÝ TRẠNG THÁI TẢI TRANG (của đồng đội) ---
                      if (state is RecipeLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is RecipeLoaded) {
                        final recipes = state.recipes;
                        if (recipes.isEmpty) {
                          return const Center(child: Text('Chưa có công thức nào.'));
                        }
                        // Hiển thị danh sách đầy đủ VÀ truyền currentUser
                        return _buildRecipeList(context, recipes, currentUser);
                      } else if (state is RecipeError) {
                        return Center(child: Text('Lỗi: ${state.message}'));
                      }
                      
                      // Trạng thái ban đầu
                      return const Center(child: Text('Gõ vào ô tìm kiếm...'));
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      // 8. GIỮ LẠI FloatingActionButton của đồng đội
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Sửa: Dùng GoRouter thay vì Navigator
          GoRouter.of(context).push('/add'); 
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 9. TẠO HÀM HELPER (đã cập nhật)
  /// Xây dựng một ListView, yêu cầu currentUser để truyền cho RecipeCard
  Widget _buildRecipeList(
      BuildContext context, List<RecipeEntity> recipes, UserEntity currentUser) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          recipe: recipe,
          currentUser: currentUser, // <-- Truyền currentUser vào card
          onTap: () {
            GoRouter.of(context).push('/recipe-detail', extra: recipe);
          },
        );
      },
    );
  }
}