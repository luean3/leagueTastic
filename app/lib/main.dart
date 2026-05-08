import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:leaguetastic/screens/auth_screen.dart';
import 'package:leaguetastic/services/auth_service.dart';
import 'package:leaguetastic/services/deep_link_service.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final deepLinkService = DeepLinkService();
  deepLinkService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.userStatus,
      builder: (context, snapshot) {
        // Falls die Verbindung noch aufgebaut wird
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Wenn ein User eingeloggt ist -> MainNavigation (inkl. HomeScreen)
        if (snapshot.hasData) {
          return const MainNavigation();
        }

        // Wenn kein User eingeloggt ist -> AuthScreen
        return const AuthScreen();
      },
    );
  }
}
