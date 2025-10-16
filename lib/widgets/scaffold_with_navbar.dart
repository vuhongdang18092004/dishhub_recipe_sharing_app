import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'drawer_widget.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color.fromRGBO(240, 144, 48, 1);
    final titles = ["Home", "Add", "Settings"];
    final currentTitle = titles[navigationShell.currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: const AppDrawer(),
      body: navigationShell,

      bottomNavigationBar: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          String? avatarUrl;
          if (state is AuthAuthenticated) {
            avatarUrl = state.user.photo;
          }

          return BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => navigationShell.goBranch(index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              const BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
              BottomNavigationBarItem(
                icon: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                label: "Settings",
              ),
            ],
          );
        },
      ),
    );
  }
}
