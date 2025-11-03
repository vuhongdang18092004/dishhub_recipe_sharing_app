import '../../data/models/recipe_step.dart';
import '../../data/models/recipe_comment.dart';

class RecipeEntity {
  final String id;
  final String title; // Tên công thức
  final String description;
  final List<String> photoUrls;
  final String? videoUrl;
  final String creatorId;
  final List<String> ingredients; // Nguyên liệu
  final List<RecipeStep> steps;
  final List<String> likes;
  final List<String> savedBy;
  final List<RecipeComment> comments;
  final List<String> tags; // Thẻ (tags)

  final List<String> searchKeywords; // <-- THÊM TRƯỜNG NÀY

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
    this.comments = const [],
    this.tags = const [],
    
    // Thêm giá trị mặc định để code cũ không bị lỗi
    this.searchKeywords = const [], 
  });
}