import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  UserModel? get user => _currentUser; // Add getter for compatibility
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((UserModel? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _authService.registerWithEmailAndPassword(
        name: name,
        email: email, 
        password: password,
      );
      
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'student',
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.logout();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await signOut();
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _setError('No user signed in');
        return false;
      }
      
      final updatedUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
        updatedAt: DateTime.now(),
      );
      
      final result = await _authService.updateUserProfile(updatedUser);
      
      if (result != null) {
        _currentUser = result;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount(String password) async {
    try {
      _setLoading(true);
      _clearError();
      
      await _authService.deleteAccount();
      _currentUser = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> uploadProfileImage(String imagePath) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _setError('No user signed in');
        return null;
      }
      
      // TODO: Implement image upload to Firebase Storage
      // For now, return null or a placeholder URL
      // final downloadUrl = await _authService.uploadProfileImage(
      //   _currentUser!.uid,
      //   imagePath,
      // );
      
      // await updateProfile(profileImageUrl: downloadUrl);
      // return downloadUrl;
      return null;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    try {
      return await _authService.isEmailRegistered(email);
    } catch (e) {
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Helper methods for role checking
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isTeacher => _currentUser?.role == UserRole.teacher;
  bool get isStudent => _currentUser?.role == UserRole.student;

  // Reload user data
  Future<void> reloadUser() async {
    if (_currentUser != null) {
      _setLoading(true);
      try {
        final updatedUser = await _authService.getUserById(_currentUser!.uid);
        if (updatedUser != null) {
          _currentUser = updatedUser;
          notifyListeners();
        }
      } catch (e) {
        _setError('Failed to reload user: ${e.toString()}');
      } finally {
        _setLoading(false);
      }
    }
  }
  
  // Get appropriate dashboard route based on user role
  String getDashboardRoute() {
    if (isAdmin) {
      return '/admin-dashboard';
    } else if (isTeacher) {
      return '/dashboard-home-screen'; // Teachers use same dashboard as students for now
    } else {
      return '/dashboard-home-screen';
    }
  }
}
