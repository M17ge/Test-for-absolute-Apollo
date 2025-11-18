import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _firebaseUser;
  AppUser? _appUser;
  bool _isLoading = false;

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null && _appUser != null;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _firebaseUser = FirebaseAuth.instance.currentUser;
    if (_firebaseUser != null) {
      await _loadUserData();
    }
    
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserData();
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_firebaseUser != null) {
      _appUser = await _authService.getUserData(_firebaseUser!.uid);
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        _firebaseUser = user;
        await _loadUserData();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Sign in error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );
      
      if (user != null) {
        _firebaseUser = user;
        await _loadUserData();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Sign up error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _firebaseUser = null;
    _appUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? phone, String? photoUrl}) async {
    if (_appUser == null) return;

    try {
      await _authService.updateUserData(
        _appUser!.id,
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );
      await _loadUserData();
    } catch (e) {
      print('Update profile error: $e');
    }
  }
}
