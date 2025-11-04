import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RecipeComment extends Equatable {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String comment;
  final DateTime createdAt;

  const RecipeComment({
    required this.userId,
    required this.userName, 
    this.userPhotoUrl,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    userId, 
    userName, 
    userPhotoUrl, 
    comment, 
    createdAt
  ];

  factory RecipeComment.fromMap(Map<String, dynamic> map) {
    return RecipeComment(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Ẩn danh',
      userPhotoUrl: map['userPhotoUrl'],
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

Map<String, dynamic> toMap() {
  return {
    'userId': userId,
    'userName': userName, 
    'userPhotoUrl': userPhotoUrl,
    'comment': comment,
    'createdAt': Timestamp.fromDate(createdAt), 
  };
}

  RecipeComment copyWith({
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? comment,
    DateTime? createdAt,
  }) {
    return RecipeComment(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}