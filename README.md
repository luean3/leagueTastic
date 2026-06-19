# LeagueTastic

LeagueTastic ist eine Flutter-App für wochenbasierte Radsport-Challenges. Nutzer
melden sich mit Firebase an, verbinden Strava, suchen Segmente in ihrer Umgebung,
erstellen Challenges und vergleichen Resultate in Segment- und Gesamt-Ranglisten.

Dieses Dokument beschreibt die vollstaendige Einrichtung, lokale Ausfuehrung,
Kompilierung, Architektur und die wichtigsten Klassen des Projekts.

## Projektaufbau

```text
leagueTastic/
|- app/                         Flutter-App für Android und iOS
|  |- lib/controllers/         UI-unabhaengige Ablaufsteuerung
|  |- lib/models/              Typisierte Datenmodelle
|  |- lib/repositories/        Firestore-Datenzugriff
|  |- lib/services/            Firebase Functions, Auth, Strava und Deep Links
|  |- lib/screens/             Vollstaendige Seiten
|  |- lib/widgets/             Wiederverwendbare UI-Bausteine
|  |- lib/core/                Themes und globale Provider
|  `- lib/l10n/                Deutsche und englische Uebersetzungen
|- functions/                  Firebase Cloud Functions in TypeScript
|- firebase.json               Firebase- und Emulator-Konfiguration
|- firestore.rules             Firestore-Zugriffsregeln
`- firestore.indexes.json      Benoetigte Firestore-Indizes
```

## Voraussetzungen

Für die Entwicklung werden folgende Werkzeuge benoetigt:

