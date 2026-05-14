import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../services/strava_service.dart';
import '../services/auth_service.dart';

import '../core/providers/theme_provider.dart';
import '../core/providers/locale_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _connectStrava() {
    StravaService().connect();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = AppLocalizations.of(context)!;

    final authService = AuthService();
    final profile = authService.getUserProfile();

    String displayName = locale.guest;

    if (profile != null) {
      if (profile['displayName'] != null &&
          profile['displayName'] != "Kein Name gesetzt") {
        displayName = profile['displayName'];
      } else {
        displayName = profile['email'] ?? locale.guest;
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: Text(
                locale.profile,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // AVATAR
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.cardColor,
              child: Icon(
                Icons.person,
                size: 50,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 20),

            // NAME
            Text(
              displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 10),

            // LEVEL
            Text(
              "${locale.level}: 5",
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 30),

            // STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ProfileStat(
                  title: locale.wins,
                  value: "3",
                ),
                ProfileStat(
                  title: locale.races,
                  value: "12",
                ),
                ProfileStat(
                  title: locale.points,
                  value: "120",
                ),
              ],
            ),

            const SizedBox(height: 30),

            // SETTINGS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    locale.settings,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // THEME SWITCH
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      final isDark =
                          themeProvider.themeMode == ThemeMode.dark;

                      return SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          locale.darkMode,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                          ),
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

            const SizedBox(height: 20),

            // LOGOUT BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                authService.signOut();
              },
              child: Text(locale.logout),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String title;
  final String value;

  const ProfileStat({
    super.key,
    required this.title,
    required this.value,
  });

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
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}