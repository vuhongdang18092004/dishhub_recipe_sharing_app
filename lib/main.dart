import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/auth_usecases.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/firebase_auth_datasource.dart';
import 'features/auth/presentation/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Khởi tạo Firebase

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final googleSignIn = GoogleSignIn();

  // tạo datasource
  final remoteDataSource = AuthRemoteDataSourceImpl(
    firebaseAuth,
    firestore,
    googleSignIn,
  );

  // tạo repository
  final authRepository = AuthRepositoryImpl(remoteDataSource);

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepositoryImpl authRepository;

  const MyApp({super.key, required this.authRepository});

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
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
