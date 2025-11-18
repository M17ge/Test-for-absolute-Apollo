import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if user is approved
      if (credential.user != null) {
        final userData = await getUserData(credential.user!.uid);
        if (userData != null && !userData.isApproved) {
          // Sign out the user if not approved
          await _auth.signOut();
          throw Exception('Your account is pending approval from an administrator.');
        }
      }
      
      return credential.user;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final appUser = AppUser(
          id: credential.user!.uid,
          email: email,
          name: name,
          phone: phone,
          role: role,
          createdAt: DateTime.now(),
          isApproved: false, // New users need approval
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(appUser.toMap());
        
        // Sign out immediately as user needs approval
        await _auth.signOut();

        return credential.user;
      }
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AppUser?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Get user data error: $e');
    }
    return null;
  }

  Future<void> updateUserData(
    String userId, {
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updates);
      }
    } catch (e) {
      print('Update user data error: $e');
      rethrow;
    }
  }

  Future<List<AppUser>> getUsersByRole(UserRole role) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role.toString().split('.').last)
          .get();

      return querySnapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get users by role error: $e');
      return [];
    }
  }

  Future<List<AppUser>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get all users error: $e');
      return [];
    }
  }

  Future<List<AppUser>> getPendingApprovalUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('isApproved', isEqualTo: false)
          .get();

      return querySnapshot.docs
          .map((doc) => AppUser.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get pending approval users error: $e');
      return [];
    }
  }

  Future<void> approveUser(String userId, String approvedByUserId, String approverName) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isApproved': true,
        'approvedBy': approverName,
        'approvedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Approve user error: $e');
      rethrow;
    }
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.toString().split('.').last,
      });
    } catch (e) {
      print('Update user role error: $e');
      rethrow;
    }
  }

  Future<void> toggleUserActiveStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
      });
    } catch (e) {
      print('Toggle user active status error: $e');
      rethrow;
    }
  }
}
