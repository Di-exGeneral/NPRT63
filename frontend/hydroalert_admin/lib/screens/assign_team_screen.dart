import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../widgets/common.dart';
import 'report_review_screen.dart';

class AssignTeamScreen extends StatelessWidget {
  const AssignTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final pending = admin.reports
        .where((r) => ReportStatus.open.contains(r.status))
        .toList();
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SectionCard(
          title: 'Reports waiting for a team',
          subtitle: 'Approve a report and assign it to a maintenance team',
          child: pending.isEmpty
              ? const Text('All reports have been assigned.')
              : Column(
                  children: [
                    for (final r in pending)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(r.displayTitle),
                        subtitle: Text(r.location),
                        onTap: () => openReport(context, r.reportID),
                        trailing: FilledButton(
                          onPressed: () async {
                            if (await showAssignTeamDialog(context, r) &&
                                context.mounted) {
                              showSnack(context, 'Team assigned');
                            }
                          },
                          child: const Text('Assign'),
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionCard(
          title: 'Maintenance teams',
          subtitle: 'Current workload',
          child: admin.teams.isEmpty
              ? const Text('No maintenance teams are registered yet.')
              : Column(
                  children: [
                    for (final t in admin.teams)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: (t.activeAssignments == 0
                                  ? AppColors.success
                                  : AppColors.warning)
                              .withValues(alpha: 0.15),
                          child: const Icon(Icons.engineering),
                        ),
                        title: Text(t.name),
                        subtitle: Text('${t.email} · ${t.phoneNumber}'),
                        trailing: Text(t.activeAssignments == 0
                            ? 'Available'
                            : '${t.activeAssignments} active'),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
