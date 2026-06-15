import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Stream für Auth-Status Änderungen
  Stream<User?> get userStatus => _auth.authStateChanges();

  // Aktueller User
  User? get currentUser => _auth.currentUser;

  // Registrierung mit Email, Passwort und username
  Future<User?> registerWithEmail(String emailAddress, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  // Login mit Email und Passwort
  Future<User?> loginWithEmail(String emailAddress, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: emailAddress,
          password: password
      );

      final user = result.user;
      if (user != null) {
        await _analytics.setUserId(id: user.uid);
        await _analytics.logLogin(loginMethod: 'email');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    return null;
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    await _analytics.setUserId(id: null);
  }

  // Methode zum Setzen/Aktualisieren des Display Namens
  Future<void> setDisplayName(String name) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
      }
    } catch (e) {
      print("Fehler beim Aktualisieren des Namens: $e");
    }
  }

  // Methode zum Zurücksetzen des Passwords
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Fehler beim Zurücksetzen des Passworts: $e");
      return false;
    }
  }

  // Methode zum Abfragen des User Profils
  Map<String, dynamic>? getUserProfile() {
    final user = _auth.currentUser;

    if (user != null) {
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL ?? "",
        'lastSignIn': user.metadata.lastSignInTime,
      };
    }
    return null;
  }
}
