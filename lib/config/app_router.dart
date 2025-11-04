import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/recipe/presentation/screens/home_page.dart';
import '../features/recipe/presentation/screens/add_recipe_page.dart';
import '../features/auth/presentation/screens/setting_page.dart';
import '../features/auth/presentation/screens/login_page.dart';
import '../features/auth/presentation/screens/signup_page.dart';
import '../features/auth/presentation/screens/account_info_page.dart';
import '../features/recipe/presentation/screens/saved_recipes_page.dart';
import '../features/auth/domain/entities/user_entity.dart';
import '../features/recipe/presentation/screens/recipe_detail_page.dart';
import '../features/recipe/presentation/screens/search_page.dart';
import '../features/recipe/presentation/screens/my_recipes_page.dart';
import '../features/recipe/presentation/screens/edit_recipe_page.dart';
import '../features/recipe/presentation/screens/author_page.dart';
import '../features/recipe/domain/entities/recipe_entity.dart';
import '../features/auth/presentation/screens/user_list_page.dart';
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
        path: '/author/:authorId',
        pageBuilder: (context, state) {
          final currentUser = _getUserFromExtra(state.extra);
          final authorId = state.pathParameters['authorId']!;
          
          if (currentUser == null) {
            return const MaterialPage(child: LoginPage());
          }
          
          return CustomTransitionPage(
            key: state.pageKey,
            child: AuthorPage(currentUser: currentUser, authorId: authorId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
        path: '/recipe-detail',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return const MaterialPage(child: LoginPage());
          }
          
          final recipe = extra['recipe'] as RecipeEntity?;
          final currentUser = extra['currentUser'] as UserEntity?;
          
          if (recipe == null || currentUser == null) {
            return const MaterialPage(child: LoginPage());
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: RecipeDetailPage(recipe: recipe, currentUser: currentUser),
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
          final user = _getUserFromExtra(state.extra);
          if (user == null) {
            return const MaterialPage(child: LoginPage());
          }
          
          return CustomTransitionPage(
            key: state.pageKey,
            child: SearchPage(user: user),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
        path: '/my-recipes',
        pageBuilder: (context, state) {
          final user = _getUserFromExtra(state.extra);
          if (user == null) {
            return const MaterialPage(child: LoginPage());
          }
          
          return CustomTransitionPage(
            key: state.pageKey,
            child: MyRecipesPage(user: user),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
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

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) {
                  final user = _getUserFromState(state);
                  if (user == null) return const MaterialPage(child: LoginPage());
                  return MaterialPage(
                    key: const ValueKey('home-page'),
                    child: HomePage(user: user),
                  );
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/add',
                pageBuilder: (context, state) {
                  final user = _getUserFromState(state);
                  if (user == null) return const MaterialPage(child: LoginPage());
                  return MaterialPage(
                    key: const ValueKey('add-recipe-page'),
                    child: const AddRecipePage(),
                  );
                },
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) {
                  final user = _getUserFromState(state);
                  if (user == null) return const MaterialPage(child: LoginPage());
                  return MaterialPage(
                    key: const ValueKey('settings-page'),
                    child: const SettingPage(),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/settings/account-info',
        pageBuilder: (context, state) {
          final user = _getUserFromState(state);
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
          final user = _getUserFromState(state);
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
          final recipe = state.extra as RecipeEntity?;
          if (recipe == null) {
            return const MaterialPage(child: Scaffold(
              body: Center(child: Text('Recipe not found')),
            ));
          }
          
          return CustomTransitionPage(
            key: state.pageKey,
            child: EditRecipePage(recipe: recipe),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
        path: '/followers-list',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return const MaterialPage(child: LoginPage());
          }
          
          final currentUser = extra['currentUser'] as UserEntity?;
          final userId = extra['userId'] as String?;
          final title = extra['title'] as String? ?? 'Người theo dõi';

          if (currentUser == null || userId == null) {
            return const MaterialPage(child: LoginPage());
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: UserListPage(
              userId: userId,
              title: title,
              showFollowers: true,
              currentUser: currentUser,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
        path: '/following-list',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          if (extra == null) {
            return const MaterialPage(child: LoginPage());
          }
          
          final currentUser = extra['currentUser'] as UserEntity?;
          final userId = extra['userId'] as String?;
          final title = extra['title'] as String? ?? 'Đang theo dõi';

          if (currentUser == null || userId == null) {
            return const MaterialPage(child: LoginPage());
          }

          return CustomTransitionPage(
            key: state.pageKey,
            child: UserListPage(
              userId: userId,
              title: title,
              showFollowers: false,
              currentUser: currentUser,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.uri.path}'),
      ),
    ),
  );

  UserEntity? _getUserFromState(GoRouterState state) {
    return _getUserFromExtra(state.extra) ?? initialUser;
  }

  UserEntity? _getUserFromExtra(Object? extra) {
    if (extra is UserEntity) {
      return extra;
    }
    return null;
  }
}