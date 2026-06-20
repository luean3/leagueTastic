# LeagueTastic

LeagueTastic ist eine kompetitive, gamifizierte Sport-App, die darauf abzielt, 
die Motivation von Sportlern durch einen spielerischen Wettbewerb zu steigern. 
Das Kernkonzept der App basiert auf wöchentlich wechselnden, zeitlich begrenzten 
Streckenabschnitten (Segmenten), auf welchen eine Rangliste mit den teilnehmenden 
Usern erstellt wird.

LeagueTastic ist eine Flutter-App Nutzer melden sich mit Firebase an, verbinden 
Strava, suchen Segmente in ihrer Umgebung, erstellen Challenges und vergleichen 
Resultate in Segment- und Gesamt-Ranglisten.

Dieses Dokument beschreibt die vollständige Einrichtung, lokale Ausführung,
Kompilierung, Architektur und die wichtigsten Klassen des Projekts. Schlussendlich
folgt noch eine KI-Deklarierung, also wie KI in diesem Projekt eingesetzt wurde.

## Projektaufbau

```text
leagueTastic/
|- app/                        Flutter-App für Android und iOS
|  |- lib/controllers/         UI-unabhängige Ablaufsteuerung
|  |- lib/models/              Typisierte Datenmodelle
|  |- lib/repositories/        Firestore-Datenzugriff
|  |- lib/services/            Firebase Functions, Auth, Strava und Deep Links
|  |- lib/screens/             Vollständige Seiten
|  |- lib/widgets/             Wiederverwendbare UI-Bausteine
|  |- lib/core/                Themes und globale Provider
|  `- lib/l10n/                Deutsche und englische Übersetzungen
|- functions/                  Firebase Cloud Functions in TypeScript
|- firebase.json               Firebase- und Emulator-Konfiguration
|- firestore.rules             Firestore-Zugriffsregeln
`- firestore.indexes.json      Benötigte Firestore-Indizes
```

## Voraussetzungen

Für die Entwicklung werden folgende Werkzeuge benötigt:

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

Alle von `flutter doctor` gemeldeten Fehler für die gewünschte Zielplattform
sollten vor dem ersten Build behoben werden.

## Einrichtung

### 1. Repository und Abhängigkeiten

```bash
git clone https://github.com/luean3/leagueTastic.git
cd leagueTastic
git checkout main

cd app
flutter pub get
cd ../functions
npm ci
cd ..
```

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
Plattformkonfigurationen. Geheimnisse gehören nicht in Dart-Dateien oder in
Git-Commits.

Firestore-Regeln und Indizes bereitstellen:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Die aktuellen Regeln erlauben jedem angemeldeten Nutzer Lese- und Schreibzugriff
auf alle Collections. Vor einem produktiven Release müssen sie pro Collection
und Besitzer eingeschränkt werden.

### 3. Strava konfigurieren

In der Strava-API-Anwendung müssen Client-ID, Client-Secret und die
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
`leaguetastic://strava-success` zurück. Dieses URL-Schema ist in
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

Ein verbundenes Gerät oder einen Simulator anzeigen und die App starten:

```bash
cd app
flutter devices
flutter run
```

Ein bestimmtes Ziel wird mit `flutter run -d <device-id>` ausgewählt. für die
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
Veröffentlichung muss in `app/android/app/build.gradle.kts` eine eigene
Release-Signatur hinterlegt werden. Momentan verwendet der Release-Build den
Debug-Key.

### iOS

Die iOS-Kompilierung ist nur unter macOS möglich. Zuerst in Xcode für das
Runner-Target Team, Bundle-ID und Signing setzen, danach:

```bash
flutter build ios --release --no-codesign
```

Ein signierbares App-Archiv beziehungsweise IPA wird mit gültigem Apple-Team
erstellt:

```bash
flutter build ipa --release \
  --dart-define=STRAVA_CLIENT_ID=DEINE_CLIENT_ID \
  --dart-define=STRAVA_REDIRECT_URI=https://DEINE_CALLBACK_URL
```

