import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class FirebaseStorageTest {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Test Firebase Storage permissions
  static Future<void> testStoragePermissions() async {
    print('🔍 Testing Firebase Storage Permissions...\n');
    
    try {
      final user = _auth.currentUser;
      print('👤 Current user: ${user?.email ?? 'No user logged in'}');
      print('🔐 User authenticated: ${user != null}');
      print('🆔 User ID: ${user?.uid ?? 'N/A'}\n');
      
      if (user == null) {
        print('❌ No user logged in. Please login first to test storage permissions.');
        return;
      }

      // Test 1: Read permission
      await _testReadPermission(user.uid);
      
      // Test 2: Write permission
      await _testWritePermission(user.uid);
      
      // Test 3: Delete permission
      await _testDeletePermission(user.uid);
      
      print('\n✅ All Firebase Storage tests completed!');
      
    } catch (e) {
      print('❌ Storage test failed: $e');
    }
  }

  static Future<void> _testReadPermission(String userId) async {
    try {
      print('📖 Testing READ permission...');
      
      // Try to list files in user's video folder
      final ref = _storage.ref().child('videos').child(userId);
      final listResult = await ref.listAll();
      
      print('✅ Read permission: OK - Found ${listResult.items.length} files');
    } catch (e) {
      print('❌ Read permission: Failed - $e');
    }
  }

  static Future<void> _testWritePermission(String userId) async {
    try {
      print('📝 Testing WRITE permission...');
      
      // Create a small test file
      final testData = Uint8List.fromList('Test video upload content'.codeUnits);
      final ref = _storage.ref().child('videos').child(userId).child('test_upload.txt');
      
      await ref.putData(testData, SettableMetadata(
        contentType: 'text/plain',
        customMetadata: {
          'test': 'true',
          'createdAt': DateTime.now().toIso8601String(),
        },
      ));
      
      print('✅ Write permission: OK - Test file uploaded successfully');
    } catch (e) {
      print('❌ Write permission: Failed - $e');
    }
  }

  static Future<void> _testDeletePermission(String userId) async {
    try {
      print('🗑️ Testing DELETE permission...');
      
      // Try to delete the test file we just created
      final ref = _storage.ref().child('videos').child(userId).child('test_upload.txt');
      await ref.delete();
      
      print('✅ Delete permission: OK - Test file deleted successfully');
    } catch (e) {
      print('❌ Delete permission: Failed - $e');
    }
  }

  /// Check if user has admin role
  static Future<bool> checkAdminRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final idTokenResult = await user.getIdTokenResult();
      final claims = idTokenResult.claims;
      
      return claims?['admin'] == true || claims?['role'] == 'admin';
    } catch (e) {
      print('Error checking admin role: $e');
      return false;
    }
  }

  /// Get current user's custom claims
  static Future<Map<String, dynamic>?> getUserClaims() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final idTokenResult = await user.getIdTokenResult();
      return idTokenResult.claims;
    } catch (e) {
      print('Error getting user claims: $e');
      return null;
    }
  }
}
