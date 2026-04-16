import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      home: const MainNavigation(),
    );
  }
}