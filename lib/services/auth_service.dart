import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user account.
      // firebase_auth has a known bug where createUserWithEmailAndPassword throws
      // a TypeError ("List<Object?> is not a subtype of PigeonUserDetails?") even
      // though the account was successfully created on the Firebase side.
      // We catch TypeError and fall back to currentUser to continue the flow.
      User? user;
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = userCredential.user;
      } on TypeError {
        user = _auth.currentUser;
      }

      if (user == null) {
        return {'success': false, 'message': 'Failed to create account. Please try again.'};
      }

      // Send email verification
      await user.sendEmailVerification();

      // Create user profile in Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());

      // Sign out after signup so user must verify email before accessing app
      await _auth.signOut();

      return {
        'success': true,
        'message': 'Account created! Please verify your email.',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } on FirebaseException catch (e) {
      return {'success': false, 'message': e.message ?? 'A Firebase error occurred'};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: ${e.toString()}'};
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Same PigeonUserDetails TypeError workaround as signUp.
      User? user;
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        user = userCredential.user;
      } on TypeError {
        user = _auth.currentUser;
      }

      if (user == null) {
        return {'success': false, 'message': 'Sign in failed. Please try again.'};
      }

      // Check if email is verified (ENABLED)
      if (!user.emailVerified) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Please verify your email before logging in',
          'needsVerification': true,
        };
      }

      return {'success': true, 'message': 'Login successful'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } on FirebaseException catch (e) {
      return {'success': false, 'message': e.message ?? 'A Firebase error occurred'};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred: ${e.toString()}'};
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Resend verification email
  Future<Map<String, dynamic>> resendVerificationEmail() async {
    try {
      await currentUser?.sendEmailVerification();
      return {
        'success': true,
        'message': 'Verification email sent. Please check your inbox.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send verification email. Please try again later.',
      };
    }
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update profile'};
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getAuthErrorMessage(e.code)};
    } on FirebaseException catch (e) {
      return {'success': false, 'message': e.message ?? 'A Firebase error occurred'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send password reset email',
      };
    }
  }

  // Helper method for error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/password sign in is not enabled';
      case 'invalid-credential':
        return 'Invalid email or password';
      default:
        return 'Authentication error: $code';
    }
  }
}
