import '../../data/models/recipe_step.dart';
import '../../data/models/recipe_comment.dart';

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
  final List<RecipeComment> comments;
  final List<String> tags;
  final List<String> searchKeywords;

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
    this.searchKeywords = const [],
  });

  /// ✅ copyWith giúp cập nhật 1 phần dữ liệu mà không tạo lại toàn bộ object
  RecipeEntity copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? photoUrls,
    String? videoUrl,
    String? creatorId,
    List<String>? ingredients,
    List<RecipeStep>? steps,
    List<String>? likes,
    List<String>? savedBy,
    List<RecipeComment>? comments,
    List<String>? tags,
    List<String>? searchKeywords,
  }) {
    return RecipeEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      creatorId: creatorId ?? this.creatorId,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      likes: likes ?? this.likes,
      savedBy: savedBy ?? this.savedBy,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
      searchKeywords: searchKeywords ?? this.searchKeywords,
    );
  }

  /// ✅ Chuyển RecipeEntity -> Map (dùng để lưu Firestore / local DB)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photoUrls': photoUrls,
      'videoUrl': videoUrl,
      'creatorId': creatorId,
      'ingredients': ingredients,
      'steps': steps.map((x) => x.toMap()).toList(),
      'likes': likes,
      'savedBy': savedBy,
      'comments': comments.map((x) => x.toMap()).toList(),
      'tags': tags,
      'searchKeywords': searchKeywords,
    };
  }

  /// ✅ Chuyển Map -> RecipeEntity (dùng khi đọc Firestore / local DB)
  factory RecipeEntity.fromMap(Map<String, dynamic> map) {
    return RecipeEntity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      videoUrl: map['videoUrl'],
      creatorId: map['creatorId'] ?? '',
      ingredients: List<String>.from(map['ingredients'] ?? []),
      steps: (map['steps'] as List<dynamic>?)
              ?.map((x) => RecipeStep.fromMap(Map<String, dynamic>.from(x)))
              .toList() ??
          [],
      likes: List<String>.from(map['likes'] ?? []),
      savedBy: List<String>.from(map['savedBy'] ?? []),
      comments: (map['comments'] as List<dynamic>?)
              ?.map((x) => RecipeComment.fromMap(Map<String, dynamic>.from(x)))
              .toList() ??
          [],
      tags: List<String>.from(map['tags'] ?? []),
      searchKeywords: List<String>.from(map['searchKeywords'] ?? []),
    );
  }

  /// ✅ So sánh hai RecipeEntity
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecipeEntity &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        _listEquals(other.photoUrls, photoUrls) &&
        other.videoUrl == videoUrl &&
        other.creatorId == creatorId &&
        _listEquals(other.ingredients, ingredients) &&
        _listEquals(other.steps, steps) &&
        _listEquals(other.likes, likes) &&
        _listEquals(other.savedBy, savedBy) &&
        _listEquals(other.comments, comments) &&
        _listEquals(other.tags, tags) &&
        _listEquals(other.searchKeywords, searchKeywords);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      photoUrls.hashCode ^
      videoUrl.hashCode ^
      creatorId.hashCode ^
      ingredients.hashCode ^
      steps.hashCode ^
      likes.hashCode ^
      savedBy.hashCode ^
      comments.hashCode ^
      tags.hashCode ^
      searchKeywords.hashCode;

  @override
  String toString() {
    return 'RecipeEntity(id: $id, title: $title, creatorId: $creatorId)';
  }

  /// 🔧 Helper function để so sánh 2 list
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
