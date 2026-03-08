import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthState { loading, authenticated, unauthenticated, needsVerification }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserModel? _userProfile;
  AuthState _authState = AuthState.loading;
  String? _errorMessage;
  bool _isLoading = false;
  bool _suppressAuthListener = false;

  // Getters
  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  AuthState get authState => _authState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  AuthProvider() {
    _initAuth();
  }

  // Initialize auth state listener
  void _initAuth() {
    _authService.authStateChanges.listen((User? user) async {
      // Skip processing when signIn is handling verification check
      if (_suppressAuthListener) return;

      _user = user;

      if (user != null) {
        // Email verification check ENABLED
        if (user.emailVerified) {
          // Load user profile from Firestore
          _userProfile = await _authService.getUserProfile(user.uid);
          _authState = AuthState.authenticated;
        } else {
          _authState = AuthState.needsVerification;
        }
      } else {
        _userProfile = null;
        _authState = AuthState.unauthenticated;
      }

      notifyListeners();
    });
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    final result = await _authService.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );

    _setLoading(false);

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({required String email, required String password}) async {
    _setLoading(true);
    _errorMessage = null;

    // Suppress auth listener to prevent race condition with verification check
    _suppressAuthListener = true;

    final result = await _authService.signIn(email: email, password: password);

    _suppressAuthListener = false;
    _setLoading(false);

    if (result['success']) {
      // Manually trigger auth state update since we suppressed the listener
      _user = _authService.currentUser;
      if (_user != null) {
        _userProfile = await _authService.getUserProfile(_user!.uid);
        _authState = AuthState.authenticated;
        notifyListeners();
      }
      return true;
    } else {
      // If signIn failed due to verification, update state accordingly
      if (result['needsVerification'] == true) {
        _authState = AuthState.unauthenticated;
        notifyListeners();
      }
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Resend verification email
  Future<bool> resendVerificationEmail() async {
    _setLoading(true);
    final result = await _authService.resendVerificationEmail();
    _setLoading(false);

    if (result['success']) {
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  // Reload user to check verification status
  // Uses getIdToken(true) to force token refresh instead of User.reload()
  // which has a known PigeonUserInfo type cast bug in firebase_auth 4.x
  Future<void> reloadUser() async {
    try {
      // Force token refresh — this updates emailVerified without
      // going through the buggy PigeonUserDetails.decode path
      await _user?.getIdToken(true);
      _user = _authService.currentUser;

      // If email is now verified, update auth state
      if (_user != null &&
          _user!.emailVerified &&
          _authState == AuthState.needsVerification) {
        _userProfile = await _authService.getUserProfile(_user!.uid);
        _authState = AuthState.authenticated;
      }

      notifyListeners();
    } catch (e) {
      // Fallback: re-fetch the current user without refresh
      _user = _authService.currentUser;
      if (_user != null &&
          _user!.emailVerified &&
          _authState == AuthState.needsVerification) {
        _userProfile = await _authService.getUserProfile(_user!.uid);
        _authState = AuthState.authenticated;
        notifyListeners();
      }
    }
  }

  // Update notification preference
  Future<void> updateNotificationPreference(bool enabled) async {
    if (_user != null) {
      await _authService.updateUserProfile(_user!.uid, {
        'notificationsEnabled': enabled,
      });
      _userProfile = await _authService.getUserProfile(_user!.uid);
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
