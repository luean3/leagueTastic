import 'package:flutter/material.dart';
import 'package:leaguetastic/core/theme/app_colors.dart';
import 'package:leaguetastic/l10n/app_localizations.dart';

import '../controllers/auth_controller.dart';

/// Login- und Registrierungsformular für Firebase-Auth.
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

  String email = "";
  String password = "";
  String username = "";

  Future<void> handleSubmit() async {
    if (_formKey.currentState!.validate()) {
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
                  ? "Login fehlgeschlagen. Daten prüfen."
                  : "Registrierung fehlgeschlagen. E-Mail evtl. schon vergeben.",
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary, // bewusst behalten (Brand Color)
              child: Text(
                "LeagueTastic",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // OK: Brand Header bleibt fix
                ),
              ),
            ),

            const SizedBox(height: 30),

            // TITLE
            Text(
              isLogin ? loc.welcomeBack : loc.createAccount,
              style: textTheme.titleLarge?.copyWith(
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
                      // USERNAME
                      if (!isLogin) ...[
                        TextFormField(
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: InputDecoration(
                            labelText: "Benutzername",
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? "Bitte Namen eingeben" : null,
                          onSaved: (value) => username = value!.trim(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // EMAIL
                      TextFormField(
                        style: TextStyle(color: colorScheme.onSurface),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "E-Mail",
                          labelStyle: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty || !value.contains("@")
                            ? "Gültige E-Mail eingeben"
                            : null,
                        onSaved: (value) => email = value!.trim(),
                      ),

                      const SizedBox(height: 20),

                      // PASSWORD
                      TextFormField(
                        style: TextStyle(color: colorScheme.onSurface),
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Passwort",
                          labelStyle: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ),
                        validator: (value) => value!.length < 6
                            ? "Passwort zu kurz (min. 6 Zeichen)"
                            : null,
                        onSaved: (value) => password = value!,
                      ),

                      const SizedBox(height: 40),

                      // BUTTON / LOADING
                      if (isLoading)
                        Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: handleSubmit,
                          child: Text(isLogin ? "Einloggen" : "Registrieren"),
                        ),

                      const SizedBox(height: 20),

                      // SWITCH LOGIN / REGISTER
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                        child: Text(
                          isLogin
                              ? "Noch kein Konto? Jetzt registrieren"
                              : "Bereits ein Konto? Hier einloggen",
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
