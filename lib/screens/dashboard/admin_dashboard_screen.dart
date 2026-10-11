import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/index.dart';
import '../../providers/app_providers.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OutageProvider>().fetchOutages();
      context.read<FaultReportProvider>().fetchReports();
      context.read<MaintenanceTeamProvider>().fetchTeams();
      context.read<EmergencyAlertProvider>().fetchAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: AppSpacing.xl),
                _buildMetricsGrid(context),
                const SizedBox(height: AppSpacing.xl),
                _buildQuickActions(context),
                const SizedBox(height: AppSpacing.xl),
                _buildRecentActivity(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      authProvider.currentUser?.name ?? 'Admin',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    authProvider.logout();
                    Navigator.of(context)
                        .pushReplacementNamed('/login');
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    return Consumer3<OutageProvider, FaultReportProvider,
        MaintenanceTeamProvider>(
      builder: (context, outageProvider, reportProvider, teamProvider, _) {
        final pendingReports = reportProvider.reports
            .where((r) => r.status == ReportStatus.submitted)
            .length;
        final ongoingOutages = outageProvider.outages
            .where((o) => o.status == OutageStatus.ongoing)
            .length;
        final availableTeams = teamProvider.teams
            .where((t) => t.status == TeamStatus.available)
            .length;

        return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.2,
          children: [
            _MetricCard(
              title: 'Pending Reports',
              value: pendingReports.toString(),
              icon: Icons.assignment_outlined,
              color: AppColors.warning,
            ),
            _MetricCard(
              title: 'Ongoing Outages',
              value: ongoingOutages.toString(),
              icon: Icons.water_drop_outlined,
              color: AppColors.error,
            ),
            _MetricCard(
              title: 'Teams Available',
              value: availableTeams.toString(),
              icon: Icons.people_outlined,
              color: AppColors.success,
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          children: [
            _ActionButton(
              label: 'Schedule Outage',
              icon: Icons.event_note,
              onTap: () => Navigator.pushNamed(
                context,
                '/outage-schedule',
              ),
            ),
            _ActionButton(
              label: 'View Fault Reports',
              icon: Icons.assignment,
              onTap: () => Navigator.pushNamed(
                context,
                '/fault-reports',
              ),
            ),
            _ActionButton(
              label: 'Assign Maintenance',
              icon: Icons.assignment_turned_in,
              onTap: () => Navigator.pushNamed(
                context,
                '/assign-maintenance',
              ),
            ),
            _ActionButton(
              label: 'Send Alert',
              icon: Icons.notifications_active,
              onTap: () => Navigator.pushNamed(
                context,
                '/emergency-alert',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Consumer<FaultReportProvider>(
      builder: (context, reportProvider, _) {
        final recentReports = reportProvider.reports
            .where((r) => r.status == ReportStatus.submitted)
            .take(3)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Fault Reports',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/fault-reports'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (recentReports.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Center(
                  child: Text(
                    'No recent reports',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentReports.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final report = recentReports[index];
                  return ListTile(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/report-review/${report.id}',
                    ),
                    title: Text(report.description),
                    subtitle: Text(report.address),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(report.priority)
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        'P${report.priority}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: _getPriorityColor(report.priority),
                            ),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Color _getPriorityColor(int priority) {
    if (priority == 1) return AppColors.critical;
    if (priority == 2) return AppColors.high;
    if (priority == 3) return AppColors.medium;
    return AppColors.low;
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
