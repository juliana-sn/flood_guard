import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/risk_map_screen.dart';
import 'screens/alert_center_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_nav.dart';

void main() {
  runApp(const LumenOrbitApp());
}

class LumenOrbitApp extends StatelessWidget {
  const LumenOrbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumen Orbit',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int selectedIndex = 0;
  final screens = const [
    RiskMapScreen(),
    AlertCenterScreen(),
    ProfileScreen(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
