import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseAnalytics? analytics,
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Emits the current user whenever the authentication state changes.
  Stream<User?> get userStatus => _auth.authStateChanges();

  /// Currently signed-in Firebase user, or `null` for guests.
  User? get currentUser => _auth.currentUser;

  /// Creates an account, sets its display name and creates
  /// the corresponding Firestore user document.
  Future<User?> registerWithEmail(
      String emailAddress,
      String password,
      String name,
      ) async {
    try {
      final normalizedEmail = emailAddress.trim();
      final normalizedName = name.trim();

      final result = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = result.user;

      if (user == null) {
        return null;
      }

      await user.updateDisplayName(normalizedName);
      await user.reload();

      final updatedUser = _auth.currentUser;

      if (updatedUser == null) {
        return null;
      }

      await _firestore.collection('users').doc(updatedUser.uid).set({
        'displayName': normalizedName,
        'email': normalizedEmail,
        'photoUrl': updatedUser.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _analytics.setUserId(id: updatedUser.uid);
      await _analytics.logSignUp(signUpMethod: 'email');

      return updatedUser;
    } on FirebaseAuthException catch (exception) {
      debugPrint('Registration failed: ${exception.code}');
      return null;
    } on FirebaseException catch (exception) {
      debugPrint(
        'Firestore user creation failed: '
            '${exception.code} ${exception.message}',
      );
      return null;
    } catch (exception) {
      debugPrint('Registration failed: $exception');
      return null;
    }
  }

  /// Signs in with email and password and records the login event.
  Future<User?> loginWithEmail(
      String emailAddress,
      String password,
      ) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password,
      );

      final user = result.user;

      if (user != null) {
        await _ensureUserDocument(user);

        await _analytics.setUserId(id: user.uid);
        await _analytics.logLogin(loginMethod: 'email');
      }

      return user;
    } on FirebaseAuthException catch (exception) {
      debugPrint('Login failed: ${exception.code}');
      return null;
    } catch (exception) {
      debugPrint('Login failed: $exception');
      return null;
    }
  }

  /// Creates or updates the Firestore document for an existing user.
  ///
  /// This also repairs accounts which were registered before Firestore
  /// user documents were created during registration.
  Future<void> _ensureUserDocument(User user) async {
    try {
      final userReference = _firestore.collection('users').doc(user.uid);
      final userSnapshot = await userReference.get();

      if (!userSnapshot.exists) {
        await userReference.set({
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'photoUrl': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return;
      }

      await userReference.set({
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (exception) {
      debugPrint('Failed to synchronize Firestore user: $exception');
    }
  }

  /// Signs out and clears the Analytics user association.
  Future<void> signOut() async {
    await _auth.signOut();
    await _analytics.setUserId(id: null);
  }

  /// Sends a password-reset email and reports whether Firebase accepted it.
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (exception) {
      debugPrint('Password reset failed: ${exception.code}');
      return false;
    }
  }

  /// Updates the display name in Firebase Authentication and Firestore.
  Future<void> setDisplayName(String name) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return;
      }

      final normalizedName = name.trim();

      if (normalizedName.isEmpty) {
        return;
      }

      await user.updateDisplayName(normalizedName);
      await user.reload();

      await _firestore.collection('users').doc(user.uid).set({
        'displayName': normalizedName,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (exception) {
      debugPrint('Failed to update display name: $exception');
    }
  }

  /// Uploads a profile picture and stores its URL in Authentication
  /// and Firestore.
  Future<String?> updateProfilePicture(File imageFile) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return null;
      }

      final storageReference = _storage
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      await storageReference.putFile(imageFile);

      final downloadUrl = await storageReference.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await user.reload();

      await _firestore.collection('users').doc(user.uid).set({
        'photoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return downloadUrl;
    } catch (exception) {
      debugPrint('Profile picture upload failed: $exception');
      return null;
    }
  }

  /// Returns a UI-friendly snapshot of the current Firebase user.
  UserProfile? getUserProfile() {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    return UserProfile(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL ?? '',
      lastSignIn: user.metadata.lastSignInTime,
    );
  }
}