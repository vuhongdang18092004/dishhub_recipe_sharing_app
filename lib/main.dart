import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
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

void main() async {
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
      initialUser = UserEntity(
        id: doc.id,
        name: doc.data()?['name'] ?? '',
        email: doc.data()?['email'] ?? '',
        photo: doc.data()?['photo'],
        role: doc.data()?['role'] ?? 'user',
        vip: doc.data()?['vip'] ?? false,
        recipes: List<String>.from(doc.data()?['recipes'] ?? []),
        followers: List<String>.from(doc.data()?['followers'] ?? []),
        following: List<String>.from(doc.data()?['following'] ?? []),
        savedRecipes: List<String>.from(doc.data()?['savedRecipes'] ?? []),
      );
    }
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            signUpWithEmail: SignUpWithEmail(authRepository),
            signInWithEmail: SignInWithEmail(authRepository),
            signInWithGoogle: SignInWithGoogle(authRepository),
            resetPassword: ResetPassword(authRepository),
            signOut: SignOut(authRepository),
            getCurrentUser: GetCurrentUser(authRepository),
          )..add(const AuthCheckStatus()),
        ),
        BlocProvider<RecipeBloc>(
          create: (_) => RecipeBloc(
            getAllRecipes: GetAllRecipes(recipeRepository),
            getRecipeById: GetRecipeById(recipeRepository),
            addRecipe: AddRecipe(recipeRepository),
            updateRecipe: UpdateRecipe(recipeRepository),
            deleteRecipe: DeleteRecipe(recipeRepository),
          )..add(LoadAllRecipes()),
        ),
      ],
      child: MyApp(initialUser: initialUser),
    ),
  );
}

class MyApp extends StatelessWidget {
  final UserEntity? initialUser;

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

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
