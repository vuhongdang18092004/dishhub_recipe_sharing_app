import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/theme.dart';
import 'config/app_router.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/firebase_auth_datasource.dart';
import 'features/auth/domain/entities/user_entity.dart';

import 'features/recipe/presentation/bloc/recipe_bloc.dart';
import 'features/recipe/domain/usecases/recipe_usecases.dart';
import 'features/recipe/data/repositories/recipe_repository_impl.dart';

import 'features/social/presentation/bloc/social_bloc.dart';
import 'features/social/data/repositories/social_repository_impl.dart';
import 'features/social/domain/repositories/social_repository.dart';
import 'features/social/domain/usecases/follow_user.dart';
import 'features/social/domain/usecases/unfollow_user.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final googleSignIn = GoogleSignIn();

  final authRemoteDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth,
    firestore,
    googleSignIn,
  );
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);

  final recipeRepository = RecipeRepositoryImpl(firestore);

  UserEntity? initialUser;
  final currentUser = firebaseAuth.currentUser;
  if (currentUser != null) {
    final doc = await firestore.collection('users').doc(currentUser.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      initialUser = UserEntity(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        photo: data['photo'],
        role: data['role'] ?? 'user',
        vip: data['vip'] ?? false,
        recipes: List<String>.from(data['recipes'] ?? []),
        followers: List<String>.from(data['followers'] ?? []),
        following: List<String>.from(data['following'] ?? []),
        savedRecipes: List<String>.from(data['savedRecipes'] ?? []),
      );
    }
  }

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SocialRepository>(
          create: (_) => SocialRepositoryImpl(firestore),
        ),
        RepositoryProvider<FollowUser>(
          create: (context) => FollowUser(context.read<SocialRepository>()),
        ),
        RepositoryProvider<UnfollowUser>(
          create: (context) => UnfollowUser(context.read<SocialRepository>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              signUpWithEmail: SignUpWithEmail(authRepository),
              signInWithEmail: SignInWithEmail(authRepository),
              signInWithGoogle: SignInWithGoogle(authRepository),
              resetPassword: ResetPassword(authRepository),
              signOut: SignOut(authRepository),
              getCurrentUser: GetCurrentUser(authRepository),
              toggleSaveRecipe: ToggleSaveRecipe(authRepository),
              sendEmailVerification: SendEmailVerification(authRepository),
            )..add(const AuthCheckStatus()),
          ),

          BlocProvider<RecipeBloc>(
            create: (_) => RecipeBloc(
              getAllRecipes: GetAllRecipes(recipeRepository),
              getRecipeById: GetRecipeById(recipeRepository),
              addRecipe: AddRecipe(recipeRepository),
              updateRecipe: UpdateRecipe(recipeRepository),
              deleteRecipe: DeleteRecipe(recipeRepository),
              toggleLikeRecipe: ToggleLikeRecipe(recipeRepository),
              searchRecipes: SearchRecipes(recipeRepository),
              addComment: AddComment(recipeRepository),
            )..add(LoadAllRecipes()),
          ),

          BlocProvider<SocialBloc>(
            create: (context) => SocialBloc(
              repository: context.read<SocialRepository>(),
              followUser: context.read<FollowUser>(),
              unfollowUser: context.read<UnfollowUser>(),
            ),
          ),
        ],
        child: MyApp(initialUser: initialUser),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserEntity? initialUser;

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  const MyApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeMode,
          routerConfig: AppRouter(initialUser: initialUser).router,
        );
      },
    );
  }
}
