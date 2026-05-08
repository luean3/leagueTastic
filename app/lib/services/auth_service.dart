import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      
      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        await result.user!.reload();
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
      return result.user;
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