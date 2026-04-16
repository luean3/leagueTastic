import 'package:app_links/app_links.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  void init() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri == null) return;

      print("DEEP LINK: $uri");

      if (uri.scheme == "leaguetastic" &&
          uri.host == "strava-success") {
        final code = uri.queryParameters["code"];

        print("STRAVA CODE: $code");

        // TODO: Firebase function call oder navigation trigger
      }
    });
  }
}