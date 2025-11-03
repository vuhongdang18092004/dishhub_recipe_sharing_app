import '../../domain/entities/recipe_entity.dart';
import 'recipe_step.dart';
import 'recipe_comment.dart';

class RecipeModel extends RecipeEntity {
  const RecipeModel({
    required String id,
    required String title,
    required String description,
    List<String> photoUrls = const [],
    String? videoUrl,
    required String creatorId,
    required List<String> ingredients,
    required List<RecipeStep> steps,
    List<String> likes = const [],
    List<String> savedBy = const [],
    List<RecipeComment> comments = const [],
    List<String> tags = const [],
    List<String> searchKeywords = const [], // <-- THÊM DÒNG NÀY
  }) : super(
          id: id,
          title: title,
          description: description,
          photoUrls: photoUrls,
          videoUrl: videoUrl,
          creatorId: creatorId,
          ingredients: ingredients,
          steps: steps,
          likes: likes,
          savedBy: savedBy,
          comments: comments,
          tags: tags,
          searchKeywords: searchKeywords, // <-- THÊM DÒNG NÀY
        );

  factory RecipeModel.fromMap(Map<String, dynamic> map, String docId) {
    return RecipeModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      videoUrl: map['videoUrl'],
      creatorId: map['creatorId'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: (map['steps'] as List<dynamic>? ?? [])
          .map((e) => RecipeStep.fromMap(e))
          .toList(),
      likes: List<String>.from(map['likes'] ?? []),
      savedBy: List<String>.from(map['savedBy'] ?? []),
      comments: (map['comments'] as List<dynamic>? ?? [])
          .map((e) => RecipeComment.fromMap(e))
          .toList(),
      tags: List<String>.from(map['tags'] ?? []),
      // Đọc từ firestore, nếu không có thì trả về mảng rỗng
      searchKeywords: List<String>.from(map['searchKeywords'] ?? []), // <-- THÊM DÒNG NÀY
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'photoUrls': photoUrls,
      'videoUrl': videoUrl,
      'creatorId': creatorId,
      'ingredients': ingredients,
      'steps': steps.map((e) => e.toMap()).toList(),
      'likes': likes,
      'savedBy': savedBy,
      'comments': comments.map((e) => e.toMap()).toList(),
      'tags': tags,
      // Ghi vào firestore
      'searchKeywords': searchKeywords, // <-- THÊM DÒNG NÀY
    };
  }
}