import '../entities/recipe_entity.dart';
import '../../data/models/recipe_comment.dart';

abstract class RecipeRepository {
  Future<List<RecipeEntity>> getAllRecipes();

  Future<RecipeEntity?> getRecipeById(String id);

  Future<void> addRecipe(RecipeEntity recipe);

  Future<void> updateRecipe(RecipeEntity recipe);

  Future<void> deleteRecipe(String id);

  Future<void> toggleLike(String recipeId, String userId);
  
  Future<List<RecipeEntity>> searchRecipes(String query);

  Future<void> addComment(String recipeId, RecipeComment comment);
}
