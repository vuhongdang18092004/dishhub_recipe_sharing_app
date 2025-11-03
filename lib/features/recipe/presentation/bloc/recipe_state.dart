part of 'recipe_bloc.dart';

abstract class RecipeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final List<RecipeEntity> recipes;
  RecipeLoaded(this.recipes);
  @override
  List<Object?> get props => [recipes];
}

class RecipeError extends RecipeState {
  final String message;
  RecipeError(this.message);
  @override
  List<Object?> get props => [message];
}

class RecipeSearchLoading extends RecipeState {}

class RecipeSearchLoaded extends RecipeState {
  final List<RecipeEntity> searchResults;
  RecipeSearchLoaded(this.searchResults);

  @override
  List<Object?> get props => [searchResults];
}

class RecipeSearchError extends RecipeState {
  final String message;
  RecipeSearchError(this.message);

  @override
  List<Object?> get props => [message];
}