Das IPA liegt unter `app/build/ios/ipa`. Falls CocoaPods nicht automatisch
aufgelöst wird: `cd ios && pod install && cd ..`.

## Qualitätsprüfungen

```bash
# Flutter formatieren, analysieren und testen
cd app
dart format lib test
flutter analyze
flutter test

# TypeScript-Backend prüfen
cd ../functions
npm run build
```

Die Widget-Tests befinden sich in `app/test`. Neue Logik gehört bevorzugt in
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
- **Controller** koordinieren einen Anwendungsfall und übersetzen technische
  Ergebnisse in UI-Zustände.
- **Repositories** kapseln Collections, Queries und Firestore-Limits.
- **Services** kapseln externe APIs wie Firebase Auth, Callable Functions,
  Strava OAuth und Deep Links.
- **Modelle** wandeln dynamische Systemantworten einmalig in typisierte
  Dart-Objekte um.

Abhängigkeiten werden über optionale Konstruktorparameter injiziert. Dadurch
können Controller, Services und Repositories in Tests durch Fakes ersetzt
werden.

## Wichtige Abläufe

### Anmeldung

`AuthWrapper` beobachtet den Auth-Stream des `AuthController`. Ohne Nutzer wird
`AuthScreen`, mit Nutzer `MainNavigation` angezeigt. Login und Registrierung
laufen über `AuthController` und `AuthService`.

### Challenge erstellen

`CreateScreen` sammelt Formulareingaben. `CreateChallengeController` holt den
Standort, berechnet das Suchgebiet und ruft `exploreSegments` auf. Die gefundenen
IDs werden im `SegmentRepository` in typisierte `ExploreSegment`-Objekte
umgewandelt. Beim Speichern ruft der Controller `createChallenge` auf. Danach
wechselt `MainNavigation` auf den bestehenden Home-Tab; die Navigationsleiste
bleibt dadurch sichtbar.

### Challenge- und Segmentdetails

`ChallengeDetailController` kombiniert den Zustand der Callable Function mit
dem persönlichen Resultat aus `SegmentResultRepository`. Ein
`ChallengeSegment` wird typisiert an `SegmentDetailScreen` übergeben.
`SegmentDetailController` lädt dort Versuche, Bestzeit und Segment-Rangliste.

### Strava-Aktivität

Der Strava-Webhook legt einen Job in Firestore an. `processActivity` lädt die
Aktivität, speichert Segmentversuche und löst die Berechnung der Ranglisten
aus. Die App liest nur die daraus entstandenen Firestore-Dokumente.

## Wichtige Klassen

| Klasse | Verantwortung |
|---|---|
| `MyApp` | Konfiguriert Theme, Sprache und die App-Wurzel. |
| `AuthWrapper` | Wechselt anhand des Auth-Status zwischen Login und Hauptnavigation. |
| `MainNavigation` | Hält die vier Hauptseiten und die untere Navigation dauerhaft im Widget-Baum. |
| `AuthController` | Koordiniert Login und Registrierung für die UI. |
| `HomeController` | Liefert die beigetretenen Challenges des aktuellen Nutzers. |
| `ChallengeSearchController` | Liefert Suchdaten und koordiniert den Beitritt zu Challenges. |
| `CreateChallengeController` | Verwaltet Standortsuche, Segmentauswahl und Challenge-Erstellung. |
| `ChallengeDetailController` | Lädt Challenge-Zustand und persönliche Leistung gemeinsam. |
| `SegmentDetailController` | Lädt persönliche Versuche und die Segment-Rangliste. |
| `ProfileController` | Stellt Profildaten, Strava-Verbindung und Logout bereit. |
| `AuthService` | Kapselt Firebase Authentication, Analytics und Profilbild-Uploads. |
| `ChallengeFunctionsService` | Kapselt Namen und Payloads der Callable Functions. |
| `StravaService` | Startet den externen Strava-OAuth-Flow. |
| `DeepLinkService` | Beobachtet Rücksprünge über das App-URL-Schema. |
| `ChallengeRepository` | Kapselt Challenge-, Mitgliedschafts- und Join-Queries. |
| `SegmentRepository` | Lädt Explore-Segmente in Firestore-Blöcken von maximal zehn IDs. |
| `SegmentResultRepository` | Lädt Bestzeiten, Versuche und Ranglisten eines Segments. |
| `UserRepository` | Ordnet Firebase-Nutzer einer Strava-Athleten-ID zu. |
| `ChallengeSummary` | Typisierte Challenge-Daten für Listen und Suche. |
| `ChallengeState` | Vollständiger, typisierter Zustand einer Challenge-Detailseite. |
| `ChallengeSegment` | Segmentdaten, Wochenposition, Route und zeitlicher Status. |
| `SegmentDetails` | Persönliches Resultat, Versuche und Segment-Rangliste. |
| `SegmentPerformance` | Kompakte Leistung für die Karte des aktiven Segments. |
| `ExploreSegment` | Typisierte Vorschau eines geografisch gefundenen Segments. |
| `UserProfile` | UI-freundlicher Snapshot des angemeldeten Firebase-Nutzers. |
| `ThemeProvider` | Speichert und verteilt Hell-/Dunkelmodus. |
| `LocaleProvider` | Speichert und verteilt Deutsch oder Englisch. |
| `AppFormatters` | Formatiert Zeiten, Distanzen und Datumswerte einheitlich. |
| `ValueParser` | Typisiert Werte an den Grenzen zu Firestore und Functions. |

