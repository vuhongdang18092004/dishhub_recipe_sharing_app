import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/recipe/presentation/screens/home_page.dart';
import '../features/recipe/presentation/screens/add_recipe_page.dart';
import '../features/auth/presentation/screens/setting_page.dart';
import '../features/auth/presentation/screens/login_page.dart';
import '../features/auth/presentation/screens/signup_page.dart';
import '../features/auth/presentation/screens/account_info_page.dart';
import '../features/auth/presentation/screens/saved_recipes_page.dart';
import '../features/auth/domain/entities/user_entity.dart';
import '../features/recipe/presentation/screens/recipe_detail_page.dart';
import '../features/recipe/presentation/screens/search_page.dart';
import '../features/recipe/presentation/screens/my_recipes_page.dart';
import '../features/recipe/presentation/screens/edit_recipe_page.dart';
import '../features/recipe/domain/entities/recipe_entity.dart';
import '../widgets/scaffold_with_navbar.dart';

class AppRouter {
  final UserEntity? initialUser;

  AppRouter({this.initialUser});

  late final GoRouter router = GoRouter(
    initialLocation: initialUser != null ? '/home' : '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),

      GoRoute(
        path: '/recipe-detail',
        pageBuilder: (context, state) {
          final recipe = state.extra as RecipeEntity;
          return CustomTransitionPage(
            key: state.pageKey,
            child: RecipeDetailPage(recipe: recipe),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
          );
        },
      ),

      GoRoute(
        path: '/search',
        pageBuilder: (context, state) {
          final user = state.extra as UserEntity;
          return MaterialPage(
            key: state.pageKey,
            child: SearchPage(user: user),
          );
        },
      ),

      GoRoute(
        path: '/my-recipes',
        pageBuilder: (context, state) {
          final user = state.extra as UserEntity;
          return MaterialPage(
            key: state.pageKey,
            child: MyRecipesPage(user: user),
          );
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) {
                  final user = state.extra is UserEntity
                      ? state.extra as UserEntity
                      : initialUser;
                  if (user == null)
                    return const NoTransitionPage(child: LoginPage());
                  return NoTransitionPage(child: HomePage(user: user));
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/add',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AddRecipePage()),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: SettingPage()),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/settings/account-info',
        pageBuilder: (context, state) {
          final user = state.extra is UserEntity
              ? state.extra as UserEntity
              : initialUser;
          if (user == null) return const MaterialPage(child: LoginPage());

          return CustomTransitionPage(
            key: state.pageKey,
            child: AccountInfoPage(user: user),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
          );
        },
      ),

      GoRoute(
        path: '/saved-recipes',
        pageBuilder: (context, state) {
          final user = state.extra is UserEntity
              ? state.extra as UserEntity
              : initialUser;
          if (user == null) return const MaterialPage(child: LoginPage());

          return CustomTransitionPage(
            key: state.pageKey,
            child: SavedRecipesPage(user: user),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
          );
        },
      ),
      
      GoRoute(
        path: '/edit-recipe',
        pageBuilder: (context, state) {
          final recipe = state.extra as RecipeEntity;
          return MaterialPage(
            key: state.pageKey,
            child: EditRecipePage(recipe: recipe),
          );
        },
      ),
    ],
  );
}
