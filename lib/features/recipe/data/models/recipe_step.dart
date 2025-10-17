class RecipeStep {
  final String title;
  final String description;
  final String? photoUrl;

  RecipeStep({
    required this.title,
    required this.description,
    this.photoUrl,
  });

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'photoUrl': photoUrl,
    };
  }
}
