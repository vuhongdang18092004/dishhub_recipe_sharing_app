import '../entities/recipe_entity.dart';
import '../repositories/recipe_repository.dart';

class GetAllRecipes {
  final RecipeRepository repository;
  GetAllRecipes(this.repository);
  Future<List<RecipeEntity>> call() => repository.getAllRecipes();
}

class GetRecipeById {
  final RecipeRepository repository;
  GetRecipeById(this.repository);
  Future<RecipeEntity?> call(String id) => repository.getRecipeById(id);
}

class AddRecipe {
  final RecipeRepository repository;
  AddRecipe(this.repository);
  Future<void> call(RecipeEntity recipe) => repository.addRecipe(recipe);
}

class UpdateRecipe {
  final RecipeRepository repository;
  UpdateRecipe(this.repository);
  Future<void> call(RecipeEntity recipe) => repository.updateRecipe(recipe);
}

class DeleteRecipe {
  final RecipeRepository repository;
  DeleteRecipe(this.repository);
  Future<void> call(String id) => repository.deleteRecipe(id);
}

// *** PHẦN CỦA ĐỒNG ĐỘI (GIỮ LẠI) ***
class ToggleLikeRecipe {
  final RecipeRepository repository;
  ToggleLikeRecipe(this.repository);

  Future<void> call(String recipeId, String userId) =>
      repository.toggleLike(recipeId, userId);
}
// *** HẾT PHẦN CỦA ĐỒNG ĐỘI ***


// *** PHẦN CỦA BẠN (THÊM VÀO) ***
class SearchRecipes {
  final RecipeRepository repository;
  SearchRecipes(this.repository);

  Future<List<RecipeEntity>> call(String query) async {
    // Logic nghiệp vụ: không tìm kiếm nếu chuỗi rỗng
    if (query.isEmpty) {
      return [];
    }
    // Chuyển sang chữ thường để đảm bảo
    return repository.searchRecipes(query.toLowerCase());
  }
}
// *** HẾT PHẦN CỦA BẠN ***