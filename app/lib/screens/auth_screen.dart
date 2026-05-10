import 'package:flutter/material.dart';
import 'package:leaguetastic/core/theme/app_colors.dart';
import 'package:leaguetastic/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool isLogin = true;
  bool isLoading = false;

  String email = "";
  String password = "";
  String username = "";

  Future<void> handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => isLoading = true);

      dynamic user;

      if (isLogin) {
        user = await _authService.loginWithEmail(email, password);
      } else {
        user = await _authService.registerWithEmail(email, password, username);
      }

      setState(() => isLoading = false);

      if (user != null) {
        print("Erfolg! User: ${user.email}");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(isLogin
                ? "Login fehlgeschlagen. Daten prüfen."
                : "Registrierung fehlgeschlagen. E-Mail evtl. schon vergeben."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: const Text(
                "LeagueTastic",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // DYNAMISCHE ÜBERSCHRIFT
            Text(
              isLogin ? "Willkommen zurück" : "Neues Konto erstellen",
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w500,
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
                      // username
                      if (!isLogin) ...[
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: "Benutzername",
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white24)),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? "Bitte Namen eingeben" : null,
                          onSaved: (value) => username = value!.trim(),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // email
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "E-Mail",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24)),
                        ),
                        validator: (value) =>
                            value!.isEmpty || !value.contains("@")
                                ? "Gültige E-Mail eingeben"
                                : null,
                        onSaved: (value) => email = value!.trim(),
                      ),

                      const SizedBox(height: 20),

                      // password
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Passwort",
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white24)),
                        ),
                        validator: (value) =>
                            value!.length < 6 ? "Passwort zu kurz (min. 6 Zeichen)" : null,
                        onSaved: (value) => password = value!,
                      ),

                      const SizedBox(height: 40),

                      if (isLoading)
                        const Center(
                            child: CircularProgressIndicator(color: AppColors.primary))
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: handleSubmit,
                          child: Text(
                            isLogin ? "Einloggen" : "Registrieren",
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),

                      const SizedBox(height: 20),

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
                          style: const TextStyle(color: Colors.white70),
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
