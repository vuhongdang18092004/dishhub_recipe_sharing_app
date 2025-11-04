import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/entities/user_entity.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.id)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _buildUserInterface(context, user);
              }

              final userData =
                  snapshot.data!.data() as Map<String, dynamic>? ?? {};
              final updatedFollowers = List<String>.from(
                userData['followers'] ?? [],
              );
              final updatedFollowing = List<String>.from(
                userData['following'] ?? [],
              );

              final updatedUser = user.copyWith(
                followers: updatedFollowers,
                following: updatedFollowing,
              );

              return _buildUserInterface(context, updatedUser);
            },
          );
        },
      ),
    );
  }

  Widget _buildUserInterface(BuildContext context, UserEntity user) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),

        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: user.photo != null && user.photo!.isNotEmpty
                    ? NetworkImage(user.photo!)
                    : null,
                child: (user.photo == null || user.photo!.isEmpty)
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                user.email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
        const Divider(),

        ListTile(
          leading: const Icon(Icons.menu_book),
          title: const Text("Công thức của bạn"),
          subtitle: const Text("Quản lý các công thức bạn đã tạo"),
          onTap: () {
            context.push('/my-recipes', extra: user);
          },
        ),

        ListTile(
          leading: const Icon(Icons.bookmark_outline),
          title: const Text("Kho lưu trữ công thức"),
          subtitle: const Text("Xem lại các công thức bạn đã lưu"),
          onTap: () {
            context.push('/saved-recipes', extra: user);
          },
        ),

        const Divider(height: 32),

        ListTile(
          leading: const Icon(Icons.person_add_alt_1),
          title: const Text("Người bạn theo dõi"),
          subtitle: Text("${user.following.length} người"),
          onTap: () {
            context.push(
              '/following-list',
              extra: {
                'currentUser': user,
                'userId': user.id,
                'title': 'Người bạn theo dõi',
              },
            );
          },
        ),

        ListTile(
          leading: const Icon(Icons.people),
          title: const Text("Người theo dõi bạn"),
          subtitle: Text("${user.followers.length} người"),
          onTap: () {
            context.push(
              '/followers-list',
              extra: {
                'currentUser': user,
                'userId': user.id,
                'title': 'Người theo dõi bạn',
              },
            );
          },
        ),

        const Divider(height: 32),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Tài khoản",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text("Đổi mật khẩu"),
          onTap: () {
            context.push('/change-password', extra: user);
          },
        ),
        ListTile(
          leading: const Icon(Icons.manage_accounts_outlined),
          title: const Text("Quản lý thông tin cá nhân"),
          onTap: () {
            context.push('/settings/account-info', extra: user);
          },
        ),

        const Divider(height: 32),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Ứng dụng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text("Về ứng dụng"),
          onTap: () {
            context.push('/about');
          },
        ),
        ListTile(
          leading: const Icon(Icons.feedback_outlined),
          title: const Text("Liên hệ & góp ý"),
          onTap: () {
            context.push('/feedback');
          },
        ),

        const Divider(height: 32),

        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Hệ thống",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 24),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text(
              "Đăng xuất",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOut());
              context.go('/login');
            },
          ),
        ),
      ],
    );
  }
}
