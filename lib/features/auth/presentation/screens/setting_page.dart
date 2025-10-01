import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';

class SettingPage extends StatelessWidget {

  final UserEntity user;
  const SettingPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOut());
              context.go('/login');
            },
            tooltip: "Logout",
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Đây là trang Settings",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
