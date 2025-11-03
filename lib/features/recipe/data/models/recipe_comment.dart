import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeComment {
  final String userId;
  final String comment;
  final DateTime createdAt;

  const RecipeComment({
    required this.userId,
    required this.comment,
    required this.createdAt,
  });

  factory RecipeComment.fromMap(Map<String, dynamic> map) {
    return RecipeComment(
      userId: map['userId'] ?? '',
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}