- Flutter Stable mit Dart `>= 3.11.4`
- Android Studio mit Android SDK und Java 17 für Android
- macOS, Xcode und CocoaPods für iOS; das minimale iOS-Ziel ist 15.0
- Node.js 24 und npm für die Cloud Functions
- Firebase CLI (`npm install -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)
- Ein Firebase-Projekt und eine Strava-API-Anwendung

Installation kontrollieren:

```bash
flutter doctor
node --version
firebase --version
```

Alle von `flutter doctor` gemeldeten Fehler für die gewuenschte Zielplattform
sollten vor dem ersten Build behoben werden.

## Einrichtung

### 1. Repository und Abhaengigkeiten

```bash
git clone https://github.com/luean3/leagueTastic.git
cd leagueTastic
git checkout refactor/segment-details-tech-debt

cd app
flutter pub get
cd ../functions
npm ci
cd ..
```

Der Branch basiert auf `feature/segment-details`.

### 2. Firebase konfigurieren

Das Repository ist aktuell mit dem Firebase-Projekt `leaguetastic-ffhs`
verbunden. für dieses Projekt sind die Plattformdateien bereits vorhanden:

- `app/lib/firebase_options.dart`
- `app/android/app/google-services.json`
- `app/ios/Runner/GoogleService-Info.plist`

für ein eigenes Firebase-Projekt:

1. In der Firebase Console eine Android-App mit der Package-ID
   `ch.ffhs.leaguetastic` und eine iOS-App mit der in Xcode eingestellten
   Bundle-ID anlegen.
2. Authentication aktivieren und den Anbieter **E-Mail/Passwort** einschalten.
3. Eine Firestore-Datenbank anlegen. Die bestehende Konfiguration verwendet die
   Region `eur3`.
4. Firebase Storage aktivieren und Regeln für Profilbilder unter
   `profile_pictures/{userId}.jpg` konfigurieren.
5. Im Projektstamm anmelden und die App-Konfiguration erzeugen:

```bash
firebase login
firebase use --add
cd app
flutterfire configure
cd ..
```

`flutterfire configure` aktualisiert die drei oben genannten
Plattformkonfigurationen. Geheimnisse gehoeren nicht in Dart-Dateien oder in
Git-Commits.

Firestore-Regeln und Indizes bereitstellen:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Die aktuellen Regeln erlauben jedem angemeldeten Nutzer Lese- und Schreibzugriff
auf alle Collections. Vor einem produktiven Release muessen sie pro Collection
und Besitzer eingeschraenkt werden.

### 3. Strava konfigurieren

In der Strava-API-Anwendung muessen Client-ID, Client-Secret und die
Callback-Domain eingetragen sein. Die Cloud Functions lesen ihre Geheimnisse aus
Firebase Secret Manager:

```bash
firebase functions:secrets:set STRAVA_CLIENT_ID
firebase functions:secrets:set STRAVA_CLIENT_SECRET
```

Die App akzeptiert Client-ID und Callback-URL als Dart-Defines. Ohne Parameter
werden die bisherigen Projektwerte verwendet.

```bash
cd app
flutter run \
  --dart-define=STRAVA_CLIENT_ID=DEINE_CLIENT_ID \
  --dart-define=STRAVA_REDIRECT_URI=https://DEINE_CALLBACK_URL
```

Der Callback leitet nach erfolgreicher Verbindung auf
`leaguetastic://strava-success` zurueck. Dieses URL-Schema ist in
`AndroidManifest.xml` und `Info.plist` registriert.

### 4. Cloud Functions kompilieren und bereitstellen

```bash
cd functions
npm ci
npm run build
cd ..
firebase deploy --only functions
```

`npm run build` kompiliert den TypeScript-Code aus `functions/src` nach
`functions/lib`. Der generierte Ordner wird nicht manuell bearbeitet.

## App starten

Ein verbundenes Geraet oder einen Simulator anzeigen und die App starten:

```bash
cd app
flutter devices
flutter run
```

Ein bestimmtes Ziel wird mit `flutter run -d <device-id>` ausgewaehlt. für die
Umkreissuche muss der Simulator einen Standort besitzen und die
Standortberechtigung muss erteilt werden.

## Kompilierung

Vor jedem Release:

```bash
cd app
flutter clean
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

### Android

Debug-APK:

```bash
flutter build apk --debug
```

Release-App-Bundle für Google Play:

```bash
flutter build appbundle --release \
  --dart-define=STRAVA_CLIENT_ID=DEINE_CLIENT_ID \
  --dart-define=STRAVA_REDIRECT_URI=https://DEINE_CALLBACK_URL
```

Das Bundle liegt danach unter
`app/build/app/outputs/bundle/release/app-release.aab`. für eine echte
Veroeffentlichung muss in `app/android/app/build.gradle.kts` eine eigene
Release-Signatur hinterlegt werden; momentan verwendet der Release-Build den
Debug-Key.

### iOS

Die iOS-Kompilierung ist nur unter macOS moeglich. Zuerst in Xcode für das
Runner-Target Team, Bundle-ID und Signing setzen, danach:

```bash
flutter build ios --release --no-codesign
```

Ein signierbares App-Archiv beziehungsweise IPA wird mit gueltigem Apple-Team
erstellt:

```bash
flutter build ipa --release \
  --dart-define=STRAVA_CLIENT_ID=DEINE_CLIENT_ID \
  --dart-define=STRAVA_REDIRECT_URI=https://DEINE_CALLBACK_URL
```

Das IPA liegt unter `app/build/ios/ipa`. Falls CocoaPods nicht automatisch
aufgeloest wird: `cd ios && pod install && cd ..`.

## Qualitaetspruefungen

```bash
# Flutter formatieren, analysieren und testen
cd app
dart format lib test
flutter analyze
flutter test

# TypeScript-Backend pruefen
cd ../functions
npm run build
```

Die Widget-Tests befinden sich in `app/test`. Neue Logik gehoert bevorzugt in
Controller, Modelle oder Repositories, damit sie ohne kompletten Screen getestet
werden kann.

## Architektur

Die Flutter-App verwendet eine klare Schichtenstruktur:

```text
Screen/Widget -> Controller -> Service/Repository -> Firebase oder Strava
                         |
                       Model
```

- **Screens und Widgets** zeigen Zustand an, nehmen Eingaben entgegen und
  navigieren. Sie enthalten keine Firebase- oder Strava-Aufrufe.
- **Controller** koordinieren einen Anwendungsfall und uebersetzen technische
  Ergebnisse in UI-Zustaende.
- **Repositories** kapseln Collections, Queries und Firestore-Limits.
- **Services** kapseln externe APIs wie Firebase Auth, Callable Functions,
  Strava OAuth und Deep Links.
- **Modelle** wandeln dynamische Systemantworten einmalig in typisierte
  Dart-Objekte um.

Abhaengigkeiten werden ueber optionale Konstruktorparameter injiziert. Dadurch
koennen Controller, Services und Repositories in Tests durch Fakes ersetzt
werden.

## Wichtige Ablaeufe

### Anmeldung

`AuthWrapper` beobachtet den Auth-Stream des `AuthController`. Ohne Nutzer wird
`AuthScreen`, mit Nutzer `MainNavigation` angezeigt. Login und Registrierung
laufen ueber `AuthController` und `AuthService`.

### Challenge erstellen

`CreateScreen` sammelt Formulareingaben. `CreateChallengeController` holt den
Standort, berechnet das Suchgebiet und ruft `exploreSegments` auf. Die gefundenen
IDs werden im `SegmentRepository` in typisierte `ExploreSegment`-Objekte
umgewandelt. Beim Speichern ruft der Controller `createChallenge` auf. Danach
wechselt `MainNavigation` auf den bestehenden Home-Tab; die Navigationsleiste
bleibt dadurch sichtbar.

### Challenge- und Segmentdetails

`ChallengeDetailController` kombiniert den Zustand der Callable Function mit
dem persoenlichen Resultat aus `SegmentResultRepository`. Ein
`ChallengeSegment` wird typisiert an `SegmentDetailScreen` uebergeben.
`SegmentDetailController` laedt dort Versuche, Bestzeit und Segment-Rangliste.

### Strava-Aktivitaet

Der Strava-Webhook legt einen Job in Firestore an. `processActivity` laedt die
Aktivitaet, speichert Segmentversuche und loest die Berechnung der Ranglisten
aus. Die App liest nur die daraus entstandenen Firestore-Dokumente.

## Wichtige Klassen

| Klasse | Verantwortung |
|---|---|
| `MyApp` | Konfiguriert Theme, Sprache und die App-Wurzel. |
| `AuthWrapper` | Wechselt anhand des Auth-Status zwischen Login und Hauptnavigation. |
| `MainNavigation` | Haelt die vier Hauptseiten und die untere Navigation dauerhaft im Widget-Baum. |
| `AuthController` | Koordiniert Login und Registrierung für die UI. |
| `HomeController` | Liefert die beigetretenen Challenges des aktuellen Nutzers. |
| `ChallengeSearchController` | Liefert Suchdaten und koordiniert den Beitritt zu Challenges. |
| `CreateChallengeController` | Verwaltet Standortsuche, Segmentauswahl und Challenge-Erstellung. |
| `ChallengeDetailController` | Laedt Challenge-Zustand und persoenliche Leistung gemeinsam. |
| `SegmentDetailController` | Laedt persoenliche Versuche und die Segment-Rangliste. |
| `ProfileController` | Stellt Profildaten, Strava-Verbindung und Logout bereit. |
| `AuthService` | Kapselt Firebase Authentication, Analytics und Profilbild-Uploads. |
| `ChallengeFunctionsService` | Kapselt Namen und Payloads der Callable Functions. |
| `StravaService` | Startet den externen Strava-OAuth-Flow. |
| `DeepLinkService` | Beobachtet Rueckspruenge ueber das App-URL-Schema. |
| `ChallengeRepository` | Kapselt Challenge-, Mitgliedschafts- und Join-Queries. |
| `SegmentRepository` | Laedt Explore-Segmente in Firestore-Bloecken von maximal zehn IDs. |
| `SegmentResultRepository` | Laedt Bestzeiten, Versuche und Ranglisten eines Segments. |
| `UserRepository` | Ordnet Firebase-Nutzer einer Strava-Athleten-ID zu. |
| `ChallengeSummary` | Typisierte Challenge-Daten für Listen und Suche. |
| `ChallengeState` | Vollstaendiger, typisierter Zustand einer Challenge-Detailseite. |
| `ChallengeSegment` | Segmentdaten, Wochenposition, Route und zeitlicher Status. |
| `SegmentDetails` | Persoenliches Resultat, Versuche und Segment-Rangliste. |
| `SegmentPerformance` | Kompakte Leistung für die Karte des aktiven Segments. |
| `ExploreSegment` | Typisierte Vorschau eines geografisch gefundenen Segments. |
| `UserProfile` | UI-freundlicher Snapshot des angemeldeten Firebase-Nutzers. |
| `ThemeProvider` | Speichert und verteilt Hell-/Dunkelmodus. |
| `LocaleProvider` | Speichert und verteilt Deutsch oder Englisch. |
| `AppFormatters` | Formatiert Zeiten, Distanzen und Datumswerte einheitlich. |
| `ValueParser` | Typisiert Werte an den Grenzen zu Firestore und Functions. |

Alle oeffentlichen Kernklassen besitzen zusaetzlich Dartdoc direkt im Quellcode.
Generierte Dateien in `lib/l10n` und `firebase_options.dart` werden nicht manuell
dokumentiert oder bearbeitet.

## Firestore-Datenmodell

| Collection | Inhalt |
|---|---|
| `challenges` | Name, Beschreibung, Zeitraum und Segment-IDs einer Challenge |
| `challengeSegments` | Wochenzuordnung und Aktivzeitraum eines Segments |
| `userChallenges` | Mitgliedschaft eines Nutzers in einer Challenge |
| `segments` | Vollstaendige, zwischengespeicherte Strava-Segmente |
| `segment_explore` | Kompakte Segmente der geografischen Suche |
| `segment_explore_queries` | Cache für bereits ausgefuehrte Gebietssuchen |
| `segmentEfforts` | Einzelne Segmentversuche aus Strava-Aktivitaeten |
| `segmentLeaderboards` | Bestzeit, Rang und Punkte pro Challenge-Segment |
| `challengeLeaderboards` | Gesamtpunkte pro Challenge |
| `strava-user` | Strava-Token und Athletenzuordnung |
| `users` | App-Nutzerprofil und Athleten-ID |
| `jobs` | Asynchrone Verarbeitung eingehender Strava-Aktivitaeten |

## Lokalisierung

Texte liegen in `app/lib/l10n/app_de.arb` und `app/lib/l10n/app_en.arb`. Nach
einer Aenderung werden die Dart-Klassen neu erzeugt:

```bash
cd app
flutter gen-l10n
```

Die generierten Dateien unter `app/lib/l10n` duerfen nicht von Hand angepasst
werden.

## Fehlerbehebung

- **Firebase startet nicht:** Plattformdateien und `firebase_options.dart` mit
  `flutterfire configure` neu erzeugen.
- **Keine Challenges sichtbar:** Anmeldung, Firestore-Regeln und den aktiven
  Firebase-Projektalias mit `firebase use` kontrollieren.
- **Keine Segmente in der Naehe:** Standortdienst einschalten, Berechtigung
  erteilen und im Simulator einen Standort setzen.
- **Strava kehrt nicht zur App zurueck:** Callback-URL in Strava und Firebase
  sowie das Schema `leaguetastic://strava-success` kontrollieren.
- **Firestore-Query verlangt einen Index:** Den von Firebase angebotenen Index
  anlegen und anschliessend `firestore.indexes.json` aktualisieren.
- **iOS-Pods fehlen:** `flutter clean`, `flutter pub get` und danach in
  `app/ios` erneut `pod install` ausfuehren.

## Release-Checkliste

1. Eigene Android-Release-Signatur und Apple-Signing konfigurieren.
2. Firestore-Regeln für produktive Rollen und Besitzverhaeltnisse haerten.
3. Strava-Dart-Defines und Firebase-Secrets auf dieselbe Anwendung setzen.
4. `flutter analyze`, `flutter test` und `npm run build` erfolgreich ausfuehren.
5. Android App Bundle und iOS IPA mit Release-Konfiguration bauen.
