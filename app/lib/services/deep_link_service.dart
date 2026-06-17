import 'package:app_links/app_links.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();

  void init() {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri == null) return;

      print("DEEP LINK: $uri");
    });
  }
}
