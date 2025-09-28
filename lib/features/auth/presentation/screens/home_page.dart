import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';

class HomePage extends StatelessWidget {
  final UserEntity user;

  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang chính")),
      body: Center(
        child: Text(
          "Hello, ${user.name}!",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
