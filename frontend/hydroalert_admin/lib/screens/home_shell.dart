import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import 'alerts_screen.dart';
import 'areas_screen.dart';
import 'assign_team_screen.dart';
import 'dashboard_screen.dart';
import 'fault_reports_screen.dart';
import 'outage_schedule_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _destinations = [
    (Icons.dashboard_outlined, 'Dashboard'),
    (Icons.assignment_outlined, 'Fault Reports'),
    (Icons.groups_outlined, 'Assign Team'),
    (Icons.event_note_outlined, 'Outages'),
    (Icons.warning_amber_outlined, 'Alerts'),
    (Icons.map_outlined, 'Areas'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AdminProvider>().loadAll(),
    );
  }

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final auth = context.read<AuthProvider>();
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final pages = [
      DashboardScreen(onNavigate: _goTo),
      const FaultReportsScreen(),
      const AssignTeamScreen(),
      const OutageScheduleScreen(),
      const AlertsScreen(),
      const AreasScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_destinations[_index].$2),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: admin.isLoading ? null : admin.loadAll,
          ),
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
        bottom: admin.isLoading
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: Row(
        children: [
          if (wide)
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: _goTo,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                      icon: Icon(d.$1), label: Text(d.$2)),
              ],
            ),
          Expanded(child: pages[_index]),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _goTo,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(icon: Icon(d.$1), label: d.$2),
              ],
            ),
    );
  }
}
