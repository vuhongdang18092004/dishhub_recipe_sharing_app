import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';

import 'config/theme.dart';
import 'config/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/firebase_auth_datasource.dart';
import 'features/auth/domain/entities/user_entity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final googleSignIn = GoogleSignIn();

  final remoteDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth,
    firestore,
    googleSignIn,
  );

  final authRepository = AuthRepositoryImpl(remoteDataSource);

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

  runApp(MyApp(authRepository: authRepository, initialUser: initialUser));
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;
  final UserEntity? initialUser;
  
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  const MyApp({super.key, required this.authRepository, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        signUpWithEmail: SignUpWithEmail(authRepository),
        signInWithEmail: SignInWithEmail(authRepository),
        signInWithGoogle: SignInWithGoogle(authRepository),
        resetPassword: ResetPassword(authRepository),
        signOut: SignOut(authRepository),
        getCurrentUser: GetCurrentUser(authRepository),
      ),
      child: ValueListenableBuilder<ThemeMode>(
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
      ),
    );
  }
}
