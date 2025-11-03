part of 'recipe_bloc.dart';

abstract class RecipeEvent extends Equatable {
  const RecipeEvent();
  @override
  List<Object?> get props => [];
}

class LoadAllRecipes extends RecipeEvent {}

class AddNewRecipe extends RecipeEvent {
  final RecipeEntity recipe;
  const AddNewRecipe(this.recipe);
  @override
  List<Object?> get props => [recipe];
}

class UpdateExistingRecipe extends RecipeEvent {
  final RecipeEntity recipe;
  const UpdateExistingRecipe(this.recipe);
  @override
  List<Object?> get props => [recipe];
}

class DeleteRecipeById extends RecipeEvent {
  final String id;
  const DeleteRecipeById(this.id);
  @override
  List<Object?> get props => [id];
}

// *** PHẦN CỦA ĐỒNG ĐỘI (PHẢI GIỮ LẠI) ***
class ToggleLike extends RecipeEvent {
  final String recipeId;
  final String userId;
  const ToggleLike({required this.recipeId, required this.userId});

  @override
  List<Object?> get props => [recipeId, userId];
}
// *** HẾT PHẦN CỦA ĐỒNG ĐỘI ***

// *** PHẦN CỦA BẠN (ĐÃ THÊM VÀO) ***
class SearchRecipesEvent extends RecipeEvent {
  final String query;
  const SearchRecipesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
// *** HẾT PHẦN CỦA BẠN ***