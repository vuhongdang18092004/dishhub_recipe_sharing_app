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
}
