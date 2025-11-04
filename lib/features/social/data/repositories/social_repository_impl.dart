import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/social_repository.dart';

class SocialRepositoryImpl implements SocialRepository {
  final FirebaseFirestore firestore;

  SocialRepositoryImpl(this.firestore);

  @override
  Future<void> followUser(String currentUserId, String targetUserId) async {
    final userRef = firestore.collection('users').doc(targetUserId);
    await userRef.update({
      'followers': FieldValue.arrayUnion([currentUserId]),
    });

    // Optionally, thêm vào danh sách following của current user
    final currentUserRef = firestore.collection('users').doc(currentUserId);
    await currentUserRef.update({
      'following': FieldValue.arrayUnion([targetUserId]),
    });
  }

  @override
  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final userRef = firestore.collection('users').doc(targetUserId);
    await userRef.update({
      'followers': FieldValue.arrayRemove([currentUserId]),
    });

    final currentUserRef = firestore.collection('users').doc(currentUserId);
    await currentUserRef.update({
      'following': FieldValue.arrayRemove([targetUserId]),
    });
  }

  @override
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    final doc = await firestore.collection('users').doc(targetUserId).get();
    final data = doc.data();
    if (data == null) return false;

    final followers = List<String>.from(data['followers'] ?? []);
    return followers.contains(currentUserId);
  }
}
