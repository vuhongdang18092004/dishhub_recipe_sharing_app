import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/home_page.dart';
import '../features/auth/presentation/screens/add_recipe_page.dart';
import '../features/auth/presentation/screens/setting_page.dart';
import '../features/auth/presentation/screens/login_page.dart';
import '../features/auth/domain/entities/user_entity.dart';
import '../widgets/scaffold_with_navbar.dart';

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
                  if (user == null) return NoTransitionPage(child: const LoginPage());
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
                  if (user == null) return NoTransitionPage(child: const LoginPage());
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
