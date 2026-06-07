import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'screens/login_screen.dart';
import 'screens/risk_map_screen.dart';
import 'screens/alert_center_screen.dart';
import 'screens/profile_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize().catchError((_) {});
  BackgroundService.initialize().catchError((_) {});
  await AuthService.instance.checkSession();
  runApp(const FloodGuardApp());
}

class FloodGuardApp extends StatelessWidget {
  const FloodGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (_, __) {
        return MaterialApp(
          title: 'Flood Guard',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: AppColors.primary,
            useMaterial3: true,
            fontFamily: 'Plus Jakarta Sans',
          ),
          home: AuthService.instance.isLoggedIn
              ? const AppShell()
              : const LoginScreen(),
        );
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _screens = const [
    RiskMapScreen(),
    AlertCenterScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}