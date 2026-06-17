import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Beobachtet App-Links wie den Strava-Callback-Redirect.
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  void init() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri == null) return;

      debugPrint("Deep link received: $uri");
    });
  }
}
