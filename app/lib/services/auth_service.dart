import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';

/// Zentrale Kapselung der Firebase-Auth-Zugriffe.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream für Login-/Logout-Wechsel.
  Stream<User?> get userStatus => _auth.authStateChanges();

  /// Aktuell angemeldeter Firebase-User.
  User? get currentUser => _auth.currentUser;

  /// Erstellt einen Account und setzt direkt den sichtbaren Namen.
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

      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        await result.user!.reload();
      }

      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      debugPrint('Registration failed: ${e.code}');
    } catch (e) {
      debugPrint('Registration failed: $e');
    }

    return null;
  }

  /// Meldet einen bestehenden User mit E-Mail und Passwort an.
  Future<User?> loginWithEmail(String emailAddress, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Login failed: ${e.code}');
    }

    return null;
  }

  /// Meldet den aktuellen User ab.
  Future<void> signOut() async {
    await _auth.signOut();
    await _analytics.setUserId(id: null);
  }

  /// Aktualisiert den sichtbaren Anzeigenamen des aktuellen Users.
  Future<void> setDisplayName(String name) async {
    try {
      final user = _auth.currentUser;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
      }
    } catch (e) {
      debugPrint('Failed to update display name: $e');
    }
  }

  /// Liefert die Profildaten des aktuellen Users als UI-freundliches Objekt.
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
