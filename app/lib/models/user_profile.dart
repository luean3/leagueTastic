/// Snapshot der aktuell angemeldeten Firebase-Userdaten für die UI.
class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String photoUrl;
  final DateTime? lastSignIn;

  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.lastSignIn,
  });
}
