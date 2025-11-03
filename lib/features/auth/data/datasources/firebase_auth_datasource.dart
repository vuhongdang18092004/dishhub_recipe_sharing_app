import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmail(String email, String password, String name);
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> resetPassword(String email);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> toggleSaveRecipe(String userId, String recipeId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl(this._auth, this._firestore, this._googleSignIn);

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final userId = cred.user!.uid;

    final user = UserModel(id: userId, name: name, email: email);

    await _firestore.collection('users').doc(userId).set(user.toMap());

    return user;
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final userDoc = await _firestore
        .collection('users')
        .doc(cred.user!.uid)
        .get();

    return UserModel.fromMap(userDoc.data()!, cred.user!.uid);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);
    final userId = cred.user!.uid;

    final userDoc = await _firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      final user = UserModel(
        id: userId,
        name: cred.user!.displayName ?? '',
        email: cred.user!.email ?? '',
        photo: cred.user!.photoURL,
      );
      await _firestore.collection('users').doc(userId).set(user.toMap());
      return user;
    }

    return UserModel.fromMap(userDoc.data()!, userId);
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!, user.uid);
  }

  @override
  Future<UserModel> toggleSaveRecipe(String userId, String recipeId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      throw Exception('User not found');
    }

    final userData = docSnapshot.data()!;
    final savedRecipes = List<String>.from(userData['savedRecipes'] ?? []);

    print('Before toggle - savedRecipes: $savedRecipes');
    print('Recipe ID to toggle: $recipeId');
    print('Contains recipe: ${savedRecipes.contains(recipeId)}');

    if (savedRecipes.contains(recipeId)) {
      // Remove recipe from saved list (use atomic arrayRemove to avoid races)
      print('Removing recipe $recipeId from user $userId savedRecipes');
      await userDoc.update({
        'savedRecipes': FieldValue.arrayRemove([recipeId]),
      });

      // Also remove userId from recipe.savedBy atomically
      try {
        final recipeDocRef = _firestore.collection('recipes').doc(recipeId);
        await recipeDocRef.update({
          'savedBy': FieldValue.arrayRemove([userId]),
        });
      } catch (e) {
        // Non-fatal: log and continue
        print('Failed to arrayRemove recipe.savedBy: $e');
      }
    } else {
      // Add recipe to saved list (use atomic arrayUnion to avoid races)
      print('Adding recipe $recipeId to user $userId savedRecipes');
      await userDoc.update({
        'savedRecipes': FieldValue.arrayUnion([recipeId]),
      });

      // Also add userId to recipe.savedBy atomically
      try {
        final recipeDocRef = _firestore.collection('recipes').doc(recipeId);
        await recipeDocRef.update({
          'savedBy': FieldValue.arrayUnion([userId]),
        });
      } catch (e) {
        // Non-fatal: log and continue
        print('Failed to arrayUnion recipe.savedBy: $e');
      }
    }

    final updatedDoc = await userDoc.get();
    final updatedUser = UserModel.fromMap(updatedDoc.data()!, userId);
    print('Updated user savedRecipes: ${updatedUser.savedRecipes}');

    return updatedUser;
  }
}
