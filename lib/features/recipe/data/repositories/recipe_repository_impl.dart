import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final FirebaseFirestore firestore;
  final CollectionReference recipesCollection;

  RecipeRepositoryImpl(this.firestore)
      : recipesCollection = firestore.collection('recipes');

  @override
  Future<List<RecipeEntity>> getAllRecipes() async {
    final snapshot = await recipesCollection.get();
    return snapshot.docs
        .map((doc) => RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  @override
  Future<RecipeEntity?> getRecipeById(String id) async {
    final doc = await recipesCollection.doc(id).get();
    if (!doc.exists) return null;
    return RecipeModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  @override
  Future<void> addRecipe(RecipeEntity recipe) async {
    final recipeModel = RecipeModel(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      photoUrls: recipe.photoUrls,
      videoUrl: recipe.videoUrl,
      creatorId: recipe.creatorId,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      likes: recipe.likes,
      savedBy: recipe.savedBy,
    );

    await recipesCollection.add(recipeModel.toMap());
  }

  @override
  Future<void> updateRecipe(RecipeEntity recipe) async {
    final recipeModel = RecipeModel(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      photoUrls: recipe.photoUrls,
      videoUrl: recipe.videoUrl,
      creatorId: recipe.creatorId,
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      likes: recipe.likes,
      savedBy: recipe.savedBy,
    );

    await recipesCollection.doc(recipe.id).update(recipeModel.toMap());
  }

  @override
  Future<void> toggleLike(String recipeId, String userId) async {
    final docRef = recipesCollection.doc(recipeId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final likes = List<String>.from(data['likes'] ?? []);

    // If user already liked, remove; otherwise add. Use atomic updates to avoid races.
    if (likes.contains(userId)) {
      await docRef.update({'likes': FieldValue.arrayRemove([userId])});
    } else {
      await docRef.update({'likes': FieldValue.arrayUnion([userId])});
    }
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await recipesCollection.doc(id).delete();
  }
}
