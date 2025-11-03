import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dishhub_recipe_sharing_app/core/utils/generate_keywords.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/usecases/recipe_usecases.dart';
import 'package:rxdart/rxdart.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final GetAllRecipes getAllRecipes;
  final GetRecipeById getRecipeById;
  final AddRecipe addRecipe;
  final UpdateRecipe updateRecipe;
  final DeleteRecipe deleteRecipe;
  final ToggleLikeRecipe toggleLikeRecipe;
  final SearchRecipes searchRecipes;

  List<RecipeEntity> _allRecipes = [];

  RecipeBloc({
    required this.getAllRecipes,
    required this.getRecipeById,
    required this.addRecipe,
    required this.updateRecipe,
    required this.deleteRecipe,
    required this.toggleLikeRecipe,
    required this.searchRecipes,
  }) : super(RecipeInitial()) {
    on<LoadAllRecipes>((event, emit) async {
      emit(RecipeLoading());
      try {
        final recipes = await getAllRecipes();
        _allRecipes = recipes;
        emit(RecipeLoaded(recipes));
      } catch (e) {
        emit(RecipeError(e.toString()));
      }
    });

    on<AddNewRecipe>((event, emit) async {
      try {
        final keywords = generateKeywords(
          event.recipe.title,
          event.recipe.ingredients,
          event.recipe.tags,
        );
        final recipeWithKeywords = RecipeEntity(
          id: event.recipe.id,
          title: event.recipe.title,
          description: event.recipe.description,
          photoUrls: event.recipe.photoUrls,
          videoUrl: event.recipe.videoUrl,
          creatorId: event.recipe.creatorId,
          ingredients: event.recipe.ingredients,
          steps: event.recipe.steps,
          likes: event.recipe.likes,
          savedBy: event.recipe.savedBy,
          comments: event.recipe.comments,
          tags: event.recipe.tags,
          searchKeywords: keywords,
        );

        await addRecipe(recipeWithKeywords);
        add(LoadAllRecipes());
      } catch (e) {
        emit(RecipeError(e.toString()));
      }
    });

    on<UpdateExistingRecipe>((event, emit) async {
      try {
        final keywords = generateKeywords(
          event.recipe.title,
          event.recipe.ingredients,
          event.recipe.tags,
        );
        final recipeWithKeywords = RecipeEntity(
          id: event.recipe.id,
          title: event.recipe.title,
          description: event.recipe.description,
          photoUrls: event.recipe.photoUrls,
          videoUrl: event.recipe.videoUrl,
          creatorId: event.recipe.creatorId,
          ingredients: event.recipe.ingredients,
          steps: event.recipe.steps,
          likes: event.recipe.likes,
          savedBy: event.recipe.savedBy,
          comments: event.recipe.comments,
          tags: event.recipe.tags,
          searchKeywords: keywords,
        );

        await updateRecipe(recipeWithKeywords);
        add(LoadAllRecipes());
      } catch (e) {
        emit(RecipeError(e.toString()));
      }
    });

    on<DeleteRecipeById>((event, emit) async {
      try {
        await deleteRecipe(event.id);
        add(LoadAllRecipes());
      } catch (e) {
        emit(RecipeError(e.toString()));
      }
    });

    on<ToggleLike>((event, emit) async {
      final currentState = state;
      if (currentState is RecipeLoaded) {
        final updatedList = List<RecipeEntity>.from(currentState.recipes);
        final index = updatedList.indexWhere((r) => r.id == event.recipeId);
        if (index != -1) {
          final recipe = updatedList[index];
          final newLikes = List<String>.from(recipe.likes);
          if (newLikes.contains(event.userId)) {
            newLikes.remove(event.userId);
          } else {
            newLikes.add(event.userId);
          }

          final updatedRecipe = RecipeEntity(
            id: recipe.id,
            title: recipe.title,
            description: recipe.description,
            photoUrls: recipe.photoUrls,
            videoUrl: recipe.videoUrl,
            creatorId: recipe.creatorId,
            ingredients: recipe.ingredients,
            steps: recipe.steps,
            likes: newLikes,
            savedBy: recipe.savedBy,
            comments: recipe.comments,
            tags: recipe.tags,
          );

          updatedList[index] = updatedRecipe;
          emit(RecipeLoaded(updatedList));

          try {
            await toggleLikeRecipe(event.recipeId, event.userId);
            add(LoadAllRecipes());
          } catch (e) {
            emit(currentState);
            emit(RecipeError(e.toString()));
          }
          return;
        }
      }

      try {
        await toggleLikeRecipe(event.recipeId, event.userId);
        add(LoadAllRecipes());
      } catch (e) {
        emit(RecipeError(e.toString()));
      }
    });

    on<SearchRecipesEvent>(
      _onSearchRecipes,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }

  Future<void> _onSearchRecipes(
    SearchRecipesEvent event,
    Emitter<RecipeState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(RecipeLoaded(_allRecipes));
      return;
    }

    emit(RecipeSearchLoading());

    final firstWord = event.query.split(' ').first;

    try {
      final recipes = await searchRecipes(firstWord);
      emit(RecipeSearchLoaded(recipes));
    } catch (e) {
      emit(RecipeSearchError(e.toString()));
    }
  }
}
