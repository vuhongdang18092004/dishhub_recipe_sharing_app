import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/home_page.dart';
import '../features/auth/presentation/screens/add_recipe_page.dart';
import '../features/auth/presentation/screens/setting_page.dart';
import '../features/auth/presentation/screens/login_page.dart';
import '../features/auth/domain/entities/user_entity.dart';

class AppRouter {
  final UserEntity? initialUser;

  AppRouter({this.initialUser});

  late final GoRouter router = GoRouter(
    initialLocation: initialUser != null ? "/home" : "/login",
    routes: [
      GoRoute(
        path: "/login",
        builder: (context, state) => const LoginPage(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final user = state.extra as UserEntity? ?? initialUser;

          return ScaffoldWithNavBar(
            navigationShell: navigationShell,
            userAvatarUrl: user?.photo,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/home",
                pageBuilder: (context, state) {
                  final user = state.extra as UserEntity? ?? initialUser;
                  if (user == null) {
                    // Nếu không có user thì chuyển về login
                    return NoTransitionPage(child: const LoginPage());
                  }
                  return NoTransitionPage(child: HomePage(user: user));
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/add",
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AddRecipePage()),
              ),
            ],
          ),
          
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/settings",
                pageBuilder: (context, state) {
                  final user = state.extra as UserEntity? ?? initialUser;
                  if (user == null) {
                    return NoTransitionPage(child: const LoginPage());
                  }
                  return NoTransitionPage(child: SettingPage(user: user));
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final String? userAvatarUrl;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
    this.userAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  userAvatarUrl != null ? NetworkImage(userAvatarUrl!) : null,
              child: userAvatarUrl == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
