import '../../data/models/recipe_step.dart';

class RecipeEntity {
  final String id;
  final String title;
  final String description;
  final List<String> photoUrls;
  final String? videoUrl;    
  final String creatorId;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final List<String> likes;
  final List<String> savedBy;

  const RecipeEntity({
    required this.id,
    required this.title,
    required this.description,
    this.photoUrls = const [],
    this.videoUrl,
    required this.creatorId,
    required this.ingredients,
    required this.steps,
    this.likes = const [],
    this.savedBy = const [],
  });
}
