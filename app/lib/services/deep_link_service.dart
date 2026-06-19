import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Beobachtet App-Links wie den Strava-Callback-Redirect.
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  /// Starts listening once for links delivered while the app is running.
  void init() {
    _subscription ??= _appLinks.uriLinkStream.listen((uri) {
      debugPrint("Deep link received: $uri");
    });
  }

  /// Releases the app-link stream when the application widget is disposed.
  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
  }
}