Alle öffentlichen Kernklassen besitzen zusätzlich Dartdoc direkt im Quellcode.
Generierte Dateien in `lib/l10n` und `firebase_options.dart` werden nicht manuell
dokumentiert oder bearbeitet.

## Detaillierte Klassen-Architektur

Die App folgt einem **Layered-Architecture-Muster**, um Testbarkeit und Wartbarkeit zu garantieren.

### Data Layer (Repositories & Models)
Die Datenhaltung ist strikt von der Logik getrennt.
* **`ChallengeRepository`**: Zentraler Einstiegspunkt für Firestore. Implementiert Caching-Strategien für Challenge-Listen, um Read-Requests zu minimieren.
* **`SegmentResultRepository`**: Berechnet lokal Differenzen zwischen persönlichen Bestzeiten und Segment-Vorgaben.
* **`ValueParser`**: Eine Utility-Klasse, die `Map<String, dynamic>` aus Firestore sicher in Dart-Typen castet und Fallback-Werte bei fehlenden Feldern liefert (Null-Safety an der Systemgrenze).

### Logic Layer (Controllers & Services)
Controller halten den State (meist via `ChangeNotifier` oder `StateProvider`).
* **`ChallengeDetailController`**: Das "Gehirn" der Detailansicht. Er orchestriert den Stream von Echtzeit-Updates aus Firestore und kombiniert diese mit statischen Daten der Strava-API.
* **`StravaService`**: Implementiert den OAuth2-Flow. Nutzt `ASWebAuthenticationSession` für einen sicheren Token-Austausch ohne externe Browser-App.

### UI Layer (Screens & Widgets)
* **`MainNavigation`**: Implementiert ein persistentes Navigations-Muster (IndexedStack), damit der Scroll-Zustand beim Tab-Wechsel erhalten bleibt.
* **`AppFormatters`**: Garantiert eine einheitliche Darstellung von Sport-Metriken (z.B. Umrechnung von m/s in km/h oder Pace pro km).

## Firestore-Datenmodell

| Collection | Inhalt |
|---|---|
| `challenges` | Name, Beschreibung, Zeitraum und Segment-IDs einer Challenge |
| `challengeSegments` | Wochenzuordnung und Aktivzeitraum eines Segments |
| `userChallenges` | Mitgliedschaft eines Nutzers in einer Challenge |
| `segments` | Vollständige, zwischengespeicherte Strava-Segmente |
| `segment_explore` | Kompakte Segmente der geografischen Suche |
| `segment_explore_queries` | Cache für bereits ausgeführte Gebietssuchen |
| `segmentEfforts` | Einzelne Segmentversuche aus Strava-Aktivitäten |
| `segmentLeaderboards` | Bestzeit, Rang und Punkte pro Challenge-Segment |
| `challengeLeaderboards` | Gesamtpunkte pro Challenge |
| `strava-user` | Strava-Token und Athletenzuordnung |
| `users` | App-Nutzerprofil und Athleten-ID |
| `jobs` | Asynchrone Verarbeitung eingehender Strava-Aktivitäten |

