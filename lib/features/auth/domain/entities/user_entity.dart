class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? photo;
  final String role;
  final bool vip;

  final List<String> recipes;
  final List<String> followers;
  final List<String> following;
  final List<String> savedRecipes;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photo,
    this.role = "user",
    this.vip = false,
    this.recipes = const [],
    this.followers = const [],
    this.following = const [],
    this.savedRecipes = const [],
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? photo,
    String? role,
    bool? vip,
    List<String>? recipes,
    List<String>? followers,
    List<String>? following,
    List<String>? savedRecipes,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photo: photo ?? this.photo,
      role: role ?? this.role,
      vip: vip ?? this.vip,
      recipes: recipes ?? this.recipes,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      savedRecipes: savedRecipes ?? this.savedRecipes,
    );
  }
}
