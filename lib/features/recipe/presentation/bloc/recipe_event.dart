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

class ToggleLike extends RecipeEvent {
  final String recipeId;
  final String userId;
  
  const ToggleLike({required this.recipeId, required this.userId});

  @override
  List<Object?> get props => [recipeId, userId];
}

class SearchRecipesEvent extends RecipeEvent {
  final String query;
  
  const SearchRecipesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class AddNewComment extends RecipeEvent {
  final String recipeId;
  final RecipeComment comment;
  
  const AddNewComment({required this.recipeId, required this.comment});

  @override
  List<Object?> get props => [recipeId, comment];
}

class DeleteComment extends RecipeEvent {
  final String recipeId;
  final String commentId;

  const DeleteComment({required this.recipeId, required this.commentId});

  @override
  List<Object?> get props => [recipeId, commentId];
}