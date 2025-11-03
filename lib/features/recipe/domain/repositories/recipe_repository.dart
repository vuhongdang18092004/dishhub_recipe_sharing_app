import '../entities/recipe_entity.dart';

abstract class RecipeRepository {
  Future<List<RecipeEntity>> getAllRecipes();

  Future<RecipeEntity?> getRecipeById(String id);

  Future<void> addRecipe(RecipeEntity recipe);

  Future<void> updateRecipe(RecipeEntity recipe);

  Future<void> deleteRecipe(String id);
  
  Future<void> toggleLike(String recipeId, String userId);
}
