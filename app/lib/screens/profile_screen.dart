import 'package:flutter/material.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../controllers/profile_controller.dart';
import '../core/providers/locale_provider.dart';
import '../core/providers/theme_provider.dart';
import '../widgets/app_header.dart';

/// Profile and settings page for the signed-in user.
class ProfileScreen extends StatefulWidget {
  final ProfileController? controller;

  const ProfileScreen({super.key, this.controller});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller =
      widget.controller ?? ProfileController();
  bool _isUploading = false;

  Future<void> _selectProfilePicture() async {
    if (_isUploading) return;

    setState(() => _isUploading = true);
    final result = await _controller.selectAndUploadProfilePicture();

    if (!mounted) return;
    setState(() => _isUploading = false);

    switch (result) {
      case ProfilePictureUpdateResult.updated:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profilbild erfolgreich aktualisiert.')),
        );
      case ProfilePictureUpdateResult.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profilbild konnte nicht hochgeladen werden.'),
          ),
        );
      case ProfilePictureUpdateResult.cancelled:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = AppLocalizations.of(context)!;
    final profile = _controller.profile;
    final profilePhotoUrl = profile?.photoUrl ?? '';

    final displayName =
        profile?.displayName?.isNotEmpty == true &&
            profile?.displayName != 'Kein Name gesetzt'
        ? profile!.displayName!
        : profile?.email ?? locale.guest;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: locale.profile),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.cardColor,
                          backgroundImage: profilePhotoUrl.isNotEmpty
                              ? NetworkImage(profilePhotoUrl)
                              : null,
                          child: profilePhotoUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: colorScheme.onSurface,
                                )
                              : null,
                        ),
                        if (_isUploading)
                          const Positioned.fill(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton.filled(
                            tooltip: 'Profilbild ändern',
                            onPressed: _isUploading
                                ? null
                                : _selectProfilePicture,
                            icon: const Icon(Icons.edit, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        locale.settings,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            locale.darkMode,
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                          value: themeProvider.themeMode == ThemeMode.dark,
                          onChanged: themeProvider.toggleTheme,
                        );
                      },
                    ),
                    Consumer<LocaleProvider>(
                      builder: (context, localeProvider, _) {
                        return DropdownButtonFormField<String>(
                          initialValue: localeProvider.locale.languageCode,
                          decoration: InputDecoration(
                            labelText: locale.language,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'de',
                              child: Text(locale.german),
                            ),
                            DropdownMenuItem(
                              value: 'en',
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
                    const SizedBox(height: 30),
                    StreamBuilder<bool>(
                      stream: _controller.stravaConnectionStream,
                      initialData: false,
                      builder: (context, snapshot) {
                        final isConnected = snapshot.data ?? false;

                        if (snapshot.hasError) {
                          return ElevatedButton.icon(
                            onPressed: _controller.connectStrava,
                            icon: const Icon(Icons.link),
                            label: Text(locale.connectStrava),
                          );
                        }

                        return ElevatedButton.icon(
                          onPressed: isConnected ? null : _controller.connectStrava,
                          icon: Icon(
                            isConnected ? Icons.check_circle : Icons.link,
                          ),
                          label: Text(
                            isConnected
                                ? locale.connected
                                : locale.connectStrava,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _controller.signOut,
                      child: Text(locale.logout),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small profile statistic such as wins, races or points.
class ProfileStat extends StatelessWidget {
  final String title;
  final String value;

  const ProfileStat({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
