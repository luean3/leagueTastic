import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/challenge_search_screen.dart';
import '../screens/create_screen.dart';
import '../screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    // Die Screens bleiben im PageView, damit Tab-Wechsel und Rücksprünge die
    // Bottom-Navigation nicht aus dem Widget-Baum entfernen.
    screens = [
      HomeScreen(),
      const ChallengeSearchScreen(),
      CreateScreen(onChallengeCreated: _openHomeTab),
      const ProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  void _openHomeTab() {
    _pageController.jumpToPage(0);
    setState(() {
      currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.cardColor,
        currentIndex: currentIndex,
        onTap: onTabTapped,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.5),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
        ],
      ),
    );
  }
}
