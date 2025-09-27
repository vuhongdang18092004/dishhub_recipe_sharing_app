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
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl(this._auth, this._firestore, this._googleSignIn);

  @override
  Future<UserModel> signUpWithEmail(String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final userId = cred.user!.uid;

    final user = UserModel(
      id: userId,
      name: name,
      email: email,
    );

    await _firestore.collection('users').doc(userId).set(user.toMap());

    return user;
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final userDoc = await _firestore.collection('users').doc(cred.user!.uid).get();

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
}
