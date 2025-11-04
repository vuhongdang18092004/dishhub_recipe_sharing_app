part of 'recipe_bloc.dart';

abstract class RecipeState extends Equatable {
  const RecipeState();
  
  @override
  List<Object?> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeAdding extends RecipeState {}

class RecipeUpdating extends RecipeState {}

class RecipeDeleting extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<RecipeEntity> recipes;
  
  const RecipeLoaded(this.recipes);
  
  @override
  List<Object?> get props => [recipes];
}

class RecipeAddedSuccess extends RecipeState {
  final RecipeEntity recipe;
  
  const RecipeAddedSuccess(this.recipe);
  
  @override
  List<Object> get props => [recipe];
}

class RecipeUpdatedSuccess extends RecipeState {
  final RecipeEntity recipe;
  
  const RecipeUpdatedSuccess(this.recipe);
  
  @override
  List<Object> get props => [recipe];
}

class RecipeDeletedSuccess extends RecipeState {
  final String recipeId;
  
  const RecipeDeletedSuccess(this.recipeId);
  
  @override
  List<Object> get props => [recipeId];
}

class RecipeError extends RecipeState {
  final String message;
  
  const RecipeError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class RecipeSearchLoading extends RecipeState {}

class RecipeSearchLoaded extends RecipeState {
  final List<RecipeEntity> searchResults;
  
  const RecipeSearchLoaded(this.searchResults);

  @override
  List<Object?> get props => [searchResults];
}

class RecipeSearchError extends RecipeState {
  final String message;
  
  const RecipeSearchError(this.message);

  @override
  List<Object?> get props => [message];
}