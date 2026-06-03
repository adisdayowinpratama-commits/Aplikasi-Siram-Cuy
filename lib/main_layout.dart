import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/input_screen.dart';
import 'screens/monitor_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
  const HomeScreen(),
  const InputScreen(),    // Ganti placeholder
  const MonitorScreen(),  // Ganti placeholder
  const HistoryScreen(),  // Ganti placeholder
  const ProfileScreen(),  // Ganti placeholder
];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: theme.colorScheme.primary.withOpacity(0.18),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600);
            }
            return theme.textTheme.labelSmall?.copyWith(color: theme.hintColor);
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return IconThemeData(color: theme.colorScheme.primary);
            }
            return IconThemeData(color: theme.hintColor);
          }),
          backgroundColor: theme.cardColor,
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          elevation: 8,
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: const Icon(Icons.add_circle_outline), selectedIcon: const Icon(Icons.add_circle), label: 'Input'),
            NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart), label: 'Monitor'),
            NavigationDestination(icon: const Icon(Icons.history_outlined), selectedIcon: const Icon(Icons.history), label: 'History'),
            NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}