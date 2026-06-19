import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_profile.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/strava_service.dart';

/// Result of selecting and uploading a profile picture.
enum ProfilePictureUpdateResult { updated, cancelled, failed }

/// Exposes profile data and actions without coupling the page to services.
class ProfileController {
  final AuthService _authService;
  final StravaService _stravaService;
  final ImagePicker _imagePicker;
  final UserRepository _userRepository;
  final FirebaseAuth _auth;

  ProfileController({
    AuthService? authService,
    StravaService? stravaService,
    ImagePicker? imagePicker,
    UserRepository? userRepository,
    FirebaseAuth? auth,
  }) : _authService = authService ?? AuthService(),
        _stravaService = stravaService ?? StravaService(),
        _imagePicker = imagePicker ?? ImagePicker(),
        _userRepository = userRepository ?? UserRepository(),
        _auth = auth ?? FirebaseAuth.instance;

  UserProfile? get profile => _authService.getUserProfile();

  Stream<bool> get stravaConnectionStream {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value(false);
    }

    return _userRepository.watchStravaConnection(user.uid);
  }

  Future<void> connectStrava() => _stravaService.connect();

  Future<void> signOut() => _authService.signOut();

  /// Opens the gallery and uploads the selected image to Firebase Storage.
  Future<ProfilePictureUpdateResult> selectAndUploadProfilePicture() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image == null) {
      return ProfilePictureUpdateResult.cancelled;
    }

    final downloadUrl = await _authService.updateProfilePicture(
      File(image.path),
    );

    return downloadUrl == null
        ? ProfilePictureUpdateResult.failed
        : ProfilePictureUpdateResult.updated;
  }
}