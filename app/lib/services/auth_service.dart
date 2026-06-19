import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';

/// Central access point for Firebase authentication and user profile storage.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseAnalytics _analytics;
  final FirebaseStorage _storage;

  AuthService({
    FirebaseAuth? auth,
    FirebaseAnalytics? analytics,
    FirebaseStorage? storage,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _analytics = analytics ?? FirebaseAnalytics.instance,
       _storage = storage ?? FirebaseStorage.instance;

  /// Emits the current user whenever the authentication state changes.
  Stream<User?> get userStatus => _auth.authStateChanges();

  /// Currently signed-in Firebase user, or `null` for guests.
  User? get currentUser => _auth.currentUser;

  /// Creates an account, sets its display name and records the sign-up event.
  Future<User?> registerWithEmail(
    String emailAddress,
    String password,
    String name,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      final user = result.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        await _analytics.setUserId(id: user.uid);
        await _analytics.logSignUp(signUpMethod: 'email');
      }

      return _auth.currentUser;
    } on FirebaseAuthException catch (exception) {
      debugPrint('Registration failed: ${exception.code}');
    } catch (exception) {
      debugPrint('Registration failed: $exception');
    }

    return null;
  }

  /// Signs in with email and password and records the login event.
  Future<User?> loginWithEmail(String emailAddress, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      final user = result.user;

      if (user != null) {
        await _analytics.setUserId(id: user.uid);
        await _analytics.logLogin(loginMethod: 'email');
      }

      return user;
    } on FirebaseAuthException catch (exception) {
      debugPrint('Login failed: ${exception.code}');
    }

    return null;
  }

  /// Signs out and clears the Analytics user association.
  Future<void> signOut() async {
    await _auth.signOut();
    await _analytics.setUserId(id: null);
  }

  /// Sends a password-reset email and reports whether Firebase accepted it.
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (exception) {
      debugPrint('Password reset failed: ${exception.code}');
      return false;
    }
  }

  /// Updates the visible display name of the current user.
  Future<void> setDisplayName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await user.updateDisplayName(name);
      await user.reload();
    } catch (exception) {
      debugPrint('Failed to update display name: $exception');
    }
  }

  /// Uploads a profile picture and stores its download URL on the user.
  Future<String?> updateProfilePicture(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final storageReference = _storage
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');
      await storageReference.putFile(imageFile);
      final downloadUrl = await storageReference.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await user.reload();
      return downloadUrl;
    } catch (exception) {
      debugPrint('Profile picture upload failed: $exception');
      return null;
    }
  }

  /// Returns a UI-friendly snapshot of the current Firebase user.
  UserProfile? getUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return UserProfile(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL ?? '',
      lastSignIn: user.metadata.lastSignInTime,
    );
  }
}
