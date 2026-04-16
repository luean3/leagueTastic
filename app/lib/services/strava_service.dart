import 'package:url_launcher/url_launcher.dart';

class StravaService {
  static const String clientId = "86073";
  static const String redirectUri =
      "https://stravacallback-bvydn3tz4q-uc.a.run.app";

  Future<void> connect() async {
    final uri = Uri.https(
      "www.strava.com",
      "/oauth/authorize",
      {
        "client_id": clientId,
        "response_type": "code",
        "redirect_uri": redirectUri,
        "scope": "activity:read_all",
        "approval_prompt": "auto",
      },
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}