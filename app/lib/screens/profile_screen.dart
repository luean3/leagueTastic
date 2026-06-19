import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../controllers/profile_controller.dart';
import '../core/providers/theme_provider.dart';
import '../core/providers/locale_provider.dart';
import '../widgets/app_header.dart';

/// Profil- und Einstellungsseite des angemeldeten Users.
class ProfileScreen extends StatelessWidget {
  final ProfileController _controller;

  ProfileScreen({super.key, ProfileController? controller})
    : _controller = controller ?? ProfileController();

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      setState(() {
        _isUploading = true;
      });

      final String? downloadUrl = await _authService.updateProfilePicture(File(image.path));

      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        if (downloadUrl != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profilbild erfolgreich aktualisiert!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fehler beim Hochladen des Bildes.")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = AppLocalizations.of(context)!;

    final profile = _controller.profile;

    String displayName = locale.guest;
    String? photoUrl;

    if (profile != null) {
      if (profile.displayName != null &&
          profile.displayName != "Kein Name gesetzt") {
        displayName = profile.displayName!;
      } else {
        displayName = profile.email ?? locale.guest;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: locale.profile),

            const SizedBox(height: 30),

            // AVATAR
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.cardColor,
              child: Icon(Icons.person, size: 50, color: colorScheme.onSurface),
            ),

              const SizedBox(height: 30),

              // AVATAR
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.cardColor,
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? Icon(
                            Icons.person,
                            size: 50,
                            color: colorScheme.onSurface,
                          )
                        : null,
                  ),
                  if (_isUploading)
                    const Positioned.fill(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploading ? null : _pickAndUploadImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

            // LEVEL
            Text(
              "${locale.level}: 5",
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),

              const SizedBox(height: 10),

            // STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ProfileStat(title: locale.wins, value: "3"),
                ProfileStat(title: locale.races, value: "12"),
                ProfileStat(title: locale.points, value: "120"),
              ],
            ),

              const SizedBox(height: 30),

              // STATS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    locale.settings,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),

                    const SizedBox(height: 10),

                  // THEME SWITCH
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      final isDark = themeProvider.themeMode == ThemeMode.dark;

                      return SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          locale.darkMode,
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                        value: isDark,
                        onChanged: (value) {
                          themeProvider.toggleTheme(value);
                        },
                      );
                    },
                  ),

                  // LANGUAGE DROPDOWN
                  Consumer<LocaleProvider>(
                    builder: (context, localeProvider, _) {
                      return DropdownButtonFormField<String>(
                        initialValue: localeProvider.locale.languageCode,

                        decoration: InputDecoration(labelText: locale.language),

                    // LANGUAGE DROPDOWN
                    Consumer<LocaleProvider>(
                      builder: (context, localeProvider, _) {
                        return DropdownButtonFormField<String>(
                          value: localeProvider.locale.languageCode,
                          decoration: InputDecoration(
                            labelText: locale.language,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: "de",
                              child: Text(locale.german),
                            ),
                            DropdownMenuItem(
                              value: "en",
                              child: Text(locale.english),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              localeProvider.setLocale(value);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // STRAVA BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                onPressed: _connectStrava,
                child: Text(locale.connectStrava),
              ),
              onPressed: _controller.connectStrava,
              child: Text(locale.connectStrava),
            ),

              const SizedBox(height: 20),

              // LOGOUT BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _authService.signOut();
                },
                child: Text(locale.logout),
              ),
              onPressed: _controller.signOut,
              child: Text(locale.logout),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kleine Profilkennzahl wie Siege, Rennen oder Punkte.
class ProfileStat extends StatelessWidget {
  final String title;
  final String value;

  const ProfileStat({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
