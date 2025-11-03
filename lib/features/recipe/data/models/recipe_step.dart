class RecipeStep {
  final String description;
  final String? photoUrl;

  RecipeStep({
    required this.description,
    this.photoUrl,
  });

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      description: map['description'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'photoUrl': photoUrl,
    };
  }
}
