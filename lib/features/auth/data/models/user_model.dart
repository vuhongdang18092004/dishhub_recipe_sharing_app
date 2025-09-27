import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String name,
    required String email,
    String? photo,
    String role = 'user',
    bool vip = false,
    List<String> recipes = const [],
    List<String> followers = const [],
    List<String> following = const [],
    List<String> savedRecipes = const [],
  }) : super(
          id: id,
          name: name,
          email: email,
          photo: photo,
          role: role,
          vip: vip,
          recipes: recipes,
          followers: followers,
          following: following,
          savedRecipes: savedRecipes,
        );

  factory UserModel.fromMap(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photo: json['photo'],
      role: json['role'] ?? 'user',
      vip: json['vip'] ?? false,
      recipes: List<String>.from(json['recipes'] ?? []),
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      savedRecipes: List<String>.from(json['savedRecipes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photo': photo,
      'role': role,
      'vip': vip,
      'recipes': recipes,
      'followers': followers,
      'following': following,
      'savedRecipes': savedRecipes,
    };
  }

  UserEntity toEntity() => this;
}
