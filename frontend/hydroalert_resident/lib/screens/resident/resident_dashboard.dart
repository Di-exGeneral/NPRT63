import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../services/fault_report_provider.dart';
import '../../services/outage_provider.dart';
import '../../services/notification_provider.dart';
import '../../services/auth_provider.dart';
import 'my_reports_screen.dart';
import 'outage_schedule_screen.dart';
import 'notifications_screen.dart';
import 'report_issue_screen.dart';
import 'profile_screen.dart';
import '../../models/area_model.dart';
import '../../services/area_provider.dart';

class ResidentDashboard extends StatefulWidget {
  const ResidentDashboard({super.key});

  @override
  State<ResidentDashboard> createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _DashboardHome(),
    const OutageScheduleScreen(),
    const ReportIssueScreen(),
    const MyReportsScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Outages'),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem_outlined), activeIcon: Icon(Icons.report_problem), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'My Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatefulWidget {
  const _DashboardHome();

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  @override
  void initState() {
    super.initState();
    final resident = context.read<AuthProvider>().resident;
    if (resident != null) {
      context.read<FaultReportProvider>().fetchMyReports(resident.residentID);
    }

    context.read<AreaProvider>().fetchAreas();
    context.read<OutageProvider>().fetchOutages();
    context.read<NotificationProvider>().fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<FaultReportProvider>();
    final outages = context.watch<OutageProvider>();
    final notifications = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Row(
          children: [
            const Icon(Icons.water_drop, color: Colors.white),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HydroAlert', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Dashboard', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined, color: Colors.white),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coming soon')),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AuthProvider>(
              builder: (context, auth, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${auth.user?.username ?? 'Resident'}!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Consumer<AreaProvider>(
                    builder: (context, areaProvider, _) {
                      final resident = context.read<AuthProvider>().resident;
                      final area = areaProvider.areas.firstWhere(
                            (a) => a.id == resident?.areaID,
                        orElse: () => AreaModel(id: '', suburbName: 'No area selected', municipalityName: ''),
                      );
                      return Text(
                        'Service Area: ${area.suburbName}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatCard(label: 'Upcoming Outages', value: outages.outages.length.toString(), icon: Icons.calendar_today, color: AppColors.primaryLight, iconColor: AppColors.primary),
                const SizedBox(width: 12),
                _StatCard(label: 'Active Alerts', value: '0', icon: Icons.warning_outlined, color: const Color(0xFFFFEBEB), iconColor: AppColors.error),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _StatCard(label: 'My Reports', value: reports.reports.length.toString(), icon: Icons.water_drop_outlined, color: const Color(0xFFF3E8FF), iconColor: const Color(0xFF7C3AED)),
                const SizedBox(width: 12),
                _StatCard(label: 'Notifications', value: notifications.unreadCount.toString(), icon: Icons.notifications_outlined, color: const Color(0xFFFFFBEB), iconColor: AppColors.warning),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Scheduled Outages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                TextButton(
                  onPressed: () {
                    final dashboard = context.findAncestorStateOfType<_ResidentDashboardState>();
                    dashboard?.setState(() => dashboard._currentIndex = 1);
                  },
                  child: const Text('View All →', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (outages.outages.isEmpty)
              const Text('No scheduled outages', style: TextStyle(color: AppColors.textSecondary))
            else
              ...outages.outages.take(2).map((o) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(o.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(o.description),
                  trailing: const Icon(Icons.access_time, color: AppColors.textSecondary),
                ),
              )),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Recent Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                TextButton(
                  onPressed: () {
                    final dashboard = context.findAncestorStateOfType<_ResidentDashboardState>();
                    dashboard?.setState(() => dashboard._currentIndex = 3);
                  },
                  child: const Text('View All →', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (reports.reports.isEmpty)
              const Text('No reports submitted yet', style: TextStyle(color: AppColors.textSecondary))
            else
              ...reports.reports.take(2).map((r) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(r.location),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(r.status, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                  ),
                ),
              )),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    label: 'Report an Issue',
                    subtitle: 'Submit a water-related problem',
                    icon: Icons.report_problem_outlined,
                    color: AppColors.reportCard,
                    onTap: () {
                      final dashboard = context.findAncestorStateOfType<_ResidentDashboardState>();
                      dashboard?.setState(() => dashboard._currentIndex = 2);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    label: 'Outage Schedule',
                    subtitle: 'View planned maintenance',
                    icon: Icons.calendar_today_outlined,
                    color: AppColors.outageCard,
                    onTap: () {
                      final dashboard = context.findAncestorStateOfType<_ResidentDashboardState>();
                      dashboard?.setState(() => dashboard._currentIndex = 1);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _QuickActionCard(
              label: 'Notifications',
              subtitle: '${notifications.unreadCount} unread alerts',
              icon: Icons.notifications_outlined,
              color: AppColors.notificationCard,
              onTap: () {
                final dashboard = context.findAncestorStateOfType<_ResidentDashboardState>();
                dashboard?.setState(() => dashboard._currentIndex = 4);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}