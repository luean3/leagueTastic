// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get welcomeBack => 'Willkommen zurück';

  @override
  String get createAccount => 'Neues Konto erstellen';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get login => 'Einloggen';

  @override
  String get register => 'Registrieren';

  @override
  String get profile => 'Profil';

  @override
  String get guest => 'Gast';

  @override
  String get level => 'Level';

  @override
  String get wins => 'Siege';

  @override
  String get races => 'Rennen';

  @override
  String get points => 'Punkte';

  @override
  String get settings => 'Einstellungen';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Sprache';

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'Englisch';

  @override
  String get connectStrava => 'Strava verbinden';

  @override
  String get logout => 'Logout';

  @override
  String get my_time => 'Meine Zeit';

  @override
  String get attempts => 'Versuche';

  @override
  String get rank => 'Rang';

  @override
  String get currentSegment => 'Aktuelles Segment';

  @override
  String get noActiveSegment => 'Aktuell ist kein Segment aktiv';

  @override
  String get week => 'Woche';

  @override
  String get allSegments => 'Alle Segmente';

  @override
  String get active => 'Aktiv';

  @override
  String get finished => 'Abgeschlossen';

  @override
  String get upcoming => 'Bevorstehend';

  @override
  String get noEntries => 'Noch keine Einträge';

  @override
  String get point => 'Punkt';

  @override
  String get myTime => 'Meine Zeit';

  @override
  String get segment => 'Segment';

  @override
  String get segmentId => 'Segment-ID';

  @override
  String get route => 'Route';

  @override
  String get myResult => 'Mein Resultat';

  @override
  String get bestTime => 'Bestzeit';

  @override
  String get myAttempts => 'Meine Versuche';

  @override
  String get noSegmentAttempts => 'Du hast für dieses Segment noch keinen Versuch.';

  @override
  String get segmentLeaderboard => 'Segment-Rangliste';

  @override
  String get noSegmentLeaderboardEntries => 'Für dieses Segment gibt es noch keine Einträge.';

  @override
  String get anonymous => 'Anonym';

  @override
  String get myChallenges => 'Meine Challenges';

  @override
  String get rideCompeteWin => 'Ride. Compete. Win.';

  @override
  String get errorLoadingChallenges => 'Fehler beim Laden der Challenges';

  @override
  String get noJoinedChallenges => 'Du bist noch keiner Challenge beigetreten';

  @override
  String get findChallenges => 'Challenges finden';

  @override
  String get searchChallenge => 'Challenge suchen';

  @override
  String get notLoggedIn => 'Du bist nicht eingeloggt';

  @override
  String get noChallengesAvailable => 'Keine Challenges vorhanden';

  @override
  String get noMatchingChallengeFound => 'Keine passende Challenge gefunden';

  @override
  String get alreadyJoined => 'Beigetreten';

  @override
  String get alreadyJoinedChallenge => 'Bereits beigetreten';

  @override
  String get joinChallenge => 'Beitreten';

  @override
  String get joinedChallenge => 'Challenge beigetreten';

  @override
  String get alreadyJoinedSnackbar => 'Du bist dieser Challenge bereits beigetreten';

  @override
  String segments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Segmente',
      one: '1 Segment',
    );
    return '$_temp0';
  }

  @override
  String get createChallenge => 'Neue Challenge erstellen';

  @override
  String get createChallengeSubtitle => 'Wähle ein Startdatum und füge Segmente hinzu. Jedes Segment wird automatisch einer Woche zugeteilt.';

  @override
  String get challengeName => 'Name';

  @override
  String get description => 'Beschreibung';

  @override
  String get pleaseEnterChallengeName => 'Bitte Name eingeben';

  @override
  String get selectStartDate => 'Startdatum auswählen';

  @override
  String get pleaseSelectStartDate => 'Bitte Startdatum auswählen';

  @override
  String get selectSegments => 'Segmente auswählen';

  @override
  String selectedSegmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '1 ausgewählt',
      zero: 'Keine ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get loadNearbySegments => 'Segmente in der Nähe laden';

  @override
  String get loadingSegments => 'Segmente werden geladen';

  @override
  String get searchSegment => 'Segment suchen';

  @override
  String get noSegmentsLoaded => 'Lade zuerst Segmente aus deiner Umgebung.';

  @override
  String get noMatchingSegmentFound => 'Kein passendes Segment gefunden';

  @override
  String get saveChallenge => 'Challenge speichern';

  @override
  String get challengeCreated => 'Challenge wurde erstellt';

  @override
  String get errorCreatingChallenge => 'Fehler beim Erstellen der Challenge';

  @override
  String get errorLoadingSegments => 'Fehler beim Laden der Segmente';

  @override
  String get pleaseSelectSegments => 'Bitte mindestens ein Segment auswählen';

  @override
  String get locationPermissionRequired => 'Standortberechtigung wird benötigt';

  @override
  String get stravaUserNotFound => 'Strava-Benutzer wurde nicht gefunden';

  @override
  String get connected => 'Mit Strava verbunden';
}
