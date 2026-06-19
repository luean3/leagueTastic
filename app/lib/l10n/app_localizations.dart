import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @races.
  ///
  /// In en, this message translates to:
  /// **'Races'**
  String get races;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @connectStrava.
  ///
  /// In en, this message translates to:
  /// **'Connect Strava'**
  String get connectStrava;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @my_time.
  ///
  /// In en, this message translates to:
  /// **'My time'**
  String get my_time;

  /// No description provided for @attempts.
  ///
  /// In en, this message translates to:
  /// **'Attempts'**
  String get attempts;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @currentSegment.
  ///
  /// In en, this message translates to:
  /// **'Current segment'**
  String get currentSegment;

  /// No description provided for @noActiveSegment.
  ///
  /// In en, this message translates to:
  /// **'No active segment'**
  String get noActiveSegment;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @allSegments.
  ///
  /// In en, this message translates to:
  /// **'All segments'**
  String get allSegments;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntries;

  /// No description provided for @point.
  ///
  /// In en, this message translates to:
  /// **'point'**
  String get point;

  /// No description provided for @myTime.
  ///
  /// In en, this message translates to:
  /// **'My time'**
  String get myTime;

  /// No description provided for @segment.
  ///
  /// In en, this message translates to:
  /// **'Segment'**
  String get segment;

  /// No description provided for @segmentId.
  ///
  /// In en, this message translates to:
  /// **'Segment ID'**
  String get segmentId;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @myResult.
  ///
  /// In en, this message translates to:
  /// **'My result'**
  String get myResult;

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best time'**
  String get bestTime;

  /// No description provided for @myAttempts.
  ///
  /// In en, this message translates to:
  /// **'My attempts'**
  String get myAttempts;

  /// No description provided for @noSegmentAttempts.
  ///
  /// In en, this message translates to:
  /// **'You do not have any attempts for this segment yet.'**
  String get noSegmentAttempts;

  /// No description provided for @segmentLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Segment leaderboard'**
  String get segmentLeaderboard;

  /// No description provided for @noSegmentLeaderboardEntries.
  ///
  /// In en, this message translates to:
  /// **'There are no entries for this segment yet.'**
  String get noSegmentLeaderboardEntries;

  /// No description provided for @anonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// No description provided for @myChallenges.
  ///
  /// In en, this message translates to:
  /// **'My Challenges'**
  String get myChallenges;

  /// No description provided for @rideCompeteWin.
  ///
  /// In en, this message translates to:
  /// **'Ride. Compete. Win.'**
  String get rideCompeteWin;

  /// No description provided for @errorLoadingChallenges.
  ///
  /// In en, this message translates to:
  /// **'Error loading challenges'**
  String get errorLoadingChallenges;

  /// No description provided for @noJoinedChallenges.
  ///
  /// In en, this message translates to:
  /// **'You have not joined any challenges yet'**
  String get noJoinedChallenges;

  /// No description provided for @findChallenges.
  ///
  /// In en, this message translates to:
  /// **'Find Challenges'**
  String get findChallenges;

  /// No description provided for @searchChallenge.
  ///
  /// In en, this message translates to:
  /// **'Search challenge'**
  String get searchChallenge;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in'**
  String get notLoggedIn;

  /// No description provided for @noChallengesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No challenges available'**
  String get noChallengesAvailable;

  /// No description provided for @noMatchingChallengeFound.
  ///
  /// In en, this message translates to:
  /// **'No matching challenge found'**
  String get noMatchingChallengeFound;

  /// No description provided for @alreadyJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get alreadyJoined;

  /// No description provided for @alreadyJoinedChallenge.
  ///
  /// In en, this message translates to:
  /// **'Already joined'**
  String get alreadyJoinedChallenge;

  /// No description provided for @joinChallenge.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinChallenge;

  /// No description provided for @joinedChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge joined'**
  String get joinedChallenge;

  /// No description provided for @alreadyJoinedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'You have already joined this challenge'**
  String get alreadyJoinedSnackbar;

  /// No description provided for @segments.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 segment} other{{count} segments}}'**
  String segments(int count);

  /// No description provided for @createChallenge.
  ///
  /// In en, this message translates to:
  /// **'Create new challenge'**
  String get createChallenge;

  /// No description provided for @createChallengeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a start date and add segments. Each segment is automatically assigned to one week.'**
  String get createChallengeSubtitle;

  /// No description provided for @challengeName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get challengeName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @pleaseEnterChallengeName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterChallengeName;

  /// No description provided for @selectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Select start date'**
  String get selectStartDate;

  /// No description provided for @pleaseSelectStartDate.
  ///
  /// In en, this message translates to:
  /// **'Please select a start date'**
  String get pleaseSelectStartDate;

  /// No description provided for @selectSegments.
  ///
  /// In en, this message translates to:
  /// **'Select segments'**
  String get selectSegments;

  /// No description provided for @selectedSegmentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None selected} =1{1 selected} other{{count} selected}}'**
  String selectedSegmentCount(int count);

  /// No description provided for @loadNearbySegments.
  ///
  /// In en, this message translates to:
  /// **'Load nearby segments'**
  String get loadNearbySegments;

  /// No description provided for @loadingSegments.
  ///
  /// In en, this message translates to:
  /// **'Loading segments'**
  String get loadingSegments;

  /// No description provided for @searchSegment.
  ///
  /// In en, this message translates to:
  /// **'Search segment'**
  String get searchSegment;

  /// No description provided for @noSegmentsLoaded.
  ///
  /// In en, this message translates to:
  /// **'Load segments from your area first.'**
  String get noSegmentsLoaded;

  /// No description provided for @noMatchingSegmentFound.
  ///
  /// In en, this message translates to:
  /// **'No matching segment found'**
  String get noMatchingSegmentFound;

  /// No description provided for @saveChallenge.
  ///
  /// In en, this message translates to:
  /// **'Save challenge'**
  String get saveChallenge;

  /// No description provided for @challengeCreated.
  ///
  /// In en, this message translates to:
  /// **'Challenge created'**
  String get challengeCreated;

  /// No description provided for @errorCreatingChallenge.
  ///
  /// In en, this message translates to:
  /// **'Error creating challenge'**
  String get errorCreatingChallenge;

  /// No description provided for @errorLoadingSegments.
  ///
  /// In en, this message translates to:
  /// **'Error loading segments'**
  String get errorLoadingSegments;

  /// No description provided for @pleaseSelectSegments.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one segment'**
  String get pleaseSelectSegments;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required'**
  String get locationPermissionRequired;

  /// No description provided for @stravaUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'Strava user was not found'**
  String get stravaUserNotFound;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
