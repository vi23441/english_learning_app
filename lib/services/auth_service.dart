import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;

  // Stream to listen to auth state changes
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebase_auth.User? user) async {
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          _currentUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          return _currentUser;
        }
      }
      _currentUser = null;
      return null;
    });
  }

  // Get current user
  UserModel? get currentUser => _currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final firebase_auth.UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        // Update last login time
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        
        final userDoc = await _firestore.collection('users').doc(result.user!.uid).get();
        if (userDoc.exists) {
          _currentUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          return _currentUser;
        } else {
          // Create user document if it doesn't exist
          final newUser = UserModel(
            id: result.user!.uid,
            name: result.user!.displayName ?? 'User',
            email: result.user!.email ?? email,
            role: UserRole.student,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
          
          await _firestore.collection('users').doc(result.user!.uid).set(newUser.toMap());
          _currentUser = newUser;
          return _currentUser;
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred during login';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many login attempts. Please try again later';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection';
          break;
        default:
          errorMessage = e.message ?? 'Login failed';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
    return null;
  }

  // Register user with email and password
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String role = 'student',
  }) async {
    try {
      final userData = UserModel(
        id: '',
        name: name,
        email: email,
        role: UserRole.values.firstWhere((e) => e.name == role, orElse: () => UserRole.student),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return await register(
        email: email,
        password: password,
        userData: userData,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register user
  Future<UserModel?> register({
    required String email,
    required String password,
    required UserModel userData,
  }) async {
    try {
      // Create user with email and password
      final firebase_auth.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document with the provided data
        final userModel = userData.copyWith(
          id: userCredential.user!.uid,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save user data to Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set(userModel.toMap());

        _currentUser = userModel;
        return userModel;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
  }

  // Sign out (alias for logout)
  Future<void> signOut() async {
    await logout();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate user with current password
        final credential = firebase_auth.EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Update password
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Check if email is registered
  Future<bool> isEmailRegistered(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Update user profile
  Future<UserModel?> updateUserProfile(UserModel updatedUser) async {
    try {
      final userDoc = _firestore.collection('users').doc(updatedUser.id);
      await userDoc.update(updatedUser.toMap());
      _currentUser = updatedUser;
      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
        _currentUser = null;
      }
    } catch (e) {
      rethrow;
    }
  }
}
