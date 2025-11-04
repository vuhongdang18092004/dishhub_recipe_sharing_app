import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/usecases/recipe_usecases.dart';
import '../../data/models/recipe_comment.dart'; 

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
  final AddComment? addComment; 

  List<RecipeEntity> _allRecipes = [];

  RecipeBloc({
    required this.getAllRecipes,
    required this.getRecipeById,
    required this.addRecipe,
    required this.updateRecipe,
    required this.deleteRecipe,
    required this.toggleLikeRecipe,
    required this.searchRecipes,
    this.addComment, 
  }) : super(RecipeInitial()) {
    on<LoadAllRecipes>(_onLoadAllRecipes);

    on<AddNewRecipe>(_onAddRecipe);
    on<UpdateExistingRecipe>(_onUpdateRecipe);
    on<DeleteRecipeById>(_onDeleteRecipe);

    on<ToggleLike>(_onToggleLike);
    on<AddNewComment>(_onAddComment);

    on<SearchRecipesEvent>(
      _onSearchRecipes,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }

  Future<void> _onLoadAllRecipes(
    LoadAllRecipes event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading());
    try {
      final recipes = await getAllRecipes();
      _allRecipes = recipes;
      emit(RecipeLoaded(recipes));
    } catch (e) {
      print('Lỗi tải công thức: $e');
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> _onAddRecipe(
    AddNewRecipe event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      await addRecipe(event.recipe);
      add(LoadAllRecipes());
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> _onUpdateRecipe(
    UpdateExistingRecipe event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      await updateRecipe(event.recipe);
      add(LoadAllRecipes());
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> _onDeleteRecipe(
    DeleteRecipeById event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      await deleteRecipe(event.id);
      add(LoadAllRecipes());
    } catch (e) {
      emit(RecipeError(e.toString()));
    }
  }

  Future<void> _onToggleLike(
    ToggleLike event,
    Emitter<RecipeState> emit,
  ) async {
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

        final updatedRecipe = recipe.copyWith(likes: newLikes); 

        updatedList[index] = updatedRecipe;
        emit(RecipeLoaded(updatedList)); 
      }
    }

    try {
      await toggleLikeRecipe(event.recipeId, event.userId);
      add(LoadAllRecipes()); 
    } catch (e) {
      emit(RecipeError(e.toString())); 
    }
  }

  Future<void> _onAddComment(
    AddNewComment event,
    Emitter<RecipeState> emit,
  ) async {
    if (addComment == null) {
      print('Lỗi cấu hình: UseCase AddComment chưa được cung cấp.');
      emit(RecipeError("Cảnh báo: Tính năng bình luận chưa được kích hoạt/cấu hình API."));
      return;
    }

    try {
      await addComment!(event.recipeId, event.comment);
      add(LoadAllRecipes()); 

    } catch (e) {
      print('Lỗi gửi comment lên Firestore: $e'); 
      emit(RecipeError('Không thể thêm bình luận: ${e.toString()}'));
    }
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
    try {
      final recipes = await searchRecipes(event.query);
      emit(RecipeSearchLoaded(recipes));
    } catch (e) {
      emit(RecipeSearchError(e.toString()));
    }
  }
}