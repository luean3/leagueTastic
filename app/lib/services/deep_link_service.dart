import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<Uri>? _subscription;

  void init() {
    debugPrint('DeepLinkService wird initialisiert');

    _subscription?.cancel();

    _subscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Deep-Link-Fehler: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );
  }

  Future<void> _handleDeepLink(Uri uri) async {
    debugPrint('DEEP LINK: $uri');

    if (uri.scheme != 'leaguetastic' || uri.host != 'strava-success') {
      debugPrint('Unbekannter Deep Link');
      return;
    }

    final stravaId = uri.queryParameters['id'];

    debugPrint('Strava-ID aus Deep Link: $stravaId');

    if (stravaId == null || stravaId.isEmpty) {
      debugPrint('Keine Strava-ID im Deep Link vorhanden');
      return;
    }

    final user = _auth.currentUser;

    debugPrint('Firebase-User-ID: ${user?.uid}');

    if (user == null) {
      debugPrint('Kein App-Benutzer angemeldet');
      return;
    }

    final username =
        user.displayName ?? user.email?.split('@').first ?? 'Unbekannt';

    debugPrint('Username: $username');
    debugPrint('Starte Firestore-Update für strava-user/$stravaId');

    try {
      await _firestore
          .collection('strava-user')
          .doc(stravaId)
          .set({
            'userId': user.uid,
            'username': username,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
      await _firestore
          .collection("users")
          .doc(user.uid)
          .set({'stravaId': stravaId}, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));
      debugPrint('ERFOLG: Strava-Dokument $stravaId wurde verknüpft');
    } on TimeoutException {
      debugPrint(
        'TIMEOUT: Firestore konnte innerhalb von 10 Sekunden '
        'nicht erreicht werden',
      );
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('Firestore-Code: ${error.code}');
      debugPrint('Firestore-Fehler: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
    } catch (error, stackTrace) {
      debugPrint('Allgemeiner Fehler: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
