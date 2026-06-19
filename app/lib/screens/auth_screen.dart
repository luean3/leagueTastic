import 'package:flutter/material.dart';
import 'package:leaguetastic/core/theme/app_colors.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../controllers/auth_controller.dart';

/// Login and registration form, including password-reset support.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController _controller = AuthController();

  bool isLogin = true;
  bool isLoading = false;
  String email = '';
  String password = '';
  String username = '';

  Future<void> handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => isLoading = true);
    final user = await _controller.authenticate(
      isLogin: isLogin,
      email: email,
      password: password,
      username: username,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            isLogin
                ? 'Login fehlgeschlagen. Daten prüfen.'
                : 'Registrierung fehlgeschlagen. E-Mail eventuell schon vergeben.',
          ),
        ),
      );
    }
  }

  Future<void> handleResetPassword() async {
    _formKey.currentState?.save();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte eine gültige E-Mail-Adresse eingeben.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    final success = await _controller.resetPassword(email);

    if (!mounted) return;
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'E-Mail zum Zurücksetzen des Passworts wurde gesendet.'
              : 'E-Mail konnte nicht gesendet werden. Bitte Adresse prüfen.',
        ),
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: const Text(
                'LeagueTastic',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              isLogin ? locale.welcomeBack : locale.createAccount,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      if (!isLogin) ...[
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Benutzername',
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Bitte Namen eingeben'
                              : null,
                          onSaved: (value) => username = value?.trim() ?? '',
                        ),
                        const SizedBox(height: 20),
                      ],
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: locale.email),
                        validator: (value) =>
                            value == null || !value.contains('@')
                            ? 'Gültige E-Mail eingeben'
                            : null,
                        onChanged: (value) => email = value.trim(),
                        onSaved: (value) => email = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: true,
                        decoration: InputDecoration(labelText: locale.password),
                        validator: (value) => value == null || value.length < 6
                            ? 'Passwort zu kurz (mindestens 6 Zeichen)'
                            : null,
                        onSaved: (value) => password = value ?? '',
                      ),
                      if (isLogin)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading ? null : handleResetPassword,
                            child: const Text('Passwort vergessen?'),
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: handleSubmit,
                          child: Text(isLogin ? locale.login : locale.register),
                        ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() => isLogin = !isLogin);
                              },
                        child: Text(
                          isLogin
                              ? 'Noch kein Konto? Jetzt registrieren'
                              : 'Bereits ein Konto? Hier einloggen',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
