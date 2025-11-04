import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../recipe/presentation/screens/author_page.dart';

class UserListPage extends StatelessWidget {
  final String userId;
  final String title;
  final bool showFollowers;
  final UserEntity currentUser;

  const UserListPage({
    super.key,
    required this.userId,
    required this.title,
    required this.showFollowers,
    required this.currentUser,
  });

  /// Load followers or following users from Firestore
  Future<List<UserEntity>> _loadUsers() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    if (!userDoc.exists) return [];

    final data = userDoc.data()!;
    final List<String> ids = List<String>.from(
      showFollowers ? (data['followers'] ?? []) : (data['following'] ?? []),
    );

    if (ids.isEmpty) return [];

    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return usersSnapshot.docs.map((d) {
      final map = d.data();
      return UserEntity(
        id: d.id,
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        photo: map['photo'],
        role: map['role'] ?? 'user',
        vip: map['vip'] ?? false,
        recipes: List<String>.from(map['recipes'] ?? []),
        followers: List<String>.from(map['followers'] ?? []),
        following: List<String>.from(map['following'] ?? []),
        savedRecipes: List<String>.from(map['savedRecipes'] ?? []),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<UserEntity>>(
        future: _loadUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                showFollowers ? 'Chưa có người theo dõi' : 'Chưa theo dõi ai',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: u.photo != null && u.photo!.isNotEmpty
                      ? NetworkImage(u.photo!)
                      : null,
                  child: (u.photo == null || u.photo!.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(u.name),
                subtitle: Text(u.email),
                trailing: Text(
                  '${u.followers.length} followers',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  // SỬA LẠI: Dùng đúng route path và format extra
                  context.push(
                    '/author/${u.id}', // ← Dùng path parameters
                    extra: currentUser, // ← Chỉ truyền currentUser, không dùng Map
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}