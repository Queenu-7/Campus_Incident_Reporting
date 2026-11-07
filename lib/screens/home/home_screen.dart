import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../profile/profile_screen.dart';
import '../reports/new_report_screen.dart';
import '../reports/reports_list_screen.dart';
import '../staff/staff_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final IncidentProvider _incidents;

  @override
  void initState() {
    super.initState();
    // Start the live Firestore stream once we are logged in.
    _incidents = context.read<IncidentProvider>();
    _incidents.startListening();
  }

  @override
  void dispose() {
    _incidents.stopListening(); // stop when we log out
    super.dispose();
  }

  void _goToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final isStaff = context.watch<AuthProvider>().isStaff;

    final pages = <Widget>[
      DashboardScreen(
        onNewReport: () => _goToTab(2),
        onSeeAll: () => _goToTab(1),
      ),
      const ReportsListScreen(),
      NewReportScreen(onSubmitted: () => _goToTab(1)),
      if (isStaff) const StaffScreen(),
      const ProfileScreen(),
    ];

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.list_alt_outlined),
        selectedIcon: Icon(Icons.list_alt),
        label: 'Reports',
      ),
      const NavigationDestination(
        icon: Icon(Icons.add_circle_outline),
        selectedIcon: Icon(Icons.add_circle),
        label: 'Report',
      ),
      if (isStaff)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Staff',
        ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      // IndexedStack keeps each tab alive, so a half-filled form isn't lost.
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _goToTab,
        destinations: destinations,
      ),
    );
  }
}
