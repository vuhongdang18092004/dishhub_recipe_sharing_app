import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/usecases/recipe_usecases.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final GetAllRecipes getAllRecipes;
  final GetRecipeById getRecipeById;
  final AddRecipe addRecipe;
  final UpdateRecipe updateRecipe;
  final DeleteRecipe deleteRecipe;
  final ToggleLikeRecipe toggleLikeRecipe;

  RecipeBloc({
    required this.getAllRecipes,
    required this.getRecipeById,
    required this.addRecipe,
    required this.updateRecipe,
    required this.deleteRecipe,
    required this.toggleLikeRecipe,
  }) : super(RecipeInitial()) {
    on<LoadAllRecipes>((event, emit) async {
      emit(RecipeLoading());
      try {
        final recipes = await getAllRecipes();
        emit(RecipeLoaded(recipes));
      } catch (e) {
        emit(RecipeError(e.toString()));
      }
    });

    on<AddNewRecipe>((event, emit) async {
      try {
        await addRecipe(event.recipe);
        add(LoadAllRecipes());
      } catch (e) {
        emit(RecipeError(e.toString()));
      }
    });

    on<UpdateExistingRecipe>((event, emit) async {
      try {
        await updateRecipe(event.recipe);
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
      try {
        await toggleLikeRecipe(event.recipeId, event.userId);
        // Refresh list so counts update for all listeners
        add(LoadAllRecipes());
      } catch (e) {
        emit(RecipeError(e.toString()));
      }
    });
  }
}