## Lokalisierung

Texte liegen in `app/lib/l10n/app_de.arb` und `app/lib/l10n/app_en.arb`. Nach
einer Änderung werden die Dart-Klassen neu erzeugt:

```bash
cd app
flutter gen-l10n
```

Die generierten Dateien unter `app/lib/l10n` dürfen nicht von Hand angepasst
werden.

## Fehlerbehebung

- **Firebase startet nicht:** Plattformdateien und `firebase_options.dart` mit
  `flutterfire configure` neu erzeugen.
- **Keine Challenges sichtbar:** Anmeldung, Firestore-Regeln und den aktiven
  Firebase-Projektalias mit `firebase use` kontrollieren.
- **Keine Segmente in der Nähe:** Standortdienst einschalten, Berechtigung
  erteilen und im Simulator einen Standort setzen.
- **Strava kehrt nicht zur App zurück:** Callback-URL in Strava und Firebase
  sowie das Schema `leaguetastic://strava-success` kontrollieren.
- **Firestore-Query verlangt einen Index:** Den von Firebase angebotenen Index
  anlegen und anschliessend `firestore.indexes.json` aktualisieren.
- **iOS-Pods fehlen:** `flutter clean`, `flutter pub get` und danach in
  `app/ios` erneut `pod install` ausführen.

## Release-Checkliste

1. Eigene Android-Release-Signatur und Apple-Signing konfigurieren.
2. Firestore-Regeln für produktive Rollen und Besitzverhältnisse härten.
3. Strava-Dart-Defines und Firebase-Secrets auf dieselbe Anwendung setzen.
4. `flutter analyze`, `flutter test` und `npm run build` erfolgreich ausführen.
5. Android App Bundle und iOS IPA mit Release-Konfiguration bauen.


## KI-Deklaration

In diesem Projekt wurde Künstliche Intelligenz (Large 
Language Models wie ChatGPT, Claude und Cursor) gezielt 
eingesetzt, um die Softwarequalität, Wartbarkeit und 
Entwicklungsgeschwindigkeit zu steigern. Der Einsatz 
gliedert sich in folgende Kernbereiche:

1. **Architektur-Design & Strukturierung**:
    * Unterstützung bei der Konzeption der **Layered-Architecture** 
   (Trennung von UI, Controllern, Repositories und 
   Services).
    * Definition von Schnittstellen für den 
   Datenaustausch zwischen dem Flutter-Frontend und den 
   Firebase Cloud Functions, um ein skalierbares 
   Systemdesign zu gewährleisten.

2. **Code-Qualitätssicherung & Refactoring**:
    * **Logik-Optimierung**: KI-gestütztes 
   Refactoring komplexer Abläufe (z. B. im `ChallengeDetailController`), 
   um die Code-Lesbarkeit zu erhöhen und Redundanzen zu vermeiden.
    * **Fehleranalyse**: Einsatz von KI zur 
   Identifikation potenzieller Edge-Cases bei der 
   Verarbeitung von Strava-Webhooks.

3. **Dokumentation & Kommentierung**:
    * **Quellcode-Dokumentation**: Automatisierte 
   Erstellung von präzisen Dartdoc-Kommentaren für 
   alle wichtigen Klassen und Methoden direkt im Code.
    * **Technische Dokumentation**: Strukturierung 
   und Formulierungshilfe dieser `README.md`, um eine 
   detaillierte und leicht verständliche Anleitung 
   für Dritte zu garantieren.

Alle durch KI generierten Vorschläge wurden manuell 
durch die Entwickler geprüft, verifiziert und an die 
spezifischen Anforderungen von LeagueTastic angepasst.