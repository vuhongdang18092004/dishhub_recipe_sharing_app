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

class ToggleLikeRecipe {
  final RecipeRepository repository;
  ToggleLikeRecipe(this.repository);

  Future<void> call(String recipeId, String userId) => repository.toggleLike(recipeId, userId);
}
