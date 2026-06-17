// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get createAccount => 'Create account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get profile => 'Profile';

  @override
  String get guest => 'Guest';

  @override
  String get level => 'Level';

  @override
  String get wins => 'Wins';

  @override
  String get races => 'Races';

  @override
  String get points => 'Points';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get german => 'German';

  @override
  String get english => 'English';

  @override
  String get connectStrava => 'Connect Strava';

  @override
  String get logout => 'Logout';

  @override
  String get my_time => 'My time';

  @override
  String get attempts => 'Attempts';

  @override
  String get rank => 'Rank';

  @override
  String get currentSegment => 'Current segment';

  @override
  String get noActiveSegment => 'No active segment';

  @override
  String get week => 'Week';

  @override
  String get allSegments => 'All segments';

  @override
  String get active => 'Active';

  @override
  String get finished => 'Finished';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get noEntries => 'No entries yet';

  @override
  String get point => 'point';

  @override
  String get myTime => 'My time';

  @override
  String get segment => 'Segment';

  @override
  String get segmentId => 'Segment ID';

  @override
  String get route => 'Route';

  @override
  String get myResult => 'My result';

  @override
  String get bestTime => 'Best time';

  @override
  String get myAttempts => 'My attempts';

  @override
  String get noSegmentAttempts => 'You do not have any attempts for this segment yet.';

  @override
  String get segmentLeaderboard => 'Segment leaderboard';

  @override
  String get noSegmentLeaderboardEntries => 'There are no entries for this segment yet.';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get myChallenges => 'My Challenges';

  @override
  String get rideCompeteWin => 'Ride. Compete. Win.';

  @override
  String get errorLoadingChallenges => 'Error loading challenges';

  @override
  String get noJoinedChallenges => 'You have not joined any challenges yet';

  @override
  String get findChallenges => 'Find Challenges';

  @override
  String get searchChallenge => 'Search challenge';

  @override
  String get notLoggedIn => 'You are not logged in';

  @override
  String get noChallengesAvailable => 'No challenges available';

  @override
  String get noMatchingChallengeFound => 'No matching challenge found';

  @override
  String get alreadyJoined => 'Joined';

  @override
  String get alreadyJoinedChallenge => 'Already joined';

  @override
  String get joinChallenge => 'Join';

  @override
  String get joinedChallenge => 'Challenge joined';

  @override
  String get alreadyJoinedSnackbar => 'You have already joined this challenge';

  @override
  String segments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count segments',
      one: '1 segment',
    );
    return '$_temp0';
  }

  @override
  String get createChallenge => 'Create new challenge';

  @override
  String get createChallengeSubtitle => 'Choose a start date and add segments. Each segment is automatically assigned to one week.';

  @override
  String get challengeName => 'Name';

  @override
  String get description => 'Description';

  @override
  String get pleaseEnterChallengeName => 'Please enter a name';

  @override
  String get selectStartDate => 'Select start date';

  @override
  String get pleaseSelectStartDate => 'Please select a start date';

  @override
  String get selectSegments => 'Select segments';

  @override
  String selectedSegmentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: 'None selected',
    );
    return '$_temp0';
  }

  @override
  String get loadNearbySegments => 'Load nearby segments';

  @override
  String get loadingSegments => 'Loading segments';

  @override
  String get searchSegment => 'Search segment';

  @override
  String get noSegmentsLoaded => 'Load segments from your area first.';

  @override
  String get noMatchingSegmentFound => 'No matching segment found';

  @override
  String get saveChallenge => 'Save challenge';

  @override
  String get challengeCreated => 'Challenge created';

  @override
  String get errorCreatingChallenge => 'Error creating challenge';

  @override
  String get errorLoadingSegments => 'Error loading segments';

  @override
  String get pleaseSelectSegments => 'Please select at least one segment';

  @override
  String get locationPermissionRequired => 'Location permission is required';

  @override
  String get stravaUserNotFound => 'Strava user was not found';
}
