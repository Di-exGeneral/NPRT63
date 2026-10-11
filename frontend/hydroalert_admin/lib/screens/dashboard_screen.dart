import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import 'report_review_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final s = admin.summary;
    if (s == null && admin.error != null) {
      return MessageView(
        icon: Icons.cloud_off,
        message: admin.error!,
        onRetry: admin.loadAll,
      );
    }
    final newReports = admin.reports
        .where((r) => ReportStatus.open.contains(r.status))
        .take(5)
        .toList();
    final upcoming = admin.schedules.where((o) => !o.isClosed).toList()
      ..sort((a, b) => (a.startTime ?? DateTime(0))
          .compareTo(b.startTime ?? DateTime(0)));

    return RefreshIndicator(
      onRefresh: admin.loadAll,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Welcome back,', style: Theme.of(context).textTheme.bodyMedium),
          Text(user?.username ?? 'Administrator',
              style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _Metric('New reports', s?.reportsWith(ReportStatus.open),
                  Icons.assignment_late_outlined, AppColors.warning),
              _Metric(
                  'Repairs in progress',
                  s?.reportsWith(
                      [ReportStatus.assigned, ReportStatus.inProgress]),
                  Icons.build_outlined,
                  AppColors.high),
              _Metric('Ongoing outages', s?.ongoingOutages,
                  Icons.water_drop_outlined, AppColors.error),
              _Metric('Upcoming outages', s?.upcomingOutages,
                  Icons.event_outlined, AppColors.info),
              _Metric('Maintenance teams', s?.maintenanceTeams,
                  Icons.groups_outlined, AppColors.success),
              _Metric('Alerts sent', s?.alertsSent,
                  Icons.campaign_outlined, AppColors.critical),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: () => onNavigate(3),
                icon: const Icon(Icons.event_note),
                label: const Text('Schedule outage'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => onNavigate(1),
                icon: const Icon(Icons.assignment),
                label: const Text('Review reports'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => onNavigate(2),
                icon: const Icon(Icons.groups),
                label: const Text('Assign team'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error),
                onPressed: () => onNavigate(4),
                icon: const Icon(Icons.warning_amber),
                label: const Text('Emergency alert'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Reports awaiting review',
            subtitle: 'Newest resident fault reports',
            child: newReports.isEmpty
                ? const Text('No reports waiting for review.')
                : Column(
                    children: [
                      for (final r in newReports)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(r.displayTitle),
                          subtitle: Text(
                              '${r.location} · ${formatDateTime(r.timestamp)}'),
                          trailing: StatusBadge(r.status),
                          onTap: () => openReport(context, r.reportID),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: 'Current and upcoming outages',
            subtitle: 'Affected areas and restoration times',
            child: upcoming.isEmpty
                ? const Text('No outages scheduled.')
                : Column(
                    children: [
                      for (final o in upcoming.take(5))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            o.isOngoing
                                ? Icons.water_drop
                                : Icons.event_outlined,
                            color: o.isOngoing
                                ? AppColors.error
                                : AppColors.info,
                          ),
                          title: Text(admin.areaName(o.areaID)),
                          subtitle: Text(
                              '${formatDateTime(o.startTime)} → restored by ${formatDateTime(o.endTime)}'),
                          trailing: StatusBadge(o.status),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon, this.color);
  final String label;
  final int? value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: SectionCard(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value?.toString() ?? '–',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
